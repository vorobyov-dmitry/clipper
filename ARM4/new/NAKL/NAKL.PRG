#include "menu.ch"
#include "new.ch"
// #include "setcurs.ch"
#define P_EMPH_ON  CHR(27)+"E"
#define P_EMPH_OFF CHR(27)+"F"

MEMVAR m_mash,m_temppath,m_level,m_platpath,m_sprpath,p_npr,m_tabn,m_oper,m_computer
STATIC lApnd:=.f.,;
a_kod1:={;
{"Г ", "Готiвка         "},;
{"Г1", "Готiвка-оплата  "},;
{"Г2", "Готiвка-за одер "},;
{"П ", "Перерахування   "},;
{"П1", "Перерах.-оплата "},;
{"П2", "Перерах.-за одер"},;
{"З ", "В рах. зарплати "},;
{"З2", "Зарплата по одер"},;
{"Б ", "Бартер          "},;
{"Б1", "Бартер-одерж.   "},;
{"Б2", "Бартер-вiдвант. "},;
{"К ", "Взаєморазрахунки"},;
{"С ", "В рах. пенсiї   "},;
{"В ", "Виробництво     "},;
{"М ", "Внутр. передача "},;
{"Д ", "Допомога безпов."},;
{"Т ", "Пiдзвiтна особа "}}

Function Nakl(l_mode)
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,n_win1,m_col,m_ddoc,m_file
  LOCAL m_exit:=READEXIT(.T.),l_stop:=.t.,l_filter:=.f.,k_ctrl_u
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={}
  LOCAL a_get1:={},a_data1:={},n_pole1,a_say1:={},a_brgd:={}
  LOCAL m_browse1,m_vnum,m_ndoc,m_valid,a_dop:={},a_spr01:={},m
  LOCAL m_browse2,m_get1b,m_state:="0",m_col1b,a_fam:={},m_sum,m_nds,m_date,m_pension
  LOCAL blnk_nkl:={||nakl1->tabn:=blank(nakl1->tabn,.t.),;
  nakl1->ksash:=blank(nakl1->ksash,.t.),nakl1->okpo:=blank(nakl1->okpo,.t.),;
  nakl1->mol:=BLANK(nakl1->mol,.t.),nakl1->brgd:=BLANK(nakl1->brgd,.t.)}
  LOCAL k_f4,k_Ctrlf5,k_altf5,b_spr01:={|z|z:=n_pole,n_pole:=17,a_data[17]:=a_spr01[2],a_get[17]:display(),n_pole:=z}
//  LOCAL a_get2:={}
  DCL MENU
  DCL LIST
  LOCAL m_select:=SELECT(),a_pred01:={}
  IF .NOT.RECURS()
  SavePar()
  IF EMPTY(l_mode)
    NET USE (m_platpath+"FVNUM") NEW
    IF .NOT.f_vnum(1)
      CLOSE fvnum
      RETURN .f.
    ENDIF
    SopenFiles("100",@s_files)
    OpenFl1()
  ENDIF
  WSELECT(0)
  SET CURSOR OFF
  k_f4:=SETKEY(K_F4,{||EdFirm01("FIRM01")})
  k_Ctrlf5:=SETKEY(K_CTRL_F5,{||nalog(1),fvnum->(DBGOTO(1))})
  k_altf5:=SETKEY(K_ALT_F5,{||FormNalog(),fvnum->(DBGOTO(1))})
  k_ctrl_u:=SETKEY(K_CTRL_U,{||LSetprint()})
  a_pred01:={pred01->tabnr,pred01->tabnb,ALLTRIM(_Fio(pred01->tabnr)),ALLTRIM(_Fio(pred01->tabnb))}
  InitNds()
  Lapnd:=.f.
//  setblink(.f.)
  NET USE (m_platpath+"memvar") INDEX (m_platpath+"memvar") NEW ALIAS myvar
  m_pension:=RestVar1("m_pension","NK")
  CLOSE myvar

  SELECT Nakl1
  SET FILTER TO
  SET FILTER TO nakl1->vdoc=="1" // Витрата
  Nakl1->(DBSETORDER(1))
  INIT GET "NAKL1 " TO a_get KEY n_pole DATA a_data SAY a_say
  a_get[1]:PreBlock:={||(.Not.Lapnd)}
  a_get[4]:PrebLock:={||.NOT.IsUslug(a_data[3])}
  a_get[5]:PrebLock:={||IsUslug(a_data[3])}
  a_get[6]:PreBlock:={||(.Not.Lapnd)}
  a_get[7]:PreBlock:={||(AT(NumPotr(a_data[3]),"0267")<>0)}
  a_get[8]:PreBlock:={||(NumPotr(a_data[3])=="1")}
  a_get[9]:PreBlock:={||(NumPotr(a_data[3])=="3")}
  a_get[10]:PreBlock:={||(AT(NumPotr(a_data[3]),"267")<>0)}
  a_get[11]:PreBlock:={||(AT(NumPotr(a_data[3]),"267")<>0)}
  a_get[12]:PreBlock:={||(NumPotr(a_data[3])=="6")}
  a_get[13]:PreBlock:={||(NumPotr(a_data[3])=="7")}
  a_get[14]:PreBlock:={||(NumPotr(a_data[3])=="8")}
  a_get[6]:PostBlock:={||KodOpl()}
  a_get[7]:PostBlock:={||sp10(@a_data,@a_get,@n_pole)}
  a_get[8]:PostBlock:={||Firm01(@a_data,@a_get,@n_pole)}
  a_get[9]:PostBlock:={||sp02(@a_data,@a_get,@n_pole)}
  a_get[10]:PostBlock:={||sp01(@a_data,@a_get,@n_pole)}
  a_get[11]:PostBlock:={||sp44(@a_data,@a_get,@n_pole)}
  a_get[12]:PostBlock:={||Inv_a(@a_data,@a_get,@n_pole)}
  a_get[13]:PostBlock:={||Inv_t(@a_data,@a_get,@n_pole)}
	  a_get[14]:PostBlock:={||Sp17(@a_data,@a_get,@n_pole,m_pension)}
  a_say[6]:={2,51,"","GR+/B",{||SayOpl(a_data[6])}}
  a_say[16]:={{ASC("?"),{||Sp10Dop(@a_data,@a_get,@n_pole)}}}

//  Test1()

//  a_say[5]:={{ASC("?"),{||sp10->(sp10(@a_fam,@a_data)),a_get[5]:upDateBuffer()}}}
//  NET USE (m_platpath+"nakl2") INDEX (m_platpath+"nakl2")     NEW ALIAS nakl2
//  nakl2->(DBGOTOP())
  SELECT spr01
  SET FILTER TO spr01->kopr>="100"
  SELECT nakl2
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  a_get[3]:PostBlock:={||m:=Spr01->(spr01(@a_spr01)),IF(.NOT.EMPTY(a_spr01).AND.EMPTY(a_data[17]),EVAL(b_spr01),NIL),m}
  CrList1("NAKL1",@m_browse,@l_print)
  n_win1:=InitScr("NAKL1 ")
  a_get1:=CrGet("NAKL2",a_say1)
  a_say1[1]={{ASC("?"),{||kaptka_vl(a_get1[1],a_data[3],@a_dop)}},;
  {K_F2,{||PrintNakl(a_data,a_pred01)}},;
  {K_CTRL_F12,{||kaptka_vl(a_get1[1],a_data[3],@a_dop,K_CTRL_F12)}}}
  a_get1[1]:PostBlock:={|x|kpt_vl(x,@a_dop)}
  a_get1[4]:PostBlock:=a_get1[7]:PostBlock:={||TaxStm(a_data[3])}
  a_get1[4]:PreBlock:={||IF(NumPotr(a_data[3])=="5",Nakl3(lApnd,"NAKL3"),IF(NumPotr(a_data[3])=="9",Nakl3(lApnd,"NAKL4"),.t.))}
  a_get1[7]:PreBlock:={||IF(NumPotr(a_data[3])=="5".OR.NumPotr(a_data[3])=="9",.f.,.t.)}
  a_get1[10]:PreBlock:={||IF(NumPotr(a_data[3])=="5".OR.NumPotr(a_data[3])=="9",.f.,.t.)}
  m_browse1               := TBrowseDB(10,1,MAXROW()-3,MAXCOL()-1)
