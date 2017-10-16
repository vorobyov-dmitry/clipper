#include "menu.ch"
#include "new.ch"
// #include "setcurs.ch"
MEMVAR m_mash,m_temppath,m_level,m_platpath,m_sprpath,p_npr,m_tabn
MEMVAR m_oper,m_computer,m_uchpath
STATIC lApnd:=.f.,m_koef1
Function LZK1(vid)
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,n_win1,m_col,m_ddoc,m_file
  LOCAL m_exit:=READEXIT(.T.),l_stop:=.t.,l_filter:=.f.,k_ctrl_u
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={},m_buf
  LOCAL a_get1:={},a_data1:={},n_pole1,m_block,a_say1:={},m_litr
  LOCAL m_browse1,m_vnum,m_ndoc,m_valid,m_valid1,l_firstline:=.t.,m,;
  m_mol,m_molavto:="  ",; // Код мол авто
  m_moltr  :="  "   // Код мол трактористов
  LOCAL m_state:="0",m_sum,m_date,k_kod,;
  bSayK:={||SetPos(7,33),m_koef1:=ROUND(IF(a_data[8]<>0,a_data[7]/a_data[8],0),3),DispOut(TRANSFORM(m_koef1,"99.999"),"Gr+/b")}
  DCL MENU
  DCL LIST
  LOCAL m_select:=SELECT(),a_pred01:={}
  IF .NOT.RECURS()
  SavePar()
  WSELECT(0)
    NET USE (m_platpath+"FVNUM") NEW
  IF .NOT.f_vnum(1)
    RETURN .f.
  ENDIF
  USE (m_uchpath+"inst1") INDEX  (m_uchpath+"inst1") new ALIAS myvar
  RESTMEM m_molavto,m_moltr
  CLOSE myvar
  OpenFl1()
  SopenFiles("100",@s_files)
  SET CURSOR OFF
  Lapnd:=.f.
  SELECT Nakl1
  SET FILTER TO nakl1->vdoc==vid // ЛЗК трактористiв
NET  USE (m_sprpath+"sp22") INDEX (m_sprpath+"sp22") NEW
//  INIT GET "NAKL1 " TO a_get KEY n_pole DATA a_data SAY a_say
  FOR i:=1 TO 10
    AADD(a_get,GETNEW())
    a_get[i]:colorSpec:="g+/b,gr+/n";a_get[i]:picture:="@K"
    a_get[i]:block:=COLBR(a_data[n_pole])
    AADD(a_say,NIL)
  NEXT
  a_get[1]:row:=1 ;a_get[1]:col:=26
  a_get[1]:cargo:=COLBR(Nakl1->NDOC)
  a_get[1]:PostBlock={|p|EVAL(p:block,JustRight(EVAL(p:block))),.t.}
  a_get[2]:row:=1 ;a_get[2]:col:=38
  a_get[2]:cargo:=COLBR(Nakl1->DDOC)
  a_get[3]:row:=2 ;a_get[3]:col:=12
  a_get[3]:cargo:=COLBR(Nakl1->OTP)
  a_get[3]:PostBlock={|p|Sp02->(Sp_vl("SP02"))}
  a_say[3]:={2,16,,"Gr+/b",{||_mol(a_data[3])}}
  a_get[4]:row:=3 ;a_get[4]:col:=17
  a_get[4]:cargo:=COLBR(Nakl1->TABN)
  a_say[4]:={3,23,,"Gr+/b",{||_fio(a_data[4])}}
  a_get[5]:row:=4 ;a_get[5]:col:=17
  IF vid=="2"
    a_get[4]:PostBlock={|p|Sp10t(@a_data,@a_get,@n_pole,@a_say)}
    a_get[5]:cargo:=COLBR(Nakl1->NTR)
    a_get[5]:PostBlock={|p|EVAL(p:block,JustRight(EVAL(p:block))),inv_t->(Sp_VL("INV_T"))}
    a_say[5]:={4,23,,"Gr+/b",{||Inv_t->(DS(a_data[5])),Sp13b->(DS(inv_t->kmtr)),Sp13b->naim13b}}
  ELSE
    a_get[4]:PostBlock={|p|Sp10a(@a_data,@a_get,@n_pole,@a_say)}
    a_get[5]:cargo:=COLBR(Nakl1->gnavt)
    a_get[5]:PostBlock={|p|EVAL(p:block,JustRight(EVAL(p:block))),inv_a->(Sp_VL("INV_A"))}
    a_say[5]:={4,23,,"Gr+/b",{||Inv_t->(DS(a_data[5])),Sp13a->(DS(inv_a->kavt)),Sp13a->naim13a}}
  ENDIF
  a_get[6]:row:=6 ;a_get[6]:col:=19
  a_get[6]:cargo:=COLBR(Nakl2->KOD)
  a_get[6]:PostBlock={||gsm(@n_pole,@a_data,@a_get,m_browse1,lapnd)}
  a_say[6]:={6,31,,"Gr+/b",{||Kaptka1->(DS(a_data[6])),Kaptka1->name}}
  a_get[7]:row:=7 ;a_get[7]:col:=4
  a_get[7]:cargo:=COLBR(Nakl2->KVO)
  a_get[7]:PostBlock:={||TaxStm(@a_get,@a_data,@n_pole,Lapnd),EVAL(bSayk),.t.}
  a_get[7]:PreBlock:={||.NOT.Lapnd}
  a_get[7]:picture+=" 9999.99"
  a_Say[7]:={7,33,,"GR+/B",{||Transform(IF(a_data[8]<>0,a_data[7]/a_data[8],0),"99.999")}}

