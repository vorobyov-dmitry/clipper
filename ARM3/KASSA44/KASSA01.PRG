#include "new.ch"
#DEFINE M_WAIT     30 &&   Время ожидания нажатия клавиши
#DEFINE M_WAIT_PRINTER 5 &&   Время ожидания готовности принтера
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
#define F_NAME 1
#define AC_ABORT 0
#  DEFINE   HEAD_CLR     "r+/b"                // цвет начальной заставки
#  DEFINE   HELLO1_CLR   "w+/bg,w+/n"          // цвет при вводе даты
#  DEFINE   MNU_CLR      "w+/b,n/w"            // цвет меню
#  DEFINE   VVOD_CLR     "w+/b,gr+/n,,,w+/b"   // цвет экрана ввода-вывода
MEMVAR m_workpath,a_menu,m_sprpath,m_platpath,m_temppath,m_mainpath,m_syspath
STATIC m_page:=0,m_left_margin:=8,m_right_margin:=60
STATIC LAPND:=.f.,m_endpage:=60
STATIC Alias_Browse:=0
STATIC l_error:=.F.
FUNCTION  kass02(m_var)
   LOCAL m_sum:=0,pl_ved,m_sumall:=0,m_time,m_screen,m_proc1,s_files:={},;
   m_col,getlist:={},a_col:={{||fks01->tabn},;
   {||sp10->(dbseek(fks01->tabn)),;
   IF(sp10->(FOUND()),LEFT(ALLTRIM(sp10->fam)  + ' ' + ALLTRIM(sp10->imja);
   + ' ' + ALLTRIM(sp10->otch)+SPACE(40),40),SPACE(40))},;
   {||fks01->sum},;
   {||IF(fks01->tk,"   ","НЕТ")};
   },;
   a_name:={"ТАБ. НОМЕР",;
   "      ФАМИЛИЯ    ИМЯ   ОТЧЕСТВО       ","  СУММА ","ПОДПИСЬ"},;
   buf:="    ",m_recno,l_printer,m_sum01,m_name:="Платежная ведомость N ",;
   m_buf:=0,a_dir:=DIRECTORY(m_workpath+"fksp???.dbf"),a_choice:={},l_end:=.f.,;
   m_str:="     ТАБ.НОМЕР   ФАМИЛИЯ ИМЯ ОТЧЕСТВО                        СУММА ",;
   i:=0
   // ВЫБОР ПЛАТЕЖНОЙ ВЕДОМОСТИ
   a_dir:=ASORT(a_dir,,,{|x,y|x[1]<y[1]})
   AEVAL(a_dir,{|x| AADD(a_choice,m_name+ SUBSTR(x[F_NAME],5,2))})
   @ M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( VVOD_CLR )
   SHADOW(M_ROWFIRST, M_COLFIRST, M_ROWLAST, M_COLLAST)
   SET COLOR TO  ( HEAD_CLR )
   @ M_ROWFIRST,M_COLFIRST+2 SayDisp LEFT(' '+ALLTRIM("Выбор ведомости")+' ',M_WIDTH -5)
   SET COLOR TO ( MNU_CLR )
   m_col :=ACHOICE (M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST-1,M_COLLAST-2, A_CHOICE,,,,)
   IF m_col==AC_ABORT
      RETURN .T.
   ELSE
      DBUSEAREA(.T.,,m_workpath+a_dir[m_col,F_NAME],'fks01')
   ENDIF
   CLEAR
   pl_ved:=TBrowseDB(2,1,MAXROW()-7,MAXCOL()-1)
   KEYBOARD ""
   USE (m_workpath+"fks02") INDEX (m_workpath+"fks02") NEW
   fks02->(DBSEEK(UPPER(LEFT(a_dir[m_col,F_NAME],AT(".",a_dir[m_col,F_NAME])-1))))
   SopenFiles("SP10",@s_files)
   fks01->(DBEVAL({||m_sumall+=fks01->sum,IF(fks01->tk,m_sum+=fks01->sum,0)}))
   fks01->(DBGOTO(1))
   DISPBEGIN()
   DISPBOX( 1, 0, MAXROW()-6, MAXCOL(), B_DOUBLE + " " )
//   @0,0 SayDisp p_npr
   @0,25 SayDisp  m_name +SUBSTR(a_dir[m_col,F_NAME],5,2)+ " ЗА "+;
   NtoCMonth(VAL(fks02->month))+" МЕСЯЦ"
   m_str:= m_name+SUBSTR(a_dir[m_col,F_NAME],5,3)+ " ЗА "+;
   NtoCMonth(VAL(fks02->month))+" МЕСЯЦ"+CHR(K_ENTER)+CHR(10)+m_str
   @MAXROW()-5,0 SayDisp "Неполучено зар.платы"
   @MAXROW()-3,0 SayDisp "Сумма получ. зар.платы"
   @MAXROW()-1,0 SayDisp "Общ. сумма по ведомости"
   @MAXROW()-5, 24 SayDisp m_sumall-m_sum PICTURE "999'999'999.99" COLOR "W/B"
   CLEAREOL(MAXROW()-4,0,'B/B')
   @MAXROW()-4, 0 SayDisp NumToStr(m_sumall-m_sum)  COLOR "W/B"
   @MAXROW()-3, 24 SayDisp m_sum PICTURE "999'999'999.99" COLOR "W/B"
   CLEAREOL(MAXROW()-2,0,'B/B')
   @MAXROW()-2, 0 SayDisp NumToStr(m_sum)  COLOR "W/B"
   @MAXROW()-1, 24 SayDisp m_sumall PICTURE "999'999'999.99" COLOR "W/b"
   CLEAREOL(MAXROW(),0,'B/B')
   @MAXROW(), 0 SayDisp NumToStr(m_sumall)  COLOR "W/B"
   DISPEND()
   FOR i:=1 TO LEN(a_col)
      m_Col           := TBColumnNew()
      m_Col:colorblock:=  {|| IF(fks01->tk,{3,3},{5,5})}
      m_Col:headsep    := "─"
      m_Col:colsep     := "│"
      m_Col:footsep    := "─"
      m_col:heading    := a_name[i]
      m_col:block      :=a_col[i]
      pl_ved:addColumn( m_col )
   NEXT
   pl_ved:colorspec     := 'N/W,R/N,B/W,G/Y,N/R'
   pl_ved:colsep        := '│'
   pl_ved:cargo         :=""
   pl_ved:SkipBlock     := { |n| SkipKassa(n) }
   pl_ved:goBottomBlock := { || fks01->( DBGOBOTTOM() ) }
   pl_ved:goTopBlock    := { || fks01->( DBGOTOP() ) }
   SELECT fks01
   do while .not.pl_ved:stabilize()
   enddo
   DO WHILE .T.
      KEYBOARD ""
      i:=0
      DO WHILE .NOT.(pl_ved:stabilize()).AND.((i:=inkey())==0)
      ENDDO
      pl_ved:colorRect({pl_ved:rowPos,1,pl_ved:rowPos,pl_ved:ColCount},IF(fks01->tk,{4,4},{2,2}))
      IF i==0
         m_time:=seconds()
         DO WHILE (i:=inkey())==0.AND.SECONDS()-m_time<M_WAIT
         ENDDO
         IF i==0
            m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL())
            COLORWIN(0,0,MAXROW(),MAXCOL(),'8/0')
            i:=INKEY(0)
            RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
         ENDIF
      ENDIF
      DO CASE
         CASE i == K_ENTER.OR.i == ASC(' ')
            IF fks01->tk
               m_sum-=fks01->sum
               fks01->tk:=.F.
            ELSE
               m_sum+=fks01->sum
               fks01->tk:=.T.
            ENDIF
            pl_ved:refreshCurrent()
            @MAXROW()-5, 24 SayDisp m_sumall-m_sum PICTURE "999'999'999.99" COLOR "W/B"
            CLEAREOL(MAXROW()-4,0,'B/B')
            @MAXROW()-4, 0 SayDisp NumToStr(m_sumall-m_sum)  COLOR "W/B"
            @MAXROW()-3, 24 SayDisp m_sum PICTURE "999'999'999.99" COLOR "W/B"
            CLEAREOL(MAXROW()-2,0,'B/B')
            @MAXROW()-2, 0 SayDisp NumToStr(m_sum)  COLOR "W/B"
            @MAXROW()-1, 24 SayDisp m_sumall PICTURE "999'999'999.99" COLOR "W/b"
            CLEAREOL(MAXROW(),0,'B/B')
            @MAXROW(), 0 SayDisp NumToStr(m_sumall)  COLOR "W/B"
        CASE i == K_CTRL_RET
            IF ALERT("Отмечать все суммы как неполученные?",{"ДА","НЕТ"},"bg/w,w+/n")==1
              i:=fks01->(RECNO())
              fks01->(DBGOTOP())
              m_sum:=0
              fks01->(DBEVAL({||fks01->tk:=.f.}))
              fks01->(DBGOTO(i))
              pl_ved:refreshAll()
            ENDIF
            @MAXROW()-5, 24 SayDisp m_sumall-m_sum PICTURE "999'999'999.99" COLOR "W/B"
            CLEAREOL(MAXROW()-4,0,'B/B')
            @MAXROW()-4, 0 SayDisp NumToStr(m_sumall-m_sum)  COLOR "W/B"
            @MAXROW()-3, 24 SayDisp m_sum PICTURE "999'999'999.99" COLOR "W/B"
            CLEAREOL(MAXROW()-2,0,'B/B')
            @MAXROW()-2, 0 SayDisp NumToStr(m_sum)  COLOR "W/B"
            @MAXROW()-1, 24 SayDisp m_sumall PICTURE "999'999'999.99" COLOR "W/b"
            CLEAREOL(MAXROW(),0,'B/B')
            @MAXROW(), 0 SayDisp NumToStr(m_sumall)  COLOR "W/B"
        CASE i == K_CTRL_BS
            IF ALERT("Отмечать все суммы как полученные?",{"ДА","НЕТ"},"bg/w,w+/n")==1
              i:=fks01->(RECNO())
              fks01->(DBGOTOP())
              m_sum:=0
              fks01->(DBEVAL({||fks01->tk:=.t.,m_sum+=fks01->sum}))
              fks01->(DBGOTO(i))
              pl_ved:refreshAll()
            ENDIF
            @MAXROW()-5, 24 SayDisp m_sumall-m_sum PICTURE "999'999'999.99" COLOR "W/B"
            CLEAREOL(MAXROW()-4,0,'B/B')
            @MAXROW()-4, 0 SayDisp NumToStr(m_sumall-m_sum)  COLOR "W/B"
            @MAXROW()-3, 24 SayDisp m_sum PICTURE "999'999'999.99" COLOR "W/B"
            CLEAREOL(MAXROW()-2,0,'B/B')
            @MAXROW()-2, 0 SayDisp NumToStr(m_sum)  COLOR "W/B"
            @MAXROW()-1, 24 SayDisp m_sumall PICTURE "999'999'999.99" COLOR "W/b"
            CLEAREOL(MAXROW(),0,'B/B')
            @MAXROW(), 0 SayDisp NumToStr(m_sumall)  COLOR "W/B"
         CASE i == K_DOWN     ; pl_ved:down()
         CASE i == K_UP       ; pl_ved:up()
         CASE i == K_PGDN     ; pl_ved:pagedown()
         CASE i == K_PGUP     ; pl_ved:pageup()
         CASE i == K_CTRL_PGUP; pl_ved:gotop()
         CASE i == K_CTRL_PGDN; pl_ved:gobottom()
         CASE i == K_F10      ; Calc()
         CASE i == K_ESC .AND. ANSWER("   Завершить работу ?   " )==YES
               EXIT
         CASE i == K_F6                                               /* поиск */
                  // Вывод запроса и поля ввода
                  m_buf  := SAVESCREEN( 10, 5, 14, 77 )
                  i := SETCOLOR( HELLO1_CLR )
                  m_col:=pl_ved:GetColumn(pl_ved:colpos)
                  Dispbox(10, 5, 13, 75,"w+/bg",B_SINGLE+" ")
                  SHADOW(10, 5, 13, 75)
                  @11,6 SayDisp PADC( 'Введите значение "'+;
                     STRTRAN( ALLTRIM( m_col:heading ), ";", " " ) +;
                                          '" для поиска :', 68 )
                  @ 12, ( 40 - INT( pl_ved:colwidth(pl_ved:colpos)/2 ) ) GET buf PICTURE "9999"
