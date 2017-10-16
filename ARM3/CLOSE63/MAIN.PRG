#include "new.ch"
#include "menu.ch"
#include "ACHOICE.ch"
#include "pass.ch"
MEMVAR a_menu,m_mainpath,m_level,m_tabn,m_oper
MEMVAR m_sprpath,m_exepath,m_syspath,m_bufpath,m_mash
MEMVAR m_copypath,m_proc,m_menu_name
MEMVAR m_workpath,m_temppath,p_npr,m_dbspath,p_sovhoz

Function Main(var1)
LOCAL m_time:=TIME(),getlist:={},m_parol,m_str:=""
LOCAL m_var1:=IF(EMPTY(var1),"",var1),m_imja,m_pol
CLEAR
/*
IF numfiles()<100
  DispError("Количество дескрипторов файлов меньше 100;Измените CONFIG.SYS")
  QUIT
ENDIF
*/
KSETCAPS(.f.)
KSETNUM(.t.)
Beginit (m_var1)
wboard(0,0,MAXROW(),MAXCOL())
SET KEY K_F10 TO Calc
InitParPrn()
NET USE (m_workpath+"MENU63") INDEX (m_workpath+"MENU63") ALIAS menu NEW READONLY
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
      @0,0 SayDisp DMY(DATE())+" "+CDOW(DATE()) COLOR "n/w"
      @0,Col()+2 SayText 'АРМ Бухгалтера "~2Б~3а~4р~5с~1" - ~6Закрытие 63-37 счета' COLOR "b/w,rb/w,gr+/w,r/w,g+/w,b+/w"
      @MAXROW(),2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
      @MAXROW(),Col()+2 SayText "Версия №~2 001 ~1от ~229/03/04" COLOR "N/w,R/w"
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
NET USE (m_workpath+"MENU63") INDEX (m_workpath+"MENU63") ALIAS menu NEW READONLY
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
         ScreenFile(m_temppath+"sc1.scr")
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_temppath+"sc1.scr")
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
   PUBLIC   m_workpath  :=""
   PUBLIC   p_sovhoz
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
          ENDIF
          CLOSE init
        ENDIF
    ENDIF
ELSE
IF m_exepath<>LEFT(s1,LEN(m_exepath))
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
 m_dbspath   := ''              // каталог с текущей БД
 m_bufpath   :=s1+SUBSTR(m_bufpath    ,  11)  // каталог с буферной БД
 m_mainpath  :=s1+SUBSTR(m_mainpath   ,  11)  // каталог с основной БД
 m_sprpath   :=s1+SUBSTR(m_sprpath    ,  11)  // каталог со справочниками
 m_exepath   :=s1+SUBSTR(m_exepath    ,  11)  // каталог для .EXE модуля пакета
 m_mash      :=s1+SUBSTR(m_mash       ,  11)  // каталог для машинограмм
 m_syspath   :=s1+SUBSTR(m_syspath    ,  11)  // каталог с  системной информацией
 m_copypath  :=s1+SUBSTR(m_copypath   ,  11)  // каталог для копий
    ENDIF
ENDIF

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- код оператора ( пользователя )
   PUBLIC m_tabn     := ' '      // --- табельный N оператора ( пользователя )


   NET USE (m_syspath+"sovhoz") NEW READONLY
   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- наименование предприятия
   p_sovhoz:=sovhoz->sov
   USE

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


Function calc63
  LOCAL m_scht:='36,63          ',m_scht1,m_scht2,m_month,s_scht,s_cod
  LOCAL GetList:={},m_gauge1,m_sum,n_error:=0,l1,l2
  set escape on
  @ 12,10,15,75  box B_DOUBLE+" " color "GR+/bG"
  @ 13,12 Say "Введiть коди рахункiв  >"   COLOR "W+/BG"
  @ 13,38 GET m_scht   COLOR "b/BG,gr+/n"    PICTURE "@S20"
  READ
  IF LASTKEY()==K_ESC
    RETURN .T.
  ENDIF
  m_month:=GetMonth()
  IF m_month==0
    RETURN .f.
  ENDIF

  SET DECIMALS TO 6
  m_scht1=TOKEN(ALLTRIM(m_scht),'.,;',1)
  m_scht2=TOKEN(ALLTRIM(m_scht),'.,;',2)
  l1:=LEN(m_scht1)+1
  l2:=LEN(m_scht2)+1

//NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44") NEW READONLY
//NET USE (m_mainpath+"fp2")  NEW READONLY
//NET USE (m_mainpath+"fp1") INDEX (m_mainpath+"fp1") NEW READONLY
OpenFp1()
  USE forma63 NEW;zap
  INDEX ON forma63->cod to forma63
  m_gauge1:=initGauge("Вибiрка данних по рахункам "+m_scht1+"-"+m_scht2)

  DO WHILE .NOT. Fp2->(EOF())
      // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
         // ЗАПИСЬ С РАСЧЕТНОГО ПЕРИОДА
      IF (mnt_month(fp1->mnt)<=m_month)

         IF LEFT(fp2->dbt,LEN(m_scht1))==m_scht1
          appRec1(m_scht1,m_scht2,SUBSTR(fp2->dbt,l1),fp2->stm)
         ENDIF
         IF LEFT(fp2->crt,LEN(m_scht1))==m_scht1
          appRec1(m_scht1,m_scht2,SUBSTR(fp2->crt,l1),-fp2->stm)
         ENDIF
         IF LEFT(fp2->dbt,LEN(m_scht2))==m_scht2
          appRec2(m_scht1,m_scht2,SUBSTR(fp2->dbt,l2),fp2->stm)
         ENDIF
         IF LEFT(fp2->crt,LEN(m_scht2))==m_scht2
          appRec2(m_scht1,m_scht2,SUBSTR(fp2->crt,l2),-fp2->stm)
         ENDIF
      ENDIF
    Fp2->(DBSKIP())
    m_gauge1:=DispGauge(m_gauge1,fp2->(RECNO()/LASTREC()))
  ENDDO
//INKEY(0)
Forma63->(DBGOTOP())
  DO WHILE .NOT.Forma63->(EOF())
    IF (Forma63->sum1==0).AND.(Forma63->sum2==0)
Forma63->(DBDELETE())
ELSE
  IF (SIGN(Forma63->sum1)<>SIGN(Forma63->sum2))
     Forma63->sum3:=MIN(ABS(Forma63->sum1),ABS(Forma63->sum2))
//     Forma63->sum3:=MIN(ABS(Forma63->sum1),ABS(Forma63->sum2))*SIGN(Forma63->sum2)
  ENDIF
  ENDIF
  Forma63->(DBSKIP())
ENDDO
SELE Forma63
PACK
DelGauge(m_gauge1)
STRFILE(ALLTRIM(m_scht),m_workpath+"scht.lst")
CLOSE base forma63,fp1,fp2,sp44
RETURN .T.
Function appRec1(m_scht1,m_scht2,x_cod,x_stm)
IF .NOT.Forma63->(DBSEEK(PADR(x_cod,10)))
  Forma63->(DBAPPEND())
  Forma63->cod:=x_cod
  Sp44->(DS(m_scht1+x_cod))
// ?"---",m_scht1+'|'+x_cod
  Forma63->name1:=Sp44->naim7
  Sp44->(DS(m_scht2+x_cod))
// ?"---", m_scht2+x_cod
  Forma63->name2:=Sp44->naim7
ENDIF
  Forma63->sum1+=x_stm
RETURN .T.

Function appRec2(m_scht1,m_scht2,x_cod,x_stm)
IF .NOT.Forma63->(DBSEEK(PADR(x_cod,10)))
  Forma63->(DBAPPEND())
  Forma63->cod:=x_cod
  Sp44->(DS(m_scht1+x_cod))
  Forma63->name1:=Sp44->naim7
  Sp44->(DS(m_scht2+x_cod))
  Forma63->name2:=Sp44->naim7
ENDIF
  Forma63->sum2+=x_stm
RETURN .T.


Function brow63
  LOCAL i,j,k,m_key,m_get:=GetNew(),m_screen,x
  LOCAL m_sum1,m_sum2,m_glav,m_tabn1,m_tabn2,GetList:={}
  LOCAL m_gauge,m_scht,m_scht1,m_scht2
  DCL LIST
  DCL MENU
  SET ESCAPE ON
  SET SCOREBOARD OFF
  ADD MENU UP_DOWN
  ADD MENU SEARCH
  ADD MENU LEFT_RIGHT
  ADD MENU EDIT
  USE (m_workpath+"forma63") INDEX (m_workpath+"forma63")
m_scht=FILESTR(m_workpath+"scht.lst")
m_scht1=TOKEN(ALLTRIM(m_scht),'.,;',1)
m_scht2=TOKEN(ALLTRIM(m_scht),'.,;',2)

