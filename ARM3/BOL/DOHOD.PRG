#include "new.ch"
 #include "pass.ch"
//#include "setcurs.ch"
Memvar a_menu,m_workpath,m_syspath
Memvar M_DBSPATH,M_BUFPATH,M_MAINPATH,M_SPRPATH,M_EXEPATH,m_proc,m_temppath
Memvar M_MASH,M_COPYPATH,M_MENU_NAME
Memvar  m_uchpath
FUNCTION BegInit (var1)
LOCAL m_time:=TIME(),m_env,getlist:={},m_path,m_x,m_name,;
      m_var1:=IF(var1==NIL,"",alltrim(var1)),s1

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

   SET DATE BRITISH
   SET EPOCH TO 1960

   CLEAR SCREEN
   PUBLIC   m_dbspath   := ''              // каталог с текущей БД
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // каталог с буферной БД
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // каталог со справочниками
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // каталог для .EXE модуля пакета
   PUBLIC   m_mash      := 'd:\buhgal\ms\'  // каталог для машинограмм
   PUBLIC   m_syspath   := 'd:\buhgal\js\'  // каталог с  системной информацией
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
          m_syspath   := m_var1+'js\'
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
   PUBLIC a_menu:={}
KSETCAPS(.f.)
KSETNUM(.t.)
CLEARWIN(0,0,MAXROW(),MAXCOL(),"n/w","▓")
CLEAREOL(0,0,"n/w")
CLEAREOL(MAXROW(),0,"n/w")
@0,0 SayDisp DMY(DATE())+" "+NTOCDOW(DOW(DATE())) COLOR "n/w"
@0,Col()+2 SayText 'АРМ Бухгалтера "~2Б~3а~4р~5с~1" - ~6Формування довiдки     '  COLOR "b/w,rb/w,gr+/w,r/w,g+/w,b+/w"
 @MAXROW(),2 SayDisp crypt(ITP,PASSWORD1) COLOR "b/W"
@MAXROW(),Col()+2 SayText "Версiя №~2 1.00 ~1вiд ~218/04/99" COLOR "N/w,R/w"
   SET KEY K_F10 TO Calcul
   SET KEY K_ALT_F10 TO Calc
keyboard ''
USE (m_workpath+"menud") INDEX (m_workpath+"menud") ALIAS menu NEW
KEYBOARD ""
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"SPVIEW") INDEX (m_syspath+"SPVIEW")     ALIAS VIEW NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN")     NEW READONLY
dialog("Довiдка на субсидiю ")
Finish()
close all
RETURN .t.
FUNCTION  Finish
         SET COLOR TO DOS_CLR
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
//  initarmerror()
  KEYBOARD ""
  DO WHILE l_while
   BEGIN SEQUENCE
      MENU ('001')
      l_while:=.f.
   RECOVER USING obj_error
      QUIT
   END SEQUENCE
  ENDDO
RETURN .t.

FUNCTION Menu (M_choice)
    local M_screen:=SAVESCREEN (M_ROWFIRST-1, M_COLFIRST, M_ROWLAST+1,M_COLLAST+2)
    local m_recno:= MENU->(RECNO())
    local a_choice:={ "0 Вихiд"},; && Перечень пунктов меню
          a_prc:={},;            && Перечень вызываемых процедур
          a_par:={}              && Параметры процедур
    local m_key:=0
    @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ('w+/b,gr+/n,,,w+/b' )
    SHADOW(M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST)
    SET COLOR TO  ( 'r+/b')
    @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM(m_menu_name)+' ',M_WIDTH -5)
    MENU->(DBseek(m_choice))
    SET COLOR TO ( 'w+/b,n/w' )
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
         ScreenFile(m_workpath+"screen.scr")
         IF XTOC(&m_proc(a_par[m_key-1]))<>"NORESTORE"
            FileScreen(m_workpath+"screen.scr")
         ENDIF
        ELSE
          Disperror("Програма не пiдключена")
        ENDIF
        SET PRINTER TO
        SET COLOR TO ('w+/b,n/w' )
      ENDIF
      ASIZE(a_menu,len(a_menu)-1)
   ENDDO
