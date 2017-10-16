#include "new.ch"
Function zan
use buf1 new
use flish new
INDEX ON flish->month+flish->tabn+flish->kopu TO buf4
SET DELE ON
DO WHILE .NOT.buf1->(EOF())
  IF flish->(DS(buf1->month+buf1->tabn+buf1->kopu))
    Flish->otdn:=buf1->otdn
    Flish->oths:=buf1->oths
  ELSE
    DispError("Ž¬¨«ª  !!! "+buf1->month+buf1->tabn+buf1->kopu)
  ENDIF
  buf1->(DBSKIP())
ENDDO
CLOSE ALL
RETURN .t.
