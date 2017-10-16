#include "menu.ch"
#include "new.ch"
#include "setcurs.ch"
MEMVAR m_mash,m_temppath,m_level,m_sprpath
// STATIC m_browse:=NIL,m_browse1:=NIL
STATIC n_space:=10,s_kod:=""
Function kaptka1
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win,a_win:={},m_col
  LOCAL a_name:={"KAPTKA1"},m_exit:=READEXIT(.T.),l_stop:=.t.
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={},m_buf
  LOCAL a_get1:={},a_data1:={},n_pole1,Lapnd:=.f.,m_block
  LOCAL m_browse1,m_vnum,m_valid,m_valid1,n_order
  LOCAL m_browse2,m_get1b,m_state:="0",m_col1b
  LOCAL m_value:="",m_len,m_rec
  DCL menu
  DCL LIST
  LOCAL m_select:=SELECT()
  SopenFiles("100",@s_files)
  OPenFl2()
  CrList1("KAPTKA1",@m_browse,@l_print)
  ASIZE(a_win,LEN(a_name));AFILL(A_WIN,-1)
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  WSELECT(n_win)
  FOR i:=1 TO LEN(a_name)
      a_win[i]:=InitScr(a_name[i])
  NEXT
  Select kaptka1 ; Wselect(n_win)
  SELECT(a_name[1])
  INIT GET a_name[1] TO a_get KEY n_pole DATA a_data SAY a_say
  a_say[4]:={{ASC("?"),{||Sp44Dop(@a_data,@a_get,@n_pole)}}}
  ADD menu up_down
  add menu Left_Right
  add menu search
  add menu print
  kaptka1->(DBGOTOP())
  INIT menu
  m_browse:RowPos:=1;m_browse:ColPos:=1
  m_browse:configure()
  m_get:ColorSpec:=TOKEN(m_browse:colorSpec,",",4) + TOKEN(m_browse:colorSpec,",",4)
  DISPLAYLIST
  SET cursor Off
    IF INDEXORD()<>0
      m_len:=LEN(&(INDEXKEY(0)))
    ELSE
      m_len:=0
    ENDIF
   @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
  DO WHILE .t.
    Display Browse m_browse
    m_key:=INKEY(0)
    Winsay
    DEAL MENU
    DO CASE
      DEAL BROWSE m_browse KEY m_key
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      SEEK  BROWSE m_browse KEY m_key
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==K_F5.AND.ANSWERu("Робити копiю картки облiку ТМЦ?")==YES
        CopyRec()
        m_browse:RefreshAll()
        CASE m_key == K_ALT_1
          IF INDEXORD()<>1
            SET ORDER TO 1
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
        CASE m_key == K_ALT_0
          IF INDEXORD()<>0
            SET ORDER TO 0
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
          @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
          m_len:=0
          m_value:=""
          ENDIF
        CASE m_key == K_ALT_2
          IF INDEXORD()<>2.AND..NOT.EMPTY(INDEXKEY(2))
            SET ORDER TO 2
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
        CASE m_key == K_ALT_3
          IF INDEXORD()<>3.AND..NOT.EMPTY(INDEXKEY(4))
            SET ORDER TO 4
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
    CASE m_key==K_BS.AND.LEN(m_value)>0
        @m_browse:nbottom+1,m_browse:nleft+10+LEN(m_value) SayDisp "▒" COLOR "GR+/b"
        m_value:=SUBSTR(m_value,1,LEN(m_value)-1)
    CASE m_len<>0.AND.LEN(m_value)<m_len.AND.m_key>=32
        m_rec:=RECNO()
        IF DBSEEK(m_value+UPPER(CHR(m_key)),.t.)
        m_browse:rowPos:=1;m_browse:configure()
        m_browse:refreshCurrent()
        m_rec:=RECNO()
        m_browse:refreshAll()
        m_value+=UPPER(CHR(m_key))
        @m_browse:nbottom+1,m_browse:nleft+10+LEN(m_value) SayDisp CHR(m_key) COLOR "GR+/b"
      ELSE
        DBGOTO(m_rec)
        BeepErr()
      ENDIF
      CASE m_Key == K_DEL                                    /* удаление записи */
         IF l_delete.OR.( answer( "Вы действительно хотите уничтожить запись ?" )==YES )
          IF kaptka1->(RLOCK());kaptka1->(dbdelete());kaptka1->(dbUNLOCK())
          ELSE;DispErr("Файл заблокирован");ENDIF
          DBSKIP(-1);DBSKIP(1);m_browse:RefreshAll()
         ENDIF
    CASE m_key==K_ENTER
      WSELECT(a_win[1])
      EditKaptka(@a_get,@a_data,@a_say,@m_browse,@n_pole)
      Wselect(n_win)
    CASE m_key==K_INS
      WSELECT(a_win[1])
      InsKaptka(@a_get,@a_data,@a_say,@m_browse,@n_pole)
      Wselect(n_win)
    CASE m_key==K_CTRL_F12
      IF EMPTY(a_get)
        SELECT(a_name[1])
        INIT GET a_name[1] TO a_get KEY n_pole DATA a_data SAY a_say
      ENDIF
      m_browse:SkipBlock     :={|n|SkipDb3(n)}
      m_browse:goBottomBlock := { ||  MyGOBT() }
      m_browse:goTopBlock    := { ||  MyGOTOP()  }
      n_order:=INDEXORD()
      m_rec:=RECNO()
      kaptka1->(DBSETORDER(3))
      kaptka1->(DBGOTOP())
      s_kod:=""
      n_space:=LEN(kaptka1->kod)-AT(" ",kaptka1->kod)
      KaptkaTree(m_browse,"~3Групи ТМЦ i послуг",a_win[1],@a_get,@a_data,@a_say,@m_browse,@n_pole)
      WSELECT(n_win)
      m_browse:rowPos:=1;m_browse:configure()
      kaptka1->(DBSETORDER(n_order))
      m_browse:refreshAll()
      m_browse:SkipBlock     := { |n| SkipDb(n) }
      m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
      m_browse:goTopBlock    := { ||  DBGOTOP()  }
   FINISH LIST
   ScloseFile(s_files)
   CloseFl2()
   WCLOSE(n_win)
   AEVAL(a_win,{|x|WCLOSE(x)})
   WSELECT(0)
   READEXIT(m_exit)