//  a_say[7]:={7,41,"99.999","Gr+/b",{||IF(a_data[8]<>0,a_data[7]/a_data[8],0)}}
//  a_say[8]:={7,41,"99.999","Gr+/b",{||IF(a_data[8]<>0,a_data[7]/a_data[8],0)}}

  a_get[8]:row:=7 ;a_get[8]:col:=19
//  a_get[8]:PreBlock:={||.NOT.Lapnd}
  a_get[8]:PreBlock:={||.F.}
  a_get[8]:cargo:=COLBR(Nakl2->GLV)
  a_get[8]:picture+=" 99999"
  a_get[8]:PostBlock:={||SetLitr(@n_pole,@a_data,@a_get,lApnd,m_browse1),EVAL(bSayk),.t.}
  a_Say[8]:={7,33,,"GR+/B",{||Transform(IF(a_data[8]<>0,a_data[7]/a_data[8],0),"99.999")}}
  a_get[9]:row:=7 ;a_get[9]:col:=45
  a_get[9]:PreBlock:={||.Not.Lapnd}
  a_get[9]:cargo:=COLBR(Nakl2->prise1)
  a_get[9]:picture+=" 999.9999"
  a_get[9]:PostBlock:={||TaxStm(@a_get,@a_data,@n_pole,Lapnd),.t.}
  a_get[10]:row:=7 ;a_get[10]:col:=65
  a_get[10]:PreBlock:={||.f.}
  a_get[10]:cargo:=COLBR(Nakl2->stm1)
  a_get[10]:picture+=" 99999.99"
  ASIZE(a_data,LEN(a_get))
  FOR i:=1 TO 2
    AADD(a_get1,GETNEW())
    a_get1[i]:colorSpec:="g+/b,gr+/n";a_get1[i]:picture:="@K"
    AADD(a_say1,NIL)
  NEXT
  a_get1[1]:block:=COLBR(Nakl3->DDOC)
  a_get1[1]:PostBlock:={||.t.}
  a_get1[2]:block:=COLBR(Nakl3->GLV)
  SELECT nakl3
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  CrList1(IF(vid=="2","LZK1","LZK2"),@m_browse,@l_print,"NAKL1")
  n_win1:=InitScr(IF(vid=="2","LZK1  ","LZK2  "))
  m_browse1               := TBrowseDB(9,1,MAXROW()-2,MAXCOL()-1)
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_browse1:colsep        := '│'
  m_browse1:SkipBlock     := {|n| SkipDb1(n,{||(nakl1->vnum==nakl3->vnum)},lApnd) }
  m_browse1:goBottomBlock := {||nakl3->(DBSEEK(nakl1->vnum,.f.)),nakl3->(DBEVAL(,,{||(nakl1->vnum==nakl3->vnum)})),nakl3->(dbskip(-1))}
  m_browse1:goTopBlock    := {||nakl3->(DBSEEK(nakl1->vnum,.f.))}
  CrBrCol("LZK1A",@m_browse1,"NAKL3")
  FOR i:=1 TO m_browse1:ColCount
    m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──")
  NEXT
  NET USE (m_platpath+"memvar") INDEX (m_platpath+"memvar") NEW ALIAS myvar
  IF vid=="3"
    k_kod:=RestVar1("k_avto","NK")
    m_mol:=m_molavto
  ELSE
    k_kod:=RestVar1("k_tract","NK")
    m_mol:=m_moltr
  ENDIF
