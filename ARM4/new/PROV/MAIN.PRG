#include "new.ch"
#include "MENU.ch"
#include "pass.ch"
#  DEFINE   MNU_CLR      "w+/b,n/w"            // цвет меню
#DEFINE M_COLFIRST 1+LEN(A_MENU)*2  && Столбец верхнего левого угла меню
#DEFINE M_ROWFIRST 1+LEN(A_MENU)*1 && Строка  верхнего левого угла меню
#DEFINE M_COLLAST   M_COLFIRST+55 && Столбец нижнего правого угла меню
#DEFINE M_ROWLAST   M_ROWFIRST+12 && Строка нижнего правого угла

MEMVAR m_tabn,m_oper,m_level,m_syspath,m_workpath,a_menu,m_imja,m_sprpath,m_proc,m_copypath,p_npr
MEMVAR m_vdisk,m_bufpath,m_mainpath,m_mash,m_struct,m_exepath,m_shapka,m_temppath
MEMVAR m_virtdisk,m_menu_name,m_kassapath,m_menu,m_computer,m_platpath,m_uchpath
STATIC a_user:={}
Function Main(var1)
LOCAL m_time:=TIME(),m_pol,getlist:={},m_parol,m_str:=""

LOCAL s_files:={}

IF numfiles()<100
  DispError("Кiлькiсть дескрипторiв файлiв менш 100;Виправте CONFIG.SYS")
  QUIT
ENDIF
KSETCAPS(.f.)
KSETNUM(.t.)
SETBLINK(.F.)
SETSHARE(4)
READEXIT(.t.)
Beginit (var1)
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
SET KEY K_ALT_F10 TO Calc
InitParPrn()
NET USE (m_syspath+m_menu) INDEX (m_syspath+m_menu) ALIAS menu NEW READONLY
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"Screen") INDEX (m_syspath+"Screen")     NEW READONLY
NET USE (m_syspath+"tbget") INDEX (m_syspath+"tbget")       NEW READONLY
NET USE (m_syspath+"MAKET") INDEX (m_syspath+"MAKET") NEW
// NET USE (m_workpath+"PRED01") NEW
InitEdizm()
   m_time:=VAL(LEFT(TIME(),2))
   DO CASE
    CASE m_time>=5.AND.m_time<=12
      m_str:="Доброго ранку, "
    CASE m_time>=13.AND.m_time<=16
      m_str:="Добрий день, "
    CASE m_time>=16.AND.m_time<=23
      m_str:="Добрий вечiр, "
    OTHERWISE
      m_str:="Вiтаю Вас, "
  ENDCASE
  WaitMessage(m_str+'Шановн' + m_pol + m_imja + ',;'+'АРМ "Бухгалтер" вiтає Вас !',"bg+/bg,W+/BG")
  DO dialog
// SET KEY K_ESC TO Finish
Finish()
RETURN .t.
FUNCTION  Finish
         SET COLOR TO "w/b"
         CLEAR SCREEN
         CLOSE ALL
         QUIT
RETURN .t.
PROCEDURE dialog
  local obj_error,m_set,old_err
  local l_while:=.t.,i,j,k,a_prc:={},m_screen,m_key,s_files:={}
  Local a_hor_menu:={},a_num_menu:={},a_ver_menu:={},;
  menu_hor_width,s_letter:="",menu_col1,n_menu:=1,;
  menu_clr:="n/w,b/w,n/bg,w/b,n/w,w+/bg"
  private m_proc && Используется для макроподстановки имени процедуры
  private m_menu_name:='Головне меню ' && Используется для формирования наименования меню
  m_set:=CSetAll()
   menu->(DS("001"))
    menu->(DBEVAL ({||AADD(a_hor_menu,ALLTRIM(MENU->PUNKTNAME)),AADD(A_prc, ALLTRIM(MENU->PRC))},;
    ,{||"001"==MENU->NUMMENU}))
    ASIZE(a_ver_menu,LEN(a_hor_menu))
    FOR i:=1 TO LEN(a_prc)
      menu->(DS(a_prc[i]))
      a_ver_menu[i]:={}
      menu->(DBEVAL({||AADD(a_ver_menu[i],{ALLTRIM(menu->punktname),ALLTRIM(menu->prc),ALLTRIM(menu->par)})},;
     ,{||a_prc[i]==menu->nummenu}))
    NEXT

