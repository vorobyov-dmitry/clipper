#include "new.ch"
#include "MENU.ch"
#include "pass.ch"
// #include  "error.ch"
#  DEFINE   MNU_CLR      "w+/b,n/w"            // цвет меню

// #define   NAME_FILE_ERR  "errors.arm"

#DEFINE M_COLFIRST 1+LEN(A_MENU)*2  && Столбец верхнего левого угла меню
#DEFINE M_ROWFIRST 1+LEN(A_MENU)*1 && Строка  верхнего левого угла меню
#DEFINE M_COLLAST   M_COLFIRST+55 && Столбец нижнего правого угла меню
#DEFINE M_ROWLAST   M_ROWFIRST+12 && Строка нижнего правого угла

MEMVAR m_tabn,m_oper,m_level,m_syspath,m_workpath,a_menu,m_imja,m_sprpath,m_proc,m_copypath,p_npr
MEMVAR m_bufpath,m_mainpath,m_mash,m_struct,m_exepath,m_shapka,m_temppath
MEMVAR m_menu_name,m_kassapath,m_menu,m_computer,m_uchpath,m_platpath
MEMVAR m_endpage,m_page,m_line,m_first

static s_tabn:=""
Function sverka(var1)
LOCAL m_time:=TIME(),m_pol,getlist:={},m_parol,m_str:=""
LOCAL s_files:={}

KSETCAPS(.f.)
KSETNUM(.t.)
SETBLINK(.F.)
SETSHARE(4)
Beginit (var1)
wboard(0,0,maxrow(),maxcol())
wmode(.t.,.t.,.t.,.t.)
SET KEY K_F10 TO Calcul
SET KEY K_ALT_F10 TO Calc
InitParPrn()
NET USE (m_workpath+m_menu) INDEX (m_workpath+m_menu) ALIAS menu NEW READONLY
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"Screen") INDEX (m_syspath+"Screen")     NEW READONLY
NET USE (m_syspath+"tbget") INDEX (m_syspath+"tbget")       NEW READONLY
m_time:=VAL(LEFT(TIME(),2))
// SET KEY K_ESC TO Finish
s01()
Finish()
Return .t.
FUNCTION  Finish
         SET COLOR TO "w/b"
         CLEAR SCREEN
         CLOSE ALL
         QUIT