//  k_kod:=RestVar1(IF(vid=="3","k_avto","k_tract"),"NK")
  CLOSE myvar
  Select nakl1 ; Wselect(n_win)
  m_browse:GetColumn(3):block:={||Status1()}
  ADD menu up_down
  add menu Left_Right
  add menu search
  a_ver_menu[3][1][3]:="Пошук по номеру ЛЗК <Shift>+F6"
  AADD(a_ver_menu[3][1],"Складний пошук      <alt>+F7")
  AADD(a_ver_menu[3][2],K_ALT_F7)
  ADD MENU NAME "В~иправлення" ;
  ITEMS {"Добавити   Ins" ,"Виправити  Enter" ,;
  "Удалити    Delete ","Вiдмiтка про сплату <Alt>+<?>",;
  "Вибiрка ЛЗК"} ;
  KEY {K_INS,K_ENTER,K_DEL,309,K_ALT_F}
  AADD(a_ver_menu[4][1],"Вiдмiтка про одержання <Alt>+<P>")
  AADD(a_ver_menu[4][2],K_ALT_P)
  add menu print
   SELECT nakl1
  m_browse:goBottom()
//                      1   2    3    4      5    6   7   8   9  10   11   12   13  14   15     16   17   18  19   20     21
  m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w,w/n,n/w,w/b*,b+/w,w/n*,n+/w,w/rb,rb/w,w+/r,w+/n,w+/b*,w+/n*,w+/rb'
  FOR i:=1 TO m_browse:colCount
    m_browse:GetColumn(i):colorBlock:={||color1(nakl1->state)}
  NEXT
  INIT menu
  DISPLAYLIST
  DO WHILE .t.
    m_browse:refReshCurrent()
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},EVAL(m_browse:GetColumn(1):colorBlock))
    m_key:=0
    keyboard ""
    DO WHILE .NOT.(m_browse:stabilize()) .AND.((m_key:=inkey())==0)
    ENDDO
    IF m_browse:stabilize()
      m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},color2(nakl1->state))
      m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},MyFunc1(EVAL(m_browse:GetColumn(1):colorBlock)))
    ENDIF
    IF .NOT.(nakl1->(BOF()).AND.Nakl1->(EOF()))
      IF m_key==0
        m_key:=INKEY(0)
      ENDIF
    ELSE
      m_key:=K_INS
    ENDIF
    Winsay
    DEAL MENU
    DO CASE
      DEAL BROWSE m_browse KEY m_key
    CASE m_key==K_CTRL_BS.AND.IsLevel(nakl1->oper)
      IF Nakl1->(NetRlock())
        nakl1->state:=IF(IsBit(ASC(nakl1->state),3),CHR(CLEARBIT(ASC(nakl1->state),3)),;
        CHR(SETBIT(ASC(nakl1->state),3)))
        nakl1->(dbUnlock())
      ENDIF
    CASE m_key==K_F2
      IF ANSWER("Друкувати перелiк ЛЗК за день?")==YES
        // PrintLs()
      ENDIF
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      CASE m_key==K_SH_F6
        ShiftF6(m_browse,ALIAS("NAKL1"))
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
/*      CASE m_key==K_ALT_F
          IF ANSWERu("Робити вибiрку ;ЛЗК?")==YES
            IF .NOT.l_filter
              SetFilter(@m_browse)
              l_filter:=.t.
            ELSE
              DispError("Вибiрка вже зроблена")
            ENDIF
          ELSE
            l_filter:=.f.
            IF SELECT("Rec")<>0
              CLOSE REC
            ENDIF
            SELECT Nakl1
            m_browse:SkipBlock     := { |n| Nakl1->(SkipDb(n)) }
            m_browse:goBottomBlock := { ||  Nakl1->(DBGOBOTTOM()) }
            m_browse:goTopBlock    := { ||  Nakl1->(DBGOTOP())  }
            m_browse:RefreshAll()

          ENDIF */