//                            1   2   3      4    5    6    7      8     10
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,GR+/N+,N+/GR,W/N'
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,GR+/B,GR+/W,BG/N+'
  
  m_browse1:colsep        := '│'
  m_browse1:SkipBlock     := {|n| SkipDb1(n,{||(nakl1->vnum==nakl2->vnum)},lApnd) }
  m_browse1:goBottomBlock := {||nakl2->(DBSEEK(nakl1->vnum,.f.)),nakl2->(DBEVAL(,,{||(nakl1->vnum==nakl2->vnum)})),nakl2->(dbskip(-1))}
  m_browse1:goTopBlock    := {||nakl2->(DBSEEK(nakl1->vnum,.f.))}
  CrBrCol("NAKL2",@m_browse1)
  i:=1;AEVAL(a_get1,{|x|a_get1[i]:block:=m_browse1:GetColumn(i):Block,;
  m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──"),i++})
  a_get1[10]:Block:={|x|IF(x==NIL,nakl2->stm+nakl2->nds,SetStm(x))}
  Select nakl1 ; Wselect(n_win)
  m_browse:GetColumn(3):block:={||Status1()}

  m_browse1:GetColumn(11):colorblock:=  {|| IF(field->KNDS==' ',{1,2},{7,8})}
  m_browse1:GetColumn(1):colorblock:=  {|| IF(field->KNDS==' ',{1,2},{7,8})}

  ADD menu up_down
  add menu Left_Right
  add menu search
  a_ver_menu[3][1][3]:="Пошук по номеру накладної <Shift>+F6"
  AADD(a_ver_menu[3][1],"Складний пошук      <alt>+F7")
  AADD(a_ver_menu[3][2],K_ALT_F7)
  ADD MENU NAME "В~иправлення" ;
  ITEMS {"Добавити   Ins" ,"Виправити  Enter" ,;
  "Удалити    Delete ","Вiдмiтка про сплату <Alt>+<?>",;
  "Розрахунок суми накладних <Alt>+<S>","Вибiрка накладних"} ;
  KEY {K_INS,K_ENTER,K_DEL,309,K_ALT_S,K_ALT_F}
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
    IF m_key==0
      m_key:=INKEY(0)
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
      IF ANSWERu("Друкувати перелiк накладних за день?")==YES
        PrintLs()
      ENDIF
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      CASE m_key==K_SH_F6
        ShiftF6(m_browse,SELECT("NAKL1"))
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_P.OR.(m_key==K_ENTER.AND.m_browse:ColPos==3)
         ReadPol();m_browse:refreshAll()
      CASE m_key==309.OR.(m_key==K_ENTER.AND.m_browse:ColPos==5) // ALT+?
         DispOpl()
        CASE m_key==K_ALT_F
          IF ANSWERu("Робити вибiрку ;накладних?")==YES
            IF .NOT.l_filter
              SetFilter(@m_browse,l_filter)
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
          ENDIF
      CASE m_key==K_ALT_F7
        If KaltF7()
          m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
        ENDIF
    CASE m_Key == K_DEL
      DelDoc(m_browse,l_delete,SELECT("NAKL1"),SELECT("NAKL2"),SELECT("NAKL3"))
    CASE m_key==K_ENTER
      STABILIZE BROWSE m_browse
      WSELECT(n_win1)
      m_screen:=SaveScreen(0,0,MAXROW(),MAXCOL())
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      SELECT nakl1;n_pole:=1
      DBGOTO(RECNO())
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1;m_state:="0"
      set escape on
      SELECT NAKL2
      m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
      WSELECT(n_win1)
      CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
      DISPBOX(m_browse1:nTop-1,m_browse1:nLeft-1,m_browse1:nBottom,m_browse1:nRight+1,"▌─▐▐▐─▌▌ ",m_browse1:colorSpec)
      lApnd:=.f.;EVAL(m_browse1:GotopBlock)
      IF nakl2->vnum==nakl1->vnum //m_browse1:hitBottom
        SumSumNds(@m_sum,@m_nds,m_browse1)
        Stabilize Browse m_browse1
        m_browse1:autolite:=.f.
        m_browse1:DeHilite()
      ENDIF
      a_fam:={}
      SET ESCAPE ON
      DO WHILE .t.
       DO CASE
        CASE m_state=="0"
          select nakl1
          WSELECT(n_win1)
          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
              CASE m_key == K_UP;IF n_pole ==1;ELSE;n_pole:=n_pole-1;END
              CASE m_key == K_DOWN;IF n_pole ==LEN(a_get);ELSE;n_pole:=n_pole+1;END
              CASE m_key == K_CTRL_F5;nalog(1);fvnum->(DBGOTO(1))
              CASE m_key == K_ALT_F5;FormNalog();fvnum->(DBGOTO(1))
              CASE m_key == K_CTRL_U;LSetprint()
              CASE m_key == K_ESC;BeepErr();IF ALERT("Всi змiни будуть анульованi;Виходити ?",{"Так","Нi"})==1;EXIT;END
              CASE m_key == ASC("0");EXIT
              CASE m_key == K_F12.OR. m_key == K_CTRL_END
              IF NetRLOCK();n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                UNLOCK;EXIT
              ELSE;DispError("Невозможно заблокировать запись");END
              CASE m_key == K_ENTER ;WinSay
          IF IsLevel(nakl1->oper)      //.AND..NOT.IsBit(ASC(nakl1->state),1).AND..NOT.IsBit(ASC(nakl1->state),2)
              ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
              DispSay(@n_pole,@a_say,@a_data)
                IF n_pole==3
                  IF LEN(a_spr01)>0
                      a_data[6]:=a_spr01[4]
                      i:=n_pole;n_pole:=6;a_get[n_pole]:Display()
                      DispSay(@n_pole,@a_say,@a_data)
                      n_pole:=i
                  ENDIF
                END
          ELSE
          DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
         ENDIF
            CASE m_key = K_TAB
               m_state:="4"
            CASE m_key = K_F2
               PrintNakl(a_data,a_pred01)
          ENDCASE
         CASE m_state=="4"
            CountNds(a_data[3])
            select nakl2
            m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
            lApnd:=.f.;EVAL(m_browse1:GotopBlock)
            IF .NOT.nakl2->vnum==nakl1->vnum //m_browse1:hitBottom
              IF ANSWER("Вiдсутнi строки накладної!;Будемо вводити ?")<>YES
                select nakl1;m_state:="0"
                LOOP
              ELSE
                lApnd:=.t.
              ENDIF
            ENDIF
            DO WHILE .t.
              
//                            1   2   3      4    5    6    7      8     10
//  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,RB+/N+,N+/RB+,BG/N+'
              m_browse1:refReshCurrent()
              IF nakl2->KNDS!=' ' 
                 m_browse1:ColorRect({m_browse1:RowPos,1,m_browse1:RowPos,m_browse1:colCount},{7,8})
               ELSE
               	m_browse1:ColorRect({m_browse1:RowPos,1,m_browse1:RowPos,m_browse1:colCount},{1,1})
               ENDIF
        	   STABILIZE BROWSE m_browse1
              IF nakl2->KNDS!=' ' 
        		  m_browse1:ColorRect({m_browse1:RowPos,1,m_browse1:RowPos,m_browse1:colCount},{10,7})
                  m_browse1:ColorRect({m_browse1:RowPos,m_browse1:ColPos,m_browse1:RowPos,m_browse1:ColPos},{8,7})
               ELSE
        		 m_browse1:ColorRect({m_browse1:RowPos,1,m_browse1:RowPos,m_browse1:colCount},{6,1})
                 m_browse1:ColorRect({m_browse1:RowPos,m_browse1:ColPos,m_browse1:RowPos,m_browse1:ColPos},{2,2})
              ENDIF
              Winsay
              m_key:=IF(.NOT.lApnd,INKEY(0),K_INS)
                DO CASE
                  CASE m_key==K_ALT_S
                   SumSumNds(@m_sum,@m_nds,m_browse1)
                  CASE m_key = K_F2
                      PrintNakl(a_data,a_pred01)
                  CASE m_key==309.OR.(m_key==K_ENTER.AND.m_browse1:ColPos==2) // ALT+?
                      DspOpl1()
                  CASE m_key==K_ESC.OR.m_key==ASC("0")
                    SumSumNds(@m_sum,@m_nds,m_browse1)
                     m_state:="0";EXIT
                  CASE m_key = K_TAB
                     SumSumNds(@m_sum,@m_nds,m_browse1)
                     m_state:="0";EXIT
                DEAL BROWSE m_browse1 KEY m_key
                CASE m_key==K_ENTER   // .OR.Lapnd
                  IF (NumPotr(a_data[3])=="5".AND.m_browse1:ColPos==4).OR.(IsLevel(nakl1->oper))
                      IF NetRLOCK()
                        m_browse1:refreshCurrent()
                        STABILIZE BROWSE m_browse1
                        a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                          ReadMy({a_get1[m_browse1:ColPos]},;
                          IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
                          IF .NOT.EMPTY(a_dop)
                            nakl2->prise:=SetPrise(a_data[3],a_dop)
                            nakl2->KNDS:= a_dop[8]
                            TaxStm(a_data[3])
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
                  IF IsLevel(nakl1->oper)
                    DelStroka(@m_browse1)
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
                CASE m_Key == K_INS
                  IF IsLevel(nakl1->oper)
                    m_browse1:panHome();m_browse1:goBottom()
                    STABILIZE BROWSE m_browse1
                    lApnd:=.t.;m_browse1:down();m_browse1:refreshAll()
                    STABILIZE BROWSE m_browse1
                    ReadStroka(@m_browse1,@a_get1,@a_say1,@a_data,.f.,@a_dop)
                    m_browse1:goBottom();m_browse1:refreshAll()
                  ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                  ENDIF
                ENDCASE
            ENDDO
            m_browse1:RefreshCurrent()
            m_browse1:goTop()
            Stabilize Browse m_browse1
            m_browse1:autolite:=.f.
            m_browse1:DeHilite()
        ENDCASE
      ENDDO
      RestScreen(0,0,MAXROW(),MAXCOL(),m_screen)
      Wselect(n_win)
      IF INDEXORD()<>0;IF c_key<>&(INDEXKEY(0));m_browse:refreshAll()
      ELSE;m_browse:refreshCurrent();END;END
    CASE m_key==K_INS
      STABILIZE BROWSE m_browse
      WSELECT(n_win1)
      m_screen:=SaveScreen(0,0,MAXROW(),MAXCOL())
      RestScreen(0,0,MAXROW(),MAXCOL(),m_screen)
      l_stop:=.t.
      m_valid:=a_get[1]:postBlock;a_get[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid,x))}
      DO WHILE l_stop
        set escape on
        CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
        select nakl1;n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
          a_data[2]:=DATE()
          m_ndoc:=a_data[1]:=STR(fvnum->ndoc,6)
        Display Get a_get KEY n_pole SAY a_say DATA a_data
          n_pole:=1
          DO WHILE .t.
            IF a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A".AND.a_say[n_pole][1][1]==ASC("?")
              KEYBOARD(ASC("?"))
            ENDIF
            ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
            DispSay(@n_pole,@a_say,@a_data)
            DO CASE
              CASE LASTKEY() == K_ESC.AND.ALERT("Вийти iз програми",{"Так","Нi"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT
              CASE LASTKEY() == K_UP.AND.n_pole # 1;n_pole--;LOOP
              CASE n_pole == LEN(a_get)
                IF NetDbAp()
                  n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  nakl1->oper:=m_oper
                  EXIT
                ELSE
                  DispError("Невозможно добавить запись")
                ENDIF
              CASE n_pole == 1.AND.EMPTY(a_data[1]);l_stop:=.f.;EXIT
            OTHERWISE
                IF n_pole==3
                  IF LEN(a_spr01)>0
                      a_data[6]:=a_spr01[4]
                      i:=n_pole;n_pole:=6;a_get[n_pole]:Display()
                      DispSay(@n_pole,@a_say,@a_data)
                      n_pole:=i
                  ENDIF
                END
               DO CASE
                CASE n_pole==14
                  n_pole:=16
                OTHERWISE
                n_pole++
               ENDCASE
            ENDCASE
          ENDDO
          IF LASTKEY()==K_ESC.OR..NOT.l_stop
            EXIT
          ENDIF
          nakl1->vdoc:="1"
          nakl1->day:=DATE()
          IF fvnum->(NetRlock())
            IF m_ndoc<>a_data[1].AND.ANSWERu("Присвоїти накладнiй; номер "+a_data[1]+" ?")==YES
              nakl1->ndoc:=a_data[1]
            ELSE
              nakl1->ndoc:=STR(fvnum->ndoc,LEN(nakl1->ndoc))
              a_data[1]:=nakl1->ndoc;n_pole:=1;a_get[n_pole]:display()
              fvnum->ndoc:=fvnum->ndoc+1
            ENDIF
            nakl1->vnum:=STR(fvnum->vnum,6)
            fvnum->vnum:=fvnum->vnum+1
            fvnum->(DBCOMMIT())
            fvnum->(DbUnlock())
          ELSE
            DispError("Вiдмовлено в доступi")
            EXIT
          ENDIF
          dbUnlock()
          select nakl2
          m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
          EVAL(m_browse1:GotopBlock);lApnd:=.t.
          Display Browse m_browse1
          CountNds(a_data[3])
//          DispS01(m_browse:colorspec,m_sum,m_nds)
          ReadStroka(@m_browse1,@a_get1,@a_say1,@a_data,.t.,@a_dop)
        ENDDO
        a_get[1]:postBlock:=m_valid
        RestScreen(0,0,MAXROW(),MAXCOL(),m_screen)
        Wselect(n_win)
        m_browse:refreshAll()
   FINISH LIST
   WCLOSE(n_win);WCLOSE(n_win1)
   WSELECT(0)
   READEXIT(m_exit)
  SETKEY(K_F4,k_f4)
  SETKEY(K_CTRL_F5,k_Ctrlf5)
  SETKEY(K_ALT_F5,k_altf5)
  SETKEY(K_CTRL_U,k_ctrl_u)
  IF fvnum->(NetRlock())
    fvnum->reg:=CLEARBIT(fvnum->reg,m_computer)
    fvnum->(DBCOMMIT())
    fvnum->(DbUnlock())
  ELSE
    DispError("Вiдмовлено в доступi")
  ENDIF
  IF EMPTY(l_mode)
    ScloseFile(s_files)
    Close Fvnum
    CloseFl1()
  ENDIF
  SavePar(1)
  ENDIF
RETURN .t.
Function EdForm(m_var)
  LOCAL a_get:={},m_key,a_data:={},GetList:={},n_win1,l_close:=.f.,n_win,a_say:={}
  LOCAL n_pole,i,j,k
  SAVEpar()
  IF SELECT(m_var)==0
    l_close:=.t.
    NET USE (m_platpath+m_var)  NEW
  ELSE
    DBSELECTAREA(m_var)
  ENDIF
  n_win:=InitScr(UPPER(m_var))
  INIT GET UPPER(m_var) TO a_get KEY n_pole DATA a_data SAY a_say
  INIT DATA a_data FROM a_get KEY n_pole
  Display Get a_get KEY n_pole SAY a_say DATA a_data
  WSELECT(n_win)
  n_pole:=1
DO WHILE .t.
  DEAL GET a_get KEY n_pole TO m_key COLOR "b/w",TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
  DO CASE
    WORK GET a_get KEY m_key BY n_pole  SAY a_say DATA a_data
  ENDCASE
ENDDO
  WCLOSE(n_win)
  IF l_close
    USE
  ENDIF
  SavePar(1)
RETURN .t.
Function kpt_vl(x,a_dop)
LOCAL m_kod
IF x<>NIL
   m_kod:=x:buffer
IF kaptka1->(DBSEEK(x:buffer))
    a_dop:={kaptka1->kod,kaptka1->name,kaptka1->izm,kaptka1->izm2,kaptka1->prise,kaptka1->prise1,kaptka1->prise2,kaptka1->KNDS}
ELSE
  a_dop:={}
  KEYBOARD "?"
  RETURN .f.
ENDIF
ENDIF
RETURN .t.
Function Spr01(a_spr01)
  IF sp_vl("SPR01")
    a_spr01:={spr01->kpr,spr01->dov,spr01->kod,spr01->kod1}
    RETURN .t.
  ENDIF
  a_spr01:={}
RETURN .f.
STATIC Function sp10(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l:=Sp10->(Sp_VL("SP10A"))
  IF l
    Sp10->(DS(a_data[7]))
    a_data[8]:=BLANK(a_data[8],.t.)
    a_data[09]:=BLANK(a_data[09],.t.)
    Sp10->(DS(a_data[7]))
    IF NumPotr(a_data[3])=="6".OR.NumPotr(a_data[3])=="7".OR.NumPotr(a_data[3])=="2"
      a_data[16]:=PADR(SUBSTR(ALLTRIM(sp10->fam)+" "+ALLTRIM(sp10->imja)+" ";
      +ALLTRIM(sp10->otch)+ " ("+sp10->tabn+")",1,LEN(a_data[16])),LEN(a_data[16]))
    ELSE
      a_data[15]:=PADR(SUBSTR(ALLTRIM(sp10->fam)+" "+ALLTRIM(sp10->imja)+" ";
      +ALLTRIM(sp10->otch)+ " ("+sp10->tabn+")",1,LEN(a_data[15])),LEN(a_data[15]))
    ENDIF
    IF NumPotr(a_data[3])=="6".AND.EMPTY(a_data[12])
      Inv_a->(DBSETORDER(2))
      Inv_a->(DS(a_data[7]))
      a_data[12]:=Inv_a->gnavt
      IF EMPTY(a_data[10])
        a_data[10]:=Inv_a->brgd
      ENDIF
      IF EMPTY(a_data[11])
        a_data[11]:=inv_a->ksash
        Sp44->(DS(a_data[11]))
        Sp01->(DS(a_data[10]))
        a_data[15]:=PADR(SUBSTR(ALLTRIM(sp44->naim7)+" ("+a_data[11]+") "+ALLTRIM(a_data[12])+" ("+a_data[10]+")"+ALLTRIM(Sp01->naim1),1,LEN(a_data[15])),LEN(a_data[15]))
      ENDIF
      Inv_a->(DBSETORDER(1))
    ENDIF
    IF NumPotr(a_data[3])=="7".AND.EMPTY(a_data[13])
      Inv_t->(DBSETORDER(2))
      Inv_t->(DS(a_data[7]))
      a_data[13]:=Inv_t->invnum
      IF EMPTY(a_data[11])
        a_data[11]:=inv_t->ksash
        Sp44->(DS(a_data[11]))
        Sp01->(DS(a_data[10]))
        a_data[15]:=PADR(SUBSTR(ALLTRIM(sp44->naim7)+" ("+a_data[11]+") "+ALLTRIM(a_data[13])+" ("+a_data[10]+")"+ALLTRIM(Sp01->naim1),1,LEN(a_data[15])),LEN(a_data[15]))
      ENDIF
      Inv_t->(DBSETORDER(1))
    ENDIF
    FOR n_pole:=6 TO 16
      a_get[n_pole]:Display()
    NEXT
    n_pole:=i
    RETURN .t.
ENDIF
RETURN .f.
STATIC Function sp17(a_data,a_get,n_pole,m_pension)
  LOCAL i:=n_pole
  LOCAL l:=Sp17->(Sp_VL("SP17"))
  IF l
    Sp17->(DS(a_data[14]))
    IF NumPotr(a_data[3])=="8"
      a_data[15]:=PADR(SUBSTR(ALLTRIM(sp17->fam)+" "+ALLTRIM(sp17->imja)+" ";
      +ALLTRIM(sp17->otch)+ " ("+ALLTRIM(sp17->codn)+")",1,LEN(a_data[15])),LEN(a_data[15]))
    ENDIF
    a_data[8]:=BLANK(a_data[8],.t.)
    a_data[09]:=BLANK(a_data[09],.t.)
    a_data[10]:=BLANK(a_data[10],.t.)
    a_data[11]:=m_pension
    a_data[12]:=BLANK(a_data[12],.t.)
    a_data[13]:=BLANK(a_data[13],.t.)
    FOR n_pole:=6 TO 16
      a_get[n_pole]:Display()
    NEXT
    n_pole:=i
    RETURN .t.
ENDIF
RETURN .f.
STATIC Function firm01(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l
//  l:=firm01->(sp_vl("FIRM01",,,,,,,2))
  l:=firm01->(firm01_vl())
  Firm01->(DBSETORDER(1))
  IF l
    a_data[15]:=PADR(SUBSTR(;
    ALLTRIM(firm01->full1)+ALLTRIM(Firm01->full2)+ " ("+ALLTRIM(firm01->okpo)+")";
    ,1,LEN(a_data[15])),LEN(a_data[15]))
    a_data[7]:=BLANK(a_data[7],.t.)
    a_data[11]:=Firm01->ksash
    a_data[09]:=BLANK(a_data[09],.t.)
    a_data[10]:=BLANK(a_data[10],.t.)
    a_data[12]:=BLANK(a_data[12],.t.)
    a_data[13]:=BLANK(a_data[13],.t.)
    a_data[14]:=BLANK(a_data[14],.t.)
    FOR n_pole:=6 TO 16
      a_get[n_pole]:Display()
    NEXT
    n_pole:=i
    RETURN .t.
ENDIF
RETURN .f.
STATIC Function sp44(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l:=Sp44->(sp_vl("SP44"))
IF l
  IF NumPotr(a_data[3]) =="2"
    Sp01->(DS(a_data[10]))
    a_data[15]:=PADR(SUBSTR(ALLTRIM(sp44->naim7)+" ("+a_data[11]+") "+ALLTRIM(Sp01->naim1)+" ("+a_data[10]+") ";
    ,1,LEN(a_data[15])),LEN(a_data[15]))
    a_data[8]:=BLANK(a_data[8],.t.)
    a_data[09]:=BLANK(a_data[09],.t.)
    a_data[14]:=BLANK(a_data[14],.t.)
    FOR n_pole:=6 TO 16
      a_get[n_pole]:Display()
    NEXT
  ENDIF
  n_pole:=i
RETURN .t.
ENDIF
RETURN .F.
STATIC Function sp01(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l:=Sp01->(sp_vl("SP01"))
  IF l
//    IF NumPotr(a_data[3])=="2"
//      a_data[14]:=PADR(LEFT(ALLTRIM(sp01->naim1)+" ("+sp01->brgd+")",LEN(a_data[14])),LEN(a_data[14]))
//      n_pole:=14;a_get[14]:display();n_pole:=i
//    ENDIF
    RETURN .t.
  ENDIF
RETURN .f.
STATIC Function sp02(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l:=Sp02->(sp_vl("SP02"))
  IF l
    Sp10->(DS(Sp02->tabn))
  a_data[15]:=PADR(SUBSTR(fiomol(sp02->mol),1,LEN(a_data[15])),LEN(a_data[15]))
    a_data[7]:=BLANK(a_data[7],.t.)
    a_data[8]:=BLANK(a_data[8],.t.)
    a_data[10]:=BLANK(a_data[10],.t.)
    a_data[11]:=BLANK(a_data[11],.t.)
    a_data[12]:=BLANK(a_data[12],.t.)
    a_data[13]:=BLANK(a_data[13],.t.)
    FOR n_pole:=6 TO 15
      a_get[n_pole]:Display()
    NEXT
  n_pole:=i
RETURN .t.
ENDIF
RETURN .f.
STATIC Function inv_a(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l
  a_data[i]:=JustRight(a_data[i])
  l:=inv_a->(Sp_VL("INV_A"))
  IF l
    IF EMPTY(a_data[11])
      a_data[11]:=inv_a->ksash
    ENDIF
    Sp44->(DS(a_data[11]))
    Sp01->(DS(a_data[10]))
//    a_data[14]:=PADR(SUBSTR(ALLTRIM(sp44->naim7)+" ("+sp44->ksash+") Автом. "+ALLTRIM(a_data[12]),1,LEN(a_data[14])),LEN(a_data[14]))
    a_data[15]:=PADR(SUBSTR(ALLTRIM(sp44->naim7)+" ("+a_data[11]+") "+ALLTRIM(a_data[12])+" ("+a_data[10]+")"+ALLTRIM(Sp01->naim1),1,LEN(a_data[15])),LEN(a_data[15]))
    a_data[8]:=BLANK(a_data[8],.t.)
    a_data[09]:=BLANK(a_data[09],.t.)
    a_data[13]:=BLANK(a_data[13],.t.)
    FOR n_pole:=6 TO 16
      a_get[n_pole]:Display()
    NEXT
    n_pole:=i
    RETURN .t.
ENDIF
RETURN .f.
STATIC Function inv_t(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l
  a_data[i]:=JustRight(a_data[i])
  l:=inv_t->(Sp_VL("INV_T"))
  IF l
    IF EMPTY(a_data[11])
      a_data[11]:=inv_t->ksash
    ENDIF
    Sp44->(DS(a_data[11]))
    a_data[8]:=BLANK(a_data[8],.t.)
    a_data[09]:=BLANK(a_data[09],.t.)
    a_data[12]:=BLANK(a_data[12],.t.)
    Sp01->(DS(a_data[10]))
    a_data[15]:=PADR(SUBSTR(ALLTRIM(sp44->naim7)+" ("+a_data[11]+") "+ALLTRIM(a_data[13])+" ("+a_data[10]+")"+ALLTRIM(Sp01->naim1),1,LEN(a_data[15])),LEN(a_data[15]))
    FOR n_pole:=6 TO 16
      a_get[n_pole]:Display()
    NEXT
    n_pole:=i
    RETURN .t.
ENDIF
RETURN .f.
Function PrintNakl(a_data,a_pred01)
  LOCAL m_sum:=0,m_nds:=0,i:=1,n_copy,m_kvo,m_rec:=0,m_file,j,m_str
  LOCAL k:=0,l1,l_type
//  LOCAL m_str1
  SavePar()
  DBCOMMITALL()
  m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
//  m_file:="d:\buhgal\temp\t1.lst"
  m_kvo:=ALERT("Кiлькiсть примiрникiв;на друк",{" 1 "," 2 "," 3 "," 4 "},"n/bg,w/b,gr/rb")
  IF m_kvo==0
    SavePar(1)
    RETURN .f.
  ENDIF
  nakl2->(DBSEEK(nakl1->vnum))
  DO WHILE .t.
    nakl2->(DBSKIP(-1))
    IF nakl1->VNUM<>nakl2->VNUM
      nakl2->(DBSKIP())
      EXIT
    ENDIF
    IF nakl2->(BOF())
      EXIT
    ENDIF
  ENDDO
  SET PRINTER TO (m_file)
  SET PRINTER ON
  SET CONSOLE OFF
  m_rec:=Nakl2->(RECNO())
  FOR n_copy:=1 TO m_kvo
    nakl2->(DBGOTO(m_rec))
  IF .NOT.IsUslug(a_data[3])
?""+P_EMPH_ON+CHR(27)+"-1"+PADC(p_npr,22)+""+CHR(27)+"0"+P_EMPH_OFF+CHR(27)+"-0                            Копiя "+STR(n_copy,2)
?"Комiрник "+P_EMPH_ON+fiomol(a_data[4])+" "+CHR(27)+"F("+ALLTRIM(SayOpl(a_data[6]))+")"
?
?"          "+CHR(27)+"FНАКЛАДНА № "+CHR(27)+"w1"+CHR(14)+P_EMPH_ON+ALLTRIM(a_data[1])+""+P_EMPH_OFF+CHR(20)+CHR(27)+"w0 вiд "+P_EMPH_ON+my_dtos(a_data[2])+""+P_EMPH_OFF
?""+CHR(27)+"2Кому        "+P_EMPH_ON+CHR(27)+"-1"+a_data[15]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Через кого  "+P_EMPH_ON+CHR(27)+"-1"+a_data[16]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Призначення "+P_EMPH_ON+CHR(27)+"-1"+a_data[17]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Податкова накладна N"+nakl1->ndoc2+" Дата: "+DTOC(nakl1->ddoc2)
?CHR(27)+"P──┬────────────────────┬──────┬──────────┬────┬──────┬─────────┬────────────┐"
?CHR(27)+"3"+CHR(17)+CHR(27)+"S0 №│ Назва, сорт, розмiр│Один. │ Кiлькiсть│Од. │Кiльк.│   Цiна  │    Сума    │"+CHR(27)+"T"
?CHR(27)+"S0  │                    │вимiру│          │вим2│    2 │ без ПДВ │   до оплати│"+CHR(27)+"T"+CHR(27)+"2"
m_sum:=0;m_nds:=0;i:=1
DO WHILE nakl2->VNUM==nakl1->vnum.AND..NOT.nakl2->(EOF())
  Kaptka1->(DS(nakl2->kod))
  m_str:=ALLTRIM(kaptka1->name)+" "+ALLTRIM(kaptka1->name2)+ALLTRIM(kaptka1->p1)
  IF n_copy==m_kvo
/*    IF (AT(NumPotr(a_data[3]),"267")<>0)
      m_str+=" "+a_data[11]+" "+kaptka1->ksash
    ELSE
      IF NumPotr(a_data[3])=="3"
        m_str+=" "+kaptka1->ksash+" "+kaptka1->ksash
      ELSE
        m_str+=" "+kaptka1->ksash2+" "+kaptka1->ksash
      ENDIF
    ENDIF  */
  ENDIF
  ?"──┼────────────────────┼──────┼──────────┼────┼──────┼─────────┼────────────┤"
    k:=1
    DO WHILE .NOT.EMPTY(m_str).OR.k==1
      IF LEN(m_str)>20
        j:=RAT(" ",SUBSTR(m_str,1,20))
      ELSE
        j:=0
      ENDIF
      l1:=IF(j==0,20,j)
        IF k==1
           ?STRZERO(i,2)+"│"+PADR(LEFT(m_str,l1),20)+"│ "+PADR(Kaptka1->izm,5)+"│"+STR(nakl2->kvo,10,2)+"│"+PADR(Kaptka1->izm2,4)+"│"+NumtoSTR(nakl2->glv,6)+"│"+Str(nakl2->prise,9,3)+"│"+SumToStr(nakl2->stm+nakl2->nds,12)+"│"
        ELSE
        ?"  │"+PADR(LEFT(m_str,l1),20)+"│      │          │    │      │         │            │"
        ENDIF
        m_str:=SUBSTR(m_str,l1+1)
      k++
    ENDDO
  i++;m_sum+=nakl2->stm;m_nds+=nakl2->nds
  nakl2->(Dbskip())
ENDDO
?"──┴────────────────────┴──────┴──────────┴────┴──────┴─────────┴───────────┘"
// ?"                                                              "+SumToStr(m_sum+m_nds,11)+CHR(27)+"P"
?"Сума   "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_sum))+P_EMPH_OFF+CHR(27)+"P"
??" ПДВ "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_nds))+P_EMPH_OFF+CHR(27)+"P"
?"До оплати "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_sum+m_nds))+""+CHR(27)+"F/"+SumStr(m_sum+m_nds)+"/,"+CHR(27)+"P"
?""+CHR(27)+"3-"+CHR(27)+"EВиписав:"+CHR(27)+"F "+ALLTRIM(_Fio(m_tabn))+"  "+CHR(27)+"S1"+DTOS(DATE())+TIME()+STR(m_computer,1)+m_oper+CHR(27)+"T"
?""+CHR(27)+"EДозволено"+CHR(27)+"F ___________  "+P_EMPH_ON+CHR(27)+"-1"+a_pred01[3]+P_EMPH_OFF+CHR(27)+"-0"+"  ________________ "+P_EMPH_ON+CHR(27)+"-1"+a_pred01[4]+P_EMPH_OFF+CHR(27)+"-0"+CHR(27)+"0"
?"            "+CHR(27)+"S0(керiвник)       "+SPACE(LEN(a_pred01[3]))+"  (Гол. бухгалтер)"+CHR(27)+"T"+CHR(27)+"3-"
?""+CHR(27)+"EВiдпустив"+CHR(27)+"F _________   "+P_EMPH_ON+CHR(27)+"-1"+FioOfMol(a_data[4]) + P_EMPH_OFF+CHR(27)+"-0"+CHR(27)+"E    Прийняв"+CHR(27)+"F  ______________"
?""+CHR(27)+"2"
?
?
ELSE
?""+P_EMPH_ON+CHR(27)+"-1"+PADC(p_npr,22)+""+CHR(27)+"0"+P_EMPH_OFF+CHR(27)+"-0                            Копiя "+STR(n_copy,2)
Sp01->(DS(a_data[5]))
?"Бригада  "+CHR(27)+"E "+Sp01->naim1+"        "+CHR(27)+"F("+ALLTRIM(SayOpl(a_data[6]))+")"
?"     "+CHR(27)+"FКВИТАНЦIЯ НА ПОСЛУГИ № "+CHR(27)+"w1"+CHR(14)+P_EMPH_ON+ALLTRIM(a_data[1])+""+P_EMPH_OFF+CHR(20)+CHR(27)+"w0 вiд "+P_EMPH_ON+my_dtos(a_data[2])+""+P_EMPH_OFF
?""+CHR(27)+"2Кому        "+P_EMPH_ON+CHR(27)+"-1"+a_data[15]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Через кого  "+P_EMPH_ON+CHR(27)+"-1"+a_data[16]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Призначення "+P_EMPH_ON+CHR(27)+"-1"+a_data[17]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Податкова накладна N"+nakl1->ndoc2+" Дата: "+DTOC(nakl1->ddoc2)
?CHR(27)+"P──┬────────────────────┬──────┬──────────┬─────────┬────────────┐"
?CHR(27)+"3"+CHR(17)+CHR(27)+"S0 №│ Назва, сорт, розмiр│Один. │ Кiлькiсть│   Цiна  │    Сума    │"+CHR(27)+"T"
?CHR(27)+"S0  │                    │вимiру│          │ без ПДВ │  до оплати │"+CHR(27)+"T"+CHR(27)+"2"
m_sum:=0;m_nds:=0;i:=1
DO WHILE nakl2->VNUM==nakl1->vnum.AND..NOT.nakl2->(EOF())
  Kaptka1->(DS(nakl2->kod))
  m_str:=ALLTRIM(kaptka1->name)
  IF n_copy==m_kvo
    m_str+=" "+kaptka1->ksash2+" "+kaptka1->ksash
  ENDIF
  ?"──┼────────────────────┼──────┼──────────┼─────────┼────────────┤"
    k:=1
    DO WHILE .NOT.EMPTY(m_str)
      j:=RAT(" ",SUBSTR(m_str,1,20))
      IF LEN(m_str)>20
        l1:=IF(j==0,20,j)
      ELSE
        l1:=LEN(m_str)
      ENDIF

        IF k==1
           ?STRZERO(i,2)+"│"+PADR(LEFT(m_str,l1),20)+"│ "+PADR(Kaptka1->izm,5)+"│"+STR(nakl2->kvo,10,2)+"│"+Str(nakl2->prise,9,3)+"│"+SumToStr(nakl2->stm+nakl2->nds,12)+"│"
        ELSE
        ?"  │"+PADR(LEFT(m_str,l1),20)+"│      │          │         │            │"
        ENDIF
        m_str:=SUBSTR(m_str,l1+1)
      k++
    ENDDO
  i++;m_sum+=nakl2->stm;m_nds+=nakl2->nds
  nakl2->(Dbskip())
ENDDO
?"──┴────────────────────┴──────┴──────────┴─────────┴────────────┘"
// ?"                                                              "+SumToStr(m_sum+m_nds,11)+CHR(27)+"P"
?"Сума   "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_sum))+""+P_EMPH_OFF+CHR(27)+"P"
??"ПДВ "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_nds))+""+P_EMPH_OFF+CHR(27)+"P"
?"До оплати "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_sum+m_nds))+""+CHR(27)+"F/"+SumStr(m_sum+m_nds)+"/,"+CHR(27)+"P"
?""+CHR(27)+"3-"+CHR(27)+"EВиписав:"+CHR(27)+"F "+ALLTRIM(_Fio(m_tabn))+"   "+CHR(27)+"S1"+DTOS(DATE())+TIME()+STR(m_computer,1)+m_oper+CHR(27)+"T"
?""+CHR(27)+"EДозволено"+CHR(27)+"F ________________            _____________________"+CHR(27)+"0"
?"            "+CHR(27)+"S0(керiвник)                 (бухгалтер)"+CHR(27)+"T"+CHR(27)+"3-"
?""+CHR(27)+"EВiдпустив"+CHR(27)+"F ________________   "+CHR(27)+"EОдержав"+CHR(27)+"F  ____________________"
?""+CHR(27)+"2"
?
?

