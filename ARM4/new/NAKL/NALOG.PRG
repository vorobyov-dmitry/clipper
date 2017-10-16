#include "menu.ch"
#include "new.ch"
// #include "setcurs.ch"
MEMVAR m_mash,m_temppath,m_level,m_platpath,m_sprpath,p_npr,m_tabn,m_oper,m_computer
STATIC lApnd:=.f.
STATIC SI:=CHR(15)
STATIC DC2:=CHR(18)
Function Nalog(l_mode)
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,n_win1,m_col,m_ddoc,m_file
  LOCAL m_exit:=READEXIT(.T.),l_stop:=.t.
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={},m_buf
  LOCAL a_get1:={},a_data1:={},n_pole1,m_block,a_say1:={},a_brgd:={}
  LOCAL m_browse1,m_ndoc,m_valid,m_valid1,a_dop:={},a_spr01:={},l_firstline:=.t.,m
  LOCAL m_browse2,m_get1b,m_state:="0",m_col1b,a_fam:={},m_sum,m_nds,m_date
  LOCAL k_f4,k_f3,k_Ctrlf4
  DCL MENU
  DCL LIST
  LOCAL m_select:=SELECT(),a_saydop:={},;
  a_pred01:={},a_block:={},;
  do_block:={||.f.},RefrGet:={|k|a_get[n_pole]:UpdateBuffer(),k:=n_pole,n_pole:=1,AEVAL(a_get,{|x|a_get[n_pole]:display(),n_pole++}),n_pole:=k}
  IF .NOT.RECURS("nalog")
  SavePar()
  WSELECT(0)
  IF EMPTY(l_mode)
    NET USE (m_platpath+"FVNUM") NEW
    IF .NOT.f_vnum(2)
      RETURN .f.
    ENDIF
    NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b") ALIAS kaptka1 NEW
    SopenFiles("100",@s_files)
    OpenFl1()
  ENDIF
  SET CURSOR OFF
  SETKEY(K_CTRL_F2,{||PrNalog(a_data,a_pred01[7],a_pred01[8])})
  k_f4:=SETKEY(K_F4,{||firm01->(EdFirm03(@a_data)),EVAL(RefrGet)})
  k_f3:=SETKEY(K_F3,{||GetPr01(@a_pred01,@a_data,2),EVAL(RefrGet)})
  k_Ctrlf4:=SETKEY(K_CTRL_F4,{||nakl(1)})
  InitNds()
  Lapnd:=.f.
  a_pred01:={pred01->short,pred01->KodNds,pred01->Addr1,pred01->Addr2,pred01->tel,pred01->NumNds,pred01->tabnr,pred01->tabnb}
  SELECT nalog1
  nalog1->(DBGOTOP())
  INIT GET "NALOG1" TO a_get KEY n_pole DATA a_data SAY a_say
  a_get[1]:PostBlock:={||.t.}
  n_pole1:=1
//  NET USE (m_platpath+"nalog2") INDEX (m_platpath+"nalog2")     NEW ALIAS nalog2
  SELECT nalog2
  Nalog2->(DBGOTOP())
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  CrList1("NALOG1",@m_browse,@l_print)
  n_win1:=InitScr("NALOG1")
  a_get1:=CrGet("NALOG2",a_say1)
  a_say1[1]={K_F2,{||PrNewNalog(a_data,a_pred01[7],a_pred01[8])}}
  a_say1[2]={{ASC("?"),{||kaptka_vl(a_get1[2],,@a_dop)}}}
  a_get1[1]:PostBlock:={||.t.}
  a_get1[2]:PostBlock:={|x,l|l:=kpt_vl(x,@a_dop),SetStm(),l}
  a_get1[3]:PreBlock:={|p|IF(lApnd,IF(EMPTY(nalog2->name),.t.,.f.),.t.)}
  a_get1[4]:PreBlock:={|p|IF(lApnd,IF(EMPTY(nalog2->izm),.t.,.f.),.t.)}
  a_get1[7]:PreBlock:={||IF(lApnd,(nalog2->sum2==0.AND.nalog2->sum3==0.AND.nalog2->sum4==0),.t.)}
  a_get1[8]:PreBlock:={||IF(lApnd,(nalog2->sum1==0.AND.nalog2->sum3==0.AND.nalog2->sum4==0),.t.)}
  a_get1[9]:PreBlock:={||IF(lApnd,(nalog2->sum1==0.AND.nalog2->sum2==0.AND.nalog2->sum4==0),.t.)}
  a_get1[10]:PreBlock:={||IF(lApnd,(nalog2->sum1==0.AND.nalog2->sum2==0.AND.nalog2->sum3==0),.t.)}
  a_get1[5]:PostBlock :={||SetStm()}
  a_get1[6]:PostBlock :={||SetStm()}
  a_get1[7]:PostBlock :={||CountStm(lApnd,"1")}
  a_get1[8]:PostBlock :={||CountStm(lApnd,"2")}
  a_get1[9]:PostBlock :={||CountStm(lApnd,"3")}
  a_get1[10]:PostBlock:={||CountStm(lApnd,"4")}
//a_get1[11]:PostBlock:={||CountStm(lApnd,"4")}

  m_browse1               := TBrowseDB(12,1,MAXROW()-3,MAXCOL()-1)
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_browse1:colsep        := '│'
  m_browse1:SkipBlock     := {|n| SkipDb1(n,{||(nalog1->vnum==nalog2->vnum)},lApnd) }
  m_browse1:goBottomBlock := {||nalog2->(DBSEEK(nalog1->vnum,.f.)),nalog2->(DBEVAL(,,{||(nalog1->vnum==nalog2->vnum)})),nalog2->(dbskip(-1))}
  m_browse1:goTopBlock    := {||nalog2->(DBSEEK(nalog1->vnum,.f.))}
  CrBrCol("NALOG2",@m_browse1)
  i:=1;AEVAL(a_get1,{|x|a_get1[i]:block:=m_browse1:GetColumn(i):Block,;
  m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──"),i++})
  a_get1[11]:Block:={|x|IF(x==NIL,nalog2->stm,SetStm6(x))}
  Select nalog1 ; Wselect(n_win)
  SET FILTER TO nalog1->vdoc=="1" // Витрата
  m_browse:goBottom()
  ADD menu up_down
  add menu Left_Right
  add menu search
  AADD(a_ver_menu[3][1],"Сложный поиск      K_ALT_F7")
  AADD(a_ver_menu[3][2],K_ALT_F7)
  ADD MENU NAME "~Изменение" ;
  ITEMS {"Добавить   Ins" ,"Исправить  Enter" ,"Удалить    Delete ","Скопировать F5" } ;
  KEY {K_INS,K_ENTER,K_DEL,K_F5}
  add menu print
//                      1   2    3    4      5    6   7   8   9  10   11   12   13  14   15     16   17   18  19   20     21
  m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w,w/n,n/w,w/b*,b+/w,w/n*,n+/w,w/rb,rb/w,w+/r,w+/n,w+/b*,w+/n*,w+/rb'
  FOR i:=1 TO m_browse:colCount
    m_browse:GetColumn(i):colorBlock:={||{1,2}}
  NEXT
  INIT menu
  DISPLAYLIST
  nalog1->(DBSETRELATION("nalog2",{||nalog1->vnum},"nalog1->vnum"))
  DO WHILE .t.
    m_browse:refReshCurrent()
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},EVAL(m_browse:GetColumn(1):colorBlock))
    STABILIZE BROWSE m_browse
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2(nalog1->state))
    m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},MyFunc1(EVAL(m_browse:GetColumn(1):colorBlock)))