//                  SETCURSOR( SC_NORMAL )
                  READ
                  SETCOLOR( i )
//                  SETCURSOR( SC_NONE )
                  RESTSCREEN( 10, 5, 14, 77, m_buf )

                  IF ( LASTKEY() != K_ESC )

                        i := fks01->( RECNO() )
                        fks01->(DBEVAL( { || NIL },,;
                              { || fks01->tabn<>buf} ))
                        // Если не найдено
                        IF fks01->(EOF())
                           fks01->( DBGOTO(i) )
                           DispError(" Запись с таким значением поля не найдена ")
                        ENDIF
                        // Если найдено
                        DO WHILE !( pl_ved:stabilize() ) ; END
                        pl_ved:RefreshAll()

                  ENDIF

         CASE i == K_CTRL_P.OR. i == K_F2
            m_recno:=fks01->(RECNO())
            IF OpenPrn()
//            setprinter(96)
            IF SetWidthPrinter(96)
            m_endpage:=GetEndPage()
            fks01->(DBGOTOP())
            m_sum01:=0
            m_page:=0
            m_proc1 := InitGauge(" Вывод на печать ",2)
            l_end:=.F.
            DO WHILE .NOT.fks01->(EOF())
               DispGauge(m_proc1,fks01->(RECNO())/fks01->(LASTREC()))
               IF INKEY() == K_ESC
                  IF ANSWER("ПРЕРВАТЬ печать , Вы уверены ?")==YES
                     l_end:=.T.
                     EXIT
                  ENDIF
               ENDIF
               IF .NOT.fks01->tk
                  m_time:=SECONDS()
                  l_printer:=.T.
                  DO   WHILE   ( ! ISPRINTER())
                     IF SECONDS()-m_time>M_WAIT_PRINTER.AND.l_printer
                        m_screen:=DispMessage("ПРИНТЕР НЕ ГОТОВ;К ПЕЧАТИ")
                        l_printer:=.F.
                     ENDIF
                     IF INKEY() == K_ESC
                        IF  ANSWER("ПРЕРВАТЬ печать ,; Вы уверены ?")==YES
                           l_end:=.T.
                           EXIT
                        ENDIF
                     ENDIF
                  ENDDO
                  IF .NOT.l_printer
                     DelMessage(m_screen)
                  ENDIF
                  IF l_end
                     EXIT
                  ENDIF
                  d_skip_line(m_str)
                  @PROW(),8 SAY fks01->tabn
                  sp10->(dbseek(fks01->tabn))
                  IF sp10->(FOUND())
                     @PROW(),14 SAY LEFT(ALLTRIM(sp10->fam)  + ' ' + ALLTRIM(sp10->imja);
                     + ' ' + ALLTRIM(sp10->otch),40)
                  ENDIF
                  @PROW(),56 SAY fks01->sum
                  m_sum01+=fks01->sum
               ENDIF
               fks01->(DBSKIP(1))
            ENDDO
            IF .NOT.l_end
               d_skip_line(m_str)
               @PROW(),0 Say "Неполучено зар.платы"
               @PROW(), 24 Say m_sum01 PICTURE "999'999'999.99"
               d_skip_line(m_str)
               @PROW(), 0  Say NumToStr(m_sum01)
               d_skip_line(m_str)
               @PROW(),0   Say "Сумма получ. зар.платы"
               @PROW(), 24 Say m_sum PICTURE "999'999'999.99"
               d_skip_line(m_str)
               @PROW(), 0  Say NumToStr(m_sum)
               d_skip_line(m_str)
               @PROW(),0   Say "Общ. сумма по ведомости"
               @PROW(), 24 Say m_sumall PICTURE "999'999'999.99"
               d_skip_line(m_str)
               @PROW(), 0  Say NumToStr(m_sumall)
               @PROW()+1,0 Say ""
            ENDIF
            fks01->(DBGOTO(m_recno))
            DelGauge(m_proc1)
            ClosePrn()
            ENDIF
            ENDIF
      ENDCASE
      pl_ved:refreshCurrent()
   ENDDO

SCLOSEFiles(@s_files)
CLOSE fks01
fks02->sum:=m_sum
CLOSE fks02
RETURN (.T.)


FUNCTION  kass03()
   LOCAL m_buf:=0,pl_ved,m_sumall:=0,m_time,m_screen,m_proc1,m_col,getlist:={},;
   a_col:={;
      {  {|x|IF(x==NIL,fks01->tabn,fks01->tabn:=x)},;
         "ТАБ. НОМЕР",{||.T.},;
         {|p|sp10->(sp_vl("SP10A"))},;
         {||.T.}},;
      {{||sp10->(dbseek(fks01->tabn)),IF(sp10->(FOUND()),LEFT(ALLTRIM(sp10->fam)  + ' ' + ALLTRIM(sp10->imja);
         + ' ' + ALLTRIM(sp10->otch)+SPACE(40),40),SPACE(40))},;
         "      ФАМИЛИЯ    ИМЯ   ОТЧЕСТВО       ",;
         {||.F.},{||.T.},{||.T.}},;
      {{|p|IF(p==NIL,fks01->sum,fks01->sum:=p)},"  СУММА ",;
         {||.T.},{||.T.},{||m_sumall:=m_sumall-fks01->sum+m_buf}}},;
   buf:="    ",m_recno,l_printer,m_sum01,m_name:="Авансовая ведомость N ",;
   a_dir:=DIRECTORY(m_workpath+"fksd???.dbf"),;
   a_choice:={},l_end:=.f.,i:=0,l_print:={.t.,.t.,.t.},s_files:={}
   local m_str := '',m_ved:=0,m_month:=MONTH(DATE()),;
      a_struct2:={;
      {"tabn","C",4,0},{"sum","N",16,2},{"tk","L",1,0}}
   // ВЫБОР ПЛАТЕЖНОЙ ВЕДОМОСТИ
   AEVAL(a_dir,{|x| AADD(a_choice,m_name+ SUBSTR(x[F_NAME],5,3))})
   AADD(a_choice,"Ввод новой авансовой ведомости")
   @ M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST+1, M_COLLAST+2 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( VVOD_CLR )
   SHADOW(M_ROWFIRST+1, M_COLFIRST+2, M_ROWLAST+1, M_COLLAST+2)
   SET COLOR TO  ( HEAD_CLR )
   @ M_ROWFIRST+1,M_COLFIRST+2+2 SayDisp LEFT(' '+ALLTRIM("Выбор ведомости")+' ',M_WIDTH -5)
   SET COLOR TO ( MNU_CLR )
   m_col :=ACHOICE (M_ROWFIRST+1+1, M_COLFIRST+2+2, M_ROWLAST-1+1,M_COLLAST-2+2, A_CHOICE,,"My_Key",,)
   IF m_col==AC_ABORT
      RETURN .T.
   ELSE
      IF m_col==LEN(a_choice)
         IF  ANSWER("Вы действительно хотите; создать новую ведомость ?" )==YES
            set escape on
            set cursor on
            m_str :=savescreen(9,19,16,64)
            SET COLOR TO  "N/BG+,N/W"
            DispBox(9,19,14,62,"w+/bg",B_SINGLE+" ")
            SHADOW(9,19,14,62)
            @ 10,20 say 'Введите номер авансовой ведомости '
            @ 12,20 say 'Введите месяц авансовой ведомости '
            @ 11,39 get m_ved picture '999' VALID ASCAN(a_dir,{|x|UPPER(x[F_NAME])=="FKSD"+STRZERO(m_ved,3)+".DBF"})==0
            read
            @ 13,39 get m_month picture '99' VALID m_month<13.AND.m_month>=1
            read
            IF LASTKEY()==K_ESC
               RETURN .T.
            ENDIF
            DBCREATE(m_workpath+"fksd"+STRZERO(m_ved,3),a_struct2)
            USE (m_workpath+"fks02") INDEX (m_workpath+"fks02") NEW
            fks02->(DBAPPEND())
            fks02->month:=STRZERO(m_month,2)
            fks02->name:="FKSD"+STRZERO(m_ved,3)
            set escape off
            set cursor off
            restscreen(9,19,16,64,m_str)
            DBUSEAREA(.T.,,m_workpath+"fksd"+STRZERO(m_ved,3),'fks01')
         ELSE
            RETURN .T.
         ENDIF
      ELSE
         DBUSEAREA(.T.,,m_workpath+a_dir[m_col,F_NAME],'fks01')
         USE (m_workpath+"fks02") INDEX (m_workpath+"fks02") NEW
         fks02->(DBSEEK(UPPER(LEFT(a_dir[m_col,F_NAME],AT(".",a_dir[m_col,F_NAME])-1))))
         m_ved:=VAL(SUBSTR(a_dir[m_col,F_NAME],5,3))
      ENDIF
   ENDIF
   SET COLOR TO ( MNU_CLR )
   CLEAR
   pl_ved:=TBrowseDB(2,1,MAXROW()-3,MAXCOL()-1)
   KEYBOARD ""
   SopenFiles("SP10",@s_files)
    NET use (m_syspath+"DBROWSE")  index (m_syspath+"DBROWSE") new readonly   alias sptabl
//    NET use (m_syspath+"SPVIEW")   index (m_syspath+"SPVIEW") NEW READONLY ALIAS spview
    NET use (m_syspath+"DBRTB")  index (m_syspath+"DBRTB") new readonly   alias sptabl1
   fks01->(DBEVAL({||m_sumall+=fks01->sum}))
   fks01->(DBGOTOP())
   DISPBEGIN()
   DISPBOX( 1, 0, MAXROW()-2, MAXCOL(), B_DOUBLE + " " )
//   @0,0 SayDisp p_npr
   @0,25 SayDisp  m_name +STRZERO(m_ved,3)+ " ЗА "+;
   NtoCMonth(VAL(fks02->month))+" МЕСЯЦ"
   @MAXROW()-1,0 SayDisp "Общ. сумма по ведомости"
   @MAXROW()-1, 24 SayDisp m_sumall PICTURE "99'999'999'999.99" COLOR "W/b"
   CLEAREOL(MAXROW(),0,'B/B')
   @MAXROW(), 0 SayDisp NumToStr(m_sumall)  COLOR "W/B"
   DISPEND()
   FOR i:=1 TO LEN(a_col)
      m_Col           := TBColumnNew()
      m_Col:colorblock:=  {||{2,3}}
      m_Col:headsep    := "─"
      m_Col:colsep     := "│"
      m_Col:footsep    := "─"
      m_col:heading    := a_col[i,2]
      m_col:block      :=a_col[i,1]
      pl_ved:addColumn( m_col )
   NEXT
   pl_ved:colorspec     := 'N/W,B/W,G/Y'
   pl_ved:colsep        := '│'
   pl_ved:SkipBlock     := { |n| SkipOrder(n) }
   pl_ved:goBottomBlock := { || fks01->( DBGOBOTTOM() ) }
   pl_ved:goTopBlock    := { || fks01->( DBGOTOP() ) }
   pl_ved:cargo:=""
   SELECT fks01
   Alias_Browse:=SELECT()
   do while .not.pl_ved:stabilize()
   enddo
   IF fks01->(BOF())
      lApnd  := .T.
   ENDIF
   DO WHILE .T.
      KEYBOARD ""
      i:=0
      DO WHILE .NOT.(pl_ved:stabilize()).AND.((i:=inkey())==0)
      ENDDO
      IF i==0.AND..NOT.lApnd
         m_time:=seconds()
         DO WHILE (i:=inkey())==0.AND.SECONDS()-m_time<M_WAIT
         ENDDO
         IF i==0
            m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL())
            COLORWIN(0,0,MAXROW(),MAXCOL(),'8/0')
            i:=INKEY(0)
            RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
         ENDIF
      ENDIF
      DO CASE
         CASE i == K_ENTER.OR.lApnd.OR. ( i >= 32 .AND. i <= 239 )
            DO WHILE .NOT.(pl_ved:stabilize())
            ENDDO
            IF EVAL(a_col[pl_ved:colPos,3])
               m_buf:=EVAL(a_col[pl_ved:colPos,1])
               READINSERT(.F.)