RETURN .t.

// ***********************************************************************

Function kaptka_vl(x,m_kopr,a_dop,m_Inkey)
  LOCAL m_key:=m_inkey,i,j,k,GetList:={},m_screen,m_col,l1:=.f.
  LOCAL a_name:={"KAPTKA1"},m_exit:=READEXIT(.T.),l_stop:=.t.
//  LOCAL a_func_block:=GetEdIzm()
  LOCAL a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={},m_buf
  LOCAL a_data1:={},n_pole1,Lapnd:=.f.,m_block
  LOCAL m_browse1,m_vnum,m_valid,m_valid1,m_ret:=.f.
  LOCAL m_value:="",m_len,m_rec,m_kod,m_skipblock
  DCL menu
//  DCL LIST
  LOCAL m_select:=SELECT(),oCurGet      := GETACTIVE ( )
  LOCAL s_files:={},l_delete:=.f.
  LOCAL m_recno,m_poisk1,m_poisk2:={||.f.},m_poisk3,m_poisk4,m_indexkey,m_time
  LOCAL m_browse,a_win:={},n_win,l_print:={},a_get1,a_get,n_order:=INDEXORD()
  IF oCurGet<>NIL.AND.x==NIL
      m_recno:=RECNO()
      SET ORDER TO 1
      DBSEEK(oCurGet:VarGet(),.t.)
      SET ORDER TO n_order
      IF .NOT.FOUND()
        DBGOTO(m_recno)
      ELSE
        RETURN .t.
      ENDIF
  ENDIF

  SAvePar()
  WSELECT(0)
    IF VALTYPE(a_dop)=="A"
      a_dop:={}
    ENDIF
//  IF m_browse==NIL
    CrList1("KAPTKA1",@m_browse,@l_print)
    ASIZE(a_win,LEN(a_name));AFILL(A_WIN,-1)
    n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
    FOR i:=1 TO LEN(a_name)
        a_win[i]:=InitScr(a_name[i])
    NEXT
//  ENDIF
  WSELECT(n_win)
  Select kaptka1 ; Wselect(n_win)
  SELECT(a_name[1])
  INIT GET a_name[1] TO a_get KEY n_pole DATA a_data SAY a_say
  a_say[4]:={{ASC("?"),{||Sp44Dop(@a_data,@a_get,@n_pole)}}}
  ADD menu up_down
  add menu Left_Right
  add menu search
  Add Menu NAME "В~иправлення" ;
  ITEMS {"Добавити <Ins>" ,"Виправити  <Ctrl>+<Enter>" ,"Занести <Enter>","Видалити <Delete>","Дерево кодiв <Ctrl>+<F12>" } ;
  KEY {K_INS,K_CTRL_RET,K_ENTER,K_DEL,K_CTRL_F12}
  add menu print
  SELECT Kaptka1
  kaptka1->(DBSETORDER(1))
  IF  kaptka1->(EOF())
    kaptka1->(DBGOTOP())
  ENDIF

  INIT menu
  m_browse:RowPos:=1;m_browse:ColPos:=1
  m_browse:configure()
  m_get:ColorSpec:=TOKEN(m_browse:colorSpec,",",4) + TOKEN(m_browse:colorSpec,",",4)
  DISPLAYLIST
  SET cursor Off
    IF INDEXORD()<>0
      m_len:=LEN(&(INDEXKEY(0)))
    ELSE
      m_len:=0
    ENDIF
   @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
  DO WHILE .t.
    Display Browse m_browse
    IF m_key==NIL.OR.l1
      m_key:=INKEY(0)
    ENDIF
    l1:=.t.
    Winsay
    DEAL MENU
    DO CASE
      CASE m_key==K_ESC
        EXIT
      DEAL BROWSE m_browse KEY m_key
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      SEEK  BROWSE m_browse KEY m_key
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_key==K_F5.AND.ANSWERu("Робити копiю картки облiку ТМЦ?")==YES
        CopyRec()
        m_browse:RefreshAll()
      CASE m_Key == K_DEL                                    /* удаление записи */
         IF l_delete.OR.( answer( "Вы действительно хотите уничтожить запись ?" )==YES )
          IF kaptka1->(RLOCK());kaptka1->(dbdelete());kaptka1->(dbUNLOCK())
          ELSE;DispErr("Файл заблокирован");ENDIF
          DBSKIP(-1);DBSKIP(1);m_browse:RefreshAll()
         ENDIF
        CASE m_key == K_ALT_1
          IF INDEXORD()<>1
            SET ORDER TO 1
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
        CASE m_key == K_ALT_0
          IF INDEXORD()<>0
            SET ORDER TO 0
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
          @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
          m_len:=0
          m_value:=""
          ENDIF
        CASE m_key == K_ALT_2
          IF INDEXORD()<>2.AND..NOT.EMPTY(INDEXKEY(2))
            SET ORDER TO 2
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
        CASE m_key == K_ALT_3
          IF INDEXORD()<>3.AND..NOT.EMPTY(INDEXKEY(4))
            SET ORDER TO 4
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
    CASE m_key==K_ENTER
