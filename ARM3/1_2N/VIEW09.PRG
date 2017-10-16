#INCLUDE "NEW.CH"
#INCLUDE "MENU.CH"
#DEFINE BUF_SIZE 128
#define FIRST_ROW 2
#define LAST_ROW (MAXROW()-2)
#define FIRST_COL 1
#define LAST_COL  MAXCOL()-1
#define n_len_screen  21
#DEFINE N_PAPER 2
#define END_PAGE  "<<<<<   КIНЕЦЬ СТОРIНКИ   >>>>>"

STATIC S_NUM := "09"
STATIC l_trn:=.t.
MEMVAR M_DBSPATH,M_BUFPATH,M_MAINPATH,M_SPRPATH,M_EXEPATH
MEMVAR M_MASH,M_SYSPATH,M_COPYPATH,M_TEMPPATH,M_WORKPATH
/*
Function Test(m1)
  LOCAL x:=IF(m1==NIL,"09",m1)
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

  InitParPrn()
  View09(x)
RETURN .T.
*/
Function View09(num)
  LOCAL a_str:={},m_file,n_pos1:=0,n_pos2:=0,m_len_file,i,a_dop:={}
  LOCAL m_var:=m_mash+num+".txt",GetList:={},m_key,n_col:=1,j
  LOCAL a_str1:={},m_poisk1:=SPACE(60),l1,m_screen,m_month:=0,m_month1:=0,k
  LOCAL m_max_width
   DCL MENU
   ADD MENU NAME "Строки" ITEMS ;
{"Униз на одну строку  "+CHR(25) ,;
"Вверх на одну строку  "+CHR(24),;
"Униз на сторiнку  Page Down" ,;
"Вверх на сторiнку Page Up" ,;
"На початок     Ctrl+Page Up" ,;
"На кiнець    Ctrl+Page Down" ,;
} KEY {K_DOWN,K_UP,K_PGDN,K_PGUP,K_CTRL_PGUP,K_CTRL_PGDN}
   ADD MENU NAME "Стовбцi" ITEMS ;
{"Вправо на один символ               "+CHR(26),;
"Влiво на один символ                "+CHR(27),;
"Вправо до кiнця                     End" ,;
"Влiво  до кiнця                     Home" ,;
"Вправо на 10 символiв               Ctrl+"+CHR(26),;
"Влiво на 10 символiв                Ctrl+"+CHR(27)} KEY;
{K_RIGHT,K_LEFT,K_END,K_HOME,K_CTRL_RIGHT,K_CTRL_LEFT}
ADD MENU NAME "Друк" ITEMS ;
{"Друк              Ctrl+P  ",;
"Друк через спулер  F2      ",;
"Друк у файл        Shift+F2",;
"Настройка друку    F9    ",;
"Настройка принтера Ctrl+U"} KEY {K_CTRL_P,K_F2,K_SH_F2,K_F9,K_CTRL_U}
  IF .NOT.FILE(m_var)
    DispError("Файл "+m_var+" вiдсутнiй")
    RETURN .F.
  endif
  s_num:=num
  CLEAR
  @FIRST_ROW-1,FIRST_COL-1,LAST_ROW+1,LAST_COL+1 BOX B_DOUBLE+" " color "W/b"
  m_len_file:=FILESIZE(m_var)
  m_file:=FOPEN(m_var)
  T001(m_file,m_len_file,@m_month,@m_month1)
  m_max_width:=GetMaxWidth(m_file,m_len_file)
  @LAST_ROW+2,0 SayDisp PADC("F8 - Меню",80) COLOR "n/w"
  @FIRST_ROW-1,FIRST_COL+10 SayDisp "Машинограма N "+num+;
  " за "+UPPER(NTOCMONTH(VAL(m_month1)))+" - "+UPPER(NTOCMONTH(VAL(m_month)))+" мiсяць" COLOR "W/B"
  InitScr(m_file,@a_str)
  FOR i:=1 TO LEN(a_str)
    AADD(a_str1,{0,"",0})
  NEXT
  INIT MENU
  DO WHILE .t.
  DISPBEGIN()
  i:=1;AEVAL(a_str,;
  {|x|SetPos(FIRST_ROW+i-1,FIRST_COL),;
   DispText(PADR(SUBSTR(x[2],n_col,LAST_COL-FIRST_COL+1),LAST_COL-FIRST_COL+1),"w/b,w+/b,gr+/b,w/r"),i++})
  DISPEND()
    keyboard ""
    m_key:=INKEY(0)
    Deal Menu
    DO CASE
      CASE m_key==K_F10
        Calcul()
      CASE m_key==K_ALT_F10
        Calc()
      CASE m_key == K_CTRL_U
              LSetprint()
      CASE m_key == K_F9
              SetLpechat()
      CASE m_key==K_ESC
        EXIT
      CASE m_key==K_LEFT.AND.n_col<m_max_width
        n_col++
      CASE m_key==K_CTRL_LEFT.AND.n_col<m_max_width
        n_col:=MIN(m_max_width,n_col+10)
      CASE m_key==K_RIGHT.AND.n_col>1
        n_col--
      CASE m_key==K_CTRL_RIGHT.AND.n_col>1
        n_col:=MAX(1,n_col-10)
      CASE m_key==K_PGDN
        MovePgDown(@a_str,m_len_file,m_file,a_str[n_len_screen,1]+a_str[n_len_screen,3])
      CASE m_key==K_CTRL_PGDN
        MoveBottom(@a_str,m_len_file,m_file)
     CASE m_key==K_DOWN
        MoveDown(@a_str,m_len_file,m_file)
      CASE m_key==K_UP
        MoveUp(@a_str,m_len_file,m_file)
      CASE m_key==K_PGUP
         MovePgUp(@a_str,m_len_file,m_file)
      CASE m_key==K_CTRL_PGUP
         MovePgDown(@a_str,m_len_file,m_file,0)
      CASE m_key==K_F6.OR.m_key==K_F7
        m_screen  := SAVESCREEN(10,5,14,77)
        SET ESCAPE ON
        @10,5,14,77 BOX B_DOUBLE+" " COLOR "n/bg"
        @11,8 SayDisp PADC( 'Введiть значення строки пошуку',66 ) COLOR  "b/bg"
        @12,8 GET m_poisk1 COLOR  "GR+/N,GR+/n" PICTURE "@K"
        m_poisk1:=PADR(m_poisk1,60)
        SET ESCAPE ON
        READ
        m_poisk1:=ALLTRIM(m_poisk1)
        IF m_key==K_F7
          IF VAL(num)<>11
            m_poisk1:="N ~2"+m_poisk1
          ELSE
            m_poisk1:=m_poisk1+"   "
          ENDIF
        ENDIF
        l1:=.f.
        n_pos2:=a_str[n_len_screen,1]+a_str[n_len_screen,3]
        DO WHILE n_pos2<m_len_file
            a_dop:=Readln1(m_file,n_pos2)
            j:=AT(m_poisk1,a_dop[2])
            n_pos2:=a_dop[1]+a_dop[3]
            IF j<>0
              l1:=.t.
              EXIT
            ENDIF
        ENDDO
        IF .NOT.l1
          DispError("Строка ("+m_poisk1+") не знайдена")
        ELSE
         MovePgDown(@a_str,m_len_file,m_file,a_dop[1])
         a_str[1][2]:=LEFT(a_str[1][2],j-1)+"~3"+SUBSTR(a_str[1][2],j,LEN(m_poisk1))+"~1"+SUBSTR(a_str[1][2],j+LEN(m_poisk1))
        ENDIF
      CASE m_key==K_F2
        l_trn:=.f.
        IF s_num=="11"
          PrLbl11(m_file,m_len_file,m_max_width)
        ELSE
          PrLbl09(m_file,m_len_file,m_max_width)
        ENDIF
        l_trn:=.t.
    ENDCASE
  ENDDO
  FCLOSE(m_file)