DO WHILE l_while
   old_err:=ERRORBLOCK( { |obj_error|  ArmError(obj_error) } )
//      CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","▓")
      DispWall()
      CLEAREOL(0,0,"n/g")
      CLEAREOL(MAXROW(),0,"n/g")
      @0,0 SayDisp DMY(DATE())+" "+NTOCDOW(DOW(DATE())) COLOR "n/g"
      @0,Col()+2 SayText 'АРМ Бухгалтера "~2Б~3а~4р~5с~1" - ~6Книга господарчих операцiй' COLOR "b/g,rb/g,gr+/g,r/g,g+/g,b+/g"
      @MAXROW(),0 SayDisp crypt(ITP,PASSWORD1) COLOR "b/g"
      @MAXROW(),Col()+1 SayText "Мережева Версiя N~22.0 ~1вiд ~201/08/98" COLOR "N/g,R/g"
    menu_hor_width:=INT(MAXCOL()/LEN(a_hor_menu));ASIZE(a_num_menu,LEN(a_hor_menu))
    AFILL(a_num_menu,1);n_menu:=1;CLEAREOL(1,0,USL_CLR)
    FOR i:=1 TO LEN(a_hor_menu);j:=AT("~",a_hor_menu[i]);IF j==0;a_hor_menu[i]:="~"+a_hor_menu[i]
    s_letter+=MyUPPER(SUBSTR(a_hor_menu[i],2,1));ELSE;s_letter+=MyUPPER(SUBSTR(a_hor_menu[i],j+1,1));END
    a_hor_menu[i]:=PADC(a_hor_menu[i],menu_hor_width);@1,(i-1)*menu_hor_width SayMenu a_hor_menu[i] COLOR (USL_CLR+","+SEL_CLR)
    j:=LEN(ALLTRIM(a_ver_menu[i][1][1]));ASCAN(a_ver_menu[i],{|x|IF(LEN(ALLTRIM(x[1]))>j,j:=LEN(ALLTRIM(x[1])),0)})
    FOR k:=1 TO LEN(a_ver_menu[i]);a_ver_menu[i][k][1]:=PADR(ALLTRIM(a_ver_menu[i][k][1]),j);NEXT;NEXT
   BEGIN SEQUENCE
//      MENU ('001')
      j:=1
      DO WHILE j==1
        @1,(n_menu-1)*menu_hor_width SayMenu a_hor_menu[n_menu] COLOR (SEL_H+","+SEL_H1)
        i:=LEN(a_ver_menu[n_menu][1][1])+3
        menu_col1:=MIN((n_menu-1)*menu_hor_width,MAXCOL()-i-4)
        m_screen:=SAVESCREEN (2,menu_col1 ,LEN(a_ver_menu[n_menu])+4,menu_col1+i+4)
        @2,menu_col1 ,LEN(a_ver_menu[n_menu])+3,menu_col1+i+2 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( "n/bg" )
        SHADOW( 2,menu_col1 ,LEN(a_ver_menu[n_menu])+3,menu_col1+i+2)
        FOR i:=1 TO LEN(a_ver_menu[n_menu])
          @2+i,menu_col1+1 SayDisp STR(i,1)+' '+a_ver_menu[n_menu][i][1] COLOR (IF(a_num_menu[n_menu]==i,"gr+/b","n/bg"))
        NEXT
        DO WHILE .t.
          i:=INKEY(0)
          DO CASE
            CASE i==K_ESC
              IF ANSWERu("Завершити програму?")==YES
                j:=0;m_key:=0;EXIT
              ENDIF
            CASE i==K_PGDN
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=LEN(a_ver_menu[n_menu])
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_PGUP
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=1
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_DOWN.AND.a_num_menu[n_menu]<LEN(a_ver_menu[n_menu])
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=a_num_menu[n_menu]+1
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_UP.AND.a_num_menu[n_menu]>1
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=a_num_menu[n_menu]-1
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_RIGHT
              j:=1
              i:=IF(n_menu==LEN(a_hor_menu),1,n_menu+1)
              EXIT
            CASE i==K_LEFT
              j:=1
              i:=IF(n_menu==1,LEN(a_hor_menu),n_menu-1)
              EXIT
            CASE i>=ASC("1").AND.i<=ASC("0")+LEN(a_ver_menu[n_menu])
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
              a_num_menu[n_menu]:=i-ASC("0")
              @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
            CASE i==K_ENTER
