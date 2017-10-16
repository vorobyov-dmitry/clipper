#include "menu.ch"
#include "new.ch"
// #include "setcurs.ch"
MEMVAR m_mash,m_temppath,m_level,m_syspath,m_workpath,m_sprpath,p_npr,m_tabn
STATIC lApnd:=.f.
Function Schet
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,n_win1,m_col,m_ddoc,m_file
  LOCAL m_exit:=READEXIT(.T.),l_stop:=.t.
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={},m_buf
  LOCAL a_get1:={},a_data1:={},n_pole1,m_block,a_say1:={},a_brgd:={}
  LOCAL m_browse1,m_vnum,m_ndoc,m_valid,m_valid1,a_dop:={},a_spr01:={},l_firstline:=.t.,m
  LOCAL m_browse2,m_get1b,m_state:="0",m_col1b,a_fam:={},m_sum,m_nds,m_date
  DCL MENU
  DCL LIST
  LOCAL m_select:=SELECT(),a_saydop:={},;
  a_block:={},a_pred01:={}
  InitNds()
  Lapnd:=.f.
  setblink(.f.)
    SopenFiles("100",@s_files)
    OpenFl3()
  SETKEY(K_F4,{||firm01->(firm01(@a_data)),a_get[n_pole]:updateBuffer(),k:=n_pole,n_pole:=1,AEVAL(a_get,{|x|a_get[n_pole]:display(),n_pole++}),n_pole:=k})
  NET USE (m_workpath+"scht1") INDEX (m_workpath+"scht1"),(m_workpath+"scht1a") NEW ALIAS scht1
  a_pred01:={ALLTRIM(pred01->Full1),pred01->okpo,;
             ALLTRIM(pred01->Addr1)+" "+ALLTRIM(pred01->Addr2),;
 {pred01->rasch,ALLTRIM(pred01->Bank1)+" "+ALLTRIM(pred01->Bank2),pred01->mfo}}
  a_pred01[1]:=PADR(SUBSTR(a_pred01[1],1,LEN(scht1->full)),LEN(scht1->full))
  a_pred01[2]:=PADR(SUBSTR(a_pred01[2],1,LEN(scht1->okpo)),LEN(scht1->okpo))
  a_pred01[3]:=PADR(SUBSTR(a_pred01[3],1,LEN(scht1->addr)),LEN(scht1->addr))
  a_pred01[4][1]:=PADR(SUBSTR(a_pred01[4][1],1,LEN(scht1->rasch)),LEN(scht1->rasch))
  a_pred01[4][2]:=PADR(SUBSTR(a_pred01[4][2],1,LEN(scht1->bank)),LEN(scht1->bank))
  a_pred01[4][3]:=PADR(SUBSTR(a_pred01[4][3],1,LEN(scht1->mfo)),LEN(scht1->mfo))
  IF .NOT.EMPTY(pred01->rasch1)
    AADD(a_pred01,{pred01->rasch1,ALLTRIM(pred01->Bank1a)+" "+ALLTRIM(pred01->Bank2a),pred01->mfo1})
    a_pred01[5][1]:=PADR(SUBSTR(a_pred01[5][1],1,LEN(scht1->rasch)),LEN(scht1->rasch))
    a_pred01[5][2]:=PADR(SUBSTR(a_pred01[5][2],1,LEN(scht1->bank)),LEN(scht1->bank))
    a_pred01[5][3]:=PADR(SUBSTR(a_pred01[5][3],1,LEN(scht1->mfo)),LEN(scht1->mfo))
    IF .NOT.EMPTY(pred01->rasch2)
      AADD(a_pred01,{pred01->rasch2,ALLTRIM(pred01->Bank1b)+" "+ALLTRIM(pred01->Bank2b),pred01->mfo2})
      a_pred01[6][1]:=PADR(SUBSTR(a_pred01[6][1],1,LEN(scht1->rasch)),LEN(scht1->rasch))
      a_pred01[6][2]:=PADR(SUBSTR(a_pred01[6][2],1,LEN(scht1->bank)),LEN(scht1->bank))
      a_pred01[6][3]:=PADR(SUBSTR(a_pred01[6][3],1,LEN(scht1->mfo)),LEN(scht1->mfo))
      IF .NOT.EMPTY(pred01->rasch3)
        AADD(a_pred01,{pred01->rasch3,ALLTRIM(pred01->Bank1c)+" "+ALLTRIM(pred01->Bank2c),pred01->mfo3})
        a_pred01[7][1]:=PADR(SUBSTR(a_pred01[7][1],1,LEN(scht1->rasch)),LEN(scht1->rasch))
        a_pred01[7][2]:=PADR(SUBSTR(a_pred01[7][2],1,LEN(scht1->bank)),LEN(scht1->bank))
        a_pred01[7][3]:=PADR(SUBSTR(a_pred01[7][3],1,LEN(scht1->mfo)),LEN(scht1->mfo))
      ENDIF
    ENDIF
  ENDIF
  INIT GET "SCHT1" TO a_get KEY n_pole DATA a_data SAY a_say
  a_say[1]:={{K_F3,{||GetPr01(@a_pred01,@a_data),k:=n_pole,n_pole:=1,AEVAL(a_get,{|x|a_get[n_pole]:display(),n_pole++}),n_pole:=k}}}