RETURN .t.
FUNCTION BegInit (m_var)

   LOCAL s1:=LOWER(EXENAME()),i // количество свободного пространства
                                     // на диске в Мбайтах, необходимое для
                                     // работы АРМ "Бухгалтер"

   // ----------------------------------------------------
   // --- УСТАHОВKА ПАРАМЕТРОВ, ОБЩИХ ДЛЯ ВСЕЙ СИСТЕМЫ ---
   // ----------------------------------------------------
   SetCancel ( .f. )
   SetCursor ( 0 )
   setblink(.f.)
   VGAPALETTE(6,32,32,32)

   Set ( _SET_ESCAPE     , .t. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  7  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SetShare(4)
   SET CENTURY       OFF
   SET DATE          BRITISH
   SET EPOCH TO 1960
   PUBLIC   m_workpath   := 'd:\buhgal\plat\'   // каталог с текущей БД
   PUBLIC   m_kassapath   := 'd:\buhgal\kassa\' // каталог с кассой
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // каталог с буферной БД
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // каталог со справочниками
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // каталог для .EXE модуля пакета
   PUBLIC   m_shapka    := 'd:\buhgal\nf\'  // каталог для шапок машинограмм
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // каталог для машинограмм
   PUBLIC   m_struct    := 'd:\buhgal\st\'  // каталог с пустыми структурами
                                           // файлов
   PUBLIC   m_syspath   := 'd:\buhgal\system\'  // каталог с  системной информацией
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // каталог для копий
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // каталог с буферной БД
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
   PUBLIC   m_menu      := 'menu05'
   PUBLIC   m_platpath  := 'd:\buhgal\plat\'       // каталог с текущей БД
   PUBLIC   m_computer

   IF .NOT.EMPTY(m_var)
      USE init NEW READONLY
      IF VAL(m_var)>0.AND.VAL(m_var)<=LASTREC()
        DBGOTO(VAL(m_var))
        m_workpath  :=ALLTRIM(init->nk)
        m_bufpath   :=ALLTRIM(init->bf)
        m_platpath  :=ALLTRIM(init->nk)
        m_mainpath  :=ALLTRIM(init->mn)
        m_sprpath   :=ALLTRIM(init->sp)
        m_exepath   :=ALLTRIM(init->bh)
        m_shapka    :=ALLTRIM(init->nf)
        m_mash      :=ALLTRIM(init->ms)
        m_struct    :=ALLTRIM(init->st)
        m_syspath   :=ALLTRIM(init->js)
        m_copypath  :=ALLTRIM(init->cp)
        m_temppath  :=ALLTRIM(init->tp)
        m_kassapath :=ALLTRIM(init->kassa)
        m_menu      :=ALLTRIM(init->menu)
        m_uchpath   := ALLTRIM(init->uch)
      ENDIF
      CLOSE init
ELSE
  IF   m_exepath<>LEFT(s1,LEN(m_exepath))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_workpath  := s1+SUBSTR(m_workpath  ,11)
       m_mainpath  := s1+SUBSTR(m_mainpath  ,11)
       m_sprpath   := s1+SUBSTR(m_sprpath   ,11)
       m_exepath   := s1+SUBSTR(m_exepath   ,11)
       m_syspath   := s1+SUBSTR(m_syspath   ,11)
       m_bufpath   := s1+SUBSTR(m_bufpath   ,11)
       m_mash      := s1+SUBSTR(m_mash      ,11)
       m_copypath  := s1+SUBSTR(m_copypath  ,11)
       m_temppath  := s1+SUBSTR(m_temppath  ,11)
       m_uchpath   := s1+SUBSTR(m_uchpath  ,11)
       m_kassapath := s1+SUBSTR(m_kassapath  ,11)
       m_platpath  := s1+SUBSTR(m_platpath  ,11)
   ENDIF
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

   IF ( i := DiskSpace () ) <= ( 3 * 1048576 )
      DispErr('Для нормальної работи;АРМ необхiдно '+Str ( 3, 2 ) + ' Мбайт вiльного мiсця на диску.;'+;
      'Вiльного мiсця '+ Str ( i / 1048576 , 5 , 2 ) + ' Мбайт.; Запуск системи неможливий.')
      QUIT
   ENDIF
RETURN .t.
Function s01
  LOCAL m_file1,m_file2,m_gauge,a_struct:={}
  LOCAL m_mol:="  ",m_mnt:=CTOD("")
  LOCAL l_kvo2:=.f.,i,j,k,m_key,GetList:={},s1,s3
  LOCAL n_win,m_screen,l_filter:=.f.,s2:="",n,l_doc:=.f.
  LOCAL n_file1,n_file2,n_kapt,n_file3
  DCL MENU
  DCL LIST
SopenFiles("SP02",@s_files)
IF .not.Get001(@m_mol,@m_mnt)
  ScloseFile(s_files)
  RETURN .f.
ENDIF
s2:=_mol(sp02->mol)
//?s2,m_mol,m_mnt
  NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1") ALIAS kaptka1 NEW READONLY
  n_kapt:=SELECT("KAPTKA1")
  NET USE (m_platpath+"spr03.dbf") NEW  ALIAS File3
  n_file3:=SELECT()

  USE  (m_syspath+"Struct") INDEX (m_syspath+"Struct") NEW READONLY
  struct->(DS("NAKL06"))
  DO WHILE .NOT.struct->(EOF()).AND."NAKL06"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
AADD(a_struct,{"ksash","C",7,0})
DBCREATE(m_temppath+"svr",a_struct)
USE (m_temppath+"svr") NEW ALIAS buf
INDEX ON field->kod TO (m_temppath+"svr")
CLOSE struct
m_gauge:=InitGauge("Вибiрка сальдо",2)
DO WHILE .NOT.(n_file3)->(EOF())
  IF m_mol==(n_file3)->mol.AND.m_mnt==(n_file3)->mnt
//    ?(n_file3)->kod,(n_kapt)->name

    buf->(DS((n_file3)->kod))
    IF .NOT.BUF->(FOUND())
      buf->(DBAP())
      buf->kod:=(n_file3)->kod
      (n_kapt)->(DS(buf->kod));buf->name:=(n_kapt)->name
      buf->prise:=(n_kapt)->prise
buf->ksash=(n_kapt)->ksash
      buf->izm:=(n_kapt)->izm;buf->izm2:=(n_kapt)->izm2
    ENDIF
    buf->inkvo1+=(n_file3)->kvo
    IF (n_file3)->glv<>0
      l_kvo2:=.t.
      buf->inkvo2+=(n_file3)->glv
    ENDIF
    buf->insum+=(n_file3)->stm
  ENDIF
  (n_file3)->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,(n_file3)->(RECNO())/(n_file3)->(LASTREC()))
