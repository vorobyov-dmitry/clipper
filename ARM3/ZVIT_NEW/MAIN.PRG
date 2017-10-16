#include "new.ch"
#include "menu.ch"
#include "ACHOICE.ch"
#include "pass.ch"
#define DOS_LETTERS     "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюяЁёЄєЇїЎўAEI"
#define WINDOWS_LETTERS "└┴┬├─┼╞╟╚╔╩╦╠═╬╧╨╤╥╙╘╒╓╫╪┘┌█▄▌▐▀рстуфхцчшщъыьэюяЁёЄєЇїЎў°∙·√№¤■ и╕к║п┐бв└┼▓"

MEMVAR a_menu,m_mainpath,m_level,m_tabn,m_oper,m_codn,m_krpou,m_kppidpr
MEMVAR m_sprpath,m_exepath,m_syspath,m_bufpath,m_mash
MEMVAR m_copypath,m_proc,m_menu_name
MEMVAR m_workpath,m_temppath,p_npr,m_dbspath,p_sovhoz,m_pension,s_year

Function Main(var1)
LOCAL m_time:=TIME(),getlist:={},m_parol,m_str:="",i
LOCAL m_var1:=IF(EMPTY(var1),"",var1),m_imja,m_pol
CLEAR
IF numfiles()<100
  DispError("Количество дескрипторов файлов меньше 100;Измените CONFIG.SYS")
  QUIT
ENDIF
KSETCAPS(.f.)
KSETNUM(.t.)
Beginit (m_var1)
wboard(0,0,MAXROW(),MAXCOL())
i:=0

SET ESCAPE ON
SET KEY K_F10 TO Calc
InitParPrn()
NET USE ("MENUIND") INDEX ("MENUIND") ALIAS menu NEW READONLY
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY
dialog()
SET COLOR TO "w/b"
CLOSE ALL
QUIT
RETURN .t.
#DEFINE M_COLZERO  1  &&   Столбец первого меню
#DEFINE M_ROWZERO  1  &&   Строка первого меню
#DEFINE M_COLSTEP  2  &&   Сдвижка меню по горизонтали
#DEFINE M_ROWSTEP  1  &&   Сдвижка меню по вертикали
#DEFINE M_WIDTH    55 &&   Ширина меню
#DEFINE M_HIGH     12 &&   Высота меню
#DEFINE M_COLFIRST M_COLZERO+LEN(A_MENU)*M_COLSTEP && Столбец верхнего левого угла меню
#DEFINE M_ROWFIRST M_ROWZERO+LEN(A_MENU)*M_ROWSTEP && Строка  верхнего левого угла меню
#DEFINE M_COLLAST   M_COLFIRST+M_WIDTH && Столбец нижнего правого угла меню
#DEFINE M_ROWLAST   M_ROWFIRST+M_HIGH && Строка нижнего правого угла
PROCEDURE dialog
  local obj_error,m_set,old_err,m_str,j
  local l_while:=.t.
  private m_proc && Используется для макроподстановки имени процедуры
  private m_menu_name:='Головне меню ' && Используется для формирования наименования меню
   m_set:=CSetAll()

DO WHILE l_while
   old_err:=ERRORBLOCK( { |obj_error|  ArmError(obj_error) } )
   BEGIN SEQUENCE
      CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","▓")
      CLEAREOL(0,0,"n/w")
      CLEAREOL(MAXROW(),0,"n/w")
      @0,0 SayDisp DMY(DATE())+" "+MyCDOW(DOW(DATE())) COLOR "n/w"
      @0,Col()+2 SayText 'АРМ Бухгалтера "~2Б~3а~4р~5с~1" - ~6Форма IНДАНI' COLOR "b/w,rb/w,gr+/w,r/w,g+/w,b+/w"
      @MAXROW(),2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
      @MAXROW(),Col()+2 SayText "Версия №~2 001 ~1от ~222/12/99" COLOR "N/w,R/w"
   m_str:="^о{oлjutgцеdjвaamа]i[┌AJG╓JTУЮ[^Q╬ПQV╪╔┘█╙┘╫╨┌╓"
