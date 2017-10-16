#include "new.ch"
Function FormFl(var1,var2)
LOCAL m_sprpath:=IF(var2==NIL,"D:\buhgal\sp\",var2)
LOCAL m_year:="2001",m_gauge,m_month,i,m_kod,m_year1

Public m_mainpath:=IF(var1==NIL,"D:\buhgal\mn\",var1)
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
  USE (m_mainpath+"flish") NEW READONLY
  USE (m_sprpath+"SP08") INDEX  (m_sprpath+"SP08") NEW  READONLY
Formfl01()
close all
RETURN .t.
STATIC FUNCTION Formfl01()
LOCAL m_year,m_year1,m_proc2,m_month,i,m_kod
  USE (m_mainpath+"fvnum.dbr") NEW
  m_year1:=fvnum->year
  CLOSE fvnum
m_proc2:=InitGauge("Формування файла довiдки")
  FERASE(m_mainpath+"fl01.dbf")
  FERASE(m_mainpath+"fl01.ntx")
  FILECOPY(m_mainpath+"fl02.dbf",m_mainpath+"fl01.dbf")
  FILECOPY(m_mainpath+"fl02.ntx",m_mainpath+"fl01.ntx")
USE (m_mainpath+"fl01") NEW
fl01->(DBGOTOP())
DO WHILE .NOT.fl01->(EOF())
IF fl01->year==m_year1
fl01->OTDN01:=0
fl01->OTHS01:=0
fl01->Sum001:=0
fl01->OTDN02:=0
fl01->OTHS02:=0
fl01->Sum002:=0
fl01->OTDN03:=0
fl01->OTHS03:=0
fl01->Sum003:=0
fl01->OTDN04:=0
fl01->OTHS04:=0
fl01->Sum004:=0
fl01->OTDN05:=0
fl01->OTHS05:=0
fl01->Sum005:=0
fl01->OTDN06:=0
fl01->OTHS06:=0
fl01->Sum006:=0
fl01->OTDN07:=0
fl01->OTHS07:=0
fl01->Sum007:=0
fl01->OTDN08:=0
fl01->OTHS08:=0
fl01->Sum008:=0
fl01->OTDN09:=0
fl01->OTHS09:=0
fl01->Sum009:=0
fl01->OTDN10:=0
fl01->OTHS10:=0
fl01->Sum010:=0
fl01->OTDN11:=0
fl01->OTHS11:=0
fl01->Sum011:=0
fl01->OTDN12:=0
fl01->OTHS12:=0
fl01->Sum012:=0
ENDIF

  fl01->(DBSKIP())
  m_proc2:=DispGauge(m_proc2,fl01->(RECNO()/lastrec()))
ENDDO
INDEX ON fl01->year+fl01->tabn+fl01->kopu TO (m_mainpath+"fl01")
fl01->(DBGOTOP())

// USE (m_mainpath+"flish") NEW
flish->(DBGOTOP())
DO WHILE .NOT.flish->(EOF())
If (flish->month>="01".AND.flish->month<="12")
    Sp08->(DS(flish->kopu))
    IF EMPTY(flish->mnt)
      m_year:=m_year1
    ELSE
      m_year:=mnt_syear(flish->mnt)
    ENDIF
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
    ENDIF
  flish->(DBSKIP())
  m_proc2:=DispGauge(m_proc2,flish->(RECNO()/lastrec()))
ENDDO
CLOSE fl01
RETURN .T.
