// #define     BEEP_ERR    TONE(125,0.5);tone(300,0.5);tone(125,0.5)
#translate @ <nRow>, <nCol> SayDisp <exp> [PICTURE <cSayPicture>] [COLOR <cColor>] ;
=>;
           SETPOS( <nRow>, <nCol> );;
           DISPOUT( TRANSFORM( <exp>, <cSayPicture> ),<cColor>)

/***
*	Getsys.prg
*	Standard Clipper 5.0 GET/READ subsystem
*	Copyright (c) 1990, 1991 Nantucket Corp.  All rights reserved.
*
*	NOTE: compile with /m/n/w
*/

#include "Set.ch"
#include "Inkey.ch"
#include "Getexit.ch"

#define K_UNDO          K_ALT_U


// state variables for active READ
static Format
static Updated := .f.
static KillRead
static BumpTop
static BumpBot
static LastExit
static LastPos
static ActiveGet
static ReadProcName
static ReadProcLine
STATIC Locale :="EN"
Static MyLastKey:=0
// display coordinates for SCOREBOARD
STATIC SCORE_ROW :=  0
STATIC SCORE_COL :=  4
STATIC SCORE_MODE:= .t.
// format of array used to preserve state variables
#define GSV_KILLREAD		1
#define GSV_BUMPTOP			2
#define GSV_BUMPBOT			3
#define GSV_LASTEXIT		4
#define GSV_LASTPOS			5
#define GSV_ACTIVEGET		6
#define GSV_READVAR 		7
#define GSV_READPROCNAME	8
#define GSV_READPROCLINE	9

#define GSV_COUNT			9



/***
*	ReadModal()
*	Standard modal READ on an array of GETs.
*/
func ReadMy( GetList , a_func_block ,m_mode)

local get,n_mode:=IF(m_mode==NIL,0,m_mode)
local pos
local savedGetSysVars
Local m_scr1:=""
IF(READINSERT(),SETCURSOR(12,15,.t.),SETCURSOR(15))

	if ( ValType(Format) == "B" )
		Eval(Format)
	end

	if ( Empty(getList) )
		// S87 compat.
        SetPos( MaxRow()-1, 0 )
		return (.f.)			// NOTE
	end


	// preserve state vars
	savedGetSysVars := ClearGetSysVars()

	// set these for use in SET KEYs
	ReadProcName := ProcName(1)
	ReadProcLine := ProcLine(1)

	// set initial GET to be read
	pos := Settle( Getlist, 0 )
  IF SCORE_MODE
    m_scr1:=SAVESCREEN(SCORE_ROW,MAXCOL()-SCORE_COL,SCORE_ROW,MAXCOL()-SCORE_COL+3)
  ENDIF
	while ( pos <> 0 )

		// get next GET from list and post it as the active GET
		get := GetList[pos]
    IF EMPTY(get:ColorSpec)
      get:ColorSpec:="GR+/N,W/b"
    ENDIF
    ShowScoreboard()
		PostActiveGet( get )


		// read the GET
		if ( ValType( get:reader ) == "B" )
			Eval( get:reader, get ) 		// use custom reader block
		else
      IF (get:picture<>NIL.AND.AT("9'",get:picture)<>0).OR.n_mode==1
        ReadSum(get,a_func_block)
      ELSE
        GetReader( get , a_func_block )        // use standard reader
      ENDIF
		end


		// move to next GET based on exit condition
		pos := Settle( GetList, pos )

	end


	// restore state vars
	RestoreGetSysVars(savedGetSysVars)

	// S87 compat.
    SetPos( MaxRow()-1, 0 )
SET CURSOR OFF
  IF SCORE_MODE
    RESTSCREEN(SCORE_ROW,MAXCOL()-SCORE_COL,SCORE_ROW,MAXCOL()-SCORE_COL+3,m_scr1)
  ENDIF
return (Updated)



/***
*	GetReader()
*	Standard modal read of a single GET.
*/
func ReadModal( GetList )