ENDIF
IF n_copy<>m_kvo.AND.ALERT("Формування экземпляру"+STR(n_copy,2)+" завершено;Виконувати прогiн листа?",{" Да "," Нi "},"n/bg,n/w")==1
?CHR(K_CTRL_L)
ENDIF
NEXT
IF nakl1->(NetRlock())
  nakl1->pCount:=nakl1->pCount+1
  nakl1->(DbUnlock())
ENDIF

  SET CONSOLE ON
  SET PRINTER TO
  SET PRINTER OFF
  IF SPOOLACTIV().AND.SPOOLCOUNT()<8
//    IF Is_Ready_Prn()
      SPOOLADD(m_file)
//    ENDIF
  ELSE
    MyPRINTFILE(m_file)
  ENDIF
  SavePar(1)
RETURN .t.
FUNCTION SUMSTR(m_sum)
 LOCAL m_str:=NumTochar(INT(m_sum)) +" грн.",i,s:=ALLTRIM(STR(INT(m_sum))),s1,s2:=""
  i:=ROUND(100*(m_sum-INT(m_sum)),0);s1:=STRZERO(i,2)
  m_str+=+" "+s1+" коп."
 return m_str
Function FioMol(m_var)
  IF Sp02->(DBSEEK(m_var))
    RETURN PADR(ALLTRIM(_fio(sp02->tabn))+" ("+sp02->mol+")",29)
  ENDIF
RETURN ""
Function FioOfMol(m_var)
  IF Sp02->(DBSEEK(m_var))
    RETURN ALLTRIM(_fio(sp02->tabn))
  ENDIF
RETURN ""


Function GetlApnd()
RETURN .not.lApnd

Function NumPotr(var)
  spr01->(DBSEEK(var))
RETURN spr01->potr

Function SetPrise(var,a_dop)
  spr01->(DBSEEK(var))
  DO CASE
    CASE spr01->prise=="2"
      RETURN a_dop[6]
    CASE spr01->prise=="3"
      RETURN a_dop[7]
  ENDCASE
RETURN a_dop[5]

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
STATIC Function PrintLs()
LOCAL m_file,m_ddoc,c_key,m_buf,GetList:={}
LOCAL i,j,k,c_dov,m_sum,n_page:=1,m_line:=GetEndPage()
LOCAL m_str0
LOCAL m_str1:="------------------------------------------------------------------------------------------"
LOCAL m_str2:="  Номер I        I                             I                             I            "
LOCAL m_str3:="докумен.I Дата   I   Одержувач                 I    Продукцiя                I   Оплата   "
LOCAL m_str4:="------------------------------------------------------------------------------------------"
        // Ввести дату
        savepar()
        m_ddoc:=nakl1->ddoc
        @INT((MAXROW()-4)/2),5,INT((MAXROW()-4)/2)+3,75 BOX B_DOUBLE+" " COLOR ("w+/bg")
        @INT((MAXROW()-4)/2)+1,6 SayDisp PADC( 'Введiть значення дати для друку',68) COLOR "GR+/bg"
        @INT((MAXROW()-4)/2)+2,38 GET m_ddoc COLOR "w/b,Gr+/n"
        READ
        IF LASTKEY()==K_ESC
          SavePar(1)
          RETURN .f.
        ENDIF
        // найти дату
        m_str0:=PADC("Перелiк документiв за "+My_DTOS(m_ddoc),72)+"Лист "
        Nakl1->(DBSETORDER(0))
        nakl1->(DBGOBOTTOM())
        DO WHILE .NOT.nakl1->(BOF()).AND.nakl1->day>m_ddoc
          nakl1->(DBSKIP(-1))
        ENDDO
        IF nakl1->day<>m_ddoc
          DispError("Накладнi за "+DTOC(m_ddoc)+" не знайденi ")
          Nakl1->(DBSETORDER(1))
          SavePar(1)
          RETURN .f.
        ENDIF
        DO WHILE .NOT.nakl1->(BOF()).AND.nakl1->day==m_ddoc
          nakl1->(DBSKIP(-1))
        ENDDO
        IF .NOT.nakl1->(BOF())
          nakl1->(DBSKIP())
        ENDIF
        m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
        SET PRINTER TO (m_file)
        SET DEVICE TO PRINTER
        SetWidthPrn(LEN(m_str1))
        // распечатать данные
        @PROW(),0 SAY m_str0+STR(n_page,2)
        n_page++
        @PROW()+1,0 SAY m_str1
        @PROW()+1,0 SAY m_str2
        @PROW()+1,0 SAY m_str3
        @PROW()+1,0 SAY m_str4
        DO WHILE .NOT.nakl1->(EOF()).AND.nakl1->day==m_ddoc
          c_key:="";m_sum:=0
          m_buf:=IF(nakl1->day<>nakl1->ddoc,LEFT(DTOC(nakl1->ddoc),2)+"."+SUBSTR(DTOC(nakl1->ddoc),4,2)+" ","")+Alltrim(nakl1->fio1)
          DO WHILE nakl1->vnum==nakl2->vnum.AND..NOT.nakl2->(EOF())
            Kaptka1->(DS(nakl2->kod))
            c_key:=c_key+RTRIM(IF(EMPTY(c_key),"",",")+ALLTRIM(Kaptka1->name)+" ";
+ALLTRIM(STR(nakl2->kvo))+" "+ALLTRIM(Kaptka1->izm)+IF(nakl2->glv<>0," "+ALLTRIM(STR(nakl2->glv))+" "+ALLTRIM(Kaptka1->izm2),""))
            m_sum+=nakl2->stm+nakl2->nds
            nakl2->(DBSKIP())
          ENDDO
          c_key+=" "+ALLTRIM(SumToStr(m_sum,14))
          IF PROW()>=m_line+1
              StrToPrn(IF(GetParPrn(2)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
              SETPRC(0,0)
              @PROW(),0 SAY m_str0+STR(n_page,2)
              n_page++
              @PROW()+1,0 SAY m_str1
              @PROW()+1,0 SAY m_str2
              @PROW()+1,0 SAY m_str3
              @PROW()+1,0 SAY m_str4
          ENDIF
          @PROW()+1,0 Say nakl1->ndoc
//          @PROW(),7 Say " I"
//          @PROW(),9 Say LEFT(DTOC(nakl1->ddoc),2)+"."+SUBSTR(DTOC(nakl1->ddoc),2),4,2))
//          @PROW(),17 Say "I"
          @PROW(),8 Say "I"
          j:=RAT(" ",SUBSTR(m_buf,1,38))
          IF j==0.OR.LEN(m_buf)<38
            @PROW(),9 Say SUBSTR(m_buf,1,38)
            m_buf:=SUBSTR(m_buf,39)
          ELSE
            @PROW(),9 Say SUBSTR(m_buf,1,j-1)
            m_buf:=SUBSTR(m_buf,j+1)
          ENDIF
          @PROW(),46 Say " I "
          i:=MAX(RAT(" ",SUBSTR(c_key,1,27)),RAT(",",SUBSTR(c_key,1,27)))
          IF i==0.OR.LEN(c_key)<27
            @PROW(),49 Say SUBSTR(c_key,1,27)
            c_key:=SUBSTR(c_key,28)
          ELSE
            @PROW(),49 Say SUBSTR(c_key,1,i-1)
            c_key:=SUBSTR(c_key,i+1)
          ENDIF
          @PROW(),76 Say " I "
          c_dov:=ALLTRIM(nakl1->dov)
          j:=RAT(" ",SUBSTR(c_dov,1,15))
          IF j==0.OR.LEN(c_dov)<15
            @PROW(),79 Say SUBSTR(c_dov,1,15)
            c_dov:=SUBSTR(c_dov,16)
          ELSE
            @PROW(),79 Say SUBSTR(c_dov,1,j-1)
            c_dov:=SUBSTR(c_dov,j+1)
          ENDIF
//        @PROW(),70 Say ALLTRIM(nakl1->dov)
          DO WHILE .NOT.EMPTY(m_buf).OR..NOT.EMPTY(c_key).OR..NOT.EMPTY(c_dov)
            IF PROW()>=m_line+1
                StrToPrn(IF(GetParPrn(2)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
                SETPRC(0,0)
                @PROW(),0 SAY m_str0+STR(n_page,2)
                n_page++
                @PROW()+1,0 SAY m_str1
                @PROW()+1,0 SAY m_str2
                @PROW()+1,0 SAY m_str3
                @PROW()+1,0 SAY m_str4
            ENDIF
            @PROW()+1,0 SAY ""
            @PROW(),7 Say " I"
            IF .NOT.EMPTY(m_buf)
              j:=RAT(" ",SUBSTR(m_buf,1,38))
              IF j==0.OR.LEN(m_buf)<38
                @PROW(),9 Say SUBSTR(m_buf,1,38)
                m_buf:=SUBSTR(m_buf,39)
              ELSE
                @PROW(),9 Say SUBSTR(m_buf,1,j-1)
                m_buf:=SUBSTR(m_buf,j+1)
              ENDIF
            ENDIF
          @PROW(),46 Say " I "
            IF .NOT.EMPTY(c_key)
              i:=MAX(RAT(" ",SUBSTR(c_key,1,27)),RAT(",",SUBSTR(c_key,1,27)))
              IF i==0.OR.LEN(c_key)<27
                @PROW(),49 Say SUBSTR(c_key,1,27)
                c_key:=SUBSTR(c_key,28)
              ELSE
                @PROW(),49 Say SUBSTR(c_key,1,i-1)
                c_key:=SUBSTR(c_key,i+1)
              ENDIF
            ENDIF
          @PROW(),76 Say " I "
          IF .NOT.EMPTY(c_dov)
            j:=RAT(" ",SUBSTR(c_dov,1,15))
            IF j==0.OR.LEN(c_dov)<15
              @PROW(),79 Say SUBSTR(c_dov,1,15)
              c_dov:=SUBSTR(c_dov,16)
            ELSE
              @PROW(),79 Say SUBSTR(c_dov,1,j-1)
              c_dov:=SUBSTR(c_dov,j+1)
            ENDIF
          ENDIF
          ENDDO
          nakl1->(DBSKIP())
        ENDDO
        @PROW()+1,0 SAY CHR(27)+"!"+CHR(0)+REPLICATE("=",60)
        @PROW()+1,0 SAY ""
        SET PRINTER TO
        SET DEVICE TO SCREEN
        IF SPOOLACTIV().AND.SPOOLCOUNT()<6
            SPOOLADD(m_file)
        ELSE
          MyPRINTFILE(m_file)
//          PRINTFILE(m_file,.t.)
        ENDIF
        Nakl1->(DBSETORDER(1))
        SavePar(1)
RETURN .t.

STATIC Function KaltF7()
LOCAL m_recno1:=Nakl1->(RECNO()),m_recno2:=Nakl2->(RECNO()),a_dop:={},GetList:={},m_screen
LOCAL m_poisk:=.t.,m_gauge,i:=1
STATIC m_tabn,m_okpo,m_ksash,m_kod,m_stm1,m_stm2,m_ddoc1,m_ddoc2
// SaveCur()
IF m_ddoc1==NIL
  m_ddoc1:=BLANK(nakl1->ddoc,,.t.)
  m_ddoc2:=BLANK(nakl1->ddoc,.t.)
  m_tabn:=BLANK(nakl1->tabn,.t.)
  m_ksash:=BLANK(nakl1->ksash,.t.)
  m_okpo:=BLANK(nakl1->okpo,.t.)
  m_kod :=BLANK(nakl2->kod ,.t.)
  m_stm1:=BLANK(nakl1->sum,.t.)
  m_stm2:=BLANK(nakl1->sum,.t.)
ENDIF
#DEFINE ROW1 INT((MAXROW()- 10)/2)
#DEFINE COL1 INT((MAXCOL()- 60)/2)
//Сложный поиск
m_screen:=SAVESCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64)
@ROW1,COL1,ROW1+ 11,COL1+ 62 BOX (B_SINGLE+' ') COLOR ("w/b")
SHADOW(ROW1,COL1,ROW1+ 11,COL1+ 62)
@ROW1,COL1+INT( 37/2) SayText "~3Сложный поиск накладной" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+1+ 10,COL1+INT( 60/2) SayText "~4" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  1,COL1+1 SayText "~2Найти накладную" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  2,COL1+1 SayText "~2с           по" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  3,COL1+1 SayText "~2Таб. номер" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  4,COL1+1 SayText "~2ОКПО" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  5,COL1+1 SayText "~2ШПЗ" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  6,COL1+1 SayText "~2Код мат-ла" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  7,COL1+1 SayText "~2Стоимость c             по   " COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
// SET CURSOR ON
SET ESCAPE ON
@ROW1+  2,COL1+  3 Get m_ddoc1 COLOR ("n/w,gr+/n")
@ROW1+  2,COL1+ 17 Get m_ddoc2 COLOR ("n/w,gr+/n")
@ROW1+  3,COL1+ 12 Get m_tabn VALID sp10->(sp_vl("SP10A","2",ROW1+  3,COL1+ 22,"_fio()","Gr+/b")) COLOR ("n/w,gr+/n")
@ROW1+  4,COL1+ 12 Get m_okpo COLOR ("n/w,gr+/n")
@ROW1+  5,COL1+ 12 Get m_ksash VALID sp44->(sp_vl("SP44","2",ROW1+  5,COL1+ 22,"sp44->naim7","Gr+/b"))  COLOR ("n/w,gr+/n")
@ROW1+  6,COL1+ 12 Get m_kod  VALID kaptka1->(sp_vl("KAPTKA1","2",ROW1+  6,COL1+ 22,"kaptka1->name","Gr+/b"))   COLOR ("n/w,gr+/n")
@ROW1+  7,COL1+ 12 Get m_stm1 COLOR ("n/w,gr+/n") PICTURE "9'999'999.99"
@ROW1+  7,COL1+ 27 Get m_stm2 COLOR ("n/w,gr+/n") PICTURE "9'999'999.99"
// Firm01->(DBSETORDER(2))
GetList[4]:PostBlock:={|x|firm01->(firm01a(x))}
READMY(GetList)
// Firm01->(DBSETORDER(1))
// SET CURSOR OFF
IF LASTKEY()==K_ESC
  RESTSCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64,m_screen)
  RETURN .f.
ENDIF
m_gauge:=InitGauge("Пошук накладної")
DO WHILE .t.
  nakl1->(DBSKIP())
  i++;DispGauge(m_gauge,i/nakl1->(LASTREC()))
  IF nakl1->(EOF())
    DelGauge(m_gauge)
    DispErr("Накладна не знайдена")
    nakl1->(DBGOTO(m_recno1));nakl2->(DBGOTO(m_recno2))
    RESTSCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64,m_screen)
//    SavePar(1)
    RETURN .f.
  ENDIF
  IF .NOT.EMPTY(m_ddoc1)
    IF nakl1->ddoc<m_ddoc1
      LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_ddoc2)
    IF nakl1->ddoc>m_ddoc2
      LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_tabn)
    IF nakl1->tabn<>m_tabn
      LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_okpo)
    IF nakl1->okpo<>m_okpo
      LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_ksash)
    IF nakl1->ksash<>m_ksash
      LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_ksash)
    IF nakl1->ksash<>m_ksash
      LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_stm1)
    IF nakl1->sum<m_stm1
      LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_stm2)
    IF nakl1->sum>m_stm2
      LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_kod)
    IF nakl2->(DS(nakl1->vnum))
      DO WHILE nakl1->vnum==nakl2->vnum.AND..not.nakl2->(EOF()).and.nakl2->kod<>m_kod
        nakl2->(DBSKIP())
      ENDDO
    ENDIF
    IF nakl1->vnum<>nakl2->vnum.OR.nakl2->(EOF())
      LOOP
    ENDIF
  ENDIF
  EXIT