//               SETCURSOR(SC_NORMAL)
               SET(_SET_ESCAPE,.NOT.(lApnd.AND.pl_ved:colPos<>1))
               IF ( i >= 32 .AND. i <= 239 )
                  KEYBOARD CHR(i)
               ENDIF
               @ROW(),COL() GET m_buf VALID EVAL(a_col[pl_ved:colPos,4],m_buf) COLOR "GR+/N" PICTURE '@K'
               READ
//               SETCURSOR(SC_NONE)
               IF LASTKEY()==K_ESC.AND.lApnd
                  IF LASTREC()==0
                     lApnd:=.F.
                     EXIT
                  ELSE
                     lApnd:=.F.
                     pl_ved:up()
                     pl_ved:refreshAll()
                     LOOP
                  ENDIF
               ENDIF
               IF m_buf<>EVAL(a_col[pl_ved:colPos,1])
                  IF lApnd.AND.pl_ved:colPos==1
                     fks01->(DBAPPEND())
                     fks01->tk:=.t.
                  ENDIF
                  EVAL(a_col[pl_ved:colPos,5])
                  EVAL(a_col[pl_ved:colPos,1],m_buf)
               ENDIF
            ENDIF
            IF lApnd
               IF pl_ved:colPos==pl_ved:colCount
                  pl_ved:panHome()
                  pl_ved:down()
               ELSE
                  pl_ved:right()
               ENDIF
            ENDIF
            pl_ved:refreshCurrent()
            @MAXROW()-1, 24 SayDisp m_sumall PICTURE "99'999'999'999.99" COLOR "W/b"
            CLEAREOL(MAXROW(),0,'B/B')
            @MAXROW(), 0 SayDisp NumToStr(m_sumall)  COLOR "W/B"
         CASE i == K_DOWN     ; pl_ved:down()
            IF .NOT.lApnd
               fks01->( DBSKIP() )
               IF fks01->(EOF()).AND.pl_ved:colpos==1
                     lApnd  := .T.
               ENDIF
               fks01->( DBSKIP( -1 ) )
            ENDIF
            IF lApnd
               DO WHILE .NOT.(pl_ved:stabilize())
               ENDDO
            ENDIF
         CASE i == K_RIGHT     ; pl_ved:right()
         CASE i == K_CTRL_LEFT ; pl_ved:panleft()
         CASE i == K_CTRL_RIGHT; pl_ved:panright()
         CASE i == K_LEFT      ; pl_ved:left()
         CASE i == K_END       ; pl_ved:end()
         CASE i == K_HOME      ; pl_ved:home()
         CASE i == K_CTRL_END  ; pl_ved:panend()
         CASE i == K_CTRL_HOME ; pl_ved:panhome()
         CASE i == K_UP        ; pl_ved:up()
         CASE i == K_PGDN      ; pl_ved:pagedown()
         CASE i == K_PGUP      ; pl_ved:pageup()
         CASE i == K_CTRL_PGUP ; pl_ved:gotop()
         CASE i == K_CTRL_PGDN ; pl_ved:gobottom()
         CASE i == K_DEL                                    /* удаление записи */
                  IF  ANSWER( "Вы действительно хотите уничтожить запись ?" ) ==YES
                     m_sumall-=fks01->sum
                     fks01->( DBDELETE() )
                     fks01->( DBSKIP(-1) )
                     fks01->( DBSKIP(1) )
                     pl_ved:RefreshAll()
                     @MAXROW()-1, 24 SayDisp m_sumall PICTURE "999'999'999.99" COLOR "W/b"
                     CLEAREOL(MAXROW(),0,'B/B')
                     @MAXROW(), 0 SayDisp NumToStr(m_sumall)  COLOR "W/B"
                  ENDIF
         CASE i == K_F10      ; Calc()
         CASE i == K_ESC .AND. ANSWER("   Завершить работу ?   " )==YES
               EXIT
         CASE i == K_F6                                               /* поиск */
                  // Вывод запроса и поля ввода
                  m_buf  := SAVESCREEN( 10, 5, 14, 77 )
                  i := SETCOLOR( HELLO1_CLR )
//                  m_col:=pl_ved:GetColumn(pl_ved:colpos)
                  DispBox( 10, 5, 13, 75 ,"w+/bg",B_SINGLE+" ")
                  Shadow( 10, 5, 13, 75 )
                  @11,6 SayDisp PADC( 'Введите значение табельного номера  для поиска :', 68 )
                  @ 12,38  GET buf PICTURE "9999"
//                  SETCURSOR( SC_NORMAL )
                  READ
                  SETCOLOR( i )
//                  SETCURSOR( SC_NONE )
                  RESTSCREEN( 10, 5, 14, 77, m_buf )

                  IF ( LASTKEY() != K_ESC )

                        i := fks01->( RECNO() )
//                        pl_ved:goTop()
                        fks01->(DBEVAL( { || NIL },,;
                              { || fks01->tabn<>buf} ))
                        // Если не найдено
                        IF fks01->(EOF())
                           fks01->( DBGOTO(i) )
                           DispError( " Запись с таким значением поля не найдена ")
                        ENDIF
                        // Если найдено
                        DO WHILE !( pl_ved:stabilize() ) ; END
                        pl_ved:RefreshAll()

                  ENDIF

         CASE i == K_CTRL_P.OR. i == K_F2
            SELECT fks01
            IF OpenPrn()
            m_recno:=fks01->(RECNO())
            PrintBrowse(pl_ved,l_print)
            fks01->(DBGOTO(m_recno))
            @PROW()+1,0   Say "Общ. сумма по ведомости"
            @PROW(), 24 Say m_sumall PICTURE "99'999'999'999.99"
            @PROW()+1, 0  Say NumToStr(m_sumall)
            @PROW()+1,0 Say ""
           ClosePrn()
           ENDIF
      ENDCASE
      pl_ved:refreshCurrent()
   ENDDO
SCLOSEFiles(@s_files)
fks02->sum:=m_sumall
CLOSE base sptabl,sptabl1,fks01,fks02
RETURN (.T.)





STATIC FUNCTION SkipKassa( n )
    LOCAL  ncount  := n+fks01->(RECNO())
    DO CASE
       CASE n>fks01->(LASTREC()) - fks01->(RECNO())
         ncount:=fks01->(LASTREC()) - fks01->(RECNO())
         fks01->(DBGOBOTTOM())
       CASE n<=-fks01->(RECNO())
         ncount:=1-fks01->(RECNO())
         fks01->(DBGOTOP())
       OTHERWISE
         ncount:=n
         fks01->(DBGOTO(fks01->(RECNO())+n))
    ENDCASE
RETURN ( ncount )
STATIC FUNCTION SkipOrder( n )
    LOCAL  ncount  := 0


IF n > 0
   DO WHILE ncount < n
       (Alias_Browse)->( DBSKIP() )
       // Если конец файла
       IF ( (Alias_Browse)->( EOF() ) )
          // Если флаг добавления
          IF  lApnd
             // В конец файла
//             lApnd := .F.
             nCount++
          ELSE
             // Hа последнюю запись
             (Alias_Browse)->( DBSKIP( -1 ) )
          ENDIF
          EXIT
       END
       ncount++
   ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       (Alias_Browse)->( DBSKIP( -1 ) )
       IF ( (Alias_Browse)->( BOF() ) )
          EXIT
       END
       ncount--
   ENDDO
END

RETURN ( ncount )
STATIC FUNCTION  d_skip_line(m_shapka)
   IF m_page=0.or.prow()>=m_endpage
      @0,m_left_margin  SAY date()
      @0,m_right_margin SAY "Лист N " +STRZERO(++m_page,2)
      @1,0  SAY m_shapka
   ENDIF
   @PROW()+1,0 SAY ""
   SETPRC(PROW(),0)
RETURN .T.
FUNCTION  KASS01
   LOCAL m_hor_width:=10,usl_hor_menu_clr:="N/W",sel_hor_menu:="n/bg+"
   LOCAL n_vert2:={},n_menu:=1,n_vert_menu:={},n_menu2:=1,m_col1,m_inkey,l_delete:=.f.
LOCAL   m_key:=0,m_sumdb:=0,m_sumcr:=0,m_col,i:=0,j:=0,;
        m_time:=0,m_recno:=0,m_screen,l_printer,m_proc1,m_buf,;
        nRow,nCol,getlist:={},;
        m_nds:=0,m_ksash:='680001',m_kopr:='f1',;
        l_print:={.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.f.,.t.,.f.,.t.,.t.,.t.,.t.,.t.}
   LOCAL a_hor_menu:={" Строки"," Столбцы"," Изменение"," Печать"," Настройка"}
   LOCAL a_vert_menu:={{;
        "1 Вниз на одну строку      "+CHR(25)+"             " ,;
        "2 Вверх на одну строку     "+CHR(24)+"             " ,;
        "3 Вниз на один экран        Page Down     " ,;
        "4 Вверх на одину экран      Page Up       " ,;
        "5 На первую строку          Ctrl+Page Up  " ,;
        "6 На последнюю строку       Ctrl+Page Down" ,;
        "7 Поиск записи по столбцу   F6            " ,;
        "8 Поиск по образцу          Alt+F6        ",;
        "9 Продолжение поиска записи Ctrl+F6       ",;
        "0 Поиск по диапазону        F7            "},;
       {"1 Вправо на один столбец              "+CHR(26)+"        " ,;
        "2 Влево на один столбец               "+CHR(27)+"        " ,;
        "3 Вправо на последний видимый столбец End      " ,;
        "4 Влево  на первый видимый столбец    Home     " ,;
        "5 На первый столбец                   Ctrl+End " ,;
        "6 На последний столбец                Ctrl+Home" ,;
        "7 Прокрутка вправо                    Ctrl+"+CHR(26)+"   " ,;
        "8 Прокрутка влево                     Ctrl+"+CHR(27)+"   " } ,;
       {"1 Добавить документ  Ins       " ,;
        "2 Исправить документ Enter     " ,;
        "3 Удалить документ   Delete    " ,;
        "4 Полноэкранный режим F4       " ,;
        "5 Просуммировать документ Alt+S"},;
       {"1 Печать          F2 или Ctrl+P",;
        "2 Распечатываеме столбцы Ctrl+L",;
        "3 Настройка печати       F9    ",;
        "4 Настройка принтера     Ctrl+U"} ,;
       {"1 Подтверждение удаления записей  Alt+L " ,;
        "2 Калькулятор                     F10   " }}

      LOCAL a_param:={;
                     {K_DOWN,;
                      K_UP,;
                      K_PGDN,;
                      K_PGUP,;
                      K_CTRL_PGUP,;
                      K_CTRL_PGDN,;
                      K_F6,;
                      K_ALT_F6,;
                      K_CTRL_F6,;
                      K_F7},;
                     {K_RIGHT,;
                      K_LEFT,;
                      K_END,;
                      K_HOME,;
                      K_CTRL_END,;
                      K_CTRL_HOME,;
                      K_CTRL_RIGHT,;
                      K_CTRL_LEFT},;
                     {K_INS,;
                      K_ENTER,;
                      K_DEL,;
                      K_F4,;
                      K_ALT_S} ,;
                     {K_CTRL_P,;
                      K_CTRL_L,;
                      K_F9,;
                      K_CTRL_U},;
                     {K_ALT_L,;
                      K_F10}}
   LOCAL m_stroka:='101.102',m_tr:={||.T.},m_fl:={||.F.},s_nds,p,m_poisk1,m_poisk2,m_poisk3,m_poisk4
   LOCAL b_str:={||Fks07->(DBSEEK(fks03->kpr)),IF(.NOT.EMPTY(fks07->kopu),.t.,.f.)},;
         b_nds:={||fks03->prcn:=m_nds,fks03->nds:=ROUND(((fks03->prcn/100/(1+fks03->prcn/100))*m_buf)/m_okrugl,0)*m_okrugl},;
         b_46:={||IF(AT(SUBSTR(fks03->ksash,1,2),s_nds)<>0,.T.,.F.)},;
         b_462:={||IF(AT(SUBSTR(fks03->ksash,1,3),s_nds)<>0,.T.,.F.)},;
         b_itog:={||setpos(MAXROW()-2, 24),DispOut(TRANSFORM(m_sumdb,"99'999'999'999.99"),"W/B"),;
            SETPOS(MAXROW()-1,24),DispOut(TRANSFORM(m_sumcr,"99'999'999'999.99"),"W/B"),;
            SETPOS(MAXROW(), 24),DispOut(TRANSFORM(fks04->saldo+m_sumdb-m_sumcr,"99'999'999'999.99"),"W/b")}