local get
local pos
local savedGetSysVars
Local m_scr1:=""
IF(READINSERT(),SETCURSOR(12,15,.t.),SETCURSOR(15))


	if ( ValType(Format) == "B" )
		Eval(Format)
	end

	if ( Empty(getList) )
		// S87 compat.
        SetPos( MaxRow()-1, 0 )
		return (.f.)			// NOTE
	end


	// preserve state vars
	savedGetSysVars := ClearGetSysVars()

	// set these for use in SET KEYs
	ReadProcName := ProcName(1)
	ReadProcLine := ProcLine(1)


	// set initial GET to be read
	pos := Settle( Getlist, 0 )
  IF SCORE_MODE
    m_scr1:=SAVESCREEN(SCORE_ROW,MAXCOL()-SCORE_COL,SCORE_ROW,MAXCOL()-SCORE_COL+3)
  ENDIF

	while ( pos <> 0 )

		// get next GET from list and post it as the active GET
		get := GetList[pos]
    IF EMPTY(get:ColorSpec)
      get:ColorSpec:="GR+/N,W/b"
    ENDIF
		PostActiveGet( get )


		// read the GET
    if ( ValType( get:reader ) == "B" )
			Eval( get:reader, get ) 		// use custom reader block
		else
      IF get:picture<>NIL.AND.AT("9'",get:picture)<>0
        ReadSum(get)
      ELSE
        GetReader( get )        // use standard reader
      ENDIF
		end


		// move to next GET based on exit condition
		pos := Settle( GetList, pos )

	end


	// restore state vars
	RestoreGetSysVars(savedGetSysVars)

	// S87 compat.
    SetPos( MaxRow()-1, 0 )
SET CURSOR OFF
  IF SCORE_MODE
    RESTSCREEN(SCORE_ROW,MAXCOL()-SCORE_COL,SCORE_ROW,MAXCOL()-SCORE_COL+3,m_scr1)
  ENDIF
return (Updated)


proc GetReader( get , a_func_block)


	// read the GET if the WHEN condition is satisfied
	if ( GetPreValidate(get) )

		// activate the GET for reading
		get:SetFocus()

		while ( get:exitState == GE_NOEXIT )

			// check for initial typeout (no editable positions)
			if ( get:typeOut )
				get:exitState := GE_ENTER
			end

			// apply keystrokes until exit
			while ( get:exitState == GE_NOEXIT )
				GetApplyKey( get, Inkey(0), a_func_block )
			end

			// disallow exit if the VALID condition is not satisfied
			if ( !GetPostValidate(get) )
				get:exitState := GE_NOEXIT
        BeepErr()
			end

		end

		// de-activate the GET
		get:KillFocus()

	end

return



/***
*	GetApplyKey()
*	Apply a single Inkey() keystroke to a GET.
*
*	NOTE: GET must have focus.
*/
proc GetApplyKey(get, key, a_func_block)

local cKey,n_row,n_col,l0
local bKeyBlock


	// check for SET KEY first
	if ( (bKeyBlock := SetKey(key)) <> NIL )

		GetDoSetKey(bKeyBlock, get)
		return									// NOTE

	end
  IF upper(VALTYPE(a_func_block))=="A"
    AEVAL(a_func_block,;
    {|x|IF(x[1]==key,;
     IF(VALTYPE(x[2])=="B",EVAL({|x|n_row:=ROW(),n_col:=COL(),;
        EVAL(x[2]),SETPOS(n_row,n_col),key:=0,get:Assign(),get:display()},x);
      ,PutStr(get,x[2],@key)),NIL)})
  ENDIF


	do case
  case ( key == K_UP ) .OR. ((key == K_LEFT).AND.get:pos==1)
		get:exitState := GE_UP

	case ( key == K_SH_TAB )
		get:exitState := GE_UP

  case ( key == K_DOWN ) .OR. ((key == K_RIGHT).and.get:pos==len(get:buffer))
		get:exitState := GE_DOWN

	case ( key == K_TAB )
		get:exitState := GE_DOWN

	case ( key == K_ENTER )
		get:exitState := GE_ENTER

	case ( key == K_ESC )
		if ( Set(_SET_ESCAPE) )
			get:undo()
			get:exitState := GE_ESCAPE
		end

	case ( key == K_PGUP )
		get:exitState := GE_WRITE

	case ( key == K_PGDN )
		get:exitState := GE_WRITE

	case ( key == K_CTRL_HOME )
		get:exitState := GE_TOP


#ifdef CTRL_END_SPECIAL

	// both ^W and ^End go to the last GET
	case (key == K_CTRL_END)
		get:exitState := GE_BOTTOM