//  a_say[8]:={{ASC("?"),{||firm01->(firm01(@a_data)),a_get[n_pole]:updateBuffer(),k:=n_pole,n_pole:=1,AEVAL(a_get,{|x|a_get[n_pole]:display(),n_pole++}),n_pole:=k}}}
//  a_say[5]:={{ASC("?"),{||sp10->(sp10(@a_fam,@a_data)),a_get[5]:upDateBuffer()}}}
  NET USE (m_workpath+"scht2") INDEX (m_workpath+"scht2")     NEW ALIAS scht2
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  CrList1("SCHT1",@m_browse,@l_print)
  n_win1:=InitScr("SCHT1")
  a_get1:=CrGet("SCHT2",a_say1)
  m_browse1               := TBrowseDB(11,1,MAXROW()-3,MAXCOL()-1)
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_browse1:colsep        := '│'
  m_browse1:SkipBlock     := {|n| SkipDb1(n,{||(scht1->vnum==scht2->vnum)},lApnd) }
  m_browse1:goBottomBlock := {||scht2->(DBSEEK(scht1->vnum,.f.)),scht2->(DBEVAL(,,{||(scht1->vnum==scht2->vnum)})),scht2->(dbskip(-1))}
  m_browse1:goTopBlock    := {||scht2->(DBSEEK(scht1->vnum,.f.))}
  CrBrCol("SCHT2",@m_browse1)
  i:=1;AEVAL(a_get1,{|x|a_get1[i]:block:=m_browse1:GetColumn(i):Block,;
  m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──"),i++})
  a_say1[1]={{ASC("?"),{||kaptka_vl(a_get1[1],a_data[3],@a_dop)}},{K_F2,{||Printscht(a_data)}}}
  a_get1[10]:Block:={|x|IF(x==NIL,scht2->stm+scht2->nds,SetStm(x))}
  a_get1[10]:PreBlock:={||.t.}
  a_get1[1]:PostBlock:={|x|kpt_vl(x,@a_dop)}
  a_get1[4]:PostBlock:=a_get1[7]:PostBlock:={||taxir01(lApnd)}
  Select scht1 ; Wselect(n_win)
  ADD menu up_down
  add menu Left_Right
  add menu search
  ADD MENU NAME "~Изменение" ;
  ITEMS {"Добавить   Ins" ,"Исправить  Enter" ,"Удалить    Delete ","Скопировать F5" } ;
  KEY {K_INS,K_ENTER,K_DEL,K_F5}
  add menu print
   SELECT scht1
  scht1->(DBGOBOTTOM())
  IF scht1->(RECNO())==scht1->(LASTREC())+1
    m_vnum:=0;m_ndoc:=1
  ELSE
    scht2->(DBGOBOTTOM())
    m_vnum:=VAL(scht2->vnum)+1
  ENDIF
  scht1->(DBSETORDER(1))
  scht1->(DBGOBOTTOM())
  m_ndoc:=STR(VAL(scht1->ndoc)+1,LEN(scht1->ndoc))
  scht1->(DBGOTOP())
  m_browse:goBottom()
  m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w,w/n,n/w,n/g,g/w*,b/bg,bg/w*,w/rb,rb/w,w+/r,w+/n,w+/g,w+/bg,w+/rb'
  FOR i:=1 TO m_browse:colCount
    m_browse:GetColumn(i):colorBlock:={||color1(scht1->state)}
  NEXT
  INIT menu
  DISPLAYLIST
  scht1->(DBSETRELATION("scht2",{||scht1->vnum},"scht1->vnum"))
  DO WHILE .t.
    m_browse:refReshCurrent()
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},EVAL(m_browse:GetColumn(1):colorBlock))
    STABILIZE BROWSE m_browse
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2(scht1->state))
    m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},MyFunc1(EVAL(m_browse:GetColumn(1):colorBlock)))
//    Display Browse m_browse
    m_key:=INKEY(0)
    Winsay
    DEAL MENU
    DO CASE
      DEAL BROWSE m_browse KEY m_key
    CASE m_key==K_F2
      IF ANSWER("Печатать перечень счетов за день?")==YES
        PrintLs()
      ENDIF

      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      SEEK  BROWSE m_browse KEY m_key
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_S
         IF ANSWER("Расчитывать сумму?")==YES
          m_recno:=scht1->(REcno())
          DO WHILE .NOT.scht1->(EOF())
            scht2->(DS(scht1->vnum))
            k:=scht1->vnum
            If scht1->(NetRLock())
              scht1->sum:=0
              DO WHILE .NOT.scht2->(EOF()).AND.scht1->vnum==scht2->vnum
                scht1->sum+=scht2->stm
                scht2->(DBSKIP())
              ENDDO
              scht1->(dbUnlock())
            ENDIF
            scht1->(DBSKIP())
          ENDDO
          scht1->(Dbgoto(m_recno))
          m_browse:RefreshAll()
          ENDIF

    CASE m_Key == K_DEL
        DelDoc(m_browse,l_delete,SELECT("SCHT1"),SELECT("SCHT2"))
    CASE m_key==K_ENTER
      WSELECT(n_win1)
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      SELECT scht1;n_pole:=1
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1;m_state:="0"
      set escape on
      SELECT scht2
      m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
      WSELECT(n_win1)
      CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
      DISPBOX(m_browse1:nTop-1,m_browse1:nLeft-1,m_browse1:nBottom,m_browse1:nRight+1,"▌─▐▐▐─▌▌ ",m_browse1:colorSpec)
      lApnd:=.f.;EVAL(m_browse1:GotopBlock)
      IF scht2->vnum==scht1->vnum //m_browse1:hitBottom
        m_sum:=m_nds:=0
        @MAXROW()-1,22 SayDisp SPACE(20) COLOR TOKEN(m_browse:colorspec,",",6)
        @MAXROW()-1,1 SayDisp "До оплати "+ALLTRIM(SumToStr(m_sum)) COLOR TOKEN(m_browse:colorspec,",",1)
        select scht2
        m_recno:=RECNO()
        DO WHILE .NOT.EOF().AND.scht2->vnum==scht1->vnum
          m_sum+=scht2->stm;m_nds+=scht2->nds
          DBSKIP()
        ENDDO
        DBGOTO(m_recno)
        @MAXROW()-1,22 SayDisp SPACE(20) COLOR TOKEN(m_browse:colorspec,",",6)
        @MAXROW()-1,22 SayDisp ALLTRIM(SumToStr(m_sum+m_nds)) COLOR TOKEN(m_browse:colorspec,",",6)
        IF scht1->(NetRLOCK())
          scht1->sum:=m_sum;scht1->(dbUnlock())
        ENDIF
        Stabilize Browse m_browse1
        m_browse1:autolite:=.f.
        m_browse1:DeHilite()
      ENDIF
      DO WHILE .t.
       DO CASE
        CASE m_state=="0"
          select scht1
          WSELECT(n_win1)
          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