//    IF NetRLOCK()
      IF x<>NIL
        x:buffer:=kaptka1->kod;x:exitState:=5
      ELSE
        IF oCurGet<>NIL
            oCurGet:VarPut(kaptka1->kod)
            oCurGet:UpdateBuffer()
        ENDIF
      ENDIF
//    ELSE
//      DispError("Невозможно заблокировать запись")
//    ENDIF
    IF VALTYPE(a_dop)=="A"
      a_dop:={kaptka1->kod,kaptka1->name,kaptka1->izm,kaptka1->izm2,kaptka1->prise,kaptka1->prise1,kaptka1->prise2}
    ENDIF
    m_ret:=.t.
    EXIT
    CASE m_key==K_CTRL_RET
      WSELECT(a_win[1])
      EditKaptka(@a_get,@a_data,@a_say,@m_browse,@n_pole)
      Wselect(n_win)
    CASE m_key==K_INS
      WSELECT(a_win[1])
      InsKaptka(@a_get,@a_data,@a_say,@m_browse,@n_pole)
      Wselect(n_win)
    CASE m_key==K_BS.AND.LEN(m_value)>0
        @m_browse:nbottom+1,m_browse:nleft+10+LEN(m_value) SayDisp "▒" COLOR "GR+/b"
        m_value:=SUBSTR(m_value,1,LEN(m_value)-1)
    CASE m_len<>0.AND.LEN(m_value)<m_len.AND.m_key>=32
        m_rec:=RECNO()
        IF DBSEEK(m_value+UPPER(CHR(m_key)),.t.)
        m_browse:rowPos:=1;m_browse:configure()
        m_browse:refreshCurrent()
        m_rec:=RECNO()
        m_browse:refreshAll()
        m_value+=UPPER(CHR(m_key))
        @m_browse:nbottom+1,m_browse:nleft+10+LEN(m_value) SayDisp CHR(m_key) COLOR "GR+/b"
      ELSE
        DBGOTO(m_rec)
        BeepErr()
      ENDIF
    CASE m_key==K_CTRL_F12
      m_browse:SkipBlock     :={|n|SkipDb3(n)}
      m_browse:goBottomBlock := { ||  MyGOBT() }
      m_browse:goTopBlock    := { ||  MyGOTOP()  }
      n_order:=INDEXORD()
      m_rec:=RECNO()
      kaptka1->(DBSETORDER(3))
      kaptka1->(DBGOTOP())
      s_kod:=""
      n_space:=LEN(kaptka1->kod)-AT(" ",kaptka1->kod)
      IF KaptkaTree(m_browse,"~3Групи ТМЦ i послуг",a_win[1],@a_get,@a_data,@a_say,@m_browse,@n_pole)==1
        IF NetRLOCK()
          IF x<>NIL
            x:buffer:=kaptka1->kod;x:exitState:=5
          ELSE
            IF oCurGet<>NIL
                oCurGet:VarPut(kaptka1->kod)
                oCurGet:UpdateBuffer()
            ENDIF
          ENDIF
        ELSE
          DispError("Невозможно заблокировать запись")
        ENDIF
        IF VALTYPE(a_dop)=="A"
          a_dop:={kaptka1->kod,kaptka1->name,kaptka1->izm,kaptka1->izm2,kaptka1->prise,kaptka1->prise1,kaptka1->prise2}
        ENDIF
        EXIT
      ENDIF
      WSELECT(n_win)
      m_browse:rowPos:=1;m_browse:configure()
      kaptka1->(DBSETORDER(n_order))
      m_browse:refreshAll()
      m_browse:SkipBlock     := { |n| SkipDb(n) }
      m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
      m_browse:goTopBlock    := { ||  DBGOTOP()  }
   FINISH LIST
   READEXIT(m_exit)
   SET ORDER TO 1
   WClose(n_win)
   AEVAL(a_win,{|x|WCLOSE(x)})
   WSELECT(0)
   SELECT(m_select)
   savePar(1)
