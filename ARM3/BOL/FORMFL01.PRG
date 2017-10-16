#include "new.ch"
Function FormFl01(var1,var2)
LOCAL m_mainpath:=IF(var1==NIL,"D:\buhgal\mn\",var1)
LOCAL m_sprpath:=IF(var2==NIL,"D:\buhgal\sp\",var2)
LOCAL m_year:="2001",m_gauge,m_month,i,m_kod,m_year1
   SetCursor (0)
   SETBLINK(.f.)

   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   SET EPOCH TO 1960
  SET DELE ON
  USE (m_mainpath+"fvnum.dbr")
  m_year1:=fvnum->year
  CLOSE fvnum
  USE (m_mainpath+"flish") NEW READONLY
  USE (m_sprpath+"SP08") INDEX  (m_sprpath+"SP08") NEW
  USE (m_mainpath+"fl01") NEW
  ZAP
  APPEND FROM (m_mainpath+"fl00")
  INDEX ON fl01->year+fl01->tabn+fl01->kopu TO (m_mainpath+"fl01")
  m_gauge:=INITGAUGE("FL01")
  DO WHILE .NOT.flish->(EOF())
    IF EMPTY(flish->mnt)
      m_year:=m_year1
    ELSE
      m_year:=IF(LEFT(flish->mnt,1)=="0","20","19")+LEFT(flish->mnt,2)
    ENDIF
/*
    IF .NOT.Fl01->(DS(m_year+flish->tabn+flish->kopu))
      Fl01->(DBAP())
      fl01->year:=m_year
      fl01->tabn:=flish->tabn
      fl01->kopu:=flish->kopu
    ENDIF
    IF EMPTY(flish->mnt)
      m_month:=flish->month
    ELSE
      m_month:=RIGHT(flish->mnt,2)
    ENDIF
    i:=Fl01->(FIELDNUM("OTDN"+m_month))
    Fl01->(FIELDPUT(i,FIELDGET(i)+flish->otdn))
    i:=Fl01->(FIELDNUM("OTHS"+m_month))
    Fl01->(FIELDPUT(i,FIELDGET(i)+flish->oths))
    i:=Fl01->(FIELDNUM("SUM0"+m_month))
    Fl01->(FIELDPUT(i,FIELDGET(i)+flish->sum))
*/
    Sp08->(DS(flish->kopu))
    IF Sp08->p15=="1"
      IF .NOT.Fl01->(DS(m_year+flish->tabn+"911"))
        Fl01->(DBAP())
        fl01->year:=m_year
        fl01->tabn:=flish->tabn
        fl01->kopu:="911"
      ENDIF
      IF EMPTY(flish->mnt)
        m_month:=flish->month
      ELSE
        m_month:=RIGHT(flish->mnt,2)
      ENDIF
      i:=Fl01->(FIELDNUM("OTDN"+m_month))
      Fl01->(FIELDPUT(i,FIELDGET(i)+flish->otdn))
      i:=Fl01->(FIELDNUM("OTHS"+m_month))
      Fl01->(FIELDPUT(i,FIELDGET(i)+flish->oths))
      i:=Fl01->(FIELDNUM("SUM0"+m_month))
      Fl01->(FIELDPUT(i,FIELDGET(i)+flish->sum))
    ENDIF
    IF Sp08->p09=="1".OR.Sp08->p09=="2".OR.Sp08->p09=="3".OR.Sp08->p09=="4"
      DO CASE
        CASE Sp08->p09=="1"
          m_kod:='914'
        CASE Sp08->p09=="2"
          m_kod:='915'
        CASE Sp08->p09=="3"
          m_kod:='916'
        CASE Sp08->p09=="4"
          m_kod:='917'
      ENDCASE

      IF .NOT.Fl01->(DS(m_year+flish->tabn+m_kod))
        Fl01->(DBAP())
        fl01->year:=m_year
        fl01->tabn:=flish->tabn
        fl01->kopu:=m_kod
      ENDIF
      IF EMPTY(flish->mnt)
        m_month:=flish->month
      ELSE
        m_month:=RIGHT(flish->mnt,2)
      ENDIF
      i:=Fl01->(FIELDNUM("OTDN"+m_month))
      Fl01->(FIELDPUT(i,FIELDGET(i)+flish->otdn))
      i:=Fl01->(FIELDNUM("OTHS"+m_month))
      Fl01->(FIELDPUT(i,FIELDGET(i)+flish->oths))
      i:=Fl01->(FIELDNUM("SUM0"+m_month))
      Fl01->(FIELDPUT(i,FIELDGET(i)+flish->sum))
    ENDIF

    m_gauge:=DispGauge(m_gauge,flish->(RECNO()/LASTREC()))
    flish->(DBSKIP())
  ENDDO
close all
RETURN .t.