FOR j:=1 TO LEN(m_str)
  m_str:=STUFF(m_str,j,1,CHR(ASC(SUBSTR(m_str,j,1))+j+48))
NEXT
   @21,8,23,63 BOX "╔═╗║╝═╚║ " COLOR "w+/bg"
   @22,10 Say LEFT(m_str,LEN(m_str)-8)+CHR(49)+CHR(52)+CHR(45)+CHR(52)+CHR(51)+CHR(45)+CHR(56)+CHR(53) COLOR "GR+/bg"
      MENU ('001')
      l_while:=.f.
   RECOVER USING obj_error
      DBCOMMITALL()
      CLOSE ALL
      CSetAll(m_set)
      SET PRINTER TO
      SET DEVICE TO SCREEN
      asize(a_menu,0)
   END SEQUENCE
   ERRORBLOCK(old_err)

NET USE (m_syspath +"DBROWSE")  INDEX  (m_syspath+"DBROWSE")   ALIAS SPTABL  NEW READONLY
NET USE ("MENUind") INDEX ("MENUind") ALIAS menu NEW READONLY
NET USE (m_syspath +"DBRTB")    INDEX (m_syspath+"DBRTB")      ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath +"SPVIEW")   INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath +"SCREEN")   INDEX (m_syspath+"SCREEN")     NEW READONLY

      m_menu_name:=' Головне меню '
  ENDDO
RETURN

FUNCTION Menu (M_choice)
    local M_screen:=SAVESCREEN (M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+1)
    local m_recno:= MENU->(RECNO())
    local a_choice:={ "0 Вихiд"},; && Перечень пунктов меню
          a_prc:={},;            && Перечень вызываемых процедур
          a_par:={}              && Параметры процедур
    local m_key:=0,i:=ASC("0")
    @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ('w/b,gr+/n,,,n/w')
    SET COLOR TO  ( 'r+/b')
    @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM(m_menu_name)+' ',M_WIDTH -5)
    MENU->(DBseek(m_choice))
    SET COLOR TO ( 'w+/b,n/w')
    menu->(DBEVAL ({||i++,AADD(A_CHOICE, CHR(i)+" "+MENU->PUNKTNAME),AADD(A_prc, ALLTRIM(MENU->PRC));
             ,AADD(A_par, ALLTRIM(MENU->PAR))},,{||m_choice ==MENU->NUMMENU}))
    DO WHILE .T.
        m_key :=ACHOICE (M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST-1,M_COLLAST-2, A_CHOICE,,, m_key,)
      IF M_KEY==1.OR. m_key==AC_ABORT
         RESTSCREEN(M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+1,m_screen)
         MENU->(DBGOTO(m_recno))
         RETURN .T.
      ENDIF
      AADD(a_menu,a_par[m_key-1])
      m_menu_name:=a_choice[m_key]
      IF Isdigit(A_PRC[m_key-1])
         menu(ALLTRIM(A_PRC[m_key-1]))
      ELSE
         m_proc:=A_PRC[m_key-1]
         IF .NOT.EMPTY(m_proc)
         ScreenFile(m_temppath+"screen.scr")
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_temppath+"screen.scr")
         ENDIF
        ELSE
          DispError("Програма не пiдключена")
        ENDIF
         SET COLOR TO ( 'w+/b,n/w')
      ENDIF
      ASIZE(a_menu,len(a_menu)-1)
   ENDDO
RETURN .T.


