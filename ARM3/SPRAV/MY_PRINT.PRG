#include "new.ch"
#include "SET.ch"
#DEFINE N_PRINTER 1
#DEFINE N_PAPER 2
#DEFINE N_ZAG 3
#DEFINE N_SYMBOL 4
#DEFINE N_LINES 5
#DEFINE N_INIT_PRINTER  6
//Static a_par:={},a_prname:={},a_prvalue:={},m_page:=0,a_page:={}
Static a_par:={},a_prname:={},a_prvalue:={},m_page:=0
STATIC m_left_margin:=0,m_right_margin:=0,m_endpage:=60
MEMVAR m_syspath
FUNCTION PrintBrowse(browse,a_print,a_picture,var1)
LOCAL a_shp:={"┌","│","├","│","└"},;
      a_col:={},;
      p_col:={},a_width:={},;
      m_col,l_end,m_recno,m_proc,;
      m_shpka,i_str:=2,m_length:=1,m_max,i,j,l,i1,;
      x:=0,m_count:=IF(var1==NIL,LASTREC()+10,var1)
  LOCAL m_key1,m_key2,m_screen,Getlist:={}

FOR i:=1 TO browse:colCount
  If a_print==NIL.OR.(a_print<>NIL.AND.a_print[i]==.T.)
    m_col:=browse:getColumn(i)
    AADD(a_width,m_col:width)
    m_shpka:=m_col:heading+";"
    AADD(a_col,m_col:block)
    m_max:=0
    i_str:=2
    DO While   .NOT.EMPTY(m_shpka)
      j:=AT(";",m_shpka)
      IF(j>m_max+1,m_max:=j-1,NIL)
      If i_str>LEN(a_shp)-3
        AADD(a_shp,NIL)
        AINS(a_shp,i_str)
        a_shp[i_str]:=SPACE(m_length)
        FOR l:=1 TO LEN(a_shp[i_str-1])
          IF SUBSTR(a_shp[i_str-1],l,1)=="│"
            a_shp[i_str]:=STUFF(a_shp[i_str],l,1,"│")
          ENDIF
        ENDFOR
      EndIF
      a_shp[i_str]:=a_shp[i_str]+LEFT(m_shpka,j-1)
      i_str++
      m_shpka:=RIGHT(m_shpka,LEN(m_shpka)-j)
    EndDO
    IF a_picture<>NIL
    ENDIF
    m_max:=MAX(m_max,browse:colwidth(i))
    a_shp[1]+=REPLICATE("─",m_max)
    a_shp[LEN(a_shp)-2]+=REPLICATE("─",m_max)
    a_shp[LEN(a_shp)-1]+=PADC(STR(i,2),m_max)
    a_shp[LEN(a_shp)]+=REPLICATE("─",m_max)
//    AEVAL(a_shp,{|x|x:=PADR(x,m_length+m_max)+"│"},2,LEN(a_shp)-3)
    FOR l:=2 TO LEN(a_shp)-3
      a_shp[l]:=PADR(a_shp[l],m_length+m_max)+"│"
    NEXT
    AADD(p_col,m_length)
    m_length+=m_max+1
    a_shp[1]+="┬"
    a_shp[LEN(a_shp)-2]+="┼"
    a_shp[LEN(a_shp)-1]+="│"
    a_shp[LEN(a_shp)]+="┴"
  EndIF
NEXT
a_shp[1]:=STUFF(a_shp[1],LEN(a_shp[1]),1,"┐")
a_shp[LEN(a_shp)-2]:=STUFF(a_shp[LEN(a_shp)-2],LEN(a_shp[LEN(a_shp)-2]),1,"┤")
a_shp[LEN(a_shp)]:=STUFF(a_shp[LEN(a_shp)],LEN(a_shp[LEN(a_shp)]),1,"┘")
//EVAL(browse:gotopblock)
l_end:=.F.
IF .NOT.SetWidthPrn(m_length)
  RETURN .f.
ENDIF

IF GetParPrn(N_SYMBOL)==2
  FOR i:=1 TO LEN(a_shp)
    a_shp[i]:=CHARREPL("┌│├└┼┴┬─┘┤┐",a_shp[i],"-||-|----||")
  NEXT
ENDIF
m_recno:=RECNO()
i1:=ALERT("Друкувати",{"З першої строки","З поточної","Вибiркова","Вiдмовитися"},"n/bg,w/b" )
DO CASE
  CASE i1==1
    EVAL(browse:goTopBlock)
//    DBGOTOP()
    j:=1
    l:=LASTREC()
  CASE i1==2
