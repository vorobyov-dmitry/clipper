#include "new.ch"
#include "pass.ch"
// Условие учета количества - не перекачка и не кормо - дни
// (ИЗ перекачки берется только горючее )
#DEFINE COND1 (funnum->vdoc <> 51.OR.funnum->kopr=='05') .AND. funnum->kopr<>'00'
STATIC m_sch1:="05,07,08,09,10,12,40,41         "
STATIC m_sch2:="09                                 "
MEMVAR m_tabn,m_oper,m_level,m_syspath,m_workpath,a_menu,m_imja,m_sprpath,m_proc,m_copypath,p_npr
MEMVAR m_vdisk,m_bufpath,m_mainpath,m_mash,m_struct,m_exepath,m_shapka,m_temppath
MEMVAR m_virtdisk,m_menu_name,m_kassapath,m_1

Function DispOst(var)
local m_screen,i:=0,j:=0,n_menu:=1
local a_choice:={}
local m_key:=0,x:=8,y:=10
LOCAL m_time:=TIME(),m_pol,getlist:={},m_parol,m_str:=""
LOCAL s_files:={}
AADD(a_choice,"Вихiд")
AADD(a_choice,"Перевiрка кодiв карток         ")
AADD(a_choice,"Перегляд звiту перевiрки       ")
AADD(a_choice,"Формування залишкiв             ")
AADD(a_choice,"Перегляд звiту формування       ")
KSETNUM(.t.)
SETBLINK(.F.)
SETSHARE(4)
Beginit (var)
vhod()
IF m_tabn=="****".AND.m_oper=="**"
      m_imja := 'Адмiнiстратор'
      m_pol  := 'ий '
ELSE
      NET USE (m_sprpath+"SP10") INDEX (m_sprpath+"SP10") READONLY
      sp10->(DBSEEK(m_tabn))
      IF .NOT. sp10->(Found ())
         DispErr("Табельний номер "+m_tabn+";вiдсутнiй в справочнику працiвникiв")
         m_imja = "Незнайомец"
         m_pol = 'ий '
      ELSE
      m_imja = Alltrim ( SP10 -> IMJA ) + ' ' + Alltrim ( SP10 -> OTCH )
      IF  UPPER(SP10->POL)=='М'
            m_pol = 'ий '
          ELSE
            m_pol = 'а  '
      ENDIF
      ENDIF
      CLOSE sp10
ENDIF
wboard(0,0,maxrow(),maxcol())
wmode(.t.,.t.,.t.,.t.)
SET KEY K_F10 TO Calcul
InitParPrn()

    j:= 40
    i:=1;AEVAL(a_choice,{|x|a_choice[i]:=PADR(a_choice[i],j),i++})
    m_screen:=SAVESCREEN (x,y ,x+LEN(a_choice)+2,x+j+6)
    @x,y,x+LEN(a_choice)+1,y+j+4 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ("n/bg")
    @x,y+2 SayDisp ' '+" Формування залишкiв "+' ' COLOR "w+/Bg"
    SHADOW(x,y,x+LEN(a_choice)+1,y+j+4 )
    FOR i:=1 TO LEN(a_choice)
      @x+i,y+2 SayDisp STR(i-1,1)+' '+a_choice[i] COLOR (IF(n_menu==i,"gr+/b","n/bg"))
    NEXT
      DO WHILE .t.
        m_key:=INKEY(0)
        DO CASE
          CASE m_key==K_ESC.OR.m_key==ASC("0")
            EXIT
          CASE m_key==K_PGDN
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_PGUP
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_DOWN.AND.n_menu<LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=n_menu+1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_UP.AND.n_menu>1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=n_menu-1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE CHR(m_key)>="0".AND.m_key<=ASC("0")+LEN(a_choice)
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "n/bg"
            n_menu:=m_key-ASC("0")+1
            @n_menu+x,y+2 SayDisp STR(n_menu-1,1)+' '+a_choice[n_menu] COLOR "gr+/b"
          CASE m_key==K_ENTER
              DO CASE
                CASE n_menu==1
                  EXIT
                CASE n_menu==2
                  Check01()
                CASE n_menu==3
                  ViewOtch("99")
              CASE n_menu==4
                  FormOst()
              CASE n_menu==5
                  ViewOtch("98")
              ENDCASE
          CASE m_key==K_F10;calcul()
        ENDCASE
      ENDDO
      RESTSCREEN(x,y ,x+LEN(a_choice)+2,x+j+6,m_screen)