//            WORK GET a_get KEY m_key BY n_pole  SAY a_say DATA a_data
              CASE m_key == K_UP;IF n_pole ==1;ELSE;n_pole:=n_pole-1;END
              CASE m_key == K_DOWN;IF n_pole ==LEN(a_get);ELSE;n_pole:=n_pole+1;END
              CASE m_key == K_ESC;BeepErr();IF ALERT("Все изменения будут анулированы;Выходить ?",{"Да","Нет"})==1;EXIT;END
              CASE m_key==K_F4.AND.ANSWERu("Заносити вiдомостi про покупця?")==YES
                firm01->(firm01(@a_data))
                a_get[n_pole]:updateBuffer()
                k:=n_pole
                n_pole:=1
                AEVAL(a_get,{|x|a_get[n_pole]:display(),n_pole++})
                n_pole:=k
              CASE m_key==K_F3.AND.ANSWERu("Заносити вiдомостi про постачальника?")==YES
                GetPr01(@a_pred01,@a_data)
                k:=n_pole;n_pole:=1
                AEVAL(a_get,{|x|a_get[n_pole]:display(),n_pole++})
                n_pole:=k
              CASE m_key == K_F12.OR. m_key == K_CTRL_END
              IF NetRLOCK();n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                UNLOCK;EXIT
              ELSE;DispError("Невозможно заблокировать запись");END
              CASE m_key == K_ENTER ;WinSay
              ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
              IF a_say[n_pole] # NIL .AND. VALTYPE(a_say[n_pole][1])<>"A"
              SETPOS(a_say[n_pole][1],a_say[n_pole][2])
              DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
              END
            CASE m_key = K_TAB
               m_state:="4"
            CASE m_key = K_F2
               Printscht(a_data)
          ENDCASE
         CASE m_state=="4"
            select scht2
            m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
            lApnd:=.f.;EVAL(m_browse1:GotopBlock)
            IF scht2->vnum<>scht1->vnum //m_browse1:hitBottom
              IF ANSWER("Данных по материалам нет !;Будем вводить ?")<>YES
                select scht1;m_state:="0"
                m_browse1:refreshCurent()
                STABILIZE BROWSE m_browse1
                LOOP
              ELSE
                lApnd:=.t.
              ENDIF
            ENDIF
            DO WHILE .t.
              Display Browse m_browse1
              Winsay
              IF .NOT.lApnd
                m_key:=INKEY(0)
              ELSE
                m_key:=K_INS
              ENDIF
                DO CASE
                  CASE m_key==K_ALT_S
                    m_sum:=m_nds:=0
                    m_recno:=scht2->(RECNO())
                    EVAL(m_browse1:GotopBlock)
                    DO WHILE .NOT.scht2->(EOF()).AND.scht2->vnum==scht1->vnum
                      m_sum+=scht2->stm;m_nds+=scht2->nds
                      scht2->(DBSKIP())
                      @MAXROW()-1,22 SayDisp SPACE(20) COLOR TOKEN(m_browse:colorspec,",",6)
                      @MAXROW()-1,22 SayDisp ALLTRIM(SumToStr(m_sum+m_nds)) COLOR TOKEN(m_browse:colorspec,",",6)
                    ENDDO
                    scht2->(DBGOTO(m_recno))
                  CASE m_key==K_ESC
                    m_sum:=m_nds:=0
                    m_recno:=scht2->(RECNO())
                    EVAL(m_browse1:GotopBlock)
                    DO WHILE .NOT.scht2->(EOF()).AND.scht2->vnum==scht1->vnum
                      m_sum+=scht2->stm;m_nds+=scht2->nds
                      scht2->(DBSKIP())
                      @MAXROW()-1,22 SayDisp SPACE(20) COLOR TOKEN(m_browse:colorspec,",",6)
                      @MAXROW()-1,22 SayDisp ALLTRIM(SumToStr(m_sum+m_nds)) COLOR TOKEN(m_browse:colorspec,",",6)
                    ENDDO
                    IF scht1->(NetRLOCK())
                      scht1->sum:=m_sum;scht1->(dbUnlock())
                    ENDIF
                    scht2->(DBGOTO(m_recno))
                      m_state:="0";EXIT
                  CASE m_key = K_TAB
                    m_sum:=m_nds:=0
                    m_recno:=scht2->(RECNO())
                    EVAL(m_browse1:GotopBlock)
                    DO WHILE .NOT.scht2->(EOF()).AND.scht2->vnum==scht1->vnum
                      m_sum+=scht2->stm;m_nds+=scht2->nds
                      scht2->(DBSKIP())
                      @MAXROW()-1,22 SayDisp SPACE(20) COLOR TOKEN(m_browse:colorspec,",",6)
                      @MAXROW()-1,22 SayDisp ALLTRIM(SumToStr(m_sum+m_nds)) COLOR TOKEN(m_browse:colorspec,",",6)
                    ENDDO
                    IF scht1->(NetRLOCK())
                      scht1->sum:=m_sum;scht1->(dbUnlock())
                    ENDIF

                    scht2->(DBGOTO(m_recno))
                     m_state:="0";EXIT
                DEAL BROWSE m_browse1 KEY m_key
                CASE m_key==K_ENTER   // .OR.Lapnd
                      IF NetRLOCK()
                        m_browse1:refreshCurrent()
                        STABILIZE BROWSE m_browse1
                        a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                        ReadMy({a_get1[m_browse1:ColPos]},;
                        IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
                        IF .NOT.EMPTY(a_dop)
                          scht2->name :=a_dop[2];scht2->izm  :=a_dop[3]
                          scht2->izm2 :=a_dop[4];scht2->prise:=a_dop[6]
                          a_dop:={}
                        ENDIF
                        dbUNLOCK()
                      ELSE
                        DispError("Невозможно заблокировать запись")
                      ENDIF
                CASE m_Key == K_DEL                                    /* удаление записи */
                   IF  answer( "Вы действительно хотите уничтожить запись ?" )==YES
                    IF NetRLOCK();dbdelete();UNLOCK
                    ELSE;DispErr("Файл заблокирован");ENDIF
                    IF EVAL(m_browse1:SkipBlock,1)==0
                      IF EVAL(m_browse1:SkipBlock,-1)==0
                        BeepErr();WaitMessage("Удалена последняя запись")
                        EXIT
                      ELSE
                        IF  M_browse1:RowPos<>1
                          m_browse1:RowPos:=m_browse1:RowPos-1
                        ENDIF
                      ENDIF
                    ENDIF
                    m_browse1:RefreshAll()
                   ENDIF
                CASE m_Key == K_INS
                  IF .NOT.Lapnd
                    m_browse1:panHome();m_browse1:goBottom()
                    STABILIZE BROWSE m_browse1
                    lApnd:=.t.;m_browse1:down();m_browse1:refreshAll()
                    STABILIZE BROWSE m_browse1
                  ELSE
                  ENDIF
                  m_block:=a_get1[1]:block;m_buf:=EVAL(m_block)
                  m_valid1:=a_get1[1]:postBlock;a_get1[1]:postBlock:={|x|IF(x==NIL.OR.EMPTY(x:buffer),.t.,EVAL(m_valid1,x))}
                  a_get1[1]:block:={|x|IF(x==NIL,m_buf,m_buf:=x)}
                  DO WHILE .t.
                    STABILIZE BROWSE m_browse1
                    SET ESCAPE ON
                    m_buf:=EVAL(m_block)
                    a_get1[1]:row:=ROW();a_get1[1]:col:=COL()
                    ReadMy({a_get1[m_browse1:ColPos]},;
                        IF(a_say1[1]#NIL.AND.VALTYPE(a_say1[1][1])=="A",a_say1[1],NIL))
                    IF LASTKEY()<>K_ESC.AND..NOT.EMPTY(m_buf)
                      IF scht2->(NetDbAp())
                        IF .NOT.EMPTY(a_dop)
                          scht2->name :=a_dop[2];scht2->izm  :=a_dop[3]
                          scht2->izm2 :=a_dop[4];scht2->prise:=a_dop[6]
                          a_dop:={}
                        ENDIF
                        scht2->vnum:=scht1->vnum
                        EVAL(m_block,m_buf)
                        FOR i:=2 TO m_browse1:ColCount
                          m_browse1:right();m_browse1:refreshCurrent()
                          STABILIZE BROWSE m_browse1
                          a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                          ReadMoDal({a_get1[m_browse1:ColPos]})
                        NEXT
                      ELSE
                        DispError("Невозможно добавить запись")
                      ENDIF
                      m_browse1:panHome();m_browse1:down()
                      UNLOCK
                  ELSE
                    lApnd:=.f.;m_browse1:goBottom();m_browse1:refreshAll()
                    a_get1[1]:block:=m_block;a_get1[1]:postBlock:=m_valid1
                    EXIT
                  ENDIF
                  ENDDO
                ENDCASE
            ENDDO
            m_browse1:RefreshCurrent()
            Stabilize Browse m_browse1
            m_browse1:autolite:=.f.
            m_browse1:DeHilite()
        ENDCASE
      ENDDO
      Wselect(n_win)
      IF INDEXORD()<>0;IF c_key<>&(INDEXKEY(0));m_browse:refreshAll()
      ELSE;m_browse:refreshCurrent();END;END
    CASE m_key==K_INS
      WSELECT(n_win1)
      l_stop:=.t.
      m_valid:=a_get[1]:postBlock;a_get[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid,x))}
      DO WHILE l_stop
        set escape on
        CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
        select scht1;n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
        EVAL(a_say[1][1][2])
          a_data[2]:=DATE()
          a_data[1]:=m_ndoc
        Display Get a_get KEY n_pole SAY a_say DATA a_data
//        TAKE GET a_get KEY n_pole SAY a_say DATA a_data
          n_pole:=1
          a_data[2]:=DATE()
          WHILE .t.
          IF a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A".AND.a_say[n_pole][1][1]==ASC("?")
            KEYBOARD(ASC("?"))
          ENDIF
          ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
          IF a_say[n_pole] # NIL.AND. VALTYPE(a_say[n_pole][1])<>"A"
          SETPOS(a_say[n_pole][1],a_say[n_pole][2])
          DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
          END
          DO CASE;CASE LASTKEY() == K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT
          CASE LASTKEY() == K_UP.AND.n_pole # 1;n_pole--;LOOP
          CASE n_pole == LEN(a_get)
          IF NetDbAp();n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++});EXIT
          ELSE;DispError("Невозможно добавить запись");END
          CASE n_pole == 1.AND.EMPTY(a_data[1]);l_stop:=.f.;EXIT
          OTHERWISE ;n_pole++;END;END
        IF LASTKEY()==K_ESC.OR..NOT.l_stop
          EXIT
        ENDIF
        scht1->vnum:=STR(m_vnum++,6)
        m_ndoc:=STR(VAL(scht1->ndoc)+1,LEN(scht1->ndoc))
        select scht2
        m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
        EVAL(m_browse1:GotopBlock);lApnd:=.t.
        Display Browse m_browse1
        m_block:=a_get1[1]:block;m_buf:=EVAL(m_block)
        m_valid1:=a_get1[1]:postBlock;a_get1[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid1,x))}
        a_get1[1]:block:={|x|IF(x==NIL,m_buf,m_buf:=x)}
        m_sum:=m_nds:=0
        l_firstline:=.t.
        @MAXROW()-1,22 SayDisp SPACE(20) COLOR TOKEN(m_browse:colorspec,",",6)
        @MAXROW()-1,22 SayDisp ALLTRIM(SumToStr(m_sum+m_nds)) COLOR TOKEN(m_browse:colorspec,",",6)
        DO WHILE .t.
          STABILIZE BROWSE m_browse1
          SET ESCAPE ON
          m_buf:=BLANK(EVAL(m_block),.t.)
          a_get1[1]:row:=ROW();a_get1[1]:col:=COL()
          ReadMy({a_get1[m_browse1:ColPos]},;
              IF(a_say1[1]#NIL.AND.VALTYPE(a_say1[1][1])=="A",a_say1[1],NIL))
          SET ESCAPE OFF
          IF LASTKEY()<>K_ESC.AND..NOT.EMPTY(m_buf)
            IF scht2->(NetDbAp())
              IF .NOT.EMPTY(a_dop)
                scht2->name :=a_dop[2];scht2->izm  :=a_dop[3]
                scht2->izm2 :=a_dop[4];scht2->prise:=a_dop[6]
                a_dop:={}
              ENDIF
              scht2->vnum:=scht1->vnum
              EVAL(m_block,m_buf)
              FOR i:=2 TO m_browse1:ColCount
                m_browse1:right();m_browse1:refreshCurrent()
                STABILIZE BROWSE m_browse1
                a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                ReadMoDal({a_get1[m_browse1:ColPos]})
              NEXT
            ELSE
              DispError("Невозможно добавить запись")
            ENDIF
            m_sum+=scht2->stm;m_nds+=scht2->nds
        @MAXROW()-1,22 SayDisp SPACE(20) COLOR TOKEN(m_browse:colorspec,",",6)
        @MAXROW()-1,22 SayDisp ALLTRIM(SumToStr(m_sum+m_nds)) COLOR TOKEN(m_browse:colorspec,",",6)
            m_browse1:panHome();m_browse1:down()
            l_firstline:=.f.
            scht2->(DbUnLock())
          ELSE
            lApnd:=.f.;a_get1[1]:block:=m_block;a_get1[1]:postBlock:=m_valid1
            @MAXROW()-1,22 SayDisp SPACE(18) COLOR TOKEN(m_browse:colorspec,",",6)
            EXIT
          ENDIF
        ENDDO
        IF Scht1->(NetRlock());scht1->sum:=m_sum;scht1->(dbUnlock());ENDIF
      ENDDO
      a_get[1]:postBlock:=m_valid
      Wselect(n_win)
      m_browse:refreshAll()
   FINISH LIST
   WCLOSE(n_win);WCLOSE(n_win1)
   WSELECT(0)
   READEXIT(m_exit)
  SETKEY(K_F4,)
    SopenFiles("100",@s_files)
    OpenFl3()
  setblink(.f.)
RETURN .t.
Function Printscht(a_data)
  LOCAL m_sum:=0,m_nds:=0,i:=1,n_copy,m_kvo,m_rec:=0,m_file,j,m_str
  LOCAL k:=0
//  LOCAL m_str1
  SavePar()
  DBCOMMITALL()
  m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
  m_kvo:=ALERT("Количество экземпляров; выводимых на печать",{" 1 "," 2 "," 3 "," 4 "},"n/bg,w/b,gr/rb")
  IF m_kvo==0
    RETURN .f.
  ENDIF
  scht2->(DBSEEK(scht1->vnum))
  DO WHILE .t.
    scht2->(DBSKIP(-1))
    IF scht1->VNUM<>scht2->VNUM
      scht2->(DBSKIP())
      EXIT
    ENDIF
    IF scht2->(BOF())
      EXIT
    ENDIF
  ENDDO
  SET PRINTER TO (m_file)
  SET PRINTER ON
  SET CONSOLE OFF
  m_rec:=scht2->(RECNO())
  FOR n_copy:=1 TO m_kvo
    scht2->(DBGOTO(m_rec))
?CHR(27)+"M"+"Постачальник:"+CHR(27)+"E"+ALLTRIM(a_data[3])+CHR(27)+"F"
?"Адреса      :"+CHR(27)+"E"+ALLTRIM(a_data[4])+CHR(27)+"F"
?"Рахунок "+CHR(27)+"E"+ALLTRIM(a_data[5])+CHR(27)+"F"+" в "+CHR(27)+"E"+ALLTRIM(a_data[6])+CHR(27)+"F"
?"МФО "+CHR(27)+"E"+a_data[7]+CHR(27)+"F"+" ЄДРПОУ "+CHR(27)+"E"+a_data[8]+CHR(27)+"F"
?"Платник :"+ALLTRIM(a_data[09])
?""
?"          "+CHR(27)+"FРАХУНОК № "+CHR(27)+"w1"+CHR(14)+CHR(27)+"E"+ALLTRIM(a_data[1])+""+CHR(27)+"F"+CHR(20)+CHR(27)+"w0 вiд "+CHR(27)+"E"+my_dtos(a_data[2])+""+CHR(27)+"F"
?""+CHR(27)+"M"+ "──┬────────────────────┬──────┬──────────┬────┬──────┬─────────┬──────────┐"
?" №│ Назва, сорт, розмiр│Один. │ Кiлькiсть│Од. │Кiльк.│   Цiна  │  Сума    │"
?"  │                    │вимiру│          │вим2│    2 │ без ПДВ │ з ПДВ    │"
m_sum:=0;m_nds:=0;i:=1
DO WHILE scht2->VNUM==scht1->vnum.AND..NOT.scht2->(EOF())
  m_str:=ALLTRIM(scht2->name)
  ?"──┼────────────────────┼──────┼──────────┼────┼──────┼─────────┼──────────┤"
    k:=1
    DO WHILE .NOT.EMPTY(m_str)
      j:=RAT(" ",SUBSTR(m_str,1,20))
      IF j<>0
        IF k==1
           ?STRZERO(i,2)+"│"+PADR(SUBSTR(m_str,1,j-1),20)+"│ "+PADR(scht2->izm,5)+"│"+STR(scht2->kvo,10,2)+"│"+PADR(scht2->izm2,4)+"│"+NumtoSTR(scht2->glv,6)+"│"+Str(scht2->prise,9,3)+"│"+SumToStr(scht2->stm+Scht2->nds,10)+"│"
        ELSE
        ?"  │"+PADR(SUBSTR(m_str,1,j-1),20)+"│      │          │    │      │         │          │         │"
        ENDIF
        m_str:=SUBSTR(m_str,j+1)
      ELSE
        IF k==1
           ?STRZERO(i,2)+"│"+PADR(SUBSTR(m_str,1,20),20)+"│ "+PADR(scht2->izm,5)+"│"+STR(scht2->kvo,10,2)+"│"+PADR(scht2->izm2,4)+"│"+NumtoSTR(scht2->glv,6)+"│"+Str(scht2->prise,9,3)+"│"+SumToStr(scht2->stm+scht2->nds,10)+"│"
        ELSE
        ?"  │"+PADR(SUBSTR(m_str,1,20),20)+ "│      │          │    │      │         │          │         │"
        ENDIF
        m_str:=SUBSTR(m_str,21)
      ENDIF
      k++
    ENDDO
  i++;m_sum+=scht2->stm;m_nds+=scht2->nds
  scht2->(Dbskip())
ENDDO
?"──┴────────────────────┴──────┴──────────┴────┴──────┴─────────┴──────────┘"
// ?"                                                              "+SumToStr(m_sum,11)+" "+SumToStr(m_nds,10)+CHR(27)+"P"
?"ПДВ "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_nds))+""+CHR(27)+"F/"+SumStr(m_nds)+"/"+CHR(27)+"P"
?"До сплати "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_sum+m_nds))+""+CHR(27)+"F/"+SumStr(m_sum+m_nds)+"/"+CHR(27)+"P"