/*      CASE m_key==K_ALT_F7
        If KaltF7()
          m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
        ENDIF */
    CASE m_Key == K_DEL
      DelDoc(m_browse,l_delete,alias("NAKL1"),alias("NAKL2"),alias("NAKL3"))
    CASE m_key==K_ENTER     // редактирование документа
      STABILIZE BROWSE m_browse
      WSELECT(n_win1)
      m_screen:=SaveScreen(0,0,MAXROW(),MAXCOL())
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      SELECT nakl1;n_pole:=1
      DBGOTO(RECNO())
      FOR i:=1 TO LEN(a_get)
        a_data[i]:=EVAL(a_get[i]:cargo)
      NEXT
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1;m_state:="0"
      set escape on
      SELECT NAKL3
      m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
      CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
      DISPBOX(m_browse1:nTop-1,m_browse1:nLeft-1,m_browse1:nBottom,m_browse1:nRight+1,"▌─▐▐▐─▌▌ ",m_browse1:colorSpec)
      lApnd:=.f.;EVAL(m_browse1:GotopBlock)
      STABILIZE BROWSE m_browse1
      m_litr:=SumLitr(m_browse1)
      m_browse1:autolite:=.f.
      m_browse1:DeHilite()
      SET ESCAPE ON
      DO WHILE .t.
       DO CASE
        CASE m_state=="0"
          select nakl1
          j:=a_get[n_pole]:ColorSpec;a_get[n_pole]:ColorSpec:="b/w,b/w"
          a_get[n_pole]:Display();a_get[n_pole]:ColorSpec:=j
          m_key:=INKEY(0)
          a_get[n_pole]:Display()
//          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
              CASE m_key == K_UP;IF n_pole ==1;ELSE;n_pole:=n_pole-1;END
              CASE m_key == K_DOWN;IF n_pole ==LEN(a_get);ELSE;n_pole:=n_pole+1;END
              CASE m_key == K_CTRL_U;LSetprint()
              CASE m_key == K_ESC;BeepErr();IF ALERT("Всi змiни будуть анульованi;Виходити ?",{"Так","Нi"})==1;EXIT;END
              CASE m_key == K_F12.OR. m_key == K_CTRL_END
              IF Nakl1->(NetRLOCK()).AND.Nakl2->(NetRLOCK())
                n_pole:=1;AEVAL(a_get,{|x|EVAL(x:cargo,a_data[n_pole]),n_pole++})
                Nakl1->(DBUNLOCK());Nakl2->(DBUNLOCK());EXIT
              ELSE;DispError("Невозможно заблокировать запись");END
              CASE m_key == K_ENTER ;WinSay
                IF IsLevel(nakl1->oper)
                    ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
                    IF a_say[n_pole] # NIL .AND. VALTYPE(a_say[n_pole][1])<>"A"
                      SETPOS(a_say[n_pole][1],a_say[n_pole][2])
                      DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
                    END
                ELSE
                  DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
               ENDIF
            CASE m_key = K_TAB
               m_state:="4"
            CASE m_key = K_F2
//               PrintNakl(a_data)
          ENDCASE
         CASE m_state=="4"
            select nakl3
            m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
            lApnd:=.f.;EVAL(m_browse1:GotopBlock)
            IF .NOT.nakl3->vnum==nakl1->vnum
              IF ANSWER("Вiдсутнi строки ЛЗК!;Будемо вводити ?")<>YES
                select nakl1;m_state:="0"
                LOOP
              ELSE
                lApnd:=.t.
              ENDIF
            ENDIF
            DO WHILE .t.
              Display Browse m_browse1
              Winsay
              m_key:=IF(.NOT.lApnd,INKEY(0),K_INS)
                DO CASE
                  CASE m_key==K_ALT_S
                    m_litr:=SumLitr(m_browse1)