//    Display Browse m_browse
    m_key:=INKEY(0)
    Winsay
    DEAL MENU
    DO CASE
      DEAL BROWSE m_browse KEY m_key
    CASE m_key==K_F2
      IF ANSWER("Печатать перечень налоговых за день?")==YES
        PrintLs()
      ENDIF

      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      CASE m_key==K_SH_F6
        ShiftF6(m_browse,SELECT("NALOG1"))
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_F7
        If .t. //  KaltF7()
          m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
        ENDIF
      CASE m_key==K_ALT_S
         IF ANSWER("Расчитывать сумму?")==YES
          m_recno:=nalog1->(REcno())
          DO WHILE .NOT.nalog1->(EOF())
            nalog2->(DS(nalog1->vnum))
            k:=nalog1->vnum
            If nalog1->(NetRLock())
              nalog1->sum:=0
              DO WHILE .NOT.nalog2->(EOF()).AND.nalog1->vnum==nalog2->vnum
                nalog1->sum+=nalog2->stm
                nalog2->(DBSKIP())
              ENDDO
              nalog1->(dbUnlock())
            ENDIF
            nalog1->(DBSKIP())
          ENDDO
          nalog1->(Dbgoto(m_recno))
          m_browse:RefreshAll()
          ENDIF

      CASE m_Key == K_DEL                                    /* удаление записи */
      DelDoc(m_browse,l_delete,SELECT("NALOG1"),SELECT("NALOG2"))
    CASE m_key==K_ENTER
      WSELECT(n_win1)
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      SELECT nalog1;n_pole:=1
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1;m_state:="0"
      set escape on
      SELECT nalog2
      m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
      WSELECT(n_win1)
      CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
      DISPBOX(m_browse1:nTop-1,m_browse1:nLeft-1,m_browse1:nBottom,m_browse1:nRight+1,"▌─▐▐▐─▌▌ ",m_browse1:colorSpec)
      lApnd:=.f.;EVAL(m_browse1:GotopBlock)
      IF nalog2->vnum==nalog1->vnum //m_browse1:hitBottom
        m_sum:=m_nds:=0
        @MAXROW()-1,1 SayDisp "Разом на суму  "+ALLTRIM(SumToStr(m_sum)) COLOR TOKEN(m_browse:colorspec,",",1)
        select nalog2
        m_recno:=RECNO()
        DO WHILE .NOT.EOF().AND.nalog2->vnum==nalog1->vnum
          m_sum+=nalog2->stm ;m_nds+=nalog2->nds
          DBSKIP()
        ENDDO
        DBGOTO(m_recno)
        @MAXROW()-1,22 SayDisp SPACE(20) COLOR TOKEN(m_browse:colorspec,",",6)
        @MAXROW()-1,22 SayDisp ALLTRIM(SumToStr(m_sum)) COLOR TOKEN(m_browse:colorspec,",",6)
        IF nalog1->(NetRLOCK())
          nalog1->nds:=m_nds;nalog1->sum:=m_sum;nalog1->(dbUnlock())
        ENDIF
        Stabilize Browse m_browse1
        m_browse1:autolite:=.f.
        m_browse1:DeHilite()
      ENDIF
      DO WHILE .t.
       DO CASE
        CASE m_state=="0"
          select nalog1
          WSELECT(n_win1)
          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
              CASE m_key == K_UP;IF n_pole ==1;ELSE;n_pole:=n_pole-1;END
              CASE m_key == K_F3
              IF IsLevel(nalog1->oper)
                IF ANSWERu("Занести вiдомостi про платника?")==YES
                  GetPr01(@a_pred01,@a_data,2);EVAL(RefrGet)
                ENDIF
              ELSE
                DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
              ENDIF
              CASE m_key == K_CTRL_F4;nakl(1)
              CASE m_key == K_F4
              IF IsLevel(nalog1->oper)
                IF ANSWERu("Занести вiдомостi про покупця?")==YES
                  firm01->(EdFirm03(@a_data));EVAL(RefrGet)
                ENDIF
              ELSE
                DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
              ENDIF
              CASE m_key == K_DOWN;IF n_pole ==LEN(a_get);ELSE;n_pole:=n_pole+1;END
              CASE m_key == K_ESC;BeepErr();IF ALERT("Все изменения будут анулированы;Выходить ?",{"Да","Нет"})==1;EXIT;END
              CASE m_key == K_F12.OR. m_key == K_CTRL_END
                IF NetRLOCK();n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  EXIT
                ELSE;DispError("Невозможно заблокировать запись");END
              CASE m_key == K_ENTER ;WinSay
              IF IsLevel(nalog1->oper)
                ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
                IF a_say[n_pole] # NIL .AND. VALTYPE(a_say[n_pole][1])<>"A"
                  SETPOS(a_say[n_pole][1],a_say[n_pole][2])
                  DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
                ENDIF
              ELSE
                DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
              ENDIF
            CASE m_key = K_TAB
               m_state:="4"
            CASE m_key = K_F2
                IF NetRLOCK();i:=n_pole;n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  PrNewnalog(a_data,a_pred01[7],a_pred01[8])
                  n_pole:=i
                ELSE;DispError("Невозможно заблокировать запись");END
          ENDCASE
         CASE m_state=="4"
            select nalog2
            m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
            lApnd:=.f.;EVAL(m_browse1:GotopBlock)
            IF .NOT.nalog2->vnum==nalog1->vnum //m_browse1:hitBottom
              IF ANSWER("Данных по материалам нет !;Будем вводить ?")<>YES
                select nalog1;m_state:="0"
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
                    m_recno:=nalog2->(RECNO())
                    EVAL(m_browse1:GotopBlock)
                    DO WHILE .NOT.nalog2->(EOF()).AND.nalog2->vnum==nalog1->vnum
                      m_sum+=nalog2->stm;m_nds+=nalog2->nds
                      nalog2->(DBSKIP())
                    ENDDO
                    @MAXROW()-1,22 SayDisp SumToStr(m_sum,16) COLOR TOKEN(m_browse:colorspec,",",6)
                    nalog2->(DBGOTO(m_recno))
                  CASE m_key==K_ESC
                    m_sum:=m_nds:=0
                    m_recno:=nalog2->(RECNO())
                    EVAL(m_browse1:GotopBlock)
                    DO WHILE .NOT.nalog2->(EOF()).AND.nalog2->vnum==nalog1->vnum
                      m_sum+=nalog2->stm;m_nds+=nalog2->nds
                      nalog2->(DBSKIP())
                      @MAXROW()-1,22 SayDisp SumToStr(m_sum,16) COLOR TOKEN(m_browse:colorspec,",",6)
                    ENDDO
                    IF nalog1->(NetRLOCK())
                      nalog1->nds:=m_nds;nalog1->sum:=m_sum;nalog1->(dbUnlock())
                    ENDIF
                    nalog2->(DBGOTO(m_recno))
                    m_state:="0";EXIT
                  CASE m_key = K_TAB
                    m_sum:=m_nds:=0
                    m_recno:=nalog2->(RECNO())
                    EVAL(m_browse1:GotopBlock)
                    DO WHILE .NOT.nalog2->(EOF()).AND.nalog2->vnum==nalog1->vnum
                      m_sum+=nalog2->stm;m_nds+=nalog2->nds
                      nalog2->(DBSKIP())
                      @MAXROW()-1,22 SayDisp SumToStr(m_sum,16) COLOR TOKEN(m_browse:colorspec,",",6)
                    ENDDO
                    IF nalog1->(NetRLOCK())
                      nalog1->nds:=m_nds;nalog1->sum:=m_sum;nalog1->(dbUnlock())
                    ENDIF
                    nalog2->(DBGOTO(m_recno))
                    m_state:="0";EXIT
                DEAL BROWSE m_browse1 KEY m_key
                CASE m_key==K_ENTER   // .OR.Lapnd
                  IF IsLevel(nalog1->oper)
                      IF NetRLOCK()
                        m_browse1:refreshCurrent()
                        STABILIZE BROWSE m_browse1
                        a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                        ReadMy({a_get1[m_browse1:ColPos]},;
                        IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
                        IF .NOT.EMPTY(a_dop)
                          nalog2->name :=a_dop[2];nalog2->izm  :=a_dop[3]
                          nalog2->prise:=SetPrise("1",a_dop)
                          SetStm()
                          a_dop:={}
                        ENDIF
                        dbUNLOCK()
                      ELSE
                        DispError("Невозможно заблокировать запись")
                      ENDIF
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
                CASE m_Key == K_DEL                                    /* удаление записи */
                  IF IsLevel(nalog1->oper)
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
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
                CASE m_Key == K_INS
                  IF IsLevel(nalog1->oper)
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
                      IF nalog2->(NetDbAp())
                        nalog2->vnum:=nalog1->vnum
                        EVAL(m_block,m_buf)
                        FOR i:=2 TO m_browse1:ColCount
                          m_browse1:right();m_browse1:refreshCurrent()
                          STABILIZE BROWSE m_browse1
                          a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
//                          ReadMoDal({a_get1[m_browse1:ColPos]})
                          ReadMy({a_get1[m_browse1:ColPos]},;
                              IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
                          IF .NOT.EMPTY(a_dop)
                            nalog2->name :=a_dop[2];nalog2->izm  :=a_dop[3]
                            nalog2->prise:=SetPrise("1",a_dop)
                            SetStm()
                            a_dop:={}
                          ENDIF
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
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
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
        select nalog1;n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
          a_data[1]:=DATE()
          m_ndoc:=a_data[2]:=STR(fvnum->ndoc,6)
          Display Get a_get KEY n_pole SAY a_say DATA a_data
          n_pole:=1
          DO WHILE .t.
            IF a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A".AND.a_say[n_pole][1][1]==ASC("?")
              KEYBOARD(ASC("?"))
            ENDIF
            ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
            IF a_say[n_pole] # NIL.AND. VALTYPE(a_say[n_pole][1])<>"A"
              SETPOS(a_say[n_pole][1],a_say[n_pole][2])
              DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
            END
            DO CASE;CASE LASTKEY() == K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT
              CASE LASTKEY() == K_PGUP
                n_pole:=1
              CASE LASTKEY() == K_PGDN
                n_pole:=LEN(a_get)-1
              CASE LASTKEY() == K_UP.AND.n_pole # 1;n_pole--;LOOP
              CASE n_pole == LEN(a_get)
                IF NALOG1->(NetDbAp());n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  nalog1->oper:=m_oper;nalog1->vdoc:="1"
                  EXIT
                ELSE;DispError("Невозможно добавить запись");END
              CASE n_pole == 1.AND.EMPTY(a_data[1]);l_stop:=.f.;EXIT
              OTHERWISE ;n_pole++
            ENDCASE
          ENDDO
        IF LASTKEY()==K_ESC.OR..NOT.l_stop
          EXIT
        ENDIF
          IF fvnum->(NetRlock())
            IF m_ndoc<>a_data[2].AND.ANSWERu("Присвоїти податковiй накладнiй; номер "+a_data[2]+" ?")==YES
              nalog1->ndoc:=a_data[2]
            ELSE
              nalog1->ndoc:=STR(fvnum->ndoc,LEN(nalog1->ndoc))
              fvnum->ndoc:=fvnum->ndoc+1
              a_data[2]:=nalog1->ndoc;n_pole:=2;a_get[n_pole]:display()
            ENDIF
//            fvnum->name:="Ввод накладної N "+STR(fvnum->ndoc,6)
            nalog1->vnum:=STR(fvnum->vnum,6)
            fvnum->vnum:=fvnum->vnum+1
            fvnum->(DBCOMMIT())
            fvnum->(DbUnlock())
          ELSE
            DispError("Вiдмовлено в доступi")
            EXIT
          ENDIF
          dbUnlock()
        select nalog2
        m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
        EVAL(m_browse1:GotopBlock);lApnd:=.t.
        Display Browse m_browse1
        m_block:=a_get1[1]:block;m_buf:=EVAL(m_block)
        m_valid1:=a_get1[1]:postBlock;a_get1[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid1,x))}
        a_get1[1]:block:={|x|IF(x==NIL,m_buf,m_buf:=x)}
        m_sum:=m_nds:=0
        l_firstline:=.t.
        @MAXROW()-1,22 SayDisp SumToStr(m_sum,16) COLOR TOKEN(m_browse:colorspec,",",6)
        DO WHILE .t.
          STABILIZE BROWSE m_browse1
          SET ESCAPE ON
          m_buf:=IF(l_firstline,CTOD(""),EVAL(m_block))
          a_get1[1]:row:=ROW();a_get1[1]:col:=COL()
          ReadMy({a_get1[m_browse1:ColPos]},;
              IF(a_say1[1]#NIL.AND.VALTYPE(a_say1[1][1])=="A",a_say1[1],NIL))
          SET ESCAPE OFF
          IF LASTKEY()<>K_ESC.AND..NOT.EMPTY(m_buf)
            IF nalog2->(NetDbAp())
              nalog2->vnum:=nalog1->vnum
              EVAL(m_block,m_buf)
              FOR i:=2 TO m_browse1:ColCount
                m_browse1:right();m_browse1:refreshCurrent()
                STABILIZE BROWSE m_browse1
                a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                ReadMy({a_get1[m_browse1:ColPos]},;
                    IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
              IF .NOT.EMPTY(a_dop)
                nalog2->name :=a_dop[2];nalog2->izm  :=a_dop[3]
                nalog2->prise:=SetPrise("1",a_dop)
                SetStm()
                a_dop:={}
              ENDIF
              NEXT
            ELSE
              DispError("Невозможно добавить запись")
            ENDIF
            m_sum+=nalog2->stm
            m_nds+=nalog2->nds
            @MAXROW()-1,22 SayDisp SumToStr(m_sum,16) COLOR TOKEN(m_browse:colorspec,",",6)
            m_browse1:panHome();m_browse1:down()
            l_firstline:=.f.
            nalog2->(DbUnLock())
          ELSE
            lApnd:=.f.;a_get1[1]:block:=m_block;a_get1[1]:postBlock:=m_valid1
            @MAXROW()-1,22 SayDisp SumToStr(m_sum,16) COLOR TOKEN(m_browse:colorspec,",",6)
            EXIT
          ENDIF
        ENDDO
        IF nalog1->(NetRlock())
          nalog1->nds:=m_nds;nalog1->sum:=m_sum;nalog1->(dbUnlock())
        ENDIF
      ENDDO
      a_get[1]:postBlock:=m_valid
      Wselect(n_win)
      m_browse:refreshAll()
   FINISH LIST
   WCLOSE(n_win);WCLOSE(n_win1)
   WSELECT(0)
   READEXIT(m_exit)
  SETKEY(K_CTRL_F2,NIL)
  SETKEY(K_F4,k_f4)
  SETKEY(K_F4,k_f3)
  SETKEY(K_CTRL_F4,k_Ctrlf4)
//  CLOSE base nalog1,nalog2,spr01
  IF fvnum->(NetRlock())
//    fvnum->name:=BLANK(fvnum->name,.t.)
    fvnum->reg:=CLEARBIT(fvnum->reg,m_computer)
    fvnum->(DBCOMMIT())
    fvnum->(DbUnlock())
  ELSE
    DispError("Вiдмовлено в доступi")
  ENDIF
  IF EMPTY(l_mode)
    ScloseFile(s_files)
    CloseFl1()
  ENDIF
  SavePar(1)
  ENDIF

RETURN .t.
STATIC function Color2(var)
LOCAL x:={21,21},i:=ASC(var)
DO CASE
  CASE var==" "   // Исходное состояние
    x:={6,6}
  CASE ISBIT(i,3) // Аннулированная накладная
    x:={18,18}
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1) // Получена , но не оплачена
    x:={17,17}
  CASE ISBIT(i,2).AND.ISBIT(i,1) // Оплачена и получена
    x:={20,20}
  CASE .NOT.ISBIT(i,2).AND.ISBIT(i,1) // Оплачена, но не получена
    x:={19,19}
  CASE ISBIT(i,4) // Невыписанная накладная
    x:={20,20}
ENDCASE
RETURN x
STATIC Function MyFunc1(x)
LOCAL y:={0,0}
y[1]:=x[2];y[2]:=x[2]
return y
STATIC Function PrintLs()
LOCAL m_file,m_ddoc,c_key,m_buf,GetList:={}
LOCAL i,j,k,c_dov
        // Ввести дату
        savepar()
        m_ddoc:=nalog1->ddoc
        @INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+3,75 BOX B_DOUBLE+" " COLOR ("w+/bg")
        @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( 'Введите значение даты для распечатки',68) COLOR "GR+/bg"
        @INT((MAXROW()-4)/2)+2,38 GET m_ddoc COLOR "w/b,Gr+/n"
        READ
        IF LASTKEY()==K_ESC
          SavePar(1)
          RETURN .f.
        ENDIF
        // найти дату
        nalog1->(DBGOBOTTOM())
        DO WHILE .NOT.nalog1->(BOF())
          IF nalog1->ddoc==m_ddoc
            EXIT
          ENDIF
          nalog1->(DBSKIP(-1))
        ENDDO
        IF   nalog1->ddoc<>m_ddoc
          DispError("Накладные за "+DTOC(m_ddoc)+" не обнаружены ")
          SavePar(1)
          RETURN .f.
        ENDIF
        DO WHILE nalog1->ddoc==m_ddoc.AND..NOT.nalog1->(BOF())
          nalog1->(DBSKIP(-1))
        ENDDO
        IF nalog1->ddoc<>m_ddoc
          nalog1->(DBSKIP())
        ENDIF
        m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
        SET PRINTER TO (m_file)
        SET DEVICE TO PRINTER
        // распечатать данные
        @PROW(),0 SAY PADC('Перелiк накладних за '+My_DTOS(m_ddoc),60)+CHR(27)+"M"
        DO WHILE nalog1->ddoc==m_ddoc.AND..NOT.nalog1->(EOF())
          c_key:="";m_buf:=Alltrim(nalog1->fio1)
          DO WHILE nalog1->vnum==nalog2->vnum.AND..NOT.nalog2->(EOF())
            c_key:=c_key+RTRIM(IF(EMPTY(c_key),"",",")+ALLTRIM(nalog2->name)+" ";
+ALLTRIM(STR(nalog2->kvo))+" "+ALLTRIM(nalog2->izm)+IF(nalog2->glv<>0," "+ALLTRIM(STR(nalog2->glv))+" "+ALLTRIM(nalog2->izm2),""))
            nalog2->(DBSKIP())
          ENDDO
          @PROW()+1,0 Say nalog1->ndoc
          @PROW(),7 Say " I "
          j:=RAT(" ",SUBSTR(m_buf,1,28))
          IF j==0.OR.LEN(m_buf)<28
            @PROW(),10 Say SUBSTR(m_buf,1,28)
            m_buf:=SUBSTR(m_buf,29)
          ELSE
            @PROW(),10 Say SUBSTR(m_buf,1,j-1)
            m_buf:=SUBSTR(m_buf,j+1)
          ENDIF
          @PROW(),37 Say " I "
          i:=MAX(RAT(" ",SUBSTR(c_key,1,27)),RAT(",",SUBSTR(c_key,1,27)))
          IF i==0.OR.LEN(c_key)<27
            @PROW(),40 Say SUBSTR(c_key,1,27)
            c_key:=SUBSTR(c_key,28)
          ELSE
            @PROW(),40 Say SUBSTR(c_key,1,i-1)
            c_key:=SUBSTR(c_key,i+1)
          ENDIF
          @PROW(),67 Say " I "
          c_dov:=ALLTRIM(nalog1->dov)
          j:=RAT(" ",SUBSTR(c_dov,1,15))
          IF j==0.OR.LEN(c_dov)<15
            @PROW(),70 Say SUBSTR(c_dov,1,15)
            c_dov:=SUBSTR(c_dov,16)
          ELSE
            @PROW(),70 Say SUBSTR(c_dov,1,j-1)
            c_dov:=SUBSTR(c_dov,j+1)
          ENDIF
//        @PROW(),70 Say ALLTRIM(nalog1->dov)
          DO WHILE .NOT.EMPTY(m_buf).OR..NOT.EMPTY(c_key).OR..NOT.EMPTY(c_dov)
            @PROW()+1,0 SAY ""
            @PROW(),7 Say " I "
            IF .NOT.EMPTY(m_buf)
              j:=RAT(" ",SUBSTR(m_buf,1,28))
              IF j==0.OR.LEN(m_buf)<28
                @PROW(),10 Say SUBSTR(m_buf,1,28)
                m_buf:=SUBSTR(m_buf,29)
              ELSE
                @PROW(),10 Say SUBSTR(m_buf,1,j-1)
                m_buf:=SUBSTR(m_buf,j+1)
              ENDIF
            ENDIF
          @PROW(),37 Say " I "
            IF .NOT.EMPTY(c_key)
              i:=MAX(RAT(" ",SUBSTR(c_key,1,27)),RAT(",",SUBSTR(c_key,1,27)))
              IF i==0.OR.LEN(c_key)<27
                @PROW(),40 Say SUBSTR(c_key,1,27)
                c_key:=SUBSTR(c_key,28)
              ELSE
                @PROW(),40 Say SUBSTR(c_key,1,i-1)
                c_key:=SUBSTR(c_key,i+1)
              ENDIF
            ENDIF
          @PROW(),67 Say " I "
          IF .NOT.EMPTY(c_dov)
            j:=RAT(" ",SUBSTR(c_dov,1,15))
            IF j==0.OR.LEN(c_dov)<15
              @PROW(),70 Say SUBSTR(c_dov,1,15)
              c_dov:=SUBSTR(c_dov,16)
            ELSE
              @PROW(),70 Say SUBSTR(c_dov,1,j-1)
              c_dov:=SUBSTR(c_dov,j+1)
            ENDIF
          ENDIF
          ENDDO
          nalog1->(DBSKIP())
        ENDDO
        @PROW()+1,0 SAY CHR(27)+"P"+REPLICATE("=",60)
        @PROW()+1,0 SAY ""
        SET PRINTER TO
        SET DEVICE TO SCREEN
        IF SPOOLACTIV().AND.SPOOLCOUNT()<8
//        IF Is_Ready_Prn()
            SPOOLADD(m_file)
//        ENDIF
        ELSE
          MyPRINTFILE(m_file)
//          PRINTFILE(m_file,.t.)
        ENDIF
        SavePar(1)
RETURN .t.
STATIC FUnction Getpr01(a_pred01,a_data,var)
LOCAL i
FOR i:=1 TO 6
  a_data[i+var]:=a_pred01[i]
NEXT
RETURN .t.
STATIC Function EdFirm03(a_data,var)
LOCAL a_var:={},i:=IF(var==NIL,9,var)
// EDFIRM02("FIRM01",{"SHORT","KODNDS","ADDR1","ADDR2","TEL","NUMNDS"})
IF Firm01->(Firm01_vl(@a_var,{"SHORT","KODNDS","ADDR1","ADDR2","TEL","NUMNDS"}))
  AEVAL(a_var,{|x|a_data[i++]:=x})
ENDIF
RETURN .t.

STATIC FUNCTION CountStm(m_mode,var)
LOCAL m_nds:=GetNds()
DO CASE
  CASE nalog2->sum1==0.AND.nalog2->sum2==0.AND.nalog2->sum3==0.AND.nalog2->sum4==0
    nalog2->stm:=0;nalog2->nds:=0
  CASE nalog2->sum1<>0
    nalog2->nds:=nalog2->sum1*m_nds;nalog2->stm:=nalog2->sum1+nalog2->nds
  CASE nalog2->sum2<>0
    nalog2->stm:=nalog2->sum2;nalog2->nds:=0
  CASE nalog2->sum3<>0
    nalog2->stm:=nalog2->sum3;nalog2->nds:=0
  CASE nalog2->sum4<>0
    nalog2->stm:=nalog2->sum4;nalog2->nds:=0
ENDCASE
IF m_mode
  DO CASE
    CASE var=="1".AND.nalog2->sum1==0
      nalog2->sum2:=nalog2->kvo*nalog2->prise
      nalog2->nds:=0
      nalog2->stm:=nalog2->sum2
    CASE var=="2".AND.nalog2->sum2==0
      nalog2->sum3:=nalog2->kvo*nalog2->prise
      nalog2->nds:=0
      nalog2->stm:=nalog2->sum3
    CASE var=="3".AND.nalog2->sum3==0
      nalog2->sum4:=nalog2->kvo*nalog2->prise
      nalog2->nds:=0
      nalog2->stm:=nalog2->sum4
    CASE var=="4".AND.nalog2->sum4==0
      nalog2->sum1:=nalog2->kvo*nalog2->prise
      nalog2->nds:=nalog2->sum1*m_nds
      nalog2->stm:=nalog2->sum1+nalog2->nds
  ENDCASE
ENDIF
RETURN .t.
STATIC FUNCTION SetStm()
LOCAL m_nds:=GetNds()
DO CASE
  CASE nalog2->sum1<>0.OR.(nalog2->sum2==0.AND.nalog2->sum3==0.AND.nalog2->sum4==0)
    nalog2->sum1:=nalog2->kvo*nalog2->prise
    nalog2->nds:=nalog2->sum1*m_nds
    nalog2->stm:=nalog2->sum1+nalog2->nds
  CASE nalog2->sum2<>0
    nalog2->sum2:=nalog2->kvo*nalog2->prise
    nalog2->nds:=0
    nalog2->stm:=nalog2->sum2
  CASE nalog2->sum3<>0
    nalog2->sum3:=nalog2->kvo*nalog2->prise
    nalog2->nds:=0
    nalog2->stm:=nalog2->sum3
  CASE nalog2->sum4<>0
    nalog2->sum4:=nalog2->kvo*nalog2->prise
    nalog2->nds:=0
    nalog2->stm:=nalog2->sum4
ENDCASE
RETURN .t.


STATIC Function PrNewNalog(a_data,m_tabnr,m_tabnb)
  LOCAL m_sum:=0,m_nds:=0,i:=1,n_copy,m_kvo,m_rec:=0,m_file,j,m_str
  LOCAL k:=0,l1,m_sum1:=0,m_sum2:=0,m_sum3:=0,m_sum4:=0,m_sumnds:=0,k1:=33
  LOCAL s01,s02,s03
  LOCAL m_page:=1,m_line:=GetEndPage()
  SavePar()
  DBCOMMITALL()
  m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
  m_kvo:=ALERT("Кiлькiсть  экземплярiв; виводимих на друк  ",{" 1 "," 2 "," 3 "," 4 "},"n/bg,w/b,gr/rb")
  IF m_kvo==0
    RETURN .f.
  ENDIF
  nalog2->(DBSEEK(nalog1->vnum))
  DO WHILE .t.
    nalog2->(DBSKIP(-1))
    IF nalog1->VNUM<>nalog2->VNUM
      nalog2->(DBSKIP())
      EXIT
    ENDIF
    IF nalog2->(BOF())
      EXIT
    ENDIF
  ENDDO
  SET PRINTER TO (m_file)
  SET PRINTER ON
  SET CONSOLE OFF
  m_rec:=nalog2->(RECNO())
  FOR n_copy:=1 TO m_kvo
    nalog2->(DBGOTO(m_rec))
    k1:=35;m_page:=1
?CHR(18)+CHR(27)+"M"+CHR(27)+"0"

?"--------------------------------------------"
?"|ОРИГIНАЛ |Видаєтся покупцю      |    X    |             "+CHR(27)+"M"+"ЗАТВЕРЖДЕНО "+CHR(27)+"E"
?"|         |--------------------------------|             "+CHR(27)+"M"+"Наказ Мiнiстерства фiнансiв України"+CHR(27)+"E"
?"|         |Включено до ЄРПН      |         |             "+CHR(27)+"M"+"01.11.2011 N 1379 "+CHR(27)+"E"
?"|         |--------------------------------|"
?"|         |Залишається у продавця|         |"
?"|         |                      |---------|"
?"|         |(тип причини)         |    |    |"
?"|------------------------------------------|"
?"|Копiя (залишається у продавця)            |"
?"|------------------------------------------|"
?'     (Потрiбне видiлити помiткою "Х")'
?""
?""
?CHR(27)+"E"+CHR(27)+"P"+CHR(14)+CHR(27)+"w1       ПОДАТКОВА  НАКЛАДНА"+CHR(20)+CHR(27)+"w0"+CHR(27)+"F"+CHR(27)+"F"
?CHR(15)

s01:=DTOS(Nalog1->ddoc)
s01:="|"+SUBSTR(s01,7,1)+"|"+SUBSTR(s01,8,1)+"|"+SUBSTR(s01,5,1)+"|"+SUBSTR(s01,6,1)+"|"+SUBSTR(s01,1,1)+"|"+SUBSTR(s01,2,1)+"|"+SUBSTR(s01,3,1)+"|"+SUBSTR(s01,4,1)+"|"
s02:=PADL(ALLTRIM(nalog1->ndoc),7,'0')
s02:="|"+SUBSTR(s02,1,1)+"|"+SUBSTR(s02,2,1)+"|"+SUBSTR(s02,3,1)+"|"+SUBSTR(s02,4,1)+"|"+SUBSTR(s02,5,1)+"|"+SUBSTR(s02,6,1)+"|"+SUBSTR(s02,7,1)+"|"
?CHR(27)+"M"+"                                  -----------------                  --------------  ---------"+CHR(27)+"E"
?CHR(27)+"M"+"Дата виписки податкової накладної:"+s01+" Податковий номер "+s02+"/| | | | |"+CHR(27)+"E"
?CHR(27)+"M"+"                                  -----------------                  --------------  ---------"+CHR(27)+"E"
?CHR(27)+"M"+"                                                                                   (номер филiї)"+CHR(27)+"E"


?
?CHR(15)+"Особа (платник      "+CHR(18)+" "+CHR(27)+"E"+LEFT(PADR(ALLTRIM(nalog1->Short),20),20)+CHR(27)+"F"+CHR(18)+"   "+CHR(15)+"Особа (платник      "+CHR(18)+" "+CHR(27)+"E"+LEFT(PADR(ALLTRIM(nalog1->Shortb),30),30)+CHR(27)+"F"+" "
?CHR(15)+"податку) - продавець"+CHR(18)+"                        "+CHR(15)+"податку) - покупець "+CHR(18)+"                                "+CHR(27)+"P"+CHR(15)
?" -------------------------------------------------                   -------------------------------------------------"
?" | "+SUBSTR(nalog1->KodNds,1,1)+" | "+SUBSTR(nalog1->KodNds,2,1)+" | "+SUBSTR(nalog1->KodNds,3,1)+" | "
??SUBSTR(nalog1->KodNds,4,1)+" | "+SUBSTR(nalog1->KodNds,5,1)+" | "+SUBSTR(nalog1->KodNds,6,1)+" | "
??SUBSTR(nalog1->KodNds,7,1)+" | "+SUBSTR(nalog1->KodNds,8,1)+" | "+SUBSTR(nalog1->KodNds,9,1)+" | "+SUBSTR(nalog1->KodNds,10,1)
??" | "+SUBSTR(nalog1->KodNds,11,1)+" | "+SUBSTR(nalog1->KodNds,12,1)+" |                   | "
??SUBSTR(nalog1->KodNdsb,1,1)+" | "+SUBSTR(nalog1->KodNdsb,2,1)+" | "+SUBSTR(nalog1->KodNdsb,3,1)+" | "+SUBSTR(nalog1->KodNdsb,4,1)+" | "
??SUBSTR(nalog1->KodNdsb,5,1)+" | "+SUBSTR(nalog1->KodNdsb,6,1)+" | "+SUBSTR(nalog1->KodNdsb,7,1)+" | "+SUBSTR(nalog1->KodNdsb,8,1)+" | "
??SUBSTR(nalog1->KodNdsb,9,1)+" | "+SUBSTR(nalog1->KodNdsb,10,1)+" | "+SUBSTR(nalog1->KodNdsb,11,1)+" | "+SUBSTR(nalog1->KodNdsb,12,1)+" |"
?" -------------------------------------------------                   -------------------------------------------------"
?CHR(27)+"S0  (iндивiдуальний податковий номер продавця)                "
??"          (iндивiдуальний податковий номер покупця)"+CHR(27)+"T"
?CHR(18)+CHR(27)+"M"+"Мiсце знаходження                             Мiсце знаходження"
?CHR(18)+CHR(27)+"M"+"(податкова адреса) продавця:                  (податкова адреса) покупця:"
?CHR(27)+"E"+nalog1->addr1+"      "+nalog1->addr1b+CHR(27)+"F"
?CHR(27)+"E"+nalog1->addr2+"      "+nalog1->addr2b+CHR(27)+"F"
?"Номер телефону:"+CHR(27)+"E"+nalog1->tel+CHR(27)
??"F                     Номер телефону:"+CHR(27)+"E"+nalog1->telb+CHR(27)+"F"
?CHR(27)+"P"+CHR(15)+"Номер свiдоцтва про реєстрацiю       "+CHR(18)+CHR(27)+"M                    "+CHR(27)+"P"+CHR(15)+"Номер свiдоцтва про реєстрацiю      "+CHR(18)+CHR(27)+"M              "
?CHR(27)+"P"+CHR(15)+"платника на додану вартiсть продавця "+CHR(18)+CHR(27)+"M  "+CHR(27)+"E"+PADR(LTRIM(nalog1->NumNds),10)
??CHR(27)+"F        "+CHR(27)+"P"+CHR(15)+"платника на додану вартiсть покупця "+CHR(18)+CHR(27)+"M  "+CHR(27)+"E"+PADR(LTRIM(nalog1->NumNdsb),10)+CHR(27)+"F"+"  "
?CHR(27)+"P"+CHR(15)+"                                     "+CHR(18)+CHR(27)+"M                        "+CHR(27)+"P"+CHR(15)+"                             "+CHR(18)+CHR(27)+"M               "

?SI+"Вид цивiльно-правового                                   -------------------------     ---------------------------"+DC2
?SI+"       договору        _____________________________ вiд |  |  |  |  |  |  |  |  |  № |                          |"+DC2
?SI+"                        (вид договору)                   -------------------------     ----------------------------"+DC2
?"Форма проведення розрахункiв "+CHR(27)+"E"+nalog1->form+CHR(27)+"F"
SayShp01()
m_sum:=m_sum1:=m_sum2:=m_sum3:=m_sum4:=0;i:=1;m_sumnds:=0
DO WHILE nalog2->VNUM==nalog1->vnum.AND..NOT.nalog2->(EOF())
  m_str:=ALLTRIM(nalog2->name)
  IF i<>1
   ?"|   |----------|----------------------|----------|----|-----------|----------+------------+-------+-------+-----------|-------------|"
   IF k1>=m_line
      ??CHR(K_CTRL_L)+END_LINE
      SayShp01()
      k1:=9;m_page++
    ENDIF
  ENDIF
    k:=1
    DO WHILE .NOT.EMPTY(m_str)
      IF LEN(m_str) > 22
        j:=RAT(" ",SUBSTR(m_str,1,22))
        l1:=IF(j==0,22,j)
      ELSE
        l1:=LEN(m_str)
      ENDIF
      IF k==1
        ?"|"+IF(i==1," I ","   ")+"| "+DTOC(nalog2->ddoc)+" |"+PADR(LEFT(m_str,l1),22)+"|"
??SPACE(10)+"|"
??LEFT(nalog2->izm,4)+"|"+STR(nalog2->kvo,10,2)+" |"+Str(nalog2->prise,9,3)+" |"
        ??IF(nalog2->sum1==0,SPACE(11),STR(nalog2->sum1,11,2))+" |"+IF(nalog2->sum2==0,SPACE(7),STR(nalog2->sum2,7,2))+"|"+IF(nalog2->sum3==0,SPACE(7),STR(nalog2->sum3,7,2))+"|"+IF(nalog2->sum4==0,SPACE(10),STR(nalog2->sum4,10,2))+" |             |"
      ELSE
        ?"|   |          |"+PADR(LEFT(m_str,l1),22)+"|          |    |           |          |            |       |       |           |             |"
      ENDIF
    m_str:=SUBSTR(m_str,l1+1)
    k++
    ENDDO
  i++;m_sum+=nalog2->stm;m_sumnds+=nalog2->nds
  k1+=k
  m_sum1+=nalog2->sum1
  m_sum2+=nalog2->sum2
  m_sum3+=nalog2->sum3
  m_sum4+=nalog2->sum4
  nalog2->(Dbskip())
ENDDO
  ?"|   |----------|----------------------|----------|----|-----------|----------+------------+-------+-------+-----------|-------------|"
  ?"|   | Усього по роздiлу I I    X      |    X     | X  |     X     |          |"+ IF(m_sum1==0,SPACE(11),STR(m_sum1,11,2))+" |"+IF(m_sum2==0,SPACE(7),STR(m_sum2,7,2))+"|"+IF(m_sum3==0,SPACE(7),STR(m_sum3,7,2))+"|"+IF(m_sum4==0,SPACE(10),STR(m_sum4,10,2))+" |             |"
          ?"|---+---------------------------------|----------|----|-----------|----------+------------+-------+-------+-----------|-------------|"
?CHR(27)+"-1| II| Зворотна (заставна тара)        |   X      | Х  |     Х     |    Х     |       Х    |  Х    |   Х   |      Х    |             |"+CHR(27)+"-0"
?CHR(27)+"-1|III| Податок на додану вартiсть      |   X      | X  |     X     |    X     |"+STR(m_sumnds,11,2)+" |       |       |           |"
??CHR(27)+"-1"+SumtoStr(m_sumnds,13)+"|"+CHR(27)+"-0"
          ?"| IV| Загальна сума з ПДВ             |   X      | X  |     X     |    X     |"+STR(m_sumnds+m_sum1,11,2)+" |"
??IF(m_sum2==0,SPACE(7),STR(m_sum2,7,2))+"|"+IF(m_sum3==0,SPACE(7),STR(m_sum3,7,2))+"|"+IF(m_sum4==0,SPACE(10),STR(m_sum4,10,2))+" |"
??SumtoStr(m_sum1+m_sumnds+m_sum2+m_sum3+m_sum4,13)+"|"
   ?"-------------------------------------------------------------------------------------------------------------------------------------"
??CHR(27)+"0"
?CHR(27)+"S0Суми ПДВ , нарахованi (сплаченi) в зв'язку з поставкою товарiв (робiт,послуг), зазначених в цiй накладнiй , "+CHR(27)+"T"
??CHR(13)
??CHR(27)+"S1визначенi правильно, вiдповiдають сумi податкових зобов'язень продавця i включенi до реєстру виданих  "+CHR(27)+"T"
?CHR(27)+"S0та отриманих податкових накладних."+CHR(27)+"T"
??CHR(13)
?CHR(18)+CHR(27)+"M"
?" -----------"
?" |         |"
?" |  М.П.   |"+CHR(27)+"-1"+PADR(SPACE(15)+CHR(27)+"4"+ALLTRIM(_Fio(m_tabn))+CHR(27)+"5",85)+CHR(27)+"-0"
?" |         |" +CHR(27)+"S0  (Пiдпис i прозвище особи , яка склала податкову накладну )"+CHR(27)+"T"
?" -----------"



?"1  "+CHR(15)+CHR(27)+"S0 Зазначається код виду дiяльностi, що передбачає спецiальний режим оподаткування (2, або 3, або 4), "+CHR(27)+"T"
??CHR(13)
??CHR(27)+"S1   у разi складання податкової накладної за такою дiяльнiстю."+CHR(27)+"T"
?"2  "+CHR(15)+CHR(27)+"S0 Дата оплати ставиться у разi попередньої оплати постачання, на яку виписується податкова накладна, для операцiй"+CHR(27)+"T"
??CHR(13)
??CHR(27)+"S1   з постачання товарiв/послуг вiдповiдно до пункту 187.10 статтi 187 роздiлу V Податкового кодексу України."+CHR(27)+"T"
?
?"3  "+CHR(15)+CHR(27)+"S0 _____________________________________________________________________________________________________________"+CHR(27)+"T"
??CHR(13)
??"         "+CHR(15)+CHR(27)+"S1(вiдповiднi пункти (пiдпункти), статтi, пiдроздiли, роздiли Податкового кодексу України, якими передбачено звiльнення вiд оподаткування)"

?CHR(18)+CHR(27)+"M"


k1:=k1+8
IF k1>m_line-9
  m_page++
  ??CHR(K_CTRL_L)+END_LINE
ENDIF
?CHR(18)+CHR(27)+"M"
?CHR(18)+CHR(27)+"P"+CHR(27)+"2"
IF m_page<>1
  WaitMessage("Увага !!! Податкова накладна мiстить "+STR(m_page,2)+" сторiнки; При друкуваннi перегортайте лист !;Для продовження натиснить  будь-яку клавiшу",,.t.)
ENDIF
IF n_copy<>m_kvo.AND.ALERT("Вивiд екземпляра"+STR(n_copy,2)+" завершен;Виконувати прогiн листа?",{"Так "," Нi "},"n/bg,n/w")==1
  ?CHR(K_CTRL_L)
ENDIF
NEXT
IF nalog1->(NetRlock())
  nalog1->pCount:=nalog1->pCount+1
  nalog1->(DbUnlock())
ENDIF

  SET CONSOLE ON
  SET PRINTER OFF
  SET PRINTER TO
  IF SPOOLACTIV().AND.SPOOLCOUNT()<8
//  IF Is_Ready_Prn()
      SPOOLADD(m_file)
//  ENDIF
  ELSE
          MyPRINTFILE(m_file)
//    PRINTFILE(m_file,.t.)
  ENDIF
  SavePar(1)
  RETURN .t.
Function Recurs(var)
  LOCAL i,m_func:=IF(var==NIL,UPPER(PROCNAME(1)),UPPER(var))
  LOCAL s1:="1"
 i := 2
 DO  WHILE i<20.AND..NOT.EMPTY(s1)
  IF (s1:=UPPER(PROCNAME(i)))==m_func
    DispError("Программа вже "+m_func+" активна")
    RETURN .t.
  ENDIF
  i++
 ENDDO
RETURN .f.
Function SetPred01()
    nalog1->short  :=pred01->short
    nalog1->KodNds :=pred01->KodNds
    nalog1->Addr1  :=pred01->Addr1
    nalog1->Addr2  :=pred01->Addr2
    nalog1->tel    :=pred01->tel
    nalog1->NumNds :=pred01->NumNds
RETURN .t.
Function SetFirm01()
      nalog1->shortb  :=firm01->short
      nalog1->KodNdsb :=firm01->KodNds
      nalog1->Addr1b  :=firm01->Addr1
      nalog1->Addr2b  :=firm01->Addr2
      nalog1->telb    :=firm01->tel
      nalog1->NumNdsb :=firm01->NumNds
RETURN .t.

Function Nalog3()
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,n_win1,m_col,m_ddoc,m_file
  LOCAL m_exit:=READEXIT(.T.),l_stop:=.t.
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={},m_buf
  LOCAL a_get1:={},a_data1:={},n_pole1,m_block,a_say1:={},a_brgd:={}
  LOCAL m_browse1,m_ndoc,m_valid,m_valid1,a_dop:={},a_spr01:={},l_firstline:=.t.,m
  LOCAL m_browse2,m_get1b,m_state:="0",m_col1b,a_fam:={},m_sum,m_nds,m_date
  LOCAL k_f4,k_f3,k_Ctrlf4
  DCL MENU
  DCL LIST
  LOCAL m_select:=SELECT(),a_saydop:={},;
  a_pred01:={},a_block:={},;
  do_block:={||.f.},RefrGet:={|k|a_get[n_pole]:UpdateBuffer(),k:=n_pole,n_pole:=1,AEVAL(a_get,{|x|a_get[n_pole]:display(),n_pole++}),n_pole:=k}
  SavePar()
  WSELECT(0)

    NET USE (m_platpath+"FVNUM") NEW
  IF .NOT.f_vnum(7)
    RETURN .f.
  ENDIF
    SopenFiles("100",@s_files)
    OpenFl1()
  NET USE (m_platpath+"Nalog3") INDEX (m_platpath+"Nalog3"),(m_platpath+"Nalog3a") NEW
  NET USE (m_platpath+"Nalog4") INDEX (m_platpath+"Nalog4") NEW
  SET CURSOR OFF
  k_f4:=SETKEY(K_F4,{||firm01->(EdFirm03(@a_data,12)),EVAL(RefrGet)})
  k_f3:=SETKEY(K_F3,{||GetPr01(@a_pred01,@a_data,5),EVAL(RefrGet)})
  k_Ctrlf4:=SETKEY(K_CTRL_F4,{||nakl(1)})
  InitNds()
  Lapnd:=.f.
  a_pred01:={pred01->short,pred01->KodNds,pred01->Addr1,pred01->Addr2,pred01->tel,pred01->NumNds,pred01->tabnr,pred01->tabnb}
  SELECT nalog3
  nalog3->(DBGOTOP())
  INIT GET "NALOG3" TO a_get KEY n_pole DATA a_data SAY a_say
  n_pole1:=1
  SELECT nalog4
  nalog4->(DBGOTOP())
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  CrList1("NALOG3",@m_browse,@l_print)
  n_win1:=InitScr("NALOG3")
  a_get1:=CrGet("NALOG4",a_say1)
  a_say1[1]={K_F2,{||PrintRozr(a_data,a_pred01[7],a_pred01[8])}}
  a_say1[3]={{ASC("?"),{||kaptka_vl(a_get1[3],,@a_dop)}}}
  a_get1[1]:PostBlock:={||.t.}
  a_get1[3]:PostBlock:={|x,l|l:=kpt_vl(x,@a_dop),SetStm3(),l}
  a_get1[4]:PreBlock:={|p|IF(lApnd,IF(EMPTY(nalog4->name),.t.,.f.),.t.)}
  a_get1[5]:PreBlock:={|p|IF(lApnd,IF(EMPTY(nalog4->izm),.t.,.f.),.t.)}
  a_get1[6]:PreBlock:={||IF(nalog4->prise2==0.AND.nalog4->kvo2==0,.t.,.f.)}
  a_get1[7]:PreBlock:={||IF(nalog4->prise2==0.AND.nalog4->kvo2==0,.t.,.f.)}
  a_get1[8]:PreBlock:={||IF(nalog4->prise1==0.AND.nalog4->kvo1==0,.t.,.f.)}
  a_get1[9]:PreBlock:={||IF(nalog4->prise1==0.AND.nalog4->kvo1==0,.t.,.f.)}
  a_get1[10]:PreBlock:={||IF(nalog4->sum2==0.AND.nalog4->sum3==0,.t.,.f.)}
  a_get1[11]:PreBlock:={||IF(nalog4->sum1==0.AND.nalog4->sum3==0,.t.,.f.)}
  a_get1[12]:PreBlock:={||IF(nalog4->sum2==0.AND.nalog4->sum1==0,.t.,.f.)}
  a_get1[13]:PreBlock:={||IF(nalog4->sum1<0,.t.,.f.)}
  a_get1[14]:PreBlock:={||IF(nalog4->sum1<0,.t.,.f.)}
  a_get1[15]:PreBlock:={||IF(nalog4->sum1>0,.t.,.f.)}
  a_get1[16]:PreBlock:={||IF(nalog4->sum1>0,.t.,.f.)}
  a_get1[6]:PostBlock :={||SetStm3()}
  a_get1[7]:PostBlock :={||SetStm3()}
  a_get1[8]:PostBlock :={||SetStm4()}
  a_get1[9]:PostBlock :={||SetStm4()}
  a_get1[10]:PostBlock :={||SetStm5()}

  m_browse1               := TBrowseDB(14,1,MAXROW()-1,MAXCOL()-1)
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_browse1:colsep        := '│'
  m_browse1:SkipBlock     := {|n| SkipDb1(n,{||(nalog3->vnum==nalog4->vnum)},lApnd) }
  m_browse1:goBottomBlock := {||nalog4->(DBSEEK(nalog3->vnum,.f.)),nalog4->(DBEVAL(,,{||(nalog3->vnum==nalog4->vnum)})),nalog4->(dbskip(-1))}
  m_browse1:goTopBlock    := {||nalog4->(DBSEEK(nalog3->vnum,.f.))}
  CrBrCol("NALOG4",@m_browse1)
  i:=1;AEVAL(a_get1,{|x|a_get1[i]:block:=m_browse1:GetColumn(i):Block,;
  m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──"),i++})
  Select nalog3 ; Wselect(n_win)
  SET FILTER TO nalog3->vdoc=="2" // Розрахунок
  m_browse:goBottom()
  ADD menu up_down
  add menu Left_Right
  add menu search
  AADD(a_ver_menu[3][1],"Складний пошук      K_ALT_F7")
  AADD(a_ver_menu[3][2],K_ALT_F7)
  ADD MENU NAME "В~иправлення" ;
  ITEMS {"Добавити   Ins" ,"Виправити  Enter" ,"Удалити    Delete ","Скопiровати F5" } ;
  KEY {K_INS,K_ENTER,K_DEL,K_F5}
  add menu print
//                      1   2    3    4      5    6   7   8   9  10   11   12   13  14   15     16   17   18  19   20     21
  m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w,w/n,n/w,w/b*,b+/w,w/n*,n+/w,w/rb,rb/w,w+/r,w+/n,w+/b*,w+/n*,w+/rb'
  FOR i:=1 TO m_browse:colCount
    m_browse:GetColumn(i):colorBlock:={||{1,2}}
  NEXT
  INIT menu
  DISPLAYLIST
  nalog3->(DBSETRELATION("nalog4",{||nalog3->vnum},"nalog3->vnum"))
  DO WHILE .t.
    m_browse:refReshCurrent()
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},EVAL(m_browse:GetColumn(1):colorBlock))
    STABILIZE BROWSE m_browse
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2(nalog3->state))
    m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},MyFunc1(EVAL(m_browse:GetColumn(1):colorBlock)))
    m_key:=INKEY(0)
    Winsay
    DEAL MENU
    DO CASE
      DEAL BROWSE m_browse KEY m_key
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      CASE m_key==K_SH_F6
        ShiftF6(m_browse,SELECT("NALOG3"))
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_F7
        If .t. //  KaltF7()
          m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
        ENDIF
      CASE m_Key == K_DEL
      DelDoc(m_browse,l_delete,SELECT("NALOG3"),SELECT("NALOG4"))
    CASE m_key==K_ENTER
      WSELECT(n_win1)
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      SELECT nalog3;n_pole:=1
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1;m_state:="0"
      set escape on
      SELECT nalog4
      m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
      WSELECT(n_win1)
      CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
      DISPBOX(m_browse1:nTop-1,m_browse1:nLeft-1,m_browse1:nBottom,m_browse1:nRight+1,"▌─▐▐▐─▌▌ ",m_browse1:colorSpec)
      lApnd:=.f.;EVAL(m_browse1:GotopBlock)
      IF nalog4->vnum==nalog3->vnum //m_browse1:hitBottom
        Stabilize Browse m_browse1
        m_browse1:autolite:=.f.
        m_browse1:DeHilite()
      ENDIF
      DO WHILE .t.
       DO CASE
        CASE m_state=="0"
          select nalog3
          WSELECT(n_win1)
          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
              CASE m_key == K_UP;IF n_pole ==1;ELSE;n_pole:=n_pole-1;END
              CASE m_key == K_F3
              IF IsLevel(nalog3->oper)
                IF ANSWER("Занести вiдомостi про платника?")==YES
                  GetPr01(@a_pred01,@a_data,5);EVAL(RefrGet)
                ENDIF
              ELSE
                DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
              ENDIF
              CASE m_key == K_CTRL_F4;nakl(1)
              CASE m_key == K_F4
              IF IsLevel(nalog3->oper)
                IF ANSWER("Занести вiдомостi про покупця?")==YES
                  firm01->(EdFirm03(@a_data,12));EVAL(RefrGet)
                ENDIF
              ELSE
                DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
              ENDIF
              CASE m_key == K_DOWN;IF n_pole ==LEN(a_get);ELSE;n_pole:=n_pole+1;END
              CASE m_key == K_ESC;BeepErr();IF ALERT("Все изменения будут анулированы;Выходить ?",{"Да","Нет"})==1;EXIT;END
              CASE m_key == K_F12.OR. m_key == K_CTRL_END
                IF NetRLOCK();n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  EXIT
                ELSE;DispError("Невозможно заблокировать запись");END
              CASE m_key == K_ENTER ;WinSay
              IF IsLevel(nalog3->oper)
                ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
                IF a_say[n_pole] # NIL .AND. VALTYPE(a_say[n_pole][1])<>"A"
                  SETPOS(a_say[n_pole][1],a_say[n_pole][2])
                  DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
                ENDIF
              ELSE
                DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
              ENDIF
            CASE m_key = K_TAB
               m_state:="4"
            CASE m_key = K_F2
                IF NetRLOCK();i:=n_pole;n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  PrintRozr(a_data,a_pred01[7],a_pred01[8])
                  n_pole:=i
                ELSE;DispError("Невозможно заблокировать запись");END
          ENDCASE
         CASE m_state=="4"
            select nalog4
            m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
            lApnd:=.f.;EVAL(m_browse1:GotopBlock)
            IF .NOT.nalog4->vnum==nalog3->vnum //m_browse1:hitBottom
              IF ANSWER("Данных по материалам нет !;Будем вводить ?")<>YES
                select nalog3;m_state:="0"
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
                  CASE m_key==K_ESC
                    m_state:="0";EXIT
                  CASE m_key = K_TAB
                    m_state:="0";EXIT
                DEAL BROWSE m_browse1 KEY m_key
                CASE m_key==K_ENTER   // .OR.Lapnd
                  IF IsLevel(nalog3->oper)
                      IF NetRLOCK()
                        m_browse1:refreshCurrent()
                        STABILIZE BROWSE m_browse1
                        a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                        ReadMy({a_get1[m_browse1:ColPos]},;
                        IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
                        dbUNLOCK()
                      ELSE
                        DispError("Невозможно заблокировать запись")
                      ENDIF
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
                CASE m_Key == K_DEL
                  IF IsLevel(nalog3->oper)
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
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
                CASE m_Key == K_INS
                  IF IsLevel(nalog3->oper)
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
                      IF nalog4->(NetDbAp())
                        nalog4->vnum:=nalog3->vnum
                        EVAL(m_block,m_buf)
                        FOR i:=2 TO m_browse1:ColCount
                          m_browse1:right();m_browse1:refreshCurrent()
                          STABILIZE BROWSE m_browse1
                          a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
//                          ReadMoDal({a_get1[m_browse1:ColPos]})
                          ReadMy({a_get1[m_browse1:ColPos]},;
                              IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
                          IF .NOT.EMPTY(a_dop)
                            nalog4->name :=a_dop[2];nalog4->izm  :=a_dop[3]
                            a_dop:={}
                          ENDIF
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
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
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
        select nalog3;n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
          m_ndoc:=a_data[1]:=STR(fvnum->ndoc,6)
//          a_data[2]:=m_ndoc
          Display Get a_get KEY n_pole SAY a_say DATA a_data
          n_pole:=1
          DO WHILE .t.
            IF a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A".AND.a_say[n_pole][1][1]==ASC("?")
              KEYBOARD(ASC("?"))
            ENDIF
            ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
            IF a_say[n_pole] # NIL.AND. VALTYPE(a_say[n_pole][1])<>"A"
              SETPOS(a_say[n_pole][1],a_say[n_pole][2])
              DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
            END
            DO CASE;CASE LASTKEY() == K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT
              CASE LASTKEY() == K_PGUP
                n_pole:=1
              CASE LASTKEY() == K_PGDN
                n_pole:=LEN(a_get)-1
              CASE LASTKEY() == K_UP.AND.n_pole # 1;n_pole--;LOOP
              CASE n_pole == LEN(a_get)
                IF nalog3->(NetDbAp());n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  nalog3->oper:=m_oper;nalog3->vdoc:="2"
                  EXIT
                ELSE;DispError("Невозможно добавить запись");END
              CASE n_pole == 1.AND.EMPTY(a_data[1]);l_stop:=.f.;EXIT
              OTHERWISE ;n_pole++
            ENDCASE
          ENDDO
        IF LASTKEY()==K_ESC.OR..NOT.l_stop
          EXIT
        ENDIF
          IF fvnum->(NetRlock())
            IF m_ndoc<>a_data[1].AND.ANSWERu("Присвоїти розрахунку; номер "+a_data[1]+" ?")==YES
              nalog3->ndoc:=a_data[1]
            ELSE
              nalog3->ndoc:=STR(fvnum->ndoc,LEN(nalog3->ndoc))
              fvnum->ndoc:=fvnum->ndoc+1
            ENDIF
            nalog3->vnum:=STR(fvnum->vnum,6)
            fvnum->vnum:=fvnum->vnum+1
            fvnum->(DBCOMMIT())
            fvnum->(DbUnlock())
          ELSE
            DispError("Вiдмовлено в доступi")
            EXIT
          ENDIF
          dbUnlock()
        select nalog4
        m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
        EVAL(m_browse1:GotopBlock);lApnd:=.t.
        Display Browse m_browse1
        m_block:=a_get1[1]:block;m_buf:=EVAL(m_block)
        m_valid1:=a_get1[1]:postBlock;a_get1[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid1,x))}
        a_get1[1]:block:={|x|IF(x==NIL,m_buf,m_buf:=x)}
        m_sum:=m_nds:=0
        l_firstline:=.t.
        @MAXROW()-1,22 SayDisp SumToStr(m_sum,16) COLOR TOKEN(m_browse:colorspec,",",6)
        DO WHILE .t.
          STABILIZE BROWSE m_browse1
          SET ESCAPE ON
          m_buf:=IF(l_firstline,CTOD(""),EVAL(m_block))
          a_get1[1]:row:=ROW();a_get1[1]:col:=COL()
          ReadMy({a_get1[m_browse1:ColPos]},;
              IF(a_say1[1]#NIL.AND.VALTYPE(a_say1[1][1])=="A",a_say1[1],NIL))
          SET ESCAPE OFF
          IF LASTKEY()<>K_ESC.AND..NOT.EMPTY(m_buf)
            IF nalog4->(NetDbAp())
              nalog4->vnum:=nalog3->vnum
              EVAL(m_block,m_buf)
              FOR i:=2 TO m_browse1:ColCount
                m_browse1:right();m_browse1:refreshCurrent()
                STABILIZE BROWSE m_browse1
                a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                ReadMy({a_get1[m_browse1:ColPos]},;
                    IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
                IF .NOT.EMPTY(a_dop)
                  nalog4->name :=a_dop[2];nalog4->izm  :=a_dop[3]
                  a_dop:={}
                ENDIF
              NEXT
            ELSE
              DispError("Невозможно добавить запись")
            ENDIF
            m_browse1:panHome();m_browse1:down()
            l_firstline:=.f.
            nalog4->(DbUnLock())
          ELSE
            lApnd:=.f.;a_get1[1]:block:=m_block;a_get1[1]:postBlock:=m_valid1
            @MAXROW()-1,22 SayDisp SumToStr(m_sum,16) COLOR TOKEN(m_browse:colorspec,",",6)
            EXIT
          ENDIF
        ENDDO
        IF nalog3->(NetRlock())
          nalog3->nds:=m_nds;nalog3->sum:=m_sum;nalog3->(dbUnlock())
        ENDIF
      ENDDO
      a_get[1]:postBlock:=m_valid
      Wselect(n_win)
      m_browse:refreshAll()
   FINISH LIST
   WCLOSE(n_win);WCLOSE(n_win1)
   WSELECT(0)
   READEXIT(m_exit)
  SETKEY(K_F4,k_f4)
  SETKEY(K_F4,k_f3)
  SETKEY(K_CTRL_F4,k_Ctrlf4)
  IF fvnum->(NetRlock())
    fvnum->reg:=CLEARBIT(fvnum->reg,m_computer)
    fvnum->(DBCOMMIT())
    fvnum->(DbUnlock())
  ELSE
    DispError("Вiдмовлено в доступi")
  ENDIF
    ScloseFile(s_files)
    CloseFl1()
  CLOSE BASE Nalog3,Nalog4
  SavePar(1)
RETURN .t.

STATIC FUNCTION SetStm3()
nalog4->sum1:=nalog4->kvo1*nalog4->prise1
setstm5()
RETURN .t.
STATIC FUNCTION SetStm4()
nalog4->sum1:=nalog4->kvo2*nalog4->prise2
setstm5()
RETURN .t.
STATIC FUNCTION SetStm5()
LOCAL m_nds:=GetNds()
IF Nalog4->sum1<0
  nalog4->sum4:=nalog4->sum5:=m_nds*ABS(nalog4->sum1)
  nalog4->sum6:=nalog4->sum7:=0
ELSE
  nalog4->sum6:=nalog4->sum7:=m_nds*nalog4->sum1
  nalog4->sum4:=nalog4->sum5:=0
ENDIF
RETURN .t.

STATIC Function PrintRozr(a_data,m_tabnr,m_tabnb)
  LOCAL m_sum:=0,m_nds:=0,i:=1,n_copy,m_kvo,m_rec:=0,m_file,j,m_str
  LOCAL k:=0,l1,l2,k1:=33
  LOCAL m_page:=1,m_line:=GetEndPage(),m_str1
//  LOCAL m_str1
  SavePar()
  DBCOMMITALL()
  m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
  m_kvo:=ALERT("Кiлькiсть  екземплярiв; виводимих на друк",{" 1 "," 2 "," 3 "," 4 "},"n/bg,w/b,gr/rb")
  IF m_kvo==0
    RETURN .f.
  ENDIF
  nalog4->(DBSEEK(nalog3->vnum))
  DO WHILE .t.
    nalog4->(DBSKIP(-1))
    IF nalog3->VNUM<>nalog4->VNUM
      nalog4->(DBSKIP())
      EXIT
    ENDIF
    IF nalog4->(BOF())
      EXIT
    ENDIF
  ENDDO
  SET PRINTER TO (m_file)
  SET PRINTER ON
  SET CONSOLE OFF
  m_rec:=nalog4->(RECNO())
  FOR n_copy:=1 TO m_kvo
    nalog4->(DBGOTO(m_rec))
    k1:=35;m_page:=1
?CHR(27)+"M"+CHR(27)+"0"
?"--------------------------------------------"
?"|ОРИГIНАЛ (видаєтся покупцю)      |        |                Додаток N 2"
?"--------------------------------------------             до податкової накладної"
?"|ПЕРША КОПIЯ (видаєтся покупцю)   |        |"
?"--------------------------------------------"
?""
?CHR(27)+"E"+CHR(27)+"P"+CHR(14)+CHR(27)+"w1       РОЗРАХУНОК N "+PADR(LTRIM(nalog3->ndoc),10)+CHR(20)+CHR(27)+"w0"+CHR(27)+"F"+CHR(27)+"F"
?" коригування кiлькiсних i вартiсних показникiв до податкової накладної"
?" вiд "+DTOC(nalog3->ddoc1)+" N "+ALLTRIM(nalog3->ndoc1)+" по договору вiд "+DTOC(nalog3->ddoc2)+" N "+nalog3->ndoc2
??CHR(27)+"M"
?CHR(15)+"                    "+CHR(18)+"                        "+CHR(15)+"                    "+CHR(18)+"                                "
?CHR(15)+"Особа (платник      "+CHR(18)+" "+CHR(27)+"E"+LEFT(PADR(ALLTRIM(nalog3->Short),20),20)+CHR(27)+"F"+CHR(18)+"   "+CHR(15)+"Особа (платник      "+CHR(18)+" "+CHR(27)+"E"+LEFT(PADR(ALLTRIM(nalog3->Shortb),30),30)+CHR(27)+"F"+" "
?CHR(15)+"податку) - продавець"+CHR(18)+"                        "+CHR(15)+"податку) - покупець "+CHR(18)+"                                "+CHR(27)+"P"+CHR(15)
?" -------------------------------------------------                   -------------------------------------------------"
?" | "+SUBSTR(nalog3->KodNds,1,1)+" | "+SUBSTR(nalog3->KodNds,2,1)+" | "+SUBSTR(nalog3->KodNds,3,1)+" | "
??SUBSTR(nalog3->KodNds,4,1)+" | "+SUBSTR(nalog3->KodNds,5,1)+" | "+SUBSTR(nalog3->KodNds,6,1)+" | "
??SUBSTR(nalog3->KodNds,7,1)+" | "+SUBSTR(nalog3->KodNds,8,1)+" | "+SUBSTR(nalog3->KodNds,9,1)+" | "+SUBSTR(nalog3->KodNds,10,1)
??" | "+SUBSTR(nalog3->KodNds,11,1)+" | "+SUBSTR(nalog3->KodNds,12,1)+" |                   | "
??SUBSTR(nalog3->KodNdsb,1,1)+" | "+SUBSTR(nalog3->KodNdsb,2,1)+" | "+SUBSTR(nalog3->KodNdsb,3,1)+" | "+SUBSTR(nalog3->KodNdsb,4,1)+" | "
??SUBSTR(nalog3->KodNdsb,5,1)+" | "+SUBSTR(nalog3->KodNdsb,6,1)+" | "+SUBSTR(nalog3->KodNdsb,7,1)+" | "+SUBSTR(nalog3->KodNdsb,8,1)+" | "
??SUBSTR(nalog3->KodNdsb,9,1)+" | "+SUBSTR(nalog3->KodNdsb,10,1)+" | "+SUBSTR(nalog3->KodNdsb,11,1)+" | "+SUBSTR(nalog3->KodNdsb,12,1)+" |"
?" -------------------------------------------------                   -------------------------------------------------"
?CHR(27)+"S0  (iндивiдуальний податковий номер продавця)                "
??"          (iндивiдуальний податковий номер покупця)"+CHR(27)+"T"
?CHR(18)+CHR(27)+"M"+"Мiсце знаходження продавця:                   Мiсце знаходження покупця:"
?CHR(27)+"E"+nalog3->addr1+"      "+nalog3->addr1b+CHR(27)+"F"
?CHR(27)+"E"+nalog3->addr2+"      "+nalog3->addr2b+CHR(27)+"F"
?"Номер телефону:"+CHR(27)+"E"+nalog3->tel+CHR(27)
??"F                     Номер телефону:"+CHR(27)+"E"+nalog3->telb+CHR(27)+"F"
?CHR(27)+"P"+CHR(15)+"Номер свiдоцтва про реєстрацiю       "+CHR(18)+CHR(27)+"M                    "+CHR(27)+"P"+CHR(15)+"Номер свiдоцтва про реєстрацiю      "+CHR(18)+CHR(27)+"M              "
?CHR(27)+"P"+CHR(15)+"платника на додану вартiсть продавця "+CHR(18)+CHR(27)+"M  "+CHR(27)+"E"+PADR(LTRIM(nalog3->NumNds),10)
??CHR(27)+"F        "+CHR(27)+"P"+CHR(15)+"платника на додану вартiсть покупця "+CHR(18)+CHR(27)+"M  "+CHR(27)+"E"+PADR(LTRIM(nalog3->NumNdsb),10)+CHR(27)+"F"+"  "
?"Умова продажу "+CHR(27)+"E"+nalog3->sal+SPACE(14)+CHR(27)+"F"
?"Дата оплати "+CHR(27)+"E"+DTOC(nalog3->ddoc)+SPACE(14)+CHR(27)+"F"
?"Форма проведення розрахункiв "+CHR(27)+"E"+nalog3->form+CHR(27)+"F"
??CHR(27)+"M"+CHR(15)
PrintShp1()
i:=1
DO WHILE nalog4->VNUM==nalog3->vnum.AND..NOT.nalog4->(EOF())
  m_str:=ALLTRIM(nalog4->name)
  m_str1:=ALLTRIM(nalog4->reas)
  IF i<>1
      ?"|--------|----------------|------------------|-----|----------|--------|--------|----------|----------|-------|--------|---------|---------|---------|---------|"
   IF k1>=m_line
      ??CHR(K_CTRL_L)+END_LINE
      PrintShp1()
      k1:=9;m_page++
   ENDIF
  ENDIF
    k:=1
    DO WHILE .NOT.EMPTY(m_str).OR..NOT.EMPTY(m_str1)
      j:=RAT(" ",LEFT(m_str,18))
      IF LEN(m_str)>18
        l1:=IF(j==0,18,j)
      ELSE
        l1:=LEN(m_str)
      ENDIF
      j:=RAT(" ",LEFT(m_str1,16))
      IF LEN(m_str1)>16
        l2:=IF(j==0,16,j)
      ELSE
        l2:=LEN(m_str1)
      ENDIF
      IF k==1
        ?"|"+DTOC(nalog4->ddoc)+"|"+PADR(LEFT(m_str1,l2),16)+"|"+PADR(LEFT(m_str,l1),18)+"|"+LEFT(nalog4->izm,5)+"|"
        ??IF(nalog4->kvo1==0,SPACE(10),STR(nalog4->kvo1,10,2))+"|"+IF(nalog4->prise1==0,SPACE(8),Str(nalog4->prise1,8,2))+"|"
        ??IF(nalog4->prise2==0,SPACE(8),STR(nalog4->prise2,8,2))+"|"+IF(nalog4->kvo2==0,SPACE(10),STR(nalog4->kvo2,10,2))+"|"
        ??IF(nalog4->sum1==0,SPACE(10),STR(nalog4->sum1,10,2))+"|"
        ??IF(nalog4->sum2==0,SPACE(7),STR(nalog4->sum2,7,2))+"|"
        ??IF(nalog4->sum3==0,SPACE(8),STR(nalog4->sum3,8,2))+"|"
        ??IF(nalog4->sum4==0,SPACE(9),STR(nalog4->sum4,9,2))+"|"
        ??IF(nalog4->sum4==0,SPACE(9),STR(nalog4->sum4,9,2))+"|"
        ??IF(nalog4->sum6==0,SPACE(9),STR(nalog4->sum6,9,2))+"|"
        ??IF(nalog4->sum6==0,SPACE(9),STR(nalog4->sum6,9,2))+"|"
      ELSE
        ?"|        |"+PADR(LEFT(m_str1,l2),16)+"|"+PADR(LEFT(m_str,l1),18)+"|     |          |        |        |          |          |       |        |         |         |         |         |"
      ENDIF
    m_str:=SUBSTR(m_str,l1+1)
    m_str1:=SUBSTR(m_str1,l2+1)
    k++
    ENDDO
  nalog4->(Dbskip())
ENDDO

?"|--------|----------------|------------------|-----|----------|--------|--------|----------|----------|-------|--------|---------|---------|---------|---------|"
??CHR(27)+"0"+CHR(18)+CHR(27)+"M"
?CHR(27)+"S0Суми ПДВ , нарахованi (сплаченi) в зв'язку iз змiною кiлькiсних чи вартiсних показникiв, що"
??CHR(13)
??CHR(27)+"S1зазначенi у цьому розрахунку, визначенi правильно та включенi вiдповiдно до податкового зо-"
?CHR(27)+"S0бов'язання з одночасним вiдображенням у реєстрi отриманих та виданих податкових накладних."+CHR(27)+"T"
?CHR(18)+CHR(27)+"M"
?CHR(27)+"-1"+PADR(SPACE(25)+CHR(27)+"4"+ALLTRIM(_Fio(m_tabn))+CHR(27)+"5",85)+CHR(27)+"-0"
?CHR(27)+"S0     М.П.          (Пiдпис i прозвище особи , яка склала розрахунок коригування )"+CHR(27)+"T"
k1:=k1+8
IF k1>m_line-9
  m_page++
  ??CHR(K_CTRL_L)+END_LINE
ENDIF
?CHR(18)+CHR(27)+"M"
/*
?"Керiвник"+"           "+CHR(27)+"-1            /"+CHR(27)+"E"+CHR(27)+"4"+ALLTRIM(_Fio(m_tabnr))+CHR(27)+"5"+CHR(27)+"F"+"/"+CHR(27)+"-0"
?"                         "+CHR(27)+"S0(пiдпис, прiзвище)"+CHR(27)+"T                  -----------"
?"                                                             |         |"
?"Головний бухгалтер "+CHR(27)+"-1            /"+CHR(27)+"E"+CHR(27)+"4"+PADR(ALLTRIM(_Fio(m_tabnb))+CHR(27)+"5"+CHR(27)+"F"+"/",21)+CHR(27)+"-0            |  М.П.   |"
?"                         "+CHR(27)+"S0(пiдпис, прiзвище)"+CHR(27)+"T                  |         |"
?"                                                             -----------"
?""
*/
?CHR(18)+CHR(27)+"M"+"Розрахунок коригування вiд _____________ № "+CHR(27)+"E"+LTRIM(nalog3->ndoc)
??CHR(27)+"F"+" до податкової накладної"
??"вiд "+CHR(27)+"E"+padr(my_dtos(nalog3->ddoc1),19)
?" N "+ALLTRIM(nalog3->ndoc1)
??CHR(27)+"F отримав i зобов'язуюсь включити суми коригування до книги реєстру отриманих та виданих"
?CHR(18)+"податкових накладних та сум податкового кредиту i податкового зобов'язання"+CHR(27)+"-1"+SPACE(30)+CHR(27)+"-0"
?CHR(18)+CHR(27)+"P"+CHR(27)+"2"
?CHR(15)+SPACE(31)+CHR(27)+"S0(дата отримання, пiдпис посадової особи покупця)"+CHR(27)+"T"
IF m_page<>1
  WaitMessage("Увага !!! Розрахунок мiстить "+STR(m_page,2)+" сторiнки; При друкуваннi перегортайте лист !;Для продовження натиснить  будь-яку клавiшу",,.t.)
ENDIF
IF n_copy<>m_kvo.AND.ALERT("Вивiд екземпляра"+STR(n_copy,2)+" завершен;Виконувати прогiн листа?",{"Так "," Нi "},"n/bg,n/w")==1
  ?CHR(K_CTRL_L)
ENDIF
NEXT
IF nalog3->(NetRlock())
  nalog3->pCount:=nalog3->pCount+1
  nalog3->(DbUnlock())
ENDIF
  SET CONSOLE ON
  SET PRINTER OFF
  SET PRINTER TO
  IF SPOOLACTIV().AND.SPOOLCOUNT()<8
//  IF Is_Ready_Prn()
      SPOOLADD(m_file)
//  ENDIF
  ELSE
          MyPRINTFILE(m_file)
//    PRINTFILE(m_file,.t.)
  ENDIF
  SavePar(1)
RETURN .t.
STATIC Function PrintShp1
?"----------------------------------------------------------------------------------------------------------------------------------------------------------------"
??CHR(27)+"3"+CHR(17)
?CHR(27)+"S0| Дата   |                |Номенклатура пос- | Оди-|    Коригування    |    Коригування    |Пiдлягають коригуванню об- | Проведення коригування податкового    |"+CHR(27)+"T"
?CHR(27)+"S0| кори-  |                |тавки товарiв (пос| ниця|     кiлькостi     |     вартостi      |сяги без урахування ПДВ,що | зобов'язання та податкового кредиту   |"+CHR(27)+"T"
?CHR(27)+"S0|гування |    Причина     |луг), вартисть чи | ви- |-------------------|-------------------|оподатковуються за ставками|---------------------------------------|"+CHR(27)+"T"
?CHR(27)+"S0|        |   коригування  |кiлькiсть яких    | мiру| змiна    | цiна   | змiна  |кiлькiсть |---------------------------|При вiд'ємному     |При позитивному    |"+CHR(27)+"T"
?CHR(27)+"S0|        |                |коригується       | то- |кiлькостi,|поставки|  цiни  | поставки |  20 %    |  0 %  |звiль-  |значеннi  графи 9  |значеннi графи 9   |"+CHR(27)+"T"
?CHR(27)+"S0|        |                |                  | вару| об'єму,  |товарiв | (-) (+)| товарiв  | (-) (+)  |(-) (+)|ненi вiд|---------------------------------------|"+CHR(27)+"T"
?CHR(27)+"S0|        |                |                  |     | обсягу   |(послуг)|        | (послуг) |          |       |ПДВ ст.5|податк.  |податк.  |податк.  |податк.  |"+CHR(27)+"T"
?CHR(27)+"S0|        |                |                  |     |(-) (+)   |        |        |          |          |       | (-) (+)|зобов.   |  кредит |зобов.   |  кредит |"+CHR(27)+"T"
?CHR(27)+"S0|        |                |                  |     |          |        |        |          |          |       |        |продавця | покупця |продавця | покупця |"+CHR(27)+"T"
?CHR(27)+"S0|        |                |                  |     |          |        |        |          |          |       |        |зменш.   |зменш.   |збiльш.  |збiльш.  |"+CHR(27)+"T"
?CHR(27)+"S0|        |                |                  |     |          |        |        |          |          |       |        |гр.9х(-) |гр.9(-)х |гр.9(-)х |гр.9(-)х |"+CHR(27)+"T"
?CHR(27)+"S0|        |                |                  |     |          |        |        |          |          |       |        | х 20%   |  х 20%  |  х 20%  | х 20%   |"+CHR(27)+"T"
?CHR(27)+"S0--------------------------------------------------------------------------------------------------------------------------------------------------------------- "+CHR(27)+"T"
      ?"|   1    |       2        |         3        |  4  |     5    |    6   |    7   |      8   |    9     |  10   |   11   |   12    |    13   |   14    |    15   |"
      ?"|--------|----------------|------------------|-----|----------|--------|--------|----------|----------|-------|--------|---------|---------|---------|---------|"
RETURN .t.
STATIC FUNCTION SetStm6(x)
LOCAL m_nds:=GetNds()
  DO CASE
    CASE nalog2->sum1<>0
      nalog2->sum1:=x/(1+m_nds)
      Nalog2->prise:=IF(nalog2->kvo<>0,nalog2->sum1 / nalog2->kvo,0)
      Nalog2->nds:=nalog2->sum1*m_nds
    CASE nalog2->sum2<>0
      nalog2->sum2:=x
      Nalog2->prise:=IF(nalog2->kvo<>0,nalog2->sum2 / nalog2->kvo,0)
      Nalog2->nds:=0
    CASE nalog2->sum3<>0
      nalog2->sum3:=x
      Nalog2->prise:=IF(nalog2->kvo<>0,nalog2->sum3 / nalog2->kvo,0)
      Nalog2->nds:=0
    CASE nalog2->sum4<>0
      nalog2->sum4:=x
      Nalog2->prise:=IF(nalog2->kvo<>0,nalog2->sum4 / nalog2->kvo,0)
      Nalog2->nds:=0
  ENDCASE
  Nalog2->stm:=x
RETURN x
Function Nalog2()
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,m_col,m_ddoc,m_file
  LOCAL m_exit:=READEXIT(.T.),n_win1,n_pole,a_get:={},a_data:={}
  LOCAL m_get:=GetNew(),c_key,a_say:={},m_buf,m_select:=SELECT(),m_valid,l_stop:=.f.
  DCL MENU
  DCL LIST
  SavePar()
  WSELECT(0)
  Firm01->(DBSetOrder(3))
  SET CURSOR OFF
  InitNds()
  Lapnd:=.f.
  USE (m_platpath+"nalog5") INDEX (m_platpath+"nalog5"),(m_platpath+"nalog5a") NEW
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  CrList1("NALOG5",@m_browse,@l_print)
  n_win1:=InitScr("NALOG5")
  WSELECT(n_win)
  INIT GET "NALOG5" TO a_get KEY n_pole DATA a_data SAY a_say
  a_get[4]:PostBlock:={||Firm01->(firm01_vl(,,3))}
  a_say[4]:={4,35,"","GR+/B",{||Firm01->(DBSEEK(a_data[4])),Firm01->short}}
  a_say[5]:={7,32,"","GR+/B",{||SumToStr(a_data[5]+a_data[6],12)}}
  a_say[6]:={7,32,"","GR+/B",{||SumToStr(a_data[5]+a_data[6],12)}}
  a_get[5]:picture:=a_get[6]:picture:="99999999.99"
  m_browse:goBottom()
  ADD menu up_down
  add menu Left_Right
  add menu search
  AADD(a_ver_menu[3][1],"Сложный поиск      K_ALT_F7")
  AADD(a_ver_menu[3][2],K_ALT_F7)
  ADD MENU NAME "~Изменение" ;
  ITEMS {"Добавить   Ins" ,"Исправить  Enter" ,"Удалить    Delete ","Скопировать F5" } ;
  KEY {K_INS,K_ENTER,K_DEL,K_F5}
  add menu print
//                      1   2    3    4      5    6   7   8   9  10   11   12   13  14   15     16   17   18  19   20     21
  m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w,w/n,n/w,w/b*,b+/w,w/n*,n+/w,w/rb,rb/w,w+/r,w+/n,w+/b*,w+/n*,w+/rb'
  FOR i:=1 TO m_browse:colCount
    m_browse:GetColumn(i):colorBlock:={||{1,2}}
  NEXT
  INIT menu
  DISPLAYLIST
  DO WHILE .t.
    m_browse:refReshCurrent()
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},EVAL(m_browse:GetColumn(1):colorBlock))
    STABILIZE BROWSE m_browse
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},"w+/b")
    m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},"b/w")
    m_key:=INKEY(0)
    Winsay
    DEAL MENU
    DO CASE
      DEAL BROWSE m_browse KEY m_key
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      CASE m_key==K_SH_F6
        ShiftF6(m_browse,SELECT("Nalog5"))
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_F7
        If .t. //  KaltF7()
          m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
        ENDIF
      CASE m_Key == K_DEL                                    /* удаление записи */
        IF l_delete.OR.( ANSWERu( "Ви дiйсно бажаєте видалити запис ?" )==YES )
          IF NetRlock()
              dbdelete()
            UNLOCK
          ELSE
            DispErr("Файл заблокирован")
          ENDIF
          DBSKIP(-1)
          DBSKIP(1)
          m_browse:RefreshAll()
        ENDIF
    CASE m_key==K_ENTER
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
          WSELECT(n_win1)
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1
      set escape on
      DO WHILE .t.
          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
              CASE m_key == K_UP;IF n_pole ==1;ELSE;n_pole:=n_pole-1;END
              CASE m_key == K_DOWN;IF n_pole ==LEN(a_get);ELSE;n_pole:=n_pole+1;END
              CASE m_key == K_ESC;BeepErr();IF ALERT("Все изменения будут анулированы;Выходить ?",{"Да","Нет"})==1;EXIT;END
              CASE m_key == K_F12.OR. m_key == K_CTRL_END
                IF NetRLOCK();n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  EXIT
                ELSE;DispError("Невозможно заблокировать запись");END
              CASE m_key == K_ENTER ;WinSay
              IF IsLevel(nalog1->oper)
                ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
                IF a_say[n_pole] # NIL .AND. VALTYPE(a_say[n_pole][1])<>"A"
                  SETPOS(a_say[n_pole][1],a_say[n_pole][2])
                  DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
                ENDIF
              ELSE
                DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
              ENDIF
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
        n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
        a_data[2]:=DATE()
        Display Get a_get KEY n_pole SAY a_say DATA a_data
        n_pole:=1
          DO WHILE .t.
            IF a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A".AND.a_say[n_pole][1][1]==ASC("?")
              KEYBOARD(ASC("?"))
            ENDIF
            ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
            IF a_say[n_pole] # NIL.AND. VALTYPE(a_say[n_pole][1])<>"A"
              SETPOS(a_say[n_pole][1],a_say[n_pole][2])
              DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
            END
            DO CASE;CASE LASTKEY() == K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT
              CASE LASTKEY() == K_PGUP
                n_pole:=1
              CASE LASTKEY() == K_PGDN
                n_pole:=LEN(a_get)-1
              CASE LASTKEY() == K_UP.AND.n_pole # 1;n_pole--;LOOP
              CASE n_pole == LEN(a_get)
                IF NALOG5->(NetDbAp());n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  EXIT
                ELSE;DispError("Невозможно добавить запись");END
              CASE n_pole == 1.AND.EMPTY(a_data[1]);l_stop:=.f.;EXIT
              OTHERWISE ;n_pole++
            ENDCASE
          ENDDO
        IF LASTKEY()==K_ESC.OR..NOT.l_stop
          EXIT
        ENDIF
      ENDDO
      a_get[1]:postBlock:=m_valid
      Wselect(n_win)
      m_browse:refreshAll()

   FINISH LIST
   WCLOSE(n_win1)
   WCLOSE(n_win)
   WSELECT(0)
   READEXIT(m_exit)
  CLOSE base Nalog5
  Firm01->(DBSetOrder(1))
  SavePar(1)
