#include "new.ch"
MEMVAR a_menu,m_mainpath,m_sprpath,m_workpath,m_syspath,l_sov
Function Work04
  LOCAL GetList:={},k_pod1,k_pod2,m_sum
  LOCAL m_gauge,m_codn,n,k_zan,k_pen1,k_pen2,k_strah1,k_strah2,k_strah3
  LOCAL s_ud,predelPod,x_pod


 IF ANSWERu("���㢠� ��i� ?")==YES
    SAVEPAR()
/*
set printer to "f1.lst"
set printer on
*/
    NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
    k_pod1  :=RESTVAR1("k_pod1","ZR")
    k_pod2  :=RESTVAR1("k_pod2","ZR")
k_zan   :=RESTVAR1("k_zan","ZR")
k_pen1  :=RESTVAR1("k_pen1","ZR")
k_pen2  :=RESTVAR1("k_pen2","ZR")
k_strah1  :=RESTVAR1("k_strah1","ZR")
k_strah2  :=RESTVAR1("k_strah2","ZR")
k_strah3  :=RESTVAR1("k_strah3","ZR")
//x_pod   :=RESTVAR1("x_pod","ZR")
x_pod:=680

    CLOSE myvar
    s_ud:=k_zan+","+k_pen1+","+k_pen2+","+k_strah1+","+k_strah2+","+k_strah3+","
    USE (m_workpath+"podohod") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin TO (m_workpath+"kvart")
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("���iઠ ����� ",2)
  DO WHILE .NOT.flish->(EOF())
      Sp08->(DS(flish->kopu))
      Sp10->(DS(flish->tabn))
      m_codn:=IF(EMPTY(Sp10->codn),PADR(sp10->tabn,10),Sp10->codn)
      IF Sp08->p01<>" ".AND.Sp08->p01<>"0"
        fl1->(DS(m_codn))
        IF .NOT.fl1->(FOUND())
          fl1->(DBAP())
          fl1->tabn:=sp10->tabn
          fl1->tin:=m_codn
          IF sp10->(FOUND())
            fl1->kpn:=sp10->kpn
            fl1->kmn:=sp10->kmn
            fl1->fio:=ALLTRIM(sp10->fam)+" "+LEFT(sp10->imja,1)+"."+LEFT(sp10->otch,1)+"."
            fl1->sumPod:=sp10->sumPod
          ENDIF
        ENDIF
        n:=fl1->(FIELDPOS("sum"+flish->month))
        fl1->(FIELDPUT(n,fl1->(FIELDGET(n))+flish->sum))
        fl1->sumAll+=flish->sum
      ENDIF

    IF (flish->kopu==k_pod1.OR.flish->kopu==k_pod2)
        fl1->(DS(m_codn))
        IF .NOT.fl1->(FOUND())
          fl1->(DBAP())
          fl1->tabn:=sp10->tabn
          fl1->tin:=m_codn
          IF sp10->(FOUND())
            fl1->kpn:=sp10->kpn
            fl1->kmn:=sp10->kmn
            fl1->fio:=ALLTRIM(sp10->fam)+" "+LEFT(sp10->imja,1)+"."+LEFT(sp10->otch,1)+"."
            fl1->sumPod:=sp10->sumPod
          ENDIF
        ENDIF
        m_sum:=flish->sum
        n:=fl1->(FIELDPOS("pod"+flish->month))
        flish->(DBSKIP())
        IF (flish->kopu=="901".OR. flish->kopu="902")
          fl1->(FIELDPUT(n,fl1->(FIELDGET(n))+m_sum))
          fl1->podAll+=m_sum
        ENDIF
    ENDIF


    IF (flish->kopu=="043")
        fl1->(DS(m_codn))
        IF .NOT.fl1->(FOUND())
          fl1->(DBAP())
          fl1->tabn:=sp10->tabn
          fl1->tin:=m_codn
          IF sp10->(FOUND())
            fl1->kpn:=sp10->kpn
            fl1->kmn:=sp10->kmn
            fl1->fio:=ALLTRIM(sp10->fam)+" "+LEFT(sp10->imja,1)+"."+LEFT(sp10->otch,1)+"."
            fl1->sumPod:=sp10->sumPod
          ENDIF
        ENDIF
        m_sum:=flish->sum
        n:=fl1->(FIELDPOS("B"+flish->month))
        fl1->(FIELDPUT(n,fl1->(FIELDGET(n))+m_sum))
        flish->(DBSKIP())
    ENDIF



    IF (AT(flish->kopu,s_ud)<>0)
        fl1->(DS(m_codn))
        IF .NOT.fl1->(FOUND())
          fl1->(DBAP())
          fl1->tabn:=sp10->tabn
          fl1->tin:=m_codn
          IF sp10->(FOUND())
            fl1->kpn:=sp10->kpn
            fl1->kmn:=sp10->kmn
            fl1->fio:=ALLTRIM(sp10->fam)+" "+LEFT(sp10->imja,1)+"."+LEFT(sp10->otch,1)+"."
            fl1->sumPod:=sp10->sumPod
          ENDIF
        ENDIF
        m_sum:=flish->sum
        n:=fl1->(FIELDPOS("u"+flish->month))
        fl1->(FIELDPUT(n,fl1->(FIELDGET(n))+flish->sum))
    ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  SELECT fl1
  fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())

  predelPod:=x_pod
  IF VAL(fl1->kmn)>1
    predelPod:=x_pod*VAL(fl1->kmn)
  ENDIF
  IF (fl1->sum01>predelPod)
    fl1->ras01:=ROUND((fl1->sum01-fl1->u01)*0.13,2)
  ELSE
    fl1->ras01:=ROUND((fl1->sum01-fl1->u01-fl1->sumPod)*0.13,2)
    IF fl1->ras01<0
      fl1->ras01:=0
    ENDIF
  ENDIF
  IF (fl1->sum02>predelPod)
    fl1->ras02:=ROUND((fl1->sum02-fl1->u02)*0.13,2)
  ELSE
    fl1->ras02:=ROUND((fl1->sum02-fl1->u02-fl1->sumPod)*0.13,2)
    IF fl1->ras02<0
      fl1->ras02:=0
    ENDIF
  ENDIF
  IF (fl1->sum03>predelPod)
    fl1->ras03:=ROUND((fl1->sum03-fl1->u03)*0.13,2)
  ELSE
    fl1->ras03:=ROUND((fl1->sum03-fl1->u03-fl1->sumPod)*0.13,2)
    IF fl1->ras03<0
      fl1->ras03:=0
    ENDIF
  ENDIF
  IF (fl1->sum04>predelPod)
    fl1->ras04:=ROUND((fl1->sum04-fl1->u04)*0.13,2)
  ELSE
    fl1->ras04:=ROUND((fl1->sum04-fl1->u04-fl1->sumPod)*0.13,2)
    IF fl1->ras04<0
      fl1->ras04:=0
    ENDIF
  ENDIF
  IF (fl1->sum05>predelPod)
    fl1->ras05:=ROUND((fl1->sum05-fl1->u05)*0.13,2)
  ELSE
    fl1->ras05:=ROUND((fl1->sum05-fl1->u05-fl1->sumPod)*0.13,2)
    IF fl1->ras05<0
      fl1->ras05:=0
    ENDIF
  ENDIF
  IF (fl1->sum06>predelPod)
    fl1->ras06:=ROUND((fl1->sum06-fl1->u06)*0.13,2)
  ELSE
    fl1->ras06:=ROUND((fl1->sum06-fl1->u06-fl1->sumPod)*0.13,2)
    IF fl1->ras06<0
      fl1->ras06:=0
    ENDIF
  ENDIF
  IF (fl1->sum07>predelPod)
    fl1->ras07:=ROUND((fl1->sum07-fl1->u07)*0.13,2)
  ELSE
    fl1->ras07:=ROUND((fl1->sum07-fl1->u07-fl1->sumPod)*0.13,2)
    IF fl1->ras07<0
      fl1->ras07:=0
    ENDIF
  ENDIF
  IF (fl1->sum08>predelPod)
    fl1->ras08:=ROUND((fl1->sum08-fl1->u08)*0.13,2)
  ELSE
    fl1->ras08:=ROUND((fl1->sum08-fl1->u08-fl1->sumPod)*0.13,2)
    IF fl1->ras08<0
      fl1->ras08:=0
    ENDIF
  ENDIF
  IF (fl1->sum09>predelPod)
    fl1->ras09:=ROUND((fl1->sum09-fl1->u09)*0.13,2)
  ELSE
    fl1->ras09:=ROUND((fl1->sum09-fl1->u09-fl1->sumPod)*0.13,2)
    IF fl1->ras09<0
      fl1->ras09:=0
    ENDIF
  ENDIF
  IF (fl1->sum10>predelPod)
    fl1->ras10:=ROUND((fl1->sum10-fl1->u10)*0.13,2)
  ELSE
    fl1->ras10:=ROUND((fl1->sum10-fl1->u10-fl1->sumPod)*0.13,2)
    IF fl1->ras10<0
      fl1->ras10:=0
    ENDIF
  ENDIF
  IF (fl1->sum11>predelPod)
    fl1->ras11:=ROUND((fl1->sum11-fl1->u11)*0.13,2)
  ELSE
    fl1->ras11:=ROUND((fl1->sum11-fl1->u11-fl1->sumPod)*0.13,2)
    IF fl1->ras11<0
      fl1->ras11:=0
    ENDIF
  ENDIF
  IF (fl1->sum12>predelPod)
    fl1->ras12:=ROUND((fl1->sum12-fl1->u12)*0.13,2)
  ELSE
    fl1->ras12:=ROUND((fl1->sum12-fl1->u12-fl1->sumPod)*0.13,2)
    IF fl1->ras12<0
      fl1->ras12:=0
    ENDIF
  ENDIF
fl1->rasAll:=fl1->ras01+fl1->ras02+fl1->ras03+fl1->ras04+fl1->ras05+fl1->ras06+fl1->ras07+fl1->ras08+fl1->ras09+fl1->ras10+fl1->ras11+fl1->ras12
    fl1->(DBSKIP())
  ENDDO
  CLOSE base fl1,sp10,sp08
  SAVEPAR(1)
 ENDIF
  RETURN .t.