RETURN .T.
Function SetVar()
  LOCAL m_rr,m_cc,m_kod,GetList:={},m_kod1,;
  m_id1,m_fam1,m_tel1,;
  m_id2,m_fam2,m_tel2,m_name,m_name1,m_year,;
  n_win
  n_win:=WOPEN(01,08,22,72)
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE + " " COLOR "w/bg"
  @0,2 SayDisp "Довiдкова iнформацiя" COLOR "n/w"
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_name:=PADR(RESTVAR1("m_name","DR"),50)
  m_name1:=PADR(RESTVAR1("m_name1","DR"),50)
  m_rr:=PADR(RESTVAR1("m_rr","DR"),2)
  m_cc:=PADR(RESTVAR1("m_cc","DR"),2)
  m_kod:=PADR(RESTVAR1("m_kod","DR"),10)
  m_kod1:=PADR(RESTVAR1("m_kod1","DR"),10)
  m_id1:=PADR(RESTVAR1("m_id1","DR"),10)
  m_fam1:=PADR(RESTVAR1("m_fam1","DR"),30)
  m_tel1:=PADR(RESTVAR1("m_tel1","DR"),10)
  m_id2:=PADR(RESTVAR1("m_id2","DR"),10)
  m_fam2:=PADR(RESTVAR1("m_fam2","DR"),30)
  m_tel2:=PADR(RESTVAR1("m_tel2","DR"),10)
  m_year:=PADR(RESTVAR1("m_year","DR"),4)
  SET ESCAPE ON
  SET CURSOR ON
  @02,2 SayDisp "Назва юридiчної особи>" COLOR "n/bg"
  @03,2 SayDisp "Код ЄДРПОУ юридiчної особи>" COLOR "n/bg"
  @08,2 SayDisp "Керiвник пiдприємства " COLOR "n/bg"
  @09,2 SayDisp "Код                       Ф.I.Б.              телефон " COLOR "n/bg"
  @11,2 SayDisp "Головний бухгалтер    " COLOR "n/bg"
  @12,2 SayDisp "Код                       Ф.I.Б.              телефон " COLOR "n/bg"
  @14,2 SayDisp "Рiк " COLOR "n/bg"

  @02,29 GET m_name PICTURE "@s34" COLOR "w/b,GR+/N"
  @03,29 GET m_kod COLOR "w/b,GR+/N"
  @10,2 GET m_id1 COLOR "w/b,GR+/N"
  @10,15 GET m_fam1 COLOR "w/b,GR+/N"
  @10,47 GET m_tel1 COLOR "w/b,GR+/N"
  @13,2 GET m_id2 COLOR "w/b,GR+/N"
  @13,15 GET m_fam2 COLOR "w/b,GR+/N"
  @13,47 GET m_tel2 COLOR "w/b,GR+/N"
  @14,15 GET m_year COLOR "w/b,GR+/N"
  READ
  IF LASTKEY()<>K_ESC
    SAVEVAR1("m_name",m_name,"DR")
    SAVEVAR1("m_name1",m_name1,"DR")
    SAVEVAR1("m_kod",m_kod,"DR")
    SAVEVAR1("m_id1", m_id1,"DR")
    SAVEVAR1("m_fam1",m_fam1,"DR")
    SAVEVAR1("m_tel1",m_tel1,"DR")
    SAVEVAR1("m_id2", m_id2,"DR")
    SAVEVAR1("m_fam2",m_fam2,"DR")
    SAVEVAR1("m_tel2",m_tel2,"DR")
    SAVEVAR1("m_year",m_year,"DR")
  ENDIF
  CLOSE myvar
  WCLOSE(n_win)
  WSELECT(0)
RETURN .t.
#DEFINE   HIGHER 10
#UNDEF   M_ROWFIRST
#DEFINE   M_ROWFIRST INT((MAXROW()-m_high)/2)+i
#UNDEF  M_COLFIRST
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

//    ПРОЦЕДУРА РАСЧЕТА

