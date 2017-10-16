#include "new.ch"
#include "ACHOICE.ch"
#include "pass.ch"
MEMVAR m_platpath
Function pervnum(m_platpath)
LOCAL m_vnum:=1,m_gauge,n_file3,i

KSETCAPS(.f.)
KSETNUM(.t.)
SETBLINK(.F.)
SETSHARE(4)
SetCancel ( .f. )
SetCursor ( 0 )
setblink(.f.)
VGAPALETTE(6,32,32,32)
Set ( _SET_ESCAPE     , .t. )
Set ( _SET_SCOREBOARD , .f. )
Set ( _SET_BELL       , .f. )
Set ( _SET_DECIMALS   ,  7  )
Set ( _SET_DELETED    , .t. )
Set ( _SET_CONFIRM    , .t. )
SetShare(4)
SET CENTURY       OFF
SET DATE          BRITISH
SET EPOCH TO 1960
   

USE (m_platpath+"nakl1") NEW  READONLY
COPY to ("nakl1.dbf") FOR YEAR(nakl1->ddoc)>=2011.AND.VAL(nakl1->vnum)>0 
USE ("perekod") NEW 
ZAP
INDEX ON field->v1 to ("perekod") UNIQUE 
select nakl1
Close nakl1
USE ("nakl1.dbf")
m_gauge:=InitGauge("Перекодировка nakl1",2)
DO WHILE .NOT.nakl1->(EOF())
	perekod->(dbappend())
	perekod->v1:=VAL(nakl1->vnum)
	perekod->v2:=m_vnum
	nakl1->vnum=STR(perekod->v2,6)
	m_vnum=m_vnum+1
	nakl1->(DBSKIP())
	m_gauge:=DispGauge(m_gauge,nakl1->(RECNO())/nakl1->(LASTREC()))
ENDDO
DelGauge(m_gauge)
CLOSE nakl1

USE (m_platpath+"nakl2") NEW  READONLY
COPY STRUCTURE TO ("nakl2a")
USE ("nakl2a") NEW  ALIAS n2
m_gauge:=InitGauge("Перекодировка nakl2",2)
DO WHILE .NOT.nakl2->(EOF())
	IF perekod->(dbseek(VAL(nakl2->vnum)))
		n2->(DBAPPEND())
		FOR i:=1 TO nakl2->(FCOUNT())
			n2->(FIELDPUT(i,nakl2->(FIELDGET(i))))
		NEXT
		n2->vnum=STR(perekod->v2,6)
	ENDIF
	nakl2->(DBSKIP())
	m_gauge:=DispGauge(m_gauge,nakl2->(RECNO())/nakl2->(LASTREC()))
ENDDO
DelGauge(m_gauge)
CLOSE nakl2
SELECT n2
INDEX ON field->vnum to ("nakl2")
CLOSE n2


USE (m_platpath+"nakl3") NEW  READONLY
COPY STRUCTURE TO ("nakl3a")
nakl3->(DBGOTO(117738))
USE ("nakl3a") NEW ALIAS n3
m_gauge:=InitGauge("Перекодировка nakl3",2)
DO WHILE .NOT.nakl3->(EOF())
	IF perekod->(dbseek(VAL(nakl3->vnum)))
		n3->(DBAPPEND())
		FOR i:=1 TO nakl3->(FCOUNT())
			n3->(FIELDPUT(i,nakl3->(FIELDGET(i))))
		NEXT
		n3->vnum=STR(perekod->v2,6)
	ENDIF
	nakl3->(DBSKIP())
	m_gauge:=DispGauge(m_gauge,nakl3->(RECNO())/nakl3->(LASTREC()))
ENDDO
DelGauge(m_gauge)
CLOSE nakl3
SELECT n3
INDEX ON field->vnum to ("nakl3")
CLOSE n3

USE ("nakl1")  new
INDEX ON (DTOS(field->ddoc)+field->ndoc) TO ("nakl1")
INDEX ON (field->ndoc+STR(99999999-VAL(dtos(field->ddoc)),8)) TO ("nakl1a")
INDEX ON (field->ndoc) TO ("nakl1b")
CLOSE nakl1
RETURN .t.