RETURN .T.
STATIC Function InitScr(m_file,a_str)
LOCAL i,n_pos:=0
FOR i:=1 TO n_len_screen
  AADD(a_str,Readln1(m_file,n_pos))
  n_pos+=a_str[i][3]
NEXT
RETURN .T.

STATIC Function Readln1(m_file,n_pos)
LOCAL m_buf:=SPACE(BUF_SIZE),n
LOCAL a_ret:={0,"",0},i
FSEEK(m_file,n_pos)
n:=FREAD(m_file,@m_buf,BUF_SIZE)
m_buf:=LEFT(m_buf,n)
i:=ATNUM(END_LINE,m_buf,1)
a_ret[1]:=n_pos
IF i==0
  a_ret[2]:=m_buf
  a_ret[3]:=LEN(a_ret[2])
ELSE
  a_ret[2]:=LEFT(m_buf,i-1)
  a_ret[3]:=LEN(a_ret[2])+2
ENDIF
a_ret[2]:=TranSl(a_ret[2])
RETURN a_ret

STATIC Function Readln2(m_file,n_pos)
LOCAL m_buf:=SPACE(BUF_SIZE),n
LOCAL a_ret:={0,"",0},i,j,k
IF n_pos>BUF_SIZE
  FSEEK(m_file,n_pos-BUF_SIZE+1)
  k:=BUF_SIZE