//                  CASE m_key = K_F2

                CASE m_key==K_ESC.OR.m_key = K_TAB
                   SetLitr(@n_pole,@a_data,@a_get,lApnd,m_browse1)
                    m_state:="0";EXIT
                DEAL BROWSE m_browse1 KEY m_key
                CASE m_key==K_ENTER   // .OR.Lapnd
                  IF IsLevel(nakl1->oper)
                      IF Nakl3->(NetRLOCK())
                        m_browse1:refreshCurrent()
                        STABILIZE BROWSE m_browse1
                        a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                          ReadMy({a_get1[m_browse1:ColPos]})
                        Nakl3->(dbUNLOCK())
                      ELSE
                        DispError("Невозможно заблокировать запись")
                      ENDIF
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
                CASE m_Key == K_DEL
                  IF IsLevel(nakl1->oper)
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
            IF IsLevel(nakl1->oper)
                  IF .NOT.Lapnd
                    m_browse1:panHome();m_browse1:goBottom()
                    STABILIZE BROWSE m_browse1
                    lApnd:=.t.;m_browse1:down();m_browse1:refreshAll()
                    STABILIZE BROWSE m_browse1
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
                    IIF(a_say1[1]#NIL.AND.VALTYPE(a_say1[1][1])=="A",a_say1[1],NIL))
                    IF LASTKEY()<>K_ESC.AND..NOT.EMPTY(m_buf)
                      IF Nakl3->(NetDbAp())
                        Nakl3->vnum:=nakl1->vnum
                        EVAL(m_block,m_buf)
                        FOR i:=2 TO m_browse1:ColCount
                          m_browse1:right();m_browse1:refreshCurrent()
                          STABILIZE BROWSE m_browse1
                          a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                          ReadMoDal({a_get1[m_browse1:ColPos]})
                        NEXT
                        Nakl3->(dbUnlock())
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
      RestScreen(0,0,MAXROW(),MAXCOL(),m_screen)
      Wselect(n_win)
      IF INDEXORD()<>0;IF c_key<>&(INDEXKEY(0));m_browse:refreshAll()
      ELSE;m_browse:refreshCurrent();END;END
    CASE m_key==K_INS // ввод документа
      STABILIZE BROWSE m_browse
      WSELECT(n_win1)
      m_screen:=SaveScreen(0,0,MAXROW(),MAXCOL())
      RestScreen(0,0,MAXROW(),MAXCOL(),m_screen)
      l_stop:=.t.
      m_valid:=a_get[1]:postBlock;a_get[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid,x))}
      m_ndoc:=BLANK(Nakl1->ndoc,.t.)
      DO WHILE l_stop
        set escape on
        Lapnd:=.t.
        CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
        select nakl1;n_pole:=1