ENDDO
DelGauge(m_gauge)
//ViewMs("Отчет по мол")
SELE buf
set index to
INDEX ON field->ksash TO (m_temppath+"svr")
OpenFp(m_mainpath)
  // ВЫБОРКА ИНФОРМАЦИИ
  m_gauge:=InitGauge("Розрахунок машинограми N 63")
  DO WHILE .NOT. Fp2->(EOF())
IF fp1->mnt>=m_mnt.AND.(.NOT.(LEFT(fp2->dbt,2)=="04".OR.LEFT(fp2->crt,2)=="04"))
    Fp2->(DBSKIP())
LOOP
ENDIF
IF fp2->otp<>m_mol.AND.fp2->kplh<>m_mol
    Fp2->(DBSKIP())
LOOP
ENDIF
IF fp2->kplh==m_mol
IF buf->(DBSEEK(fp2->dbt))
             buf->dbkvo1+=fp2->kvo
             buf->dbsum+=fp2->stm
             buf->dbkvo2+=fp2->glv
ENDIF
ENDIF

IF fp2->otp==m_mol
IF buf->(DBSEEK(fp2->crt))
             buf->dbkvo1-=fp2->kvo
             buf->dbsum-=fp2->stm
             buf->dbkvo2-=fp2->glv
ENDIF
ENDIF
    Fp2->(DBSKIP())
//    DO WHILE Fp2->vnum==Fp1->vnum
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()))
  ENDDO
  DelGauge(m_gauge)
CLOSE fp1
CLOSE fp2
BUF->(dbgotop())
ViewMs()

CLOSE BASE buf

ScloseFile(s_files)

RETURN .t.
Function Get001(m_mol,m_mnt)
  LOCAL m_month1:="01",m_year1:="  ",GetList:={}
// Ввод мат. отв. лица
SET ESCAPE ON
@03,7,08,55 BOX B_SINGLE+" " COLOR "w/bg"
@03,8 SayDisp "Виберiть комiрника i мiсяць розрахунку" COLOR "n/w"
@05,10 Get m_mol VALID Sp02->(sp_vl("SP02",,5,15,"_mol(sp02->mol)","GR+/BG")) COLOR  "w+/bg,gr+/n"
m_year1:=STR(YEAR(DATE()),4)
m_month1:=STRZERO(MONTH(DATE())-1,2)
@6,10 get m_month1 PICTURE "99" COLOR "gr+/B*,gr+/n" VALID (m_month1<"13".and.m_month1>"00")
@6,15 get m_year1 PICTURE "9999" COLOR "gr+/b*,gr+/n" VALID (m_year1<="2010".and.m_year1>="1999")
READ
m_mnt:=RIGHT(m_year1,2)+m_month1
IF LASTKEY()==K_ESC
  RETURN .f.
ENDIF
RETURN .t.

Function ViewMs()
  LOCAL n_win,m_screen,l_filter:=.f.,n_win1
  LOCAL i,j,k,m_key,a_shapka:={},m_clr,n_pos
  LOCAL m_name:=""
//  LOCAL m_endpage,m_page,m_line,m_first
  DCL MENU
  DCL list