// [i,1] - блок
// [i,2] - название
// [i,3] - WHEN
// [i,4] - VALID
// [i,5] - AFTER
LOCAL a_col:={;
   {COLBR(fks03->ndoc),"НОМЕР;ДОК.",m_tr} ,;
   {COLBR(fks03->kpr),"КОД;ОП.",m_tr},;
   { {||fks07->(DBSEEK(fks03->kpr)),fks07->name},"   НАИМЕНОВАНИЕ   ",m_fl},;
   {COLBR(fks03->tabn),"ТАБ.;НОМЕР",b_str},;
   {{||my_fio(fks03->tabn)}," ФАМИЛИЯ ИМЯ ОТЧЕСТВО ",m_fl} ,;
   {COLBR(fks03->ksash),"КОРРЕСП.;СЧЕТ",{||.T.}},;
   {{||sp44->(DBSEEK(fks03->ksash)),sp44->naim7},"   НАИМЕНОВАНИЕ   ",m_fl} ,;
   {{|x|IF(x==NIL,IF(fks03->kpr<'100', fks03->sum,;
     space(fks03->(FIELDSIZE(fks03->(FIELDNUM("sum")))))),fks03->sum:=x)},;
    "ПРИХОД",{||IF(fks03->kpr<'100',.T.,.F.)}},;
   {{|x|IF(x==NIL,IF(fks03->kpr>='100',fks03->sum,;
     space(fks03->(FIELDSIZE(fks03->(FIELDNUM("sum")))))),fks03->sum:=x)},;
    "РАСХОД",{||IF(fks03->kpr<'100'.OR.AT(fks03->kpr,m_stroka)<>0,.F.,.T.)}},;
    {COLBR(fks03->prcn),"Процент;НДС",b_46},;
    {COLBR(fks03->nds),"Сумма;НДС",b_46},;
    {COLBR(fks03->prca),"Процент;Акциза",{||IF(lApnd,.f.,.t.)}},;
    {COLBR(fks03->aksbor),"Сумма;Акциза",{||IF(lApnd,.f.,.t.)}},;
    {COLBR(fks03->glv),"ГОЛОВ",b_462},;
    {COLBR(fks03->kvo2),"ЗАЧЕТНЫЙ;  ВЕС",b_462},;
    {COLBR(fks03->kvo),"КОЛИЧЕСТВО",b_46},;
    {COLBR(fks03->ndoc1),"НОМЕР;ДОП.;ДОК.",m_tr}}
//    {COLBR(fks03->ndoc1),"НОМЕР;ДОП.;ДОК.",{||IF(AT(fks03->kpr,m_stroka)==0,.F.,.T.)}}}
   LOCAL a_col1:={;
   {{|p|IF(p>0,.t.,.f.)},m_tr} ,;
   {{|p|FKS07->(sp_vl("FKS07"))},;
     {||fks03->kopr:=fks07->kopr,;
      IF(m_buf<'100'.and.fks03->kpr>='100',EVAL({||m_sumdb+=fks03->sum,m_sumcr-=fks03->sum}),;
         IF(m_buf>'099'.and.fks03->kpr<='099',EVAL({||m_sumdb-=fks03->sum,;
            m_sumcr+=fks03->sum}),NIL)),fks03->scht:=fks07->scht,fks03->ksash:=fks07->ksash}} ,;
   {},;
   {{|p|SP10->(sp_vl("SP10A"))},m_tr} ,;
   {},;
   {{|p|sp44->(sp_vl("SP44"))},m_tr},;
   {} ,;
   {m_tr,{||m_sumdb+=m_buf-fks03->sum,IF(EVAL(b_46),EVAL(b_nds),0)}} ,;
   {m_tr,{||m_sumcr+=m_buf-fks03->sum,IF(EVAL(b_46),EVAL(b_nds),0)}} ,;
   {m_tr,{||fks03->nds:=ROUND(((m_buf/100/(1+m_buf/100))*fks03->sum)/m_okrugl,0)*m_okrugl}},;
   {m_tr,m_tr},;
   {m_tr,{||fks03->aksbor:=m_buf/100*fks03->sum}},;
   {m_tr,m_tr},;
   {m_tr,m_tr},;
   {m_tr,m_tr},;
   {m_tr,m_tr},;
   {{|p|IF(AT(fks03->kpr,m_stroka)==0,.T.,IF(getsum(p,@m_sumcr),.T.,.F.))},m_tr}}
LOCAL   a_pl_ved:={},;
   order:=TBrowseDB(3,1,MAXROW()-4,MAXCOL()-1),m_okrugl:=0,m_ksash2,s_files:={}
   InitNds(@m_nds,@m_ksash,@m_kopr,@s_nds,@m_ksash2)
NET USE (m_workpath+"inst1") INDEX  (m_workpath+"inst1") new ALIAS myvar
RESTMEM m_okrugl,s_nds
CLOSE myvar


NET use (m_syspath+"DBROWSE")  index (m_syspath+"DBROWSE") new readonly   alias sptabl
//    NET use (m_syspath+"SPVIEW")   index (m_syspath+"SPVIEW") NEW READONLY ALIAS spview
NET use (m_syspath+"DBRTB")  index (m_syspath+"DBRTB") new readonly   alias sptabl1
   SopenFiles("SP10",@S_FILES)
   SopenFiles("SP05",@s_files)
   SopenFiles("SP08",@s_files)
   SopenFiles("SP44",@s_files)
   USE (m_workpath+"fks07") INDEX (m_workpath+"fks07") NEW
   USE (m_workpath+"fks02") INDEX (m_workpath+"fks02") NEW
   USE (m_workpath+"fks03") NEW
   Alias_Browse:=SELECT()
   fks03->(DBGOTOP())
   USE (m_workpath+"fks04") NEW
   KEYBOARD ""
   CLEAR
   fks03->(DBEVAL({||IF(fks03->kpr<'100',m_sumdb+=fks03->sum,m_sumcr+=fks03->sum)}))
   fks03->(DBGOTOP())
   DISPBEGIN()
   DISPBOX( 2, 0, MAXROW()-3, MAXCOL(), B_DOUBLE + " " )
   @1,0 SayDisp  "Кассовая книга за "+ DTOC(fks04->ddoc)
   @1,29 SayDisp "Остаток на начало дня"
   @1,54 SayDisp fks04->saldo PICTURE "999'999'999'999.99"
   CLEARWIN(MAXROW()-2,0,MAXROW(),MAXCOL(),"b/b")
   @MAXROW()-2,0 SayDisp "Приход"
   @MAXROW()-1,0 SayDisp "Расход"
   @MAXROW(),0 SayDisp "Остаток на конец дня"
   EVAL(b_itog)
   DISPEND()
   FOR i:=1 TO LEN(a_col)
      m_Col           := TBColumnNew()
//      IF i==len(a_col)-3.OR.i==len(a_col)-4
         m_Col:colorblock:=  {|p|IF(fks03->kpr=='107',{2,5},{3,4})}
//      ELSE
//         m_Col:colorblock:=  {|| {3,4}}
//      ENDIF

      m_Col:headsep    := "─"
      m_Col:colsep     := "│"
      m_col:heading    := a_col[i,2]
      m_col:block      :=a_col[i,1]
      order:addColumn( m_col )
   NEXT
   order:colorspec     := 'N/W,R/W,B/W,G/Y,N/R'
   order:colsep        := '│'
   order:SkipBlock     := { |n| SkipOrder(n) }
   order:goBottomBlock := { || fks03->( DBGOBOTTOM() ) }
   order:goTopBlock    := { || fks03->( DBGOTOP() ) }
   order:freeze        := 1
   order:cargo         :=""
   SELECT fks03
   do while .not.order:stabilize()
   enddo
   IF fks03->(BOF())
      READINSERT(.F.)
//      SETCURSOR(SC_NORMAL)
      SET(_SET_ESCAPE,.NOT.(lApnd.AND.order:colPos<>1))
      @1,18 GET fks04->ddoc COLOR "GR+/N"
      READ
//      SETCURSOR(SC_NONE)
      @1,0 SayDisp  "Кассовая книга за "+ DTOC(fks04->ddoc) COLOR "W/B"
      lApnd  := .T.
   ENDIF
   m_hor_width:=INT(maxcol()/LEN(a_hor_menu))
   n_vert_menu:=Asize(n_vert_menu,LEN(a_hor_menu))
   aeval(n_vert_menu,{|x|x:=0})
   Asize(n_vert2,LEN(a_hor_menu))
   aeval(n_vert2,{|x|x:=0})
   i:=0
   AEVAL(a_hor_menu,{|x|SETPOS(0,i),DISPOUT(PADR(x,m_hor_width),usl_hor_menu_clr),i+=m_hor_width})
   DO WHILE .T.
      m_key:=0
      DO WHILE .NOT.(order:stabilize()) .AND.((m_key:=inkey())==0)
      ENDDO
      IF m_key==0.AND..NOT.lApnd
         m_time:=seconds()
         DO WHILE (m_key:=inkey())==0.AND.SECONDS()-m_time<M_WAIT
         ENDDO
         IF m_key==0
            m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL())
            COLORWIN(0,0,MAXROW(),MAXCOL(),'8/0')
            INKEY(0)
            RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
         ENDIF
      ENDIF
        IF m_key==K_F8.OR.m_key==56
          i:=0
          AEVAL(a_hor_menu,{|x|SETPOS(0,i),DISPOUT(PADR(x,m_hor_width),usl_hor_menu_clr),i+=m_hor_width})
          DO WHILE .T.
            @0,(n_menu-1)*m_hor_width SayDisp PADR(a_hor_menu[n_menu],m_hor_width) COLOR sel_hor_menu
            i:=LEN(a_vert_menu[n_menu][1])
            m_col1:=IF((n_menu-1)*m_hor_width+i+4<=MAXCOL(),(n_menu-1)*m_hor_width,MAXCOL()-i-4)
            m_screen:=SAVESCREEN (1,m_col1 ,LEN(a_vert_menu[n_menu])+3,m_col1+i+4)
            @ 1,m_col1 ,LEN(a_vert_menu[n_menu])+2,m_col1+i+2 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( VVOD_CLR )
            SHADOW( 1,m_col1 ,LEN(a_vert_menu[n_menu])+2,m_col1+i+2)
            SET COLOR TO ( MNU_CLR )
            m_inkey :=ACHOICE ( 2,m_col1+1 ,LEN(a_vert_menu[n_menu])+1,m_col1+i+1,a_vert_menu[n_menu],,,n_vert_menu[n_menu],)
            RESTSCREEN(1,m_col1 ,LEN(a_vert_menu[n_menu])+3,m_col1+i+4,m_screen)
            @0,(n_menu-1)*m_hor_width SayDisp PADR(a_hor_menu[n_menu],m_hor_width) COLOR usl_hor_menu
            DO CASE
              CASE LASTKEY()==K_RIGHT
                n_menu:=IF(n_menu==LEN(a_hor_menu),1,n_menu+1)
              CASE LASTKEY()==K_LEFT
                n_menu:=IF(n_menu==1,LEN(a_hor_menu),n_menu-1)
              CASE m_inkey==AC_ABORT.OR.m_inkey>0
                EXIT
            ENDCASE
          ENDDO
          IF LASTKEY()==K_ESC
            LOOP
          ENDIF
          IF m_inkey>0
            n_vert_menu[n_menu]:=m_inkey
            m_key:=a_param[n_menu][m_inkey]
          ENDIF
        ENDIF
      DO CASE
         CASE m_key == K_DOWN .OR. m_key == K_INS
            IF m_key==K_INS
              order:gobottom()
              order:panhome()
              DO WHILE .NOT.(order:stabilize())
              ENDDO
            ENDIF
            order:down()
            fks03->( DBSKIP() )
            IF fks03->(EOF()).AND.order:colpos==1
                  lApnd  := .T.
                  // Пеpеходим ко вводу
            ENDIF
            fks03->( DBSKIP( -1 ) )
            IF lApnd
               DO WHILE .NOT.(order:stabilize())
               ENDDO
            ENDIF
         CASE m_key == K_ENTER.OR.lApnd.OR. ( m_Key >= 32 .AND. m_Key <= 239 )
              STABILIZE BROWSE order