//                WaitMessage("Вызываем процедуру "+a_ver_menu[n_menu][a_num_menu[n_menu]][2]+";с параметром "+a_ver_menu[n_menu][a_num_menu[n_menu]][3])
               @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "n/bg"
                MyChoice(10,10,a_ver_menu[n_menu][a_num_menu[n_menu]][2],a_ver_menu[n_menu][a_num_menu[n_menu]][3],a_ver_menu[n_menu][a_num_menu[n_menu]][1])
               @2+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][a_num_menu[n_menu]][1] COLOR "gr+/b"
//                menu->(DS())
            CASE i==K_F10;calcul()
            CASE i==K_ALT_F10;calc()
            CASE (j:=AT(MyUpper(CHR(i)),s_letter))<>0
              i:=j;j:=1;EXIT
          ENDCASE
        ENDDO
        RESTSCREEN (2,menu_col1 ,LEN(a_ver_menu[n_menu])+4,menu_col1+LEN(a_ver_menu[n_menu][1][1])+3+4,m_screen)
        @1,(n_menu-1)*menu_hor_width SayMenu a_hor_menu[n_menu] COLOR (USL_CLR+","+SEL_CLR)
        IF j==1
          n_menu:=i
        ENDIF
      ENDDO
      l_while:=.f.
   RECOVER USING obj_error
      DBCOMMITALL()
      CLOSE ALL
      WAclose()
      CSetAll(m_set)
      SET PRINTER TO
      SET DEVICE TO SCREEN
      asize(a_menu,0)
   END SEQUENCE
   ERRORBLOCK(old_err)
IF l_while
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE")  ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+m_menu) INDEX (m_syspath+m_menu) ALIAS menu NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")      ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"Screen") INDEX (m_syspath+"Screen")     NEW READONLY
NET USE (m_syspath+"tbget") INDEX (m_syspath+"tbget")       NEW READONLY
NET USE (m_syspath+"MAKET") INDEX (m_syspath+"MAKET") NEW
m_menu_name:=' Головне меню '
ENDIF
  ENDDO
RETURN

FUNCTION Menu (M_choice)
    local M_screen:=SAVESCREEN (M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+1)
    local m_recno:= MENU->(RECNO())
    local a_choice:={ "0 Вихiд"},; && Перечень пунктов меню
          a_prc:={},;            && Перечень вызываемых процедур
          a_par:={}              && Параметры процедур
    local m_key:=0,i:=ASC("0")
    @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ("w+/b,gr+/n,,,w+/b")
    @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM(m_menu_name)+' ',55 -5) COLOR ("r+/b")
    MENU->(DBseek(m_choice))
    SET COLOR TO ( MNU_CLR )
    menu->(DBEVAL ({||i++,AADD(A_CHOICE, CHR(i)+" "+MENU->PUNKTNAME),AADD(A_prc, ALLTRIM(MENU->PRC));
             ,AADD(A_par, ALLTRIM(MENU->PAR))},,{||m_choice ==MENU->NUMMENU}))
    DO WHILE .T.
        m_key :=ACHOICE (M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST-1,M_COLLAST-2, A_CHOICE,,, m_key,)
      IF M_KEY==1.OR. m_key==0
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
          VGAPALETTE()
          SetCursor ( 0 )
          setblink(.f.)
          VGAPALETTE(6,30,30,30)
          VGAPALETTE(7,50,50,50)
          VGAPALETTE(10,17,56,17)
          VGAPALETTE(2,14,36,14)
          VGAPALETTE(5,42,16,42)
          VGAPALETTE(13,28,16,43)
          IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_temppath+"screen.scr")
          ENDIF
        ELSE
          WaitMessage("Програма не пiдключена","w/r,gr+/r",.t.)
        ENDIF
        SET COLOR TO ( MNU_CLR )
     ENDIF
     ASIZE(a_menu,len(a_menu)-1)
    ENDDO