?""+CHR(27)+"3-"+"Виписав:"+CHR(27)+"E "+CHR(27)+"4"+ALLTRIM(_Fio(m_tabn))+CHR(27)+"F "+""+CHR(27)+"5"
?
?"         Директор       ________________"
?
?"         Гол. бухгалтер ________________"
?""+CHR(27)+"2"+CHR(27)+"M"
?
?MEMOREAD(m_workpath+"SCht.txt")
IF n_copy<>m_kvo.AND.ALERT("Вывод экземпляра"+STR(n_copy,2)+" завершена;Выполнить прогон листа?",{" Да "," Нет"},"n/bg,n/w")==1
?CHR(K_CTRL_L)
ENDIF
NEXT
IF scht1->(NetRlock())
  scht1->pCount:=scht1->pCount+1
  scht1->(DbUnlock())
ENDIF

  SET CONSOLE ON
  SET PRINTER OFF
  SET PRINTER TO
  IF SPOOLACTIV().AND.SPOOLCOUNT()<6
    IF Is_Ready_Prn()
      SPOOLADD(m_file)
    ENDIF
  ELSE
          MyPRINTFILE(m_file)
//    PRINTFILE(m_file,.t.)
  ENDIF
  SavePar(1)
  RETURN .t.
/* Function SUMtoSTR(x)
LOCAL m_str:="",s:=STR(ABS(x),18,2),i
if x==0
  return ""
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
m_str+=","+substr(s,17,2)
IF x<0
  m_str:=","+m_str
ENDIF
RETURN m_str */
STATIC Function GetlApnd()

  RETURN .not.lApnd
