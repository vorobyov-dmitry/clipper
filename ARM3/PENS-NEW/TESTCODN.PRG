  LOCAL k:=0,GetList:={}
  SET DATE BRITISH
  SET DATE FORMAT "dd/mm/yyyy"
SET ESCAPE ON
CLEAR
DO WHILE .T.
  @10,10 GET K PICTURE "99999"
  READ
  IF LASTKEY()==27
    EXIT
  ENDIF
  @10,40 SAY CTOD("14/10/1964")-23663+k COLOR "gr+/B"
ENDDO
QUIT
