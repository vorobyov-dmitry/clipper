#include "new.ch"
FUNCTION T1
  LOCAL m_gauge,GetList:={}
  set dele on
  set date british
  setblink(.f.)
  CLEAR
  SET PRINTER TO "t101.txt"
  SET PRINTER ON
  USE d:\buh\plat\nakl1 NEW
  DO WHILE .NOT.nakl1->(EOF())
    IF nakl1->ddoc>=CTOD("01/02/98").AND.nakl1->ddoc<CTOD("01/03/98").AND.;
      .NOT.ISBIT(ASC(nakl1->state),1).AND.nakl1->kod1=="3".AND..not.IsBit(ASC(nakl1->state),3)
       ?nakl1->ndoc,nakl1->ddoc,nakl1->(recno())
    ENDIF
    nakl1->(DBSKIP())
  ENDDO
  CLOSE nakl1
  SET PRINTER OFF
  SET PRINTER TO
RETURN .t.
