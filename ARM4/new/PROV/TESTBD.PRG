#INCLUDE "NEW.CH"
Function TestBd(var)
LOCAL m_gauge,m_path:=IF(var==NIL,"d:\buhgal\",var)
  SET DELE ON
//USE m_pathSPRAV\SP\SP07 NEW
  USE (m_path+"SP\SP44") NEW
  zap
  APPEND FROM (m_path+"SP\SP07")
  GOTO TOP
DO WHILE .NOT.EOF()
IF SUBSTR(SP44->KSASH,3,4)=="0000"
SP44->KSASH:=LEFT(SP44->KSASH,2)+"     "
ENDIF
IF substr(SP44->KSASH,4,3)=="000"
SP44->KSASH:=LEFT(SP44->KSASH,3)+"    "
ENDIF
SKIP
ENDDO

  INDEX ON sp44->KSASH TO (m_path+"SP\SP44")
  CLOSE SP44
  USE (m_path+"MN\FP1") NEW
  ZAP
  USE (m_path+"MN\FP2") NEW
  ZAP
  USE (m_path+"MN\FUNNUM") new
  USE (m_path+"MN\FDBCR")  new
  USE (m_path+"MN\ftabn") NEW READONLY
  USE (m_path+"MN\fgnavt") NEW READONLY
  USE (m_path+"MN\fntr") NEW READONLY
  m_gauge:=InitGauge("Конвертирование файлов")
do while .not.funnum->(eof())
   PfilPoz("fdbcr","vnum","funnum")
   IF funnum->vdoc==2  // ЛЗК водителей
      Pfilpoz("ftabn","vnum","funnum")
      Pfilpoz("fgnavt","vnum","funnum")
   ENDIF
   do while fdbcr->vnum == funnum->vnum.and..not.fdbcr->(eof())
      fp2->(DBAP())
      fp2->vnum:=STR(FDBCR->VNUM,7)
      fp2->dbt      :=   FDBCR->dbt
      fp2->crt      :=   FDBCR->crt
      fp2->cod1     :=   FDBCR->cod1
      fp2->cod2     :=   FDBCR->cod2
      fp2->kplh     :=   FUNNUM->kplh
      fp2->otp      :=   FUNNUM->otp
      fp2->brgd1    :=   FUNNUM->brgd
      fp2->brgd2    :=   FUNNUM->brgd
      fp2->kopr     :=   FUNNUM->kopr
      fp2->kvo      :=   FDBCR->kvo
      fp2->glv      :=   FDBCR->glv
      fp2->kvo2     :=   FDBCR->kvo2
      fp2->stm      :=   FDBCR->stm
      SKIP ALIAS fdbcr
   ENDDO
   fp1->(DBAP())
   fp1->ndoc :=  STR(funnum->ndoc ,6)
   fp1->npch :=  STR(funnum->npch,5)
   fp1->ddoc :=  funnum->ddoc
   fp1->mnt  :=  "01"+STRZERO(MONTH(funnum->ddoc),2)
   fp1->maket:=  RIGHT(str(funnum->vdoc,8),2)
   fp1->vnum:=fp2->vnum
   IF funnum->vdoc==1  // ЛЗК трактористов
      Pfilpoz("ftabn","vnum","funnum")
      Pfilpoz("fntr","vnum","funnum")
      Fp1->maket:="03"
      fp1->num:=fntr->invnum
      Fp1->tabn:= ftabn->tabn
   ENDIF
   IF funnum->vdoc==2  // ЛЗК водителей
      Pfilpoz("ftabn","vnum","funnum")
      Pfilpoz("fgnavt","vnum","funnum")
      Fp1->maket:="02"
      Fp1->num:=fgnavt->gnavt
      Fp1->tabn:= ftabn->tabn
   ENDIF

   SKIP ALIAS funnum
   m_gauge:=DispGauge(m_gauge,funnum->(RECNO()/LASTREC()))
ENDDO
DelGauge(m_gauge)
CLOSE funnum
CLOSE fdbcr
CLOSE ftabn
CLOSE fntr
CLOSE fGNaVT
RETURN .T.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION pFilPoz
PARAMETERS  m_nmfl_1, m_nmpl_1, m_nmfl_2

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
   ELSE
     GOTO m_fict_zap
     SELECT( m_fict_al )
     RETURN( .F. )
ENDIF
