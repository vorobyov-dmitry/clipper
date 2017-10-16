#include "new.ch"
#include "ACHOICE.ch"
#include "pass.ch"
MEMVAR m_tabn,m_oper,m_sprpath,m_imja
memvar m_syspath,a_menu,m_vdoc,M_TEMPPATH,M_BUFPATH,M_MAINPATH,M_EXEPATH
MEMVAR M_MASH,M_COPYPATH,M_DBSPATH,M_LEVEL,M_UCHPATH,M_COMPUTER,m_workpath
Function Main(var1)
LOCAL m_time:=TIME(),m_pol,getlist:={},m_parol,m_str:=""
LOCAL m_var1:=IF(EMPTY(var1),"",var1)
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
// InitArmError()
vhod()
IF m_tabn=="****".AND.m_oper=="**"
      m_imja := 'Адмiнiстратор'
      m_pol  := 'ий '
ELSE
      NET USE (m_sprpath+"SP10") INDEX (m_sprpath+"SP10") READONLY
      sp10->(DBSEEK(m_tabn))
      IF .NOT. sp10->(Found ())
         DispError("Табельний номер "+m_tabn+";вiдсутнiй  в довiднику працiвникiв")
         m_imja = "Незнайомець"
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
wboard(0,0,MAXROW(),MAXCOL())
SET KEY K_F10 TO Calcul
SET KEY K_ALT_F10 TO Calc
SET KEY K_F9 TO SetLpechat
SET KEY K_CTRL_U TO LSetprint

InitParPrn()
NET USE (m_syspath+"MENU_NEW") INDEX (m_syspath+"MENU_NEW") ALIAS menu NEW READONLY
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY

   m_time:=VAL(LEFT(TIME(),2))
   DO CASE
    CASE m_time>=5.AND.m_time<=11
      m_str:="Доброго ранку, "
    CASE m_time>=12.AND.m_time<=16
      m_str:="Добрий день, "
    CASE m_time>=16.AND.m_time<=23
      m_str:="Добрий вечiр, "
    OTHERWISE
      m_str:="Здоровенькi були, "
  ENDCASE
  WaitMessage(m_str+'Шановн' + m_pol + m_imja + ',;'+'АРМ "Бухгалтер" вiтає Вас !',"W+/BG,GR+/BG")
   DO dialog
SET KEY K_ESC TO Finish
Finish()
RETURN .t.
FUNCTION  Finish
         SET COLOR TO &dos_clr
         CLEAR SCREEN
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
  local obj_error,m_set,old_err
  local l_while:=.t.,j,m_str
  private m_proc && Используется для макроподстановки имени процедуры
  private m_menu_name:='Головне меню ' && Используется для формирования наименования меню
//  DO BEGINIT
   m_set:=CSetAll()

DO WHILE l_while
   old_err:=ERRORBLOCK( { |obj_error|  ArmError(obj_error) } )
   BEGIN SEQUENCE
      CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","▓")
      CLEAREOL(0,0,"n/w")
      CLEAREOL(MAXROW(),0,"n/w")
      @0,0 SayDisp DMY(DATE())+" "+MyCDOW(DOW(DATE())) COLOR "n/w"
      @0,Col()+2 SayText 'АРМ Бухгалтера "~2Б~3а~4р~5с~1" - ~6ЗАРПЛАТА' COLOR "b/w,rb/w,gr+/w,r/w,g+/w,b+/w"
      @MAXROW(),2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
      @MAXROW(),Col()+2 SayText "Версия №~2 4.1 ~1от ~224/08/99" COLOR "N/w,R/w"
   m_str:="^о{oлjutgцеdjвaamа]i[┌AJG╓JTУЮ[^Q╬ПQV╪╔┘█╙┘╫╨┌╓"
FOR j:=1 TO LEN(m_str)
  m_str:=STUFF(m_str,j,1,CHR(ASC(SUBSTR(m_str,j,1))+j+48))