ELSE
  FSEEK(m_file,0)
  k:=n_pos+1
ENDIF
n:=FREAD(m_file,@m_buf,k)
m_buf:=LEFT(m_buf,n-2)
i:=ATNUM(END_LINE,m_buf)
IF i==0
  a_ret[2]:=m_buf
  a_ret[3]:=LEN(a_ret[2])+2
ELSE
  a_ret[2]:=SUBSTR(m_buf,i+2)
  a_ret[3]:=LEN(a_ret[2])+2
ENDIF
a_ret[1]:=n_pos - a_ret[3]+1
a_ret[2]:=TranSl(a_ret[2])
RETURN a_ret

STATIC Function MoveDown(a_str,m_len_file,m_file)
LOCAL i,n_pos2,a_dop
  n_pos2:=a_str[n_len_screen,1]+a_str[n_len_screen,3]
  IF n_pos2<m_len_file
    FOR i:=1 TO n_len_screen - 1
      a_str[i][1]:=a_str[i+1][1]
      a_str[i][2]:=a_str[i+1][2]
      a_str[i][3]:=a_str[i+1][3]
    NEXT
    a_dop:=Readln1(m_file,n_pos2)
    a_str[n_len_screen][1]:=a_dop[1]
    a_str[n_len_screen][2]:=a_dop[2]
    a_str[n_len_screen][3]:=a_dop[3]
    RETURN .t.
  ENDIF
RETURN .f.

STATIC Function MoveUp(a_str,m_len_file,m_file)
LOCAL i,n_pos1,a_dop
  n_pos1:=a_str[1,1]-1
  IF n_pos1>0
    FOR i:=n_len_screen TO 2 STEP -1
      a_str[i][1]:=a_str[i-1][1]
      a_str[i][2]:=a_str[i-1][2]
      a_str[i][3]:=a_str[i-1][3]
    NEXT
    a_dop:=Readln2(m_file,n_pos1)
    a_str[1][1]:=a_dop[1]
    a_str[1][2]:=a_dop[2]
    a_str[1][3]:=a_dop[3]
    RETURN .T.
  ENDIF
RETURN .F.

STATIC Function Transl(m_str)
LOCAL i
IF l_trn
  i:=AT("N ",m_str)
  IF i<>0.AND.s_num=="10"
    m_str:=LEFT(m_str,i+1)+"~2"+SUBSTR(m_str,i+2,4)+"~1"+SUBSTR(m_str,i+6)
  ENDIF
  IF i<>0.AND.s_num=="09"
    m_str:=LEFT(m_str,i+1)+"~2"+SUBSTR(m_str,i+2)
  ENDIF
  IF LEFT(m_str,1)="$"
    m_str:=STUFF(m_str,1,1,"~4"+END_PAGE)
  ENDIF
ENDIF
RETURN m_str
STATIC Function MovePgDown(a_str,m_len_file,m_file,m_pos)
LOCAL i,n_pos2:=m_pos,a_dop,j
//  n_pos2:=a_str[n_len_screen,1]+a_str[n_len_screen,3]
  i:=1
  DO WHILE .t.
    a_dop:=Readln1(m_file,n_pos2)
    a_str[i][1]:=a_dop[1]
    a_str[i][2]:=a_dop[2]
    a_str[i][3]:=a_dop[3]
    n_pos2:=a_str[i,1]+a_str[i,3]
    i++
    IF i>n_len_screen.OR.n_pos2>=m_len_file
      EXIT
    ENDIF
  ENDDO
    FOR j:=i TO n_len_screen
      a_str[j][1]:=n_pos2
      a_str[j][2]:=""
      a_str[j][3]:=0
    NEXT