ENDDO
DelGauge(m_gauge)
RESTSCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64,m_screen)
// RestCur()
RETURN .t.

STATIC Function firm01a(x)
  LOCAL a_par:={"full1","full2","okpo"}
  LOCAL a_firm:={}
  firm01->(DBSETORDER(2))
  IF .NOT.firm01->(DS(EVAL(x:block)))
    firm01->(DBSETORDER(1))
    vl_sp("FIRM01",,@a_firm,a_par)
    IF .NOT.EMPTY(a_firm)
      EVAL(x:block,a_firm[3]);x:upDateBuffer()
      x:display()
      @ROW1+  4,COL1+ 22  SayDisp ALLTRIM(a_firm[1])+" "+ALLTRIM(a_firm[2]) COLOR "GR+/B"
    ENDIF
  ELSE
    firm01->(DBSETORDER(1))
  ENDIF
RETURN .t.
#UNDEF ROW1
#UNDEF COL1

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

Function DispOpl(mode)
LOCAL n_win,m1:=IF(mode==NIL,"0",mode)
LOCAL a_get:={},i:=1,n_pole:=1,m_key
IF nakl1->(NetRlock())
  ASIZE(a_get,18);AEVAL(a_get,{|x|a_get[i]:=GetNew(),a_get[i]:ColorSpec:="w/B,GR+/n",i++})
  a_get[1]:Block:=COLBR(nakl1->ddoc1);a_get[1]:Row:=2;a_get[1]:Col:=13
  a_get[2]:Block:=COLBR(nakl1->ndoc1);a_get[2]:Row:=2;a_get[2]:Col:=39;a_get[2]:picture:="@K"
  a_get[3]:Block:=COLBR(nakl1->npch1);a_get[3]:Row:=2;a_get[3]:Col:=53;a_get[3]:picture:="@K"
  a_get[2]:PostBlock:=a_get[3]:PostBlock:={|p|EVAL(p:block,JustRight(EVAL(p:block))),p:display(),IF(.NOT.EMPTY(p:buffer).OR.nakl1->sum1==0,.t.,.f.)}
  a_get[4]:Block:=COLBR(nakl1->kod1);a_get[4]:Row:=3;a_get[4]:Col:=14
  a_get[4]:PostBlock:={||KodOpl()}
  a_get[5]:Block:=COLBR(nakl1->sum1);a_get[5]:Row:=3;a_get[5]:Col:=46
  a_get[5]:PreBlock:={||IF(EMPTY(nakl1->ddoc1).OR.EMPTY(nakl1->ndoc1).OR.EMPTY(nakl1->kod1),.f.,.t.)}
  a_get[5]:picture:="@K 999'999.99"
  a_get[6]:Block:=COLBR(nakl1->ddoc1a);a_get[6]:Row:=4;a_get[6]:Col:=13
  a_get[7]:Block:=COLBR(nakl1->ndoc1a);a_get[7]:Row:=4;a_get[7]:Col:=39;a_get[7]:picture:="@K"
  a_get[8]:Block:=COLBR(nakl1->npch1a);a_get[8]:Row:=4;a_get[8]:Col:=53;a_get[8]:picture:="@K"
  a_get[7]:PostBlock:=a_get[8]:PostBlock:={|p|EVAL(p:block,JustRight(EVAL(p:block))),p:display(),IF(.NOT.EMPTY(p:buffer).OR.nakl1->sum1==0,.t.,.f.)}
  a_get[9]:Block:=COLBR(nakl1->kod1a);a_get[9]:Row:=5;a_get[9]:Col:=14
  a_get[9]:PostBlock:={||EMPTY(nakl1->kod1a).OR.KodOpl()}
  a_get[10]:Block:=COLBR(nakl1->sum1a);a_get[10]:Row:=5;a_get[10]:Col:=46
  a_get[10]:PreBlock:={||IF(EMPTY(nakl1->ddoc1a).OR.EMPTY(nakl1->ndoc1a).OR.EMPTY(nakl1->kod1a),.f.,.t.)}
  a_get[10]:picture:="@K 999'999.99"
  a_get[11]:Block:=COLBR(nakl1->ddoc1b);a_get[11]:Row:=6;a_get[11]:Col:=13
  a_get[12]:Block:=COLBR(nakl1->ndoc1b);a_get[12]:Row:=6;a_get[12]:Col:=39;a_get[7]:picture:="@K"
  a_get[13]:Block:=COLBR(nakl1->npch1b);a_get[13]:Row:=6;a_get[13]:Col:=53;a_get[8]:picture:="@K"
  a_get[12]:PostBlock:=a_get[13]:PostBlock:={|p|EVAL(p:block,JustRight(EVAL(p:block))),p:display(),IF(.NOT.EMPTY(p:buffer).OR.nakl1->sum1==0,.t.,.f.)}
  a_get[14]:Block:=COLBR(nakl1->kod1b);a_get[14]:Row:=7;a_get[14]:Col:=14
  a_get[14]:PostBlock:={||EMPTY(nakl1->kod1a).OR.KodOpl()}
  a_get[15]:Block:=COLBR(nakl1->sum1b);a_get[15]:Row:=7;a_get[15]:Col:=46
  a_get[15]:PreBlock:={||IF(EMPTY(nakl1->ddoc1b).OR.EMPTY(nakl1->ndoc1b).OR.EMPTY(nakl1->kod1b),.f.,.t.)}
  a_get[15]:picture:="@K 999'999.99"
  a_get[16]:Block:=COLBR(nakl1->ndoc2);a_get[16]:Row:=9;a_get[16]:Col:=20
  a_get[16]:PostBlock:={|p|EVAL(p:block,JustRight(EVAL(p:block))),p:display(),.t.}
  a_get[17]:Block:=COLBR(nakl1->ddoc2);a_get[17]:Row:=9;a_get[17]:Col:=46
  a_get[18]:Block:=COLBR(nakl1->ddoc3);a_get[18]:Row:=11;a_get[18]:Col:=20
//  a_get[18]:PostBlock:={|p|IF(.NOT.EMPTY(nakl1->ddoc3),nakl1->state:=CHR(SETBIT(ASC(nakl1->state),2)),;
//  nakl1->state:=CHR(CLEARBIT(ASC(nakl1->state),2))),.t.}
  a_get[18]:PostBlock:={|p|F001()}
/*  a_get[19]:Block:=COLBR(nakl1->prise1);a_get[19]:row:=12;a_get[19]:col:=40
  a_get[20]:Block:=COLBR(nakl1->stm1);a_get[20]:row:=13;a_get[20]:col:=20
  a_get[21]:Block:=COLBR(nakl1->stm2);a_get[21]:row:=14;a_get[21]:col:=20
  a_get[19]:picture:=a_get[20]:picture:=a_get[21]:picture:="@K 999'999.99" */
  SavePar()
  n_win:=InitScr("NAKL02")
  @1,39 SayDisp ALLTRIM(SayOper(nakl1->oper)) COLOR "GR+/N*"
  @11,30 SayDisp ALLTRIM(SayOper(nakl1->oper1)) COLOR "GR+/N*"
  AEVAL(a_get,{|x|x:display()})
  IF m1=="0" // Исправление
    DO WHILE .t.
      @3,17 SayDisp SayOpl(nakl1->kod1) COLOR "GR+/N*"
      @5,17 SayDisp SayOpl(nakl1->kod1a) COLOR "GR+/N*"
      @7,17 SayDisp SayOpl(nakl1->kod1b) COLOR "GR+/N*"
      a_get[n_pole]:ColorDisp("b/w")
      m_key:=INKEY(0)
      a_get[n_pole]:ColorDisp("w/B,GR+/n")
      DO CASE
        CASE m_key==K_ENTER
          IF IsLevel(nakl1->oper)
            ReadMy({a_get[n_pole]})
          ELSE
              DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
          ENDIF
        CASE m_key==K_PGDN
          n_pole:=LEN(a_get)
        CASE m_key==K_PGUP
          n_pole:=1
        CASE m_key==K_DOWN
          n_pole:=IF(n_pole==LEN(a_get),1,n_pole+1)
        CASE m_key==K_UP
          n_pole:=IF(n_pole==1,LEN(a_get),n_pole-1)
        CASE m_key==K_ESC.OR.m_key==K_F12.OR.m_key==K_CTRL_END
          EXIT
      ENDCASE
    ENDDO
  ELSE
    DO WHILE .t.
      @3,17 SayDisp SayOpl(nakl1->kod1) COLOR "GR+/N*"
      @5,17 SayDisp SayOpl(nakl1->kod1a) COLOR "GR+/N*"
      @7,17 SayDisp SayOpl(nakl1->kod1b) COLOR "GR+/N*"
      ReadMy({a_get[n_pole]})
      DO CASE
        CASE LASTKEY()==K_PGUP
          n_pole:=1
        CASE LASTKEY()==K_PGDN
          n_pole:=LEN(a_get)
        CASE LASTKEY()==K_UP
          n_pole:=IF(n_pole==1,1,n_pole-1)
        CASE LASTKEY()==K_ESC.OR.LASTKEY()==K_F12.OR.LASTKEY()==K_CTRL_END.OR.n_pole==LEN(a_get)
          EXIT
        OTHERWISE
          n_pole++
      ENDCASE
    ENDDO
  ENDIF
  WCLOSE(n_win)
  nakl1->state:=IF(nakl1->sum==nakl1->sum1+nakl1->sum1a+nakl1->sum1b,;
  CHR(SETBIT(ASC(nakl1->state),1)),;
  CHR(NUMAND(ASC(nakl1->state),254)))
  SavePar(1)
  nakl1->(DbUnlock())
ENDIF
RETURN .t.
Function KodOpl()
  LOCAL a_mass:={},n_win,n_winold:=WSELECT()
  LOCAL oCurGet:=GETACTIVE ( ),b_block:={|x|SayOpl(x)}
  LOCAL m_var:=oCurGet:VarGet(),i,m_answer

IF EMPTY(m_var)
   RETURN .t.
ENDIF

IF .not.EMPTY(SayOpl(m_var))
   RETURN .t.
ENDIF
SavePar()
n_win:=WOPEN(2,20,23,60)
@0,0,MAXROW(),MAXCOL() BOX B_SINGLE+" " COLOR "w/b"
WSELECT(n_win)
FOR i:=1 TO LEN(a_kod1)
  AADD(a_mass,a_kod1[i,1]+" "+a_kod1[i,2])
NEXT
@1,1 SayDisp PADC("Види оплати",MAXCOL()-2) COLOR "GR+/B"
m_answer:=EditMass(a_mass,,,,,b_block,2)
WCLOSE()
WSELECT(n_winold)
SavePar(1)
RETURN m_answer

Function SayOpl(var1)
LOCAL i:=ASCAN(a_kod1,{|x|(x[1]==var1)})
IF i==0
  return SPACE(16)
ENDIF
return a_kod1[i,2]
Function FormNalog()
  LOCAL m_ndoc,m_vnum,m_rec2:=nakl2->(RECNO()),m_sum:=0,m_nds:=0,i
  IF .NOT.RECURS()
  SAVEPAR()
  fvnum->(DBGOTO(2))
  IF fvnum->(NetRlock())
    fvnum->reg:=SETBIT(fvnum->reg,m_computer)
    m_vnum:=fvnum->vnum
    fvnum->vnum:=fvnum->vnum+1
  ELSE
    DispError("Вiдмовлено в доступi")
    SAVEPAR(1)
    fvnum->(DBGOTO(1))
    RETURN .f.
  ENDIF
  IF .NOT.EMPTY(nakl1->ndoc2)
    DispError("Податкова накладна сформована;її номер "+nakl1->ndoc2)
  ENDIF
  IF ANSWER("Формирувати податкову накладну?")==YES
    nalog1->(DBSETORDER(1))
    nakl2->(DBSEEK(nakl1->vnum))
    DO WHILE .t.
      nakl2->(DBSKIP(-1))
      IF nakl1->VNUM<>nakl2->VNUM
        nakl2->(DBSKIP())
        EXIT
      ENDIF
      IF nakl2->(BOF())
        EXIT
      ENDIF
    ENDDO
    m_sum:=0;m_nds:=0
    DO WHILE nakl2->VNUM==nakl1->vnum.AND..NOT.nakl2->(EOF())
      IF nalog2->(NetDbAp())
        nalog2->vnum := STR(m_vnum,6)
        nalog2->NumNakl:=nakl1->ndoc
        nalog2->ddoc := nakl1->ddoc
        nalog2->kod  := nakl2->kod
        Kaptka1->(DS(nakl2->kod))
        nalog2->name := kaptka1->name
        nalog2->izm  := Kaptka1->izm
        nalog2->kvo  := nakl2->kvo
        nalog2->prise:= nakl2->prise
        IF  nakl2->nds<>0
          nalog2->sum1 :=nakl2->stm
          nalog2->nds  := nakl2->nds
          nalog2->stm  := nalog2->sum1 + nalog2->nds
        ELSE
          nalog2->sum4 :=nakl2->stm
          nalog2->stm  := nalog2->sum4
        ENDIF
      ELSE
        DispError("Неможливо добавити строку в податкову накладну")
      ENDIF
      nalog2->(dbUnlock())
      m_sum+=nakl2->stm;m_nds+=nakl2->nds
      nakl2->(Dbskip())
    ENDDO
    IF nalog1->(NetDbAp())
      nalog1->vnum:=STR(m_vnum,6)
      nalog1->ndoc:=STR(fvnum->ndoc,LEN(nalog1->ndoc))
      fvnum->ndoc:=fvnum->ndoc+1
      nalog1->ddoc:=DATE()
      SetPred01()
      Nalog1->vdoc:="1"
      Firm01->(DBSETORDER(2))
      IF Firm01->(DS(nakl1->okpo)).AND..NOT.EMPTY(nakl1->okpo)
        SetFirm01()
      ELSE
        nalog1->shortb:=PADC(LEFT(ALLTRIM(Nakl1->fio1),LEN(nalog1->shortb)),LEN(nalog1->shortb))
      ENDIF
      Firm01->(DBSETORDER(1))
      nalog1->nds:=m_nds
      nalog1->sum:=m_sum
      nalog1->(dbUnlock())
    ELSE
      DispError("Неможливо добавити заголовок в податкову накладну")
    ENDIF
    IF nakl1->(NetRlock())
      nakl1->ndoc2:=nalog1->ndoc
      nakl1->ddoc2:=nalog1->ddoc
      nakl1->(DbUnlock())
    ENDIF
    fvnum->reg:=CLEARBIT(fvnum->reg,m_computer)
    fvnum->(DBCOMMIT())
    fvnum->(DbUnlock())
    nalog(1)
    fvnum->(DBGOTO(1))
  ENDIF
  DBCOMMITALL()
SAVEPAR(1)
ENDIF
RETURN .t.

Function IsLevel(m_var)
  IF m_level<=3
    RETURN .t.
  ENDIF
  IF m_var==NIL
    RETURN .f.
  ENDIF
  IF m_var<>m_oper
    RETURN .f.
  ENDIF
RETURN .t.

FUNCTION  ReadPol()
LOCAL m_numNakl:=BLANK(nakl1->ndoc,.t.),m_ddoc:=CTOD("")
LOCAL n_win1,m_get1:=GetNew(2,17,COLBR(m_NumNakl),"m_numNakl","@K","w/B,GR+/n")
LOCAL m_get2:=GetNew(4,17,COLBR(m_ddoc),"m_ddoc",,"w/B,GR+/n")
LOCAL l_err:=.f.,l_vvod:=.f.,m_key
m_get1:PostBlock:={|p|EVAL(p:block,JustRight(EVAL(p:block))),p:display(),.t.}
// m_get2:PostBlock:={|p|F001()}
SET ESCAPE ON
SavePar()
n_win1:=InitScr("NAKL03")
WSELECT(n_win1)
DO WHILE .t.
  IF l_vvod==.t.
    ReadMy({m_get1})
    IF LASTKEY()==K_ESC
      EXIT
    ENDIF
    Nakl1->(DBSETORDER(2))
    IF .NOT.Nakl1->(DS(m_numNakl))
      BeepErr()
      @3,1 SayDisp "Накладної з таким номером не iснує" COLOR "GR+/r"
      l_err:=.t.
      LOOP
    ENDIF
    Nakl1->(DBSETORDER(1))
    IF IsBit(ASC(nakl1->state),2)
      BeepErr()
      @3,1 SayDisp "Накладна вже вiдмiчена як одержана" COLOR "GR+/r"
      l_err:=.t.
      LOOP
    ENDIF
    IF l_err
      @3,1 SayDisp "                                  " COLOR "n*/n*"
      l_err:=.f.
    ENDIF
    ReadMy({m_get2})
    IF LASTKEY()==K_ESC
      EXIT
    ENDIF
    IF Nakl1->(NetRlock())
      nakl1->state:=CHR(SETBIT(ASC(nakl1->state),2))
      nakl1->ddoc3:=m_ddoc
      IF nakl1->ddoc3<nakl1->ddoc
        Disperror("Увага !!! Дата виписки пiзнiша за; дату одержання ")
      ENDIF
      nakl1->oper1:=m_oper
      Nakl1->(DbUnLock())
    ELSE
      DispError("НАКЛАДНА НЕ БЛОКУЄТЬСЯ")
    ENDIF
  ELSE
    @m_get1:row,m_get1:col SayDisp nakl1->ndoc COLOR "w/b"
    @m_get2:row,m_get2:col SayDisp nakl1->ddoc3 COLOR "b/w"
    m_key:=INKEY(0)
    DO CASE
      CASE m_key==K_ESC
        EXIT
      CASE m_key==K_ENTER
        IF IsLevel(nakl1->oper)
            m_ddoc:=nakl1->ddoc3
            SET ESCAPE ON
            ReadMy({m_get2})
            IF LASTKEY()<>K_ESC
              IF Nakl1->(NetRlock())
                IF .NOT.EMPTY(m_ddoc)
                  nakl1->state:=CHR(SETBIT(ASC(nakl1->state),2))
                ELSE
                  nakl1->state:=CHR(NUMAND(ASC(nakl1->state),NUMNOT(SetBit(0,2))))
                ENDIF
                nakl1->ddoc3:=m_ddoc
                IF nakl1->ddoc3<nakl1->ddoc
                  Disperror("Увага !!! Дата виписки пiзнiша за; дату одержання ")
                ENDIF
                nakl1->oper1:=m_oper
                Nakl1->(DbUnLock())
              ELSE
                  DispError("НАКЛАДНА НЕ БЛОКУЄТЬСЯ")
              ENDIF
            ENDIF
          ELSE
            DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
          ENDIF
      CASE m_key==K_INS.AND.m_level<=3
         m_numNakl:=BLANK(nakl1->ndoc,.t.);m_ddoc:=CTOD("")
         l_vvod:=.t.
    ENDCASE
  ENDIF
ENDDO
WCLOSE(n_win1)
SavePar(1)
RETURN .t.