//    j:=RECNO()
    j:=1
    l:=LASTREC()-RECNO()
   CASE i1==3
    m_screen  := SAVESCREEN(INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+6,77)
    m_key1:=&(INDEXKEY(0));m_key1:=BLANK(m_key1,.t.)
    m_key2:=&(INDEXKEY(0));m_key2:=BLANK(m_key2,.t.)
    @INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+5,75 BOX B_DOUBLE+" " COLOR "n/bg"
    @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( 'Введiть значення 1-го коду :', 68 ) COLOR "n/bg" PICTURE "@!"
    @INT((MAXROW()-4)/2)+2,(40-INT(LEN(m_key1)/2)) GET m_key1 COLOR ("b/w,gr+/n")
    @INT((MAXROW()-4)/2)+3,6 SayDisp PADC( 'Введiть значення 2-го коду :', 68 ) COLOR "n/bg" PICTURE "@!"
    @INT((MAXROW()-4)/2)+4,(40-INT(LEN(m_key2)/2)) GET m_key2 COLOR ("b/w,gr+/n")
    READ
    RESTSCREEN( INT((MAXROW()-4)/2), 5, INT((MAXROW()-4)/2)+6, 77, m_screen )
    IF(LASTKEY()!=K_ESC)
      m_key1:=ALLTRIM(m_key1)
      m_key2:=ALLTRIM(m_key2)
      IF .NOT.DBSEEK(m_key1,.t.)
        DispError(" Строка з "+m_key1+" значенням стовбця не знайдена ")
        DBGOTO(m_recno)
        RETURN .f.
      ENDIF
    ELSE
      RETURN .f.
    ENDIF
    j:=1
    l:=LASTREC()-RECNO()

OTHERWISE
  RETURN .f.
ENDCASE

m_proc := InitGauge("Друк таблицi ",2)
DO WHILE .T.
   IF SkipLinePrn(@a_shp,browse:cargo)
      FOR i:=1 TO LEN(a_col)
         IF PrnOnLine()
            IF a_width[i]==NIL
              @PROW(),p_col[i] SAY EVAL(a_col[i])
            ELSE
              @PROW(),p_col[i] SAY LEFT(EVAL(a_col[i]),a_width[i])
            ENDIF
         ELSE
            l_end:=.T.
            EXIT
         ENDIF
      NEXT
   ELSE
      l_end:=.T.
   ENDIF
   IF l_end
      EXIT
   ENDIF
   m_proc:=DispGauge(m_proc,j++/l)
  IF x>m_count
    EXIT
  ENDIF
   IF EVAL(browse:skipblock,1)<1
      EXIT
   ENDIF
//   dbskip(1)
   IF EOF()   //browse:hitbottom
      EXIT
   ENDIF
   IF .NOT.EMPTY(m_key2)
    m_key1:=&(INDEXKEY(0))
    IF LEFT(m_key1,LEN(m_key2))>m_key2
      EXIT
    ENDIF
   ENDIF
ENDDO
DelGauge(m_proc)
@PROW()+1,0 SAY ""
SETPRC(PROW(),0)
RETURN .T.

Function SetLprint(m_browse,l_print)
  LOCAL m_screen:=SAVESCREEN(4,4,MAXROW()-3,MAXCOL()-2),;
        a_browse:=TbrowseNew(5,5,MAXROW()-5,MAXCOL()-5),;
        a_shp:={},m_color:=SETCOLOR("n/bg"),m_first:=1,;
        m_col,i,m_row:=1,m_skip:=0

      a_shp:=ASIZE(a_shp,LEN(l_print))
      FOR i:=1 TO m_browse:colcount
        m_col:=m_browse:getColumn(i)
        a_shp[i]:=PADR(SUBSTR(CHARREPL(";",m_col:heading," "),1,40),40)
      NEXT
      m_col:=TBcolumnNew()
      m_col:block={||a_shp[m_row]}
      m_col:heading:="Назва стовбця"
      m_col:colsep:="│"
      m_col:headsep    := "─"
      m_col:footsep    := "─"
      a_browse:AddColumn(m_col)
      m_col:=TBcolumnNew()
      m_col:block:={||IF(l_print[m_row]," Да  "," Нет ")}
      m_col:heading:="Друкувати стовбець"
      m_col:colsep:="│"
      m_col:headsep    := "─"
      m_col:footsep    := "─"
      m_col:colorblock:={||IF(l_print[m_row],{1,2},{3,4})}
      a_browse:AddColumn(m_col)
      a_browse:Autolite:=.f.
      a_browse:colorspec:="n/bg,n/w,n/r,r/w"
      a_browse:skipBlock:={|m_count|;
        m_skip:=IF(m_count>=0,;
                IF(m_row+m_count>LEN(l_print),LEN(l_print)-m_row,m_count),;
                IF(m_row+m_count>=m_first,m_count,-m_row+m_first)),m_row+=m_skip,m_skip}
     @4,4,MAXROW()-4,MAXCOL()-4  BOX B_DOUBLE_SINGLE + SPACE(1)
     SHADOW(4,4,MAXROW()-4,MAXCOL()-4 )
     DO WHILE .T.
      DO WHILE .NOT.a_browse:stabilize()
      ENDDO
      a_browse:hilite()
      i:=inkey(0)
      a_browse:deHilite()
      DO CASE
        CASE i==K_DOWN
          a_browse:down()
        CASE i==K_UP
          a_browse:up()
        CASE i==K_ENTER.OR.CHR(i)==" "
          l_print[m_row]:=.NOT.l_print[m_row]
          a_browse:refreshCurrent()
        CASE i==K_ESC
          EXIT
        CASE i==K_CTRL_RET
          FOR i:=1 TO LEN(l_print)
            l_print[i]:=.t.
          NEXT
          a_browse:refreshAll()
      ENDCASE
    ENDDO
    SETCOLOR(m_color)
    RESTSCREEN(4,4,MAXROW()-3,MAXCOL()-2,m_screen)
    RETURN .t.


