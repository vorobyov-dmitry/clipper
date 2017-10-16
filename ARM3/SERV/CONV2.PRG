FUNCTION Conv2(VAR)
LOCAL m_path:=IF(var==NIL,"D:\buhgal\mn\",var),l_exit:=.f.,getlist:={},m_kmtop
clear
set dele on
USE (m_path+"funnum") NEW
USE (m_path+"fkvo2") NEW
USE (m_path+"fglv") NEW
USE (m_path+"fdbcr") NEW

  DO WHILE ( funnum->( !EOF() ) )
  DO CASE
    CASE funnum->vdoc==1.OR.funnum->vdoc==2.OR.funnum->vdoc==3
      IF Pfilpoz("fdbcr","vnum","funnum")
        DO WHILE fdbcr->vnum==funnum->vnum.and..not.fdbcr->(EOF())
            IF LEFT(fdbcr->dbt,2)=="06".OR.LEFT(fdbcr->crt,2)=="06"
              fdbcr->kvo2:=fdbcr->kvo
            ENDIF
            fdbcr->(DBSKIP())
          ENDDO
      ENDIF
    CASE funnum->vdoc==51
      IF Pfilpoz("fdbcr","vnum","funnum")
        DO WHILE fdbcr->vnum==funnum->vnum.and..not.fdbcr->(EOF())
            IF LEFT(fdbcr->dbt,2)=="06".OR.LEFT(fdbcr->crt,2)=="06"
              fdbcr->kvo2:=fdbcr->kvo
            ENDIF
            fdbcr->(DBSKIP())
          ENDDO
      ENDIF
      ENDCASE
     funnum->(DBSKIP())
     @10,10 say 100*funnum->(RECNO())/funnum->(LASTREC()) PICTURE "99.999"
  ENDDO
 CLOSE funnum
 CLOSE fdbcr
 CLOSE fkvo2
 CLOSE fglv
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