STATIC FUNCTION Nakl3(m_mode,var2)
  LOCAL m_browse1,n_win1,m_key,lApnd:=.f.,n_win:=WSELECT()
  LOCAL a_get1:={},a_data1:={},n_pole1,m_block,a_say1:={}
  LOCAL m_nds,m_sum,m_recno,i,l_delete:=.f.,m_buf,m_valid1,m_glv
  LOCAL m_kvo:=0,l_print:={},GetList:={},n:=0
  SavePar()
  n_win1:=INitScr(var2)
  select nakl3
  m_browse1               := TBrowseDB(2,1,MAXROW()-2,MAXCOL()-1)
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w'
  m_browse1:colsep        := '│'
  m_browse1:SkipBlock     := {|n| SkipDb1(n,{||(nakl1->vnum==nakl3->vnum)},lApnd) }
  m_browse1:goBottomBlock := {||nakl3->(DBSEEK(nakl1->vnum,.f.)),nakl3->(DBEVAL(,,{||(nakl1->vnum==nakl3->vnum)})),nakl3->(dbskip(-1))}
  m_browse1:goTopBlock    := {||nakl3->(DBSEEK(nakl1->vnum,.f.))}
  @1,2 SayDisp "Цiна="      COLOR "GR+/B"
  IF m_mode
    @1,8 Get Nakl2->prise COLOR "GR+/N"
    READ
  ELSE
    @1,8 SayDisp Nakl2->prise COLOR "GR+/B"
  ENDIF
  CrBrCol(var2,@m_browse1,"NAKL3")
  FOR i:=1 TO m_browse1:ColCount
    m_browse1:GetColumn(i):ColorBlock:={||IF(nakl3->stm==ROUND(nakl2->prise*nakl3->kvo*(1+getVat()),2),{1,2},{7,8})}
  NEXT

  i:=1;AEVAL(a_get1,{|x|a_get1[i]:block:=m_browse1:GetColumn(i):Block,;
  m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──"),i++})
  m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
  lApnd:=.f.;EVAL(m_browse1:GotopBlock)
  ASIZE(l_print,m_browse1:ColCount);AFILL(l_print,.t.)
  a_get1:=CrGet(var2,a_say1)
  i:=1;AEVAL(a_get1,{|x|a_get1[i]:block:=m_browse1:GetColumn(i):Block,;
  m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──"),i++})
  IF var2=="NAKL3"
    a_get1[1]:block:=COLBR(nakl3->tabn)
    m_browse1:cargo:="Перелiк робiтникiв до накладної N "+ALLTRIM(nakl1->ndoc)
  ELSE
    a_get1[1]:block:=COLBR(nakl3->codn)
    m_browse1:cargo:="Перелiк фiз. осiб до накладної N "+ALLTRIM(nakl1->ndoc)
  ENDIF

  a_get1[3]:block:=COLBR(nakl3->kvo)
  a_get1[4]:block:=COLBR(nakl3->glv)
  a_get1[5]:Block:=COLBR(nakl3->stm)
  a_get1[3]:PostBlock:={||TaxStm3(lApnd)}
  IF m_mode
    lApnd:=.t.
  ELSE
    IF .NOT.nakl3->vnum==nakl1->vnum //m_browse1:hitBottom
      IF ANSWER("Даннi вiдсутнi !;Будемо вводити ?")<>YES
        SavePar(1)
        RETURN .f.
      ELSE
        lApnd:=.t.
      ENDIF
    ENDIF
  ENDIF
  SET CURSOR OFF
  DO WHILE .t.
    //Display Browse m_browse1
    STABILIZE BROWSE m_browse1
    Winsay
     m_key:=IF(.NOT.lApnd,INKEY(0),K_INS)
      DO CASE
        CASE m_key==K_ALT_S
          n:=m_sum:=m_glv:=m_kvo:=0
          m_recno:=nakl3->(RECNO())
          EVAL(m_browse1:GotopBlock)
          DO WHILE .NOT.nakl3->(EOF()).AND.nakl3->vnum==nakl1->vnum
            m_kvo+=nakl3->kvo;m_glv+=nakl3->glv;m_sum+=nakl3->stm
            n++
            nakl3->(DBSKIP())
          ENDDO
          @MAXROW()-1,28 SayDisp n COLOR "w+/b" PICTURE "999"
          @MAXROW()-1,34 SayDisp SumToStr(m_kvo,14) COLOR "w+/b"
          @MAXROW()-1,49 SayDisp SumToStr(m_glv,14) COLOR "w+/b"
          @MAXROW()-1,64 SayDisp SumtoStr(m_sum,14) COLOR "w+/b"
          nakl3->(DBGOTO(m_recno))
        CASE m_key==K_ESC.OR.m_key==K_F12
          n:=m_sum:=m_glv:=m_kvo:=0
          m_recno:=nakl3->(RECNO())
          EVAL(m_browse1:GotopBlock)
          DO WHILE .NOT.nakl3->(EOF()).AND.nakl3->vnum==nakl1->vnum
            m_kvo+=nakl3->kvo;m_glv+=nakl3->glv;m_sum+=nakl3->stm
            n++
            nakl3->(DBSKIP())
          ENDDO
          @MAXROW()-1,28 SayDisp n COLOR "w+/b" PICTURE "999"
          @MAXROW()-1,34 SayDisp SumToStr(m_kvo,14) COLOR "w+/b"
          @MAXROW()-1,49 SayDisp SumToStr(m_glv,14) COLOR "w+/b"
          @MAXROW()-1,64 SayDisp SumtoStr(m_sum,14) COLOR "w+/b"
//          IF ANSWERu("Заносити загальну кiлькiсть i суму в накладну")==YES
              IF nakl2->(NetRLOCK())
                nakl2->kvo:=m_kvo;nakl2->glv:=m_glv
                IF GetVat()==0
                  nakl2->stm:=m_sum
                ELSE
                  nakl2->nds:=m_sum*GetNds()/(1+GetVat())
                  nakl2->stm:=m_sum-nakl2->nds
                  nakl2->prise:=IF(nakl2->kvo==0,0,nakl2->stm/nakl2->kvo)
                ENDIF
                nakl2->(dbUnlock())
              ENDIF
//          ENDIF
          nakl3->(DBGOTO(m_recno))
          EXIT
      DEAL BROWSE m_browse1 KEY m_key
      PRINT BROWSE m_browse1 KEY m_key
      CASE m_key==K_ENTER   // .OR.Lapnd
        IF IsLevel(nakl1->oper)
            IF Nakl3->(NetRLOCK())
              m_browse1:refreshCurrent()
              STABILIZE BROWSE m_browse1
              a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
              ReadMy({a_get1[m_browse1:ColPos]},;
              IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
              Nakl3->(dbUNLOCK())
              m_browse1:refreshCurrent()
            ELSE
              DispError("Невозможно заблокировать запись")
            ENDIF
          ELSE
          DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
          ENDIF
      CASE m_Key == K_DEL                                    /* удаление записи */
        IF IsLevel(nakl1->oper)
          DelStroka(@m_browse1)
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
            IF nakl3->(NetDbAp())
              nakl3->vnum:=nakl1->vnum
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
            m_browse1:refreshCurrent();STABILIZE BROWSE m_browse1
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
WCLOSE(n_win1)
SavePar(1)
Wselect(n_win)
Return .f.
STATIC Function SetFilter(m_browse,l_filter)
LOCAL m_recno1:=Nakl1->(RECNO()),m_recno2:=Nakl2->(RECNO()),a_dop:={},GetList:={},m_screen
LOCAL m_poisk:=.t.,m_gauge,i:=1,l_found:=.f.,m_file,k:=1,n_rec:=0,n
STATIC m_tabn,m_okpo,m_ksash,m_kod,m_stm1,m_stm2,m_ddoc1,m_ddoc2,m_kod1,m_mol,m_otp
STATIC l_pol:=" ",l_opl:=" "
// SaveCur()
IF m_ddoc1==NIL
  m_ddoc1:=BLANK(nakl1->ddoc,,.t.)
  m_ddoc2:=BLANK(nakl1->ddoc,.t.)
  m_tabn:=BLANK(nakl1->tabn,.t.)
  m_kod1:=BLANK(nakl1->kod1,.t.)
  m_ksash:=BLANK(nakl1->ksash,.t.)
  m_okpo:=BLANK(nakl1->okpo,.t.)
  m_kod :=BLANK(nakl2->kod ,.t.)
  m_mol :=BLANK(nakl1->mol ,.t.)
  m_otp :=BLANK(nakl1->otp ,.t.)
  m_stm1:=BLANK(nakl1->sum,.t.)
  m_stm2:=BLANK(nakl1->sum,.t.)
ENDIF
#DEFINE ROW1 INT((MAXROW()- 10)/2)
#DEFINE COL1 INT((MAXCOL()- 60)/2)
//Сложный поиск
m_screen:=SAVESCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64)
@ROW1,COL1,ROW1+ 11,COL1+ 62 BOX (B_SINGLE+' ') COLOR ("w/b")
SHADOW(ROW1,COL1,ROW1+ 11,COL1+ 62)
@ROW1,COL1+INT( 37/2) SayText "~3Вибiрка накладних" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+1+ 10,COL1+INT( 60/2) SayText "~4" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  1,COL1+1 SayText "~2Вибрати накладнi по " COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  2,COL1+1 SayText "~2з           по" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  2,COL1+28 SayText "~2Код оплати" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  3,COL1+1 SayText "~2Таб. номер" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  4,COL1+1 SayText "~2ОКПО" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  5,COL1+1 SayText "~2ШВЗ" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  6,COL1+1 SayText "~2Код мат-лу" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  7,COL1+1 SayText "~2Вартiсть  з             до   " COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  8,COL1+1 SayText "~2Оплата      Одержання        " COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
// SET CURSOR ON
SET ESCAPE ON
@ROW1+  1,COL1+  21 Get m_otp VALID sp02->(sp_vl("SP02","2",ROW1+  1,COL1+ 24,"_mol()","Gr+/b",15))  COLOR ("n/w,gr+/n")
@ROW1+  1,COL1+  40 Get m_mol VALID sp02->(sp_vl("SP02","2",ROW1+  1,COL1+ 43,"_mol()","Gr+/b",15))  COLOR ("n/w,gr+/n")
@ROW1+  2,COL1+  3 Get m_ddoc1 COLOR ("n/w,gr+/n")
@ROW1+  2,COL1+ 17 Get m_ddoc2 COLOR ("n/w,gr+/n")
@ROW1+  2,COL1+37  Get m_kod1 COLOR ("n/w,gr+/n") PICTURE "!!" VALID (EMPTY(m_kod1).OR.KodOpl())
@ROW1+  3,COL1+ 12 Get m_tabn VALID sp10->(sp_vl("SP10A","2",ROW1+  3,COL1+ 22,"_fio()","Gr+/b")) COLOR ("n/w,gr+/n")
@ROW1+  4,COL1+ 12 Get m_okpo COLOR ("n/w,gr+/n")
@ROW1+  5,COL1+ 12 Get m_ksash VALID sp44->(sp_vl("SP44","2",ROW1+  5,COL1+ 22,"sp44->naim7","Gr+/b"))  COLOR ("n/w,gr+/n")
@ROW1+  6,COL1+ 12 Get m_kod  VALID kaptka1->(sp_vl("KAPTKA1","2",ROW1+  6,COL1+ 22,"kaptka1->name","Gr+/b"))   COLOR ("n/w,gr+/n")
@ROW1+  7,COL1+ 12 Get m_stm1 COLOR ("n/w,gr+/n") PICTURE "9'999'999.99"
@ROW1+  7,COL1+ 27 Get m_stm2 COLOR ("n/w,gr+/n") PICTURE "9'999'999.99"
@ROW1+  8,COL1+ 09 Get l_opl COLOR ("n/w,gr+/n") VALID (l_opl==" ".OR.l_opl=="1".OR.l_opl=="0")
@ROW1+  8,COL1+ 24 Get l_pol COLOR ("n/w,gr+/n") VALID (l_pol==" ".OR.l_pol=="1".OR.l_pol=="0")
GetList[5]:PostBlock:={|x|SetPos(ROW1+2,COL1+42),DispOut(SayOpl(m_kod1),"gr+/b"),IF(EMPTY(m_kod1),.t.,KodOpl())}
GetList[7]:PostBlock:={|x|firm01->(firm01a(x))}
READMY(GetList)
IF LASTKEY()==K_ESC
  RESTSCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64,m_screen)
  RETURN .f.
ENDIF
IF SELECT("Rec")==0
  m_file:=TEMPFILE(m_temppath,"dbf");FERASE(m_file)
  DBCREATE(m_file,{{"num","C",4,0}})
  USE (m_file) NEW ALIAS REC
  n_rec:=SELECT()
  select nakl1
  n:=Nakl1->(LASTREC())
ELSE
  Select Rec
  n:=Rec->(LASTREC())
ENDIF
m_gauge:=InitGauge("Вибiрка накладних")
EVAL(m_browse:goTopBlock)
DO WHILE k<>0
  m_gauge:=DispGauge(m_gauge,i++/n)
  IF .NOT.EMPTY(m_ddoc1)
    IF nakl1->ddoc<m_ddoc1
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_ddoc2)
    IF nakl1->ddoc>m_ddoc2
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_kod1)
    IF nakl1->kod1<>m_kod1
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_otp)
    IF nakl1->otp<>m_otp
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_mol)
    IF nakl1->mol<>m_mol
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_tabn)
    IF NumPotr(nakl1->kopr)=="5"
      IF nakl3->(DS(nakl1->vnum))
        DO WHILE nakl1->vnum==nakl3->vnum.AND..not.nakl3->(EOF()).and.nakl3->tabn<>m_tabn
          nakl3->(DBSKIP())
        ENDDO
      ENDIF
      IF nakl1->vnum<>nakl3->vnum.OR.nakl3->(EOF())
        k:=EVAL(m_browse:SkipBlock,1);LOOP
      ENDIF
    ELSE
      IF nakl1->tabn<>m_tabn
        k:=EVAL(m_browse:SkipBlock,1);LOOP
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_okpo)
    IF nakl1->okpo<>m_okpo
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_ksash)
    IF nakl1->ksash<>m_ksash
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_stm1)
    IF nakl1->sum<m_stm1
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_stm2)
    IF nakl1->sum>m_stm2
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  IF .NOT.EMPTY(l_opl)
    IF l_opl=="1"
      IF .NOT.ISBIT(ASC(nakl1->state),1)
        k:=EVAL(m_browse:SkipBlock,1);LOOP
      ENDIF
    ELSE
      IF ISBIT(ASC(nakl1->state),1)
        k:=EVAL(m_browse:SkipBlock,1);LOOP
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.EMPTY(l_pol)
    IF l_pol=="1"
      IF .NOT.ISBIT(ASC(nakl1->state),2)
        k:=EVAL(m_browse:SkipBlock,1);LOOP
      ENDIF
    ELSE
      IF ISBIT(ASC(nakl1->state),2)
        k:=EVAL(m_browse:SkipBlock,1);LOOP
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.EMPTY(m_kod)
    IF nakl2->(DS(nakl1->vnum))
      DO WHILE nakl1->vnum==nakl2->vnum.AND..not.nakl2->(EOF()).and.nakl2->kod<>m_kod
        nakl2->(DBSKIP())
      ENDDO
    ENDIF
    IF nakl1->vnum<>nakl2->vnum.OR.nakl2->(EOF())
      k:=EVAL(m_browse:SkipBlock,1);LOOP
    ENDIF
  ENDIF
  // Запись найдена
  Rec->(DBAP())
  l_found:=.t.
  Rec->num:=L2BIN(nakl1->(RECNO()))
  nakl1->(DBSKIP())
ENDDO
m_file:=TEMPFILE(m_temppath,"ntx");FERASE(m_file)
Rec->(DBCREATEINDEX(m_file,"DTOS(nakl1->ddoc)+nakl1->ndoc",{||Nakl1->(DBGOTO(BIN2L(rec->num))),DTOS(nakl1->ddoc)+Nakl1->ndoc}))
DelGauge(m_gauge)
RESTSCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64,m_screen)
// RestCur()
  IF .Not.L_found
    DispErr("Накладнi не знайденi")
    nakl1->(DBGOTO(m_recno1));nakl2->(DBGOTO(m_recno2))
    RETURN .f.
  ELSE
    m_browse:SkipBlock     := { |n,l| l:=Rec->(SkipDb(n)),Nakl1->(DBGOTO(BIN2L(rec->num))),l }
    m_browse:goBottomBlock := { ||  Rec->(DBGOBOTTOM()),Nakl1->(DBGOTO(BIN2L(rec->num))) }
    m_browse:goTopBlock    := { ||  Rec->(DBGOTOP()),Nakl1->(DBGOTO(BIN2L(rec->num)))  }
    EVAL(m_browse:GoTopBlock);m_browse:rowPos:=1;m_browse:configure()
  ENDIF
RETURN .t.
// calculate VAT
Function TaxStm(x)
IF (lApnd.OR.ANSWERu("Перераховувати суму i ПДВ накладної")==YES).AND.;
  (NumPotr(x)<>"5".AND.NumPotr(x)<>"9") // не список к накладной
  field->stm:=field->prise*field->kvo
  field->nds:=GetVat()*field->stm
ENDIF
RETURN .t.
Function TaxStm3(m_mode)
IF m_mode.OR.ANSWERu("Перераховувати суму i ПДВ списка")==YES
  nakl3->stm:=nakl2->prise*nakl3->kvo* (1 + GetVat())
//  nakl3->nds:=GetNds()*nakl3->stm
ENDIF
RETURN .t.
Function DspOpl1()
LOCAL n_win
LOCAL a_get:={},i:=1,n_pole:=1,m_key
IF nakl2->(NetRlock())
  ASIZE(a_get,03);AEVAL(a_get,{|x|a_get[i]:=GetNew(),a_get[i]:ColorSpec:="w/B,GR+/n",i++})
  a_get[1]:Block:=COLBR(nakl2->prise1);a_get[1]:Row:=1;a_get[1]:Col:=22;a_get[1]:picture:="@K 999'999'999.99"
  a_get[2]:Block:=COLBR(nakl2->stm1);a_get[2]:Row:=2;a_get[2]:Col:=22;a_get[2]:picture:="@K 999'999'999.99"
  a_get[3]:Block:=COLBR(nakl2->st);a_get[3]:Row:=3;a_get[3]:Col:=22;a_get[3]:picture:="9"
  SavePar()
  n_win:=InitScr("NAKL04")
  AEVAL(a_get,{|x|x:display()})
    DO WHILE .t.
      a_get[n_pole]:ColorDisp("b/w")
      m_key:=INKEY(0)
      a_get[n_pole]:ColorDisp("w/B,GR+/n")
      DO CASE
        CASE m_key==K_ENTER
          IF IsLevel(nakl1->oper)
            ReadMy({a_get[n_pole]})
          ELSE
              DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
          ENDIF
        CASE m_key==K_PGDN
          n_pole:=LEN(a_get)
        CASE m_key==K_PGUP
          n_pole:=1
        CASE m_key==K_DOWN
          n_pole:=IF(n_pole==LEN(a_get),1,n_pole+1)
        CASE m_key==K_UP
          n_pole:=IF(n_pole==1,LEN(a_get),n_pole-1)
        CASE m_key==K_ESC.OR.m_key==K_F12.OR.m_key==K_CTRL_END
          EXIT
      ENDCASE
    ENDDO
  WCLOSE(n_win)
  SavePar(1)
  nakl2->(DbUnlock())
ENDIF
RETURN .t.
STATIC FUNCTION SetStm(x)
//LOCAL i:=GetNds()
LOCAL i:=GetVat()

x:=ROUND(x,2)
IF i==0
  nakl2->stm:=x;nakl2->nds:=0;nakl2->prise:=IF(nakl2->kvo==0,0,nakl2->stm/nakl2->kvo)
ELSE
  nakl2->stm:=ROUND(x/(1+i),2)
  nakl2->nds:=ROUND(i*nakl2->stm,2)
  nakl2->stm:=x-nakl2->nds
  nakl2->prise:=IF(nakl2->kvo==0,0,nakl2->stm/nakl2->kvo)
endif
RETURN x
STATIC FUNCTION getVat()
IF field->KNDS == ' ' 
	RETURN GetNds()
ENDIF
RETURN  GetNds1()


/* STATIC FUNCTION SetStm2(x)
LOCAL i:=GetNds()
x:=ROUND(x,2)
IF i==0
  nakl3->stm:=x
ELSE
//  nakl3->stm:=x/(1+i);nakl3->nds:=i*nakl3->stm
  nakl3->stm:=ROUND(x/(1+i),2);nakl3->nds:=ROUND(i*nakl3->stm,2)
  nakl3->stm:=x-nakl3->nds
endif
RETURN x  */
Function Nakla(l_mode)
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,n_win1,m_col,m_ddoc,m_file
  LOCAL m_exit:=READEXIT(.T.),l_stop:=.t.,l_filter:=.f.,k_ctrl_u
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={}
  LOCAL a_get1:={},a_data1:={},n_pole1,a_say1:={},a_brgd:={}
  LOCAL m_browse1,m_vnum,m_ndoc,m_valid,a_dop:={},a_spr01:={},m
  LOCAL m_browse2,m_get1b,m_state:="0",m_col1b,a_fam:={},m_sum,m_nds,m_date
  LOCAL blnk_nkl:={||nakl1->tabn:=blank(nakl1->tabn,.t.),;
  nakl1->ksash:=blank(nakl1->ksash,.t.),nakl1->okpo:=blank(nakl1->okpo,.t.),;
  nakl1->mol:=BLANK(nakl1->mol,.t.),nakl1->brgd:=BLANK(nakl1->brgd,.t.)}
  LOCAL k_f4,k_Ctrlf5,k_altf5
