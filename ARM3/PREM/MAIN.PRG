#include "new.ch"
 #include "pass.ch"
//#include "setcurs.ch"
FUNCTION BegInit (var1)
LOCAL m_time:=TIME(),m_env,getlist:={},m_path,m_x,m_name,;
      m_var:=IF(var1==NIL,"",alltrim(var1))

   SetCancel ( .f. )
   SetCursor (0)
   SetBlink(.f.)

   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   READEXIT(.t.)

   SET CENTURY       OFF
   SET DATE          BRITISH

   CLEAR SCREEN
   PUBLIC   p_help_code  := 0                     // параметр для экранного HELP
   PUBLIC   msg1_clr     := 'w+*/bg'              // цвет сообщений с мерцанием
   PUBLIC   box_clr      := 'w/b'                 // цвет рамок и т.п.
   PUBLIC   hlp_clr      := 'n/w,gr+/w'           // цвет справок ( help'а )
   PUBLIC   psw_clr      := 'w+/bg,n/n'           // цвет пароля
   PUBLIC   hello_clr    := 'gr+/b'               // цвет обычного приветствия
   PUBLIC   head_clr     := 'r+/b'                // цвет начальной заставки
   PUBLIC   dos_clr      := SetColor ()           // цвет MS-DOS
   PUBLIC   str_clr      := 'w+/n'                // цвет
   PUBLIC   mnu_clr      := 'w+/b,n/w'            // цвет меню
           PUBLIC   ten_clr      := 'w/n'                 // цвет тени
   PUBLIC   phn_clr      := 'n/w'                 // цвет фона
   PUBLIC   vvod_clr     := 'w+/b,gr+/n,,,w+/b'   // цвет экрана ввода-вывода
   PUBLIC   vvod_mig_clr := 'w+*/b,gr+/n,,,w+/b'  // цвет экрана ввода-вывода
                                                  // с мерцанием
   PUBLIC   hello1_clr   := 'w+/bg,w+/n'          // цвет при вводе даты
   PUBLIC   poisk_clr    := 'gr+/bg'              // цвет шапки окна запроса
                                                  // при поиске и переходе
   PUBLIC   hl_clr       := 'n/w,gr+/n'           // цвет выделенного пункта

   PUBLIC   m_dbspath   := ''              // каталог с текущей БД
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // каталог с буферной БД
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // каталог со справочниками
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // каталог для .EXE модуля пакета
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // каталог для машинограмм
   PUBLIC   m_syspath   := 'd:\buhgal\js\'  // каталог с  системной информацией
   PUBLIC   m_copypath  := 'd:\buhgal\cp\'  // каталог для копий
   PUBLIC   m_temppath  := 'd:\buhgal\temp\'  // каталог для копий

   USE &m_syspath\sovhoz NEW
   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- наименование предприятия
   USE
   PUBLIC a_menu:={}
KSETCAPS(.f.)
KSETNUM(.t.)
      DispWall()
CLEAREOL(0,0,"n/w")
CLEAREOL(MAXROW(),0,"n/w")
@0,0 SayDisp DMY(DATE())+" "+NTOCDOW(DOW(DATE())) COLOR "n/w"
@0,Col()+2 SayText 'АРМ Бухгалтера "~2Б~3а~4р~5с~1" - ~6Розрахунок премiї'  COLOR "b/w,rb/w,gr+/w,r/w,g+/w,b+/w"
 @MAXROW(),2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
@MAXROW(),Col()+2 SayText "Версiя №~2 1.00 ~1вiд ~201/02/99" COLOR "N/w,R/w"
//   CLEARWIN(0,0,MAXROW(),MAXCOL(),'N/W','░')
SET KEY K_F10 TO Calcul
SET KEY K_ALT_F10 TO Calc
SET KEY K_F9 TO SetLpechat
SET KEY K_CTRL_U TO LSetprint
   PUBLIC    M_WORKPATH := m_var
keyboard ''
NET USE (m_syspath+"DBROWSE") INDEX  (m_syspath+"DBROWSE")   ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")      ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY
USE (m_workpath+"menu") INDEX (m_workpath+"menu") ALIAS menu NEW
KEYBOARD ""
InitParPrn()
dialog("Розрахунок премiї")
Finish()
SHOWTIME()
RETURN .t.
RETURN ( NIL )
FUNCTION  Finish
         SET COLOR TO DOS_CLR
         SHOWTIME()
         CLEAR SCREEN
         CLOSE ALL
         QUIT