RETURN m_ret


Function KaptkaTree(m_browse,m_name,n_win2,a_get,a_data,a_say,m_browse1,n_pole)
LOCAL m_key,n_win,l_delete:=.t.,n_ret:=0,n1,n2,n3,n4,m_recno
LOCAL m_str1,m_str2,m_str3,m_ret,n5,n6,m_value:="",m_len:=LEN(ALLTRIM(field->kod))-LEN(s_kod)
// Позиционирование на первую запись
/* DO WHILE .NOT.(BOF()).AND.n_space==LEN(kaptka1->kod)-AT(" ",kaptka1->kod)
  (DBSKIP(-1))
ENDDO */

m_browse:RowPos:=1;m_browse:Colpos:=1
n1:=m_browse:nBottom
n2:=m_browse:nTop
n3:=m_browse:nLeft
n4:=m_browse:nRight
n_win:=WOPEN(2+MAXROW(.t.)-MAXROW(),1+MAXCOL(.t.)-MAXCOL(),MAXROW(.t.),MAXCOL(.t.))
WSELECT(n_win)
m_browse:nBottom:=MAXROW()-1
m_browse:nTop   :=1
m_browse:nLeft  :=1
m_browse:nRight :=MAXCOL()-1
m_browse:configure()
@0,0,MAXROW(),MAXCOL() BOX B_SINGLE+" " COLOR "w/b"
@m_browse:nbottom+1,m_browse:nleft+10 SayDisp s_kod COLOR "GR+/b"
@m_browse:nbottom+1,m_browse:nleft+10+LEN(s_kod) SayDisp REPLICATE("▒",m_len) COLOR "GR+/b"
@0,1 SayText PADC(m_name,MAXCOL()-3) COLOR "b/w,r/w,n/w"
DO WHILE .t.
    Display Browse m_browse
    m_key:=INKEY(0)
    DO CASE
      CASE m_key==K_ESC
        m_ret:=-1
        EXIT
      CASE m_key==K_LEFT
        m_ret:=0
        EXIT
      CASE m_key==K_INS
        WSELECT(n_win2)
        InsKaptka(@a_get,@a_data,@a_say,@m_browse,@n_pole)
        Wselect(n_win)
      CASE m_key==K_CTRL_RET
        WSELECT(n_win2)
        EditKaptka(@a_get,@a_data,@a_say,@m_browse,@n_pole)
        Wselect(n_win)
      CASE m_key==K_ENTER
        m_ret:=1
        EXIT
      CASE m_key==K_RIGHT
        DBSETORDER(1)
        m_str1:=ALLTRIM(kaptka1->kod)
        m_str2:=ALLTRIM(kaptka1->name)
        m_str3:=s_kod
        m_recno:=RECNO()
        DBSKIP()
        IF LEFT(kaptka1->kod,LEN(m_str1))==m_str1
          DBSETORDER(3)
          n5:=n_space;s_kod:=m_str1
          n_space:=LEN(kaptka1->kod)-AT(" ",kaptka1->kod)
          n6:=m_browse:rowPos
          m_ret:=KaptkaTree(m_browse,"Група кодiв ~2"+m_str1+" ~3"+m_str2,n_win2,@a_get,@a_data,@a_say,@m_browse,@n_pole)
          WSELECT(n_win)
          s_kod:=m_str3;n_space:=n5
          IF m_ret==1.OR.m_ret==-1
            EXIT
          ENDIF
          m_browse:rowPos:=n6
          m_browse:configure()
          DBGOTO(m_recno)
        ELSE
          DBSKIP(-1)
          DispError("Дана група не має кодiв")
          DBSETORDER(3)
        ENDIF
    CASE m_key==K_BS.AND.LEN(m_value)>0
        @m_browse:nbottom+1,m_browse:nleft+10+LEN(s_kod)+LEN(m_value)-1 SayDisp "▒" COLOR "GR+/b"
        m_value:=LEFT(m_value,LEN(m_value)-1)
    CASE m_len<>0.AND.LEN(m_value)<m_len.AND.m_key>=32
        m_recno:=RECNO()
        IF DBSEEK(SPACE(LEN(kaptka1->kod)-LEN(s_kod)-m_len)+s_kod+m_value+UPPER(CHR(m_key)),.t.)
          m_browse:rowPos:=1;m_browse:configure()
          m_browse:refreshCurrent()
          m_recno:=RECNO()
          m_browse:refreshAll()
          m_value+=UPPER(CHR(m_key))
          @m_browse:nbottom+1,m_browse:nleft+10+LEN(s_kod)+LEN(m_value)-1 SayDisp CHR(m_key) COLOR "GR+/b"
      ELSE
        DBGOTO(m_recno)
        BeepErr()
      ENDIF
      DEAL BROWSE m_browse KEY m_key
  ENDCASE