STATIC Function SetPrise(var,a_dop)
  spr01->(DBSEEK(var))
  DO CASE
    CASE spr01->prise=="2"
      RETURN a_dop[6]
    CASE spr01->prise=="3"
      RETURN a_dop[7]
  ENDCASE
RETURN a_dop[5]
STATIC function Color1(var)
LOCAL x:={1,2}
DO CASE
  CASE var=="0"
    x:={15,16}
  CASE var=="1".OR.var==" "
    x:={1,2}
  CASE var=="2"
    x:={7,8}
  CASE var=="3"
    x:={9,10}
  CASE var=="4"
    x:={11,12}
  CASE var=="5"
    x:={13,14}
ENDCASE
RETURN x
STATIC function Color2(var)
LOCAL x:={1,2}
DO CASE
  CASE var=="0"
    x:={21,21}
  CASE var=="1".OR.var==" "
    x:={6,6}
  CASE var=="2"
    x:={17,17}
  CASE var=="3"
    x:={18,18}
  CASE var=="4"
    x:={19,19}
  CASE var=="5"
    x:={20,20}
ENDCASE
RETURN x
STATIC Function MyFunc1(x)
LOCAL y:={0,0}
y[1]:=x[2];y[2]:=x[2]
return y
STATIC Function PrintLs()
LOCAL m_file,m_ddoc,c_key,m_buf,GetList:={}
        // Ввести дату
        savepar()
        m_ddoc:=scht1->ddoc
        @INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+3,75 BOX B_DOUBLE+" " COLOR ("w+/bg")
        @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( 'Введите значение даты для распечатки',68) COLOR "GR+/bg"
        @INT((MAXROW()-4)/2)+2,38 GET m_ddoc COLOR "w/b,Gr+/n"
        READ
        IF LASTKEY()==K_ESC
          SavePar(1)
          RETURN .f.
        ENDIF
        // найти дату
        scht1->(DBGOBOTTOM())
        DO WHILE .NOT.scht1->(BOF())
          IF scht1->ddoc==m_ddoc
            EXIT
          ENDIF
          scht1->(DBSKIP(-1))
        ENDDO
        IF   scht1->ddoc<>m_ddoc
          DispError("Накладные за "+DTOC(m_ddoc)+" не обнаружены ")
          SavePar(1)
          RETURN .f.
        ENDIF
        DO WHILE scht1->ddoc==m_ddoc.AND..NOT.scht1->(BOF())
          scht1->(DBSKIP(-1))
        ENDDO
        IF scht1->ddoc<>m_ddoc
          scht1->(DBSKIP())
        ENDIF
        m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
        SET PRINTER TO (m_file)
        SET DEVICE TO PRINTER
        // распечатать данные
        @PROW(),0 SAY PADC('Перелiк накладних за '+My_DTOS(m_ddoc),60)+CHR(27)+"M"
        DO WHILE scht1->ddoc==m_ddoc.AND..NOT.scht1->(EOF())
          c_key:="";m_buf:=Alltrim(scht1->fio1)
          DO WHILE scht1->vnum==scht2->vnum.AND..NOT.scht2->(EOF())
            c_key:=c_key+IF(EMPTY(c_key),"",",")+ALLTRIM(scht2->name)
            scht2->(DBSKIP())
          ENDDO
          @PROW()+1,0 Say scht1->ndoc
          @PROW(),7 Say " I "
          @PROW(),10 Say SUBSTR(m_buf,1,26)
          @PROW(),37 Say " I "
          @PROW(),40 Say SUBSTR(c_key,1,26)
          @PROW(),67 Say " I "
          @PROW(),70 Say PADL(SumToStr(scht1->sum,12),12)
          m_buf:=SUBSTR(m_buf,27);c_key:=SUBSTR(c_key,27)
          DO WHILE .NOT.EMPTY(m_buf).OR..NOT.EMPTY(c_key)
            @PROW()+1,0 SAY ""
            @PROW(),7 Say " I "
            IF .NOT.EMPTY(m_buf)
              @PROW(),10 Say SUBSTR(m_buf,1,26)
              m_buf:=SUBSTR(m_buf,27)
            ENDIF
          @PROW(),37 Say " I "
            IF .NOT.EMPTY(c_key)
              @PROW(),40 Say SUBSTR(c_key,1,26)
              c_key:=SUBSTR(c_key,27)
            ENDIF
          @PROW(),67 Say " I "
          ENDDO
          scht1->(DBSKIP())
        ENDDO
        SET PRINTER TO
        SET DEVICE TO SCREEN
        @PROW()+1,0 SAY CHR(27)+"P"+REPLICATE("=",60)
        @PROW()+1,0 SAY ""
        IF SPOOLACTIV().AND.SPOOLCOUNT()<6
          IF Is_Ready_Prn()
            SPOOLADD(m_file)
          ENDIF
        ELSE
          MyPRINTFILE(m_file)