Function FormDohod()
  Local m_mnt1:=1,m_mnt2:=12,m_tabn:="    ",GetList:={},s_files:={}
  LOCAL m_year,m_name,m_kod,m_id1,m_fam1,m_tel1,m_id2,m_fam2,m_tel2
  LOCAL a_sum:={},a_kopu:={"914","915","916","917"},i,k,j
  // ввести перiод i табельний номер
  @9,10,12,70 BOX B_DOUBLE+' ' COLOR "w+/bg"
  @09,12 SayDisp "Введiть таб. номер i перiод розрахунку" COLOR "n/bg"
  @10,12 SayDisp "Таб. номер>"  COLOR "gr+/bg"
  @11,12 SayDisp "З       по  "   COLOR "gr+/bg"
   SopenFiles("SP10",@s_files)
  set escape on
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_name:=PADR(RESTVAR1("m_name","DR"),50)
  m_kod:=PADR(RESTVAR1("m_kod","DR"),10)
  m_id1:=PADR(RESTVAR1("m_id1","DR"),10)
  m_fam1:=PADR(RESTVAR1("m_fam1","DR"),30)
  m_tel1:=PADR(RESTVAR1("m_tel1","DR"),10)
  m_id2:=PADR(RESTVAR1("m_id2","DR"),10)
  m_fam2:=PADR(RESTVAR1("m_fam2","DR"),30)
  m_tel2:=PADR(RESTVAR1("m_tel2","DR"),10)
  m_year:=PADR(RESTVAR1("m_year","DR"),4)
  @10,24 get m_tabn valid (sp10->(Sp_vl("SP10",,10,30,"_fio()","b/bg"))) color "w/b,gr+/n"
  @11,14 GET m_mnt1 PICTURE "99" VALID (EVAL({||m_mnt2:=m_mnt1+2,m_mnt1>0.AND.m_mnt1<13}))     color "w/b,gr+/n"
  @11,24 GET m_mnt2 PICTURE "99" VALID m_mnt2>=m_mnt1.AND.m_mnt2<13  color "w/b,gr+/n"
  @11,30 get m_year PICTURE "9999"   color "w/b,gr+/n"
  READ
  IF LASTKEY()<>K_ESC
  // порахувати
    USE (m_mainpath+"fl01")INDEX  (m_mainpath+"fl01") NEW
    FOR i:=m_mnt1 TO m_mnt2+1
      AADD(a_sum,{0,0,0,0,0})
    NEXT
    FOR j:=1 TO LEN(a_kopu)
      IF Fl01->(DS(m_year+m_tabn+a_kopu[j]))
        FOR i:=m_mnt1 TO m_mnt2
          k:=Fl01->(FIELDNUM("OTDN"+STRZERO(i,2)))
          a_sum[i-m_mnt1+1][1]+=fl01->(FIELDGET(k))
          k:=Fl01->(FIELDNUM("SUM0"+STRZERO(i,2)))
          a_sum[i-m_mnt1+1][j+1]:=fl01->(FIELDGET(k))
        NEXT
      ENDIF
    NEXT
    Close fl01
  // записати у файл
  SET PRINTER TO "dohod01.lst"
  SET CONSOLE OFF
  SET PRINTER ON
  ?SPACE(10)+PADR(LEFT(m_name,40),40)+"Код по ЄДРПОУ: "+m_kod
  ?SPACE(50)+"Телефон: "+m_tel1
  ?
  ?
  ?
  ?
  ?
  ?
  ?SPACE(10)+"                  ДОВIДКА"
  ?SPACE(10)+"                о доходах"
  ?
  ?SPACE(10)+"Видана гр. "+ALLTRIM(_FioFull(m_tabn))+"  (таб.No "+m_tabn+")"
  ?SPACE(10)+"в тому, що "+IF(UPPER(sp10->pol)=="Ж","вона","вiн")+" працює на пiдприємствi:"
  ?SPACE(10)+PADR(LEFT(m_name,40),40)
  ?SPACE(10)+"форма працевлаштування:"
  IF Sp10->kpn=="6"
    ??" по договору "
  ELSE
    IF  Sp10->kpn=="4"
      ??"сумiсництво"
    ELSE
      ??"основне мiсце работи"
    ENDIF
  ENDIF
  ?SPACE(10)+"в посадi:"
  sp04->(DS(Sp10->kprof))
  ??Sp04->name4b
  ?SPACE(10)+"iндивiдуальний iдентифiкацiйний номер "+Sp10->codn
  ?SPACE(10)+"─────────┬────────┬────────────┬────────────┬────────────┬────────────"
  ?SPACE(10)+"         │        │ Нарахована │   Iншi     │  Допомога  │            "
  ?SPACE(10)+"Мiсяцi   │ Кiль.  │заробiтна   │ нарахування│  сiм'ям з  │Виплаченi   "
  ?SPACE(10)+"року     │ днiв   │плата,в т.ч │ в т.ч в    │   дiтьми   │алiменти    "
  ?SPACE(10)+"         │        │в натуральн.│ натуральн. │   (грн)    │ (грн)      "
  ?SPACE(10)+"         │        │формi (грн) │формi (грн) │            │            "
  ?SPACE(10)+"─────────┴────────┴────────────┴────────────┴────────────┴────────────"
    FOR i:=m_mnt1 TO m_mnt2
      ?SPACE(10)
      ??PADR(LEFT(NTOCMONTH(i),12),12)
      ??STR(a_sum[i-m_mnt1+1,1],5,2)
      FOR j:=2 TO 5
        ??"    "+STR(a_sum[i-m_mnt1+1,j],9,2)
        a_sum[len(a_sum),j]:=a_sum[len(a_sum),j]+a_sum[i-m_mnt1+1,j]
      NEXT
      a_sum[len(a_sum),1]:=a_sum[len(a_sum),1]+a_sum[i-m_mnt1+1,1]
    NEXT
     ?SPACE(10)+"---------------------------------------------------------------------- "
     ?SPACE(10)+"Разом:    "
     i:=LEN(a_sum)
      ??STR(a_sum[i,1],7,2)
      FOR j:=2 TO 5
        ??"    "+STR(a_sum[i,j],9,2)
      NEXT
     ?
     ?SPACE(10)+"Загальна сума додходу за перiод: "
     ??ALLTRIM(NTOCMONTH(m_mnt1))+","+m_year+"р. -"
     ??ALLTRIM(NTOCMONTH(m_mnt2))+","+m_year+"р."
     i:=a_sum[i,2]+a_sum[i,3]+a_sum[i,4]-a_sum[i,5]
     k:=INT(i)
     j:=ROUND((i-k)*100,2)
     ?SPACE(10)+"за вирахуванням алiментiв становить:"
     ?
     ?SPACE(10)+"     "+NumToChar(INT(i))+" грв. "+STR(j,2)+" кoп"
     ?
     ?SPACE(10)+"Довiка видана для пред'явлення в вiддiл житлово-коммунальних субсiдiй."
     ?
     ?
     ?
     ?
     ?"                       Голова               "+m_fam1
     ?"           МП  "
     ?"                       Гол.бухгалтер        "+ m_fam2
     ?
     ?
     SET PRINT OFF
     SET PRINTER TO
     SET CONSOLE ON
     Dima04()
  ENDIF
  ScloseFiles(@s_files)
