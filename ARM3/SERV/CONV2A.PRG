FUNCTION Conv2(VAR)
LOCAL m_path:=IF(var==NIL,"D:\buhgal\mn\",var),l_exit:=.f.,getlist:={},m_kmtop
clear
set dele on
USE sp22 INDEX sp22 READONLY
USE (m_path+"funnum") NEW
USE (m_path+"fkvo2") NEW
USE (m_path+"fglv") NEW
USE (m_path+"fdbcr") NEW

  DO WHILE ( funnum->( !EOF() ) )
  DO CASE
    CASE funnum->vdoc==51
      IF Pfilpoz("fdbcr","vnum","funnum")
        DO WHILE fdbcr->vnum==funnum->vnum.and..not.fdbcr->(EOF())
            IF LEFT(fdbcr->dbt,2)=="06".OR.LEFT(fdbcr->crt,2)=="06"
              IF LEFT(fdbcr->dbt,2)=="06"
                m_kmtop:=RIGHT(fdbcr->dbt,2)
              ELSE
                m_kmtop:=RIGHT(fdbcr->crt,2)
              ENDIF
              sp22->(DBSEEK(STRZERO(MONTH(funnum->ddoc),2) + m_kmtop))
              IF sp22->koef<>0
                fdbcr->kvo2:=fdbcr->kvo / sp22->koef
              ENDIF
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
 CLOSE sp22
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