//            DO WHILE .NOT.(order:stabilize())
//            ENDDO
            IF EVAL(a_col[order:colPos,3])
               m_buf:=EVAL(a_col[order:colPos,1])
               READINSERT(.F.)
//               SETCURSOR(SC_NORMAL)
               SET(_SET_ESCAPE,.NOT.(lApnd.AND.order:colPos<>1))
               IF ( m_Key >= 32 .AND. m_Key <= 239 )
                  KEYBOARD CHR(m_Key)
               ENDIF
               @ROW(),COL() GET m_buf VALID EVAL(a_col1[order:colPos,1],m_buf);
                COLOR "GR+/N" PICTURE '@K'
               READ
//               SETCURSOR(SC_NONE)
               IF LASTKEY()==K_ESC.AND.lApnd
                  lApnd:=.F.
                  order:up()
                  order:refreshAll()
                  LOOP
               ENDIF
                IF lApnd.AND.order:colPos==1
                    fks03->(DBAPPEND())
                ENDIF
               IF lApnd.OR.m_buf<>EVAL(a_col[order:colPos,1])
                  EVAL(a_col1[order:colPos,2])
                  EVAL(a_col[order:colPos,1],m_buf)
               ENDIF
            ENDIF
            IF lApnd
               IF order:colPos==order:colCount
                  order:panHome()
                  order:down()
               ELSE
                  order:right()
               ENDIF
            ENDIF
            order:refreshCurrent()
            EVAL(b_itog)
         CASE m_key == K_RIGHT          ; order:right()
         CASE m_key == K_CTRL_LEFT      ; order:panleft()
         CASE m_key == K_CTRL_RIGHT     ; order:panright()
         CASE m_key == K_LEFT           ; order:left()
         CASE m_key == K_END            ; order:end()
         CASE m_key == K_HOME           ; order:home()
         CASE m_key == K_CTRL_END       ; order:panend()
         CASE m_key == K_CTRL_HOME      ; order:panhome()
         CASE m_key == K_UP             ; order:up()
         CASE m_key == K_PGDN           ; order:pagedown()
         CASE m_key == K_PGUP           ; order:pageup()
         CASE m_key == K_CTRL_PGUP      ; order:gotop()
         CASE m_key == K_CTRL_PGDN      ; order:gobottom()
         CASE m_key == K_F4
          showtime()
          SETCOLOR("W/B")
          SET CURSOR ON
          WOPEN(0,0,len(a_col)+7,70)
          WBOX()
          WCENTER(.t.)
          @-1,0 SayDisp  "Кассовая книга за "+ DTOC(fks04->ddoc)
          @-1,29 SayDisp "Остаток"
          @-1,36 SayDisp fks04->saldo PICTURE "999'999'999'999.99"
          @MAXROW()-5,0 SayDisp "Приход"
          @MAXROW()-3,0 SayDisp "Расход"
          @MAXROW()-1,0 SayDisp "Остаток на конец дня"
          FOR i:=1 TO LEN(a_col)
            m_col:=order:GETCOLUMN(i)
            @0+i-1,0 SAY LEFT(CHARREPL(';',m_col:heading,' '),20)
          NEXT
          DO WHILE .t.
            FOR i:=1 TO LEN(a_col)
              @0+i-1,21 SAY eval(a_col[i,1])
            NEXT
            m_key:=INKEY(0)
            EVAL(b_itog)
            DO CASE
              CASE m_key==K_ESC
                exit
              CASE m_key==K_UP
                 IF fks03->(RECNO())<>1
                  fks03->(DBSKIP(-1))
                 ENDIF
              CASE m_key==K_DOWN
                 IF fks03->(RECNO())<>fks03->(LASTREC())
                  fks03->(DBSKIP(1))
                 ENDIF
              CASE m_key==K_PGUP
                 IF fks03->(RECNO())<>1
                  fks03->(DBSKIP(-20))
                 ENDIF
              CASE m_key==K_PGDN
                 IF fks03->(RECNO())<>fks03->(LASTREC())
                  fks03->(DBSKIP(20))
                 ENDIF
                 IF fks03->(EOF())
                  (DBSKIP(-1))
                 ENDIF
                CASE m_key==K_CTRL_PGUP
                 fks03->(DBGOTOP())
              CASE m_key==K_CTRL_PGDN
                 fks03->(DBGOBOTTOM())
            CASE m_key==K_ENTER
                 WCENTER(.t.)
                 SET(_SET_ESCAPE,.T.)
                 FOR i:=1 TO LEN(a_col)
                  IF EVAL(a_col[i,3])
                    m_buf:=EVAL(a_col[i,1])
                    @0+i-1,21 GET m_buf VALID EVAL(a_col1[i,1],m_buf) ;
                    COLOR "GR+/N" PICTURE '@K'
                    READ
                    @0+i-1,21 SAY m_buf  color 'w/b'
                    IF LASTKEY()==K_ESC
                        EXIT
                    ENDIF
                    IF m_buf<>EVAL(a_col[i,1])
                        EVAL(a_col1[i,2])
                        EVAL(a_col[i,1],m_buf)
                    ENDIF
                  ENDIF
                  NEXT
                  EVAL(b_itog)
                  CASE m_key==K_INS
                        lApnd:=.t.
                        WCENTER(.t.)
                        SET(_SET_ESCAPE,.T.)
                        DO WHILE .t.
                            FOR i:=1 TO LEN(a_col)
                              @0+i-1,21 SAY space(20)
                            NEXT
                            SET(_SET_ESCAPE,.T.)
                            m_buf:=EVAL(a_col[1,1])
                            @0,21 GET m_buf VALID EVAL(a_col1[1,1],m_buf);
                              COLOR "GR+/N" PICTURE '@K'
                            READ
                            @0,21 SAY m_buf
                            IF LASTKEY()==K_ESC
                                lApnd:=.f.
                                EXIT
                            ENDIF
                            fks03->(DBAPPEND())
                            EVAL(a_col1[1,2])
                            EVAL(a_col[1,1],m_buf)
                            SET(_SET_ESCAPE,.F.)
                            i:=2
                            DO WHILE i<=LEN(a_col)
                              IF EVAL(a_col[i,3])
                                m_buf:=EVAL(a_col[i,1])
                                @0+i-1,21 GET m_buf VALID EVAL(a_col1[i,1],m_buf) COLOR "GR+/N" ;
                                PICTURE '@K'
                                READ
                                @0+i-1,21 SAY m_buf  color 'w/b'
                                EVAL(a_col1[i,2])
                                EVAL(a_col[i,1],m_buf)
                              ENDIF
                              i++
                              FOR j:=i TO LEN(a_col)
                                @0+j-1,21 SAY eval(a_col[j,1])
                              NEXT
                            ENDDO
                            EVAL(b_itog)
                          ENDDO

                   ENDCASE
          ENDDO
          WACLOSE()
          showtime(0,72,.F.,"N/G")
          order:refreshAll()
         CASE m_key == K_F10            ; Calc()
         CASE m_key == K_ALT_S          ; SumNdoc()
         CASE m_key == K_ESC .AND. ANSWER("   Завершить работу ?   " )==YES
               EXIT
         CASE m_Key == K_DEL                                    /* удаление записи */
                  IF l_delete.OR.( ANSWER("Вы действительно хотите; уничтожить запись ?" ) == YES )
                     IF(fks03->kpr<'100',m_sumdb-=fks03->sum,m_sumcr-=fks03->sum)
                     fks03->( DBDELETE() )
                     fks03->( DBSKIP(-1) )
                     fks03->( DBSKIP(1) )
                     order:RefreshAll()
                     EVAL(b_itog)
                  ENDIF
         CASE m_key == K_CTRL_P.OR.m_key == K_F2
            SELECT fks03
            IF OpenPrn()
                IF PrintBrowse(order,l_print)
                  @PROW()+1,0 Say  "КАССОВАЯ КНИГА ЗА "+ DTOC(fks04->ddoc)
                  @PROW(),30 Say "Остаток на начало дня"
                  @PROW(),54 Say ltrim(NumToStr(fks04->saldo))
                  @PROW()+1,0 Say "Приход"
                  @PROW(), 24 Say ltrim(NumToStr(m_sumdb))
                  @PROW()+1,0 Say "Расход"
                  @PROW(), 24 Say ltrim(NumToStr(m_sumcr))
                  @PROW()+1,0 Say "Остаток на конец дня"
                  @PROW(), 24 Say ltrim(NumToStr(fks04->saldo+m_sumdb-m_sumcr))
                  @PROW()+1, 0 Say ""
                ENDIF
              ClosePrn()
              fks03->(DBGOTO(m_recno))
              ENDIF
         CASE m_key == K_F6                                               /* поиск */
                  // Вывод запроса и поля ввода
                  m_screen  := SAVESCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77 )
                  SET COLOR TO "n/bg"
                  Dispbox( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+3, 75 ,"w+/BG",B_SINGLE+" ")
                  Shadow( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+3, 75 )
                  @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( 'Введите значение  для поиска :', 68 ) COLOR "N/BG"
                  m_poisk3:=BLANK((eval(a_col[order:colpos,1])),.t.)
                  @ INT((MAXROW()-4)/2)+2, ( 40 - INT( order:colwidth(order:colpos)/2 ) ) GET m_poisk3 COLOR "GR+/N"
                  SET ESCAPE ON
                  READ
                  SET ESCAPE OFF
                  RESTSCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77, m_screen )
                  IF ( LASTKEY() != K_ESC )
                        m_recno :=  RECNO()
                        m_poisk1:=a_col[order:colpos,1]
                        m_poisk2:={||EVAL(m_poisk1)<>m_poisk3}
                        DBEVAL( { || NIL },,;
                              m_poisk2 )
                        // Если не найдено
                        IF EOF()
                           DBGOTO(m_recno)
                           DispError( " Запись с таким значением поля не найдена " )
                        ENDIF
                        // Если найдено
                        order:RefreshAll()
                        DO WHILE !( order:stabilize() ) ; END
                  ENDIF
         CASE m_key == K_ALT_F6                                               /* поиск */
                  // Вывод запроса и поля ввода
                  m_poisk3:=BLANK(EVAL(a_col[order:colpos,1]),.t.)
                  IF VALTYPE(m_poisk3)<>"C"
                    WaitMessage("Поиск по образцу в данном столбце невозможен","w/ng",.t.)
                    LOOP
                  ENDIF
                  m_screen  := SAVESCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77 )
                  SET COLOR TO "n/bg"
                  DispBox( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+3, 75 ,"w+/bg",B_SINGLE+" ")
                  SHADOW( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+3, 75 )
                  @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( 'Введите значение для поиска :', 68 ) COLOR HELLO1_CLR
                  SET ESCAPE ON
                  @ INT((MAXROW()-4)/2)+2, ( 40 - INT( order:colwidth(order:colpos)/2 ) ) GET m_poisk3 PICTURE "@!@K"   COLOR "GR+/N"
                  READ
                  SET ESCAPE OFF
                  RESTSCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77, m_screen )

                  IF ( LASTKEY() != K_ESC )
                        m_recno :=  RECNO()
                        m_poisk1:=a_col[order:colpos,1]
                        m_poisk3:=ALLTRIM(m_poisk3)
                        m_poisk2:={||.NOT.LIKE(m_poisk3,UPPER(EVAL(m_poisk1)))}
                        DBEVAL( { || NIL },,;
                              m_poisk2 )
                        // Если не найдено
                        IF EOF()
                           DBGOTO(m_recno)
                           DispError(  " Запись с таким значением поля не найдена " )
                        ENDIF
                        // Если найдено
                        order:RefreshAll()
                        DO WHILE !( order:stabilize() ) ; END
                  ENDIF
         CASE m_key == K_F7
                  // Вывод запроса и поля ввода
                  m_screen  := SAVESCREEN( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+7, 77 )
                  SET COLOR TO "n/bg"
                  DispBox( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+6, 75 ,"w+/bg",B_SINGLE+" ")
                  SHADOW( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+6, 75 )
                  @INT((MAXROW()-6)/2)+1,6 SayDisp PADC( 'Введите значение нижней границы поиска для поиска :', 68 ) COLOR HELLO1_CLR
                  @INT((MAXROW()-6)/2)+3,6 SayDisp PADC( 'Введите значение верхней границы поиска  для поиска :', 68 ) COLOR HELLO1_CLR
                  m_poisk4:=m_poisk3:=BLANK((eval(a_col[order:colpos,1])),.t.)
                  SET ESCAPE ON
                  @ INT((MAXROW()-6)/2)+2, ( 40 - INT( order:colwidth(order:colpos)/2 ) ) GET m_poisk3 COLOR "GR+/N"
                  @ INT((MAXROW()-6)/2)+4, ( 40 - INT( order:colwidth(order:colpos)/2 ) ) GET m_poisk4 COLOR "GR+/N"
                  READ
                  SET ESCAPE OFF
                  SETCOLOR( )
                  RESTSCREEN( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+7, 77, m_screen )

                  IF ( LASTKEY() != K_ESC )

                        m_recno :=  RECNO()
                        m_poisk1:=a_col[order:colpos,1]
                        m_poisk2:={||EVAL(m_poisk1)<m_poisk3.OR.EVAL(m_poisk1)>m_poisk4}
                        DBEVAL( { || NIL },,;
                              m_poisk2 )
                        // Если не найдено
                        IF EOF()
                           DBGOTO(m_recno)
                           DispError(  " Запись с таким значением поля не найдена " )
                        ENDIF
                        // Если найдено
                        order:RefreshAll()
                        DO WHILE !( order:stabilize() ) ; END
                  ENDIF
         CASE m_key == K_CTRL_F6                                               /* продолжение поиска */
                  // Вывод запроса и поля ввода
                        m_recno :=  RECNO()
                        DBSKIP(1)
                        DBEVAL( { || NIL },,;
                              m_poisk2 )
                        // Если не найдено
                        IF EOF()
                           DBGOTO(m_recno)
                           DispError(  " Запись с таким значением поля не найдена " )
                        ELSE
                           order:RefreshAll()
                        ENDIF
         CASE m_key == K_ALT_L
            l_delete:=IF(ALERT("Подтверждать удаление записей",{"Да","Нет"},"w+/bg,w/b")==2,.t.,.f.)
         CASE m_key == K_CTRL_L
                  SetLprint(@order,@l_print)
         CASE m_key == K_CTRL_U
                  LSetprint()
         CASE m_key == K_F9
                  SetLpechat()
      ENDCASE
   ENDDO