ENDDO
m_browse:nBottom:=n1
m_browse:nTop   :=n2
m_browse:nLeft  :=n3
m_browse:nRight :=n4
WCLOSE(n_win)
RETURN m_ret

STATIC FUNCTION CopyRec()
LOCAL m_kod,a_fields:={},m_num,c_delim,i
m_kod:=TOKEN(kaptka1->kod,,1)
FOR i:=1 TO kaptka1->(FCOUNT())
  AADD(a_fields,kaptka1->(FIELDGET(i)))
NEXT
DO WHILE .NOT.kaptka1->(EOF()).AND.m_kod==TOKEN(kaptka1->kod,,1)
  kaptka1->(DBSKIP())
ENDDO
kaptka1->(DBSKIP(-1))
m_num:=VAL(TOKEN(kaptka1->kod,,2))+1
IF m_num==1
  c_delim:="/"
ELSE
  c_delim:=SUBSTR(kaptka1->kod,ATTOKEN(kaptka1->kod,,2)-1,1)
ENDIF
kaptka1->(DBAP())
FOR i:=1 TO kaptka1->(FCOUNT())
  kaptka1->(FIELDPUT(i,a_fields[i]))
NEXT
kaptka1->kod:=m_kod+c_delim+STRZERO(m_num,2)
RETURN .t.
STATIC FUNCTION SkipDb3(n)
    LOCAL  ncount  := 0
IF n > 0
   DO WHILE ncount < n
        DBSKIP()
       // Если конец файла
       IF  EOF().OR.n_space<>(LEN(kaptka1->kod)-AT(" ",kaptka1->kod)).OR.LEFT(kaptka1->kod,LEN(s_kod))<>s_kod
          DBSKIP( -1 )
          EXIT
       END
       ncount++
   ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF().OR.n_space<>(LEN(kaptka1->kod)-AT(" ",kaptka1->kod)).OR.LEFT(kaptka1->kod,LEN(s_kod))<>s_kod
          IF n_space<>(LEN(kaptka1->kod)-AT(" ",kaptka1->kod)).OR.LEFT(kaptka1->kod,LEN(s_kod))<>s_kod
            kaptka1->(DBSKIP(1))
          ENDIF
          EXIT
       END
       ncount--
   ENDDO
END
RETURN ( ncount )
RETURN .t.
STATIC FUNCTION MyGoTop()
DO WHILE .NOT.kaptka1->(BOF()).AND.n_space==(LEN(kaptka1->kod)-AT(" ",kaptka1->kod)).AND.LEFT(kaptka1->kod,LEN(s_kod))==s_kod
  kaptka1->(DBSKIP(-1))
ENDDO
IF n_space<>(LEN(kaptka1->kod)-AT(" ",kaptka1->kod)).OR.LEFT(kaptka1->kod,LEN(s_kod))<>s_kod
  kaptka1->(DBSKIP(1))
ENDIF
RETURN .t.
STATIC FUNCTION MyGobt()
DO WHILE .NOT.kaptka1->(EOF()).AND.n_space==(LEN(kaptka1->kod)-AT(" ",kaptka1->kod)).AND.LEFT(kaptka1->kod,LEN(s_kod))==s_kod
  kaptka1->(DBSKIP(1))
ENDDO
kaptka1->(DBSKIP(-1))
RETURN .t.
STATIC Function EditKaptka(a_get,a_data,a_say,m_browse,n_pole)
  LOCAL c_key,j,m_key
      n_pole:=1
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      SELECT kaptka1;n_pole:=1
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1
      set escape on
      SET CURSOR OFF
      select kaptka1
      DO WHILE .t.
          DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
          DO CASE
            WORK GET a_get KEY m_key BY n_pole  SAY a_say DATA a_data
          ENDCASE
      ENDDO
      IF INDEXORD()<>0;IF c_key<>&(INDEXKEY(0));m_browse:refreshAll()
      ELSE;m_browse:refreshCurrent();END;END
RETURN .t.
STATIC Function InsKaptka(a_get,a_data,a_say,m_browse,n_pole)
LOCAL l_stop,m_valid
      set escape on
      l_stop:=.t.
      m_valid:=a_get[1]:postBlock;a_get[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid))}
      DO WHILE l_stop
        n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
        Display Get a_get KEY n_pole SAY a_say DATA a_data
        TAKE GET a_get KEY n_pole SAY a_say DATA a_data
        IF LASTKEY()==K_ESC.OR..NOT.l_stop
          EXIT
        ENDIF
        kaptka1->(dbUnlock())
      ENDDO
      a_get[1]:postBlock:=m_valid
      m_browse:refreshAll()