SELE buf
CrList6("SVROST",@m_browse,@l_print)
// m_browse:cargo:=var2
n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
ADD menu up_down
add menu Left_Right
add menu search
ADD MENU NAME "Д~рук" ITEMS {"Друк через спулер F2","Друк на прiнтер <Ctrl>+P",;
"Перелiк стовбцiв <Ctrl>+L","Параметри друку F9","Параметри прiнтера <Ctrl>+U","Кiлькiсть рядкiв <Alt>+F9"} ;
KEY {K_F2,K_CTRL_P,K_CTRL_L,K_F9,K_CTRL_U,K_ALT_F9}
ADD MENU NAME "Iн~ше" ITEMS {"Формат сторiнки F11","Перелiк накладних <Ctrl>+F4"};
KEY {K_F11,K_CTRL_F4}
ADD MENU NAME "~Фiльтр" ITEMS {"0 - рiвень <Alt>+0","1 - рiвень <Alt>+1","2 - рiвень <Alt>+2",;
"3 - рiвень <Alt>+3","4 - рiвень <Alt>+4","5 - рiвень <Alt>+5","6 - рiвень <Alt>+6",};
KEY {K_ALT_0,K_ALT_1,K_ALT_2,K_ALT_3,K_ALT_4,K_ALT_5,K_ALT_6}
// add menu print
a_shapka:=CreateShp(@m_browse,@l_print)
INIT menu
// DISPLAYLIST
@m_browse:ntop-1,m_browse:nleft-1,m_browse:nBottom,m_browse:nRight+1 BOX B_DOUBLE+" " COLOR "w/b"
i:=AT(";",m_name)
CLEAREOL(m_browse:ntop-3,0,"w/b"," ")
CLEAREOL(m_browse:ntop-2,0,"w/b"," ")
IF i<>0
  @m_browse:ntop-3,0 SayText PADC(LEFT(m_name,i-1),MAXCOL()+1) COLOR "w/b,gr+/b"
  @m_browse:ntop-2,0 SayText PADC(SUBSTR(m_name,i+1),MAXCOL()+1) COLOR "w/b,gr+/b"
ELSE
  @m_browse:ntop-2,0 SayText PADC(m_name,MAXCOL()+1) COLOR "w/b,gr+/b"
ENDIF
@m_browse:ntop-1,57 SayDisp "Сторiнка   " COLOR "W+/B"
@m_browse:ntop-1,70 SayDisp "Рядок   " COLOR "W+/B"
m_endpage:=GetEndPage();m_first:=LEN(a_shapka)+3
m_page:=1;m_line:=m_first
STABILIZE BROWSE m_browse
DO WHILE .t.
  m_browse:refReshCurrent()
  m_key:=0
  keyboard ""
  DO WHILE .NOT.(m_browse:stabilize()) .AND.((m_key:=inkey())==0)
  ENDDO
  IF m_browse:stabilize()
    @m_browse:ntop-1,66 SayDisp m_page COLOR "GR+/B" PICTURE "999"
    @m_browse:ntop-1,76 SayDisp m_line COLOR "GR+/B" PICTURE "99"
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2("3"))
    m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},color2("2"))
  ENDIF
  IF m_key==0
    m_key:=INKEY(0)
  ENDIF
  m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2("1"))
  Winsay
  DEAL MENU
  DO CASE
    CASE m_key==K_PGUP.AND.m_page>1
      EVAL(m_browse:SkipBlock,m_first-1-m_line-m_endpage+m_first)
      m_browse:rowPos:=1;m_browse:configure();m_browse:RefreshAll()
    CASE m_key==K_PGDN
      j:=m_endpage-m_line+1
      i:=EVAL(m_browse:SkipBlock,j)
      IF i==j
        m_browse:rowPos:=1;m_browse:configure();m_browse:RefreshAll()
      ELSE
        EVAL(m_browse:SkipBlock,-i)
      ENDIF
    DEAL BROWSE m_browse KEY m_key
    CASE m_key == K_F9
        SetLpechat()
        IF GetEndPage()<>m_endpage
          m_endpage:=GetEndPage()
          EVAL(m_browse:GoTopBlock)
          m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
          m_browse:RefreshAll()
        ENDIF

