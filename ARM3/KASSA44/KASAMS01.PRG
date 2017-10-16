#include "buh.ch"
MEMVAR m_workpath
MEMVAR m_sprpath
Function Ms01
  LOCAL a_struct1:={{"DDOC","D",8,0},{"ITOG","N",12,2}},;
        a_struct2:={{"DDOC","D",8,0},{"ITOG","N",12,2}},;
        i,m_ddoc1:=CTOD(""),m_ddoc2:=CTOD(""),m_ddoc1a,m_ddoc2a,;
        a_dbt:={},a_crt:={},n_field,m_alias,m_str,m_scht,;
        getlist:={}
        set escape on
        set cursor on
        m_str :=savescreen(9,19,16,64)
        SET COLOR TO  "N/BG+,N/W"
        DispBox(9,19,14,62,"w+/bg",B_SINGLE+" ",)
        Shadow(9,19,14,62)
        USE (m_workpath+"fks05") NEW READONLY
        m_ddoc1:=m_ddoc1a:=fks05->ddoc
        FKS05->(DBGOBOTTOM())
        m_ddoc2:=m_ddoc2a:=fks05->ddoc
        @ 10,20 say 'Отчет по оборотам кассы начиная с '
        @ 12,20 say 'по (включительно)                 '
        @ 11,39 get m_ddoc1  VALID m_ddoc1>=m_ddoc1a
        @ 13,39 get m_ddoc2  VALID m_ddoc2>=m_ddoc1.AND.m_ddoc2<=m_ddoc2a
        read
        IF LASTKEY()==K_ESC
            set escape off
            set cursor off
            restscreen(9,19,16,64,m_str)
            RETURN .F.
        ENDIF
        USE (m_workpath+"inst1") INDEX  (m_workpath+"inst1") new ALIAS myvar
        RESTMEM m_scht
        CLOSE myvar
        IF VALTYPE(m_scht)<>"C"
          m_scht:=""
        ENDIF
        DO WHILE m_ddoc1<=fks05->ddoc.AND..NOT.fks05->(BOF())
          IF m_ddoc2>=fks05->ddoc
            IF fks05->log=='1'
              IF ASCAN(a_dbt,{|x|(x[1]==IF(AT(LEFT(fks05->scht,2),m_scht)==0,fks05->scht,LEFT(fks05->scht,2)+"0"))})==0
                AADD(a_dbt,{IF(AT(LEFT(fks05->scht,2),m_scht)==0,fks05->scht,LEFT(fks05->scht,2)+"0"),0})
              ENDIF
            ELSE
              IF ASCAN(a_crt,{|x|(x[1]==IF(AT(LEFT(fks05->scht,2),m_scht)==0,fks05->scht,LEFT(fks05->scht,2)+"0"))})==0
                AADD(a_crt,{IF(AT(LEFT(fks05->scht,2),m_scht)==0,fks05->scht,LEFT(fks05->scht,2)+"0"),0})
              ENDIF
            ENDIF
          ENDIF
          fks05->(DBSKIP(-1))
        ENDDO
        IF .NOT.fks05->(BOF())
           fks05->(DBSKIP())
        ENDIF
        NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44") NEW READONLY
        ASORT(a_dbt,,,{|x,y|(x[1]<y[1])})
        AEVAL(a_dbt,{|x|AADD(a_struct1,{"S"+x[1],"N",12,2})})
        DBCREATE(m_workpath+"buf1",a_struct1)
        USE (m_workpath+"buf1") NEW
        ASORT(a_crt,,,{|x,y|(x[1]<y[1])})
        AEVAL(a_crt,{|x|AADD(a_struct2,{"S"+x[1],"N",12,2})})
        DBCREATE(m_workpath+"buf2",a_struct2)
        USE (m_workpath+"buf2") NEW
        AADD(a_dbt,{"xxx",0})
        AADD(a_crt,{"XXX",0})
        DO WHILE fks05->ddoc<=m_ddoc2.AND..NOT.fks05->(EOF())
          IF fks05->log=='1'
            m_alias:=SELECT('buf1')
          ELSE
            m_alias:=SELECT('buf2')
          ENDIF
          IF fks05->ddoc<>(m_alias)->ddoc
            (m_alias)->(DBAPPEND())
            (m_alias)->ddoc:=fks05->ddoc
          ENDIF
          n_field:=IF(fks05->log=="1",ASCAN(a_dbt,{|x|(x[1]==IF(AT(LEFT(fks05->scht,2),m_scht)==0,fks05->scht,LEFT(fks05->scht,2)+"0"))}),ASCAN(a_crt,{|x|(x[1]==IF(AT(LEFT(fks05->scht,2),m_scht)==0,fks05->scht,LEFT(fks05->scht,2)+"0"))}))
          IF fks05->log=="1"
            a_dbt[n_field,2]+=fks05->sum
            a_dbt[LEN(a_dbt),2]+=fks05->sum
          ELSE
            a_crt[n_field,2]+=fks05->sum
            a_crt[LEN(a_crt),2]+=fks05->sum
          ENDIF
          (m_alias)->(FIELDPUT(n_field+2,(m_alias)->(FIELDGET(n_field+2))+fks05->sum))
          (m_alias)->itog+=fks05->sum
          fks05->(DBSKIP())
        ENDDO
        USE (m_workpath+"dbrowse") NEW
        ZAP
        dbrowse->(DBAPPEND())
        dbrowse->value:="ddoc"
        dbrowse->heading:="ДАТА"
        dbrowse->footing:="ИТОГО"
        dbrowse->name:="buf1"
        FOR i:=1 TO LEN(a_dbt)-1
          dbrowse->(DBAPPEND())
          dbrowse->value:="S"+a_dbt[i,1]
          sp44->(DBSEEK(a_dbt[i,1]+"000"))
          dbrowse->heading:="СУБСЧЕТ;"+"  "+a_dbt[i,1]+";"+sp44->naim7
          dbrowse->footing:=SToStr1(a_dbt[i,2],12)
          dbrowse->name:="buf1"
        NEXT
        dbrowse->(DBAPPEND())
        dbrowse->value:="itog"
        dbrowse->heading:="ИТОГО ЗА ДЕНЬ"
        dbrowse->footing:= SToStr1(a_dbt[LEN(a_dbt),2],12)
        dbrowse->name:="buf1"
        dbrowse->(DBAPPEND())
        dbrowse->value:="ddoc"
        dbrowse->heading:="ДАТА"
        dbrowse->footing:="ИТОГО"
        dbrowse->name:="buf2"
        FOR i:=1 TO LEN(a_crt)-1
          dbrowse->(DBAPPEND())
          dbrowse->value:="S"+a_crt[i,1]
          sp44->(DBSEEK(a_crt[i,1]+"000"))
          dbrowse->heading:="СУБСЧЕТ;"+"  "+a_crt[i,1]+";"+sp44->naim7
          dbrowse->footing:=SToStr1(a_crt[i,2],12)
          dbrowse->name:="buf2"
        NEXT
        dbrowse->(DBAPPEND())
        dbrowse->value:="itog"
        dbrowse->heading:="ИТОГО ЗА ДЕНЬ"
        dbrowse->footing:= SToStr1(a_crt[LEN(a_crt),2],12)
        dbrowse->name:="buf2"
        CLOSE base dbrowse,FKS05,buf1,buf2