FUNCTION  Is_Ready_Prn(m_wait)
   LOCAL m_time:=seconds(),l_printer:=.T.,m_screen,m_pause
   IF m_wait==NIL
      m_pause:=5
   ELSE
      m_pause:=m_wait
   ENDIF
   DO WHILE .NOT.ISPRINTER()
      IF inkey()==K_ESC
         IF( ANSWER("Припинити друк , Ви впевненi?")==YES)
            IF .NOT.l_printer
               DelMessage(m_screen)
            ENDIF
            RETURN .F.
         ENDIF
      ENDIF
      IF SECONDS()-m_time>m_pause.AND.l_printer
         m_screen:=DispMessage("ПРИНТЕР НЕ ГОТОВ;ДО ДРУКУ",,.T.)
         l_printer:=.F.
      ENDIF
   ENDDO
   IF .NOT.l_printer
      DelMessage(m_screen)
   ENDIF
RETURN .T.
//
//╔══════════════════════════════════════════════════════════
//║ Функция:  (  )
//║ Автор: Воробьев Д.Л.
//║ Дата разработки: 23-04-93.
//║ Назначение:
//║
//║ Возвращает:
//║
//║ Параметры:
//║
//║ Используемые внешние переменные:
//║
//║ Используемые процедуры и функции:
//║
//║ Используемые файлы и внешние устройства:
//║
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

Function InitParPrn()
  LOCAL m_select:=SELECT(),i:=1
  USE (m_syspath+'pr01') NEW READONLY
  DBEVAL({||AADD(a_par,field->p02),AADD(a_prname,ALLTRIM(field->p01)),AADD(a_prvalue,""),i++})
  CLOSE pr01
  USE (m_syspath+'pr00') INDEX (m_syspath+'pr00') NEW READONLY
  FOR i:=1 TO LEN(a_par)
    DBSEEK(STRZERO(i,2)+STRZERO(a_par[i],2))
    IF FOUND()
      a_prvalue[i]:=FIELD->p03
    ENDIF
  NEXT
  CLOSE pr00
  m_endpage:=VAL(a_prvalue[N_LINES])
  SELECT(m_select)
RETURN .t.
Function SetParPrn(m_var,m_value)
  a_par[m_var]:=m_value
  RETURN .T.
Function GetParPrn(m_var)
  RETURN a_par[m_var]
Function SaveParPrn()
  LOCAL m_select:=SELECT(),i:=1
  USE (m_syspath+'pr01') NEW
  DBEVAL({||Field->p02:=a_par[i++]})
  CLOSE pr01
  SELECT(m_select)
RETURN .T.
Function  SetWidthPrn(m_width)
  LOCAL a_shrift:={},a_choice:={},m_shrift1:=0,m_shrift2:=0,m_shrift:=0,;
        i:=0,m_select:=SELECT(),n_shrift:=0,m_screen,m_color

        m_shrift:=STR(GetParPrn(N_PRINTER),1)
        USE (m_syspath+'pr02') INDEX (m_syspath+'pr02') NEW READONLY // Файл шрифтов
        DBSEEK(m_shrift)
        IF .NOT.FOUND()
          WaitMessage("Принтер не визначен "+m_shrift+";"+"Друк неможливий","w+/r,GR+/R",.t.)
          CLOSE pr02
          SELECT(m_select)
          RETURN .f.
        ENDIF
        DBEVAL({||AADD(a_shrift,{Field->p03,ALLTRIM(Field->p04)}),AADD(a_choice,Field->p02)},,{||Field->p01=m_shrift})
        CLOSE pr02
        SELECT(m_select)
        //Выбор шрифта
        i:=1
        AEVAL(a_shrift,{|x|IF(m_shrift1==0.AND.m_width<=8*x[1],m_shrift1:=i,0),;
                          IF(m_shrift2==0.AND.m_width<=13.6*x[1],m_shrift2:=i,0),i++})

        IF m_shrift1==0
          IF m_shrift2==0
            m_shrift:="НЕ РОЗМIЩАЄТЬСЯ"
            n_shrift:=LEN(a_shrift)
          ELSE
            m_shrift:=" широка "
            n_shrift:=m_shrift2
          ENDIF
        ELSE
          IF a_shrift[m_shrift1,1]<=15
            m_shrift:=" вузька "
            n_shrift:=m_shrift1
          ELSE
            m_shrift:=" широка "
            n_shrift:=m_shrift2
          ENDIF
        ENDIF
