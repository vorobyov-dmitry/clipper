FUNCTION Conv1(VAR)
LOCAL m_path:=IF(var==NIL,"D:\buhgal\mn\",var),l_exit:=.f.,getlist:={}
clear
set dele on
USE (m_path+"funnum") NEW
USE (m_path+"fkvo2") NEW
USE (m_path+"fglv") NEW
USE (m_path+"fdbcr") NEW

  DO WHILE ( funnum->( !EOF() ) )
IF funnum->vdoc>=100.AND.Pfilpoz("fdbcr","vnum","funnum")
     IF ( funnum->vdoc >= 200 .AND. funnum->vdoc <= 299 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
            IF Pfilpoz("fglv","vnum","funnum")
                 fdbcr->glv:=fglv->glv
                 fglv->(DBDELETE())
                 ?funnum->npch,funnum->ndoc,funnum->ddoc
            ENDIF
     ENDIF
     IF ( funnum->vdoc >= 100 .AND. funnum->vdoc <= 199 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
         IF Pfilpoz("fkvo2","vnum","funnum")
                 fdbcr->kvo2:=fkvo2->kvo2
                 fkvo2->(DBDELETE())
                 ?funnum->npch,funnum->ndoc,funnum->ddoc
         ENDIF
     ENDIF
     funnum->vdoc:=50
ENDIF
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