#else

	// both ^W and ^End terminate the READ (the default)
  case (key == K_CTRL_W) .OR. key == -41
		get:exitState := GE_WRITE

#endif


	case (key == K_INS)
//    Set( _SET_INSERT, !Set(_SET_INSERT) )
      IF READINSERT()
        READINSERT(.f.);SETCURSOR(15)
      ELSE
        READINSERT(.t.);SETCURSOR(12,15,.t.)
      ENDIF
    ShowScoreboard()
 CASE (key ==K_ALT_F1)
    Locale="EN"
    ShowScoreboard()
 CASE (key ==K_SH_F1)
    Locale="RU"
    ShowScoreboard()
 CASE (key ==K_CTRL_F1)
    Locale="UA"
    ShowScoreboard()
  case (key == 418)
       SCORE_MODE:=.NOT.SCORE_MODE
	case (key == K_UNDO)
		get:Undo()

	case (key == K_HOME)
		get:Home()

	case (key == K_END)
		get:End()

	case (key == K_RIGHT)
		get:Right()
  case (key == K_LEFT)
      get:Left()
	case (key == K_CTRL_RIGHT)
		get:WordRight()

	case (key == K_CTRL_LEFT)
		get:WordLeft()

	case (key == K_BS)
		get:BackSpace()

	case (key == K_DEL)
		get:Delete()

	case (key == K_CTRL_T)
		get:DelWordRight()

	case (key == K_CTRL_Y)
		get:DelEnd()

	case (key == K_CTRL_BS)
		get:DelWordLeft()

	otherwise
      DO CASE
        CASE key==380
          key:=37
        CASE key==379
          key:=252
      ENDCASE

    if (key >= 32 .and. key <= 255) .or. key == 21
			cKey := Chr(key)
      IF Locale == "UA".AND.key>=33.AND.key<=126
         l0=AT(ckey,"`qwertyuiop[]asdfghjkl;'zxcvbnm,./")
         IF l0<>0
             cKey:=SUBSTR("Û©Ê„™•≠£ËÈßÂ˘‰®¢†Ø‡Æ´§¶ıÔÁ·¨i‚Ï°Ó/",l0,1)
         ELSE
           l0=AT(ckey,'~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?')
           IF l0<>0
              cKey:=SUBSTR("ÚâñìäÖçÉòôáï¯îàÇÄèêéãÑÜÙüóëåIíúÅû?",l0,1)
           ENDIF
         ENDIF
      ELSE
        IF Locale == "RU".AND.key>=33.AND.key<=126
         l0=AT(ckey,"`qwertyuiop[]asdfghjkl;'zxcvbnm,./")
         IF l0<>0
             cKey:=SUBSTR("Ò©Ê„™•≠£ËÈßÂÍ‰Î¢†Ø‡Æ´§¶ÌÔÁ·¨®‚Ï°Ó/",l0,1)
         ELSE
           l0=AT(ckey,'~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?')
           IF l0<>0
              cKey:=SUBSTR("âñìäÖçÉòôáïöîõÇÄèêéãÑÜùüóëåàíúÅû?",l0,1)
           ENDIF
         ENDIF
        ENDIF
      ENDIF

			if (get:type == "N" .and. (cKey == "." .or. cKey == ","))
				get:ToDecPos()

			else
        IF get:typeOut
          TONE(125,0.5);TONE(100,0.5)
        ENDIF
        IF cKey=="?".AND.get:PostBlock<>NIL
            if ( Set(_SET_INSERT) )
              get:Insert(cKey)
            else
              get:Overstrike(cKey)
            end
            get:Assign()
            IF Eval(get:postBlock, get)
              get:exitState := GE_ENTER
              return
            ENDIF
            ckey:=""
        ELSE
          IF cKey==" ".AND.get:type=="D"
            get:buffer:=DTOC(CTOD(""))
            cKey:=""
            get:changed:=.t.
            get:Display()
//            get:exitState := GE_WRITE
          ELSE
            if ( Set(_SET_INSERT) )
              get:Insert(cKey)
            else
              get:Overstrike(cKey)
            end
          ENDIF
        ENDIF

        if (get:typeOut .and. !Set(_SET_CONFIRM) )
					if ( Set(_SET_BELL) )
						?? Chr(7)
          end

					get:exitState := GE_ENTER
				end

			end

		end

	endcase

return



/***
*	GetPreValidate()
*	Test entry condition (WHEN clause) for a GET.
*/
func GetPreValidate(get)