m_browse:=TBrowseDB(3,1,MAXROW()-1,MAXCOL()-1);m_browse:colorspec:='w/b,w+/w,g+/b,r+/b,n/bg,W+/B'
m_browse:colsep:='│';m_browse:SkipBlock:={|n|SkipOrder(n)};m_browse:goBottomBlock:={||DBGOBOTTOM()}
m_browse:goTopBlock:={||DBGOTOP()};m_browse:cargo:="Закриття рахункiв"
CrList(@m_browse,@l_print,m_scht1,m_scht2);m_browse:freeze:=2
m_get:colorSpec:="GR+/N"
INIT MENU
DISPLAYLIST
DO WHILE .t.
  m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{1,1})
  STABILIZE BROWSE m_BROWSE
  m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{6,1})
  m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},{2,2})
  m_key:=INKEY(0)
  DEAL MENU
DO CASE
  DEAL BROWSE m_browse KEY m_key
  SCAN BROWSE   m_browse KEY m_key
  RANGE BROWSE  m_browse KEY m_key
  SEARCH BROWSE m_browse KEY m_key
  CONTINUE SEARCH BROWSE m_browse KEY m_key
  CASE m_key==K_ENTER
    STABILIZE BROWSE m_BROWSE
    m_get:row=ROW();m_get:col:=COL()
    m_get:block:=m_browse:GetColumn(m_browse:ColPos):block
    m_get:postblock:={||IF(field->sum3>=0.AND.field->sum3<=MIN(ABS(Field->sum1),ABS(Field->sum2)),.t.,.f.)}
    SET CURSOR ON
    ReadModal({m_get})
    m_browse:refreshCurrent()
    SET CURSOR OFF
CASE m_key==K_ALT_N.AND.ANSWER("Занести проводки в буфферную базу ?")==YES
	zanec(m_scht1,m_scht2)

  CASE m_key==K_DEL.AND.ANSWER("Удалять строку ?")==YES
     Forma63->(DBDELETE())
     Forma63->(DBSKIP())
     Forma63->(DBSKIP(-1))
     m_browse:refreshAll()
  PRINT BROWSE m_browse KEY m_key
FINISH LIST
Close forma63
RETURN .t.
Function CrList(m_browse,l_print,m_scht1,m_scht2)
  LOCAL m_col
   m_Col = TBColumnNew()
   m_col:block:={||field->cod};m_col:heading:="Код";AADD(l_print,.T.);m_Col:colorblock:=  {|| {1,2}};m_col:colsep:="│";m_Col:headsep    := "┬─";m_Col:footsep    := "╧═";m_browse:addColumn( m_col )
   m_Col = TBColumnNew()
   m_col:block:={||field->NAME1};m_col:heading:="Назва рахунку "+m_scht1;AADD(l_print,.T.);m_Col:colorblock:=  {|| {1,2}};m_col:colsep:="│";m_Col:headsep    := "┬─";m_Col:footsep    := "╧═";m_browse:addColumn( m_col )
   m_Col = TBColumnNew()
   m_col:block:={||field->NAME2};m_col:heading:="Назва рахунку"+m_scht2;AADD(l_print,.T.);m_Col:colorblock:=  {|| {1,2}};m_col:colsep:="│";m_Col:headsep    := "┬─";m_Col:footsep    := "╧═";m_browse:addColumn( m_col )
   m_Col = TBColumnNew()
   m_col:block:={||field->sum1};m_col:heading:="Сума;рахунку;"+m_scht1;AADD(l_print,.T.);m_Col:colorblock:=  {||IF(field->sum1>=0,{3,2},{4,2})};m_col:colsep:="│";m_Col:headsep    := "┬─";m_Col:footsep    := "╧═";m_browse:addColumn( m_col )
   m_Col = TBColumnNew()
   m_col:block:={||field->sum2};m_col:heading:="Сума;рахунку"+m_scht2;AADD(l_print,.T.);m_Col:colorblock:= {||IF(field->sum2>=0,{3,2},{4,2})} ;m_col:colsep:="│";m_Col:headsep    := "┬─";m_Col:footsep    := "╧═";m_browse:addColumn( m_col )
   m_Col = TBColumnNew()
   m_col:block:=COLBR(field->sum3);m_col:heading:="Сума;проводки";AADD(l_print,.T.);m_Col:colorblock:=  {|| {1,2}};m_col:colsep:="│";m_Col:headsep    := "┬─";m_Col:footsep    := "╧═";m_browse:addColumn( m_col )
RETURN .t.

STATIC FUNCTION SkipOrder( n )
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
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF()
          EXIT
       END
       ncount--
   ENDDO