RETURN .t.
STATIC FUNCTION Sp44Dop(a_data,a_get,n_pole)
LOCAL i:=n_pole,a_mass:={},a_par:={"naim7"}
Sp44->(DS(a_data[1]))
IF Sp44->(vl_sp("SP44","1",@a_mass,a_par))
      a_data[4]:=PADR(LEFT(ALLTRIM(a_mass[1]),LEN(a_data[4])),LEN(a_data[4]))
      n_pole:=4;a_get[4]:reset();n_pole:=i
ENDIF
RETURN .t.
Function EdFirm01(var)
  LOCAL m_key,i,j,k,GetList:={},m_screen,n_win
  LOCAL m_exit:=READEXIT(.T.),l_stop:=.t.,m_str
  LOCAL a_get:={},a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={},m_buf
  LOCAL Lapnd:=.f.,m_valid,m_select:=SELECT(),n_win1
  LOCAL a_bank01:={8,9,10}
  DCL MENU
  DCL LIST
  SavePar()
  SopenFiles("100",@s_files)
  OPenFl2()

  SELECT (var)
  INIT GET var TO a_get KEY n_pole DATA a_data SAY a_say
  a_say[1]:={{K_F5,{||i:=n_pole,a_get[1]:Assign(),IF(EMPTY(a_data[2]),a_data[2]:=PADR(a_data[1],LEN(a_data[2])),NIL),;
  n_pole:=2,a_get[2]:Display(),n_pole:=i}}}
  a_say[2]:={{K_F5,{||i:=n_pole,IF(EMPTY(a_data[2]),a_data[2]:=PADR(a_data[1],LEN(a_data[2])),NIL),;
  n_pole:=2,a_get[2]:UpdateBuffer(),a_get[2]:Display(),n_pole:=i}}}
  CrList1(var,@m_browse,@l_print)
  DO CASE
    CASE var=="FIRM01"
      a_get[8]:postblock:={|x,l,k|l:=bank01->(bank01(@a_data,a_bank01,{"MFO","BANK1","BANK2"},@a_get)),;
      k:=n_pole,AEVAL(a_bank01,{|x|n_pole:=x,a_get[x]:UpdateBuffer(),a_get[x]:display()}),n_pole:=k,l}
  ENDCASE
  WSELECT(0)
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  n_win1:=InitScr(var)
  WSELECT(n_win)
  ADD menu up_down
  add menu Left_Right
  add menu search
  ADD MENU NAME "~Виправлення";
  ITEMS {"Добавити   Ins" ,"Виправити  Enter" ,"Видалити   Delete "} ;
  KEY {K_INS,K_ENTER,K_DEL}
  add menu print
  INIT menu
  m_browse:RowPos:=1;m_browse:ColPos:=1
  DISPLAYLIST
  SET cursor Off
  DO WHILE .t.
    Display Browse m_browse
    m_key:=INKEY(0)
    Winsay
    DEAL MENU
    DO CASE
      DEAL BROWSE m_browse KEY m_key
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      SEEK  BROWSE m_browse KEY m_key
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_Key == K_DEL                                    /* удаление записи */
         IF l_delete.OR.( ANSWERu( "Ви дiйсно бажаєте видалити картку ?" )==YES )
          IF NetRLOCK();dbdelete();dbUNLOCK()
          ELSE;DispErr("Файл заблоковано");ENDIF
          DBSKIP(-1);DBSKIP(1);m_browse:RefreshAll()
         ENDIF
    CASE m_key==K_ENTER
      WSELECT(n_win1)
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      n_pole:=1
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1
      set escape on
      SET CURSOR OFF
          DO WHILE .t.
            DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
            DO CASE
              WORK GET a_get KEY m_key BY n_pole  SAY a_say DATA a_data
            ENDCASE
          ENDDO
      Wselect(n_win)
      IF INDEXORD()<>0;IF c_key<>&(INDEXKEY(0));m_browse:refreshAll()
      ELSE;m_browse:refreshCurrent();END;END
    CASE m_key==K_INS
      set escape on
      WSELECT(n_win1)
      l_stop:=.t.
      m_valid:=a_get[1]:postBlock
      IF a_get[1]:postBlock<>NIL
        a_get[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid,x))}
      ENDIF
      DO WHILE l_stop
        n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
        Display Get a_get KEY n_pole SAY a_say DATA a_data
        TAKE GET a_get KEY n_pole SAY a_say DATA a_data
        IF LASTKEY()==K_ESC.OR..NOT.l_stop
          EXIT
        ENDIF
        dbUnlock()
      ENDDO
      a_get[1]:postBlock:=m_valid
      Wselect(n_win)
      m_browse:refreshAll()
   FINISH LIST
   ScloseFile(s_files)
   CloseFl2()
   WCLOSE(n_win);WCLOSE(n_win1)
SAVEPar(1)
RETURN .t.