local saveUpdated
local when := .t.


	if ( get:preBlock <> NIL )

		saveUpdated := Updated

		when := Eval(get:preBlock, get)

		get:Display()

		ShowScoreBoard()
		Updated := saveUpdated

	end


	if ( KillRead )
		when := .f.
		get:exitState := GE_ESCAPE		// provokes ReadModal() exit

	elseif ( !when )
		get:exitState := GE_WHEN		// indicates failure

	else
		get:exitState := GE_NOEXIT		// prepares for editing

	end

return (when)



/***
*	GetPostValidate()
*	Test exit condition (VALID clause) for a GET.
*
*	NOTE: bad dates are rejected in such a way as to preserve edit buffer.
*/
func GetPostValidate(get)

local saveUpdated
local changed, valid := .t.


	if ( get:exitState == GE_ESCAPE )
		return (.t.)					// NOTE
	end

	if ( get:BadDate() )
		get:Home()
		DateMsg()
		ShowScoreboard()
		return (.f.)					// NOTE
	end


	// if editing occurred, assign the new value to the variable
	if ( get:changed )
		get:Assign()
		Updated := .t.
	end


	// reform edit buffer, set cursor to home position, redisplay
	get:Reset()


	// check VALID condition if specified
	if ( get:postBlock <> NIL )

		saveUpdated := Updated

		// S87 compat.
        SetPos( get:row, get:col + Len(get:buffer) )

		valid := Eval(get:postBlock, get)

		// reset compat. pos
		SetPos( get:row, get:col )

		ShowScoreBoard()
		get:UpdateBuffer()

		Updated := saveUpdated

		if ( KillRead )
			get:exitState := GE_ESCAPE	// provokes ReadModal() exit
			valid := .t.
		end

	end

return (valid)




/***
*	GetDoSetKey()
*	Process SET KEY during editing.
*/
proc GetDoSetKey(keyBlock, get)

local saveUpdated


	// if editing has occurred, assign variable
	if ( get:changed )
		get:Assign()
		Updated := .t.
	end


	saveUpdated := Updated

	Eval(keyBlock, ReadProcName, ReadProcLine, ReadVar())

	ShowScoreboard()
	get:UpdateBuffer()

	Updated := saveUpdated


	if ( KillRead )
		get:exitState := GE_ESCAPE		// provokes ReadModal() exit
	end

return



/**************************
*
*	READ services
*
*/



/***
*	Settle()
*
*	Returns new position in array of Get objects, based on
*
*		- current position
*		- exitState of Get object at current position
*
*	NOTE return value of 0 indicates termination of READ
*	NOTE exitState of old Get is transferred to new Get
*/
static func Settle(GetList, pos)

local exitState


	if ( pos == 0 )
		exitState := GE_DOWN
	else
		exitState := GetList[pos]:exitState
	end


	if ( exitState == GE_ESCAPE .or. exitState == GE_WRITE )
		return ( 0 )					// NOTE
	end


	if ( exitState <> GE_WHEN )
		// reset state info
		LastPos := pos
		BumpTop := .f.
		BumpBot := .f.

	else
		// re-use last exitState, do not disturb state info
		exitState := LastExit

	end


	/***
	*	move
	*/
	do case
	case ( exitState == GE_UP )
		pos --

	case ( exitState == GE_DOWN )
		pos ++

	case ( exitState == GE_TOP )
		pos := 1
		BumpTop := .T.
		exitState := GE_DOWN

	case ( exitState == GE_BOTTOM )
		pos := Len(GetList)
		BumpBot := .T.
		exitState := GE_UP

	case ( exitState == GE_ENTER )
		pos ++

	endcase


	/***
	*	bounce
	*/
	if ( pos == 0 ) 						// bumped top

		if ( !ReadExit() .and. !BumpBot )
			BumpTop := .T.
			pos := LastPos
			exitState := GE_DOWN
		end

	elseif ( pos == Len(GetList) + 1 )		// bumped bottom

		if ( !ReadExit() .and. exitState <> GE_ENTER .and. !BumpTop )
			BumpBot := .T.
			pos := LastPos
			exitState := GE_UP
		else
			pos := 0
		end
	end


	// record exit state
	LastExit := exitState

	if ( pos <> 0 )
		GetList[pos]:exitState := exitState
	end