Return .t.

Function Check01
LOCAL m_scr1:=DispMessage("Перевiрка карток;облiку ТМЦ"),;
m_gauge:=InitGauge("Перегляд карток",2),m_ksash,i:=1,n_win1,m_kod,;
n_error:=0
SETPRC(0,0)
SET PRINTER TO (m_workpath+"99.txt")
SET PRINTER ON
NET USE (m_workpath+"kaptka1") NEW READONLY
INDEX ON kaptka1->ksash TO (m_temppath+"kaptka1")
kaptka1->(DBGOTOP())
m_ksash:=kaptka1->ksash
m_kod:=kaptka1->kod
kaptka1->(DBSKIP())
n_win1:=WOPEN(0,0,8,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC("Перевiрка карток",80) COLOR "n/w"
SETPOS(0,0)
Wselect(0)
DO WHILE .NOT.kaptka1->(EOF())
  IF m_ksash==kaptka1->ksash
    WSELECT(n_win1)
    ?" Код облiку ТМЦ "+kaptka1->kod +" спiвпадає з кодом "+m_kod
    BeepErr()
    n_error++
    Wselect(0)
  ENDIF
  m_ksash:=kaptka1->ksash
  m_kod:=kaptka1->kod
  m_gauge:=DispGauge(m_gauge,i++/kaptka1->(LASTREC()))
  kaptka1->(DBSKIP())
ENDDO
CLOSE kaptka1
WSELECT(n_win1)
?"Знайдено "+STRZERO(n_error,3)+" помилок"
INKEY(5)
Wclose(n_win1)
SET PRINTER OFF
SET PRINTER TO
WSELECT(0)
DelGauge(m_gauge)
DelMessage(m_scr1)
FERASE(m_temppath+"kaptka1.ntx")
RETURN .t.
FUNCTION   FormOst()

LOCAL   m_mol :='  '
LOCAL   a_sub := {}
LOCAL   m_proc,m_fcsh,m_fshzp,m_fshzp0,m_month1,l,m_proc1
LOCAL   m_screen := ' ',m_sch := ' ',m_gauge
LOCAL   m_glvm,m_str1,n_win1,n_error:=0
LOCAL m_month:=12,s_file:={}
NET USE (m_workpath+"Kaptka1") NEW
m_sch1:=""
DO WHILE .NOT.kaptka1->(EOF())
  IF AT(LEFT(kaptka1->ksash,2),m_sch1)==0
    m_sch1+=LEFT(kaptka1->ksash,2)+","
  ENDIF
  kaptka1->(DBSKIP())
ENDDO
INDEX ON kaptka1->ksash TO (m_temppath+"kaptka1")
m_sch1:=LEFT(m_sch1,LEN(m_sch1)-1)+"          "
NET USE (m_vdisk+"DBROWSE") INDEX (m_vdisk+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_vdisk+"DBRTB") INDEX (m_vdisk+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_vdisk+"SPVIEW") INDEX (m_vdisk+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_vdisk+"Screen") INDEX (m_vdisk+"Screen")     NEW READONLY
NET USE (m_vdisk+"tbget") INDEX (m_vdisk+"tbget")       NEW READONLY
SopenFiles("SP02",@s_file)
NET USE  d:\buhgal\mn\funnum  NEW
NET USE   d:\buhgal\mn\fdbcr  NEW
NET USE   d:\buhgal\mn\fglv   NEW
NET USE d:\buhgal\sp\SP22 INDEX d:\buhgal\sp\SP22 NEW
SELECT 0
CREATE (m_temppath+"buf1") from d:\buhgal\st\fmstr76
SELECT 0
CREATE (m_temppath+"buf2") from d:\buhgal\st\fmstr77
INDEX ON buf2->subsch+buf2->mol TO (m_temppath+"buf2")
//
a_sub:=GetScht(@m_mol,@m_month)
IF EMPTY(a_sub)
  CLOSE ALL
  RETURN 0
ENDIF

m_fshzp := fdbcr->(LASTREC())
m_fcsh  := 0
m_gauge:=InitGauge("Перегляд основної бази даних",2)
m_str1:=DispMessage("Формування залишкiв по МВО;"+ALLTRIM(m_mol+" "+_mol(m_mol))+"за "+MyMonth(m_month))
DO WHILE .NOT.fdbcr->(EOF())
   m_fcsh++
  IF ASCAN(a_sub,SUBSTR(fdbcr->dbt,1,2)) <> 0 .OR. ASCAN(a_sub,SUBSTR(fdbcr->crt,1,2))<>0
    IF .NOT.Pfilpoz("funnum","vnum","fdbcr")
      l:=fdbcr->vnum
      DO WHILE fdbcr->vnum == l.and..NOT.fdbcr->(EOF())
         m_fcsh++
         SKIP ALIAS fdbcr
      ENDDO
      LOOP
    ENDIF
    m_month1:=IF(Day(funnum->ddoc)>26,Month(funnum->ddoc)+1,Month(funnum->ddoc))
    IF  m_month1>m_month.OR.(funnum->otp<>m_mol.AND.funnum->kplh<>m_mol)
      DO WHILE fdbcr->vnum == funnum->vnum.and..NOT.fdbcr->(EOF())
         SKIP ALIAS fdbcr
         m_fcsh++
      ENDDO
      LOOP
    ENDIF
    m_glvm:=0
    IF funnum->vdoc>=200.and.funnum->vdoc<=399                            && Условие наличия голов
      IF Pfilpoz("fglv","vnum","funnum")
         m_glvm:=fglv->glv
      ENDIF
    ENDIF
    IF m_glvm<>0.OR.fdbcr->kvo<>0.OR.fdbcr->stm<>0
      IF m_glvm<>0.OR.fdbcr->kvo<>0.OR.fdbcr->stm<>0
        SELECT buf2
        IF ASCAN(a_sub,SUBSTR(fdbcr->dbt,1,2)) <> 0
          SEEK fdbcr->dbt+funnum->kplh
          IF.NOT.FOUND()
            APPEND BLANK
            REPLACE buf2->subsch WITH fdbcr->dbt
            REPLACE buf2->mol    WITH funnum->kplh
            REPLACE buf2->sum    WITH 0
            REPLACE buf2->kvo    WITH 0
            REPLACE buf2->glv    WITH 0
          ENDIF
          REPLACE buf2->glv    WITH buf2->glv + m_glvm
          REPLACE buf2->sum WITH buf2->sum+fdbcr->stm
          IF funnum->vdoc == 1 .OR. funnum->vdoc == 2 .OR. funnum->vdoc == 3
               sp22->(DBSEEK(STRZERO(m_month1,2) + SUBSTR(fdbcr->dbt,5,2)))
               REPLACE buf2->kvo    WITH buf2->kvo+ROUND(fdbcr->kvo * sp22->koef,2)
          ELSE
               IF COND1
                  REPLACE buf2->kvo    WITH buf2->kvo+fdbcr->kvo
               ENDIF
          ENDIF
        ENDIF
        IF ASCAN(a_sub,SUBSTR(fdbcr->crt,1,2)) <> 0
          SEEK fdbcr->crt+funnum->otp
          IF.NOT.FOUND()
            APPEND BLANK
            REPLACE buf2->subsch WITH fdbcr->CRT
            REPLACE buf2->mol    WITH funnum->otp
            REPLACE buf2->sum    WITH 0
            REPLACE buf2->kvo    WITH 0
            REPLACE buf2->glv    WITH 0
          ENDIF
          IF funnum->vdoc == 1 .OR. funnum->vdoc == 2 .OR. funnum->vdoc == 3
            sp22->(DBSEEK(STRZERO(m_month1,2) + SUBSTR(fdbcr->crt,5,2)))
            REPLACE buf2->kvo    WITH buf2->kvo-ROUND(fdbcr->kvo * sp22->koef,2)
          ELSE
            IF COND1
               REPLACE buf2->kvo    WITH buf2->kvo-fdbcr->kvo
            ENDIF
          ENDIF
          REPLACE buf2->sum WITH buf2->sum-fdbcr->stm
          REPLACE buf2->glv    WITH buf2->glv - m_glvm
        ENDIF
      ENDIF
    ENDIF
  ENDIF
  m_gauge:=DispGauge(m_gauge,fdbcr->(RECNO())/fdbcr->(LASTREC()))
  fdbcr->(DBSKIP())
ENDDO
DelGauge(m_gauge)
DelMessage(m_str1)
CLOSE  fdbcr
CLOSE  funnum
CLOSE  fglv
SETPRC(0,0)
SET PRINTER TO (m_workpath+"98.txt")
SET PRINTER ON
n_win1:=WOPEN(0,0,20,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC("Формування залишкiв",80) COLOR "n/w"
SETPOS(0,0)
NET USE (m_workpath+"spr03") NEW
DO WHILE .NOT.spr03->(EOF())
  IF Spr03->year==YEAR(DATE()).AND.Spr03->mol==m_mol
    Spr03->(DBDELETE())
  ENDIF
 Spr03->(DBSKIP())
ENDDO
Spr03->(__dbPack())
INDEX ON STR(spr03->year,4)+spr03->kod+spr03->mol TO (m_workpath+"spr03")
INDEX ON STR(spr03->year,4)+spr03->mol+spr03->kod TO (m_workpath+"spr03a")
SET INDEX TO
SET INDEX TO (m_workpath+"spr03"),(m_workpath+"spr03a")
Spr03->(DBSETORDER(1))
buf2->(DBGOTOP())
DO WHILE .NOT.buf2->(EOF())
  IF kaptka1->(DS(buf2->subsch))
    IF .NOT.spr03->(DS(STR(YEAR(DATE()),4)+kaptka1->kod+m_mol))
      Spr03->(DBAP())
      Spr03->year:=YEAR(DATE())
      Spr03->kod:=kaptka1->kod
      Spr03->mol:=m_mol
      Spr03->kvo:=buf2->kvo
      Spr03->glv:=buf2->glv
      Spr03->stm:=buf2->sum
      ?"Залишок по ",ALLTRIM(Kaptka1->name)+" ("+ALLTRIM(kaptka1->kod)+")"
      ?"      Кiльк=",buf2->kvo,"Сума=",buf2->sum
    ELSE
      ?"*** Подвоєння записiв! Залишок по iгнорується ",Kaptka->name
      ?"    ",buf2->subsch,"Кiльк=",buf2->kvo,"Сума=",buf2->sum
      n_error++
    ENDIF
  ELSE
    ?"*** Код "+buf2->subsch +" не знайдено у картках облiку i тому iгнорується"
    ?"      Кiлькiсть ="+ALLTRIM(STR(buf2->kvo))+" Сума="+ALLTRIM(STR(buf2->sum))
    n_error++
  ENDIF
  buf2->(DBSKIP())
ENDDO
CLOSE buf2
WSELECT(n_win1)
?"Знайдено "+STRZERO(n_error,3)+" помилок"
INKEY(5)
Wclose(n_win1)
SET PRINTER OFF
SET PRINTER TO
WSELECT(0)
CLOSE ALL
RETURN .t.
STATIC FUnction GetScht(m_mol,m_month)
LOCAL a_sub:={},m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL()),m_str:="",i,GetList:={}
SET ESCAPE ON
@10,5,15,75 BOX B_SINGLE COLOR "w/b"
@11,6 SAY "Комiрник>" COLOR "w/b"
@12,6 SAY "Рахунки >" COLOR "w/b"
@13,6 SAY "Мiсяць  >" COLOR "w/b"
@11,16 Get m_mol VALID Sp02->(sp_vl("SP02",,11,20,"_mol(sp02->mol)","GR+/B")) COLOR "GR+/N"
@12,16 Get m_sch1 COLOR "GR+/N"
@13,16 Get m_month VALID(m_month>=1.AND.m_month<=12) PICTURE "99" COLOR "GR+/N"
READ
IF LASTKEY()==K_ESC
  RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
  RETURN a_sub
ENDIF
m_str:=ALLTRIM(m_sch1)
@13,20 SayDisp MyMonth(m_month) COLOR "GR+/b"
DO WHILE .NOT.EMPTY(m_str)
  i:=AT(",",m_str)
  IF i<>0
    AADD(a_sub,SUBSTR(m_str,1,i-1))
    m_str:=SUBSTR(m_str,i+1,LEN(m_str))
  ELSE
    AADD(a_sub,m_str)
    m_STR:=""
  ENDIF
ENDDO
RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
RETURN a_sub
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION pFilPoz(m_nmfl_1, m_nmpl_1, m_nmfl_2)

LOCAL  m_fict_zap
LOCAL  m_fict_al
PRIVATE m_1
m_fict_al := SELECT()
SELECT (m_nmfl_1)
m_fict_zap :=  RECNO()
m_1 := ALLTRIM(m_nmfl_2) + '->' + ALLTRIM(m_nmpl_1)
LOCATE  REST  FOR  &(m_nmpl_1) == &(m_1)
IF  FOUND()
     SELECT( m_fict_al )
     RETURN( .T. )
   ELSE
     GOTO m_fict_zap
     SELECT( m_fict_al )
     RETURN( .F. )
ENDIF
RETURN( .F. )
FUNCTION BegInit (m_var)

   LOCAL SwapingSpace := 3,s1:=LOWER(EXENAME()),i // количество свободного пространства
                                     // на диске в Мбайтах, необходимое для
                                     // работы АРМ "Бухгалтер"

   // ----------------------------------------------------
   // --- УСТАHОВKА ПАРАМЕТРОВ, ОБЩИХ ДЛЯ ВСЕЙ СИСТЕМЫ ---
   // ----------------------------------------------------
   SetCancel ( .f. )
   SetCursor ( 0 )
   setblink(.f.)

   Set ( _SET_ESCAPE     , .t. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   PUBLIC   m_workpath   := 'd:\buh\plat\'   // каталог с текущей БД
   PUBLIC   m_kassapath   := 'd:\buh\kassa\' // каталог с кассой
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // каталог с буферной БД
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // каталог со справочниками
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // каталог для .EXE модуля пакета
   PUBLIC   m_shapka    := 'd:\buhgal\nf\'  // каталог для шапок машинограмм
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // каталог для машинограмм
   PUBLIC   m_struct    := 'd:\buhgal\st\'  // каталог с пустыми структурами
                                           // файлов
   PUBLIC   m_syspath   := 'd:\buhgal\js\'  // каталог с  системной информацией
   PUBLIC   m_vdisk     := 'd:\buhgal\vd\'  // электронный диск !!!!!!!!!!!!!!!
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // каталог для копий
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // каталог с буферной БД
   IF .NOT.EMPTY(m_var)
      USE init NEW READONLY
      IF VAL(m_var)>0.AND.VAL(m_var)<=LASTREC()
        DBGOTO(VAL(m_var))
        m_workpath  :=ALLTRIM(init->nk)
        m_bufpath   :=ALLTRIM(init->bf)
        m_mainpath  :=ALLTRIM(init->mn)
        m_sprpath   :=ALLTRIM(init->sp)
        m_exepath   :=ALLTRIM(init->bh)
        m_shapka    :=ALLTRIM(init->nf)
        m_mash      :=ALLTRIM(init->ms)
        m_struct    :=ALLTRIM(init->st)
        m_syspath   :=ALLTRIM(init->js)
        m_vdisk     :=ALLTRIM(init->vd)
        m_copypath  :=ALLTRIM(init->cp)
        m_temppath  :=ALLTRIM(init->tp)
        m_kassapath :=ALLTRIM(init->kassa)
      ENDIF
      CLOSE init
   ENDIF
// m_syspath :="i:\"

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- код оператора ( пользователя )
   PUBLIC m_tabn     := ' '      // --- табельный N оператора ( пользователя )

   PUBLIC m_imja  := ' '         // --- имя-отчество пользователя

   NET USE (m_workpath+"pred01") NEW READONLY
   PUBLIC p_npr := AllTrim ( pred01->short )     // --- наименование предприятия
   USE

   PUBLIC a_menu:={}

   // проверка наличия свободного пространства на диске

   IF ( i := DiskSpace () ) <= ( SwapingSpace * 1048576 )
      DispErr('Для нормальної работи АРМ необхiдно '+Str ( SwapingSpace, 2 ) + ' Мбайт свободного мiсця на диску.'+;
      'Свободного мiсця '+ Str ( i / 1048576 , 5 , 2 ) + ' Мбайт. Запуск системи неможливий.')
      QUIT
   ENDIF
RETURN .t.
Function vhod()
LOCAL m_str:=space(10),x:=CHR(4)+CHR(248)+CHR(8)+"T"+CHR(6)+"D"+CHR(3)+"·╗+"
LOCAL a_user:={},i,i1,m_time,m_date:=DATE(),GetList:={}
SET CURSOR OFF
set confirm on
SET CURSOR ON
CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","▓")
CLEAREOL(0,0,"n/w")
@0,0 SayDisp DMY(DATE())+" "+CDOW(DATE()) COLOR "n/w"
@0,col()+2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
CLEAREOL(MAXROW()-1,0,"w/b","▒")
NET USE (m_vdisk+"fdor") READONLY  NEW
DO WHILE .NOT. fdor->(EOF())
IF CHECKSUM(SUBSTR(fdor->name,5,11))<>BIN2L(SUBSTR(fdor->name,1,4))
      DISPERROR("Невiрний запис номер "+STR(fdor->(RECNO()),3)+";його потрiбно удалити")
      fdor->(DBSKIP())
ENDIF
AADD(a_user,{;
CRYPT(SUBSTR(fdor->name,5,4),x),PADR(CRYPT(SUBSTR(fdor->name,10,6),x),6),val(CRYPT(SUBSTR(fdor->name,9,1),x))})
fdor->(DBSKIP())
ENDDO
CLOSE fdor
SET COLOR TO "w/b,w+/b"
i:=0
SET ESCAPE ON
DO WHILE .t.
  i++
  m_str:=SPACE(6)
@MAXROW()-1,25 SayDisp " Введiть Ваш пароль>" COLOR "gr+/b"
m_str:=GetSecret(m_str)
IF m_str==DIMA
  m_tabn:=REPLICATE(CHR(42),4);m_oper:=REPLICATE(CHR(42),2);m_level:=0
  EXIT
ENDIF

IF i==3
  DispError("Всс спроби вичерпано,;До побачення !!!!")
  quit
ENDIF
IF LASTKEY()==K_ESC
  IF ANSWER("Вийти iз системи?")==YES
    QUIT
  ENDIF
ENDIF
IF (i1:=ASCAN(a_user,{|x|x[2]==m_str}))==0
  DispError("Пароль невiрен")
ELSE
  m_oper:=STR(i1+32,2)
  m_tabn :=a_user[i1][1]
  IF POSALPHA(m_tabn)<>0
    DispError("Помилка в табельному номерi")
    QUIT
  ENDIF
  m_level:=a_user[i1][3]
  IF POSALPHA(m_level)<>0
    DispError("Помилка в приорiтетi")
    QUIT
  ENDIF
  EXIT
ENDIF
ENDDO
SET ESCAPE OFF
  @02,14,06,66 BOX B_DOUBLE+" " color "W/B"
  shadow(02,14,06,66)
  @03,26 SayDisp "Сьогоднi "+my_Dtos(m_date)+" "+My_Cdow(m_date) COLOR "w+/b"
  @05,30 SayDisp "Дата>" COLOR "W+/B"
  @04,30 SayDisp "Час> " COLOR "W+/B"
  m_time:=TIME()
  @04,37 GET m_time COLOR "GR+/B,GR+/N" PICTURE "99:99:99"
  @05,37 GET m_date COLOR "GR+/B,GR+/N"
  READ
  SETTIME(m_time)
  SETDATE(m_date)
RETURN .t.
function my_dtos(m_ddoc,x,y)
  LOCAL a_month:={;
        " сiчня ",;
        " лютого ",;
        " березня ",;
        " квiтня ",;
        " травня ",;
        " червня ",;
        " липня ",;
        " серпня ",;
        " вересня ",;
        " жовтня ",;
        " листопада ",;
        " грудня "}
 IF .NOT.EMPTY(m_ddoc)
    IF x<>NIL.AND.y<>NIL
    @x,y Say STRZERO(DAY(m_ddoc),2)+a_month[MONTH(m_ddoc)]+STR(YEAR(m_ddoc),4)+' р.'
    ENDIF
    RETURN (STRZERO(DAY(m_ddoc),2)+a_month[MONTH(m_ddoc)]+STR(YEAR(m_ddoc),4))+' р.'
 ENDIF
RETURN ""
Function My_Cdow(m_ddoc)
  LOCAL i:=DOW(m_ddoc)
  DO CASE
    CASE i==1
      RETURN "Недiля"
    CASE i==2
      RETURN "Понедiлок"
    CASE i==3
      RETURN "Вiвторок"
    CASE i==4
      RETURN "Середа"
    CASE i==5
      RETURN "Четверг"
    CASE i==6
      RETURN "П'ятниця"
    CASE i==7
      RETURN "Субота"
ENDCASE
RETURN ""
Function ViewOtch(var)
  LOCAL m_color,n_win1
  IF .NOT.FILE(m_workpath+var+'.txt')
    DispError("Данний звiт вiдсутнiй")
    RETURN .f.
  ENDIF
  m_color:=SETCOLOR("w/b")
n_win1:=WOPEN(4,0,20,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC(" Просмотр звiта",80) COLOR "n/w"
MEMOEDIT(MEMOREAD(m_workpath+var+'.txt'),0,0,MAXROW(),MAXCOL(),.f.,"f001",254)
WCLOSE(n_win1)
WSELECT(0)
SETCOLOR(m_color)
RETURN .t.
Function f001(var1,var2,var3)
  LOCAL m_file:=m_workpath+"99.txt"
  IF var1==1.OR.var1==2
    IF LASTKEY()==K_F2
      IF ALERT("Друкувати звiт ?",{"Да","Нi"},"n/bg,w/b")==1
        IF SPOOLACTIV().AND.SPOOLCOUNT()<6
          SPOOLADD(m_file)
        ELSE
          PRINTFILE(m_file,.t.)
        ENDIF
      ENDIF
    ENDIF
  ENDIF
RETURN 0
Function MyMonth(n)
  LOCAL a_month:={;
"сiчень",;
"лютий",;
"березень",;
"квiтень",;
"травень",;
"червень",;
"липень",;
"серпень",;
"вересень",;
"жовтень",;
"листопад",;
"грудень"}
IF n>=1.AND.n<=12
  RETURN a_month[n]
ENDIF
RETURN ""