FUNCTION BegInit (m_var1)

   LOCAL SwapingSpace := 3,s1:=LOWER(EXENAME()) // количество свободного пространства
                                     // на диске в Мбайтах, необходимое для
                                     // работы АРМ "Бухгалтер"

   // ----------------------------------------------------
   // --- УСТАHОВKА ПАРАМЕТРОВ, ОБЩИХ ДЛЯ ВСЕЙ СИСТЕМЫ ---
   // ----------------------------------------------------
   SetCancel ( .f. )
   SetCursor (0)
   SETBLINK(.f.)

   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   PUBLIC   m_dbspath   := ''              // каталог с текущей БД
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // каталог с буферной БД
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // каталог со справочниками
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // каталог для .EXE модуля пакета
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // каталог для машинограмм
   PUBLIC   m_syspath   := 'd:\buhgal\system\'  // каталог с  системной информацией
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // каталог для копий
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // каталог с буферной БД
   PUBLIC   m_pension   :="d:\buhgal\zvit\"
   PUBLIC   m_workpath   :="d:\buhgal\zvit\"
   PUBLIC  m_codn
   PUBLIC   p_sovhoz
   PUBLIC   m_krpou
   PUBLIC  m_kppidpr
   PUBLIC s_year
   IF .NOT.EMPTY(m_var1)
      IF .NOT.IsDigit(m_var1)
       m_mainpath  := m_var1+SUBSTR(m_mainpath  ,2)
       m_sprpath   := m_var1+SUBSTR(m_sprpath   ,2)
       m_exepath   := m_var1+SUBSTR(m_exepath   ,2)
       m_syspath   := m_var1+SUBSTR(m_syspath   ,2)
       m_bufpath   := m_var1+SUBSTR(m_bufpath   ,2)
       m_mash      := m_var1+SUBSTR(m_mash      ,2)
       m_copypath  := m_var1+SUBSTR(m_copypath  ,2)
      ELSE
        IF FILE("INIT.DBF")
          USE init NEW Readonly
          IF VAL(m_var1)>=1.AND.VAL(m_var1)<=LASTREC()
            DBGOTO(VAL(m_var1))
              m_bufpath   := ALLTRIM(init->bf)
              m_mainpath  := ALLTRIM(init->mn)
              m_sprpath   := ALLTRIM(init->sp)
              m_exepath   := ALLTRIM(init->bh)
              m_mash      := ALLTRIM(init->ms)
              m_syspath   := ALLTRIM(init->js)
              m_copypath  := ALLTRIM(init->cp)
              m_pension   := ALLTRIM(init->pn)
          ENDIF
          CLOSE init
        ENDIF
      ENDIF

  ELSE
   IF m_exepath<>LEFT(s1,LEN(m_exepath))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_mainpath  := s1+SUBSTR(m_mainpath  ,11)
       m_sprpath   := s1+SUBSTR(m_sprpath   ,11)
       m_exepath   := s1+SUBSTR(m_exepath   ,11)
       m_syspath   := s1+SUBSTR(m_syspath   ,11)
       m_bufpath   := s1+SUBSTR(m_bufpath   ,11)
       m_mash      := s1+SUBSTR(m_mash      ,11)
       m_copypath  := s1+SUBSTR(m_copypath  ,11)
       m_temppath  := s1+SUBSTR(m_temppath  ,11)
  ENDIF



 ENDIF

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- код оператора ( пользователя )
   PUBLIC m_tabn     := ' '      // --- табельный N оператора ( пользователя )


//   NET USE (m_syspath+"sovhoz") NEW READONLY
//   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- наименование предприятия
   PUBLIC p_npr := ""     // --- наименование предприятия
   p_sovhoz:=.F.
//   USE

   PUBLIC a_menu:={}
RETURN .T.
#UNDEF HIGHER
#UNDEF M_ROWFIRST
#UNDEF M_COLFIRST

#DEFINE   HIGHER 10
#DEFINE   M_ROWFIRST INT((MAXROW()-m_high)/2)+i
#DEFINE   M_COLFIRST INT((MAXCOL()-m_width)/2)+i
Function MyMenu(m_name,a_choice,m_count,l_clear)
  LOCAL m_WIDTH:=0,m_high,m_screen,m_key,i:=IF(m_count==NIL,0,m_count),;
  l_restore:=IF(l_clear==NIL,.t.,l_clear)
  AADD(a_choice,NIL)
  AINS(a_choice,1)
  a_choice[1]:="Вихiд"
  AEVAL(a_choice,{|p|IF(LEN(p)>m_width,m_width:=LEN(p),NIL)})
  IF(LEN(m_name)>m_width,m_width:=LEN(m_name),NIL)
  IF(LEN(a_choice)>HIGHER,m_high:=HIGHER,m_high:=LEN(a_choice))
  m_screen:=SAVESCREEN(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1+1,M_COLFIRST+m_width+1+2)
  @M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1,M_COLFIRST+m_width+1 ;
  BOX B_DOUBLE_SINGLE+SPACE(1) COLOR ("w+/b,gr+/n,,,w+/b")
  @M_ROWFIRST-1,M_COLFIRST SayDisp m_name COLOR ("r+/b")
  SHADOW(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1,M_COLFIRST+m_width+1)
  SETCOLOR("w+/b,n/w")
  m_key:=ACHOICE(M_ROWFIRST,M_COLFIRST,M_ROWFIRST+m_high,M_COLFIRST+m_width,a_choice)
  ADEL(a_choice,1)
  ASIZE(a_choice,LEN(a_choice)-1)
  IF(l_restore,RESTSCREEN(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1+1,M_COLFIRST+m_width+1+2,m_screen),NIL)