// Выбор пользователя
        DO WHILE .t.
          i:=ALERT(;
          "Потрiбна "+m_shrift+"бумага     "+";"+;
          "Ширина каретки "+STR(CEILING(m_width*10/a_shrift[n_shrift,1]),4)+" подiлок;"+;
          "Шрифт "+a_choice[n_shrift]+";"+;
          "Кiлькiсть друкуємих символiв - "+STR(m_width,4),;
          {"Друкувати","Змiнити шрифт","Не виставлявати шрифт","Вiдмова"},"N/BG,GR+/N")
          DO CASE
            CASE i==0.OR.i==4
              RETURN .f.
            CASE i==1
              IF PrnOnLine()
                SETPRC(0,0)
                m_shrift1:=''
                FOR i:=1 TO LEN(a_shrift[n_shrift,2])/2
                  m_shrift1+=CHR(VAL(SUBSTR(a_shrift[n_shrift,2],2*i-1,2)))
                NEXT
                @0,0 Say m_shrift1
                SETPRC(0,0);m_page:=1
                RETURN .t.
              ELSE
                RETURN .f.
              ENDIF
            CASE i==2
              m_shrift1:=INT((MAXROW()-LEN(a_shrift))/2)-1
              m_shrift2:=0
              AEVAL(a_choice,{|x|IF(LEN(x)>m_shrift2,m_shrift2:=LEN(x),0)})
              m_select:=INT((MAXCOL()-m_shrift2)/2)-1
              m_screen:=SAVESCREEN(m_shrift1,m_select,m_shrift1+LEN(a_choice)+4,m_select+m_shrift2+4)
              @ m_shrift1,m_select,m_shrift1+LEN(a_choice)+2,m_select+m_shrift2+2 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( "w/b" )
              SHADOW(m_shrift1,m_select,m_shrift1+LEN(a_choice)+2,m_select+m_shrift2+2)
              m_color:=SETCOLOR("w/b,n/w")
              i:=ACHOICE (m_shrift1+1,m_select+1,m_shrift1+LEN(a_choice)+1,m_select+m_shrift2+1,A_CHOICE,,,n_shrift,0)
              RESTSCREEN(m_shrift1,m_select,m_shrift1+LEN(a_choice)+4,m_select+m_shrift2+4,m_screen)
              SETCOLOR(m_color)
              IF i<>0.AND.LASTKEY()==K_ENTER
                n_shrift:=i
                m_shrift:=IF(m_width/a_shrift[i,1]<=8," вузька  ",IF(m_width/a_shrift[i,1]<=13.6," широка  "," НЕ РОЗМIЩАЄТЬСЯ !!!"))
                LOOP
              ENDIF
             CASE i==3
              RETURN .t.;m_page:=1
          ENDCASE
        ENDDO
   m_page:=1
RETURN .T.
#define MyPause()  IF INKEY()==K_ESC.AND. ANSWER("Прервати друк ?")==YES;IF(m_screen<>NIL,DelMessage(m_screen),.t.);RETURN .F. ;END
Function PrnOnLine(m_wait)
   LOCAL m_screen,m_key,m_pause:=IF(m_wait==NIL,5,m_wait),m_time
   IF EMPTY(SET(_SET_PRINTFILE))
        IF .NOT.PRINTREADY()
          m_time:=SECONDS()
          DO WHILE ABS(SECONDS()-m_time)<m_pause.AND..NOT.PRINTREADY()
          MyPause()
          ENDDO
          IF PRINTREADY()
            RETURN .t.
          ENDIF
          m_screen:=DispMessage("Принтер не готов;Установите принтер в положение ON LINE","w/r,gr+/r",.t.)
          DO WHILE .NOT.PRINTREADY()
          MyPause()
          ENDDO
          DelMessage(m_screen)
      ENDIF
    ELSE
          MyPause()
    ENDIF
RETURN .T.
#undef  MyPause
STATIC Function SetLinePrn()
  LOCAL m_line,GetList:={}
  SAVEPAR()
    @1,2,MAXROW()-1,MAXCOL()-2 BOX B_DOUBLE+" " COLOR "w+/b"
    @2,4 SayDisp "Довжина сторiнки в рядках" COLOR "gr+/b"
    m_line:=GetEndPage()+3
    SET ESCAPE ON
    @3,8 Get m_line VALID m_line>1.AND.m_line<127 COLOR "gr+/n"
    READ
    IF LASTKEY()<>K_ESC
    SendToPrint(CHR(27)+"C"+CHR(m_line))
    ENDIF
  SAVEPAR(1)
  RETURN .t.
