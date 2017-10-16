#include "new.ch"
Function serv01
  LOCAL m_mainpath:="d:\buhgal\mn\",m_temppath:="d:\buhgal\temp\",;
  m_platpath:="d:\buh\plat\",m_gauge,m_sch:=""

  SET DELE ON
  SetBlink(.f.)
  Set DATE BRITISH
  USE (m_temppath+"buf") NEW
  buf->(__DbZap())
  USE (m_mainpath+"fdbcr") NEW READONLY
  USE (m_mainpath+"fglv") NEW READONLY
  USE (m_mainpath+"funnum") NEW READONLY
  USE (m_mainpath+"fkvo2") NEW READONLY
  USE (m_platPath+"kaptka1") NEW
  m_gauge:=InitGauge("Просмотр карточек")
  DO WHILE .NOT.kaptka1->(EOF())
    IF ASCAN(m_sch,LEFT(kaptka1->ksash,2)+"," )==0
      m_sch+=LEFT(kaptka1->ksash,2)+","
    ENDIF
    kaptka1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,kaptka1->(RECNO())/kaptka1->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  m_gauge:=InitGauge("Просмотр проводок")
  DO WHILE .NOT.fdbcr->(EOF())
    IF ASCAN(m_sch,LEFT(fdbcr->dbt,2)+",")<>0.OR.ASCAN(m_sch,LEFT(fdbcr->crt,2)+",")
      IF PfilPoz1('FDBCR',{||(funnum->vnum==fdbcr->vnum)},'funnum')
        IF ASCAN(m_sch,LEFT(fdbcr->dbt,2)+",")<>0
          IF .NOT.buf->(DS(fdbcr->dbt))
            buf->(DBAPPEND())
            buf->ksash:=fdbcr->dbt
          ENDIF
          buf->stm+=fdbcr->stm
          buf->kvo+=IF(fuunum->vdoc<>51,fdbcr->kvo,0)
          IF ( funnum->vdoc >= 200 .AND. funnum->vdoc <= 299 ) .OR.;
              ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
            IF PfilPoz1('FUNNUM',{||(funnum->vnum==fglv->vnum)},'fglv')
              buf->glv+=fglv->glv
            ENDIF
          ENDIF
          IF ( funnum->vdoc >= 100 .AND. funnum->vdoc <= 199 ) .OR.;
            ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
            IF PfilPoz1('fUNNUM',{||(funnum->vnum==fkvo2->vnum)},'fkvo2')
              buf->kvo2+=fkvo2->kvo2
            ENDIF
          ENDIF
        ENDIF
        IF ASCAN(m_sch,LEFT(fdbcr->crt,2)+",")<>0
          IF .NOT.buf->(DS(fdbcr->crt))
            buf->(DBAPPEND())
            buf->ksash:=fdbcr->crt
          ENDIF
          buf->stm-=fdbcr->stm
          buf->kvo-=IF(fuunum->vdoc<>51,fdbcr->kvo,0)
          IF ( funnum->vdoc >= 200 .AND. funnum->vdoc <= 299 ) .OR.;
            ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
            IF PfilPoz1('FUNNUM',{||(funnum->vnum==fglv->vnum)},'fglv')
              buf->glv-=fglv->glv
            ENDIF
          ENDIF
          IF ( funnum->vdoc >= 100 .AND. funnum->vdoc <= 199 ) .OR.;
              ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
            IF PfilPoz1('fUNNUM',{||(funnum->vnum==fkvo2->vnum)},'fkvo2')
              buf->kvo2-=fkvo2->kvo2
            ENDIF
          ENDIF
        ENDIF
      ENDIF
    ENDIF
    fdbcr->(DBSKIP())
    m_gauge:=DipsGauge(m_gauge,fdbcr->(RECNO())/funnum->(LASTREC()))
  ENDDO
  m_gauge:=DipsGauge(m_gauge,1)
RETURN .t.





FUNCTION Pfilpoz1(file1,b_block,file2)
  LOCAL m_recno:=(file2)->(RECNO())
  DO WHILE .NOT.(file2)->(EOF())
    IF EVAL(b_block)
      RETURN .t.
    ENDIF
    (file2)->(DBSKIP())
  ENDDO
  (file2)->(DBGOTO(m_recno))
RETURN .f.