//        INIT DATA a_data FROM a_get KEY n_pole BLANK
          FOR i:=1 TO LEN(a_get)
            a_data[i]:=BLANK(EVAL(a_get[i]:cargo),.t.)
          NEXT
          a_data[2]:=DATE()
          a_data[1]:=m_ndoc
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
            ENDIF
            DO CASE
              CASE LASTKEY() == K_ESC.AND.ALERT("Вийти iз програми",{"Так","Нi"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT
              CASE LASTKEY() == K_UP.AND.n_pole # 1;n_pole--;LOOP
              CASE n_pole == LEN(a_get)
                IF Nakl1->(NetDbAp()).AND.Nakl2->(NetDbAp())
                  n_pole:=1;AEVAL(a_get,{|x|EVAL(x:cargo,a_data[n_pole]),n_pole++})
                  nakl1->oper:=m_oper
                  EXIT
                ELSE
                  DispError("Невозможно добавить запись")
                ENDIF
              CASE n_pole == 1.AND.EMPTY(a_data[1]);l_stop:=.f.;EXIT
            OTHERWISE
                n_pole++
            ENDCASE
          ENDDO
          IF LASTKEY()==K_ESC.OR..NOT.l_stop
            EXIT
          ENDIF
          nakl1->vdoc:=vid
          nakl1->day:=DATE()
          nakl1->state:=CHR(SETBIT(ASC(nakl1->state),2))
          nakl1->ddoc3:=Nakl1->ddoc
          nakl1->kopr:=k_kod
          Nakl1->mol :=m_mol
          IF fvnum->(NetRlock())
            nakl1->vnum:=STR(fvnum->vnum,6)
            Nakl2->vnum:=Nakl1->vnum
            fvnum->vnum:=fvnum->vnum+1
            fvnum->(DBCOMMIT())
            fvnum->(DbUnlock())
          ELSE
            DispError("Вiдмовлено в доступi")
            EXIT
          ENDIF
          dbUnlock()
          select nakl3
          m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
          EVAL(m_browse1:GotopBlock);lApnd:=.t.
          Display Browse m_browse1
          m_block:=a_get1[1]:block;m_buf:=EVAL(m_block)
          m_valid1:=a_get1[1]:postBlock;a_get1[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid1,x))}
          a_get1[1]:block:={|x|IF(x==NIL,m_buf,m_buf:=x)}
          m_litr:=0
          l_firstline:=.t.
          DispS01(m_litr)
          DO WHILE .t.
            STABILIZE BROWSE m_browse1
            SET ESCAPE ON
            m_buf:=BLANK(EVAL(m_block),.t.)
            a_get1[1]:row:=ROW();a_get1[1]:col:=COL()
            ReadMy({a_get1[m_browse1:ColPos]},;
                IF(a_say1[1]#NIL.AND.VALTYPE(a_say1[1][1])=="A",a_say1[1],NIL))
            SET ESCAPE OFF
//            STABILIZE BROWSE m_browse1
            IF LASTKEY()<>K_ESC.AND..NOT.EMPTY(m_buf)
              IF nakl3->(NetDbAp())
                nakl3->vnum:=nakl1->vnum
                EVAL(m_block,m_buf)
//                STABILIZE BROWSE m_browse1
                FOR i:=2 TO m_browse1:ColCount
                  m_browse1:right();m_browse1:refreshCurrent()
                  STABILIZE BROWSE m_browse1
                  a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                  ReadMoDal({a_get1[m_browse1:ColPos]})
                  STABILIZE BROWSE m_browse1
                NEXT
                nakl3->(dbUnlock())
              ELSE
                DispError("Невозможно добавить запись")
              ENDIF
              m_litr+=nakl3->glv
              DispS01(m_litr)
              m_browse1:panHome();m_browse1:down()
              STABILIZE BROWSE m_browse1
              l_firstline:=.f.
              nakl3->(DbUnLock())
            ELSE
              lApnd:=.f.;a_get1[1]:block:=m_block;a_get1[1]:postBlock:=m_valid1
              DispS01(m_litr)
              EXIT
            ENDIF
          ENDDO
          nakl1->(dbUnlock())
          Sp22->(DS(MNT_dtod(nakl1->ddoc)+RIGHT(ALLTRIM(nakl2->kod),2)))
          nakl2->glv:=m_litr;Nakl2->prise:=Sp22->prise
          nakl2->kvo:=Sp22->koef*nakl2->glv
          Nakl2->stm1:=nakl2->kvo*Nakl2->prise
          Nakl2->stm :=Nakl2->stm1
          Nakl2->st:="1"
/*
          @0,0 SAY nakl2->glv COLOR "b/bg"
          @1,0 SAY nakl2->kvo COLOR "b/bg"
          @2,0 SAY nakl2->prise COLOR "b/bg"
          @3,0 SAY nakl2->stm COLOR "b/bg"
          @0,30 SAY Sp22->mnt COLOR "b/bg"
          @1,30 SAY Sp22->kmtop COLOR "b/bg"
          @2,30 SAY Sp22->prise COLOR "b/bg"
          @3,30 SAY Sp22->koef COLOR "b/bg"
          INKEY(0)  */

          nakl2->(dbUnlock())
          m_ndoc:=a_data[1]
        ENDDO
        a_get[1]:postBlock:=m_valid
        RestScreen(0,0,MAXROW(),MAXCOL(),m_screen)
        Wselect(n_win);lApnd:=.f.
        m_browse:refreshAll()
   FINISH LIST
   WCLOSE(n_win);WCLOSE(n_win1)
   WSELECT(0)
   READEXIT(m_exit)
  IF fvnum->(NetRlock())
    fvnum->reg:=CLEARBIT(fvnum->reg,m_computer)
    fvnum->(DBCOMMIT())
    fvnum->(DbUnlock())
  ELSE
    DispError("Вiдмовлено в доступi")
  ENDIF
  CLOSE sp22
  ScloseFile(s_files)
  CloseFl1()
  SavePar(1)
  ENDIF
RETURN .t.


STATIC Function sp10t(a_data,a_get,n_pole,a_say)
  LOCAL i:=n_pole
  LOCAL l:=Sp10->(Sp_VL("SP10A"))
  IF l.AND.EMPTY(a_data[5])
    Inv_t->(DBSETORDER(2))
    Inv_t->(DS(a_data[4]))
    a_data[5]:=Inv_t->invnum
    Inv_t->(DBSETORDER(1))
    n_pole:=5
    a_get[n_pole]:Display()
    @a_say[5][1],a_say[5][2] SayDisp EVAL(a_say[5][5]) PICTURE a_say[5][3] COLOR a_say[5][4]
  ENDIF
 n_pole:=i
RETURN l
STATIC Function sp10a(a_data,a_get,n_pole,a_say)
  LOCAL i:=n_pole
  LOCAL l:=Sp10->(Sp_VL("SP10A"))
  IF l.AND.EMPTY(a_data[5])
    Inv_a->(DBSETORDER(2))
    Inv_a->(DS(a_data[4]))
    a_data[5]:=Inv_a->gnavt
    Inv_a->(DBSETORDER(1))
    n_pole:=5
    a_get[n_pole]:Display()
    @a_say[5][1],a_say[5][2] SayDisp EVAL(a_say[5][5]) PICTURE a_say[5][3] COLOR a_say[5][4]
  ENDIF
 n_pole:=i
RETURN l
STATIC Function Status1()
LOCAL x:="ПОМИЛКА",var:=nakl1->state
LOCAL i
i:=ASC(var)
DO CASE
  CASE var==" "   // Исходное состояние
    x:="       "
  CASE ISBIT(i,3) // Аннулированная накладная
    x:="Аннулiр"
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1).AND.(AT(NumPotr(Nakl1->kopr),"2367")<>0) // Получена , но не оплачена
    x:=" √     "
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1) // Получена , но не оплачена
    x:="Не опл."
  CASE ISBIT(i,2).AND.ISBIT(i,1) // Оплачена и получена
    x:=" √     "
  CASE .NOT.ISBIT(i,2).AND.ISBIT(i,1) // Оплачена, но не получена
    x:="Не одер"
  CASE ISBIT(i,4) // Невыписанная накладная
    x:="???????"