RETURN .T.


FUNCTION BegInit (m_var)

   LOCAL SwapingSpace := 3,s1:=LOWER(EXENAME()),i // количество свободного пространства
                                     // на диске в Мбайтах, необходимое для
                                     // работы АРМ "Бухгалтер"

   // ----------------------------------------------------
   // --- УСТАHОВKА ПАРАМЕТРОВ, ОБЩИХ ДЛЯ ВСЕЙ СИСТЕМЫ ---
   // ----------------------------------------------------
   SetCancel ( .f. )
//   Fontreset()
   VGAPALETTE()
   SetCursor ( 0 )
   setblink(.f.)
   VGAPALETTE(6,30,30,30)
   VGAPALETTE(7,50,50,50)

   Set ( _SET_ESCAPE     , .t. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   SET EPOCH TO 1960
   PUBLIC   m_workpath  := 'd:\buhgal\plat\'       // каталог с текущей БД
   PUBLIC   m_platpath  := 'd:\buhgal\plat\'       // каталог с текущей БД
   PUBLIC   m_kassapath := 'd:\buhgal\kassa\'      // каталог с кассой
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'      // каталог с буферной БД
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'      // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'      // каталог со справочниками
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'      // каталог для .EXE модуля пакета
   PUBLIC   m_mash      := 'd:\buhgal\ms\'      // каталог для машинограмм
   PUBLIC   m_syspath   := 'd:\buhgal\SYSTEM\'  // каталог с  системной информацией
   PUBLIC   m_temppath  := 'd:\buhgal\temp\'    // каталог с буферной БД
   PUBLIC   m_menu      :=  "menu99"
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
   PUBLIC   m_copypath   :='d:\buhgal\cp\'
   PUBLIC   m_computer  :=1

   IF .NOT.EMPTY(m_var)
      USE init NEW READONLY
      IF VAL(m_var)>0.AND.VAL(m_var)<=LASTREC()
        DBGOTO(VAL(m_var))
        m_workpath  :=ALLTRIM(init->nk)
        m_platpath  :=ALLTRIM(init->nk)
        m_bufpath   :=ALLTRIM(init->bf)
        m_mainpath  :=ALLTRIM(init->mn)
        m_sprpath   :=ALLTRIM(init->sp)
        m_exepath   :=ALLTRIM(init->bh)
        m_mash      :=ALLTRIM(init->ms)
        m_syspath   :=ALLTRIM(init->js)
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

   PUBLIC m_level
   PUBLIC m_oper     := ' '             // --- код оператора ( пользователя )
   PUBLIC m_tabn     := ' '      // --- табельный N оператора ( пользователя )

   PUBLIC m_imja  := ' '         // --- имя-отчество пользователя

   NET USE (m_platpath+"pred01") NEW READONLY
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
LOCAL i,i1,m_time,m_date:=DATE(),GetList:={},m_file
SET CURSOR OFF
set confirm on
SET CURSOR ON
CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","▓")
CLEAREOL(0,0,"n/w")
@0,0 SayDisp DMY(DATE())+" "+NTOCDOW(DOW(DATE())) COLOR "n/w"
@0,col()+2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
CLEAREOL(MAXROW()-1,0,"w/b","▒")
NET USE (m_syspath+"fdor") READONLY  NEW
a_user:={}
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

IF LASTKEY()==K_ESC
  IF ANSWERu("Вийти iз системи?")==YES
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
IF i>=3
  DispError("Всi спроби вичерпано,;До побачення !!!!")
  quit
ENDIF
ENDDO
/*
SET ESCAPE OFF

  @02,14,06,66 BOX B_DOUBLE+" " color "W/B"
  shadow(02,14,06,66)
  @03,26 SayDisp "Сьогоднi "+DMY(m_date)+" "+NTOCdow(DOW(m_date)) COLOR "w+/b"
  @05,30 SayDisp "Дата>" COLOR "W+/B"
  @04,30 SayDisp "Час> " COLOR "W+/B"
  m_time:=TIME()
  @04,37 GET m_time COLOR "GR+/B,GR+/N" PICTURE "99:99:99"
  @05,37 GET m_date COLOR "GR+/B,GR+/N"
  READ
  SETTIME(m_time)
  SETDATE(m_date)
  */
  m_str:=MEMOREAD(m_exepath+"computer.txt")
  m_computer:=VAL(TOKEN(m_str))
RETURN .t.

#UNDEF   HIGHER
#UNDEF   M_ROWFIRST
#UNDEF   M_COLFIRST
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
Function DispWall(var)
LOCAL i:=0,j:=0,m_char:=" "
LOCAL m_clr:=IF(var==NIL,"w/b",var)
DispBegin()
DO CASE
  CASE DOW(DATE())==1
    m_clr:="w/rb"
  CASE DOW(DATE())==2
    m_clr:="w/b"
  CASE DOW(DATE())==3
    m_clr:="b/bg"
  CASE DOW(DATE())==4
    m_clr:="w/gr"
  CASE DOW(DATE())==5
    m_clr:="n/w"
  CASE DOW(DATE())==6
    m_clr:="w/rb"
  CASE DOW(DATE())==7
    m_clr:="w/g"
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
STATIC Function MyChoice(x,y,m_choice,m_par,m_name)
local m_screen,i:=0,j:=0,n_menu:=1
local m_recno:= MENU->(RECNO())
local a_choice:={"Вихiд"},; && Перечень пунктов меню
a_prc:={},;            && Перечень вызываемых процедур
a_par:={}              && Параметры процедур
local m_key:=0
  AADD(a_menu,m_par)
  IF Isdigit(m_choice) // Формировать меню
    MENU->(DBseek(m_choice))
    menu->(DBEVAL ({||i++,AADD(a_choice, ALLTRIM(menu->punktname)),AADD(a_prc, ALLTRIM(menu->prc));
   ,IF(LEN(a_choice[i+1])>j,j:=LEN(a_choice[i+1]),NIL),AADD(a_par, ALLTRIM(menu->par))},,{||m_choice ==menu->nummenu}))
    i:=1;AEVAL(a_choice,{|x|a_choice[i]:=PADR(a_choice[i],j),i++})
    m_screen:=SAVESCREEN (x,y ,x+LEN(a_choice)+2,y+j+6)
    @x,y,x+LEN(a_choice)+1,y+j+4 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ("n/bg")
    @x,y+2 SayDisp ' '+ALLTRIM(m_name)+' ' COLOR "w+/Bg"
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
              IF n_menu==1
                EXIT
              ENDIF
//              WaitMessage("Вызываем процедуру "+a_prc[n_menu-1]+";с параметром "+a_par[n_menu-1])
              MyChoice(x+2,y+4,a_prc[n_menu-1],a_par[n_menu-1],a_choice[n_menu])
          CASE m_key==K_F10;calcul()
          CASE m_key==K_ALT_F10;calc()
        ENDCASE
      ENDDO
      RESTSCREEN(x,y ,x+LEN(a_choice)+2,y+j+6,m_screen)
  ELSE
      m_proc:=m_choice
      IF .NOT.EMPTY(m_proc)
        ScreenFile(m_temppath+"screen.scr")
        IF XTOC(&m_proc(m_par))<>"NORESTORE"
          FileScreen(m_temppath+"screen.scr")
        ENDIF
      ELSE
        DispError("Програма не пiдключена")
      ENDIF
  ENDIF
ASIZE(a_menu,MAX(LEN(a_menu)-1,0))
RETURN .T.
Function GetOper(x)
  LOCAL i:=VAL(x)-32
  IF i<1.OR.i>LEN(a_user)
    RETURN "****"
  ENDIF
RETURN a_user[i][1]
Function DispParMsh()
   SetParMsh(a_menu[LEN(a_menu)-1])
RETURN .t.
Function DispViewMs()
   ViewMs(a_menu[LEN(a_menu)-1])
RETURN .t.
Function DispRmsh()
//   WaitMessage("Перед розрахунком машиниграм обов'язково ;проiндексуйте основну базу")
DO CASE
  CASE a_menu[LEN(a_menu)-1] ==  "62"
    Rms62()
  CASE a_menu[LEN(a_menu)-1] ==  "63"
    Rms63()
  CASE a_menu[LEN(a_menu)-1] ==  "64"
    Rms64()
  CASE a_menu[LEN(a_menu)-1] ==  "65"
    Rms65()
  CASE a_menu[LEN(a_menu)-1] ==  "66"
    Rms66()
  CASE a_menu[LEN(a_menu)-1] ==  "67"
    Rms67()
  CASE a_menu[LEN(a_menu)-1] ==  "68"
    Rms68()
  CASE a_menu[LEN(a_menu)-1] ==  "69"
    Rms69()
  CASE a_menu[LEN(a_menu)-1] ==  "72"
    Rms72()
  CASE a_menu[LEN(a_menu)-1] ==  "75"
    Rms75()
  CASE a_menu[LEN(a_menu)-1] ==  "70"
    Rms70()
  CASE a_menu[LEN(a_menu)-1] ==  "76"
    Rms76()
  CASE a_menu[LEN(a_menu)-1] ==  "74"
    Rms74()
  CASE a_menu[LEN(a_menu)-1] ==  "81"
    Rms81()
  CASE a_menu[LEN(a_menu)-1] ==  "82"
    Rms82()
  CASE a_menu[LEN(a_menu)-1] ==  "83"
    Rms83()
  CASE a_menu[LEN(a_menu)-1] ==  "84"
   Rms84()
  CASE a_menu[LEN(a_menu)-1] ==  "86"
   Rms86()
endcase

RETURN .t.
Function SetMntBd()
LOCAL m_path:=IF(a_menu[1]<>"MAIN",m_bufpath,m_mainpath)
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
    GetList[2]:block:={|y|IF(y==NIL,SUBSTR(field->mnt1,3,2)+"."+SUBSTR(field->mnt1,1,2),field->mnt1:=RIGHT(y,2)+LEFT(y,2))}
    GetList[2]:display()
    READ
    fvnum->(DBUNLOCK())
  ENDIF
 CLOSE fvnum
ELSE
  DispError("Ви не маєте повноважень;на запуск цiєї програми")
ENDIF
RETURN .t.
Function IndexSp()
LOCAL m_gauge:=INitGauge("Iндексацiя довiдникiв",2)
LOCAL n:=32,i:=0,m_str
SETBLINK(.f.)
SET CURSOR OFF
m_str:=DispMessag("Iндексацiя SP01")
USE (m_sprpath+"sp01") NEW;INDEX ON field->brgd TO (m_sprpath+"sp01")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP02")
USE (m_sprpath+"sp02");INDEX ON field->mol TO (m_sprpath+"sp02")
USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW
SELE Sp02
set rela to sP02->tabn INTO Sp10
INDEX ON UPPER(Sp10->fam+Sp10->imja+Sp10->otch) TO (m_sprpath+"sp02a")
CLOSE Sp10
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP03")
USE (m_sprpath+"sp03");INDEX ON field->kktg TO (m_sprpath+"sp03")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP04")
USE (m_sprpath+"sp04");INDEX ON field->kprof TO (m_sprpath+"sp04")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP05")
USE (m_sprpath+"sp05");INDEX ON field->kopr TO (m_sprpath+"sp05")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP06")
USE (m_sprpath+"sp06");INDEX ON field->vrab TO (m_sprpath+"sp06")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя sp44")
USE (m_sprpath+"sp44");INDEX ON field->ksash TO (m_sprpath+"sp44")
INDEX ON LEFT(field->ksash,3)+UPPER(sp44->naim7) TO (m_sprpath+"sp44a")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP08")
USE (m_sprpath+"sp08");INDEX ON field->kopu TO (m_sprpath+"sp08")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP09")
USE (m_sprpath+"sp09");INDEX ON field->tabn + field->kopu TO (m_sprpath+"sp09")
INDEX ON field->kopu+ field->tabn TO (m_sprpath+"sp09a")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP10")
USE (m_sprpath+"sp10");INDEX ON field->tabn TO (m_sprpath+"sp10")
INDEX ON UPPER(field->fam)+UPPER(field->imja)+UPPER(field->otch) TO (m_sprpath+"sp10a")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
IF FILE(m_sprpath+"sp11.dbf")
m_str:=DispMessag("Iндексацiя SP11")
  USE (m_sprpath+"sp11");INDEX ON field->Sch TO (m_sprpath+"sp11")
DelMessage(m_str)
ENDIF
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP13A")
USE (m_sprpath+"sp13A");INDEX ON field->kavt TO (m_sprpath+"sp13A")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP13b")
USE (m_sprpath+"sp13B");INDEX ON field->kmtr TO (m_sprpath+"sp13B")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP15")
USE (m_sprpath+"sp15");INDEX ON field->tabn TO (m_sprpath+"sp15")
DelMessage(m_str)
m_str:=DispMessag("Iндексацiя SP16")
USE (m_sprpath+"sp16");INDEX ON field->amrt TO (m_sprpath+"sp16")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP20")
USE (m_sprpath+"sp20");INDEX ON field->year+field->gr TO (m_sprpath+"sp20")
// m_str:=DispMessag("Iндексацiя SP21A")
// USE (m_sprpath+"sp21A");INDEX ON field->year+field->kod TO (m_sprpath+"sp21A")
// DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP22")
USE (m_sprpath+"sp22");INDEX ON field->mnt + field->kmtop TO (m_sprpath+"sp22")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP23")
USE (m_sprpath+"sp23");INDEX ON field->tkm TO (m_sprpath+"sp23")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP24")
USE (m_sprpath+"sp24");INDEX ON field->dbt TO (m_sprpath+"sp24")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP25")
USE (m_sprpath+"sp25");INDEX ON field->kopu TO (m_sprpath+"sp25")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя SP30")
USE (m_sprpath+"sp30");INDEX ON field->dbt TO (m_sprpath+"sp30")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя inv_a")
USE (m_sprpath+"inv_a");INDEX ON field->gnavt TO (m_sprpath+"inv_a")
INDEX ON field->tabn TO (m_sprpath+"inv_aa")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя inv_p")
USE (m_sprpath+"inv_p");INDEX ON field->gnavt TO (m_sprpath+"inv_p")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_str:=DispMessag("Iндексацiя inv_t")
USE (m_sprpath+"inv_t");INDEX ON field->invnum TO (m_sprpath+"inv_t")
INDEX ON field->tabn TO (m_sprpath+"inv_ta")
DelMessage(m_str)
m_gauge:=DispGauge(m_gauge,i++/n)
m_gauge:=DispGauge(m_gauge,i++/n)
m_gauge:=DispGauge(m_gauge,i++/n)
m_gauge:=DispGauge(m_gauge,i++/n)
m_gauge:=DispGauge(m_gauge,i++/n)
USE
SET CURSOR ON
RETURN ( NIL )