RETURN .T.
STATIC Function StoSTR1(x,m_len)
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
m_str+=IF(substr(s,17,2)=='00',"","-"+substr(s,17,2))
IF x<0
  m_str:="-"+m_str
ENDIF
IF m_len<>NIL.AND.m_len>0
   m_str:=IF(LEN(m_str)>m_len,REPLICATE("*",m_len),PADL(m_str,m_len))
ENDIF
RETURN m_str
Function viewms()
  LOCAL a_br1,a_br2,l_pr1:={},l_pr2:={},l_pr,order,m_key:=0,m_time,m_wait:=180
  LOCAL m_screen,m_recno,i,m_str
   LOCAL m_hor_width:=10,usl_hor_menu_clr:="N/W",sel_hor_menu:="n/bg+"
   LOCAL n_vert2:={},n_menu:=1,n_vert_menu:={},n_menu2:=1,m_col1,m_inkey
   LOCAL a_hor_menu:={" Строки"," Столбцы"," Изменение"," Печать"," Настройка"}
   LOCAL a_vert_menu:={{;
        "1 Вниз на одну строку      "+CHR(25)+"             " ,;
        "2 Вверх на одну строку     "+CHR(24)+"             " ,;
        "3 Вниз на один экран        Page Down     " ,;
        "4 Вверх на одину экран      Page Up       " ,;
        "5 На первую строку          Ctrl+Page Up  " ,;
        "6 На последнюю строку       Ctrl+Page Down"} ,;
       {"1 Вправо на один столбец              "+CHR(26)+"        " ,;
        "2 Влево на один столбец               "+CHR(27)+"        " ,;
        "3 Вправо на последний видимый столбец End      " ,;
        "4 Влево  на первый видимый столбец    Home     " ,;
        "5 На первый столбец                   Ctrl+End " ,;
        "6 На последний столбец                Ctrl+Home" ,;
        "7 Прокрутка вправо                    Ctrl+"+CHR(26)+"   " ,;
        "8 Прокрутка влево                     Ctrl+"+CHR(27)+"   " } ,;
       {"1 Переход на другую таблицу Tab"},;
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
                      K_CTRL_PGDN},;
                     {K_RIGHT,;
                      K_LEFT,;
                      K_END,;
                      K_HOME,;
                      K_CTRL_END,;
                      K_CTRL_HOME,;
                      K_CTRL_RIGHT,;
                      K_CTRL_LEFT},;
                     {K_TAB} ,;
                     {K_CTRL_P,;
                      K_CTRL_L,;
                      K_F9,;
                      K_CTRL_U},;
                     {K_ALT_L,;
                      K_F10}}
  USE (m_workpath+"buf1") NEW
  USE (m_workpath+"buf2") NEW
  USE (m_workpath+"dbrtb") INDEX (m_workpath+"dbrtb") NEW
  USE (m_workpath+"dbrowse") NEW
  crbrowse("buf1",@a_br1,@l_pr1)
  crbrowse("buf2",@a_br2,@l_pr2)
  m_hor_width:=INT(maxcol()/LEN(a_hor_menu))
  n_vert_menu:=Asize(n_vert_menu,LEN(a_hor_menu))
  aeval(n_vert_menu,{|x|x:=0})
  Asize(n_vert2,LEN(a_hor_menu))
  aeval(n_vert2,{|x|x:=0})
  i:=0
  AEVAL(a_hor_menu,{|x|SETPOS(0,i),DISPOUT(PADR(x,m_hor_width),usl_hor_menu_clr),i+=m_hor_width})
  SELECT buf1
  @a_br1:ntop-1,a_br1:nleft-1,a_br1:nbottom+1,a_br1:nright+1 BOX B_DOUBLE+" " COLOR "w/b"
  @a_br1:ntop-1,a_br1:nleft+5 SayDisp a_br1:cargo COLOR "w/b"
  SELECT buf2
  @a_br2:ntop-1,a_br2:nleft-1,a_br2:nbottom+1,a_br2:nright+1 BOX "╠═╣║╝═╚║ " COLOR "w/b"
  @a_br2:ntop-1,a_br2:nleft+5 SayDisp a_br2:cargo COLOR "w/b"