//  LOCAL a_get2:={}
  DCL MENU
  DCL LIST
  LOCAL m_select:=SELECT(),a_pred01:={}
  IF .NOT.RECURS()
  SavePar()
  IF EMPTY(l_mode)
    NET USE (m_platpath+"FVNUM") NEW
    IF .NOT.f_vnum(1)
      CLOSE fvnum
      RETURN .f.
    ENDIF
    NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b") ALIAS kaptka1 NEW
    SopenFiles("100",@s_files)
    OpenFl1()
  ENDIF
  WSELECT(0)
  SET CURSOR OFF
  k_f4:=SETKEY(K_F4,{||EdFirm01("FIRM01")})
  k_ctrl_u:=SETKEY(K_CTRL_U,{||LSetprint()})
  a_pred01:={pred01->tabnr,pred01->tabnb}
  InitNds()
  Lapnd:=.f.
  setblink(.f.)
  SELECT NAkl1
  SET FILTER TO
  SET FILTER TO nakl1->vdoc=="0" // Прихiд
  INIT GET "NAKL1A" TO a_get KEY n_pole DATA a_data SAY a_say
  a_get[1]:picture:="@K"
  a_get[3]:PostBlock:={||Spr01->(spr01(@a_spr01))}
  a_get[4]:PrebLock:={||.NOT.IsUslug(a_data[3])}
  a_get[5]:PrebLock:={||IsUslug(a_data[3])}
  a_get[6]:PostBlock:={||KodOpl()}
  a_get[8]:PostBlock:={||sp10a(@a_data,@a_get,@n_pole)}
  a_say[8]:={4,20,"","GR+/B",{||_fio(a_data[8])}}
  a_get[9]:PreBlock:={||(NumPotr(a_data[3])=="1")}
  a_get[9]:PostBlock:={||Firm01aa(@a_data,@a_get,@n_pole)}
  a_get[10]:PreBlock:={||(NumPotr(a_data[3])=="2".OR.NumPotr(a_data[3])=="0")}
  a_get[10]:PostBlock:={||sp44a(@a_data,@a_get,@n_pole)}
  a_get[11]:PreBlock:={||(NumPotr(a_data[3])=="2")}
  a_get[11]:PostBlock:={||sp01a(@a_data,@a_get,@n_pole)}
  a_get[12]:PreBlock:={||(NumPotr(a_data[3])=="8")}
  a_get[12]:PostBlock:={||sp17a(@a_data,@a_get,@n_pole)}
  a_say[12]:={6,30,"","GR+/B",{||Sp17->(DBSEEK(a_data[12])),LEFT(PADR(ALLTRIM(sp17->fam)+' '+ALLTRIM(sp17->imja)+' '+ALLTRIM(sp17->otch),45),45)}}
  a_get[13]:PreBlock:={||.f.}
  a_say[6]:={2,51,"","GR+/B",{||SayOpl(a_data[6])}}
  SELECT spr01
  SET FILTER TO spr01->kopr<"100"
  SELECT nakl2
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  CrList1("NAKL1",@m_browse,@l_print)
  n_win1:=InitScr("NAKL1A")
  a_get1:=CrGet("NAKL2",a_say1)
  a_say1[1]={{ASC("?"),{||kaptka_vl(a_get1[1],a_data[3],@a_dop)}},;
  {K_F2,{||PrNakl(a_data)}},;
  {K_CTRL_F12,{||kaptka_vl(a_get1[1],a_data[3],@a_dop,K_CTRL_F12)}}}
  a_get1[1]:PostBlock:={|x|kpt_vl(x,@a_dop)}
  a_get1[4]:PostBlock:=a_get1[7]:PostBlock:={||TaxStm(a_data[3])}
  a_get1[9]:PreBlock:={||.t.}
  a_get1[10]:PreBlock:={||.t.}
  a_get1[7]:PreBlock:={||.t.}
  m_browse1               := TBrowseDB(9,1,MAXROW()-3,MAXCOL()-1)
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_browse1:colsep        := '│'
  m_browse1:SkipBlock     := {|n| SkipDb1(n,{||(nakl1->vnum==nakl2->vnum)},lApnd) }
  m_browse1:goBottomBlock := {||nakl2->(DBSEEK(nakl1->vnum,.f.)),nakl2->(DBEVAL(,,{||(nakl1->vnum==nakl2->vnum)})),nakl2->(dbskip(-1))}
  m_browse1:goTopBlock    := {||nakl2->(DBSEEK(nakl1->vnum,.f.))}
  CrBrCol("NAKL2",@m_browse1)
  i:=1;AEVAL(a_get1,{|x|a_get1[i]:block:=m_browse1:GetColumn(i):Block,;
  m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──"),i++})
  a_get1[10]:Block:={|x|IF(x==NIL,nakl2->stm+nakl2->nds,SetStm(x))}
  Select nakl1 ; Wselect(n_win)
  m_browse:GetColumn(3):block:={||Status1()}
  ADD menu up_down
  add menu Left_Right
  add menu search
  a_ver_menu[3][1][3]:="Пошук по номеру накладної <Shift>+F6"
  AADD(a_ver_menu[3][1],"Складний пошук      <alt>+F7")
  AADD(a_ver_menu[3][2],K_ALT_F7)
  ADD MENU NAME "~Виправлення" ;
  ITEMS {"Добавити   Ins" ,"Виправити  Enter" ,;
  "Удалити    Delete ","Вiдмiтка про сплату <Alt>+<?>",;
  "Розрахунок суми накладних <Alt>+<S>","Вибiрка накладних"} ;
  KEY {K_INS,K_ENTER,K_DEL,309,K_ALT_S,K_ALT_F}
  add menu print
   SELECT nakl1
  m_browse:goBottom()
//                      1   2    3    4      5    6   7   8   9  10   11   12   13  14   15     16   17   18  19   20     21
  m_browse:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b,w/r,r/w,w/n,n/w,w/b*,b+/w,w/n*,n+/w,w/rb,rb/w,w+/r,w+/n,w+/b*,w+/n*,w+/rb'
  FOR i:=1 TO m_browse:colCount
    m_browse:GetColumn(i):colorBlock:={||clr1(nakl1->state)}
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
      m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},clr2(nakl1->state))
      m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},MyFunc1(EVAL(m_browse:GetColumn(1):colorBlock)))
    ENDIF
    IF m_key==0
      m_key:=INKEY(0)
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
      IF ANSWER("Друкувати перелiк накладних за день?")==YES
        PrintLs()
      ENDIF

      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      CASE m_key==K_SH_F6
        ShiftF6(m_browse,SELECT("NAKL1"))
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==309.AND.IsLevel(nakl1->oper) // ALT+?
         DispOpl()
        CASE m_key==K_ALT_F
          IF ANSWERu("Робити вибiрку ;накладних?")==YES.AND.SetFilter(@m_browse)
            l_filter:=.t.
            rec->(DBSETORDER(1))
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
          ENDIF
      CASE m_key==K_ALT_F7
        If KaltF7()
          m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
        ENDIF
      CASE m_key==K_ALT_S
         IF ANSWER("Расчитывать сумму?")==YES
          m_recno:=Nakl1->(REcno())
          DO WHILE .NOT.nakl1->(EOF())
            nakl2->(DS(nakl1->vnum))
            k:=nakl1->vnum
            If Nakl1->(NetRLock())
              nakl1->sum:=0
              DO WHILE .NOT.nakl2->(EOF()).AND.nakl1->vnum==nakl2->vnum
                nakl1->sum+=nakl2->stm+nakl2->nds
                nakl2->(DBSKIP())
              ENDDO
              nakl1->(dbUnlock())
            ENDIF
            nakl1->(DBSKIP())
          ENDDO
          Nakl1->(Dbgoto(m_recno))
          m_browse:RefreshAll()
          ENDIF

    CASE m_Key == K_DEL                                    /* удаление записи */
      DelDoc(m_browse,l_delete,SELECT("NAKL1"),SELECT("NAKL2"),SELECT("NAKL3"))
    CASE m_key==K_ENTER
      STABILIZE BROWSE m_browse
      WSELECT(n_win1)
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      SELECT nakl1;n_pole:=1
      DBGOTO(RECNO())
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1;m_state:="0"
//      Sp01->(DS(a_data[10]))
 //     @5,44 SayDisp sp01->naim1 COLOR "gr+/b"
      set escape on
      SELECT NAKL2
      m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
      WSELECT(n_win1)
      CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
      DISPBOX(m_browse1:nTop-1,m_browse1:nLeft-1,m_browse1:nBottom,m_browse1:nRight+1,"▌─▐▐▐─▌▌ ",m_browse1:colorSpec)
      lApnd:=.f.;EVAL(m_browse1:GotopBlock)
      IF nakl2->vnum==nakl1->vnum //m_browse1:hitBottom
        SumSumNds(@m_sum,@m_nds,m_browse1)
        Stabilize Browse m_browse1
        m_browse1:autolite:=.f.
        m_browse1:DeHilite()
      ENDIF
      a_fam:={}
      SET ESCAPE ON
      DO WHILE .t.
       DO CASE
        CASE m_state=="0"
          select nakl1
          WSELECT(n_win1)
          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
              CASE m_key == K_UP;IF n_pole ==1;ELSE;n_pole:=n_pole-1;END
              CASE m_key == K_DOWN;IF n_pole ==LEN(a_get);ELSE;n_pole:=n_pole+1;END
              CASE m_key == K_CTRL_F5;nalog("0")
              CASE m_key == K_CTRL_U;LSetprint()
              CASE m_key == K_ESC;BeepErr();IF ALERT("Все изменения будут анулированы;Выходить ?",{"Да","Нет"})==1;EXIT;END
              CASE m_key == K_F12.OR. m_key == K_CTRL_END
                IF NetRLOCK();n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  IF(.NOT.EMPTY(nakl1->ddoc3),nakl1->state:=CHR(SETBIT(ASC(nakl1->state),2)),;
                  nakl1->state:=CHR(CLEARBIT(ASC(nakl1->state),2)))
                  UNLOCK;EXIT
                ELSE;DispError("Невозможно заблокировать запись");END
              CASE m_key == K_ENTER ;WinSay
                IF IsLevel(nakl1->oper)
                    ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
                    DispSay(@n_pole,@a_say,@a_data)
                      IF n_pole==3
                        IF LEN(a_spr01)>0
                            a_data[6]:=a_spr01[4]
                            i:=n_pole;n_pole:=6;a_get[n_pole]:Display()
                            DispSay(@n_pole,@a_say,@a_data)
                            n_pole:=i
                        ENDIF
                      END
                ELSE
                  DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                ENDIF
              CASE m_key = K_TAB
                      m_state:="4"
              CASE m_key = K_F2
                 PrNakl(a_data)
                ENDCASE
                CASE m_state=="4"
                  CountNds(a_data[3])
                  select nakl2
                  m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
                  lApnd:=.f.;EVAL(m_browse1:GotopBlock)
                  IF .NOT.nakl2->vnum==nakl1->vnum //m_browse1:hitBottom
                    IF ANSWER("Данных по материалам нет !;Будем вводить ?")<>YES
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
                          SumSumNds(@m_sum,@m_nds,m_browse1)
                        CASE m_key==309.AND.IsLevel(nakl1->oper) // ALT+?
                            DspOpl1()
                        CASE m_key==K_ESC
                            SumSumNds(@m_sum,@m_nds,m_browse1)
                            m_state:="0";EXIT
                        CASE m_key = K_TAB
                            SumSumNds(@m_sum,@m_nds,m_browse1)
                            m_state:="0";EXIT
                      DEAL BROWSE m_browse1 KEY m_key
                      CASE m_key==K_ENTER   // .OR.Lapnd
                        IF IsLevel(nakl1->oper)
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
                      CASE m_Key == K_DEL                                    /* удаление записи */
                        IF IsLevel(nakl1->oper)
                          DelStroka(@m_browse1)
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
                    ReadStroka(@m_browse1,@a_get1,@a_say1,@a_data,.f.,@a_dop)
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
      STABILIZE BROWSE m_browse
      WSELECT(n_win1)
      l_stop:=.t.
      m_valid:=a_get[1]:postBlock;a_get[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid,x))}
      DO WHILE l_stop
        set escape on
        CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
        select nakl1;n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
        a_data[2]:=DATE()
        a_data[1]:=BLANK(nakl1->ndoc,.t.)
        Display Get a_get KEY n_pole SAY a_say DATA a_data
        n_pole:=1
          DO WHILE .t.
            IF a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A".AND.a_say[n_pole][1][1]==ASC("?")
              KEYBOARD(ASC("?"))
            ENDIF
            ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
            DispSay(@n_pole,@a_say,@a_data)
            DO CASE
              CASE LASTKEY() == K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT
              CASE LASTKEY() == K_UP.AND.n_pole # 1;n_pole--;LOOP
              CASE n_pole == LEN(a_get)
                IF NetDbAp()
                  n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  nakl1->oper:=m_oper
                  EXIT
                ELSE
                  DispError("Невозможно добавить запись")
                ENDIF
              CASE n_pole == 1.AND.EMPTY(a_data[1]);l_stop:=.f.;EXIT
            OTHERWISE
                IF n_pole==3
                  IF LEN(a_spr01)>0
                      a_data[6]:=a_spr01[4];i:=n_pole;n_pole:=6;a_get[n_pole]:Display()
                      DispSay(@n_pole,@a_say,@a_data)
                      n_pole:=i
                  ENDIF
                END
                n_pole++
            ENDCASE
          ENDDO
          IF LASTKEY()==K_ESC.OR..NOT.l_stop
            EXIT
          ENDIF
          nakl1->vdoc:="0"
          IF fvnum->(NetRlock())
            nakl1->vnum:=STR(fvnum->vnum,6)
            fvnum->vnum:=fvnum->vnum+1
            fvnum->(DBCOMMIT())
            fvnum->(DbUnlock())
          ELSE
            DispError("Вiдмовлено в доступi")
            EXIT
          ENDIF
          m_ndoc:=nakl1->ndoc
          IF(.NOT.EMPTY(nakl1->ddoc3),nakl1->state:=CHR(SETBIT(ASC(nakl1->state),2)),;
          nakl1->state:=CHR(CLEARBIT(ASC(nakl1->state),2)))
          dbUnlock()
          select nakl2
          m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
          EVAL(m_browse1:GotopBlock);lApnd:=.t.
          Display Browse m_browse1
          CountNds(a_data[3])
//          DispS01(m_browse:colorspec,m_sum,m_nds)
          ReadStroka(@m_browse1,@a_get1,@a_say1,@a_data,.t.,@a_dop)
        ENDDO
        a_get[1]:postBlock:=m_valid
        Wselect(n_win)
        m_browse:refreshAll()
   FINISH LIST
   WCLOSE(n_win);WCLOSE(n_win1)
   WSELECT(0)
   READEXIT(m_exit)
  SETKEY(K_F4,k_f4)
  SETKEY(K_CTRL_U,k_ctrl_u)
  SELECT spr01
  SET FILTER TO
// CLOSE base nakl1,nakl2,spr01
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
    Close Fvnum
  ENDIF
  SavePar(1)
  ENDIF
RETURN .t.
Function ShiftF6(m_browse,m_alias)
LOCAl m_ndoc:=BLANK((m_alias)->ndoc,.t.),;
m_recno:=(m_alias)->(RECNO()),;
m_screen:=SaveScreen(13,10,15,52),GetList:={}
// ВВести номер документа
SET ESCAPE ON
@13,10,15,52 BOX B_DOUBLE+" " COLOR "w+/BG"
@13,12 SayDisp " Введiть номер документа " COLOR "GR+/BG"
@14,12 Get m_ndoc VALID (m_ndoc:=JustRight(m_ndoc),.t.) COLOR "GR+/N"
READ
RestScreen(13,10,15,52,m_screen)
IF LASTKEY()<>K_ESC
    m_recno:=(m_alias)->(RECNO())
    (m_alias)->(DBSETORDER(2))
    IF (m_alias)->(DS(m_ndoc))
      m_browse:rowPos:=1;m_browse:Configure();m_browse:RefreshAll()
    ELSE
      (m_alias)->(DBGOTO(m_recno))
      DispError("Документ N "+m_ndoc+" не знайден")
    ENDIF
    (m_alias)->(DBSETORDER(1))
ENDIF
RETURN .t.
STATIC Function DispS01(Clr,m_sum,m_nds)
  @MAXROW()-2,22 SayDisp SPACE(20) COLOR TOKEN(clr,",",6)
  @MAXROW()-1,22 SayDisp SPACE(20)  COLOR TOKEN(clr,",",6)
  @MAXROW()-2,1 SayDisp "До оплати "+SumToStr(m_sum+m_nds,14) COLOR TOKEN(clr,",",1)
  @MAXROW()-1,1 SayDisp "ПДВ "+SumToStr(m_nds,14) COLOR TOKEN(clr,",",1)