return (pos)



/***
*	PostActiveGet()
*	Post active GET for ReadVar(), GetActive().
*/
static proc PostActiveGet(get)

	GetActive( get )
	ReadVar( GetReadVar(get) )

	ShowScoreBoard()

return



/***
*	ClearGetSysVars()
*	Save and clear READ state variables. Return array of saved values.
*
*	NOTE: 'Updated' status is cleared but not saved (S87 compat.).
*/
static func ClearGetSysVars()

local saved[ GSV_COUNT ]


	saved[ GSV_KILLREAD ] := KillRead
	KillRead := .f.

	saved[ GSV_BUMPTOP ] := BumpTop
	BumpTop := .f.

	saved[ GSV_BUMPBOT ] := BumpBot
	BumpBot := .f.

	saved[ GSV_LASTEXIT ] := LastExit
	LastExit := 0

	saved[ GSV_LASTPOS ] := LastPos
	LastPos := 0

	saved[ GSV_ACTIVEGET ] := GetActive( NIL )

	saved[ GSV_READVAR ] := ReadVar( "" )

	saved[ GSV_READPROCNAME ] := ReadProcName
	ReadProcName := ""

	saved[ GSV_READPROCLINE ] := ReadProcLine
	ReadProcLine := 0

	Updated := .f.

return (saved)



/***
*   RestoreGetSysVars()
*	Restore READ state variables from array of saved values.
*
*	NOTE: 'Updated' status is not restored (S87 compat.).
*/
static proc RestoreGetSysVars(saved)

	KillRead := saved[ GSV_KILLREAD ]

	BumpTop := saved[ GSV_BUMPTOP ]

	BumpBot := saved[ GSV_BUMPBOT ]

	LastExit := saved[ GSV_LASTEXIT ]

	LastPos := saved[ GSV_LASTPOS ]

	GetActive( saved[ GSV_ACTIVEGET ] )

	ReadVar( saved[ GSV_READVAR ] )

	ReadProcName := saved[ GSV_READPROCNAME ]

	ReadProcLine := saved[ GSV_READPROCLINE ]

return



/***
*	GetReadVar()
*	Set READVAR() value from a GET.
*/
static func GetReadVar(get)

local name := Upper(get:name)


//#ifdef SUBSCRIPT_IN_READVAR
local i

	/***
	*	The following code includes subscripts in the name returned by
	*	this function, if the get variable is an array element.
	*
	*	Subscripts are retrieved from the get:subscript instance variable.
	*
	*	NOTE: incompatible with Summer 87
	*/

	if ( get:subscript <> NIL )
		for i := 1 to len(get:subscript)
			name += "[" + ltrim(str(get:subscript[i])) + "]"
		next
	end

//#endif

return (name)



/**********************
*
*	system services
*
*/



/***
*   __SetFormat()
*	SET FORMAT service
*/
func __SetFormat(b)
	Format := if ( ValType(b) == "B", b, NIL )
return (NIL)


/***
*	__KillRead()
*   CLEAR GETS service
*/
proc __KillRead()
	KillRead := .t.
return


/***
*	GetActive()
*/
func GetActive(g)
local oldActive := ActiveGet
	if ( PCount() > 0 )
		ActiveGet := g
	end
return ( oldActive )


/***
*	Updated()
*/
func Updated()
return (Updated)


/***
*	ReadExit()
*/
func ReadExit(lNew)
return ( Set(_SET_EXIT, lNew) )


/***
*	ReadInsert()
*/
func ReadInsert(lNew)
return ( Set(_SET_INSERT, lNew) )



/**********************************
*
*	wacky compatibility services
*
*/




/***
*   ShowScoreboard()
*/
static proc ShowScoreboard()

local nRow, nCol


    if SCORE_MODE
        nRow := Row()
        nCol := Col()

    SetPos(SCORE_ROW, MAXCOL()-SCORE_COL)
    IF Set(_SET_INSERT)
       DispOut( "Ç·‚","GR+/B")
    ELSE
       DispOut( "á†¨","n/W")
    ENDIF
       DispOut(Locale,IF(Locale=="EN","GR+/B",IF(locale="RU","n/w","b/w")))
        SetPos(nRow, nCol)
	end

return



/***
*	DateMsg()
*/
static proc DateMsg()