//          PRINTFILE(m_file,.t.)
        ENDIF
        SavePar(1)
RETURN .t.
/* STATIC FUnction Getpr01(a_pred01,a_data)
     a_data[3]:=a_pred01[1]
     a_data[4]:=a_pred01[2]
     a_data[5]:=a_pred01[3]
     a_data[6]:=a_pred01[4]
     a_data[7]:=a_pred01[5]
     a_data[8]:=a_pred01[6]
RETURN .t. */
STATIC FUnction Getpr01(a_pred01,a_data)
LOCAL n_win,i,j,m_key
SavePar()
IF LEN(a_pred01[4])>1
  n_win:=InitScr("PRED01A")
  FOR i:=4 TO  LEN(a_pred01)
    @2+i-4,1 SayDisp LEFT(PADR(a_pred01[i][1]+" "+RTRIM(a_pred01[i][2])+" "+a_pred01[i][3],MAXCOL()-3),MAXCOL()-3) COLOR "w+/b"
  NEXT
  j:=4
  DO WHILE .T.
    @2+j-4,1 SayDisp LEFT(PADR(a_pred01[j][1]+" "+RTRIM(a_pred01[j][2])+" "+a_pred01[j][3],MAXCOL()-3),MAXCOL()-3) COLOR "b/w"
    m_key:=INKEY(0)
    @2+j-4,1 SayDisp LEFT(PADR(a_pred01[j][1]+" "+RTRIM(a_pred01[j][2])+" "+a_pred01[j][3],MAXCOL()-3),MAXCOL()-3) COLOR "w+/b"
    DO CASE
      CASE m_key==K_ESC
        EXIT
      CASE m_key==K_ENTER
        a_data[3]:=a_pred01[1]
        a_data[4]:=a_pred01[3]
        a_data[5]:=a_pred01[j][1]
        a_data[6]:=a_pred01[j][2]
        a_data[7]:=a_pred01[j][3]
        a_data[8]:=a_pred01[2]
        EXIT
      CASE m_key==K_DOWN
        j:=IF(j==LEN(a_pred01),4,j+1)
      CASE m_key==K_UP
        j:=IF(j==4,LEN(a_pred01),j-1)
    ENDCASE
  ENDDO
  WCLOSE(n_win)