NEXT
//   @21,8,23,63 BOX "╔═╗║╝═╚║ " COLOR "w+/bg"
//   @22,10 Say LEFT(m_str,LEN(m_str)-8)+CHR(49)+CHR(52)+CHR(45)+CHR(52)+CHR(51)+CHR(45)+CHR(56)+CHR(53) COLOR "GR+/bg"
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

NET USE (m_syspath+"DBROWSE") INDEX  (m_syspath+"DBROWSE")   ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"MENU_NEW") INDEX (m_syspath+"MENU_NEW") ALIAS menu NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")      ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY

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
    LOCAL m_file1
    @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( VVOD_CLR )
    SET COLOR TO  ( HEAD_CLR )
    @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM(m_menu_name)+' ',M_WIDTH -5)
    MENU->(DBseek(m_choice))
    SET COLOR TO ( MNU_CLR )
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
         m_file1:=TEMPFILE(m_temppath,"scr");FERASE(m_file1)
         ScreenFile(m_file1)
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_file1)
         ENDIF
        ELSE
          DispError("Програма не пiдключена")
        ENDIF
         SET COLOR TO ( MNU_CLR )
      ENDIF
      ASIZE(a_menu,len(a_menu)-1)
   ENDDO
RETURN .T.


FUNCTION BegInit (m_var1)

   LOCAL SwapingSpace := 3,i,s1:=LOWER(EXENAME()) // количество свободного пространства
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
   SET EPOCH TO 1960
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
   PUBLIC   vvod_clr     := 'w/b,gr+/n,,,n/w'   // цвет экрана ввода-вывода
   PUBLIC   vvod_mig_clr := 'w+*/b,gr+/n,,,w+/b'  // цвет экрана ввода-вывода
                                                  // с мерцанием
   PUBLIC   hello1_clr   := 'w+/bg,w+/n'          // цвет при вводе даты
   PUBLIC   poisk_clr    := 'gr+/bg'              // цвет шапки окна запроса
                                                  // при поиске и переходе
   PUBLIC   hl_clr       := 'n/w,gr+/n'           // цвет выделенного пункта
                                                  // при экранном вводе-выводе

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
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
   PUBLIC   m_computer
   IF .NOT.EMPTY(m_var1)
      IF .NOT.IsDigit(m_var1)
        IF RIGHT(m_var1,1)<>"\"
           m_mainpath  := m_var1+SUBSTR(m_mainpath  ,2)
           m_sprpath   := m_var1+SUBSTR(m_sprpath   ,2)
           m_exepath   := m_var1+SUBSTR(m_exepath   ,2)
           m_syspath   := m_var1+SUBSTR(m_syspath   ,2)
           m_bufpath   := m_var1+SUBSTR(m_bufpath   ,2)
           m_mash      := m_var1+SUBSTR(m_mash      ,2)
           m_copypath  := m_var1+SUBSTR(m_copypath  ,2)
           m_temppath  := m_var1+SUBSTR(m_temppath  ,2)
           m_uchpath   := m_var1+SUBSTR(m_uchpath  ,2)
        ELSE
          m_bufpath   := m_var1+'bf\'
          m_mainpath  := m_var1+'mn\'
          m_sprpath   := m_var1+'sp\'
          m_exepath   := m_var1+'bh\'
          m_mash      := m_var1+'ms\'
          m_syspath   := m_var1+'system\'
          m_copypath  := m_var1+'cp\'
          m_temppath  := m_var1+'temp\'
          m_uchpath   :=m_var1+'1_2\'
        ENDIF
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
              m_temppath  := ALLTRIM(init->tp)
              m_uchpath   := ALLTRIM(init->uch)
          ENDIF
          CLOSE init
    ENDIF
  ENDIF
 ELSEIF m_exepath<>LEFT(s1,LEN(m_exepath))
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
       m_uchpath   := s1+SUBSTR(m_uchpath  ,11)
 ENDIF

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- код оператора ( пользователя )
   PUBLIC m_tabn     := ' '      // --- табельный N оператора ( пользователя )

   PUBLIC m_imja  := ' '         // --- имя-отчество пользователя

   NET USE (m_syspath+"sovhoz") NEW READONLY
   PUBLIC p_npr := AllTrim ( sovhoz->naim )     // --- наименование предприятия
   USE

   PUBLIC m_vdoc    := 0                      // --- вид документа
   PUBLIC m_imjadoc := ''                     // --- название документа

   PUBLIC a_menu:={}