Function firm01_vl(a_firm,a_par,mode)
  LOCAL m_key:=NIL,i,j,k,GetList:={},m_screen,m_col
  LOCAL l_stop:=.t.
  LOCAL a_data:={},n_pole,m_get:=GetNew(),c_key,a_say:={},m_buf
  LOCAL Lapnd:=.f.,n_win1
  LOCAL m_browse1,m_vnum,m_valid,m_ret:=.f.
  LOCAL m_value:="",m_len,m_rec,m_kod
  LOCAL a_bank01:={8,9,10}
  DCL menu
  LOCAL oCurGet      := GETACTIVE ( )
  LOCAL l_delete:=.f.
  LOCAL m_recno,m_poisk1,m_poisk2:={||.f.},m_poisk3,m_poisk4,m_indexkey,m_time
  LOCAL m_browse,a_win:={},n_win,l_print:={},a_get1,a_get,n_order:=INDEXORD()
  IF oCurGet<>NIL.AND.a_par==NIL
      m_recno:=RECNO()
      IF mode==NIL
        SET ORDER TO 2
      ELSE
        SET ORDER TO 3
      ENDIF
      DBSEEK(oCurGet:VarGet(),.t.)
      SET ORDER TO n_order
      IF .NOT.FOUND()
        SET ORDER TO 1
//        DBGOTOP()
      ELSE
        RETURN .t.
      ENDIF
  ENDIF

  SAvePar()
  WSELECT(0)
    IF VALTYPE(a_par)=="A"
      a_firm:={}
    ENDIF
    CrList1("FIRM01",@m_browse,@l_print)
    FOR i:=1 TO m_browse:ColCount
      m_browse:GetColumn(i):Footsep:=NIL
    NEXT
  n_win:=WOPEN(0,0,MAXROW(),MAXCOL())
  n_win1:=InitScr("FIRM01")
  WSELECT(n_win)
  INIT GET "FIRM01" TO a_get KEY n_pole DATA a_data SAY a_say
  a_say[1]:={{K_F5,{||i:=n_pole,a_get[1]:Assign(),IF(EMPTY(a_data[2]),a_data[2]:=PADR(a_data[1],LEN(a_data[2])),NIL),;
  n_pole:=2,a_get[2]:Display(),n_pole:=i}}}
  a_say[2]:={{K_F5,{||i:=n_pole,IF(EMPTY(a_data[2]),a_data[2]:=PADR(a_data[1],LEN(a_data[2])),NIL),;
  n_pole:=2,a_get[2]:UpdateBuffer(),a_get[2]:Display(),n_pole:=i}}}
  a_get[8]:postblock:={|x,l,k|l:=bank01->(bank01(@a_data,a_bank01,{"MFO","BANK1","BANK2"},@a_get)),;
  k:=n_pole,AEVAL(a_bank01,{|x|n_pole:=x,a_get[x]:UpdateBuffer(),a_get[x]:display()}),n_pole:=k,l}
  ADD menu up_down
  add menu Left_Right
  add menu search
  Add Menu NAME "В~иправлення" ;
  ITEMS {"Добавити <Ins>" ,"Виправити  <Ctrl>+<Enter>" ,"Занести <Enter>","Видалити <Delete>"} ;
  KEY {K_INS,K_CTRL_RET,K_ENTER,K_DEL}
  add menu print
  INIT menu
  m_browse:RowPos:=1;m_browse:ColPos:=1
  m_browse:configure()