RETURN( IF(m_key==1.OR.m_key==0,0,m_key-1))
#UNDEF   HIGHER
#UNDEF   M_ROWFIRST
#UNDEF   M_COLFIRST
Function SetValue()
  LOCAL GetList:={},k_pen,k_boln,n_win
  n_win:=WOPEN(01,08,22,72)
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE + " " COLOR "w/bg"
  @0,2 SayDisp "Довiдкова iнформацiя" COLOR "n/w"
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  k_boln:=PADR(RESTVAR1("k_boln","PN"),50)
  k_pen:=PADR(RESTVAR1("k_pen","PN"),50)
  m_krpou:=ALLTRIM(RESTVAR1("m_krpou","PN"))
  m_kppidpr:=ALLTRIM(RESTVAR1("m_kppidpr","PN"))
  m_codn:=ALLTRIM(RESTVAR1("m_codn","PN"))
  SET ESCAPE ON
  SET CURSOR ON
  @02,2 SayDisp "Код лiкарняних>" COLOR "n/bg"
  @03,2 SayDisp "Код пенсiонного>" COLOR "n/bg"
  @04,2 SayDisp "Код пiдприємства>" COLOR "n/bg"
  @05,2 SayDisp "Код оператора>" COLOR "n/bg"
  @06,2 SayDisp "Код пенс. фонда>" COLOR "n/bg"
  @02,19 GET k_boln PICTURE "@S30" COLOR "w/b,GR+/N"
  @03,19 GET k_pen  PICTURE "@S30"  COLOR "w/b,GR+/N"
  @04,19 GET m_krpou PICTURE "9999999999"  COLOR "w/b,GR+/N"
  @05,19 GET m_kppidpr  PICTURE "99999"   COLOR "w/b,GR+/N"
  @06,19 GET m_codn PICTURE "9999999999"  COLOR "w/b,GR+/N"
  // @08,19 say VALTYPE(m_krpou)  +VALTYPE(m_kppidpr)+ VALTYPE(m_codn)
  READ
  IF LASTKEY()<>K_ESC
    SAVEVAR1("k_boln",k_boln,"PN")
    SAVEVAR1("k_pen",k_pen,"PN")
    SAVEVAR1("m_krpou",m_krpou,"PN")
    SAVEVAR1("m_codn",m_codn,"PN")
    SAVEVAR1("m_kppidpr",m_kppidpr,"PN")
  ENDIF
  CLOSE myvar
  WCLOSE(n_win)
  WSELECT(0)
RETURN .t.



Function calcmonth()
LOCAL m_month,s_month,m_gauge1,m1
LOCAL m_year,m_tp
//LOCAL m_k1,m_k2,m_k3
 LOCAL k_pen1,k_pen2,k_pen3,k_pen4,k_pen5
  m_month:=GetMonth()
  IF m_month==0
    RETURN .f.
  ENDIF
 USE (m_mainpath+"fvnum.dbr") NEW
 m_year:=VAL(fvnum->year)
 CLOSE fvnum

NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
k_pen1  :=RESTVAR1("k_pen1","ZR")
k_pen2  :=RESTVAR1("k_pen2","ZR")
k_pen3  :=RESTVAR1("k_pen3","ZR")
k_pen4  :=RESTVAR1("k_pen4","ZR")
k_pen5  :=RESTVAR1("k_pen5","ZR")
CLOSE myvar
  s_month:=StrZero(m_month,2)
  NET  use (m_sprpath+"sp10") index (m_sprpath+"sp10" ) NEW READONLY
  NET  use (m_mainpath+"flish") NEW READONLY
  USE ("E04T05C") NEW ALIAS tabl5;zap
  USE ("E04T06C") NEW ALIAS tabl6;zap
  INDEX ON field->NUMIDENT+STRZERO(field->PAY_TP,2)  TO  ("tabl6")
  USE ("E04T07C") NEW ALIAS tabl7;zap
  USE ("E04T08C") NEW ALIAS tabl8;zap
  USE ("E04T09C") NEW ALIAS tabl9;zap
  m_gauge1:=initGauge("Вибiрка з особистих рахункiв ")
  DO WHILE .NOT.FLISH->(EOF())
       Sp10->(DS(flish->tabn))
        IF EMPTY(ALLTRIM(Sp10->codn))
          m1:=flish->tabn+"      "
        ELSE
          m1:=ALLTRIM(Sp10->codn)
        ENDIF
        IF (s_month==flish->month)
              DO CASE
              	CASE flish->kopu==k_pen1
                	t6_app(m1,m_year,m_month ,1)
                	tabl6->SUM_INS+=flish->sum
              	CASE flish->kopu==k_pen2
                	t6_app(m1,m_year,m_month ,2)
                	tabl6->SUM_INS+=flish->sum
              	CASE flish->kopu==k_pen3
                	t6_app(m1,m_year,m_month ,1)
                	tabl6->SUM_INS+=flish->sum
              	CASE flish->kopu==k_pen4
                	t6_app(m1,m_year,m_month ,29)
                	tabl6->SUM_INS+=flish->sum
              	CASE flish->kopu==k_pen5
                	t6_app(m1,m_year,m_month ,29)
                	tabl6->SUM_INS+=flish->sum
              	CASE flish->kopu=="921"
                	t6_app(m1,m_year,m_month ,1)
                	tabl6->SUM_TOTAL+=flish->sum
                	tabl6->SUM_MAX+=flish->sum
              	CASE flish->kopu=="922"
                	t6_app(m1,m_year,m_month ,2)
                	tabl6->SUM_TOTAL+=flish->sum
                	tabl6->SUM_MAX+=flish->sum
              	CASE flish->kopu=="923"
                	t6_app(m1,m_year,m_month ,1)
                	tabl6->SUM_TOTAL+=flish->sum
                	tabl6->SUM_MAX+=flish->sum
              	CASE flish->kopu=="924"
                	t6_app(m1,m_year,m_month ,29)
                	tabl6->SUM_TOTAL+=flish->sum
                	tabl6->SUM_MAX+=flish->sum
              	CASE flish->kopu=="925"
                	t6_app(m1,m_year,m_month ,29)
                	tabl6->SUM_TOTAL+=flish->sum
                	tabl6->SUM_MAX+=flish->sum
           ENDCASE
      ENDIF
      flish->(DBSKIP())
    m_gauge1:=DispGauge(m_gauge1,FLISH->(recno()/LASTREC()))
ENDDO

DelGauge(m_gauge1)
/*
  sp10->(DBGOTOP())
  DO WHILE .NOT.sp10->(EOF())
    IF EMPTY(ALLTRIM(Sp10->codn))
      m1:=sp10->tabn+"      "
    ELSE
      m1:=ALLTRIM(Sp10->codn)
    ENDIF
    IF (AT(sp10->kprof,m_k2)<>0)
        t8_app(m1,"ЗПЗ013В1")
    ENDIF
    IF (AT(sp10->kprof,m_k3)<>0)
      t8_app(m1,"ЗПЗ013Д1")
    ENDIF
    IF (AT(sp10->kprof,m_k1)<>0)
      t8_app(m1,"ЗПЗ013Б1")
    ENDIF
      sp10->(DBSKIP())
ENDDO
*/
CLOSE base sp10,flish
CLOSE base tabl5,tabl6,tabl7,tabl8,tabl9
RETURN .t.