//   PUBLIC a_param:={}


   // проверка наличия свободного пространства на диске

   IF ( i := DiskSpace () ) <= ( SwapingSpace * 1048576 )
      ? Chr ( 7 )
      SetColor ( msg_clr )
      @ 10, 2,14,77 BOX '┌─┐│┘─└│ '
      @ 10, 1,14, 1 BOX ' '
      @ 10,78,14,78 BOX ' '
      @ 11,4 SayDisp 'Для нормальной работы АРМ необходимо ' + ;
                  Str ( SwapingSpace, 2 ) + ' Мбайт свободного места на диске.'
      @ 12,4 SayDisp '            Свободно '+ Str ( i / 1048576 , 5 , 2 ) + ;
                                  ' Мбайт. Запуск системы невозможен.'
      @ 13,4 SayDisp '             Для завершения работы нажмите любую клавишу.'
      i = Inkey ( 0 )
      SetColor ( dos_clr )
      CLEAR SCREEN
      QUIT
   ENDIF
  MEMOREAD(m_exepath+"computer.txt")
  m_computer:=VAL(TOKEN(MEMOREAD(m_exepath+"computer.txt")))

   // переиндексация всех файлов

//   Wait_Mig ()
RETURN .T.
FUNCTION DispDoc(m_var)
  m_vdoc:=VAL(a_menu[3])
  IF a_menu[1]=="BUF"
    m_dbspath:=m_bufpath
  ELSE
    m_dbspath:=m_mainpath
  ENDIF
   DO CASE

      && Путевой лист грузового автомобиля
      CASE m_vdoc==39.AND.a_menu[2]=='AVTO'
      DO CASE
         CASE m_var=="INPUT"
            s_vv039()
         CASE m_var=="EDIT"
            s_kr039   ("исправление")
         CASE m_var=="VIEW"
            s_kr039   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr039()
      ENDCASE

      && Путевой лист грузового автомобиля ( эксплуатация )
      CASE m_vdoc==38.AND.a_menu[2]=='AVTO'
      DO CASE
         CASE m_var=="INPUT"
            s_vv039()
         CASE m_var=="EDIT"
            s_kr038   ("исправление")
         CASE m_var=="VIEW"
            s_kr038   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr039()
      ENDCASE

      && Путевой лист грузового автомобиля с прицепом
      CASE m_vdoc==40.AND.a_menu[2]=='AVTO'
      DO CASE
         CASE m_var=="INPUT"
            s_vv040()
         CASE m_var=="EDIT"
            s_kr040   ("исправление")
         CASE m_var=="VIEW"
            s_kr040   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr040()
      ENDCASE

      && Путевой лист трактора
      CASE m_vdoc==37.AND.a_menu[2]=='TRAK'
      DO CASE
         CASE m_var=="INPUT"
            s_vv037()
         CASE m_var=="EDIT"
            s_kr037  ( "исправление")
         CASE m_var=="VIEW"
            s_kr037   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr037()
      ENDCASE

      && Учетный лист тракториста-машиниста - 2
      CASE m_vdoc==36.AND.a_menu[2]=='TRAK'
      DO CASE
         CASE m_var=="INPUT"
            s_vv036()
         CASE m_var=="EDIT"
            s_kr036  ( "исправление")
         CASE m_var=="VIEW"
            s_kr036   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr036()
      ENDCASE

      && Индивидуальный наряд помощника тракториста
      CASE m_vdoc==29.AND.a_menu[2]=='TRAK'
      DO CASE
         CASE m_var=="INPUT"
            s_vv031()
         CASE m_var=="EDIT"
            s_kr029  ( "исправление")
         CASE m_var=="VIEW"
            s_kr029   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr031()
      ENDCASE

      && Кассовая ведомость удержаний
      CASE m_vdoc==1.AND.a_menu[2]=='KASSA'
      DO CASE
         CASE m_var=="INPUT"
            s_vv002()
         CASE m_var=="EDIT"
            s_kr002  ( "исправление")
         CASE m_var=="VIEW"
            s_kr002   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr002()
      ENDCASE

      && Кассовая ведомость удержаний за с/х продукцию
      CASE m_vdoc==2.AND.a_menu[2]=='KASSA'
      DO CASE
         CASE m_var=="INPUT"
            s_vv002()
         CASE m_var=="EDIT"
            s_kr002  ( "исправление")
         CASE m_var=="VIEW"
            s_kr002   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr002()
      ENDCASE

      && Кассовая ведомость удерж. за продукцию животновод.
      CASE m_vdoc==3.AND.a_menu[2]=='KASSA'
      DO CASE
         CASE m_var=="INPUT"
            s_vv002()
         CASE m_var=="EDIT"
            s_kr002  ( "исправление")
         CASE m_var=="VIEW"
            s_kr002   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr002()
      ENDCASE

      && Табель учета рабочего времени
      CASE m_vdoc==30.AND.a_menu[2]=='ZAR'
      DO CASE
         CASE m_var=="INPUT"
            s_vv030()
         CASE m_var=="EDIT"
            s_kr030  ( "исправление")
         CASE m_var=="VIEW"
            s_kr030   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr001()
      ENDCASE

      && Наряд на сдельную работу ( индивидуальный )
      CASE m_vdoc==31.AND.a_menu[2]=='ZAR'
      DO CASE
         CASE m_var=="INPUT"
            s_vv031()
         CASE m_var=="EDIT"
            s_kr031  ( "исправление")
         CASE m_var=="VIEW"
            s_kr031   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr031()
      ENDCASE

      && Наряд на сдельную работу ( бригада )
      CASE m_vdoc==32.AND.a_menu[2]=='ZAR'
      DO CASE
         CASE m_var=="INPUT"
            s_vv032()
         CASE m_var=="EDIT"
            s_kr032  ( "исправление")
         CASE m_var=="VIEW"
            s_kr032   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr032()
      ENDCASE

      && Оплата отпускных
      CASE m_vdoc==20.AND.a_menu[2]=='ZAR'
      DO CASE
         CASE m_var=="INPUT"
            s_vv020_02("отп")
         CASE m_var=="EDIT"
            s_kr020   ("исправление")
         CASE m_var=="VIEW"
            s_kr020   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr001()
      ENDCASE

      && Оплата больничного листа
      CASE m_vdoc==21.AND.a_menu[2]=='ZAR'
      DO CASE
         CASE m_var=="INPUT"
            s_vv020_02("бол")
         CASE m_var=="EDIT"
            s_kr021 ("исправление")
         CASE m_var=="VIEW"
            s_kr021   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr001()
      ENDCASE

      && Универсальный реестр по заработной плате
      CASE m_vdoc==1 .AND.a_menu[2]=='ZAR'
      DO CASE
         CASE m_var=="INPUT"
            s_vv001()
         CASE m_var=="EDIT"
            s_kr001  ( "исправление")
         CASE m_var=="VIEW"
            s_kr001   ( "просмотр")
         CASE m_var=="PRINT"
            v_pr001()
      ENDCASE
