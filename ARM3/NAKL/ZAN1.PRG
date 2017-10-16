#include "new.ch"
memvar m_bufpath,m_mainpath,m_temppath,M_syspath
Function zan1
  LOCAL m_mol:="05",k_nds:="52",m_ddoc1,m_ddoc2
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
   SET CENTURY       OFF
   SET DATE          BRITISH
   PUBLIC   m_bufpath   := ''
   PUBLIC   m_mainpath  := ''
   PUBLIC   m_syspath   := ''
   PUBLIC   m_temppath  := ''
  m_ddoc1:=CTOD("01/09/98")
  m_ddoc2:=CTOD("30/09/98")
  USE PROV
  Zanes02(m_mol,k_nds,m_ddoc1,m_ddoc2)

RETURN .t.

STATIC Function Zanes02(m_mol,k_nds,m_ddoc1,m_ddoc2)
LOCAL m_npch:=700+VAL(m_mol),l_first:=.T.,;
m_gauge,m_kod,l1
  USE (m_bufpath+"funnum") NEW
  USE (m_bufpath+"fdbcr") NEW
  USE (m_bufpath+"fglv") NEW
  USE (m_syspath+"fvnum") NEW ALIAS fv
  DO WHILE .NOT. funnum->(EOF())
    IF funnum->oper=="N2".AND.funnum->ddoc>=m_ddoc1.AND.funnum->ddoc<=m_ddoc2.AND.m_npch==funnum->npch
      IF l_first
        IF ANSWERu("База вже мiстить проводки за отриману продукцiю;Удаляти цi документи?")<>YES
           EXIT
        ENDIF
        l_first:=.f.
      ENDIF
     IF ( funnum->vdoc >= 200 .AND. funnum->vdoc <= 299 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
       IF PfilPoz1('fUNNUM',{||(funnum->vnum==fdbcr->vnum)},'fdbcr')
          fglv->(DBDELETE())
       ENDIF
      ENDIF
     IF ( funnum->vdoc >= 100 .AND. funnum->vdoc <= 199 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
       IF PfilPoz1('fUNNUM',{||(funnum->vnum==fkvo2->vnum)},'fkvo2')
          fkvo2->(DBDELETE())
       ENDIF
      ENDIF
      IF pFilPoz1('funnum', {||(funnum->vnum==fdbcr->vnum)} , 'fdbcr')
        DO WHILE .NOT. fdbcr->(EOF()).AND.funnum->vnum==fdbcr->vnum
          fdbcr->(DBDELETE())
          fdbcr->(DBSKIP())
        ENDDO
      ENDIF
      funnum->(DBDELETE())
    ENDIF
    funnum->(DBSKIP())
  ENDDO
  Prov->(DBSETFILTER({||(prov->kopr<>k_nds)},"prov->kopr<>k_nds"))
  Prov->(DBGOTOP())
  m_kod:=SPACE(30);l1:=.t.
  m_gauge:=InitGauge("Занесення даних",2)
  DO WHILE .NOT.Prov->(EOF())
    IF m_kod<>prov->ndoc+prov->kopr+prov->brgd+prov->otp+prov->kplh.OR.l1
      m_kod:=prov->ndoc+prov->kopr+prov->brgd+prov->otp+prov->kplh
      l1:=.f.
      funnum->(DBAPPEND())
      funnum->npch:=m_npch
      funnum->ndoc:=VAL(prov->Ndoc)
      funnum->vnum:=fv->vnum++
      funnum->kopr:=prov->kopr
      funnum->otp :=prov->otp
      funnum->kplh:=prov->kplh
      funnum->brgd:=prov->brgd
      funnum->ddoc:=prov->ddoc
      funnum->oper:="N2"
    ENDIF
    fdbcr->(DBAPPEND())
    fdbcr->cod1:=prov->cod1
    fdbcr->cod2:=prov->cod2
    fdbcr->dbt:=prov->dbt
    fdbcr->crt:=prov->crt
    fdbcr->kvo:=prov->kvo
    fdbcr->stm:=prov->stm
    fdbcr->vnum:=funnum->vnum
    funnum->vdoc:=61
    DO CASE
      CASE prov->glv<>0.AND.(LEFT(prov->crt,2)<>"06".and.LEFT(prov->dbt,2)<>"06")
        l1:=.t.
        funnum->vdoc:=261
        fglv->(DBAP())
        fglv->vnum:=funnum->vnum
        fglv->glv:=prov->glv
      CASE prov->glv<>0
    ENDCASE
    Prov->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,prov->(RECNO()/LASTREC()/2))
  ENDDO
  SELECT prov
  SET FILTER TO prov->kopr==k_nds
  Prov->(DBGOTOP())
  l1:=.t.
  DO WHILE .NOT.Prov->(EOF())
    IF l1
      funnum->(DBAPPEND())
      funnum->npch:=m_npch
      funnum->ndoc:=1
      funnum->vnum:=fv->vnum++
      funnum->kopr:=prov->kopr
      funnum->otp :=prov->otp
      funnum->kplh:=prov->kplh
      funnum->brgd:=prov->brgd
      funnum->ddoc:=prov->ddoc
      funnum->oper:="N2"
      l1:=.f.
      funnum->vdoc:=61
    ENDIF
    fdbcr->(DBAPPEND())
    fdbcr->dbt:=prov->dbt
    fdbcr->cod1:=prov->cod1
    fdbcr->cod2:=prov->cod2
    fdbcr->crt:=prov->crt
    fdbcr->kvo:=prov->kvo
    fdbcr->stm:=prov->stm
    fdbcr->vnum:=funnum->vnum
    fdbcr->ndoc:=prov->ndoc
    Prov->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,0.5+prov->(RECNO()/LASTREC()/2))
  ENDDO
CLOSE Base funnum,fv,fdbcr,fglv
RETURN .t.