local nRow, nCol


    if ( Set(_SET_SCOREBOARD) )
		nRow := Row()
		nCol := Col()

    SetPos(SCORE_ROW, MAXCOL()-SCORE_COL)
		DispOut("Invalid Date")
        SetPos(nRow, nCol)

		while ( Nextkey() == 0 )
		end

    SetPos(SCORE_ROW, MAXCOL()-SCORE_COL)
		DispOut("            ")
        SetPos(nRow, nCol)

	end

return



/***
*   RangeCheck()
*
*	NOTE: unused second param for 5.00 compatibility.
*/

func RangeCheck(get, junk, lo, hi)

local cMsg, nRow, nCol
local xValue


	if ( !get:changed )
		return (.t.)
	end

	xValue := get:VarGet()

	if ( xValue >= lo .and. xValue <= hi )
		return (.t.)									// NOTE
	end

    if ( Set(_SET_SCOREBOARD) )
		cMsg := "Range: " + Ltrim(Transform(lo, "")) + ;
				" - " + Ltrim(Transform(hi, ""))

		if ( Len(cMsg) > MaxCol() )
			cMsg := Substr( cMsg, 1, MaxCol() )
		end

		nRow := Row()
		nCol := Col()

		SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
		DispOut(cMsg)
        SetPos(nRow, nCol)

		while ( NextKey() == 0 )
		end

		SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
		DispOut( Space(Len(cMsg)) )
        SetPos(nRow, nCol)

	end

return (.f.)
STATIC FUNCTION putstr(get,str,key)
LOCAL i:=1,n:=LEN(str)
FOR i:=1 TO n
 IF Substr(str,i,1)<>"~"
        if ( Set(_SET_INSERT) )
          get:Insert(SUBSTR(str,i,1))
				else
          get:Overstrike(SUBSTR(str,i,1))
				end
 ENDIF
NEXT
key:=0
RETURN .t.
FUnction SetScorePos(nRow,nCol,nMode)
SCORE_ROW :=  nRow
SCORE_COL :=  nCol
SCORE_MODE :=  nMode
RETURN .t.


Function ReadSum(m_get,a_func_block)
LOCAL i:=0,m_clr2:=IF(EMPTY(m_get:colorSpec),"GR+/N",TOKEN(m_get:colorSpec,",",1)),;
m_clr1:=IF(EMPTY(m_get:colorSpec),"GR+/N",TOKEN(m_get:colorSpec,",",2)),n_dec:=0
LOCAL m_key,c_buf:="",m_registr:=EVAL(m_get:block),bKeyBlock,x
LOCAL l_dec:=.f.,m_len:=16,m_dec,m_koef,l_znak:=IF(m_registr<0,.f.,.t.)
local m_cursor:=SETCURSOR(0)

IF .NOT.EMPTY(m_get:picture)
  m_dec:=IF((i:=RAT(".",m_get:picture))<>0,LEN(m_get:picture)-i,0)
  m_len:=IF((i:=AT("9",m_get:picture))<>0,LEN(m_get:picture)-i+1,16)
ENDIF
c_buf:=NumToStr(m_registr,m_len,m_dec)
IF (i:=AT(".",c_buf))<>0
  m_koef:=10**(i-LEN(c_buf)-1);n_dec:=LEN(c_buf)-i
  l_dec:=.t.
ELSE
  l_dec:=.f.
ENDIF


	// read the GET if the WHEN condition is satisfied
  if ( GetPreValidate(m_get) )

		// activate the GET for reading
    m_get:SetFocus()

    while ( m_get:exitState == GE_NOEXIT )

			// check for initial typeout (no editable positions)
      if ( m_get:typeOut )
        m_get:exitState := GE_ENTER
			end

			// apply keystrokes until exit
      while ( m_get:exitState == GE_NOEXIT )