Function lSetprint()
  LOCAL m_select:=SELECT(),m_color:=SETCOLOR("n/bg,n/w"),m_cursor:=SETCURSOR(0),;
        m_printer,m_par,m_width,m_width1:=0,m_width2:=0,;
        i,m_row:=1,a_prompt:={},a_value:={},n_wind1,n_wind2,;
        a_br,m_col,m_skip ,a_parametr:={},m_esc
        SavePar()

        USE (m_syspath+'pr04') INDEX (m_syspath+'pr04') NEW READONLY // Файл наименований параметров
        USE (m_syspath+'pr03') INDEX (m_syspath+'pr03') NEW READONLY // Файл значений и ESC последовательностей параметров
        m_printer:=STR(GetParPrn(N_PRINTER),1)
        DBSEEK(m_printer)
        IF .NOT.FOUND()
          WaitMessage("Принтер не визначен "+m_printer+";"+"Друк неможливий","w/r,GR+/R",.t.)
          CLOSE pr04
          CLOSE pr03
          SELECT(m_select)
          SETCOLOR(m_color)
          RETURN .f.
        ENDIF
        DO WHILE pr03->p01==m_printer.AND..NOT.pr03->(EOF())
          pr04->(DBSEEK(pr03->p02))
          AADD(a_prompt,IF(pr04->(FOUND()),ALLTRIM(pr04->p02),"Без назви"))
          m_par:=pr03->p02
          AADD(a_value,{})
          DO WHILE m_par==pr03->p02.AND.pr03->p01==m_printer.AND..NOT.pr03->(EOF())
            AADD(a_value[LEN(a_value)],{ALLTRIM(pr03->p03),ALLTRIM(pr03->p04)})
            pr03->(DBSKIP())
          ENDDO
        ENDDO
        CLOSE pr04
        CLOSE pr03
        AEVAL(a_prompt,{|x|m_width1:=MAX(LEN(x),m_width1)})
        AEVAL(a_value,{|x|AEVAL(x,{|y|m_width2:=MAX(m_width2,LEN(y[1]))})})
        a_parametr:=ARRAY(LEN(a_prompt))
        AFILL(a_parametr,1)
//        wboard(0,0,maxrow(),maxcol())
        wsetshadow('n+')
        n_wind1:=wopen(0,0,MIN(MAXROW()-6,LEN(a_parametr)+4),MAXCOL()-10)
        wbox(2)
        wcenter(.t.)
        wmode(.t.,.f.,.f.,.f.)
        @-1,1 SayDisp "Параметри принтера "+a_prvalue[N_PRINTER]
        @MAXROW(),0 SayDisp PADR("Пробiл - змiнити,F9 установити параметр,ALT+F9 установити усi",MAXCOL()-1) COLOR "b/bg"
        a_br:=TbrowseNew(0,0,MAXROW()-1,MAXCOL())
        m_col:=TBcolumnNew()
        m_col:block={||a_prompt[m_row]}
        m_col:heading:="     Параметр  "
        m_col:colsep:="│"
        m_col:headsep    := "─"
//        m_col:footsep    := "─"
        m_col:width:=MAX(m_width1,LEN(m_col:Heading))
        a_br:AddColumn(m_col)
        m_col:=TBcolumnNew()
        m_col:block:={||a_value[m_row,a_parametr[m_row],1]}
        m_col:heading:=" Значення параметру"
        m_col:colsep:="│"
        m_col:headsep    := "─"
//        m_col:footsep    := "─"
        m_col:width:=MAX(m_width2,LEN(m_col:Heading))
        a_br:AddColumn(m_col)
        a_br:colorspec:="n/bg,n/w"
        a_br:skipBlock:={|m_count|;
        m_skip:=IF(m_count>=0,;
                IF(m_row+m_count>LEN(a_parametr),LEN(a_parametr)-m_row,m_count),;
                IF(m_row+m_count>0,m_count,1-m_row)),m_row+=m_skip,m_skip}
      DO WHILE .T.
        STABILIZE BROWSE a_br
        a_br:colorRect({a_br:RowPos,1,a_br:RowPos,a_br:colCount},{2,1})
        i:=inkey(0)
        a_br:colorRect({a_br:RowPos,1,a_br:RowPos,a_br:colCount},{1,2})
        DO CASE
          CASE i==K_DOWN
            a_br:down()
          CASE i==K_UP
            a_br:up()
          CASE i==K_PGUP
            a_br:pageup()
          CASE i==K_PGDN
            a_br:pagedown()
          CASE CHR(i)==" ".OR.i==K_ENTER //.OR.CHR(i)=='+'

            IF m_row==2.AND.i==K_ENTER
              SetLinePrn()
            ELSE
              a_parametr[m_row]:=IF(a_parametr[m_row]==LEN(a_value[m_row]),1,a_parametr[m_row]+1)
            ENDIF

            a_br:refreshCurrent()
          case i==K_F9
              m_esc:=''
              FOR i:=1 TO LEN(a_value[m_row,a_parametr[m_row],2])/2
                m_esc+=CHR(VAL(SUBSTR(a_value[m_row,a_parametr[m_row],2],2*i-1,2)))
              NEXT
              SendToPrint(m_esc)
          case i==K_ALT_F9
              m_esc:=''
              FOR m_width1:=1 TO LEN(a_parametr)
              FOR i:=1 TO LEN(a_value[m_width1,a_parametr[m_width1],2])/2
                m_esc+=CHR(VAL(SUBSTR(a_value[m_width1,a_parametr[m_width1],2],2*i-1,2)))
              NEXT
              NEXT
              SendToPrint(m_esc)
          CASE i==K_ESC
            EXIT
        ENDCASE
      ENDDO
      WCLOSE()
      WSELECT(0)
      SETCOLOR(m_color)
      SELECT(m_select)
      SETCURSOR(m_cursor)
      SavePar(1)
      RETURN .t.