//  DISPLAYLIST
  DISPBOX(m_browse:ntop-1 ,m_browse:nleft-1,m_browse:nbottom+1,m_browse:nRight+1, B_DOUBLE + " ","w/b")
  SET cursor Off
    IF INDEXORD()<>0
      m_len:=LEN(&(INDEXKEY(0)))
    ELSE
      m_len:=0
    ENDIF
   @m_browse:nbottom+1,m_browse:nleft+6 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
  DO WHILE .t.
    Display Browse m_browse
    m_key:=INKEY(0)
    Winsay
    DEAL MENU
    DO CASE
      CASE m_key==K_ESC
        EXIT;m_ret:=.f.
      DEAL BROWSE m_browse KEY m_key
      PRINT BROWSE m_browse KEY m_key
      SCAN  BROWSE m_browse KEY m_key
      SEEK  BROWSE m_browse KEY m_key
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
      CASE m_Key == K_DEL                                    /* удаление записи */
         IF l_delete.OR.( ANSWERu( "Ви дiйсно бажаєте видалити картку ?" )==YES )
          IF NetRLOCK();dbdelete();dbUNLOCK()
          ELSE;DispErr("Файл заблоковано");ENDIF
          DBSKIP(-1);DBSKIP(1);m_browse:RefreshAll()
         ENDIF
        CASE m_key == K_ALT_1
          IF INDEXORD()<>1
            SET ORDER TO 1
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+6 SayDisp REPlicate("═",m_len) COLOR "GR+/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+6 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
        CASE m_key == K_ALT_0
          IF INDEXORD()<>0
            SET ORDER TO 0
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
          @m_browse:nbottom+1,m_browse:nleft+11 SayDisp REPlicate("═",m_len) COLOR "w/b"
          m_len:=0
          m_value:=""
          ENDIF
        CASE m_key == K_ALT_2
          IF INDEXORD()<>2.AND..NOT.EMPTY(INDEXKEY(2))
            SET ORDER TO 2
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+6 SayDisp REPlicate("═",m_len) COLOR "w/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+6 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
        CASE m_key == K_ALT_3
          IF INDEXORD()<>3.AND..NOT.EMPTY(INDEXKEY(3))
            SET ORDER TO 3
            m_browse:rowPos:=1;m_browse:configure()
            m_browse:refreshCurrent()
            m_browse:refreshAll()
            @m_browse:nbottom+1,m_browse:nleft+6 SayDisp REPlicate("═",m_len) COLOR "w/b"
            m_len:=LEN(&(INDEXKEY(0)))
            @m_browse:nbottom+1,m_browse:nleft+6 SayDisp REPlicate("▒",m_len) COLOR "GR+/b"
            m_value:=""
          ENDIF
    CASE m_key==K_ENTER
      IF a_par==NIL
      IF mode==NIL
        oCurGet:VarPut(Firm01->Okpo)
        oCurGet:UpdateBuffer()
      ELSE
        oCurGet:VarPut(Firm01->kodnds)
        oCurGet:UpdateBuffer()
      ENDIF

      SET CURSOR ON
      m_ret:=.t.
      exit
    ELSE
        FOR i:=1 TO LEN(a_par)
          IF firm01->(FIELDNUM(a_par[i]))<>0
            AADD(a_firm,firm01->(FIELDGET(FIELDNUM(a_par[i]))))
          ENDIF
        NEXT
        m_ret:=.t.
        EXIT
    ENDIF
    CASE m_key==K_CTRL_RET
      WSELECT(n_win1)
      IF INDEXORD()<>0;c_key:=&(INDEXKEY(0));ELSE;c_key:="";ENDIF
      n_pole:=1
      INIT DATA a_data FROM a_get KEY n_pole
      Display Get a_get KEY n_pole SAY a_say DATA a_data
      n_pole:=1
      set escape on
      SET CURSOR OFF
          DO WHILE .t.
            DEAL GET a_get KEY n_pole TO m_key COLOR TOKEN(m_browse:colorSpec,",",2),TOKEN(a_get[n_pole]:ColorSpec,",",1) SAY a_say DATA a_data
            DO CASE
              WORK GET a_get KEY m_key BY n_pole  SAY a_say DATA a_data
            ENDCASE
          ENDDO
      Wselect(n_win)
      IF INDEXORD()<>0;IF c_key<>&(INDEXKEY(0));m_browse:refreshAll()
      ELSE;m_browse:refreshCurrent();END;END
    CASE m_key==K_INS
      set escape on
      WSELECT(n_win1)
      l_stop:=.t.
      m_valid:=a_get[1]:postBlock
      IF a_get[1]:postBlock<>NIL
        a_get[1]:postBlock:={|x|IF(EMPTY(EVAL(x:block)),.t.,EVAL(m_valid,x))}
      ENDIF
      DO WHILE l_stop
        n_pole:=1
        INIT DATA a_data FROM a_get KEY n_pole BLANK
        Display Get a_get KEY n_pole SAY a_say DATA a_data
        TAKE GET a_get KEY n_pole SAY a_say DATA a_data
        IF LASTKEY()==K_ESC.OR..NOT.l_stop
          EXIT
        ENDIF
        dbUnlock()
      ENDDO
      a_get[1]:postBlock:=m_valid
      Wselect(n_win)
      m_browse:refreshAll()
    CASE m_key==K_BS.AND.LEN(m_value)>0
        @m_browse:nbottom+1,m_browse:nleft+5+LEN(m_value) SayDisp "▒" COLOR "GR+/b"
        m_value:=SUBSTR(m_value,1,LEN(m_value)-1)
    CASE m_len<>0.AND.LEN(m_value)<m_len.AND.m_key>=32
        m_rec:=RECNO()
        IF DBSEEK(m_value+UPPER(CHR(m_key)),.t.)
        m_browse:rowPos:=1;m_browse:configure()
        m_browse:refreshCurrent()
        m_rec:=RECNO()
        m_browse:refreshAll()
        m_value+=UPPER(CHR(m_key))
        @m_browse:nbottom+1,m_browse:nleft+5+LEN(m_value) SayDisp CHR(m_key) COLOR "GR+/b"
      ELSE
        DBGOTO(m_rec)
        BeepErr()
      ENDIF
   FINISH LIST
   WCLOSE(n_win);WCLOSE(n_win1)
   SET ORDER TO n_order
   savePar(1)
RETURN m_ret
Function bank01(a_data,a_num,a_par,a_get)
  LOCAL a_mass:={},l,i:=0
  IF bank01->(DBSEEK(a_data[a_num[1]]))
       i:=0;AEVAL(a_par,{|x|i++,a_data[a_num[i]]:=FIELDGET(FIELDNUM(x))})
    RETURN .t.
  ENDIF
  l:=vl_sp("BANK01",,@a_mass,a_par)
  IF l
    AEVAL(a_num,{|x|i++,a_data[x]:=a_mass[i]})
  ENDIF
RETURN l