//  CLEAREOL(,0,"n/w")
  @MAXROW(),20 SayDisp "Переход ДЕБЕТ/КРЕДИТ - Tab   Mеню -  F8" COLOR usl_hor_menu_clr
  SELECT buf2
  a_br2:autoLite:=.f.
  STABILIZE BROWSE a_br2
  SELECT buf1
  STABILIZE BROWSE a_br1
  order:=a_br1
  l_pr:=l_pr1
   DO WHILE .T.
      m_key:=0
      DO WHILE .NOT.(order:stabilize()) .AND.((m_key:=inkey())==0)
      ENDDO
      IF m_key==0
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
         CASE m_key == K_DOWN           ;order:down()
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
         CASE m_key == K_F10            ; Calc()
          CASE m_key == K_TAB
              IF LOWER(ALIAS())="buf1"
                a_br1:autoLite:=.f.
                a_br1:dehilite()
                a_br1:refreshCurent()
                STABILIZE BROWSE order
                SELECT buf2
                a_br2:autoLite:=.t.
                order:=a_br2
                l_pr:=l_pr2
              ELSE
                a_br2:autoLite:=.f.
                a_br2:dehilite()
                a_br2:refreshCurent()
                STABILIZE BROWSE order
                SELECT buf1
                order:=a_br1
                a_br1:autoLite:=.t.
                l_pr:=l_pr1
              ENDIF
         CASE m_key == K_ESC .AND. ANSWER("   Завершить работу ?   " )==YES
               EXIT
         CASE m_key == K_CTRL_P.OR.m_key == K_F2
            m_recno:=RECNO()
            m_str:=""
