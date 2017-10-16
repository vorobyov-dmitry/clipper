#include "new.ch"
#DEFINE COND1 (funnum->vdoc <> 51.OR.funnum->kopr=='05') .AND. funnum->kopr<>'00'
Function Kor06
LOCAL l
USE  ("funnum")  NEW
USE  ("fdbcr")  NEW
DO WHILE .NOT.fdbcr->(EOF())
  IF LEFT(fdbcr->dbt,2)=="06".OR. LEFT(fdbcr->crt,2)=="06"
    IF .NOT.Pfilpoz("funnum","vnum","fdbcr")
      l:=fdbcr->vnum
      DO WHILE fdbcr->vnum == l.and..NOT.fdbcr->(EOF())
         SKIP ALIAS fdbcr
      ENDDO
      LOOP
    ENDIF
    IF (funnum->Kplh=="63".OR.funnum->Kplh=="64").AND.LEFT(fdbcr->dbt,2)=="06"
       Fdbcr->dbt:="0640"+RIGHT(fdbcr->dbt,2)
    ENDIF
    IF (funnum->otp=="63".OR.funnum->otp=="64").AND.LEFT(fdbcr->crt,2)=="06"
       Fdbcr->crt:="0640"+RIGHT(fdbcr->crt,2)
    ENDIF
    IF LEFT(fdbcr->crt,4)=="0640".AND.(funnum->otp<>"63".AND.funnum->otp<>"64")
      fdbcr->crt:="0610"+RIGHT(fdbcr->crt,2)
    ENDIF
    IF LEFT(fdbcr->dbt,4)=="0640".AND.(funnum->kplh<>"63".AND.funnum->kplh<>"64")
      fdbcr->dbt:="0610"+RIGHT(fdbcr->dbt,2)
    ENDIF

  ENDIF
  SKIP ALIAS fdbcr
ENDDO
CLOSE BASE  fdbcr,funnum
RETURN .t.
FUNCTION   pFilPoz(m_nmfl_1, m_nmpl_1, m_nmfl_2)
  LOCAL  nSelect := SELECT(), nCurRec, lSucess := .F.
  LOCAL  nField1, cField2

SELECT(m_nmfl_1)

nCurRec := RECNO()
nField1 := FIELDPOS(m_nmpl_1)
cField2 := (m_nmfl_2) -> (FIELDGET( FIELDPOS(m_nmpl_1)))

DBEVAL( { || NIL },, { ||  FIELDGET(nField1) != cField2 },,, .T.)

 IF( ! EOF())
   lSucess := .T.
 ELSE
   DBGOTO(nCurRec)
 END

SELECT(nSelect)

RETURN(lSucess)