// CLOSE sp10
// CLOSE sp44
// CLOSE sp05
SCLOSEFiles(@s_files)
CLOSE base fks03,fks02,fks04,fks07,sptabl1,sptabl
RETURN (.T.)
Function InitNds(m_nds,m_ksash,m_kopr,s_nds,m_ksash2)
  NET USE (m_platpath+"nds") NEW READONLY
  m_nds:=nds->nds
  m_ksash:=nds->ksash
  m_kopr:=nds->kopr
  s_nds:=nds->scht
  m_ksash2:=nds->ksash2
  CLOSE nds
return .t.
Function InitAksbor(m_ksash,m_kopr)
  NET USE (m_platpath+"nds") NEW READONLY
  m_ksash:=nds->ksashaks
  m_kopr:=nds->kopraks
  CLOSE nds
return .t.
FUNCTION  GetSum (x,m_sumcr)
//   LOCAL m_var:=IF(fks03->kpr=='102',"FKSD"+STRZERO(x,3),"FKSP"+STRZERO(x,2))
   IF x==0
      RETURN .T.
   ENDIF
   fks02->(DBSEEK(IF(fks03->kpr=='102',"FKSD"+STRZERO(x,3),"FKSP"+STRZERO(x,2)) ))
   IF fks02->(FOUND())
         fks03->sum:=fks02->sum
         m_sumcr+=fks02->sum
         RETURN .T.
   ENDIF
RETURN .F.
STATIC FUNCTION SumNdoc
   LOCAL m_ndoc:=fks03->ndoc,m_recno:=fks03->(RECNO()),m_sum1:=0,;
   m_str :=savescreen(9,19,22,64),m_sum2:=0,m_sum3:=0,m_sum4:=0,getlist:={},;
   m_sum6:=0,m_sum5:=0,m_sum7:=0

   SET CURSOR ON
   SET COLOR TO  "N/BG+,N/W"
   DispBox(9,19,20,62,"w+/bg",B_SINGLE+" ")
   Shadow(9,19,20,62)
   @ 10,20 SayDisp 'Введите номер документа '
   @ 12,20 SayDisp 'Итоговая сумма '
   @ 10,45  GET m_ndoc
   read
   @ 13,20 SayDisp 'Приход    '
   @ 14,20 SayDisp 'Расход    '
   @ 15,20 SayDisp 'Голов     '
   @ 16,20 SayDisp 'Зач. вес  '
   @ 17,20 SayDisp 'Количество'
   @ 18,20 SayDisp 'НДС       '
   @ 19,20 SayDisp 'А-ный сбор'

   fks03->(DBGOTOP())
   DO WHILE .NOT.fks03->(EOF())
      IF m_ndoc=0.OR.m_ndoc==fks03->ndoc
         IF fks03->kpr<'100'
            m_sum1+=fks03->sum
            m_sum3+=fks03->glv
            m_sum4+=fks03->kvo
            m_sum7+=fks03->kvo2
            m_sum5+=fks03->nds
            m_sum6+=fks03->aksbor
         ELSE
            m_sum2+=fks03->sum
            m_sum3-=fks03->glv
            m_sum4-=fks03->kvo
            m_sum7-=fks03->kvo2
            m_sum5-=fks03->nds
            m_sum6-=fks03->aksbor
         ENDIF
      ENDIF
      @ 12,37 SayDisp m_sum1-m_sum2 PICTURE "99'999'999'999.99"
      @ 13,31 SayDisp m_sum1        PICTURE "99'999'999'999.99"
      @ 14,31 SayDisp m_sum2        PICTURE "99'999'999'999.99"
      @ 15,31 SayDisp m_sum3        PICTURE "99'999'999'999.99"
      @ 16,31 SayDisp m_sum7        PICTURE "99'999'999'999.99"
      @ 17,31 SayDisp m_sum4        PICTURE "99'999'999'999.99"
      @ 18,31 SayDisp m_sum5        PICTURE "99'999'999'999.99"
      @ 19,31 SayDisp m_sum6        PICTURE "99'999'999'999.99"
      fks03->(DBSKIP(1))
   ENDDO
   inkey(0)
   set escape off
   set cursor off
   restscreen(9,19,21,64,m_str)
   fks03->(DBGOTO(m_recno))
   SET COLOR TO ( MNU_CLR )
   SET CURSOR OFF
RETURN .T.
function my_fio(m_tabn)
  if .not.empty(m_tabn)
  sp10->(dbseek(m_tabn))
  IF sp10->(FOUND())
 return(substr(PADR(ALLTRIM(sp10->fam)+' ';
  +left(ltrim(sp10->imja),1)+'.'+left(ltrim(sp10->otch),1),20),1,20))
  ENDIF
  endif
RETURN(SPACE(20))
FUNCTION  copypl
   LOCAL m_month,a_struct1:={;
   {"tabn","C",4,0},{"sum","N",16,2},{"kassir","C",2,0}},;
   a_struct2:={;
   {"tabn","C",4,0},{"sum","N",16,2},{"tk","L",1,0}},;
   m_kassir,a_dir,i,m_screen,j
   m_month:=STRZERO(getmonth(),2)
   IF LASTKEY()==K_ESC
      RETURN .F.
   ENDIF
   IF m_month=='12'
     m_month:='00'
   ENDIF
   NET USE (m_mainpath+"flish") NEW READONLY
   NET USE (m_sprpath+"sp10")  INDEX (m_sprpath+"sp10") NEW READONLY
   DBCREATE(m_temppath+"buf",a_struct1)
   USE (m_temppath+"buf") NEW
   DBCREATE(m_temppath+"fksp",a_struct2)
   USE (m_workpath+"fks02") NEW
   flish->(DBGOBOTTOM())
   m_screen:=DispMessage("Выборка из лицевого счета")
@10,10 SAY m_month
//   DO WHILE .NOT.flish->(BOF()).AND.(flish->month>=m_month.or.flish->month=='01')
   DO WHILE .NOT.flish->(BOF())
      IF flish->month==m_month.AND.flish->kopu=="800"
         buf->(DBAPPEND())
         buf->tabn:=flish->tabn
         buf->sum:=flish->sum
         sp10->(DBSEEK(buf->tabn))
         IF sp10->(FOUND())
            buf->kassir:=sp10->kass
         ELSE
            DispError("Табельный номер "+buf->tabn+";не найден в справочнике работников!;"+;
            "Нажмите любую клавишу для продолжения")
            buf->kassir:="99"
         ENDIF
      ENDIF
      flish->(DBSKIP(-1))
   ENDDO
   DelMessage(m_screen)
   m_screen:=DispMessage("Формирование платежных ведомостей")
   // Создание файлов
   a_dir:=DIRECTORY(m_workpath+"fksp???.dbf")
   AEVAL(a_dir,{|x|FERASE(m_workpath+x[F_NAME])})
   fks02->(DBEVAL( { || IF ( LEFT(fks02->name,4)=="FKSP",fks02->(DBDELETE()),NIL ) } ))
   select buf
   INDEX ON buf->kassir+buf->tabn TO (m_temppath+"buf")
   buf->(dbgotop())
   m_kassir:="ЫЫ"
   j:=1
   DO WHILE .NOT.buf->(EOF())
      IF m_kassir<>buf->kassir
         m_kassir:=buf->kassir
         FILECOPY(m_workpath+"buf01.dbf",m_workpath+"FKSP"+STRZERO(j,2)+".DBF")
         IF (i:=SELECT("fksp"))<>0
            DBSELECTAR("FKSP")
            USE
         ENDIF
         DBUSEAREA(.T.,,m_workpath+"FKSP"+STRZERO(j,2),"fksp")
         fks02->(DBAPPEND())
         fks02->month:=m_month
         fks02->name:="FKSP"+STRZERO(j,2)
         j++
      ENDIF
      fksp->(DBAPPEND())
      fksp->sum:=buf->sum
      fksp->tabn:=buf->tabn
      fksp->tk:=.T.
      buf->(DBSKIP(1))
   ENDDO
   fksp->(DBCLOSEAREA())
   buf->(DBCLOSEAREA())
   sp10->(DBCLOSEAREA())

   flish->(DBCLOSEAREA())
   select fks02
   PACK
   fks02->(DBSETINDEX(m_workpath+"fks02"))
   fks02->(DBREINDEX())
   fks02->(DBCLOSEAREA())
   DelMessage(m_screen)
RETURN (.T.)
FUNCTION  KASS04
   LOCAL m_hor_width:=10,usl_hor_menu_clr:="N/W",sel_hor_menu:="n/bg+"
   LOCAL n_vert2:={},n_menu:=1,n_vert_menu:={},n_menu2:=1,m_col1,m_inkey