ENDCASE
RETURN .T.

Function vhod()
LOCAL m_str:=space(10),x:=CHR(4)+CHR(248)+CHR(8)+"T"+CHR(6)+"D"+CHR(3)+"·╗+"
LOCAL a_user:={},i,i1
SET CURSOR OFF
set confirm on
SET CURSOR ON
CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","▓")
      CLEAREOL(0,0,"n/w")
      @0,0 SayDisp DMY(DATE())+" "+MyCDOW(DOW(DATE())) COLOR "n/w"
      @0,col()+2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
CLEAREOL(MAXROW()-1,0,"w/b","▒")
NET USE (m_syspath+"fdor") ALIAS fdor READONLY  NEW
DO WHILE .NOT. fdor->(EOF())
IF CHECKSUM(SUBSTR(fdor->name,5,11))<>BIN2L(SUBSTR(fdor->name,1,4))
      DISPERROR("Неверная запись номер "+STR(fdor->(RECNO()),3)+";ее нужно удалить")
      fdor->(DBSKIP())
ENDIF
AADD(a_user,{;
CRYPT(SUBSTR(fdor->name,5,4),x),PADR(CRYPT(SUBSTR(fdor->name,10,6),x),6),val(CRYPT(SUBSTR(fdor->name,9,1),x))})
fdor->(DBSKIP())
ENDDO
CLOSE fdor
//m_str:=GetSecret(m_str,MAXROW()-1,19, COLOR "w/b"