RETURN .t.
STATIC Function Sayshp01()

??CHR(27)+"P"+CHR(15)

          ?"------------------------------------------------------------------------------------------------------------------------------------"
??CHR(27)+"3"+CHR(17)
?CHR(27)+"S0|Роз|Дата ви-  |Номенклатура поставки |          |Оди-| Кiлькiсть |Цiна  по- |Обсяги поставки (база оподаткування)    |Загальна     |"+CHR(27)+"T"
?CHR(27)+"S0|дiл|никнення  |товарiв (послуг)      |  код     |ниця|  (об'єм,  |ставки    |без урахування ПДВ, що пiдлягають       |сума коштiв, |"+CHR(27)+"T"
?CHR(27)+"S0|   |податквого|    продавця          | товару   |ви- |   обсяг)  |одиницi   |опадаткуванню за ставками:              |що пiдлягає  |"+CHR(27)+"T"
?CHR(27)+"S0|   |зобов'я-  |                      | згiдно   |мiру|           |товару/пос|----------------------------------------|оплатi       |"+CHR(27)+"T"
?CHR(27)+"S0|   |зання (по-|                      |   з      |то- |           |луги без  |  основна   | нульова ставка| звiльнено |             |"+CHR(27)+"T"
?CHR(27)+"S0|   |стачання  |                      | УКТ ЗЕД  |вару|           |урахування|  ставка    |---------------| вiд  ПДВ 3|             |"+CHR(27)+"T"
?CHR(27)+"S0|   |(оплати 2)|                      |          |    |           | ПДВ      |            |постач.|(экс-  |           |             |"+CHR(27)+"T"
?CHR(27)+"S0|   |)         |                      |          |    |           |          |            |на митн|порт)  |           |             |"+CHR(27)+"T"
?CHR(27)+"S0|   |          |                      |          |    |           |          |            | тери- |       |           |             |"+CHR(27)+"T"
??CHR(27)+"-1"
?CHR(27)+"S0|   |          |                      |          |    |           |          |            |торiї  |       |           |             |"+CHR(27)+"T"+CHR(27)+"-0"+CHR(27)+"2"
          ?"| 1 |    2     |          3           |     4    | 5  |     6     |    7     |      8     |   9   |  10   |     11    |      12     |"
          ?"|---+----------+----------------------+----------+----+-----------+----------+------------+-------+-------+-----------+-------------|"
return .T.
