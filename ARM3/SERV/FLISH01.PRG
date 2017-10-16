#include "new.ch"
 #include "pass.ch"
//#include "setcurs.ch"
Memvar a_menu,m_workpath,m_syspath
FUNCTION flish01 (var1,var2)

LOCAL m_time:=TIME(),getlist:={},i,l1,fname
IF var1==NIL
DispError("Директория  2006 НЕ определена")
RETURN .f.
ENDIF

IF var2==NIL
DispError("Директория 2007 не определена ")
RETURN .f.
ENDIF
IF .NOT. FILE(var1+"\flish.dbf")
  DispError("В директории  "+VAR2 + " НЕ НАЙДЕН ФАЙЛ FLISH")
ENDIF
IF .NOT. FILE(var2+"\flish.dbf")
  DispError("В директории  "+VAR2 + " НЕ НАЙДЕН ФАЙЛ FLISH")
ENDIF


   SetCancel ( .f. )
   SetCursor (0)
   SetBlink(.f.)

   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET EPOCH TO 1960
   READEXIT(.t.)

   SET CENTURY       OFF

   SET DATE format "DD.MM.YYYY"
use (var1+"\flish")
COPY TO fl20 FOR (flish->kopu="110".OR.flish->kopu="097").AND.flish->month="13"
USE
USE fl20
REPLACE month WITH "01" ALL
USE

l1=.F.
  fname=""
FOR i:=1 TO 10
  IF (.NOT.FILE(var2+"\flish"+STRZERO(i,2)+".dbf"))
    FRENAME(var2+"\flish.dbf",var2+"\flish"+STRZERO(i,2)+".dbf")
    fname=var2+"\flish"+STRZERO(i,2)+".dbf"
    ?"rename flish to ",FNAME
    l1=.t.
    EXIT
  ENDIF
NEXT
IF .not.L1
  DispError("НЕ УДАЛОСЬ СДЕЛАТЬ КОПИЮ ФАЙЛА")
  RETURN .F.
ENDIF
  filecopy("fl20.dbf",var2+"\flish.dbf")
  USE (var2+"\flish.dbf")
  append from (fname) for .NOT.(month=="01".AND.(kopu=='097'.OR.kopu=="110"))
  CLOSE ALL

RETURN .T.