RETURN .t.
#DEFINE M_COLZERO  1  &&   Столбец первого меню
#DEFINE M_ROWZERO  1  &&   Строка первого меню
#DEFINE M_COLSTEP  2  &&   Сдвижка меню по горизонтали
#DEFINE M_ROWSTEP  1  &&   Сдвижка меню по вертикали
#DEFINE M_WIDTH    65 &&   Ширина меню
#DEFINE M_HIGH     12 &&   Высота меню
#DEFINE M_COLFIRST M_COLZERO+LEN(A_MENU)*M_COLSTEP && Столбец верхнего левого угла меню
#DEFINE M_ROWFIRST M_ROWZERO+LEN(A_MENU)*M_ROWSTEP && Строка  верхнего левого угла меню
#DEFINE M_COLLAST   M_COLFIRST+M_WIDTH && Столбец нижнего правого угла меню
#DEFINE M_ROWLAST   M_ROWFIRST+M_HIGH && Строка нижнего правого угла
FUNCTION dialog(var1)
  local obj_error,m_set,old_err
  local l_while:=.t.
  private m_proc && Используется для макроподстановки имени процедуры
  private m_menu_name:=var1 && Используется для формирования наименования меню
  old_err:=ERRORBLOCK( { |obj_error|  ArmError(obj_error) } )
  KEYBOARD ""
  DO WHILE l_while
   BEGIN SEQUENCE
      MENU ('001')
      l_while:=.f.
   RECOVER USING obj_error
      QUIT
   END SEQUENCE
  ENDDO
  showtime()
RETURN .t.

FUNCTION Menu (M_choice)
    local M_screen:=SAVESCREEN (M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+2)
    local m_recno:= MENU->(RECNO())
    local a_choice:={ "0 Вихiд"},; && Перечень пунктов меню
          a_prc:={},;            && Перечень вызываемых процедур
          a_par:={}              && Параметры процедур
    local m_key:=0
    @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( VVOD_CLR )
    SHADOW(M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST)
    SET COLOR TO  ( HEAD_CLR )
    @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM(m_menu_name)+' ',M_WIDTH -5)
    MENU->(DBseek(m_choice))
    SET COLOR TO ( MNU_CLR )
    menu->(DBEVAL ({||AADD(A_CHOICE, CHR(LEN(a_choice)+IF(LEN(a_choice)>9,55,48))+;
                    " "+MENU->PUNKTNAME),AADD(A_prc, ALLTRIM(MENU->PRC));
             ,AADD(A_par, ALLTRIM(MENU->PAR))},,{||m_choice ==MENU->NUMMENU}))
    DO WHILE .T.
        m_key :=ACHOICE (M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST-1,M_COLLAST-2, A_CHOICE,,, m_key,)
      IF M_KEY==1.OR. m_key==0
         RESTSCREEN(M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+2,m_screen)
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
          Disperror("Програма не пiдключена")
        ENDIF
        SET PRINTER TO
        SET COLOR TO ( MNU_CLR )
      ENDIF
      ASIZE(a_menu,len(a_menu)-1)
   ENDDO
RETURN .T.
function buhmonth
parameter d
if day(d)>25
 if month(d)=12
  return 1
 else
  return month(d)+1
 endif
else
 return month(d)
endif
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
RETURN .t.
Function DispWall(var)
LOCAL i:=0,j:=0,m_char:=" "
LOCAL m_clr:=IF(var==NIL,"w/b",var)
DispBegin()
DO CASE
  CASE DOW(DATE())==1
    m_clr:="w/b"
  CASE DOW(DATE())==2
    m_clr:="b/bg"
  CASE DOW(DATE())==3
    m_clr:="w/gr"
  CASE DOW(DATE())==4
    m_clr:="n/w"
  CASE DOW(DATE())==5
    m_clr:="w/rb"
  CASE DOW(DATE())==6
    m_clr:="w/g"
  CASE DOW(DATE())==7
    m_clr:="w/rb*"
ENDCASE
FOR i:=1 TO MAXROW()
  FOR j:=0 TO MAXCOL()
    DO CASE
      CASE i==1
        IF j%6==2
          m_char:="┬"
        ELSE
          m_char:="─"
        ENDIF
      CASE i==MAXROW()
        IF j%6==2
          m_char:="┴"
        ELSE
          m_char:="─"
        ENDIF
      CASE i%2==0
        DO CASE
          CASE j%6==2
            m_char:="┴"
          CASE j%6==5
            m_char:="┬"
          OTHERWISE
            m_char:="─"
        ENDCASE
      OTHERWISE
        DO CASE
          CASE j%6==2
            m_char:="┬"
          CASE j%6==5
            m_char:="┴"
          OTHERWISE
            m_char:="─"
        ENDCASE

    ENDCASE
    @i,j SayDisp m_char COLOR (m_clr)
  NEXT
NEXT
DispEnd()
RETURN .t.