ELSE
        a_data[3]:=a_pred01[1]
        a_data[4]:=a_pred01[3]
        a_data[5]:=a_pred01[4][1]
        a_data[6]:=a_pred01[4][2]
        a_data[7]:=a_pred01[4][3]
        a_data[8]:=a_pred01[2]
ENDIF
SavePar(1)
RETURN .t.
STATIC Function firm01(a_data)
  LOCAL a_par:={"full1","full2","okpo","mfo","addr1","addr2","bank1","bank2","rasch"}
  LOCAl a_firm:={},m_str
  vl_sp("FIRM01",,@a_firm,a_par)
  IF .NOT.EMPTY(a_firm)
    m_str:=ALLTRIM(a_firm[1])+" "+ALLTRIM(a_firm[2])
    a_data[09]:=PADR(SUBSTR(m_str,1,LEN(scht1->full2)),LEN(scht1->full2))
    m_str:=ALLTRIM(a_firm[5])+" "+ALLTRIM(a_firm[6])
    a_data[10]:=PADR(SUBSTR(m_str,1,LEN(scht1->addr2)),LEN(scht1->addr2))
    a_data[11]:=PADR(SUBSTR(a_firm[9],1,LEN(scht1->rasch2)),LEN(scht1->rasch2))
    m_str:=ALLTRIM(a_firm[7])+" "+ALLTRIM(a_firm[8])
    a_data[12]:=PADR(SUBSTR(m_str,1,LEN(scht1->bank2)),LEN(scht1->bank2))
    a_data[13]:=PADR(SUBSTR(a_firm[4],1,LEN(scht1->mfo2)),LEN(scht1->mfo2))
    a_data[14]:=PADR(SUBSTR(a_firm[3],1,LEN(scht1->okpo2)),LEN(scht1->okpo2))
  ENDIF