ENDCASE
RETURN X
STATIC function Color1(var)
LOCAL x:={15,16},i:=ASC(var)
DO CASE
  CASE var==" "   // Исходное состояние
    x:={1,2}
  CASE ISBIT(i,3) // Аннулированная накладная
    x:={9,10}
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1).AND.(AT(NumPotr(Nakl1->kopr),"2367")<>0) // Получена , но не оплачена и производство
    x:={13,14}
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1) // Получена , но не оплачена
    x:={7,8}
  CASE ISBIT(i,2).AND.ISBIT(i,1) // Оплачена и получена
    x:={13,14}
  CASE .NOT.ISBIT(i,2).AND.ISBIT(i,1) // Оплачена, но не получена
    x:={11,12}
  CASE ISBIT(i,4) // Невыписанная накладная
    x:={17,15}
ENDCASE
RETURN x
STATIC function Clr1(var)
LOCAL x:={15,16},i:=ASC(var)
DO CASE
  CASE ISBIT(i,3) // Аннулированная накладная
    x:={9,10}
  CASE var==" "   // Исходное состояние
    x:={7,8}
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1).AND.(AT(NumPotr(Nakl1->kopr),"2367")<>0) // Получена , но не оплачена производство
    x:={13,14}
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1) // Получена , но не оплачена
    x:={1,2}
  CASE ISBIT(i,2).AND.ISBIT(i,1) // Оплачена и получена
    x:={13,14}
  CASE .NOT.ISBIT(i,2).AND.ISBIT(i,1) // Оплачена, но не получена
    x:={11,12}
  CASE ISBIT(i,4) // Невыписанная накладная
    x:={17,15}