RETURN .T.
STATIC Function MovePgUp(a_str,m_len_file,m_file)
LOCAL i,n_pos1,a_dop,j,a_str2:={}
  n_pos1:=a_str[1,1]-1
  IF n_pos1>0
  i:=n_len_screen
  DO WHILE n_pos1>0
    a_dop:=Readln2(m_file,n_pos1)
    a_str[i][1]:=a_dop[1]
    n_pos1:=a_dop[1]-1
    a_str[i][2]:=a_dop[2]
    a_str[i][3]:=a_dop[3]
    i--
    IF i==0
      EXIT
    ENDIF
  ENDDO
  IF i<>0
    FOR j:=i+1 TO n_len_screen
      AADD(a_str2,{a_str[j][1],a_str[j][2],a_str[j][3]})
    NEXT
    FOR j:=i TO 1 STEP -1
      a_str[n_len_screen-i+j][1]:=a_str[j][1]
      a_str[n_len_screen-i+j][2]:=a_str[j][2]
      a_str[n_len_screen-i+j][3]:=a_str[j][3]
    NEXT
    FOR j:=1 TO LEN(a_str2)
      a_str[j][1]:=a_str2[j][1]
      a_str[j][2]:=a_str2[j][2]
      a_str[j][3]:=a_str2[j][3]
    NEXT
  ENDIF
  ENDIF
RETURN .T.
STATIC Function MoveBottom(a_str,m_len_file,m_file)
LOCAL i,n_pos1,a_dop,j,a_str2:={}
  n_pos1:=m_len_file-1
  IF n_pos1>0
  i:=n_len_screen
  DO WHILE n_pos1>0
    a_dop:=Readln2(m_file,n_pos1)
    a_str[i][1]:=a_dop[1]
    n_pos1:=a_dop[1]-1
    a_str[i][2]:=a_dop[2]
    a_str[i][3]:=a_dop[3]
    i--
    IF i==0
      EXIT
    ENDIF
  ENDDO
  IF i<>0
    FOR j:=i+1 TO n_len_screen
      AADD(a_str2,{a_str[j][1],a_str[j][2],a_str[j][3]})
    NEXT
    FOR j:=i TO 1 STEP -1
      a_str[n_len_screen-i+j][1]:=m_len_file
      a_str[n_len_screen-i+j][2]:=""
      a_str[n_len_screen-i+j][3]:=0
    NEXT
    FOR j:=1 TO LEN(a_str2)
      a_str[j][1]:=a_str2[j][1]
      a_str[j][2]:=a_str2[j][2]
      a_str[j][3]:=a_str2[j][3]
    NEXT
  ENDIF
  ENDIF
RETURN .T.

STATIC Function PrLbl09(m_file,m_len_file,m_width)
LOCAL i:=0,j,a_dop:={},n_pos2:=0,n_row:=1,n_col:=0
LOCAL m_kvo:=3,m_interval:=5,m_endpage:=70,m_page:=1
LOCAL s_str:="------------",n_row_max:=0,m_tabn1:="****",m_tabn2:="****"
LOCAL a_screen:={},m_gauge,m_file2,s_sub
LOCAL m_width1,l1:=.t.,l2:=.t.,l_page:=.f.
LOCAL l_esc:=.f.,m_skippage:=IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L))

m_file2:=TEMPFILE(m_temppath,"prn");FERASE(m_file2)
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
DO CASE
  CASE s_num=="09"
     s_sub:="M9"
  CASE s_num=="10"
     s_sub:="MA"
ENDCASE
m_interval:=RESTVAR1("m_interval",s_sub)
m_kvo:=RESTVAR1("m_kvo",s_sub)
s_str:=RESTVAR1("s_str",s_sub)
CLOSE myvar
    // m_file2:=FCREATE("TEST.LST")
IF .NOT.t002(@m_tabn1,@m_tabn2)
  RETURN .F.
ENDIF
IF .NOT.t003(@m_kvo,m_width,m_interval)
  RETURN .F.
ENDIF

    m_width1:=m_width*m_kvo + (m_kvo - 1) * m_interval
    m_endpage:=GetEndPage()
IF OpenPrn(m_file2).AND.SetWidthPrn(m_width1)
    a_dop:={}
    ASIZE(a_screen,m_endpage)
    n_pos2:=0
    m_gauge:=InitGauge("Вивiд у файл")
    DO WHILE  n_pos2<m_len_file.AND.l2.AND..NOT.l_esc
      FOR i:=1 TO LEN(a_screen)
        a_screen[i]:=""
      NEXT
      // Формування сторiнки
      n_row:=1;n_col:=1
        FOR i:=1 TO LEN(a_dop)
          a_screen[n_row]:=a_screen[n_row]+PADR(a_dop[i],m_width)
          n_row++
        NEXT