Function SendToPrint(m_str,m_wait)
        LOCAL m_screen,i,m_key,m_time:=SECONDS(),m_pause:=If(m_wait==NIL,90,m_wait)
        FOR i:=1 TO LEN(m_str)
          IF .NOT.Is_Ready_Prn(m_pause)
            RETURN .f.
          ENDIF
          PRINTSEND(SUBSTR(m_str,i,1))
        NEXT
    RETURN .T.

Function StrToPrn(m_str,m_wait)
        LOCAL m_screen,i,m_key,m_time:=SECONDS(),m_pause:=If(m_wait==NIL,90,m_wait)
        FOR i:=1 TO LEN(m_str)
          IF .NOT.PrnOnLine(m_pause/LEN(m_str))
            RETURN .f.
          ENDIF
          @PROW(),PCOL() SAY SUBSTR(m_str,i,1)
        NEXT
    RETURN .T.

Function SetLpechat()
  LOCAL m_select:=SELECT(),m_color:=SETCOLOR("n/bg,n/w"),m_cursor:=SETCURSOR(0),;
        m_par,m_width,m_width1:=0,m_width2:=0,m_esc:=SET(_SET_ESCAPE,.t.),;
        i,m_row:=1,a_value:={},n_wind1,n_wind2,m_buf,;
        a_br,m_col,m_skip ,GetList:={}
      SavePar()
        USE (m_syspath+'pr01') INDEX (m_syspath+'pr01') NEW  // Файл параметров
        USE (m_syspath+'pr00') INDEX (m_syspath+'pr00') NEW READONLY // Файл значений параметров
        DO WHILE .NOT.pr00->(EOF())
          m_par:=pr00->p01
          AADD(a_value,{})
          DO WHILE m_par==pr00->p01.AND. .NOT.pr00->(EOF())
            AADD(a_value[LEN(a_value)],ALLTRIM(pr00->p03))
            pr00->(DBSKIP())
          ENDDO
        ENDDO
        CLOSE pr00

        AEVAL(a_prname,{|x|m_width1:=MAX(LEN(x),m_width1)})
        AEVAL(a_value,{|x|AEVAL(x,{|y|m_width2:=MAX(m_width2,LEN(y))})})
        wsetshadow('n+')
        n_wind1:=wopen(0,0,MIN(MAXROW()-6,LEN(a_prname)+4),MAXCOL()-10)
        wbox(2)
        wcenter(.t.)
        wmode(.t.,.f.,.f.,.f.)
        @-1,1 SayDisp "Параметри друку "
        @MAXROW(),0 SayDisp PADR("Пробiл - змiнити,F9 зберегти параметр,ALT+F9 зберегти усi",MAXCOL()-1) COLOR "b/bg"
        a_br:=TbrowseNew(0,0,MAXROW()-1,MAXCOL())
        m_col:=TBcolumnNew()
        m_col:block={||a_prname[m_row]}
        m_col:heading:="         Параметр  "
        m_col:colsep:="│"
        m_col:headsep    := "┬─"
//        m_col:footsep    := "─"
        m_col:width:=MAX(m_width1,LEN(m_col:Heading))
        a_br:AddColumn(m_col)
        m_col:=TBcolumnNew()
        m_col:block:={||a_prvalue[m_row]}
        m_col:heading:=" Значення параметру"
        m_col:colsep:="│"
        m_col:headsep    := "┬─"