LOCAL   m_key:=0,m_sumdb:=0,m_sumcr:=0,m_col,i:=0,j:=0,;
        m_time:=0,m_recno:=0,m_screen,l_printer,m_proc1,m_buf,;
        nRow,nCol,GetList:={},;
        m_nds:=0,m_ksash:='680001',m_kopr:='f1',;
        l_print:={.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.f.,.t.,.f.,.t.,.t.,.t.,.t.,.t.}
   LOCAL a_hor_menu:={" Строки"," Столбцы"," Изменение"," Печать"," Настройка"}
   LOCAL a_vert_menu:={{;
        "1 Вниз на одну строку      "+CHR(25)+"             " ,;
        "2 Вверх на одну строку     "+CHR(24)+"             " ,;
        "3 Вниз на один экран        Page Down     " ,;
        "4 Вверх на одину экран      Page Up       " ,;
        "5 На первую строку          Ctrl+Page Up  " ,;
        "6 На последнюю строку       Ctrl+Page Down" ,;
        "7 Поиск записи по столбцу   F6            " ,;
        "8 Поиск по образцу          Alt+F6        ",;
        "9 Продолжение поиска записи Ctrl+F6       ",;
        "0 Поиск по диапазону        F7            "},;
       {"1 Вправо на один столбец              "+CHR(26)+"        " ,;
        "2 Влево на один столбец               "+CHR(27)+"        " ,;
        "3 Вправо на последний видимый столбец End      " ,;
        "4 Влево  на первый видимый столбец    Home     " ,;
        "5 На первый столбец                   Ctrl+End " ,;
        "6 На последний столбец                Ctrl+Home" ,;
        "7 Прокрутка вправо                    Ctrl+"+CHR(26)+"   " ,;
        "8 Прокрутка влево                     Ctrl+"+CHR(27)+"   " } ,;
       {"1 Полноэкранный режим F4       " },;
       {"1 Печать          F2 или Ctrl+P",;
        "2 Распечатываеме столбцы Ctrl+L",;
        "3 Настройка печати       F9    ",;
        "4 Настройка принтера     Ctrl+U"} ,;
       {"1 Калькулятор                     F10   " }}

      LOCAL a_param:={;
                     {K_DOWN,;
                      K_UP,;
                      K_PGDN,;
                      K_PGUP,;
                      K_CTRL_PGUP,;
                      K_CTRL_PGDN,;
                      K_F6,;
                      K_ALT_F6,;
                      K_CTRL_F6,;
                      K_F7},;
                     {K_RIGHT,;
                      K_LEFT,;
                      K_END,;
                      K_HOME,;
                      K_CTRL_END,;
                      K_CTRL_HOME,;
                      K_CTRL_RIGHT,;
                      K_CTRL_LEFT},;
                     {K_F4} ,;
                     {K_CTRL_P,;
                      K_CTRL_L,;
                      K_F9,;
                      K_CTRL_U},;
                     {K_F10}}
   LOCAL p,m_poisk1,m_poisk2,m_poisk3,m_poisk4
   LOCAL b_itog:={||setpos(MAXROW()-2, 24),DispOut(TRANSFORM(m_sumdb,"99'999'999'999.99"),"W/B"),;
            SETPOS(MAXROW()-1,24),DispOut(TRANSFORM(m_sumcr,"99'999'999'999.99"),"W/B"),;
            SETPOS(MAXROW(), 24),DispOut(TRANSFORM(fks04->saldo+m_sumdb-m_sumcr,"99'999'999'999.99"),"W/b")}


// [i,1] - блок
// [i,2] - название
// [i,3] - WHEN
// [i,4] - VALID
// [i,5] - AFTER
LOCAL a_col:={{{||fks08->ddoc},"Дата;документа"},;
   {{||fks08->ndoc},"НОМЕР;ДОК."} ,;
   {{||fks08->kpr},"КОД;ОП."},;
   {{||fks07->(DBSEEK(fks08->kpr)),fks07->name},"   НАИМЕНОВАНИЕ   "},;
   {{||fks08->tabn},"ТАБ.;НОМЕР"},;
   {{||my_fio(fks08->tabn)}," ФАМИЛИЯ ИМЯ ОТЧЕСТВО "},;
   {{||fks08->ksash},"КОРРЕСП.;СЧЕТ"},;
   {{||sp44->(DBSEEK(fks08->ksash)),sp44->naim7},"   НАИМЕНОВАНИЕ   "} ,;
   {{||IF(fks08->kpr<'100',fks08->sum,;
     space(fks08->(FIELDSIZE(fks08->(FIELDNUM("sum"))))))},"ПРИХОД"},;
   {{||IF(fks08->kpr>='100',fks08->sum,;
     space(fks08->(FIELDSIZE(fks08->(FIELDNUM("sum"))))))},"РАСХОД"},;
    {{||fks08->prcn},"Процент;НДС"},;
    {{||fks08->nds},"Сумма;НДС"},;
    {{||fks08->prca},"Процент;Акциза"},;
    {{||fks08->aksbor},"Сумма;Акциза"},;
    {{||fks08->glv},"ГОЛОВ"},;
    {COLBR(fks08->kvo2),"ЗАЧЕТНЫЙ;  ВЕС"},;
    {{||fks08->kvo},"КОЛИЧЕСТВО"},;
    {{||fks08->ndoc1},"НОМЕР;ДОП.;ДОК."}}
LOCAL   a_pl_ved:={},;
   order:=TBrowseDB(3,1,MAXROW()-4,MAXCOL()-1),s_files:={}
   SopenFiles("SP10",@S_FILES)
   SopenFiles("SP05",@s_files)
   SopenFiles("SP44",@s_files)
   USE (m_workpath+"fks07") INDEX (m_workpath+"fks07") READONLY NEW
   USE (m_workpath+"fks02") INDEX (m_workpath+"fks02") NEW
   USE (m_workpath+"fks08") NEW
   Alias_Browse:=SELECT()
   fks08->(DBGOTOP())
   KEYBOARD ""
   CLEAR
   fks08->(DBGOBOTTOM())
   DISPBEGIN()
   DISPBOX( 2, 0, MAXROW()-3, MAXCOL(), B_DOUBLE + " " )
   @1,0 SayDisp  "Кассовая книга "
//   @1,29 SayDisp "Остаток на начало дня"
//   @1,54 SayDisp fks04->saldo PICTURE "999'999'999'999.99"
   CLEARWIN(MAXROW()-2,0,MAXROW(),MAXCOL(),"b/b")
//   @MAXROW()-2,0 SayDisp "Приход"
//   @MAXROW()-1,0 SayDisp "Расход"
//   @MAXROW(),0 SayDisp "Остаток на конец дня"
//   EVAL(b_itog)
   DISPEND()
   FOR i:=1 TO LEN(a_col)
      m_Col           := TBColumnNew()
      m_Col:colorblock:=  {|p|IF(fks08->kpr=='107',{2,5},{3,4})}
      m_Col:headsep    := "─"
      m_Col:colsep     := "│"
      m_col:heading    := a_col[i,2]
      m_col:block      :=a_col[i,1]
      order:addColumn( m_col )
   NEXT
   order:colorspec     := 'N/W,R/W,B/W,G/Y,N/R'
   order:colsep        := '│'
   order:SkipBlock     := { |n| SkipOrder(n) }
   order:goBottomBlock := { || fks08->( DBGOBOTTOM() ) }
   order:goTopBlock    := { || fks08->( DBGOTOP() ) }
   order:freeze        := 1
   order:cargo         :=""
   SELECT fks08
   do while .not.order:stabilize()
   enddo
   m_hor_width:=INT(maxcol()/LEN(a_hor_menu))
   n_vert_menu:=Asize(n_vert_menu,LEN(a_hor_menu))
   aeval(n_vert_menu,{|x|x:=0})
   Asize(n_vert2,LEN(a_hor_menu))
   aeval(n_vert2,{|x|x:=0})
   i:=0
   AEVAL(a_hor_menu,{|x|SETPOS(0,i),DISPOUT(PADR(x,m_hor_width),usl_hor_menu_clr),i+=m_hor_width})
   DO WHILE .T.
      m_key:=0
      DO WHILE .NOT.(order:stabilize()) .AND.((m_key:=inkey())==0)
      ENDDO
      IF m_key==0.AND..NOT.lApnd
         m_time:=seconds()
         DO WHILE (m_key:=inkey())==0.AND.SECONDS()-m_time<M_WAIT
         ENDDO
         IF m_key==0
            m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL())
            COLORWIN(0,0,MAXROW(),MAXCOL(),'8/0')
            INKEY(0)
            RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
         ENDIF
      ENDIF
        IF m_key==K_F8.OR.m_key==56
          i:=0
          AEVAL(a_hor_menu,{|x|SETPOS(0,i),DISPOUT(PADR(x,m_hor_width),usl_hor_menu_clr),i+=m_hor_width})
          DO WHILE .T.
            @0,(n_menu-1)*m_hor_width SayDisp PADR(a_hor_menu[n_menu],m_hor_width) COLOR sel_hor_menu
            i:=LEN(a_vert_menu[n_menu][1])
            m_col1:=IF((n_menu-1)*m_hor_width+i+4<=MAXCOL(),(n_menu-1)*m_hor_width,MAXCOL()-i-4)
            m_screen:=SAVESCREEN (1,m_col1 ,LEN(a_vert_menu[n_menu])+3,m_col1+i+4)
            @ 1,m_col1 ,LEN(a_vert_menu[n_menu])+2,m_col1+i+2 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( VVOD_CLR )
            SHADOW( 1,m_col1 ,LEN(a_vert_menu[n_menu])+2,m_col1+i+2)
            SET COLOR TO ( MNU_CLR )
            m_inkey :=ACHOICE ( 2,m_col1+1 ,LEN(a_vert_menu[n_menu])+1,m_col1+i+1,a_vert_menu[n_menu],,,n_vert_menu[n_menu],)
            RESTSCREEN(1,m_col1 ,LEN(a_vert_menu[n_menu])+3,m_col1+i+4,m_screen)
            @0,(n_menu-1)*m_hor_width SayDisp PADR(a_hor_menu[n_menu],m_hor_width) COLOR usl_hor_menu
            DO CASE
              CASE LASTKEY()==K_RIGHT
                n_menu:=IF(n_menu==LEN(a_hor_menu),1,n_menu+1)
              CASE LASTKEY()==K_LEFT
                n_menu:=IF(n_menu==1,LEN(a_hor_menu),n_menu-1)
              CASE m_inkey==AC_ABORT.OR.m_inkey>0
                EXIT
            ENDCASE
          ENDDO
          IF LASTKEY()==K_ESC
            LOOP
          ENDIF
          IF m_inkey>0
            n_vert_menu[n_menu]:=m_inkey
            m_key:=a_param[n_menu][m_inkey]
          ENDIF
        ENDIF
      DO CASE
         CASE m_key == K_DOWN ;   order:down()
         CASE m_key == K_RIGHT          ; order:right()
         CASE m_key == K_CTRL_LEFT      ; order:panleft()
         CASE m_key == K_CTRL_RIGHT     ; order:panright()
         CASE m_key == K_LEFT           ; order:left()
         CASE m_key == K_END            ; order:end()
         CASE m_key == K_HOME           ; order:home()
         CASE m_key == K_CTRL_END       ; order:panend()
         CASE m_key == K_CTRL_HOME      ; order:panhome()
         CASE m_key == K_UP             ; order:up()
         CASE m_key == K_PGDN           ; order:pagedown()
         CASE m_key == K_PGUP           ; order:pageup()
         CASE m_key == K_CTRL_PGUP      ; order:gotop()
         CASE m_key == K_CTRL_PGDN      ; order:gobottom()
         CASE m_key == K_F4
          showtime()
          SETCOLOR("W/B")
          SET CURSOR ON
          WOPEN(0,0,len(a_col)+7,70)
          WBOX()
          WCENTER(.t.)
//          @-1,0 SayDisp  "Кассовая книга за "+ DTOC(fks04->ddoc)
//          @-1,29 SayDisp "Остаток"
//          @-1,36 SayDisp fks04->saldo PICTURE "999'999'999'999.99"
//          @MAXROW()-5,0 SayDisp "Приход"
//          @MAXROW()-3,0 SayDisp "Расход"
//          @MAXROW()-1,0 SayDisp "Остаток на конец дня"
          FOR i:=1 TO LEN(a_col)
            m_col:=order:GETCOLUMN(i)
            @0+i-1,0 SAY LEFT(CHARREPL(';',m_col:heading,' '),20)
          NEXT
          DO WHILE .t.
            FOR i:=1 TO LEN(a_col)
              @0+i-1,21 SAY eval(a_col[i,1])
            NEXT
            m_key:=INKEY(0)