//        GetApplyKey( get, Inkey(0), a_func_block )
        DO WHILE ( m_get:exitState == GE_NOEXIT )
          @m_get:row,m_get:col SayDisp c_buf COLOR m_clr1
          m_key:=INKEY(0)
          // check for SET KEY first
          if ( (bKeyBlock := SetKey(m_key)) <> NIL )

            GetDoSetKey(bKeyBlock, m_get)
            LOOP                 // NOTE

          end
          IF upper(VALTYPE(a_func_block))=="A"
            AEVAL(a_func_block,;
            {|x|IF(x[1]==m_key,;
             IF(VALTYPE(x[2])=="B",EVAL({|x|SaveCur(),EVAL(x[2]),RestCur()},x[2]),NIL);
              ,NIL)})
          ENDIF


          do case
            case (m_key >=ASC("0").and. m_key <= ASC("9"))
              x:=m_key-ASC("0")
              IF .NOT.l_dec
                IF Len(LTRIM(c_buf))<m_len
                  m_registr:=m_registr*10+IF(l_znak,x,-x)
                  c_buf:=NumToStr(m_registr,m_len,0)
                ELSE
                  BeepErr()
                ENDIF
              ELSE
                IF LEN(LTRIM(c_buf))<m_len.AND.(m_dec==NIL.OR.n_dec<m_dec)
                  m_registr:=m_registr+IF(l_znak,x*m_koef,-x*m_koef)
                  m_koef:=m_koef*0.1
                  n_dec++
                  c_buf:=SUBSTR(c_buf,2)+CHR(m_key)
                ELSE
                  BeepErr()
                ENDIF
              ENDIF
          case ( m_key == K_UP )
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_UP

          case ( m_key == K_SH_TAB )
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_UP

          case ( m_key == K_DOWN )
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_DOWN

          case ( m_key == K_TAB )
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_DOWN

          case ( m_key == K_ENTER )
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_ENTER

          case ( m_key == K_ESC )
            if ( Set(_SET_ESCAPE) )
              m_get:exitState := GE_ESCAPE
            end

          case ( m_key == K_PGUP )
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_WRITE

          case ( m_key == K_PGDN )
            m_get:exitState := GE_WRITE

          case ( m_key == K_CTRL_HOME )
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_TOP


        #ifdef CTRL_END_SPECIAL

          // both ^W and ^End go to the last GET
          case (m_key == K_CTRL_END)
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_BOTTOM

        #else

          // both ^W and ^End terminate the READ (the default)
          case (m_key == K_CTRL_W) .OR. m_key == -41
            EVAL(m_get:Block,m_registr)
            m_get:exitState := GE_WRITE

        #endif


         CASE m_key==ASC(".").AND.(m_dec==NIL.OR.m_dec>0).AND..NOT.l_dec.AND.SUBSTR(c_buf,1,1)==" "
              l_dec:=.t.;c_buf:=SUBSTR(c_buf,2)+".";m_koef:=0.1;n_dec:=0
          case (m_key == K_BS)
              IF .NOT.l_dec
                m_registr:=Int(m_registr*0.1)
                c_buf:=NumToStr(m_registr,m_len,0)
              ELSE
                IF RIGHT(c_buf,1)=="."
                  c_buf:=" "+SUBSTR(c_buf,1,LEN(c_buf)-1)
                  l_dec:=.f.
                ELSE
                  m_koef:=m_koef*10;n_dec--
                  c_buf:=" "+SUBSTR(c_buf,1,LEN(c_buf)-1)
                  m_registr:=VAL(CHARREM(" '",c_buf))
                ENDIF
              ENDIF
            CASE m_key==ASC(" ")
              m_registr:=0;l_dec:=.f.;c_buf:=NumToStr(m_registr,m_len,0)
            CASE m_key==ASC("-")
              IF l_znak.AND.LEFT(c_buf,1)==" ".OR.;
                (.NOT.l_znak.AND.(LEFT(c_buf,1)==" ".OR.LEFT(c_buf,1)==" "))
                IF l_znak
                  m_registr:=-m_registr
                  l_znak:=.f.
                  c_buf:=PADL("-"+LTRIM(c_buf),m_len)
                ELSE
                  m_registr:=-m_registr;l_znak:=.t.
                  c_buf:=PADL(SUBSTR(LTRIM(c_buf),2),m_len)
                ENDIF
              ELSE
                BeepErr()
              ENDIF
          OTHERWISE
                BeepErr()
          ENDCASE
        ENDDO
			end

			// disallow exit if the VALID condition is not satisfied
      if ( !GetPostValidate(m_get) )
        m_get:exitState := GE_NOEXIT
        BeepErr()
			end

		end

		// de-activate the GET
    m_get:KillFocus()
    @m_get:row,m_get:col SayDisp NumToStr(EVAL(m_get:block),m_len,m_dec) COLOR m_clr2

	end

  SETCURSOR(m_cursor)
RETURN .t.