Function chkmnt()
LOCAL m_month,s_month,m_gauge1,m_mnt
  LOCAL m_year1,m_proc1
  LOCAL k_pen
  m_month:=GetMonth()
  IF m_month==0
    RETURN .f.
  ENDIF
  USE (m_mainpath+"fvnum.dbr") NEW
  m_mnt:=mnt_dtod(STOD(fvnum->year+STRZERO(m_month,2)+"20"))
  m_year1:=fvnum->year
  CLOSE fvnum
  s_month:=StrZero(m_month,2)
  USE ("check01.DBF") NEW ALIAS chk;zap
  INDEX ON field->tabn  TO  ("chk")
  NET  use (m_sprpath+"sp10") index (m_sprpath+"sp10" ) NEW READONLY
  NET  use (m_mainpath+"fz1") NEW READONLY
  NET  use (m_mainpath+"fz2") NEW READONLY
SET PRINTER TO (m_mash+"47.txt")
SET PRINT ON
SET CONSOLE OFF
?replicate("=",75)
m_date1:=STOD(m_year1+s_month+"01")
?" зароб. платнi за "+NTOcmonth(m_month)+" мiсяць"+DTOC(m_date1)
  m_gauge1:=initGauge("Вибiрка з довiднiка працiвникiв ")
  Sp10->(DBGOTOP())

  DO WHILE .NOT.sp10->(EOF())
     IF EMPTY(Sp10->DUVL) .OR. Sp10->duvl>=m_date1
        chk_app(sp10->tabn)
        chk->sp10:=1
     ENDIF
     sp10->(DBSKIP())
     m_gauge1:=DispGauge(m_gauge1,sp10->(recno()/LASTREC()))
  ENDDO

  m_proc1 := InitGauge(" Перегляд основної бази " ,1)

  DO WHILE .NOT.fz1->(EOF())
    m_proc1:=DispGauge(m_proc1, fz1->( RECNO() ) / fz1->( LASTREC() ) )
      IF fz1->mnt== m_mnt
         IF .NOT.pFilPoz ( 'fz2' , 'vnum1' , 'fz1' )
              fz1->(DBSKIP());LOOP
        ENDIF

         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
        	sp10->(DS(fz2->tabn))
        	chk_app(fz2->tabn)
        	chk->fz1:=1
            	SKIP 1 ALIAS fz2
         ENDDO
      ENDIF
      fz1->(DBSKIP())
ENDDO
sele chk
dele for chk->sp10==1 .AND. chk->fz1==1
pack
  chk->(DBGOTOP())
  DO WHILE .NOT.chk->(EOF())
      ?chk->tabn,chk->sp10,chk->fz1,chk->fam
      chk->(DBSKIP())
ENDDO

DBEDIT(1,1,24,75,{"tabn","sp10","fz1","fam"})

DispGauge(m_proc1, 1)
DelGauge(m_gauge1)
?REPLICATE("=",80)
?
?
?STRZERO(m_month,2)+m_oper+DTOS(DATE())+TIME()+"ZZ"
SET PRINTER TO
SET PRINT Off
SET CONSOLE On
FILECOPY(m_mash+"47.txt",m_mash+"47"+STRZERO(m_month,2)+".txt")
CLOSE base sp10,fz1,fz2
RETURN .t.
FUNCTION chk_app(m_tabn)
  IF .NOT.chk->(DS(m_tabn))
    chk->(DBAP())
    chk->tabn:=m_tabn
    chk->sp10:=0
    chk->fz1:=0
    chk->fam:=_fio()
  ENDIF

RETURN .t.



FUNCTION t6_app(m1,m_year,m_month,m_tp)
   IF .NOT.tabl6->(DS(m1+STRZERO(m_tp,2)))
    tabl6->(DBAP())
    tabl6->ROWNUM:=tabl6->(RECNO())
    tabl6->NUMIDENT:=m1
    tabl6->UKR_GROMAD:=1
    tabl6->ST:=IF(UPPER(Sp10->pol)=="М",1,0)
    tabl6->PAY_TP:=m_tp
    tabl6->PAY_MNTH:=m_month
    tabl6->PAY_YEAR:=m_year
    IF .NOT.(TRIM(sp10->fam)=="")
      tabl6->LN:=dostwin(UPPER(sp10->fam))
      tabl6->NM:=dostwin(UPPER(sp10->imja))
      tabl6->FTN:=dostwin(UPPER(sp10->otch))
    ELSE
        tabl6->LN:=dostwin(UPPER("фамилия"))
        tabl6->NM:=dostwin(UPPER("имя"))
        tabl6->FTN:=dostwin(UPPER("отчество"))
    ENDIF
    tabl6->ZO:=1
    tabl6->OTK:=1
    tabl6->EXP:=0
 ENDIF