SET COLOR TO "w/b,w+/b"
i:=0
SET ESCAPE ON
DO WHILE .t.
  i++
  m_str:=SPACE(6)
@MAXROW()-1,25 SayDisp " Введiть Ваш пароль>" COLOR "gr+/b"
m_str:=GetSecret(m_str) //,MAXROW()-1,19, COLOR "w/b"
IF SUBSTR(m_str,1,2)==CHR(82)+CHR(74)
  IF SUBSTR(m_str,3,1)==chr(118).AND.SUBSTR(m_str,6,1)==chr(100)
    IF SUBSTR(m_str,4,2)==CHR(75)+CHR(84)
      m_tabn:=REPLICATE(CHR(42),4);m_oper:=REPLICATE(CHR(42),2);m_level:=CHR(48)
      EXIT
    ENDIF
  ENDIF
ENDIF

IF LASTKEY()==K_ESC
  IF ANSWERu("Вийти iз програми?")==YES
    QUIT
  ENDIF
ENDIF
IF (i1:=ASCAN(a_user,{|x|x[2]==m_str}))==0
  DispError("Пароль невiрен")
ELSE
  m_oper:=STR(i1+32,2)
  m_tabn :=a_user[i1][1]
  IF POSALPHA(m_tabn)<>0
    DispError("Помилка  в табельному номерi")
    QUIT
  ENDIF
  m_level:=a_user[i1][3]
  IF POSALPHA(m_level)<>0
    DispError("Помилка в прiорiтетi")
    QUIT
  ENDIF
  EXIT
ENDIF
IF i==3;DispError("Усi спроби вичерпано,;До побачення !!!!");quit;ENDIF
ENDDO
SET ESCAPE OFF
RETURN .t.
Function IndexBd()
  LOCAL m_path:=IF(a_menu[1]=="BUF",m_bufpath,m_mainpath)
  IndBd(m_path)