//    PRINT BROWSE m_browse KEY m_key
      CASE m_key == K_CTRL_P
          m_recno:=RECNO()
          OpenPrn()
          PrintMs(m_browse,a_shapka,m_name,l_print)
          DBGOTO(m_recno)
          ClosePrn()
      CASE m_key == K_F2
          m_recno:=RECNO()
          m_clr:=TEMPFILE(m_temppath,"prn");FERASE(m_clr)
          OpenPrn(m_clr)
          PrintMs(m_browse,a_shapka,m_name,l_print)
          DBGOTO(m_recno)
          ClosePrn()
          fileToLpt1(m_clr)
          PRINTSEND(CHR(K_CTRL_L))
      CASE m_key == K_CTRL_L
          SetLprint(m_browse,@l_print)
          a_shapka:=CreateShp(@m_browse,@l_print)
          IF m_first<>LEN(a_shapka)+3
            m_first:=LEN(a_shapka)+3
            EVAL(m_browse:GoTopBlock)
            m_browse:rowPos:=1;m_browse:ColPos:=1;m_browse:configure()
            m_browse:RefreshAll()
          ENDIF
      CASE m_key == K_CTRL_U
          LSetprint()
      CASE m_key == K_ALT_F9
          CountLines()
    CASE m_key==K_F11
      WSELECT(n_win1)
      n_pos:=1
      @1,57 SayDisp "Сторiнка   " COLOR "W+/B"
      @1,70 SayDisp "Рядок   " COLOR "W+/B"
      DO WHILE .t.
        @1,66 SayDisp m_page COLOR "GR+/B" PICTURE "999"
        @1,76 SayDisp m_line COLOR "GR+/B" PICTURE "99"
        FOR i:=1 TO m_browse:ColCount
          j:=Color2("3")
          m_clr:=TOKEN(m_browse:ColorSpec,",",j[1])
          @VAL(TOKEN(m_browse:GetColumn(i):cargo,",",1)),VAL(TOKEN(m_browse:GetColumn(i):cargo,",",2));
            SayDisp EVAL(m_browse:GetColumn(i):block) COLOR m_clr
        NEXT
      j:=Color2("2")
      m_clr:=TOKEN(m_browse:ColorSpec,",",j[1])
      @VAL(TOKEN(m_browse:GetColumn(n_pos):cargo,",",1)),VAL(TOKEN(m_browse:GetColumn(n_pos):cargo,",",2));
      SayDisp EVAL(m_browse:GetColumn(n_pos):block) COLOR m_clr
      i:=INKEY(0)
      j:=Color2("3")
      m_clr:=TOKEN(m_browse:ColorSpec,",",j[1])
      @VAL(TOKEN(m_browse:GetColumn(n_pos):cargo,",",1)),VAL(TOKEN(m_browse:GetColumn(n_pos):cargo,",",2));
      SayDisp EVAL(m_browse:GetColumn(n_pos):block) COLOR m_clr
      DO CASE
        CASE i==K_ESC
          EXIT
      CASE i==K_RIGHT
        n_pos:=IF(n_pos==m_browse:ColCount,m_browse:ColCount,n_pos+1)
      CASE i==K_LEFT
        n_pos:=IF(n_pos==1,1,n_pos-1)
      CASE i==K_DOWN
        EVAL(m_browse:SkipBlock,1)
      CASE i==K_UP
        EVAL(m_browse:SkipBlock,-1)
      CASE i==K_PGUP
        EVAL(m_browse:SkipBlock,-20)
      CASE i==K_PGDN
        EVAL(m_browse:SkipBlock,20)
      CASE i==K_CTRL_PGUP
        EVAL(m_browse:GoTopBlock)
      CASE i==K_CTRL_PGDN
        EVAL(m_browse:GoBottomBlock)

      ENDCASE
      ENDDO
      j:=0
      WSELECT(n_win)
    SCAN  BROWSE m_browse KEY m_key
    SEARCH  BROWSE m_browse KEY m_key
    RANGE  BROWSE m_browse KEY m_key
    CONT SEARCH  BROWSE m_browse KEY m_key
 ENDCASE
ENDDO
WCLOSE(n_win)
WCLOSE(n_win1)
WSELECT(0)