RETURN .t.
Static function Taxir01(m_mode)
IF m_mode==.t..OR.ANSWERu("Перераховувати ПДВ i суму?")==YES
  scht2->stm:=scht2->prise*scht2->kvo
  scht2->nds:=ReadNds()*scht2->stm
ENDIF
RETURN .t.
STATIC FUNCTION SetStm(x)
LOCAL i:=GetNds()
IF i==0
  scht2->stm:=x;scht2->nds:=0;scht2->prise:=IF(scht2->kvo==0,0,scht2->stm/scht2->kvo)
ELSE
  scht2->stm:=x/(1+i);scht2->nds:=i*scht2->stm;scht2->prise:=IF(scht2->kvo==0,0,scht2->stm/scht2->kvo)
endif
RETURN x
STATIC Function Openfl3()
    NET USE (m_workpath+"kaptka1") INDEX (m_workpath+"kaptka1"),(m_workpath+"kaptka1a"),(m_workpath+"kaptka1b") ALIAS kaptka1 NEW
    NET USE (m_workpath+"PRED01") NEW
    NET USE (m_workpath+"FIRM01") INDEX (m_workpath+"FIRM01"),(m_workpath+"FIRM01A"),(m_workpath+"FIRM01B") NEW
    NET USE (m_workpath+"BANK01") INDEX (m_workpath+"BANK01") NEW
    NET USE (m_workpath+"spr01") INDEX (m_workpath+"spr01")   NEW ALIAS spr01
    NET USE (m_workpath+"scht1") INDEX (m_workpath+"scht1"),(m_workpath+"scht1a")   NEW ALIAS scht1
    NET USE (m_workpath+"scht2") INDEX (m_workpath+"scht2")   NEW ALIAS scht2
RETURN .T.
STATIC Function CloseFl3()
    CLOSE base kaptka1,pred01,Scht1,Scht2
    CLOSE BASE firm01,bank01
RETURN .t.