RETURN .t.
Function IndBd(m_path)
  LOCAL m_screen,m_proc,m_select

  m_screen:=DispMessage("Iндексацiя;"+IF(m_path=m_bufpath,"бази за мiсяць","з початку року"))
   m_proc := InitGauge(" Iндексацiя бази" )
   DispGauge(m_proc, 0)
   USE (m_path+"fd2") NEW
   INDEX ON Str ( fd2->vnuma , 7 ) TO (m_path+"fd2")
   USE (m_path+"boln2")
   INDEX ON boln2->vnumc TO (m_path+"boln2")
   USE (m_path+"boln1")
   INDEX ON boln1->ser+boln1->num TO (m_path+"boln1")
   DispGauge(m_proc, 0.05)
   DispGauge(m_proc, 0.15)
   DispGauge(m_proc, 0.20)
   DispGauge(m_proc, 0.25)
   DispGauge(m_proc, 0.30)
   DispGauge(m_proc, 0.35)
   DispGauge(m_proc, 0.40)
   USE (m_path+"fz1ae")
   INDEX ON Str ( fz1ae->vnum1 , 7 ) TO (m_path+"fz1ae")
   DispGauge(m_proc, 0.45)
   USE (m_path+"fz1ap")
   INDEX ON Str ( fz1ap->vnum1 , 7 ) TO (m_path+"fz1ap")
   DispGauge(m_proc, 0.50)
   USE (m_path+"fz1at")
   INDEX ON Str ( fz1at->vnum1 , 7 ) TO (m_path+"fz1at")
   DispGauge(m_proc, 0.55)
   USE (m_path+"fz1t")
   INDEX ON Str ( fz1t->vnum1 , 7 ) TO (m_path+"fz1t")
   DispGauge(m_proc, 0.60)
   USE (m_path+"fz1tp")
   INDEX ON Str ( fz1tp->vnum1 , 7 ) TO (m_path+"fz1tp")
   DispGauge(m_proc, 0.65)
   USE (m_path+"fz2")
   INDEX ON Str ( fz2->vnum1 , 7 ) TO (m_path+"fz2")
   DispGauge(m_proc, 0.75)
   USE (m_path+"fz2a")
   INDEX ON Str ( fz2a->vnum2 , 7 ) TO (m_path+"fz2a")
   DispGauge(m_proc, 0.80)
   USE (m_path+"fz2b")
   INDEX ON Str ( fz2b->vnum1 , 7 ) TO (m_path+"fz2b")
   DispGauge(m_proc, 0.85)
   USE (m_path+"fz2t")
   INDEX ON Str ( fz2t->vnum2 , 7 ) TO (m_path+"fz2t")
   DispGauge(m_proc, 0.90)
   USE (m_path+"fz2tp")
   INDEX ON Str ( fz2tp->vnum2 , 7 ) TO (m_path+"fz2tp")
   DispGauge(m_proc, 0.95)
   USE (m_path+"fz3")
   INDEX ON Str ( fz3->vnum2 , 7 ) TO (m_path+"fz3")
   DispGauge(m_proc, 1.00)
   USE
DelGauge(m_proc)
DelMessage(m_screen)
RETURN .t.


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
Function SetMntBd()
LOCAL m_path:=IF(a_menu[1]=="BUF",m_bufpath,m_mainpath)
LOCAL GetList:={}
IF m_level==0
  NET USE (m_path+"fvnum.dbr") NEW ALIAS fvnum
  IF fvnum->(NetRlock())
    SET ESCAPE ON
    @10,05,14,70 BOX B_DOUBLE+ " " COLOR "w+/bg"
    @11,07 SayDisp "Поточний мiсяць документiв по зарплатi >" COLOR "b/bg"
    @11,52 Get Fvnum->mnt COLOR "w+/bg,GR+/n" PICTURE "99.99"
    GetList[1]:block:={|x|IF(x==NIL,RIGHT(field->mnt,2)+"."+LEFT(field->mnt,2),field->mnt:=RIGHT(x,2)+LEFT(x,2))}
    @12,07 SayDisp "Поточний мiсяць документiв по проводкам>" COLOR "b/bg"
    @12,52 Get Fvnum->mnt1 COLOR "w+/bg,GR+/n" PICTURE "99.99"
    GetList[2]:block:={|y|IF(y==NIL,RIGHT(field->mnt1,2)+"."+LEFT(field->mnt1,2),field->mnt1:=RIGHT(y,2)+LEFT(y,2))}
    GetList[2]:display()
    READ
    fvnum->(DBUNLOCK())
  ENDIF
 CLOSE fvnum
ELSE
  DispError("Ви не маєте повноважень;на запуск цiєї програми")
ENDIF
RETURN .t.
Function DispMs(var)
  IF var=="FORM"
    m_proc:=TOKEN(a_menu[LEN(a_menu)-1],",",1)
    &m_proc()
  ENDIF
  IF var=="VIEW"
    viewmsh(TOKEN(a_menu[LEN(a_menu)-1],",",2))
  ENDIF
  IF var=="VIEW09"
    view09(TOKEN(a_menu[LEN(a_menu)-1],",",2))
  ENDIF
RETURN .t.