RETURN .t.
STATIC Function CrList6(m_var,m_browse,l_print)
    LOCAL m_col,i:=0
      m_browse:=TBrowseDB(4,1,MAXROW()-1,MAXCOL()-1)
      m_browse:colorspec:='W/B,B/W,w+/b,W+/W,GR+/B,GR+/w,w/b*,w+/b*,GR+/b*,bg+/b,bg+/w,bg+/b*,g+/b,g+/w,g+/b*,Rb+/b,rb/w,rb+/b*,r+/b,r/w,r+/B*'
      m_browse:colsep        := '│'
      m_browse:SkipBlock     := { |n| SkipDb(n) }
      m_browse:goBottomBlock := { ||MyGOBOT(m_browse) }
      m_browse:goTopBlock    := { ||m_page:=1,m_line:=m_first,DBGOTOP()  }
  sptabl->(DBGOTOP())
  sptabl->(dbseek(m_var))
  DO WHILE .NOT.sptabl->(EOF()).and.ALLTRIM(sptabl->NAME)==m_var
      m_Col           := TBColumnNew()
      i++
      DO CASE
        CASE sptabl->type=='03'
        m_col:block:=&("{||IF(buf->clr==' ',StoStr2(buf->"+ALLTRIM(sptabl->value)+",12),StoStr1(buf->"+ALLTRIM(sptabl->value)+",12))}")
      CASE sptabl->type=='04'
        m_col:block:=&("{||IF(buf->clr==' ',SPACE(12),StoStr1("+ALLTRIM(sptabl->value)+",12))}")
        CASE sptabl->type=='02'
        m_col:block:=&("{||"+ALLTRIM(sptabl->value)+"}")
        CASE sptabl->type=='01'
          m_col:block:=&("{|x|IF(x==NIL,field->"+ALLTRIM(sptabl->value)+",field->"+ALLTRIM(sptabl->value)+":=x)}")
        OTHERWISE
          m_col:block:=&("{|x|IF(x==NIL,"+ALLTRIM(sptabl->value)+","+ALLTRIM(sptabl->value)+":=x)}")
      ENDCASE
      m_col:heading:=ALLTRIM(sptabl->heading)
      AADD(l_print,IF(sptabl->print==.t.,.T.,.f.))
      m_Col:colorblock:=  {||color2("1")}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
      IF .NOT.EMPTY(sptabl->width)
        m_col:width:=sptabl->width
      ENDIF
      IF .NOT.EMPTY(sptabl->cargo)
        m_col:Cargo:=ALLTRIM(sptabl->cargo)
      ENDIF
     Sptabl->(DBSKIP())
     m_browse:addColumn(m_col)
    ENDDO
    sptabl1->(DS(m_var))
    m_browse:freeze:= IF(EMPTY(sptabl1->frz),0,sptabl1->frz)
  RETURN .t.
STATIC FUNCTION SkipDb(n)
    LOCAL  ncount  := 0
IF n > 0
   DO WHILE ncount < n
        DBSKIP()
       // Если конец файла
       IF  EOF()
          DBSKIP( -1 )
          EXIT
       END
       ncount++
   ENDDO
  m_line+=ncount
  DO WHILE  m_line>m_endpage
    m_line:=m_line-m_endpage-1+m_first
    m_page++
  ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF()
          EXIT
       END
       ncount--
   ENDDO
  m_line+=ncount
  DO WHILE  m_line<m_first
    m_line:=m_line+m_endpage-m_first+1
    m_page--
  ENDDO
END
RETURN ( ncount )
STATIC Function MyGOBOT(m_browse)

DO WHILE .t.
  IF EVAL(m_browse:SkipBlock,1)<>1
    EXIT
  ENDIF
ENDDO
RETURN .t.
Function StoSTR2(x,m_len)
LOCAL m_str:="",s:=STR(ABS(x),18,2),i
if x==0
  return SPACE(m_len)
endif
m_str:=ALLTRIM(substr(s,1,3))
FOR i:=1 TO 4
   IF .NOT.EMPTY(SUBSTR(s,3*i+1,3))
       IF .NOT.EMPTY(m_str)
           m_str+="'"+SUBSTR(s,3*i+1,3)
      ELSE
        m_str+=ALLTRIM(SUBSTR(s,3*i+1,3))
      ENDIF
    ENDIF
