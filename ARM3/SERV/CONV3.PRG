FUNCTION Conv2(VAR)
LOCAL m_path:=IF(var==NIL,"D:\buhgal\mn\",var),l_exit:=.f.,getlist:={}
clear
set dele on
USE (m_path+"funnum") NEW
USE (m_path+"fdbcr") NEW

  DO WHILE ( funnum->( !EOF() ) )
    IF funnum->kplh=="63".OR.funnum->kplh=="64".OR.;
       funnum->otp=="63".OR.funnum->otp=="64"
      IF Pfilpoz("fdbcr","vnum","funnum")
        DO WHILE fdbcr->vnum==funnum->vnum.and..not.fdbcr->(EOF())
            IF LEFT(fdbcr->dbt,4)=="0610".AND.;
              (funnum->kplh=="63".OR.funnum->kplh=="64")
              fdbcr->dbt:="0640"+RIGHT(fdbcr->dbt,2)
            ENDIF
            IF LEFT(fdbcr->crt,4)=="0610".AND.;
              (funnum->otp=="63".OR.funnum->otp=="64")
              fdbcr->crt:="0640"+RIGHT(fdbcr->crt,2)
            ENDIF
            fdbcr->(DBSKIP())
          ENDDO
      ENDIF
     ENDIF
     funnum->(DBSKIP())
     @10,10 say 100*funnum->(RECNO())/funnum->(LASTREC()) PICTURE "99.999"
  ENDDO
 CLOSE funnum
 CLOSE fdbcr
RETURN .T.
FUNCTION pFilPoz(m_nmfl_1, m_nmpl_1, m_nmfl_2)

LOCAL  m_fict_zap
LOCAL  m_fict_al
PRIVATE m_1
m_fict_al := SELECT()
SELECT (m_nmfl_1)
m_fict_zap :=  RECNO()
m_1 := ALLTRIM(m_nmfl_2) + '->' + ALLTRIM(m_nmpl_1)
LOCATE  REST  FOR  &(m_nmpl_1) == &(m_1)
IF  FOUND()
     SELECT( m_fict_al )
     RETURN( .T. )
ENDIF
     GOTO m_fict_zap
     SELECT( m_fict_al )
     RETURN( .F. )