//            EVAL(b_itog)
            DO CASE
              CASE m_key==K_ESC
                exit
              CASE m_key==K_UP
                 IF fks08->(RECNO())<>1
                  fks08->(DBSKIP(-1))
                 ENDIF
              CASE m_key==K_DOWN
                 IF fks08->(RECNO())<>fks08->(LASTREC())
                  fks08->(DBSKIP(1))
                 ENDIF
              CASE m_key==K_PGUP
                 IF fks08->(RECNO())<>1
                  fks08->(DBSKIP(-20))
                 ENDIF
              CASE m_key==K_PGDN
                 IF fks08->(RECNO())<>fks08->(LASTREC())
                  fks08->(DBSKIP(20))
                 ENDIF
                 IF fks08->(EOF())
                  (DBSKIP(-1))
                 ENDIF
                CASE m_key==K_CTRL_PGUP
                 fks08->(DBGOTOP())
              CASE m_key==K_CTRL_PGDN
                 fks08->(DBGOBOTTOM())
              ENDCASE
          ENDDO
          WACLOSE()
          showtime(0,72,.F.,"N/G")
          order:refreshAll()
         CASE m_key == K_F10            ; Calc()
 //        CASE m_key == K_ALT_S          ; SumNdoc()
         CASE m_key == K_ESC .AND. ANSWER("   Завершить работу ?   " )==YES
               EXIT
         CASE m_key == K_CTRL_P.OR.m_key == K_F2
            SELECT fks08
            IF OpenPrn()
                IF PrintBrowse(order,l_print)
//                  @PROW()+1,0 Say  "КАССОВАЯ КНИГА ЗА "+ DTOC(fks04->ddoc)
//                  @PROW(),30 Say "Остаток на начало дня"
//                  @PROW(),54 Say fks04->saldo PICTURE "99'999'999'999.99"
//                  @PROW()+1, 0 Say NumToStr(fks04->saldo)
//                  @PROW()+1,0 Say "Приход"
//                  @PROW(), 24 Say m_sumdb PICTURE "99'999'999'999.99"
//                  @PROW()+1, 0 Say NumToStr(m_sumdb)
//                  @PROW()+1,0 Say "Расход"
//                  @PROW(), 24 Say m_sumcr PICTURE "99'999'999'999.99"
//                  @PROW()+1, 0 Say NumToStr(m_sumcr)
//                 @PROW()+1,0 Say "Остаток на конец дня"
//                  @PROW(), 24 Say fks04->saldo+m_sumdb-m_sumcr PICTURE "99'999'999'999.99"
//                  @PROW()+1, 0 Say NumToStr(fks04->saldo+m_sumdb-m_sumcr)
//                  @PROW()+1, 0 Say ""
                ENDIF
              ClosePrn()
              fks08->(DBGOTO(m_recno))
              ENDIF
         CASE m_key == K_F6                                               /* поиск */
                  // Вывод запроса и поля ввода
                  m_screen  := SAVESCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77 )
                  SET COLOR TO "n/bg"
                  DispBox( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+3, 75,"w+/bg",B_SINGLE+" ")
                  Shadow( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+3, 75 )
                  @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( 'Введите значение  для поиска :', 68 ) COLOR "N/BG"
                  m_poisk3:=BLANK((eval(a_col[order:colpos,1])),.t.)
                  @ INT((MAXROW()-4)/2)+2, ( 40 - INT( order:colwidth(order:colpos)/2 ) ) GET m_poisk3 COLOR "GR+/N"
//                  SETCURSOR( SC_NORMAL )
                  SET ESCAPE ON
                  READ
                  SET ESCAPE OFF
//                  SETCURSOR( SC_NONE )
                  RESTSCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77, m_screen )
                  IF ( LASTKEY() != K_ESC )
                        m_recno :=  RECNO()
                        m_poisk1:=a_col[order:colpos,1]
                        m_poisk2:={||EVAL(m_poisk1)<>m_poisk3}
                        DBEVAL( { || NIL },,;
                              m_poisk2 )
                        // Если не найдено
                        IF EOF()
                           DBGOTO(m_recno)
                           DispError(  " Запись с таким значением поля не найдена " )
                        ENDIF
                        // Если найдено
                        order:RefreshAll()
                        DO WHILE !( order:stabilize() ) ; END
                  ENDIF
         CASE m_key == K_ALT_F6                                               /* поиск */
                  // Вывод запроса и поля ввода
                  m_poisk3:=BLANK(EVAL(a_col[order:colpos,1]),.t.)
                  IF VALTYPE(m_poisk3)<>"C"
                    WaitMessage("Поиск по образцу в данном столбце невозможен","w/ng",.t.)
                    LOOP
                  ENDIF
                  m_screen  := SAVESCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77 )
                  SET COLOR TO "n/bg"
                  DispBox( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+3, 75 ,"w+/bg",B_SINGLE+" ")
                  SHADOW( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+3, 75 )
                  @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( 'Введите значение для поиска :', 68 ) COLOR HELLO1_CLR
                  SET ESCAPE ON
                  @ INT((MAXROW()-4)/2)+2, ( 40 - INT( order:colwidth(order:colpos)/2 ) ) GET m_poisk3 PICTURE "@!@K"   COLOR "GR+/N"
//                  SETCURSOR( SC_NORMAL )
                  READ
                  SET ESCAPE OFF
//                  SETCOLOR( )
//                  SETCURSOR( SC_NONE )
                  RESTSCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+4, 77, m_screen )

                  IF ( LASTKEY() != K_ESC )
                        m_recno :=  RECNO()
                        m_poisk1:=a_col[order:colpos,1]
                        m_poisk3:=ALLTRIM(m_poisk3)
                        m_poisk2:={||.NOT.LIKE(m_poisk3,UPPER(EVAL(m_poisk1)))}
                        DBEVAL( { || NIL },,;
                              m_poisk2 )
                        // Если не найдено
                        IF EOF()
                           DBGOTO(m_recno)
                           DispError(  " Запись с таким значением поля не найдена " )
                        ENDIF
                        // Если найдено
                        order:RefreshAll()
                        DO WHILE !( order:stabilize() ) ; END
                  ENDIF
         CASE m_key == K_F7
                  // Вывод запроса и поля ввода
                  m_screen  := SAVESCREEN( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+7, 77 )
                  SET COLOR TO "n/bg"
                  DispBox( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+6, 75 ,"w+/bg",B_SINGLE+" ")
                  Shadow( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+6, 75 )
                  @INT((MAXROW()-6)/2)+1,6 SayDisp PADC( 'Введите значение нижней границы поиска для поиска :', 68 ) COLOR HELLO1_CLR
                  @INT((MAXROW()-6)/2)+3,6 SayDisp PADC( 'Введите значение верхней границы поиска  для поиска :', 68 ) COLOR HELLO1_CLR
                  m_poisk4:=m_poisk3:=BLANK((eval(a_col[order:colpos,1])),.t.)
                  SET ESCAPE ON
                  @ INT((MAXROW()-6)/2)+2, ( 40 - INT( order:colwidth(order:colpos)/2 ) ) GET m_poisk3 COLOR "GR+/N"
                  @ INT((MAXROW()-6)/2)+4, ( 40 - INT( order:colwidth(order:colpos)/2 ) ) GET m_poisk4 COLOR "GR+/N"
//                  SETCURSOR( SC_NORMAL )
                  READ
                  SET ESCAPE OFF
                  SETCOLOR( )
//                  SETCURSOR( SC_NONE )
                  RESTSCREEN( INT((MAXROW()-6)/2), 5, INT((MAXROW()-6)/2)+7, 77, m_screen )

                  IF ( LASTKEY() != K_ESC )

                        m_recno :=  RECNO()
                        m_poisk1:=a_col[order:colpos,1]
                        m_poisk2:={||EVAL(m_poisk1)<m_poisk3.OR.EVAL(m_poisk1)>m_poisk4}
                        DBEVAL( { || NIL },,;
                              m_poisk2 )
                        // Если не найдено
                        IF EOF()
                           DBGOTO(m_recno)
                           DispError(  " Запись с таким значением поля не найдена " )
                        ENDIF
                        // Если найдено
                        order:RefreshAll()
                        DO WHILE !( order:stabilize() ) ; END
                  ENDIF
         CASE m_key == K_CTRL_F6                                               /* продолжение поиска */
                  // Вывод запроса и поля ввода
                        m_recno :=  RECNO()
                        DBSKIP(1)
                        DBEVAL( { || NIL },,;
                              m_poisk2 )
                        // Если не найдено
                        IF EOF()
                           DBGOTO(m_recno)
                           DispError(  " Запись с таким значением поля не найдена " )
                        ELSE
                           order:RefreshAll()
                        ENDIF
         CASE m_key == K_CTRL_L
                  SetLprint(@order,@l_print)
         CASE m_key == K_CTRL_U
                  LSetprint()
         CASE m_key == K_F9
                  SetLpechat()
         CASE m_key == K_ALT_S
                  SumNdoc1()
      ENDCASE
   ENDDO
// CLOSE sp10 CLOSE sp44 CLOSE sp05
SCLOSEFiles(@s_files)

CLOSE fks08
CLOSE fks02
//CLOSE fks04
CLOSE fks07
RETURN (.T.)
Function RestVar(m_name)
myvar->(DBSEEK(PADR(LOWER(ALLTRIM(m_name)),12)))
DO CASE
  CASE myvar->kod=="C"
    RETURN (ALLTRIM(myvar->value))
  CASE myvar->kod=="N"
    RETURN (VAL(myvar->value))
  CASE myvar->kod=="L"
    RETURN (IF(AT(UPPER(ALLTRIM(myvar->value)),"1TYД")<>0,.t.,.f.))
  CASE myvar->kod=="D"
    RETURN (CTOD(ALLTRIM(myvar->value)))
ENDCASE
RETURN (0)
STATIC FUNCTION SumNdoc1
   LOCAL m_ddoc1,m_ddoc2,m_recno:=fks08->(RECNO()),m_sum1:=0,;
   m_str :=savescreen(9,19,22,64),m_sum2:=0,m_sum3:=0,m_sum4:=0,getlist:={},;
   m_sum6:=0,m_sum5:=0,m_sum7:=0
   fks08->(DBGOBOTTOM())
   m_ddoc2:=fks08->ddoc
   fks08->(DBGOTOP())
   m_ddoc1:=fks08->ddoc
   SET COLOR TO  "N/BG+,N/W"
   DispBox(9,19,20,62,"w+/bg",B_SINGLE+" ")
   Shadow(9,19,20,62)
   SET CURSOR ON
   @ 10,20 SayDisp 'Даты документов c          по '
   @ 12,20 SayDisp 'Итоговая сумма '
   @ 10,39  GET m_ddoc1
   @ 10,50  GET m_ddoc2
   read
   @ 13,20 SayDisp 'Приход    '
   @ 14,20 SayDisp 'Расход    '
   @ 15,20 SayDisp 'Голов     '
   @ 16,20 SayDisp 'Зач. вес  '
   @ 17,20 SayDisp 'Количество'
   @ 18,20 SayDisp 'НДС       '
   @ 19,20 SayDisp 'А-ный сбор'

   DO WHILE .NOT.fks08->(EOF())
      IF fks08->ddoc>=m_ddoc1.AND.fks08->ddoc<=m_ddoc2
         IF fks08->kpr<'100'
            m_sum1+=fks08->sum
            m_sum3+=fks08->glv
            m_sum4+=fks08->kvo
            m_sum5+=fks08->nds
            m_sum6+=fks08->aksbor
            m_sum7+=fks08->kvo2
         ELSE
            m_sum2+=fks08->sum
            m_sum3-=fks08->glv
            m_sum4-=fks08->kvo
            m_sum5-=fks08->nds
            m_sum6-=fks08->aksbor
            m_sum7-=fks08->kvo2
         ENDIF
      ENDIF
      @ 12,37 SayDisp m_sum1-m_sum2 PICTURE "99'999'999'999.99"
      @ 13,31 SayDisp m_sum1        PICTURE "99'999'999'999.99"
      @ 14,31 SayDisp m_sum2        PICTURE "99'999'999'999.99"
      @ 15,31 SayDisp m_sum3        PICTURE "99'999'999'999.99"
      @ 16,31 SayDisp m_sum7        PICTURE "99'999'999'999.99"
      @ 17,31 SayDisp m_sum4        PICTURE "99'999'999'999.99"
      @ 18,31 SayDisp m_sum5        PICTURE "99'999'999'999.99"
      @ 19,31 SayDisp m_sum6        PICTURE "99'999'999'999.99"
      fks08->(DBSKIP(1))
   ENDDO
   inkey(0)
   set escape off
   set cursor off
   restscreen(9,19,22,64,m_str)
   fks08->(DBGOTO(m_recno))
   SET COLOR TO ( MNU_CLR )
   SET CURSOR OFF
RETURN .T.