NEXT
m_str+=IF(substr(s,17,2)=='00',"","."+substr(s,17,2))
IF x<0
  m_str:="-"+m_str
ENDIF
IF m_len<>NIL.AND.m_len>0
   m_str:=IF(LEN(m_str)>m_len,REPLICATE("*",m_len),PADL(m_str,m_len))
ENDIF
RETURN m_str
Function Fp1Check(n_error)
LOCAL m_vnum
      IF Fp1->vnum<>Fp2->vnum
        IF .NOT.Fp1->(DS(Fp2->vnum))
          IF n_error==0
            DispError("Знайдена проводка без заголовку")
          ENDIF
          n_error++
          // Если ошибка пропускаем все записи fp2 с таким внутренним номером
          m_vnum:=Fp2->vnum
          DO WHILE .NOT.fp2->(EOF()).and.Fp2->vnum==m_vnum
            fp2->(DBSKIP())
          ENDDO
          RETURN .F.
        ENDIF
      ENDIF
RETURN .T.
STATIC FUNCTION OpenFp(m_path)
LOCAL l_index :=.f.
 NET USE (m_path+"Fp1") INDEX (m_path+"Fp1") NEW
  NET USE (m_path+"Fp2")   NEW
return .t.
STATIC FUNCTION CreateShp(m_browse,l_print)
LOCAL a_shp:={"┌","│","└"},;
      i,j,m_max,m_shapka,i_str:=2,m_length:=1,l
FOR i:=1 TO m_browse:colCount
  If l_print==NIL.OR.(l_print<>NIL.AND.l_print[i]==.T.)
    m_shapka:=m_browse:getColumn(i):heading+";"
    m_max:=0
    i_str:=2
    DO While   .NOT.EMPTY(m_shapka)
      j:=AT(";",m_shapka)
      IF(j>m_max+1,m_max:=j-1,NIL)
      If i_str>LEN(a_shp)-1
        AADD(a_shp,NIL)
        AINS(a_shp,i_str)
        a_shp[i_str]:=SPACE(m_length)
        FOR l:=1 TO LEN(a_shp[i_str-1])
          IF SUBSTR(a_shp[i_str-1],l,1)=="│".OR.SUBSTR(a_shp[i_str-1],l,1)=="┌"
            a_shp[i_str]:=STUFF(a_shp[i_str],l,1,"│")
          ENDIF
        ENDFOR
      EndIF
      a_shp[i_str]:=a_shp[i_str]+LEFT(m_shapka,j-1)
      i_str++
      m_shapka:=RIGHT(m_shapka,LEN(m_shapka)-j)
    EndDO
    m_max:=MAX(m_max,m_browse:colwidth(i))
    a_shp[1]+=REPLICATE("─",m_max)
    a_shp[LEN(a_shp)]+=REPLICATE("─",m_max)
    FOR l:=2 TO LEN(a_shp)-1
      a_shp[l]:=PADR(a_shp[l],m_length+m_max)+"│"
    NEXT
    m_length+=m_max+1
    a_shp[1]+="┬"
    a_shp[LEN(a_shp)]+="┴"
  EndIF
NEXT
a_shp[1]:=STUFF(a_shp[1],LEN(a_shp[1]),1,"┐")
a_shp[LEN(a_shp)]:=STUFF(a_shp[LEN(a_shp)],LEN(a_shp[LEN(a_shp)]),1,"┘")
RETURN a_shp

STATIC FUNCTION color2(var)
IF buf->dbkvo1==buf->inkvo1
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {1,2}
      CASE var=="2"
        RETURN {2,1}
      CASE var=="3"
        RETURN {7,7}
    ENDCASE
RETURN {1,2}
else
    DO CASE
      CASE var==NIL.OR.var=="1"
        RETURN {19,20}
      CASE var=="2"
        RETURN {20,19}
      CASE var=="3"
        RETURN {7,7}
    ENDCASE
        RETURN {19,20}
endif
RETURN {1,2}
