#include "new.ch"

Function testsp10
  SET DATE format "dd.mm.yyyy"
USE  "C:\ARM3\1df\soft\DB\physpe~1" ALIAS p10 NEW
ZAP
use "d:\buhgal\sp\sp10" NEW
SET DELE ON
  DO WHILE .NOT.sp10->(EOF())
    IF .NOT.EMPTY(sp10->codn)
    p10->(DBAP())
    p10->code:=VAL(sp10->tabn)
    p10->name:=dostowin(ALLTRIM(sp10->fam)+" "+ALLTRIM(sp10->imja)+" "+ALLTRIM(sp10->otch))
    p10->num:=sp10->codn
    p10->birthdate:=TRANSFORM(sp10->drog,"@D")
    ENDIF
    sp10->(DBSKIP())
  ENDDO


CLOSE sp10
CLOSE p10
return .t.