//      n_row_max:=0
      n_row_max:=LEN(a_dop)
      DO WHILE n_pos2<m_len_file.AND.l2.AND..NOT.l_esc
        IF INKEY()==K_ESC
          l_esc:=.t.
          EXIT
        ENDIF
       IF l_page
         l_page:=.f.
         a_dop:={}
         EXIT
       ENDIF
        a_dop:=GetLbl(m_file,m_len_file,@n_pos2,s_str,@l_page)
        IF m_tabn1<>"****".AND.l1
         j:=ASCAN(a_dop,{|x|(AT("N "+m_tabn1,x)<>0)})
         IF j==0
            LOOP
          ELSE
            l1:=.f.
          ENDIF
        ENDIF
         IF m_tabn2<>"****".AND.l2
             j:=ASCAN(a_dop,{|x|(AT("N "+m_tabn2,x)<>0)})
             IF j<>0
                l2:=.f.
              ENDIF
          ENDIF
        IF n_row+LEN(a_dop)>=m_endpage
          FOR j:=n_row TO LEN(a_screen)
            a_screen[j]:=a_screen[j]+SPACE(m_width)
          NEXT
          IF n_row+LEN(a_dop)>=m_endpage.AND.n_col>=m_kvo
            EXIT
          ENDIF
          FOR i:=1 TO LEN(a_screen)
            a_screen[i]+=SPACE(m_interval)
          NEXT
          n_row:=1;n_col++
        ENDIF
        FOR i:=1 TO LEN(a_dop)
          a_screen[n_row]:=a_screen[n_row]+PADR(a_dop[i],m_width)
          n_row++
        NEXT
        IF n_row_max<(n_row-1)
          n_row_max:=n_row-1
        ENDIF
      ENDDO
      // Вивiд сторiнки
      IF n_row_max>0
        FOR i:=1 TO n_row_max
          DevOut(a_screen[i]+END_LINE)
        NEXT
        DevOut(m_skippage)
      ENDIF
      m_page++
      m_gauge:=DispGauge(m_gauge,n_pos2/m_len_file)
    ENDDO
    // Вивiд останньої сторiнки
    IF LEN(a_dop)>0
      FOR i:=1 TO LEN(a_dop)
        DevOut(a_dop[i]+END_LINE)
      NEXT
      DevOut(m_skippage)
     ENDIF
      DelGauge(m_gauge)
      ClosePrn()
      IF .NOT.l_esc
        MyPrintFile(m_file2)
      ENDIF
else
  ClosePrn()
ENDIF
RETURN .t.

STATIC Function GetLbl(m_file,m_len_file,n_pos2,s_str,l_page)
LOCAL a_dop:={},a_dop1:={}
DO WHILE .T.
  a_dop1:=Readln1(m_file,n_pos2)
  n_pos2+=a_dop1[3]
  IF LEFT(a_dop1[2],1)=="$"
    l_page:=.t.
    EXIT
  ENDIF
  IF RIGHT(a_dop1[2],2)<>"ZZ"
    AADD(a_dop,RTRIM(a_dop1[2]))
  ENDIF
  IF LEFT(a_dop1[2],LEN(s_str))==s_str
    EXIT
  ENDIF
  IF n_pos2>=m_len_file
    EXIT
  ENDIF
ENDDO
RETURN a_dop

STATIC Function t001(m_file,m_len_file,m_month,m_month1)
LOCAL m_str:=SPACE(100),n
FSEEK(m_file,m_len_file-60)
n:=FREAD(m_file,@m_str,100)
  IF SUBSTR(m_str,n-1,2)=="ZZ"
    IF m_month<>NIL
      m_month:=SUBSTR(m_str,n-23,2)
      m_month1:=SUBSTR(m_str,n-21,2)
    ENDIF
    RETURN .T.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh") NEW
  m_month:=msh->p007
  m_month1:="01"
  CLOSE msh
