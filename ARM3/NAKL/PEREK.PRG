#include "new.ch"
STATIC Lapnd:=.f.
function perek(var)
  local m_browse,m_path:=IF(var==NIL,"",var),l_print:={}
  local m_col,m_key,l_delete:=.t.,GetList:={}
KSETCAPS(.f.)
KSETNUM(.t.)
SETBLINK(.F.)
SETSHARE(4)
   SetCancel ( .f. )
   SetCursor ( 0 )
   setblink(.f.)

   Set ( _SET_ESCAPE     , .t. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH

  NET USE (m_path+"kaptka1") INDEX (m_path+"kaptka1")
  @0,0,MAXROW(),MAXCOL() BOX B_DOUBLE+" " COLOR "w/b"
  m_browse               := TBrowseDB(1,1,MAXROW(),MAXCOL()-1)
  m_browse:colorspec     :='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_browse:SkipBlock     := { |n| SkipDb(n) }
  m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
  m_browse:goTopBlock    := { ||  DBGOTOP()  }
  m_Col           := TBColumnNew()
  m_col:block:=COLBR(field->kod)
  m_col:heading:="Š®¤"
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "ÂÄ"
  m_col:colsep:="³"
  m_col:footsep:="ÏÍ"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:heading:="®¢¨© ;ª®¤"
  m_col:block:=COLBR(field->kod1)
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "ÂÄ"
  m_col:colsep:="³"
  m_col:footsep:="ÏÍ"
  m_browse:addColumn(m_col)
  m_Col           := TBColumnNew()
  m_col:heading:=" §¢ "
  m_col:block:=COLBR(field->name)
  AADD(l_print,.T.)
  m_Col:colorblock:=  {|| {1,2}}
  m_Col:headsep    := "ÂÄ"
  m_col:colsep:="³"
  m_col:footsep:="ÏÍ"
  m_browse:addColumn(m_col)
  m_browse:ColPos:=2
  m_browse:freeze        := 1
  DO WHILE .t.
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{1,1})
    STABILIZE BROWSE m_browse
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{2,2})
    IF .NOT.Lapnd
    m_key:=INKEY(0)
    ENDIF
    DO CASE
        CASE m_key == K_ESC       ; EXIT
        CASE m_key == K_INS ;lApnd:=.t. ;m_key := 219
        CASE m_key == K_ENTER.OR.Lapnd
          STABILIZE BROWSE m_browse
          IF NetRlock()
            SET CURSOR ON
            @ROW(),COL() GeT field->kod1 COLOR "GR+/N"
            READ
            SET CURSOR OFF
            IF LASTKEY()==K_ESC
              Lapnd:=.f.
            ENDIF
            DBUnlock()
          ENDIF
        m_browse:refreshCurrent()
        IF Lapnd
           m_browse:down();m_browse:refreshCurrent()
        ENDIF
        CASE m_key == K_DOWN      ; m_browse:down();m_browse:refreshCurrent()
        CASE m_key == K_UP        ; m_browse:up();m_browse:refreshCurrent()
        CASE m_key == K_CTRL_PGUP ; m_browse:gotop();m_browse:refreshAll()
        CASE m_key == K_CTRL_PGDN ; m_browse:gobottom();m_browse:refreshAll()
        CASE m_key == K_PGUP      ; m_browse:pageUp();m_browse:refreshAll()
        CASE m_key == K_PGDN      ; m_browse:pageDown();m_browse:refreshAll()
        CASE m_key == K_F10       ; calcul()
        CASE m_key == K_ALT_F10       ; calc()
    ENDCASE
  ENDDO

 Return .t.
FUNCTION SkipDb(n)
    LOCAL  ncount  := 0
IF n > 0
   DO WHILE ncount < n
        DBSKIP()
       // …á«¨ ª®­¥æ ä ©« 
       IF  EOF()
          DBSKIP( -1 )
          Lapnd:=.f.
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
RETURN ( ncount )