//        m_col:footsep    := "─"
        m_col:width:=MAX(m_width2,LEN(m_col:Heading))
        a_br:AddColumn(m_col)
        a_br:colorspec:="n/bg,n/w"
        a_br:skipBlock:={|m_count|;
        m_skip:=IF(m_count>=0,;
                IF(m_row+m_count>LEN(a_par),LEN(a_par)-m_row,m_count),;
                IF(m_row+m_count>0,m_count,1-m_row)),m_row+=m_skip,m_skip}
            a_br:right()
      DO WHILE .T.
        DO WHILE .NOT.a_br:stabilize()
        ENDDO
        a_br:colorRect({a_br:RowPos,1,a_br:RowPos,a_br:colCount},{2,1})
        i:=inkey(0)
        a_br:colorRect({a_br:RowPos,1,a_br:RowPos,a_br:colCount},{1,2})
        DO CASE
          CASE i==K_DOWN
            a_br:down()
          CASE i==K_UP
            a_br:up()
          CASE i==K_PGUP
            a_br:pageup()
          CASE i==K_PGDN
            a_br:pagedown()
          CASE CHR(i)==" ".OR.i==K_ENTER //.OR.CHR(i)=='+'
            IF m_row==N_LINES.AND.i==K_ENTER
              DO WHILE .NOT.a_br:stabilize()
              ENDDO
              SET CURSOR ON
              m_buf:=VAL(a_prvalue[m_row])
              KEYBOARD ""
              @row(),COL() GET m_buf VALID m_buf>10 PICTURE "999" COLOR "GR+/N"
              READ
              SET CURSOR OFF
              IF LASTKEY()<>K_ESC
                a_prvalue[m_row]:=STR(m_buf,3)+" "+SUBSTR(a_prvalue[m_row],5)
                a_value[m_row,a_par[m_row]]:=a_prvalue[m_row]
                m_endpage:=m_buf
                a_br:refreshCurrent()
              ENDIF
            ELSE
              a_par[m_row]:=IF(a_par[m_row]==LEN(a_value[m_row]),1,a_par[m_row]+1)
              a_prvalue[m_row]:=a_value[m_row,a_par[m_row]]
              a_br:refreshCurrent()
              m_endpage:=VAL(a_prvalue[N_LINES])
//              m_endpage:=VAL(a_prvalue[m_row])
            ENDIF
          case i==K_F9
            pr01->(DBGOTOP())
            pr01->(DBSKIP(m_row-1))
            pr01->p02:=a_par[m_row]
          case i==K_ALT_F9
              pr01->(DBGOTOP())
              FOR m_width1:=1 TO LEN(a_par)
                pr01->p02:=a_par[m_width1]
                pr01->(DBSKIP(1))
              NEXT
          CASE i==K_ESC
            EXIT
        ENDCASE
      ENDDO
      WCLOSE()
      SETCOLOR(m_color)
      SELECT(m_select)
      SETCURSOR(m_cursor)
      SET(_SET_ESCAPE,m_esc)
      CLOSE pr01
      SavePar(1)
      RETURN .t.

Function OpenPrn(m_var)
  LOCAL i,j
//  LOCAL a_page:={ 69,62,43,92,83,58}
  IF .NOT.EMPTY(m_var)
     SET PRINTER TO (m_var)
  ENDIF
//  m_endpage:=a_page[a_par[N_LINES]]
  m_endpage:=VAL(a_prvalue[N_LINES])
  m_page:=1
  SET DEVICE TO PRINTER
  IF PrnOnLine()
    IF a_par[N_INIT_PRINTER]==1
      IF EMPTY(SET(_SET_PRINTFILE))
         PrintInit(1,.t.)
        ELSE
         DEVOUT(CHR(27)+"@")
        ENDIF
    ENDIF
  ELSE
    RETURN .f.
  ENDIF
  IF PrnOnLine()
    IF a_par[N_PRINTER]==3
       RUN ("lfont 8")
    ENDIF
  ELSE
    RETURN .f.
  ENDIF
  SETPRC(0,0)
  RETURN .t.
FUNCTION  SkipLinePrn(a_shapka,m_name)
   LOCAL i:=0,j:=LEN(a_shapka[1]),k:=1
   IF PROW()>=m_endpage+1
       StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
       SETPRC(0,0)
   ENDIF
   IF PROW()==0
     IF a_par[N_PAPER]==2.AND.EMPTY(SET(_SET_PRINTFILE)) //ЛИСТЫ
       WaitMessage("Заправьте лист N "+STR(m_page,3)+";и нажмите любую клавишу")
     ENDIF
     IF a_par[N_ZAG]==1.OR.(a_par[N_ZAG]==2.AND.m_page==1)
      IF PrnOnLine()
         @0,0 SAY DATE()
         IF .NOT.EMPTY(m_name)
             k:=j-10-PCOL()-3
             @0,PCOL()+2 SAY PADC(SUBSTR(ALLTRIM(m_name),1,k),k)
         ENDIF
         @0,j-10 SAY "Лист N" +STR(m_page++,3)
         IF .NOT.EMPTY(SUBSTR(ALLTRIM(m_name),k+1))
          @1,j-k-10-3 SAY PADC(SUBSTR(ALLTRIM(m_name),k+1,k),k)
         ENDIF
         FOR i:=1 TO LEN(a_shapka)
            IF PrnOnLine()
               @PROW()+1,0  SAY a_shapka[i]
            ELSE
               RETURN .F.
            ENDIF
         NEXT
      ELSE
         RETURN .F.
      ENDIF
     ENDIF
   ENDIF
   IF PrnOnLine()
      DEVPOS(PROW()+1,0)
   ELSE
      RETURN .F.
   ENDIF
  RETURN .t.