ENDCASE
RETURN x
STATIC function Color2(var)
LOCAL x:={21,21},i:=ASC(var)
DO CASE
  CASE ISBIT(i,3) // Аннулированная накладная
    x:={18,18}
  CASE var==" "   // Исходное состояние
    x:={6,6}
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1).AND.(AT(NumPotr(Nakl1->kopr),"2367")<>0) // Получена , но не оплачена
    x:={20,20}
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
STATIC function Clr2(var)
LOCAL x:={21,21},i:=ASC(var)
DO CASE
  CASE ISBIT(i,3) // Аннулированная накладная
    x:={18,18}
  CASE var==" "   // Исходное состояние
    x:={17,17}
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1).AND.(AT(NumPotr(Nakl1->kopr),"2367")<>0)  // Получена , но не оплачена
    x:={20,20}
  CASE ISBIT(i,2).AND..NOT.ISBIT(i,1) // Получена , но не оплачена
    x:={6,6}
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
STATIC Function DispS01(x)
  @MAXROW()-1,22 SayDisp SPACE(20)  COLOR "w/b"
  @MAXROW()-1,1 SayDisp "Загальна кiлькiсть " COLOR "w/b"
  @MAXROW()-1,COL()+2 SayDisp NumToStr(x,14) COLOR "w+/b"
RETURN .t.
STATIC Function  SumLitr(m_browse1)
LOCAL x:=0,m_recno:=Nakl3->(RECNO())
  EVAL(m_browse1:GotopBlock)
  DO WHILE .NOT.Nakl3->(EOF()).AND.Nakl3->vnum==nakl1->vnum
    x+=Nakl3->glv
    Nakl3->(DBSKIP())
    DispS01(x)
  ENDDO
  Nakl3->(DBGOTO(m_recno))
RETURN x
Static Function SetLitr(n_pole,a_data,a_get,Lapnd,m_browse1)
LOCAL i:=n_pole,j,l1:=IF(Lapnd==NIL,.f.,Lapnd)
//  IF l1.OR.ANSWERu("Перераховувати лiтри ПММ?")==YES
    a_data[8]:=SumLitr(m_browse1)
//  ENDIF
  IF l1.OR.ANSWERu("Перераховувати кiлограми ПММ?")==YES
    Sp22->(DS(MNT_dtod(a_data[2])+RIGHT(ALLTRIM(a_data[6]),2)))
    a_data[7]:=Sp22->koef*a_data[8]
    a_data[9]:=Sp22->prise
  ENDIF
  IF l1.OR.ANSWERu("Перераховувати вартiсть ПММ?")==YES
    a_data[10]:=a_data[9]*a_data[7]
  ENDIF
FOR n_pole:=7 TO 10
  a_get[n_pole]:Display()
NEXT
n_pole:=i
RETURN .t.
Static Function SetSum(n_pole,a_data,a_get,m_browse1,Lapnd)
LOCAL i:=n_pole,j,l1:=IF(Lapnd==NIL,.f.,Lapnd)
//  IF l1.OR.ANSWERu("Перераховувати лiтри ПММ?")==YES
    a_data[8]:=SumLitr(m_browse1)
//  ENDIF
  IF l1.OR.ANSWERu("Перераховувати кiлограми ПММ?")==YES
    Sp22->(DS(MNT_dtod(a_data[2])+RIGHT(ALLTRIM(a_data[6]),2)))
    a_data[7]:=Sp22->koef*a_data[8]
    a_data[9]:=Sp22->prise
  ENDIF
  TaxStm(@a_get,@a_data,@n_pole,Lapnd)
FOR n_pole:=7 TO 10
  a_get[n_pole]:Display()
NEXT
n_pole:=i
RETURN .t.
STATIC Function Gsm(n_pole,a_data,a_get,m_browse1,lApnd)
LOCAL i:=Kaptka1->(kaptka_vl())
IF i
  IF .NOT.lApnd
    SetLitr(@n_pole,@a_data,@a_get,Lapnd,m_browse1)
  ELSE
    Sp22->(DS(MNT_dtod(a_data[2])+RIGHT(ALLTRIM(a_data[6]),2)))
    a_data[9]:=Sp22->prise
  ENDIF
ENDIF
RETURN i
STATIC FUNCTION TaxStm(a_get,a_data,n_pole,Lapnd)
LOCAL i:=n_pole,j,l1:=IF(Lapnd==NIL,.f.,Lapnd)
  IF l1.OR.ANSWERu("Перераховувати вартiсть ПММ?")==YES
    a_data[10]:=a_data[9]*a_data[7]
  ENDIF
  n_pole:=10
  a_get[10]:Display()
n_pole:=i
RETURN .t.
Function Akt()
    NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b") ALIAS kaptka1 NEW
    Spbrow("NAKL5")
    CLOSE Kaptka1
RETURN .t.
STATIC Function RestVar(m_name)
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
