  LOCAL k:=0,GetList:={}
  SET DATE BRITISH
  SET DATE FORMAT "dd/mm/yyyy"
SET ESCAPE ON
CLEAR
use sp10

DO WHILE .not.eof()
	IF .NOT.EMPTY(sp10->codn)
		sp10->drog:=CTOD("14/10/1964")-23663+VAL(LEFT(sp10->codn,5))
	ENDIF
	skip
ENDDO
QUIT