//            IF OpenPrn(m_workpath+"kassa.prn")
            IF OpenPrn()
               IF PrintBrowse(order,l_pr)
               FOR i:=1 TO order:colCount
                IF l_pr[i]
                  m_col1:=order:getcolumn(i)
                  m_str+=PADL(m_col1:footing,order:colwidth(i)+1)
                ENDIF
              NEXT
               @PROW()+1,0 SAY REPLICATE("-",LEN(m_str))
               @PROW()+1,0 SAY m_str
               @PROW()+1,0 SAY REPLICATE("-",LEN(m_str))
               ENDIF
               ClosePrn()
               DBGOTO(m_recno)
            ENDIF
         CASE m_key == K_CTRL_L
                  SetLprint(@order,@l_pr)
         CASE m_key == K_CTRL_U
                  LSetprint()
         CASE m_key == K_F9
                  SetLpechat()
      ENDCASE
      order:refreshcurrent()
   ENDDO
RETURN .T.
STATIC FUNCTION crbrowse(m_tabl,my_browse,l_print)
  LOCAL m_col,m_block
dbrtb->(dbseek(m_tabl))
IF dbrtb->(FOUND())
  my_browse:=TBrowseDB(;
  IF(dbrtb->bt==0,2,dbrtb->bt),IF(dbrtb->lt==0,1,dbrtb->lt),;
    IF(dbrtb->tp==0,MAXROW()-2,dbrtb->tp),IF(dbrtb->nr==0,MAXCOL()-1,dbrtb->nr))
   my_browse:colorspec:=IF(EMPTY(dbrtb->clr),'W/B,B/W',dbrtb->clr)
   my_browse:colsep        := '│'
   my_browse:SkipBlock     := { |n| SkipOrder(n) }
   my_browse:goBottomBlock := { ||  DBGOBOTTOM() }
   my_browse:goTopBlock    := { ||  DBGOTOP()  }
   my_browse:freeze        := 1
   my_browse:cargo        := ALLTRIM(dbrtb->cargo)
ENDIF

DO WHILE .NOT.dbrowse->(EOF()).and.ALLTRIM(dbrowse->NAME)==m_tabl
   m_Col           := TBColumnNew()
   IF dbrowse->type=="N"
    m_col:block:=&("{||StoStr1(field->"+ALLTRIM(dbrowse->value)+",20)}")
    m_col:width      :=20
   ELSE
    m_col:block:=&("{||field->"+ALLTRIM(dbrowse->value)+"}")
   ENDIF
   m_col:heading:=ALLTRIM(dbrowse->heading)
   AADD(l_print,.T.)
   m_Col:colorblock:=  {|| {1,2}}
   m_col:colsep:="│"
   m_Col:headsep    := "┬─"
   m_Col:footsep    := "┴─"
   m_col:footing    :=ALLTRIM(dbrowse->footing)
   my_browse:addColumn( m_col )
   dbrowse->(dbskip(1))
ENDDO
RETURN (.T.)
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
RETURN (ncount)