RETURN .t.

FUNCTION t7_app(m1,m_month,m_tp)
    tabl7->(DBAP())
    tabl7->ROWNUM:=tabl7->(RECNO())
    tabl7->NUMIDENT:=m1
    IF .NOT.(TRIM(sp10->fam)=="")
      tabl7->LN:=dostwin(UPPER(sp10->fam))
      tabl7->NM:=dostwin(UPPER(sp10->imja))
      tabl7->FTN:=dostwin(UPPER(sp10->otch))
    ELSE
      tabl7->LN:=dostwin(UPPER("фамилия"))
      tabl7->NM:=dostwin(UPPER("имя"))
      tabl7->FTN:=dostwin(UPPER("отчество"))
    ENDIF
    tabl7->ZO:=1
    tabl7->ZIC:=1
    tabl7->OTK:=1
    tabl7->EXP:=0
    tabl7->PAY_MNTH:=m_month
    tabl7->PAY_YEAR:=s_year
    tabl7->PAY_TP:=m_tp
RETURN .t.


FUNCTION t8_app(m1,m_pid)
    tabl8->(DBAP())
    tabl8->ROWNUM:=tabl8->(RECNO())
    tabl8->NUMIDENT:=m1
    IF .NOT.(TRIM(sp10->fam)=="")
      tabl8->LN:=dostwin(UPPER(sp10->fam))
      tabl8->NM:=dostwin(UPPER(sp10->imja))
      tabl8->FTN:=dostwin(UPPER(sp10->otch))
    ELSE
      tabl8->LN:=dostwin(UPPER("фамилия"))
      tabl8->NM:=dostwin(UPPER("имя"))
      tabl8->FTN:=dostwin(UPPER("отчество"))
    ENDIF
    tabl8->C_PID=dostwin(UPPER(m_pid))
RETURN .t.



Function Getmnt(m_mnt)
  LOCAL m_month1:="01",m_year1:="2011",GetList:={}
SET ESCAPE ON
@03,7,08,55 BOX B_SINGLE+" " COLOR "w/bg"
@03,8 SayDisp "Виберiть мiсяць розрахунку" COLOR "n/w"
m_year1:=STR(YEAR(DATE()),4)
m_month1:=STRZERO(MONTH(DATE())-1,2)
@6,10 get m_month1 PICTURE "99" COLOR "gr+/B*,gr+/n" VALID (m_month1<"13".and.m_month1>"00")
@6,15 get m_year1 PICTURE "9999" COLOR "gr+/b*,gr+/n" VALID (m_year1<="2014".and.m_year1>="2000")
READ
m_mnt:=RIGHT(m_year1,2)+m_month1
IF LASTKEY()==K_ESC
  RETURN .f.
ENDIF
RETURN .t.
Function dosTWin(strSource)
Local strResult
RETURN CHARREPL(DOS_LETTERS,strSource,WINDOWS_LETTERS,.t.)
FUNCTION pFilPoz(m_nmfl_1, m_nmpl_1, m_nmfl_2)

LOCAL  m_fict_zap,n1:=(m_nmfl_1)->(FIELDNUM(ALLTRIM(m_nmpl_1)))
LOCAL  m_fict_al,n2:=(m_nmfl_2)->(FIELDNUM(ALLTRIM(m_nmpl_1)))
m_fict_al := SELECT()
SELECT (m_nmfl_1)
m_fict_zap :=  RECNO()
LOCATE  REST  FOR  (m_nmfl_1)->(FIELDGET(n1))==(m_nmfl_2)->(FIELDGET(n2))
IF  FOUND()
     SELECT( m_fict_al )
     RETURN( .T. )
   ELSE
     GOTO m_fict_zap
     SELECT( m_fict_al )
     RETURN( .F. )
ENDIF
RETURN .t.