RETURN .t.
STATIC Function sp10a(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l:=Sp10->(Sp_VL("SP10A",IF(NumPotr(a_data[3])=="0","1","2"),4,20,"_fio()","GR+/B"))
  IF l
    Sp10->(DS(a_data[8]))
    IF NumPotr(a_data[3])=="0"
        a_data[13]:=PADR(SUBSTR(ALLTRIM(sp10->fam)+" "+ALLTRIM(sp10->imja)+" ";
        +ALLTRIM(sp10->otch)+ " ("+sp10->tabn+")",1,LEN(a_data[13])),LEN(a_data[13]))
      a_data[12]:=BLANK(a_data[12],.t.)
//      a_data[9]:=BLANK(a_data[9],.t.)
//      a_data[10]:=BLANK(a_data[10],.t.)
    ENDIF
    FOR n_pole:=9 TO 13
      a_get[n_pole]:Display()
    NEXT
    n_pole:=i
    RETURN .t.
ENDIF
RETURN .f.
STATIC Function firm01aa(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l
  l:=firm01->(firm01_vl())
  Firm01->(DBSETORDER(1))
IF l
    a_data[13]:=PADR(SUBSTR(;
    ALLTRIM(firm01->full1)+ALLTRIM(Firm01->full2)+ " ("+ALLTRIM(firm01->okpo)+")";
    ,1,LEN(a_data[13])),LEN(a_data[13]))
    a_data[10]:=BLANK(a_data[10],.t.)
    a_data[11]:=BLANK(a_data[11],.t.)
    a_data[12]:=BLANK(a_data[12],.t.)
    FOR n_pole:=8 TO 13
      a_get[n_pole]:Display()
    NEXT
    n_pole:=i
    RETURN .t.
ENDIF
RETURN .f.
STATIC Function sp44a(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l:=Sp44->(sp_vl("SP44"))
IF l
    Sp01->(DS(a_data[11]))
    a_data[13]:=PADR(SUBSTR(ALLTRIM(sp44->naim7)+" ("+a_data[10]+") "+ALLTRIM(Sp01->naim1)+" ("+a_data[11]+")",1,;
    LEN(a_data[13])),LEN(a_data[13]))
    a_data[9]:=BLANK(a_data[9],.t.)
    a_data[12]:=BLANK(a_data[12],.t.)
    FOR n_pole:=8 TO 13
      a_get[n_pole]:Display()
    NEXT
  n_pole:=i
RETURN .t.
ENDIF
RETURN .F.
STATIC Function sp01a(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l:=Sp01->(sp_vl("SP01","2"))
  IF l
    Sp44->(DS(a_data[10]))
    a_data[13]:=PADR(SUBSTR(ALLTRIM(sp44->naim7)+" ("+a_data[10]+") "+ALLTRIM(Sp01->naim1)+" ("+a_data[11]+")",1,;
    LEN(a_data[13])),LEN(a_data[13]))
    FOR n_pole:=8 TO 13
      a_get[n_pole]:Display()
    NEXT
  n_pole:=i
      RETURN .t.
  ENDIF
RETURN .f.
STATIC Function Sp17a(a_data,a_get,n_pole)
  LOCAL i:=n_pole
  LOCAL l:=Sp17->(sp_vl("SP17"))
  IF l
    Sp44->(DS(a_data[10]))
    a_data[13]:=PADR(LEFT(ALLTRIM(sp17->fam)+' '+ALLTRIM(sp17->imja)+' '+ALLTRIM(sp17->otch),;
    LEN(a_data[13])),LEN(a_data[13]))
    FOR n_pole:=8 TO 13
      a_get[n_pole]:Display()
    NEXT
  n_pole:=i
      RETURN .t.
  ENDIF
RETURN .f.
Function IsUslug(var)
Spr01->(DS(var))
IF spr01->usl=="1"
  RETURN .t.
ENDIF
RETURN .f.
STATIC FUNCTION Sp10Dop(a_data,a_get,n_pole)
LOCAL i:=n_pole,a_mass:={},a_par:={"fam","imja","otch","tabn"}
IF Sp10->(vl_sp("SP10A",,@a_mass,a_par))
      a_data[16]:=PADR(SUBSTR(ALLTRIM(a_mass[1])+" "+ALLTRIM(a_mass[2])+" ";
      +ALLTRIM(a_mass[3])+ " ("+a_mass[4]+")",1,LEN(a_data[16])),LEN(a_data[16]))
      n_pole:=16;a_get[16]:reset();n_pole:=i
ENDIF
RETURN .t.
Function DelDoc(m_browse,l_delete,m_alias1,m_alias2,m_alias3)
     STABILIZE BROWSE m_browse
     IF l_delete.OR.( ANSWERu( "Ви дiйсно бажаєте знищити документ ?" )==YES )
          IF IsLevel((m_alias1)->oper)
          (m_alias2)->(DBSEEK((m_alias1)->vnum,.t.))
          DO WHILE .NOT.(m_alias2)->(EOF()).AND.(m_alias1)->vnum==(m_alias2)->vnum
            IF (m_alias2)->(NetRlock())
              (m_alias2)->(dbdelete());(m_alias2)->(dbUNLOCK())
            ENDIF
            (m_alias2)->(DBSKIP())
          ENDDO
          IF m_alias3<>NIL
          (m_alias3)->(DBSEEK((m_alias1)->vnum,.t.))
          DO WHILE .NOT.(m_alias3)->(EOF()).AND.(m_alias1)->vnum==(m_alias3)->vnum
            IF (m_alias3)->(NetRlock())
              (m_alias3)->(dbdelete());(m_alias3)->(dbUNLOCK())
            ENDIF
            (m_alias3)->(DBSKIP())
          ENDDO
          ENDIF
          IF (m_alias1)->(NetRLOCK());(m_alias1)->(dbdelete());(m_alias1)->(dbUNLOCK())
          ENDIF
          DBSKIP(-1);DBSKIP(1);m_browse:RefreshAll()
        ELSE
          DispError("Ви не маєте прав дозвiлу;на знищення цього документа")
         ENDIF
     ENDIF
RETURN .t.
STATIC Function SumSumNds(m_sum,m_nds,m_browse1)
LOCAL m_recno
        m_sum:=m_nds:=0
//        DispS01(m_browse:colorspec,m_sum,m_nds)
        m_recno:=Nakl2->(RECNO())
        EVAL(m_browse1:GotopBlock)
        DO WHILE .NOT.Nakl2->(EOF()).AND.nakl2->vnum==nakl1->vnum
          m_sum+=nakl2->stm;m_nds+=nakl2->nds
          Nakl2->(DBSKIP())
        ENDDO
        Nakl2->(DBGOTO(m_recno))
        DispS01(m_browse1:colorspec,m_sum,m_nds)
        IF nakl1->(NetRLOCK())
          nakl1->sum:=m_sum+m_nds;nakl1->(dbUnlock())
        ENDIF
RETURN .t.
Function F_vnum(n)
  fvnum->(DBGOTO(n))
  IF fvnum->(NetRlock())
    fvnum->reg:=SETBIT(fvnum->reg,m_computer)
    fvnum->(DBUNLOCK())
    fvnum->(DBCOMMIT())
    RETURN .t.
  ENDIF
    DispError("Вiдмовлено в доступi")
RETURN .f.
Function DispSay(n_pole,a_say,a_data,i)
  LOCAL j:=IF(i==NIL,n_pole,i),k:=n_pole
  n_pole:=j
  IF a_say[n_pole] # NIL .AND. VALTYPE(a_say[n_pole][1])<>"A"
    SETPOS(a_say[n_pole][1],a_say[n_pole][2])
    DISPOUT(TRANSFORM(EVAL(a_say[n_pole][5],a_data,n_pole),a_say[n_pole][3]),a_say[n_pole][4])
  ENDIF
  n_pole:=k
RETURN .t.
Function Delstroka(m_browse1)
IF  ANSWERu( "Ви дiйсно бажаєте видалити строку?" )==YES
  IF NetRLOCK();dbdelete();dbUNLOCK()
  ELSE
    RETURN .f.
  ENDIF
  IF EVAL(m_browse1:SkipBlock,1)==0
    IF EVAL(m_browse1:SkipBlock,-1)==0
      BeepErr();WaitMessage("Видалена остання строка")
      RETURN .f.
    ELSE
      IF  M_browse1:RowPos<>1
        m_browse1:RowPos:=m_browse1:RowPos-1
      ENDIF
    ENDIF
  ENDIF
  m_browse1:RefreshAll()
ENDIF
Return .t.
FUNCTION ReadStroka(m_browse1,a_get1,a_say1,a_data,l_vvod,a_dop)
  LOCAL  m_buf,m_block,m_valid1,i
  LOCAL   m_sum,m_nds
  m_sum:=m_nds:=0
  m_block:=a_get1[1]:block;m_buf:=EVAL(m_block)
  m_valid1:=a_get1[1]:postBlock;a_get1[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid1,x))}
  a_get1[1]:block:={|x|IF(x==NIL,m_buf,m_buf:=x)}
    DO WHILE .t.
      STABILIZE BROWSE m_browse1
      SET ESCAPE ON
      m_buf:=EVAL(m_block)
      a_get1[1]:row:=ROW();a_get1[1]:col:=COL()
      ReadMy({a_get1[m_browse1:ColPos]},;
          IF(a_say1[1]#NIL.AND.VALTYPE(a_say1[1][1])=="A",a_say1[1],NIL))
      SET ESCAPE OFF
      IF LASTKEY()<>K_ESC.AND..NOT.EMPTY(m_buf)
        IF nakl2->(NetDbAp())
          IF .NOT.EMPTY(a_dop)
            nakl2->prise:=SetPrise(a_data[3],a_dop)
            nakl2->KNDS:= a_dop[8]
            a_dop:={}
          ENDIF
          nakl2->vnum:=nakl1->vnum
          EVAL(m_block,m_buf)
//          i:=2
          m_browse1:right();m_browse1:refreshCurrent()
          DO WHILE .t.
            STABILIZE BROWSE m_browse1
            a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
            ReadMoDal({a_get1[m_browse1:ColPos]})
            IF LASTKEY()==K_UP.AND.m_browse1:colPos<>1
                DO WHILE .t.
                  m_browse1:left()
                  IF a_get1[m_browse1:colPos]:PreBlock==NIL.OR.EVAL(a_get1[m_browse1:colPos]:PreBlock).OR.m_browse1:colPos==1
                    EXIT
                  ENDIF
                ENDDO
                LOOP
            ENDIF
            IF m_browse1:ColPos==m_browse1:ColCount
              EXIT
            ENDIF
            m_browse1:right();m_browse1:refreshCurrent()
          ENDDO
        ELSE
          DispError("Невозможно добавить запись")
        ENDIF
        IF l_vvod
          m_sum+=nakl2->stm;m_nds+=nakl2->nds
          DispS01(m_browse1:colorspec,m_sum,m_nds)
        ENDIF
        m_browse1:panHome();m_browse1:down()
        nakl2->(DbUnLock())
      ELSE
        lApnd:=.f.;a_get1[1]:block:=m_block;a_get1[1]:postBlock:=m_valid1
        EXIT
      ENDIF
      IF NumPotr(a_data[3])=="5"
        lApnd:=.f.;a_get1[1]:block:=m_block;a_get1[1]:postBlock:=m_valid1
        EXIT
      ENDIF
    ENDDO
    IF l_vvod
          IF nakl1->(NetRlock())
            nakl1->sum:=m_sum+m_nds;nakl1->(dbUnlock())
          ENDIF
    ENDIF
RETURN .t.
/*
Function Test1
  LOCAL i:=1
  SET PRINTER TO "t1.txt"
  SET PRINTER ON
  SET CONSOLE OFF
  for i:=1 to 30
    ?STR(I,3),ALIAS(i)
  NEXT
  SET PRINTER OFF
  SET PRINTER TO
  SET CONSOLE ON
RETURN .T.
*/
Function LZK5(var,l_mode)
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,n_win1,m_col,m_ddoc,m_file
  LOCAL m_exit:=READEXIT(.T.),l_stop:=.t.,l_filter:=.f.,k_ctrl_u
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={}
  LOCAL a_get1:={},a_data1:={},n_pole1,a_say1:={},a_brgd:={}
  LOCAL m_browse1,m_vnum,m_ndoc,m_valid,a_dop:={},a_spr01:={},m
  LOCAL m_browse2,m_get1b,m_state:="0",m_col1b,a_fam:={},m_sum,m_nds,m_date,m_pension
  LOCAL blnk_nkl:={||nakl1->tabn:=blank(nakl1->tabn,.t.),;
  nakl1->ksash:=blank(nakl1->ksash,.t.),nakl1->okpo:=blank(nakl1->okpo,.t.),;
  nakl1->mol:=BLANK(nakl1->mol,.t.),nakl1->brgd:=BLANK(nakl1->brgd,.t.)}
  LOCAL k_f4,k_Ctrlf5,k_altf5
  DCL MENU
  DCL LIST
  LOCAL m_select:=SELECT(),a_pred01:={}
  IF .NOT.RECURS()
  SavePar()
  WSELECT(0)
  IF EMPTY(l_mode)
    NET USE (m_platpath+"FVNUM") NEW
    IF .NOT.f_vnum(1)
      CLOSE fvnum
      RETURN .f.
    ENDIF
    NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b") ALIAS kaptka1 NEW
    SopenFiles("100",@s_files)
    OpenFl1()
  ENDIF

  SET CURSOR OFF
  k_f4:=SETKEY(K_F4,{||EdFirm01("FIRM01")})
  k_Ctrlf5:=SETKEY(K_CTRL_F5,{||nalog(1),fvnum->(DBGOTO(1))})
  k_altf5:=SETKEY(K_ALT_F5,{||FormNalog(),fvnum->(DBGOTO(1))})
  k_ctrl_u:=SETKEY(K_CTRL_U,{||LSetprint()})
  a_pred01:={pred01->tabnr,pred01->tabnb}
  InitNds()
  Lapnd:=.f.
//  setblink(.f.)
  NET USE (m_platpath+"memvar") INDEX (m_platpath+"memvar") NEW ALIAS myvar
  m_pension:=RestVar1("m_pension","NK")
  CLOSE myvar

  SELECT Nakl1
  SET FILTER TO
  IF var=="1"
    SET FILTER TO nakl1->vdoc=="6" // Витрата
    INIT GET "TTN  " TO a_get KEY n_pole DATA a_data SAY a_say
    a_get[1]:PreBlock:={||(.Not.Lapnd)}
    a_get[4]:PrebLock:={||.NOT.IsUslug(a_data[3])}
    a_get[5]:PrebLock:={||IsUslug(a_data[3])}
    a_get[6]:PreBlock:={||.f.}
    a_get[7]:PreBlock:={||(NumPotr(a_data[3])=="1")}
    a_get[8]:PreBlock:={||(NumPotr(a_data[3])=="3")}
    a_get[7]:PostBlock:={||firm01->(firm01_vl())}
    a_get[8]:PostBlock:={||sp02->(sp_vl("SP02"))}
    a_get[9]:PostBlock:={||Inv_a->(sp_vl("INV_A"))}
    a_say[6]:={2,51,"","GR+/B",{||SayOpl(a_data[6])}}
  ELSE
    SET FILTER TO nakl1->vdoc=="5" // Витрата
    INIT GET "LZK5  " TO a_get KEY n_pole DATA a_data SAY a_say
    a_get[1]:PreBlock:={||(.Not.Lapnd)}
    a_get[4]:PrebLock:={||.NOT.IsUslug(a_data[3])}
    a_get[5]:PrebLock:={||IsUslug(a_data[3])}
    a_get[6]:PreBlock:={||.f.}
    a_get[7]:PreBlock:={||(AT(NumPotr(a_data[3]),"0267")<>0)}
    a_get[8]:PreBlock:={||(NumPotr(a_data[3])=="1")}
    a_get[9]:PreBlock:={||(NumPotr(a_data[3])=="3")}
    a_get[10]:PreBlock:={||(AT(NumPotr(a_data[3]),"267")<>0)}
    a_get[11]:PreBlock:={||(AT(NumPotr(a_data[3]),"267")<>0)}
    a_get[12]:PreBlock:={||(NumPotr(a_data[3])=="6")}
    a_get[13]:PreBlock:={||(NumPotr(a_data[3])=="7")}
    a_get[14]:PreBlock:={||(NumPotr(a_data[3])=="8")}
    a_get[7]:PostBlock:={||sp10->(sp_vl("SP10A"))}
    a_get[8]:PostBlock:={||firm01->(firm01_vl())}
    a_get[9]:PostBlock:={||sp02->(sp_vl("SP02"))}
    a_get[10]:PostBlock:={||sp01->(sp_vl("SP01",,6,15,"Sp01->naim1","Gr+/b"))}
    a_say[10]:={6,15,"","GR+/B",{||Sp01->(DBSEEK(a_data[10])),Sp01->naim1}}
    a_get[11]:PostBlock:={||sp44->(sp_vl("SP44",,6,40,"Sp44->naim7","Gr+/b"))}
    a_say[11]:={6,40,"","GR+/B",{||Sp44->(DBSEEK(a_data[11])),Sp44->naim7}}
    a_get[12]:PostBlock:={||Inv_a->(sp_vl("INV_A"))}
    a_get[13]:PostBlock:={||Inv_t->(sp_vl("INV_T"))}
    a_get[14]:PostBlock:={||Sp17->(sp_vl("SP17"))}
    a_say[6]:={2,51,"","GR+/B",{||SayOpl(a_data[6])}}
  ENDIF
  Nakl1->(DBSETORDER(1))
  SELECT spr01
  SET FILTER TO spr01->kopr>="100"
  SELECT nakl2
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  a_get[3]:PostBlock:={||Spr01->(spr01(@a_spr01))}
  CrList1(IF(var=="1","TTN","LZK5"),@m_browse,@l_print,"NAKL1")
  n_win1:=InitScr(IF(var=="1","TTN   ","LZK5  "))
  a_get1:=CrGet("NAKL2",a_say1)
  a_say1[1]={{ASC("?"),{||kaptka_vl(a_get1[1],a_data[3],@a_dop)}},;
  {K_F2,{||PrintNakl(a_data)}},;
  {K_CTRL_F12,{||kaptka_vl(a_get1[1],a_data[3],@a_dop,K_CTRL_F12)}}}
  a_get1[1]:PostBlock:={|x|kpt_vl(x,@a_dop)}
  a_get1[4]:PostBlock:=a_get1[7]:PostBlock:={||TaxStm(a_data[3])}
  a_get1[4]:PreBlock:={||IF(NumPotr(a_data[3])=="5",Nakl3(lApnd,"NAKL3"),IF(NumPotr(a_data[3])=="9",Nakl3(lApnd,"NAKL4"),.t.))}
  m_browse1               := TBrowseDB(08,1,MAXROW()-3,MAXCOL()-1)
  m_browse1:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_browse1:colsep        := '│'
  m_browse1:SkipBlock     := {|n| SkipDb1(n,{||(nakl1->vnum==nakl2->vnum)},lApnd) }
  m_browse1:goBottomBlock := {||nakl2->(DBSEEK(nakl1->vnum,.f.)),nakl2->(DBEVAL(,,{||(nakl1->vnum==nakl2->vnum)})),nakl2->(dbskip(-1))}
  m_browse1:goTopBlock    := {||nakl2->(DBSEEK(nakl1->vnum,.f.))}
  CrBrCol("NAKL2",@m_browse1)
  i:=1;AEVAL(a_get1,{|x|a_get1[i]:block:=m_browse1:GetColumn(i):Block,;
  m_browse1:GetColumn(i):footsep:=IF(m_browse1:GetColumn(i):headsep=="┬─","┴─","──"),i++})
  a_get1[10]:Block:={|x|IF(x==NIL,nakl2->stm+nakl2->nds,SetStm(x))}
  Select nakl1 ; Wselect(n_win)
  m_browse:GetColumn(3):block:={||Status1()}
  ADD menu up_down
  add menu Left_Right
  add menu search
  a_ver_menu[3][1][3]:="Пошук по номеру накладної <Shift>+F6"
  AADD(a_ver_menu[3][1],"Складний пошук      <alt>+F7")
  AADD(a_ver_menu[3][2],K_ALT_F7)
  ADD MENU NAME "В~иправлення" ;
  ITEMS {"Добавити   Ins" ,"Виправити  Enter" ,;
  "Удалити    Delete ","Вiдмiтка про сплату <Alt>+<?>",;
  "Розрахунок суми накладних <Alt>+<S>","Вибiрка накладних"} ;
  KEY {K_INS,K_ENTER,K_DEL,309,K_ALT_S,K_ALT_F}
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
    IF m_key==0
      m_key:=INKEY(0)
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
      IF ANSWERu("Друкувати перелiк ЛЗК за день?")==YES
        PrintLs()
      ENDIF
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      CASE m_key==K_SH_F6
        ShiftF6(m_browse,SELECT("NAKL1"))
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==K_ALT_P
         ReadPol();m_browse:refreshAll()
      CASE m_key==309               // ALT+?
         DispOpl()
        CASE m_key==K_ALT_F
          IF ANSWERu("Робити вибiрку ;накладних?")==YES
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
          ENDIF
      CASE m_key==K_ALT_F7
        If KaltF7()
          m_browse:rowPos:=1;m_browse:configure();m_browse:refreshAll()
        ENDIF
    CASE m_Key == K_DEL
      DelDoc(m_browse,l_delete,SELECT("NAKL1"),SELECT("NAKL2"),SELECT("NAKL3"))
    CASE m_key==K_ENTER
      STABILIZE BROWSE m_browse
      WSELECT(n_win1)
      m_screen:=SaveScreen(0,0,MAXROW(),MAXCOL())
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      SELECT nakl1;n_pole:=1
      DBGOTO(RECNO())
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1;m_state:="0"
      set escape on
      SELECT NAKL2
      m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
      WSELECT(n_win1)
      CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
      DISPBOX(m_browse1:nTop-1,m_browse1:nLeft-1,m_browse1:nBottom,m_browse1:nRight+1,"▌─▐▐▐─▌▌ ",m_browse1:colorSpec)
      lApnd:=.f.;EVAL(m_browse1:GotopBlock)
      IF nakl2->vnum==nakl1->vnum //m_browse1:hitBottom
        SumSumNds(@m_sum,@m_nds,m_browse1)
        Stabilize Browse m_browse1
        m_browse1:autolite:=.f.
        m_browse1:DeHilite()
      ENDIF
      a_fam:={}
      SET ESCAPE ON
      DO WHILE .t.
       DO CASE
        CASE m_state=="0"
          select nakl1
          WSELECT(n_win1)
          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
              CASE m_key == K_UP;IF n_pole ==1;ELSE;n_pole:=n_pole-1;END
              CASE m_key == K_DOWN;IF n_pole ==LEN(a_get);ELSE;n_pole:=n_pole+1;END
              CASE m_key == K_CTRL_F5;nalog(1);fvnum->(DBGOTO(1))
              CASE m_key == K_ALT_F5;FormNalog();fvnum->(DBGOTO(1))
              CASE m_key == K_CTRL_U;LSetprint()
              CASE m_key == K_ESC;BeepErr();IF ALERT("Всi змiни будуть анульованi;Виходити ?",{"Так","Нi"})==1;EXIT;END
              CASE m_key == K_F12.OR. m_key == K_CTRL_END
              IF NetRLOCK();n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                UNLOCK;EXIT
              ELSE;DispError("Невозможно заблокировать запись");END
              CASE m_key == K_ENTER ;WinSay
          IF IsLevel(nakl1->oper)      //.AND..NOT.IsBit(ASC(nakl1->state),1).AND..NOT.IsBit(ASC(nakl1->state),2)
              ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
              DispSay(@n_pole,@a_say,@a_data)
                IF n_pole==3
                  IF LEN(a_spr01)>0
                      a_data[6]:=a_spr01[4]
                      i:=n_pole;n_pole:=6;a_get[n_pole]:Display()
                      DispSay(@n_pole,@a_say,@a_data)
                      n_pole:=i
                  ENDIF
                END
          ELSE
          DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
         ENDIF
            CASE m_key = K_TAB
               m_state:="4"
            CASE m_key = K_F2
               PrintNakl(a_data)
          ENDCASE
         CASE m_state=="4"
            CountNds(a_data[3])
            select nakl2
            m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
            lApnd:=.f.;EVAL(m_browse1:GotopBlock)
            IF .NOT.nakl2->vnum==nakl1->vnum //m_browse1:hitBottom
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
                   SumSumNds(@m_sum,@m_nds,m_browse1)
                  CASE m_key = K_F2
                      PrintNakl(a_data)
                  CASE m_key==309.AND.IsLevel(nakl1->oper) // ALT+?
                      DspOpl1()
                  CASE m_key==K_ESC
                    SumSumNds(@m_sum,@m_nds,m_browse1)
                     m_state:="0";EXIT
                  CASE m_key = K_TAB
                     SumSumNds(@m_sum,@m_nds,m_browse1)
                     m_state:="0";EXIT
                DEAL BROWSE m_browse1 KEY m_key
                CASE m_key==K_ENTER   // .OR.Lapnd
                  IF (NumPotr(a_data[3])=="5".AND.m_browse1:ColPos==4).OR.(IsLevel(nakl1->oper))
                      IF NetRLOCK()
                        m_browse1:refreshCurrent()
                        STABILIZE BROWSE m_browse1
                        a_get1[m_browse1:ColPos]:Row:=ROW();a_get1[m_browse1:ColPos]:col:=COL()
                          ReadMy({a_get1[m_browse1:ColPos]},;
                          IF(a_say1[m_browse1:ColPos]#NIL.AND.VALTYPE(a_say1[m_browse1:ColPos][1])=="A",a_say1[m_browse1:ColPos],NIL))
                          IF .NOT.EMPTY(a_dop)
                            nakl2->prise:=SetPrise(a_data[3],a_dop)
                            nakl2->KNDS:= a_dop[8]
                            TaxStm(a_data[3])
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
                  IF IsLevel(nakl1->oper)
                    DelStroka(@m_browse1)
                   ELSE
                    DispError("Ви не маєте прав дозвiлу;на виправлення цього документа")
                   ENDIF
                CASE m_Key == K_INS
                  IF IsLevel(nakl1->oper)
                    m_browse1:panHome();m_browse1:goBottom()
                    STABILIZE BROWSE m_browse1
                    lApnd:=.t.;m_browse1:down();m_browse1:refreshAll()
                    STABILIZE BROWSE m_browse1
                    ReadStroka(@m_browse1,@a_get1,@a_say1,@a_data,.f.,@a_dop)
                    m_browse1:goBottom();m_browse1:refreshAll()
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
    CASE m_key==K_INS
      STABILIZE BROWSE m_browse
      WSELECT(n_win1)
      m_screen:=SaveScreen(0,0,MAXROW(),MAXCOL())
      RestScreen(0,0,MAXROW(),MAXCOL(),m_screen)
      l_stop:=.t.
      m_valid:=a_get[1]:postBlock;a_get[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid,x))}
      DO WHILE l_stop
        set escape on
        CLEARWIN(m_browse1:nTop,m_browse1:nLeft,m_browse1:nBottom,m_browse1:nRight,m_browse1:colorSpec)
        select nakl1;n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
          a_data[2]:=DATE()
        Display Get a_get KEY n_pole SAY a_say DATA a_data
          n_pole:=1
          DO WHILE .t.
            IF a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A".AND.a_say[n_pole][1][1]==ASC("?")
              KEYBOARD(ASC("?"))
            ENDIF
            ReadMy({a_get[n_pole]},IF(a_say[n_pole] # NIL.AND.VALTYPE(a_say[n_pole][1])=="A",a_say[n_pole],NIL))
            DispSay(@n_pole,@a_say,@a_data)
            DO CASE
              CASE LASTKEY() == K_ESC.AND.ALERT("Вийти iз програми",{"Так","Нi"},"Gr+/r,w+/b")==1;l_stop:=.f.;EXIT
              CASE LASTKEY() == K_UP.AND.n_pole # 1;n_pole--;LOOP
              CASE n_pole == LEN(a_get)
                IF NetDbAp()
                  n_pole:=1;AEVAL(a_get,{|x|FIELDPUT(x:cargo,EVAL(x:block)),n_pole++})
                  nakl1->oper:=m_oper
                  EXIT
                ELSE
                  DispError("Невозможно добавить запись")
                ENDIF
              CASE n_pole == 1.AND.EMPTY(a_data[1]);l_stop:=.f.;EXIT
              OTHERWISE
                IF n_pole==3
                  IF LEN(a_spr01)>0
                      a_data[6]:=a_spr01[4]
                      i:=n_pole;n_pole:=6;a_get[n_pole]:Display()
                      DispSay(@n_pole,@a_say,@a_data)
                      n_pole:=i
                  ENDIF
                END
                n_pole++
            ENDCASE
          ENDDO
          IF LASTKEY()==K_ESC.OR..NOT.l_stop
            EXIT
          ENDIF
          nakl1->vdoc:=IF(var=="1","6","5")
          nakl1->day:=DATE()
          nakl1->state:=CHR(SETBIT(ASC(nakl1->state),2))
          nakl1->ddoc3:=Nakl1->ddoc
          IF fvnum->(NetRlock())
            nakl1->vnum:=STR(fvnum->vnum,6)
            fvnum->vnum:=fvnum->vnum+1
            fvnum->(DBCOMMIT())
            fvnum->(DbUnlock())
          ELSE
            DispError("Вiдмовлено в доступi")
            EXIT
          ENDIF
          dbUnlock()
          select nakl2
          m_browse1:rowPos:=1;m_browse1:colPos:=1;m_browse1:configure()
          EVAL(m_browse1:GotopBlock);lApnd:=.t.
          Display Browse m_browse1
          CountNds(a_data[3])
//          DispS01(m_browse:colorspec,m_sum,m_nds)
          ReadStroka(@m_browse1,@a_get1,@a_say1,@a_data,.t.,@a_dop)
        ENDDO
        a_get[1]:postBlock:=m_valid
        RestScreen(0,0,MAXROW(),MAXCOL(),m_screen)
        Wselect(n_win)
        m_browse:refreshAll()
   FINISH LIST
   WCLOSE(n_win);WCLOSE(n_win1)
   WSELECT(0)
   READEXIT(m_exit)
  SETKEY(K_F4,k_f4)
  SETKEY(K_CTRL_F5,k_Ctrlf5)
  SETKEY(K_ALT_F5,k_altf5)
  SETKEY(K_CTRL_U,k_ctrl_u)
  SELECT spr01
  SET FILTER TO
// CLOSE base nakl1,nakl2,spr01
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
    Close Fvnum
  ENDIF
  SavePar(1)
  ENDIF
RETURN .t.
STATIC Function F001()
IF .NOT.EMPTY(nakl1->ddoc3)
  nakl1->state:=CHR(SETBIT(ASC(nakl1->state),2))
ELSE
  nakl1->state:=CHR(CLEARBIT(ASC(nakl1->state),2))
ENDIF
Nakl1->oper1:=m_oper
IF nakl1->ddoc3<nakl1->ddoc
  Disperror("Увага !!! Дата виписки пiзнiша за; дату одержання ")
ENDIF
RETURN .T.
Function PrNakl(a_data)
  LOCAL m_sum:=0,m_nds:=0,i:=1,n_copy,m_kvo,m_rec:=0,m_file,j,m_str
  LOCAL k:=0,l1,l_type
//  LOCAL m_str1
  SavePar()
  DBCOMMITALL()
  m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file)
  m_kvo:=ALERT("Кiлькiсть примiрникiв;на друк",{" 1 "," 2 "," 3 "," 4 "},"n/bg,w/b,gr/rb")
  IF m_kvo==0
    SavePar(1)
    RETURN .f.
  ENDIF
  nakl2->(DBSEEK(nakl1->vnum))
  DO WHILE .t.
    nakl2->(DBSKIP(-1))
    IF nakl1->VNUM<>nakl2->VNUM
      nakl2->(DBSKIP())
      EXIT
    ENDIF
    IF nakl2->(BOF())
      EXIT
    ENDIF
  ENDDO
  SET PRINTER TO (m_file)
  SET PRINTER ON
  SET CONSOLE OFF
  m_rec:=Nakl2->(RECNO())
  FOR n_copy:=1 TO m_kvo
    nakl2->(DBGOTO(m_rec))
  IF .NOT.IsUslug(a_data[3])
?""+P_EMPH_ON+CHR(27)+"-1"+PADC(p_npr,22)+""+CHR(27)+"0"+P_EMPH_OFF+CHR(27)+"-0                            Копiя "+STR(n_copy,2)
?"Комiрник "+P_EMPH_ON+CHR(27)+"4 "+fiomol(a_data[4])+" "+CHR(27)+"5"+CHR(27)+"F("+ALLTRIM(SayOpl(a_data[6]))+")"
?
?"          "+CHR(27)+"FНАКЛАДНА № "+CHR(27)+"w1"+CHR(14)+P_EMPH_ON+ALLTRIM(a_data[1])+""+P_EMPH_OFF+CHR(20)+CHR(27)+"w0 вiд "+P_EMPH_ON+my_dtos(a_data[2])+""+P_EMPH_OFF
?"Через кого  "+P_EMPH_ON+CHR(27)+"-1"+LTRIM(_fio(a_data[8]))+" ("+a_data[8]+")"+P_EMPH_OFF+CHR(27)+"-0"
?"Постачальник"+P_EMPH_ON+CHR(27)+"-1"+a_data[13]+""+P_EMPH_OFF+CHR(27)+"-0"

?CHR(27)+"P──┬────────────────────┬──────┬──────────┬────┬──────┬─────────┬──────────┐"
?CHR(27)+"3"+CHR(17)+CHR(27)+"S0 №│ Назва, сорт, розмiр│Один. │ Кiлькiсть│Од. │Кiльк.│   Цiна  │  Сума    │"+CHR(27)+"T"
?CHR(27)+"S0  │                    │вимiру│          │вим2│    2 │ без ПДВ │ до оплати│"+CHR(27)+"T"+CHR(27)+"2"
m_sum:=0;m_nds:=0;i:=1
DO WHILE nakl2->VNUM==nakl1->vnum.AND..NOT.nakl2->(EOF())
  Kaptka1->(DS(nakl2->kod))
  m_str:=ALLTRIM(kaptka1->name)
  ?"──┼────────────────────┼──────┼──────────┼────┼──────┼─────────┼──────────┤"
    k:=1
    DO WHILE .NOT.EMPTY(m_str).OR.k==1
      IF LEN(m_str)>20
        j:=RAT(" ",SUBSTR(m_str,1,20))
      ELSE
        j:=0
      ENDIF
      l1:=IF(j==0,20,j)
        IF k==1
           ?STRZERO(i,2)+"│"+PADR(LEFT(m_str,l1),20)+"│ "+PADR(Kaptka1->izm,5)+"│"+STR(nakl2->kvo,10,2)+"│"+PADR(Kaptka1->izm2,4)+"│"+NumtoSTR(nakl2->glv,6)+"│"+Str(nakl2->prise,9,3)+"│"+SumToStr(nakl2->stm+nakl2->nds,10)+"│"
        ELSE
        ?"  │"+PADR(LEFT(m_str,l1),20)+"│      │          │    │      │         │          │"
        ENDIF
        m_str:=SUBSTR(m_str,l1+1)
      k++
    ENDDO
  i++;m_sum+=nakl2->stm;m_nds+=nakl2->nds
  nakl2->(Dbskip())
ENDDO
?"──┴────────────────────┴──────┴──────────┴────┴──────┴─────────┴──────────┘"
?"До оплати "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_sum+m_nds))+""+CHR(27)+"F/"+SumStr(m_sum+m_nds)+"/,"+CHR(27)+"P"
?""+CHR(27)+"EВiдпустив"+CHR(27)+"F ________________   "+CHR(27)+"EПрийняв"+CHR(27)+"F  ____________________"
?""+CHR(27)+"2"
?
?
ELSE
?""+P_EMPH_ON+CHR(27)+"-1"+PADC(p_npr,22)+""+CHR(27)+"0"+P_EMPH_OFF+CHR(27)+"-0                            Копiя "+STR(n_copy,2)
Sp01->(DS(a_data[5]))
?"Бригада  "+P_EMPH_ON+CHR(27)+"4 "+Sp01->naim1+"        "+CHR(27)+"5"+CHR(27)+"F("+ALLTRIM(SayOpl(a_data[6]))+")"
?"     "+CHR(27)+"FКВИТАНЦIЯ НА ПОСЛУГИ № "+CHR(27)+"w1"+CHR(14)+P_EMPH_ON+ALLTRIM(a_data[1])+""+P_EMPH_OFF+CHR(20)+CHR(27)+"w0 вiд "+P_EMPH_ON+my_dtos(a_data[2])+""+P_EMPH_OFF
?""+CHR(27)+"2Кому        "+P_EMPH_ON+CHR(27)+"-1"+a_data[15]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Через кого  "+P_EMPH_ON+CHR(27)+"-1"+a_data[16]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Призначення "+P_EMPH_ON+CHR(27)+"-1"+a_data[17]+""+P_EMPH_OFF+CHR(27)+"-0"
?"Податкова накладна N"+nakl1->ndoc2+" Дата: "+DTOC(nakl1->ddoc2)
?CHR(27)+"P──┬────────────────────┬──────┬──────────┬─────────┬──────────┐"
?CHR(27)+"3"+CHR(17)+CHR(27)+"S0 №│ Назва, сорт, розмiр│Один. │ Кiлькiсть│   Цiна  │  Сума    │"+CHR(27)+"T"
?CHR(27)+"S0  │                    │вимiру│          │ без ПДВ │ до оплати│"+CHR(27)+"T"+CHR(27)+"2"
m_sum:=0;m_nds:=0;i:=1
DO WHILE nakl2->VNUM==nakl1->vnum.AND..NOT.nakl2->(EOF())
  Kaptka1->(DS(nakl2->kod))
  m_str:=ALLTRIM(kaptka1->name)
  IF n_copy==m_kvo
    m_str+=" "+kaptka1->ksash2+" "+kaptka1->ksash
  ENDIF
  ?"──┼────────────────────┼──────┼──────────┼─────────┼──────────┤"
    k:=1
    DO WHILE .NOT.EMPTY(m_str)
      j:=RAT(" ",SUBSTR(m_str,1,20))
      IF LEN(m_str)>20
        l1:=IF(j==0,20,j)
      ELSE
        l1:=LEN(m_str)
      ENDIF

        IF k==1
           ?STRZERO(i,2)+"│"+PADR(LEFT(m_str,l1),20)+"│ "+PADR(Kaptka1->izm,5)+"│"+STR(nakl2->kvo,10,2)+"│"+Str(nakl2->prise,9,3)+"│"+SumToStr(nakl2->stm+nakl2->nds,10)+"│"
        ELSE
        ?"  │"+PADR(LEFT(m_str,l1),20)+"│      │          │         │          │"
        ENDIF
        m_str:=SUBSTR(m_str,l1+1)
      k++
    ENDDO
  i++;m_sum+=nakl2->stm;m_nds+=nakl2->nds
  nakl2->(Dbskip())
ENDDO
?"──┴────────────────────┴──────┴──────────┴─────────┴──────────┘"
?"До оплати "+CHR(27)+"E "+""+CHR(27)+"M"+ALLTRIM(SumToStr(m_sum+m_nds))+""+CHR(27)+"F/"+SumStr(m_sum+m_nds)+"/,"+CHR(27)+"P"
?""+CHR(27)+"EВiдпустив"+CHR(27)+"F ________________   "+CHR(27)+"EОдержав"+CHR(27)+"F  ____________________"
?""+CHR(27)+"2"
?
?

ENDIF
IF n_copy<>m_kvo.AND.ALERT("Формування экземпляру"+STR(n_copy,2)+" завершено;Виконувати прогiн листа?",{" Да "," Нi "},"n/bg,n/w")==1
?CHR(K_CTRL_L)
ENDIF
NEXT
IF nakl1->(NetRlock())
  nakl1->pCount:=nakl1->pCount+1
  nakl1->(DbUnlock())
ENDIF

  SET CONSOLE ON
  SET PRINTER OFF
  SET PRINTER TO
  IF SPOOLACTIV().AND.SPOOLCOUNT()<8
//    IF Is_Ready_Prn()
      SPOOLADD(m_file)
//    ENDIF
  ELSE
          MyPRINTFILE(m_file)
//    PRINTFILE(m_file,.t.)
  ENDIF
  SavePar(1)
RETURN .t.
Function Openfl1()
    NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b"),(m_platpath+"kaptka1c") ALIAS kaptka1 NEW
    NET USE (m_platpath+"PRED01") NEW
    NET USE (m_platpath+"FIRM01") INDEX (m_platpath+"FIRM01"),(m_platpath+"FIRM01A"),(m_platpath+"FIRM01B") NEW
    NET USE (m_platpath+"BANK01") INDEX (m_platpath+"BANK01") NEW
    NET USE (m_platpath+"nalog1") INDEX (m_platpath+"nalog1"),(m_platpath+"nalog1a") NEW ALIAS nalog1
    NET USE (m_platpath+"nalog2") INDEX (m_platpath+"nalog2") NEW ALIAS nalog2
    NET USE (m_platpath+"spr01") INDEX (m_platpath+"spr01")   NEW ALIAS spr01
    NET USE (m_platpath+"nakl1") INDEX (m_platpath+"nakl1"),(m_platpath+"nakl1a")   NEW ALIAS nakl1
    NET USE (m_platpath+"nakl2") INDEX (m_platpath+"nakl2")   NEW ALIAS nakl2
    nakl1->(DBSETRELATION("nakl2",{||nakl1->vnum},"nakl1->vnum"))
    NET USE (m_platpath+"nakl3") INDEX (m_platpath+"nakl3")     NEW ALIAS nakl3 */
RETURN .T.
Function CloseFl1()
    CLOSE base nakl1,nakl2,nakl3,spr01,kaptka1,pred01
    CLOSE BASE nalog2,firm01,bank01,nalog1
RETURN .t.
Function Openfl2()
    NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b"),(m_platpath+"kaptka1c") ALIAS kaptka1 NEW
    NET USE (m_platpath+"PRED01") NEW
    NET USE (m_platpath+"FIRM01") INDEX (m_platpath+"FIRM01"),(m_platpath+"FIRM01A"),(m_platpath+"FIRM01B") NEW
    NET USE (m_platpath+"BANK01") INDEX (m_platpath+"BANK01") NEW
    NET USE (m_platpath+"nalog1") INDEX (m_platpath+"nalog1"),(m_platpath+"nalog1a") NEW ALIAS nalog1
    NET USE (m_platpath+"nalog2") INDEX (m_platpath+"nalog2") NEW ALIAS nalog2
    NET USE (m_platpath+"spr01") INDEX (m_platpath+"spr01")   NEW ALIAS spr01
RETURN .T.
Function CloseFl2()
    CLOSE base spr01,kaptka1,pred01
    CLOSE BASE firm01,bank01
RETURN .t.
Function AktPer()
  OPenFl1()
  SpBrow("NAKL5")
  CloseFl1()
Return .t.