RETURN .T.

  // записати у файл
  // редактувати
RETURN .T.
Function dima04()
  LOCAL n_win,m_buf:=MEMOREAD("dohod01.lst")
  LOCAL m_clr
  SAVEPAR()
  WSELECT(0)
  n_win:=WOPEN(1,1,MAXROW()-1,MAXCOL()-1)
  WSELECT(n_win)
  m_clr:=SETCOLOR("w/n")
  WBOX(12)
  SETCOLOR("gr+/n")
  set cursor on
  m_buf:=MEMOEDIT(m_buf,0,0,MAXROW(),MAXCOL(),.T.,"DIMA03",80)
  MEMOWRIT("dohod01.lst",m_buf)
  set cursor off
  SETCOLOR(m_clr)
  wclose(N_WIN)
  SAVEPAR(1)
RETURN .T.
Function DIma03(MODE,LINE,COL)
  if MODE==1.OR.MODE==2
    if lastkey()==K_CTRL_END.OR.lastkey()==K_F12
      RETURN K_CTRL_W
    ENDIF
    if lastkey()==K_F2
      IF ANSWERu("Друкувати довiдку")==YES
        FILEAPPEND(m_workpath+"dohod01.lst",m_workpath+"dohod.all")
        IF SPOOLACTIV().AND.SPOOLCOUNT()<6
          SPOOLADD(m_workpath+"dohod01.lst")
        ELSE
          MyPRINTFILE(m_workpath+"dohod01.lst",.t.)
        ENDIF
      ENDIF
      RETURN 0
    ENDIF
  ENDIF
RETURN 0