END
RETURN ( ncount )
Function Fp1Check(n_error)
LOCAL m_vnum
      IF Fp1->vnum<>Fp2->vnum
        IF .NOT.Fp1->(DS(Fp2->vnum))
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
STATIC Function OpenFp1()
LOCAL m_message
NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44") NEW READONLY
USE (m_mainpath+"Fp2") READONLY NEW
USE (m_mainpath+"Fp1") READONLY NEW
IF .NOT.FILE(m_mainpath+"Fp1.ntx")
  m_message:=DispMessage("Iндексацiя файлу")
  INDEX ON fp1->vnum TO (m_mainpath+"Fp1")
  DelMessage(m_message)
  return .t.
ELSE
  IF FILEDATE(m_mainpath+"Fp1.DBF")>FILEDATE(m_mainpath+"Fp1.NTX")
  m_message:=DispMessage("Iндексацiя файлу")
    INDEX ON fp1->vnum TO (m_mainpath+"Fp1")
  DelMessage(m_message)
  return .t.
  ELSE
    IF FILEDATE(m_mainpath+"Fp1.DBF")==FILEDATE(m_mainpath+"Fp1.NTX").AND.;
     FILETIME(m_mainpath+"Fp1.DBF")>FILETIME(m_mainpath+"Fp1.NTX")
    m_message:=DispMessage("Iндексацiя файлу")
      INDEX ON fp1->vnum TO (m_mainpath+"Fp1")
    DelMessage(m_message)
  return .t.
    ENDIF
  ENDIF
ENDIF
SET INDEX TO  (m_mainpath+"Fp1")
return .t.
STATIC Function zanec(m_scht1,m_scht2)
Local m_path:=m_bufpath,l_dob:=.f.,m_recno
// SET PRINTER TO "00.txt"
// Set printer ON
// ?m_scht1,m_scht2
// ?m_bufpath
// ?"Start"
m_recno:=forma63->(RECNO())

forma63->(DBGOTOP())

  NET USE (m_path+"Fp1") INDEX (m_path+"Fp1"),(m_path+"Fp1a")  NEW
  DBSETORDER(1)
  NET USE (m_path+"Fp2") INDEX (m_path+"Fp2"),(m_path+"Fp2a"),(m_path+"Fp2b"),(m_path+"Fp2c")  NEW
  USE (m_path+"fvnum.dbr") NEW
/*
   fp1->(DBAP())
   fp1->maket:='01'
   fp1->dvv := date()
   fp1->oper:= 'WW'
   fp1->npch:="  500"
   fp1->ndoc:=STR(1,6)
   fp1->vnum:=STR(fvnum->vnum,7)
    fvnum->vnum:=fvnum->vnum+1
   fp1->mnt:=fvnum->mnt1
   fp1->ddoc:=CTOD("01/"+RIGHT(fp1->mnt,2)+"/"+LEFT(fp1->mnt,2))
   */
forma63->(DBGOTOP())

   DO WHILE .NOT.forma63->(EOF())
    if forma63->sum3>0
//      ?"Append Fp2",forma63->sum3,forma63->cod

      l_dob:=.t.
     fp2->(DBAPPEND())
      fp2->kopr="ВЗ"
      fp2->vnum:=STR(fvnum->vnum,7)

//      fp2->kopr:=
IF forma63->sum1>0
      fp2->dbt:= m_scht1+forma63->cod
      fp2->crt:= m_scht2+forma63->cod
ELSE
      fp2->dbt:= m_scht2+forma63->cod
      fp2->crt:= m_scht1+forma63->cod
    ENDIF
      fp2->stm:= forma63->sum3
    ENDIF
      forma63->(DBSKIP())
    ENDDO
IF l_dob
//  ?"Append fp1 "
   fp1->(DBAP())
   fp1->maket:='01'
   fp1->dvv := date()
   fp1->oper:= 'WW'
   fp1->npch:="  500"
   fp1->ndoc:=STR(1,6)
   fp1->vnum:=STR(fvnum->vnum,7)
    fvnum->vnum:=fvnum->vnum+1
   fp1->mnt:=fvnum->mnt1
   fp1->ddoc:=CTOD("01/"+RIGHT(fp1->mnt,2)+"/"+LEFT(fp1->mnt,2))
  ENDIF
//  ?"_________________________"
CLOSE fvnum
CLOSE Fp2
CLOSE Fp1
sele forma63
dbgoto(m_recno)
RETURN .t.