Function ClosePrn()
  IF .NOT.PROW()==0
    @PROW()+1,0 SAY ""
    SETPRC(0,0)
  ENDIF
  IF .NOT.EMPTY(SET(_SET_PRINTFILE))
    SET PRINTER TO
  ENDIF
  SET DEVICE TO SCREEN
  m_page:=1
  RETURN .t.
Function GetEndPage()
RETURN m_endpage
Function CountLines()
  LOCAL j:=40,i:=-1,k:=1
  IF Is_Ready_Prn(2)
    PRINTSEND(CHR(27)+"9")
    inkey(2)
    DO WHILE .T.
      IF PRINTREADY().AND..NOT.ISBIT(PRINTSTAT(1),6)
//       PRINTSEND(SPACE(40))
       i++
       PRINTSEND(CHR(27)+"<")
       PRINTSEND(STR(i,10)+CHR(13)+CHR(10))
       inkey(IF(i>25,k,0.5))
      ELSE
        EXIT
      ENDIF
    ENDDO
    i-=2
    a_prvalue[N_LINES]:=STR(i,3)+" "+SUBSTR(a_prvalue[N_LINES],5)
    m_endpage:=i
//    PRINTSEND(CHR(27)+"9")
//       PRINTSEND(CHR(27)="U"+CHR(0))
    RETURN .t.
  ENDIF
RETURN .f.
Function FileToLpt1(m_file,m_name)
  LOCAL m_num,m_buf:=SPACE(4096),n,k:=FILESIZE(m_file),j:=0,;
  m_gauge:=InitGauge("Друк  "+IF(m_name==NIL,"",m_name),2)
  m_num:=FOPEN(m_file,0)
  DO WHILE .T.
    n:=FREAD(m_num,@m_buf,4096)
    PRINTSEND(SUBSTR(m_buf,1,n))
    IF n<>4096
      EXIT
    ENDIF
    j+=n
    m_gauge:=DispGauge(m_gauge,j/k)
  ENDDO
  FCLOSE(m_num)
  DelGauge(m_gauge)
RETURN .t.
FUNCTION FileToPrn(m_file,m_name)
  LOCAL m_num,m_buf:=SPACE(4096),n,k:=FILESIZE(m_file),j:=0,;
  m_gauge:=InitGauge("Друк  "+IF(m_name==NIL,"",m_name),2)
  m_num:=FOPEN(m_file,0)
  DO WHILE .T.
    n:=FREAD(m_num,@m_buf,4096)
    IF .NOT.SendToPrint(SUBSTR(m_buf,1,n))
      FCLOSE(m_num)
      DelGauge(m_gauge)
      RETURN .f.
    ENDIF
    IF n<>4096
      EXIT
    ENDIF
    j+=n
    m_gauge:=DispGauge(m_gauge,j/k)
  ENDDO
  FCLOSE(m_num)
  DelGauge(m_gauge)
RETURN .t.
Function SetShapka(a_shapka)
  LOCAL i,n:=LEN(a_shapka)
IF GetParPrn(N_SYMBOL)==2
  FOR i:=1 TO n
    a_shapka[i]:=CHARREPL("┌│├└┼┴┬─┘┤┐",a_shapka[i],"-||-|----||")
  NEXT
ENDIF
RETURN a_shapka
Function ClearPrn()
  LOCAL i,n:=SPOOLCOUNT(),m_str:="В черзi на друк знаходяться файли"
  LOCAL a_choice:={}
  IF n==0
    WaitMessage("Черга спулера друку пуста")
    RETURN .t.
  ENDIF
  FOR i:=1 TO n
    m_str+=";"+STR(i,2)+" "+SPOOLENTRY(i)
  NEXT
  i:=ALERT(m_str,{"Очистити чергу","Удалити з черги файл","Вихiд"},"n/bg,w/b")
  DO CASE
      CASE i==1
        SPOOLFLUSH()
      CASE i==2
        FOR i:=1 TO n
           AADD(a_choice,STR(i,2)+" "+SPOOLENTRY(i))
        NEXT
        i:=MyMenu("Виберiть файл",a_choice)
        IF i>0
          SPOOLDEL(SUBSTR(a_choice[i],4))
        ENDIF
    ENDCASE
SPOOLACTIVE()
RETURN .t.
FUNCTION MyPrintFile(m_file)
  IF SPOOLACTIV().AND.SPOOLCOUNT()<8
      SPOOLADD(m_file)
  ELSE
    IF VAL(osver())<>6.22
      fileToLpt1(m_file)
      PRINTSEND(CHR(K_CTRL_L))
    ELSE
      FileToPrn(m_file)
    ENDIF
  ENDIF
return .F.