RETURN .t.
STATIC Function GetMaxWidth(m_file,m_len_file)
LOCAL i:=1,m_width:=0,n_pos2:=0,a_dop:={}
// определение максимальной длины файла
    DO WHILE i<=80
      a_dop:=Readln1(m_file,n_pos2)
      IF m_width<LEN(ALLTRIM(a_dop[2]))
        m_width:=LEN(ALLTRIM(a_dop[2]))
      ENDIF
      n_pos2+=a_dop[3]
      i++
      IF n_pos2>=m_len_file
        EXIT
      ENDIF
    ENDDO
RETURN m_width
STATIC Function t002(m_tabn1,m_tabn2)
LOCAL m_screen2,GetList:={},s_file:={}
  SopenFiles("SP10",@s_file)
  m_screen2:=SaveScreen(10,10,15,70)
  SET ESCAPE ON
  SET CURSOR ON
  @10,10,15,70 BOX B_DOUBLE+" " COLOR "GR+/BG"
  m_tabn1:=m_tabn2:="    "
  @11,12 SayDisp "Введiть табельний номер з якого почати   " COLOR "w+/bg"
  @12,30 Get m_tabn1 COLOR "b/bg,GR+/n" VALID sp10->(sp_vl("SP10A","2"))
  @13,12 SayDisp "          i на якому завершити  "  COLOR "w+/bg"
  @14,30 Get m_tabn2 COLOR "b/bg,GR+/n" VALID sp10->(sp_vl("SP10A","2"))
  READ
  IF EMPTY(m_tabn1);m_tabn1:="****";ENDIF
  IF EMPTY(m_tabn2);m_tabn2:="****";ENDIF
  RestScreen(10,10,15,70,m_screen2)
  IF LASTKEY()==K_ESC
    RETURN .F.
  ENDIF
return .T.
Function T003(s_kol_ras,w,m_interval)
LOCAL m_screen1,GetList:={}
      m_screen1:=Savescreen(12,10,18,60)
      @12,10,18,60 BOX (CHR(201)+CHR(205)+CHR(187)+CHR(186)+CHR(188)+CHR(205)+CHR(200)+CHR(186))+" " COLOR "w+/bg"
      @13,15 Say "Максимальна кiлькiсть листкiв  >" COLOR "w+/bg"
      @13,47 Say INT( (272+m_interval)/(w+m_interval) ) COLOR "GR+/bg"
      @14,15 SAY "Поточна кiлькiсть листкiв >" COLOR "w+/bg"
      @14,41 GET s_kol_ras  PICTURE "99" VALID s_kol_ras >=1.AND.s_kol_ras <=INT( 272/w ) COLOR "GR+/BG,GR+/N"
      READ
      RestScreen(12,10,18,60,m_screen1)
      IF LASTKEY()==K_ESC
        RETURN .F.
      ENDIF
      SET ESCAPE OFF
      SET CURSOR OFF
RETURN .t.
STATIC Function PrLbl11(m_file,m_len_file,m_width)
LOCAL i:=0,j,a_dop:={},n_pos2:=0,n_row:=1,n_col:=0
LOCAL m_kvo:=3,m_interval:=5,m_endpage:=70,m_page:=1
LOCAL s_str:="------------",n_row_max:=0,m_tabn1:="****",m_tabn2:="****"
LOCAL a_screen:={},m_gauge,m_file2,s_sub
LOCAL m_width1,l1:=.t.,l2:=.t.,l_page:=.f.
LOCAL l_esc:=.f.,m_skippage:=IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L))

m_file2:=TEMPFILE(m_temppath,"prn");FERASE(m_file2)
m_endpage:=GetEndPage()
IF OpenPrn(m_file2).AND.SetWidthPrn(m_width)
    n_pos2:=0
    m_gauge:=InitGauge("Вивiд у файл")
    DO WHILE  n_pos2<m_len_file.AND.l2.AND..NOT.l_esc
      IF INKEY()==K_ESC
        l_esc:=.t.
        EXIT
      ENDIF
      a_dop:=Readln1(m_file,n_pos2)
      n_pos2+=a_dop[3]
      IF LEFT(a_dop[2],1)=="$"
        DevOut(m_skippage)
      ELSE
        IF RIGHT(a_dop[2],2)<>"ZZ"
          DevOut(a_dop[2]+END_LINE)
        ENDIF
      ENDIF
      m_gauge:=DispGauge(m_gauge,n_pos2/m_len_file)
     ENDDO
      ClosePrn()
      DelGauge(m_gauge)
      IF .NOT.l_esc
        MyPrintFile(m_file2)
      ENDIF
else
  ClosePrn()
ENDIF
RETURN .t.
