#include "new.ch"
MEMVAR a_menu,m_mainpath,m_sprpath,m_workpath,m_syspath,l_sov
STATIC M_date1,M_date2
Function Work04
  LOCAL GetList:={},m_num:=a_menu[1],n,m_sum,i
  LOCAL m_month1,m_month2,m_koef,m_year,k_pod1,k_pod2
  LOCAL m_kod,m_kopu,m_str1,m_kod1,s_zan,m_gauge,m_078
  LOCAL m_codn,m_koef1,m_recno,m_s_tax1,m_s_dox1,m_s_101,m_st
  LOCAL m_kopu1,m_kopu2
  LOCAL s_month1,s_month2,s_month3,s_month

 IF ANSWERu("Формувати звiт; за "+m_num+" квартал")==YES
    SAVEPAR()
/*
set printer to "f1.lst"
set printer on
*/
    NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
    k_pod1  :=RESTVAR1("k_pod1","ZR")
    k_pod2  :=RESTVAR1("k_pod2","ZR")
    m_078   :=RESTVAR1("m_078","ZR")
    CLOSE myvar
// ?"m-o78===",m_078
    USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_kopu1:=ALLTRIM(RESTVAR1("m_kopu1","DR"))
    m_kopu2:=ALLTRIM(RESTVAR1("m_kopu2","DR"))
    CLOSE myvar
    CopyZag(m_num)
    DispMessage("Формування звiту; за "+m_num+" квартал")
    IF FILE(m_workpath+"kvart"+m_num+".dbf")
      FERASE(m_workpath+"kvart"+m_num+".dbf")
    ENDIF
    USE (m_workpath+"kvart") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin+STR(fl1->ozn_dox,2) TO (m_workpath+"kvart")
    USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_year:=PADR(RESTVAR1("m_year","DR"),4)
    CLOSE myvar
    DO CASE
      CASE m_num=="1"
        m_month1:=1;m_month2:=3
        m_date1:=CTOD("01/01/"+RIGHT(m_year,2));m_date2:=CTOD("31/03/"+RIGHT(m_year,2))
        s_month1=",1,2,3"
        s_month2=",1,2,3"
      CASE m_num=="2"
        m_month1:=4;m_month2:=6
        m_date1:=CTOD("01/04/"+RIGHT(m_year,2));m_date2:=CTOD("30/06/"+RIGHT(m_year,2))
        s_month1=",4,5,6"
        s_month2=",4,5,6"
      CASE m_num=="3"
        m_month1:=7;m_month2:=9
        m_date1:=CTOD("01/07/"+RIGHT(m_year,2));m_date2:=CTOD("30/09/"+RIGHT(m_year,2))
        s_month1=",7,8,9"
        s_month2=",7,8,9"
      CASE m_num=="4"
        m_month1:=10;m_month2:=12
        m_date1:=CTOD("01/10"+RIGHT(m_year,2));m_date2:=CTOD("32/12"+RIGHT(m_year,2))
        s_month1=",10,11,12"
        s_month2=",10,11,12"
ENDCASE
ReadMonths(@s_month1,@s_month2)
n:=NUMTOKEN(s_month2,",")
s_month3:=""
FOR i:=1 TO N
  s_month3+=ALLTRIM(STR(VAL(TOKEN(s_month2,",",i))-1,2))+","
NEXT
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка виплаченної зарплати ",2)
  DO WHILE .NOT.flish->(EOF())
    s_month=","+ALLTRIM(STR(VAL(flish->month),2))+","

// Выбираем начисленную зарплату

IF (AT(s_month,s_month1)<>0).AND.(flish->kopu<'100'.OR.(flish->kopu==k_pod1.OR.flish->kopu==k_pod2))
      Sp08->(DS(flish->kopu))
      Sp10->(DS(flish->tabn))
      IF .NOT.(Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2)
      IF Sp08->p14<>" ".AND.Sp08->p14<>"0"
          IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
            IF Sp08->p14=="2"
              m_kod:=" 1"
            ELSE
              m_kod:=" "+Sp08->p14
            ENDIF
          ELSE
            m_kod:=" 2"
          ENDIF
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->s_dox+=flish->sum
      ENDIF
ELSE
          sp10->(DS(flish->tabn))
          IF Sp08->kopu==k_pod1
            m_kod:=" 1"
          ELSE
            m_kod:=" 2"
          ENDIF
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->s_tax+=flish->sum
      ENDIF
 ENDIF



// НАЧИСЛЕННАЯ ДЛЯ ВЫПЛАЧЕННОЙ

IF AT(s_month,s_month3)<>0.AND.(flish->kopu<'100'.OR.(flish->kopu==k_pod1.OR.flish->kopu==k_pod2))

      Sp08->(DS(flish->kopu))
      Sp10->(DS(flish->tabn))
      IF .NOT.(Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2)
      IF Sp08->p14<>" ".AND.Sp08->p14<>"0"
          IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
            IF Sp08->p14=="2"
              m_kod:=" 1"
            ELSE
              m_kod:=" "+Sp08->p14
            ENDIF
          ELSE
            m_kod:=" 2"
          ENDIF
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->s_dox1+=flish->sum
      ENDIF
      ELSE
          sp10->(DS(flish->tabn))
          IF Sp08->kopu==k_pod1
            m_kod:=" 1"
          ELSE
            m_kod:=" 2"
          ENDIF
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->s_tax1+=Flish->sum
      ENDIF
 ENDIF

// Выплаченная

IF flish->kopu>='100'.or. Flish->kopu==m_078
    IF (Flish->kopu<>"800".AND.VAL(flish->month)>=m_month1.AND.VAL(flish->month)<=m_month2).OR.;
      (flish->kopu=="800".AND.(VAL(flish->month)+1>=m_month1.AND.VAL(flish->month)+1<=m_month2))
/*
IF (flish->tabn=='8029')
?"****",flish->kopu,flish->month,flish->sum
endif
*/
      Sp08->(DS(flish->kopu))
      sp10->(DS(flish->tabn))
      IF .NOT.(Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2)
      m_kod:="  "
      IF (Sp08->p14<>" ".AND.Sp08->p14<>"0").OR.Flish->kopu==m_078.OR.Flish->kopu=='800'
        IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
/*
IF (flish->tabn=='8029')
?"&&&&&&&&",flish->kopu,flish->month,flish->sum
endif
*/
            IF Sp08->p14=="2"
              m_kod:=" 1"
            ELSE
              m_kod:=" "+Sp08->p14
            ENDIF
         ELSE
              m_kod:=" 2"
         ENDIF
          IF Flish->kopu==m_078.OR.Flish->kopu=="800"
            m_kod:=" 1"
          ENDIF

          DbFl1(m_kod,flish->tabn,m_num,m_year)
          IF flish->kopu==m_078
            fl1->s_dox3-=flish->sum
          ELSE
            fl1->s_dox3+=flish->sum
            IF EMPTY(fl1->div).and..NOT.EMPTY(sp08->p14)
              fl1->div:=sp08->p14
            ENDIF

          ENDIF
          // Учесть выплаченную зарплату как 078 текущего месяца - 800 прошлого

      ENDIF
      ELSE
          sp10->(DS(flish->tabn))
          IF Sp08->kopu==k_pod1
            m_kod:=" 1"
          ELSE
            m_kod:=" 2"
          ENDIF
/*
IF (flish->tabn=='8029')
?"^^^^^^^^",flish->kopu,flish->month,flish->sum
endif
*/
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->s_tax3+=Flish->sum
      ENDIF
    ENDIF
    ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  SELECT fl1
  INDEX on fl1->tabn TO (m_workpath+"fl1a")
  COPY TO (m_workpath+"kvart"+m_num)
  CLOSE base fl1,sp10,sp08
  USE (m_workpath+"kvart"+m_num) ALIAS fl1 NEW
  INDEX on fl1->tin TO (m_workpath+"kvart"+m_num)
  m_codn:="********"
  m_gauge:=InitGauge("Вибiрка виплаченної зарплати ",2)
  n:=fl1->(LASTREC())
  Fl1->(DBGOTOP())
  m_s_101:=m_s_dox1:=m_s_tax1:=0
  DO WHILE .NOT.fl1->(EOF())
   IF m_codn<>fl1->tin
    m_codn:=fl1->tin
    m_recno:=fl1->(RECNO())
    m_s_101:=m_s_dox1:=m_s_tax1:=0
    m_st:=" "
    DO WHILE m_codn==fl1->tin.AND..NOT.fl1->(EOF())
       m_s_tax1+=fl1->s_tax3
       m_s_dox1+=fl1->s_dox1
       m_s_101+=fl1->s_dox3
      fl1->(DBSKIP())
    ENDDO
    fl1->(DBGOTO(m_recno))
    IF m_s_101>(m_s_dox1-m_s_tax1)
      m_st:="!"
      m_koef:=1
    ELSE
      if (m_s_dox1<>m_s_tax1)
        m_koef:=m_s_101/(m_s_dox1-m_s_tax1)
      else
        m_st:="?"
        m_koef:=1
      ENDIF
      IF m_s_tax1==0
        m_st:="*"
      ENDIF
//       ?m_codn,fl1->tabn, m_s_101,m_s_dox1,m_s_tax1
    ENDIF
    ENDIF

/*
    IF m_s_dox1<>0
        m_koef:=fl1->s_101/(m_s_dox1-m_s_tax1)
    ELSE
      fl1->st:="*" // DispError("Помилка на таб. номерi "+fl1->tabn)
      m_koef:=1
    ENDIF
    IF m_koef1>1
      m_koef:=fl1->s_101/m_s_101
      fl1->st:="!"
  ENDIF
*/
    fl1->s_tax2 :=m_koef*fl1->s_tax1
    fl1->s_dox2:=fl1->s_dox3 + fl1->s_tax2
    fl1->st:=m_st

    IF fl1->ozn_dox=2.and.fl1->div="7"
       fl1->ozn_dox:=7
    ENDIF
    IF fl1->s_dox==0.and.fl1->s_tax1==0.and.fl1->s_101==0
      fl1->(DBDELETE())
    ENDIF
    Fl1->(DBSKIP())
  ENDDO
  PACK
  CLOSE Fl1
/*
set printer off
set printer to
*/
  SAVEPAR(1)
 ENDIF
  RETURN .t.

Function Work14
  LOCAL GetList:={},m_num:=a_menu[1],n,m_sum,i,j,n1,n2
  LOCAL m_month1,m_month2,m_koef,m_year,k_pod1,k_pod2
  LOCAL m_kod,m_kopu,m_str1,m_kod1,s_zan,m_gauge,m_078
  LOCAL m_codn,m_koef1,m_recno,m_s_tax1,m_s_dox1,m_s_101,m_st,m_pod
  LOCAL m_kopu1,m_kopu2,m_tax,m_dox
  LOCAL s_month1,s_month2

  IF ANSWERu("Формувати звiт; за "+m_num+" квартал")==YES
    SAVEPAR()
    NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
    k_pod1  :=RESTVAR1("k_pod1","ZR")
    k_pod2  :=RESTVAR1("k_pod2","ZR")
    m_078   :=RESTVAR1("m_078","ZR")
    CLOSE myvar
    USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_kopu1:=ALLTRIM(RESTVAR1("m_kopu1","DR"))
    m_kopu2:=ALLTRIM(RESTVAR1("m_kopu2","DR"))
    m_year:=PADR(RESTVAR1("m_year","DR"),4)
     CLOSE myvar

    CopyZag(m_num)
    DispMessage("Формування звiту; за "+m_num+" квартал "+m_year+ " р.")
    USE (m_workpath+"kvart") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin TO (m_workpath+"kvart")
    DO CASE
  CASE m_num=="1"
    m_month1:=1;m_month2:=3
    m_date1:=CTOD("01/01/"+RIGHT(m_year,2));m_date2:=CTOD("31/03/"+RIGHT(m_year,2))
    s_month1="1,2,3"
    s_month2="1,2,3"
  CASE m_num=="2"
    m_month1:=4;m_month2:=6
    m_date1:=CTOD("01/04/"+RIGHT(m_year,2));m_date2:=CTOD("30/06/"+RIGHT(m_year,2))
    s_month1="4,5,6"
    s_month2="4,5,6"
  CASE m_num=="3"
    m_month1:=7;m_month2:=9
    m_date1:=CTOD("01/07/"+RIGHT(m_year,2));m_date2:=CTOD("30/09/"+RIGHT(m_year,2))
    s_month1="7,8,9"
    s_month2="7,8,9"
  CASE m_num=="4"
    m_month1:=10;m_month2:=12
    m_date1:=CTOD("01/10"+RIGHT(m_year,2));m_date2:=CTOD("32/12"+RIGHT(m_year,2))
    s_month1="10,11,12"
    s_month2="10,11,12"
ENDCASE
ReadMonths(@s_month1,@s_month2)
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY

  NET USE (m_mainpath+"fz3") READONLY  NEW
  NET USE (m_mainpath+"fz2") READONLY  NEW
  NET USE (m_mainpath+"fz1") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка заробiтн. платнi",2)

  DO WHILE .NOT.fz1->(EOF())
      IF mnt_month(fz1->mnt) >= m_month1.AND.mnt_month(fz1->mnt)<=m_month2
         select fz2
         n=RECNO()
         LOCATE REST FOR fz1->vnum1=fz2->vnum1
         IF fz1->vnum1<>fz2->vnum1                  // Нарушена целостность БД ОТСУТСТВУЕТ СВЯЗКА fz1 - fz2
            GO n
            SKIP 1 ALIAS fz1
            LOOP
         ENDIF
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF fz1->vdoc<>38     // В документе должна быть запись в fz3
               sp10->(DS(fz2->tabn))
               IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
                  m_kod:=" 1"
                ELSE
                  m_kod:=" 2"
                ENDIF
               select fz3
               n=RECNO()
               LOCATE REST FOR fz2->vnum2=fz3->vnum2
               IF fz3->vnum2<>fz2->vnum2               // Нарушена целостность БД ОТСУТСТВУЕТ СВЯЗКА fz2 - fz3
                  GO n
                  SKIP 1 ALIAS fz2
                  LOOP
               ENDIF
               DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())

                   DbFl1(m_kod,fz2->tabn,m_num,m_year)
//                    Sp08->(DS(fz3->kopu))
                   DO CASE
                    CASE AT(fz3->kopu,m_kopu1)<>0
                      fl1->stm7+=fz3->sum
                    CASE AT(fz3->kopu,m_kopu2)<>0
                      fl1->stm6+=fz3->sum
                    OTHERWISE
                      fl1->stm1+=fz3->sum
                  ENDCASE


                  SKIP 1 ALIAS fz3
               ENDDO
            ENDIF
            SKIP 1 ALIAS fz2
         ENDDO
      ENDIF
      fz1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fz1->(RECNO())/FZ1->(LASTREC()))
  ENDDO
  CLOSE BASE FZ1,FZ2,FZ3
  DelGauge(m_gauge)
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка виплаченної зарплати ",2)

set printer to "t1.lst"
set printer on




  DO WHILE .NOT.flish->(EOF())
    IF (Flish->kopu<>"800".AND.VAL(flish->month)>=m_month1.AND.VAL(flish->month)<=m_month2).OR.;
      (flish->kopu=="800".AND.(VAL(flish->month)+1>=m_month1.AND.VAL(flish->month)+1<=m_month2))
      Sp08->(DS(flish->kopu))
      sp10->(DS(flish->tabn))
      m_kod:="  "
      IF (Sp08->p14<>" ".AND.Sp08->p14<>"0").OR.Flish->kopu==m_078.OR.Flish->kopu=='800'
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          IF flish->kopu==m_078
            fl1->sum1-=flish->sum
          ELSE
            DO CASE
              CASE Sp08->p14=="1"
                fl1->sum1+=flish->sum
              CASE Sp08->p14=="2"
                fl1->sum2+=flish->sum
              CASE Sp08->p14=="3"
                fl1->sum3+=flish->sum
              CASE Sp08->p14=="4"
                fl1->sum4+=flish->sum
              CASE Sp08->p14=="5"
                fl1->sum5+=flish->sum
              CASE Sp08->p14=="6"
                fl1->sum6+=flish->sum
              CASE Sp08->p14=="7"
                fl1->sum7+=flish->sum
              CASE Sp08->p14=="7"
                fl1->sum8+=flish->sum
              OTHERWISE
                FL1->SUM1+=flish->sum
            ENDCASE

          ENDIF
          // Учесть выплаченную зарплату как 078 текущего месяца - 800 прошлого

      ENDIF

      IF Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2
          sp10->(DS(flish->tabn))
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->taxall+=Flish->sum
      ENDIF
    ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  USE (m_workpath+"kvart"+m_num) ALIAS fl2 NEW
  ZAP

  SELECT fl1

  fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
      fl1->sumall=fl1->sum1+fl1->sum2+fl1->sum3+fl1->sum4+fl1->sum5+fl1->sum6+fl1->sum7+fl1->sum8
      fl1->stmall=fl1->stm1+fl1->stm2+fl1->stm3+fl1->stm4+fl1->stm5+fl1->stm6+fl1->stm7+fl1->stm8
   IF fl1->sumall<>0
      // Формирование записей квартальных данных
      m_tax:=m_dox:=n1:=n2:=j:=i:=0
      IF fl1->sum1<>0;  i++;SETBIT(n1,1);  ENDIF
      IF fl1->sum2<>0;  i++;SETBIT(n1,2);  ENDIF
      IF fl1->sum3<>0;  i++;SETBIT(n1,3);  ENDIF
      IF fl1->sum4<>0;  i++;SETBIT(n1,4);  ENDIF
      IF fl1->sum5<>0;  i++;SETBIT(n1,5);  ENDIF
      IF fl1->sum6<>0;  i++;SETBIT(n1,6);  ENDIF
      IF fl1->sum7<>0;  i++;SETBIT(n1,7);  ENDIF
      IF fl1->sum8<>0;  i++;SETBIT(n1,8);  ENDIF
      IF fl1->stm1<>0;  j++;SETBIT(n2,1);  ENDIF
      IF fl1->stm2<>0;  j++;SETBIT(n2,2);  ENDIF
      IF fl1->stm3<>0;  j++;SETBIT(n2,3);  ENDIF
      IF fl1->stm4<>0;  j++;SETBIT(n2,4);  ENDIF
      IF fl1->stm5<>0;  j++;SETBIT(n2,5);  ENDIF
      IF fl1->stm6<>0;  j++;SETBIT(n2,6);  ENDIF
      IF fl1->stm7<>0;  j++;SETBIT(n2,7);  ENDIF
      IF fl1->stm8<>0;  j++;SETBIT(n2,8);  ENDIF
      // если только одно начисление
      m_st:=" "
      IF i==1
        IF fl1->stmall=fl1->sumall+fl1->taxall
          m_tax :=fl1->taxall
          m_dox:=fl1->stmall
        ELSE      // Не сходится подоходный
            IF fl1->stmall>fl1->sumall+fl1->taxall //Выплачено меньше
              m_tax:=fl1->taxall*(fl1->sumall/(fl1->stmall-fl1->taxall))
            ELSE  //Выплачено больше
              m_tax:=fl1->taxall
              m_st:="*"
            ENDIF
            m_dox:=m_tax+fl1->sumall
        ENDIF
        fl2->(DBAP())
        fl2->period:=VAL(m_num)
        fl2->rik:=VAL(m_year)
        fl2->tabn:=fl1->tabn
        fl2->tin:=fl1->tin
        fl2->fio:=fl1->fio
        fl2->d_priyn:=fl1->d_priyn
        fl2->d_zviln:=fl1->d_zviln
        fl2->s_tax :=m_tax
        fl2->s_dox:=m_dox
        fl2->st:=m_st
          DO CASE
            CASE fl1->sum1<>0
              IF fl1->kpn<>"4".AND.fl1->kpn<>"6".AND.fl1->kpn<>"7"
                // Основные работники
                fl2->ozn_dox:=1
                Fl2->ozn_pilg:=0
                DO CASE
                  CASE fl1->kpn=="1"
                    Fl2->ozn_pilg:=0
                    DO CASE
                      CASE fl1->kmn>="1".AND.fl1->kmn<"3"
                        Fl2->ozn_pilg:=1
                      CASE fl1->kmn>="3"
                        Fl2->ozn_pilg:=5
                      ENDCASE
                  CASE fl1->kpn=="2"
                    Fl2->ozn_pilg:=2
                  CASE fl1->kpn=="3"
                    Fl2->ozn_pilg:=3
                  CASE fl1->kpn=="5"
                    Fl2->ozn_pilg:=4
                  ENDCASE
              ELSE
                fl2->ozn_dox:=2
              ENDIF
            CASE fl1->sum2<>0
              fl2->ozn_dox:=2
            CASE fl1->sum3<>0
              fl2->ozn_dox:=3
            CASE fl1->sum4<>0
              fl2->ozn_dox:=4
            CASE fl1->sum5<>0
              fl2->ozn_dox:=5
            CASE fl1->sum6<>0
              fl2->ozn_dox:=6
            CASE fl1->sum7<>0
              fl2->ozn_dox:=7
            CASE fl1->sum8<>0
              fl2->ozn_dox:=8
          ENDCASE


      ELSE // Больше одной выплаты
        IF fl1->sumall<=fl1->taxall
         m_pod:=0
        ELSE
          m_pod:=ROUND(MIN(fl1->sumall/(fl1->stmall-fl1->taxall)*fl1->taxall,fl1->taxall),2)
        ENDIF
         IF fl1->sum8<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=8
          IF fl1->stm8>=fl1->sum8 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm8-fl1->sum8
            fl2->s_dox:= fl1->stm8
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum8 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum8
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum7<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=7
          IF fl1->stm7>=fl1->sum7 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm7-fl1->sum7
            fl2->s_dox:= fl1->stm7
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum7 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum7
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum6<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=6
          IF fl1->stm6>=fl1->sum6 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm6-fl1->sum6
            fl2->s_dox:= fl1->stm6
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum6 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum6
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum5<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=5
          IF fl1->stm5>=fl1->sum5 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm5-fl1->sum5
            fl2->s_dox:= fl1->stm5
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum5 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum5
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum4<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=4
          IF fl1->stm4>=fl1->sum4 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm4-fl1->sum4
            fl2->s_dox:= fl1->stm4
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum4 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum4
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum3<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=3
          IF fl1->stm3>=fl1->sum3 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm3-fl1->sum3
            fl2->s_dox:= fl1->stm3
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum3 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum3
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
   ?"*",fl1->tabn,m_pod
        IF m_dox<>fl1->sumall.OR.m_tax<>fl1->taxall
            ??m_dox,m_tax
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->s_tax :=m_pod-m_tax
            fl2->s_dox:= fl1->sumall+m_pod-m_dox
            IF fl1->sumall+fl1->taxall>fl1->stmall //Вылата превышает начисления
              fl2->st:="?"
            ENDIF
              IF fl1->kpn<>"4".AND.fl1->kpn<>"6".AND.fl1->kpn<>"7"
                // Основные работники
                fl2->ozn_dox:=1
                Fl2->ozn_pilg:=0
                DO CASE
                  CASE fl1->kpn=="1"
                    Fl2->ozn_pilg:=0
                    DO CASE
                      CASE fl1->kmn>="1".AND.fl1->kmn<"3"
                        Fl2->ozn_pilg:=1
                      CASE fl1->kmn>="3"
                        Fl2->ozn_pilg:=5
                      ENDCASE
                  CASE fl1->kpn=="2"
                    Fl2->ozn_pilg:=2
                  CASE fl1->kpn=="3"
                    Fl2->ozn_pilg:=3
                  CASE fl1->kpn=="5"
                    Fl2->ozn_pilg:=4
                  ENDCASE
              ELSE
                fl2->ozn_dox:=2
              ENDIF
//        ENDIF
        ENDIF


      ENDIF

   ENDIF

      fl1->(DBSKIP())
  ENDDO
/*

  INDEX on fl1->tabn TO (m_workpath+"fl1a")




  COPY TO (m_workpath+"kvart"+m_num)
  CLOSE base fl1,sp10,sp08
  USE (m_workpath+"kvart"+m_num) ALIAS fl1 NEW

  INDEX on fl1->tin TO (m_workpath+"kvart"+m_num)

//  DELE FOR fl1->s_101==0
  m_codn:="********"
  m_gauge:=InitGauge("Вибiрка виплаченної зарплати ",2)
  n:=fl1->(LASTREC())
  Fl1->(DBGOTOP())
  m_s_101:=m_s_dox1:=m_s_tax1:=0
  DO WHILE .NOT.fl1->(EOF())

    IF m_codn<>fl1->tin
    m_codn:=fl1->tin
    m_recno:=fl1->(RECNO())
    m_s_101:=m_s_dox1:=m_s_tax1:=0
    m_st:=" "
    DO WHILE m_codn==fl1->tin.AND..NOT.fl1->(EOF())
       m_s_tax1+=fl1->s_tax1
       m_s_dox1+=fl1->s_dox1
       m_s_101+=fl1->s_101
      fl1->(DBSKIP())
    ENDDO
    fl1->(DBGOTO(m_recno))
    IF m_s_101>(m_s_dox1-m_s_tax1)
      m_st:="!"
      m_koef1:=1
    ELSE
      m_koef1:=m_s_101/(m_s_dox1-m_s_tax1)
    ENDIF
    IF m_s_tax1==0
      m_st:="*"
    ENDIF
//       ?m_codn,fl1->tabn, m_s_101,m_s_dox1,m_s_tax1
    ENDIF


    IF m_s_dox1<>0
        m_koef:=fl1->s_101/(m_s_dox1-m_s_tax1)
    ELSE
      fl1->st:="*" // DispError("Помилка на таб. номерi "+fl1->tabn)
      m_koef:=1
    ENDIF
    IF m_koef1>1
      m_koef:=fl1->s_101/m_s_101
      fl1->st:="!"
    ENDIF
    fl1->s_tax :=m_koef*m_s_tax1
    fl1->s_dox:=fl1->s_101 + fl1->s_tax
    IF fl1->ozn_dox=2.and.fl1->div="7"
       fl1->ozn_dox:=7
    ENDIF
    IF fl1->s_dox==0.and.fl1->s_tax1==0.and.fl1->s_101==0
      fl1->(DBDELETE())
    ENDIF
    Fl1->(DBSKIP())
  ENDDO
  PACK
*/
  CLOSE Fl1
  CLOSE Fl2
//  FILECOPY("kvart.dbf","kvart"+m_num+".dbf")
set printer to
set printer off
    SAVEPAR(1)
  ENDIF
  RETURN .t.



Function DbFl1(m_kod,m_tabn,m_num,m_year)
  LOCAL m_codn:=IF(EMPTY(Sp10->codn),PADR(m_tabn,10),Sp10->codn)
fl1->(DS(m_codn+m_kod))
IF .NOT.fl1->(FOUND())
  fl1->(DBAP())
  fl1->period:=VAL(m_num)
  fl1->rik:=VAL(m_year)
  fl1->tabn:=m_tabn
  fl1->tin:=m_codn
  fl1->ozn_dox:=VAL(m_kod)
  IF sp10->(FOUND())
    fl1->kpn:=sp10->kpn
    fl1->kmn:=sp10->kmn
    fl1->fio:=ALLTRIM(sp10->fam)+" "+LEFT(sp10->imja,1)+"."+LEFT(sp10->otch,1)+"."
    IF Sp10->dzch>=m_date1.AND.Sp10->dzch<=m_date2
      fl1->d_priyn:=Sp10->dzch
    ENDIF
    IF Sp10->(FIELDNUM("DUVL"))<>0
      IF Sp10->duvl>=m_date1.AND.Sp10->duvl<=m_date2
        fl1->d_zviln:=Sp10->duvl
      ENDIF
    ENDIF
    Fl1->ozn_pilg:=0
    DO CASE
      CASE sp10->kpn=="1"
        Fl1->ozn_pilg:=0
        DO CASE
          CASE sp10->kmn>="1".AND.sp10->kmn<"3"
            Fl1->ozn_pilg:=1
          CASE sp10->kmn>="3"
            Fl1->ozn_pilg:=5
          ENDCASE
      CASE sp10->kpn=="2"
        Fl1->ozn_pilg:=2
      CASE sp10->kpn=="3"
        Fl1->ozn_pilg:=3
      CASE sp10->kpn=="5"
        Fl1->ozn_pilg:=4
      ENDCASE
  ELSE
    Fl1->ozn_pilg:=-1
    Fl1->kpn:="?"
    Fl1->kmn:="?"
    fl1->fio:="????????????????????"
  ENDIF

ENDIF
RETURN .t.

Function DbFl2(m_kod,m_tabn,m_num,m_year)
  LOCAL m_codn:=IF(EMPTY(Sp10->codn),PADR(m_tabn,10),Sp10->codn)

fl1->(DS(m_codn))
IF .NOT.fl1->(FOUND())
  fl1->(DBAP())
  fl1->period:=VAL(m_num)
  fl1->rik:=VAL(m_year)
  fl1->tabn:=Sp10->tabn
  IF sp10->(FOUND())
    fl1->tin:=m_codn
    Fl1->ozn_pilg:=0
    DO CASE
      CASE sp10->kpn=="1"
        Fl1->ozn_pilg:=0
        DO CASE
          CASE sp10->kmn>="1".AND.sp10->kmn<"3"
            Fl1->ozn_pilg:=1
          CASE sp10->kmn>="3"
            Fl1->ozn_pilg:=5
          ENDCASE
      CASE sp10->kpn=="2"
        Fl1->ozn_pilg:=2
      CASE sp10->kpn=="3"
        Fl1->ozn_pilg:=3
      CASE sp10->kpn=="5"
        Fl1->ozn_pilg:=4
      ENDCASE
  ELSE
    fl1->tin:=m_codn
  ENDIF
  fl1->fio:=ALLTRIM(sp10->fam)+" "+LEFT(sp10->imja,1)+"."+LEFT(sp10->otch,1)+"."
  fl1->ozn_dox:=VAL(m_kod)
  IF Sp10->dzch>=m_date1.AND.Sp10->dzch<=m_date2
    fl1->d_priyn:=Sp10->dzch
  ENDIF
  IF Sp10->(FIELDNUM("DUVL"))<>0
  IF Sp10->duvl>=m_date1.AND.Sp10->duvl<=m_date2
    fl1->d_zviln:=Sp10->duvl
  ENDIF
  ENDIF
ENDIF
RETURN .t.




Function CopyZag(m_num)
  LOCAL   m_name,m_name1,m_kod,m_kod1,m_id1,m_fam1,;
  m_tel1,m_id2,m_fam2,m_tel2

  IF FILE (m_workpath+"ZAG"+m_num+".dbf")
    FERASE(m_workpath+"ZAG"+m_num+".dbf")
  ENDIF
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
  m_name:=PADR(RESTVAR1("m_name","DR"),50)
  m_name1:=PADR(RESTVAR1("m_name1","DR"),50)
  m_kod:=PADR(RESTVAR1("m_kod","DR"),10)
  m_kod1:=PADR(RESTVAR1("m_kod1","DR"),10)
  m_id1:=PADR(RESTVAR1("m_id1","DR"),10)
  m_fam1:=PADR(RESTVAR1("m_fam1","DR"),30)
  m_tel1:=PADR(RESTVAR1("m_tel1","DR"),10)
  m_id2:=PADR(RESTVAR1("m_id2","DR"),10)
  m_fam2:=PADR(RESTVAR1("m_fam2","DR"),30)
  m_tel2:=PADR(RESTVAR1("m_tel2","DR"),10)
  CLOSE myvar
  FILECOPY(m_workpath+"ZAG"+".dbf",m_workpath+"ZAG"+m_num+".dbf")
  USE (m_workpath+"ZAG"+m_num+".dbf") ALIAS Zag NEW
  zag->name := m_name
  zag->name1:= m_name1
  zag->kod  := m_kod
  zag->kod1 := m_kod1
  zag->id1  := m_id1
  zag->fam1 := m_fam1
  zag->tel1 := m_tel1
  zag->id2  := m_id2
  zag->fam2 := m_fam2
  zag->tel2 := m_tel2
  CLOSE ZAG
RETURN .t.


Function Work03
  LOCAL GetList:={},m_num:=a_menu[1],n,m_sum
  LOCAL m_month1,m_month2,m_koef,m_year,s_month
  LOCAL s_month1,s_month2
  LOCAL m_kod,m_kopu,m_str1,m_kod1,s_zan,m_gauge
  LOCAL m_kopu1,m_kopu2,m_kopu3,m_kopu4,m_kopu5,k_pod1,k_pod2
  IF ANSWERu("Формувати звiт; за "+m_num+" квартал")==YES
    SAVEPAR()
    CopyZag(m_num)
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
k_pod1  :=RESTVAR1("k_pod1","ZR")
k_pod2  :=RESTVAR1("k_pod2","ZR")
 CLOSE myvar

    DispMessage("Формування звiту; за "+m_num+" квартал")
    IF FILE(m_workpath+"kvart"+m_num+".dbf")
      FERASE(m_workpath+"kvart"+m_num+".dbf")
    ENDIF
    USE (m_workpath+"kvart") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin+STR(fl1->ozn_dox,2) TO (m_workpath+"kvart")
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_year:=PADR(RESTVAR1("m_year","DR"),4)
    CLOSE myvar
    DO CASE
  CASE m_num=="1"
    m_month1:=1;m_month2:=3
    m_date1:=CTOD("01/01/"+RIGHT(m_year,2));m_date2:=CTOD("31/03/"+RIGHT(m_year,2))
    s_month1=",1,2,3"
    s_month2=",1,2,3"
  CASE m_num=="2"
    m_month1:=4;m_month2:=6
    m_date1:=CTOD("01/04/"+RIGHT(m_year,2));m_date2:=CTOD("30/06/"+RIGHT(m_year,2))
    s_month1=",4,5,6"
    s_month2=",4,5,6"
  CASE m_num=="3"
    m_month1:=7;m_month2:=9
    m_date1:=CTOD("01/07/"+RIGHT(m_year,2));m_date2:=CTOD("30/09/"+RIGHT(m_year,2))
    s_month1=",7,8,9"
    s_month2=",7,8,9"
  CASE m_num=="4"
    m_month1:=10;m_month2:=12
    m_date1:=CTOD("01/10"+RIGHT(m_year,2));m_date2:=CTOD("32/12"+RIGHT(m_year,2))
    s_month1=",10,11,12"
    s_month2=",10,11,12"
ENDCASE
ReadMonths(@s_month1,@s_month2)

  NET USE (m_mainpath+"fz3") READONLY  NEW
  NET USE (m_mainpath+"fz2") READONLY  NEW
  NET USE (m_mainpath+"fz1") READONLY  NEW
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка сум",2)
  DO WHILE .NOT.flish->(EOF())
s_month=","+ALLTRIM(STR(VAL(flish->month),2))+","

//    IF VAL(flish->month)>=m_month1.AND.VAL(flish->month)<=m_month2
IF AT(s_month,s_month1)<>0.OR.AT(s_month,s_month2)<>0
      Sp08->(DS(flish->kopu))
      Sp10->(DS(flish->tabn))
      IF Sp08->p14<>" ".AND.Sp08->p14<>"0"
          IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
            IF Sp08->p14=="2"
              m_kod:=" 1"
            ELSE
              m_kod:=" "+Sp08->p14
            ENDIF
          ELSE
            m_kod:=" 2"
          ENDIF
          DbFl1(m_kod,flish->tabn,m_num,m_year)
IF AT(s_month,s_month1)<>0
          fl1->s_101+=flish->sum
      ENDIF
IF AT(s_month,s_month2)<>0
          fl1->s_dox2+=flish->sum
      ENDIF
      ENDIF
      IF Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2
          sp10->(DS(flish->tabn))
          IF Sp08->kopu==k_pod1
            m_kod:=" 1"
          ELSE
            m_kod:=" 2"
          ENDIF
          DbFl1(m_kod,flish->tabn,m_num,m_year)
//          fl1->(DS(Sp10->codn+m_kod))
//          fl1->s_tax1+=Flish->sum
IF AT(s_month,s_month2)<>0
          fl1->s_tax2+=flish->sum
      ENDIF
IF AT(s_month,s_month1)<>0
          fl1->s_tax1+=flish->sum
      ENDIF
      ENDIF
    ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  SELECT fl1
  INDEX on fl1->tabn TO (m_workpath+"fl1a")
  COPY TO (m_workpath+"kvart"+m_num)
  CLOSE base fl1,sp10,sp08
  USE (m_workpath+"kvart"+m_num) ALIAS fl1 NEW
  Fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
    fl1->s_tax :=fl1->s_tax1
    fl1->s_dox:=fl1->s_101
    Fl1->(DBSKIP())
  ENDDO
  PACK
  CLOSE Fl1
  SAVEPAR(1)
  ENDIF
  RETURN .t.

function buhmonth(d)
if day(d)>25
 if month(d)=12
  return 1
 else
  return month(d)+1
 endif
endif
return month(d)


Function Work15
  LOCAL GetList:={},m_num:=a_menu[1],n,m_sum,i,j,n1,n2
  LOCAL m_month1,m_month2,m_koef,m_year,k_pod1,k_pod2
  LOCAL m_kod,m_kopu,m_str1,m_kod1,s_zan,m_gauge,m_078
  LOCAL m_codn,m_koef1,m_recno,m_s_tax1,m_s_dox1,m_s_101,m_st,m_pod
  LOCAL m_kopu1,m_kopu2,m_tax,m_dox

  IF ANSWERu("Формувати звiт; за "+m_num+" квартал")==YES
    SAVEPAR()
    NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
    k_pod1  :=RESTVAR1("k_pod1","ZR")
    k_pod2  :=RESTVAR1("k_pod2","ZR")
    m_078   :=RESTVAR1("m_078","ZR")
    CLOSE myvar
    USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_kopu1:=ALLTRIM(RESTVAR1("m_kopu1","DR"))
    m_kopu2:=ALLTRIM(RESTVAR1("m_kopu2","DR"))
    m_year:=PADR(RESTVAR1("m_year","DR"),4)
     CLOSE myvar

    CopyZag(m_num)
    DispMessage("Формування звiту; за "+m_num+" квартал "+m_year+ " р.")
    USE (m_workpath+"kvart") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin TO (m_workpath+"kvart")
    DO CASE
  CASE m_num=="1"
    m_month1:=1;m_month2:=3
    m_date1:=CTOD("01/01/"+RIGHT(m_year,2));m_date2:=CTOD("31/03/"+RIGHT(m_year,2))
  CASE m_num=="2"
    m_month1:=4;m_month2:=6
    m_date1:=CTOD("01/04/"+RIGHT(m_year,2));m_date2:=CTOD("30/06/"+RIGHT(m_year,2))
  CASE m_num=="3"
    m_month1:=7;m_month2:=9
    m_date1:=CTOD("01/07/"+RIGHT(m_year,2));m_date2:=CTOD("30/09/"+RIGHT(m_year,2))
  CASE m_num=="4"
    m_month1:=10;m_month2:=12
    m_date1:=CTOD("01/10"+RIGHT(m_year,2));m_date2:=CTOD("32/12"+RIGHT(m_year,2))
ENDCASE

  NET USE (m_mainpath+"fz3") READONLY  NEW
  NET USE (m_mainpath+"fz2") READONLY  NEW
  NET USE (m_mainpath+"fz1") READONLY  NEW
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY
  m_gauge:=InitGauge("Вибiрка заробiтн. платнi",2)
  DO WHILE .NOT.fz1->(EOF())
      IF mnt_month(fz1->mnt) >= m_month1.AND.mnt_month(fz1->mnt)<=m_month2
         select fz2
         n=RECNO()
         LOCATE REST FOR fz1->vnum1=fz2->vnum1
         IF fz1->vnum1<>fz2->vnum1                  // Нарушена целостность БД ОТСУТСТВУЕТ СВЯЗКА fz1 - fz2
            GO n
            SKIP 1 ALIAS fz1
            LOOP
         ENDIF
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF fz1->vdoc<>38     // В документе должна быть запись в fz3
               sp10->(DS(fz2->tabn))
               IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
                  m_kod:=" 1"
                ELSE
                  m_kod:=" 2"
                ENDIF
               select fz3
               n=RECNO()
               LOCATE REST FOR fz2->vnum2=fz3->vnum2
               IF fz3->vnum2<>fz2->vnum2               // Нарушена целостность БД ОТСУТСТВУЕТ СВЯЗКА fz2 - fz3
                  GO n
                  SKIP 1 ALIAS fz2
                  LOOP
               ENDIF
               DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())

                   DbFl1(m_kod,fz2->tabn,m_num,m_year)
//                    Sp08->(DS(fz3->kopu))
                   DO CASE
                    CASE AT(fz3->kopu,m_kopu1)<>0
                      fl1->stm7+=fz3->sum
                    CASE AT(fz3->kopu,m_kopu2)<>0
                      fl1->stm6+=fz3->sum
                    OTHERWISE
                      fl1->stm1+=fz3->sum
                  ENDCASE


                  SKIP 1 ALIAS fz3
               ENDDO
            ENDIF
            SKIP 1 ALIAS fz2
         ENDDO
      ENDIF
      fz1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fz1->(RECNO())/FZ1->(LASTREC()))
  ENDDO
  CLOSE BASE FZ1,FZ2,FZ3
  DelGauge(m_gauge)
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка виплаченної зарплати ",2)

 set printer to "t1.lst"
 set printer on
 SET CONSOLE OFF




  DO WHILE .NOT.flish->(EOF())
    IF (Flish->kopu<>"800".AND.VAL(flish->month)>=m_month1.AND.VAL(flish->month)<=m_month2).OR.;
      (flish->kopu=="800".AND.(VAL(flish->month)+1>=m_month1.AND.VAL(flish->month)+1<=m_month2))
      Sp08->(DS(flish->kopu))
      sp10->(DS(flish->tabn))
      m_kod:="  "
      IF (Sp08->p14<>" ".AND.Sp08->p14<>"0").OR.Flish->kopu==m_078.OR.Flish->kopu=='800'
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          IF flish->kopu==m_078
            fl1->sum1-=flish->sum
          ELSE
            DO CASE
              CASE Sp08->p14=="1"
                fl1->sum1+=flish->sum
              CASE Sp08->p14=="2"
                fl1->sum2+=flish->sum
              CASE Sp08->p14=="3"
                fl1->sum3+=flish->sum
              CASE Sp08->p14=="4"
                fl1->sum4+=flish->sum
              CASE Sp08->p14=="5"
                fl1->sum5+=flish->sum
              CASE Sp08->p14=="6"
                fl1->sum6+=flish->sum
              CASE Sp08->p14=="7"
                fl1->sum7+=flish->sum
              CASE Sp08->p14=="7"
                fl1->sum8+=flish->sum
              OTHERWISE
                FL1->SUM1+=flish->sum
            ENDCASE

          ENDIF
          // Учесть выплаченную зарплату как 078 текущего месяца - 800 прошлого

      ENDIF

      IF Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2
          sp10->(DS(flish->tabn))
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->taxall+=Flish->sum
      ENDIF
    ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  USE (m_workpath+"kvart"+m_num) ALIAS fl2 NEW
  ZAP

  SELECT fl1

  fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
    ?"fl1->tabn=",fl1->tabn
      fl1->sumall=fl1->sum1+fl1->sum2+fl1->sum3+fl1->sum4+fl1->sum5+fl1->sum6+fl1->sum7+fl1->sum8
      fl1->stmall=fl1->stm1+fl1->stm2+fl1->stm3+fl1->stm4+fl1->stm5+fl1->stm6+fl1->stm7+fl1->stm8
   IF fl1->sumall<>0
    ??"<>0",fl1->sumall,fl1->tabn
      // Формирование записей квартальных данных
      m_tax:=m_dox:=n1:=n2:=j:=i:=0
      IF fl1->sum1<>0;  i++;SETBIT(n1,1);  ENDIF
      IF fl1->sum2<>0;  i++;SETBIT(n1,2);  ENDIF
      IF fl1->sum3<>0;  i++;SETBIT(n1,3);  ENDIF
      IF fl1->sum4<>0;  i++;SETBIT(n1,4);  ENDIF
      IF fl1->sum5<>0;  i++;SETBIT(n1,5);  ENDIF
      IF fl1->sum6<>0;  i++;SETBIT(n1,6);  ENDIF
      IF fl1->sum7<>0;  i++;SETBIT(n1,7);  ENDIF
      IF fl1->sum8<>0;  i++;SETBIT(n1,8);  ENDIF
      IF fl1->stm1<>0;  j++;SETBIT(n2,1);  ENDIF
      IF fl1->stm2<>0;  j++;SETBIT(n2,2);  ENDIF
      IF fl1->stm3<>0;  j++;SETBIT(n2,3);  ENDIF
      IF fl1->stm4<>0;  j++;SETBIT(n2,4);  ENDIF
      IF fl1->stm5<>0;  j++;SETBIT(n2,5);  ENDIF
      IF fl1->stm6<>0;  j++;SETBIT(n2,6);  ENDIF
      IF fl1->stm7<>0;  j++;SETBIT(n2,7);  ENDIF
      IF fl1->stm8<>0;  j++;SETBIT(n2,8);  ENDIF
      // если только одно начисление
      m_st:=" "
      IF i==1
        ??"i=1"
        IF fl1->stmall=fl1->sumall+fl1->taxall
          m_tax :=fl1->taxall
          m_dox:=fl1->stmall
        ELSE      // Не сходится подоходный
            IF fl1->stmall>fl1->sumall+fl1->taxall //Выплачено меньше
          IF fl1->stmall-fl1->taxall<>0
              m_tax:=fl1->taxall*(fl1->sumall/(fl1->stmall-fl1->taxall))
            ELSE
              m_tax:=0
            ENDIF

            ELSE  //Выплачено больше
              m_tax:=fl1->taxall
              m_st:="*"
            ENDIF
            m_dox:=m_tax+fl1->sumall
        ENDIF
        ??"fl2->dbap"
        fl2->(DBAP())
        fl2->period:=VAL(m_num)
        fl2->rik:=VAL(m_year)
        fl2->tabn:=fl1->tabn
        fl2->tin:=fl1->tin
        fl2->fio:=fl1->fio
        fl2->d_priyn:=fl1->d_priyn
        fl2->d_zviln:=fl1->d_zviln
        fl2->s_tax :=m_tax
        fl2->s_dox:=m_dox
        fl2->st:=m_st
          DO CASE
            CASE fl1->sum1<>0
              IF fl1->kpn<>"4".AND.fl1->kpn<>"6".AND.fl1->kpn<>"7"
                // Основные работники
                fl2->ozn_dox:=1
                Fl2->ozn_pilg:=0
                DO CASE
                  CASE fl1->kpn=="1"
                    Fl2->ozn_pilg:=0
                    DO CASE
                      CASE fl1->kmn>="1".AND.fl1->kmn<"3"
                        Fl2->ozn_pilg:=1
                      CASE fl1->kmn>="3"
                        Fl2->ozn_pilg:=5
                      ENDCASE
                  CASE fl1->kpn=="2"
                    Fl2->ozn_pilg:=2
                  CASE fl1->kpn=="3"
                    Fl2->ozn_pilg:=3
                  CASE fl1->kpn=="5"
                    Fl2->ozn_pilg:=4
                  ENDCASE
              ELSE
                fl2->ozn_dox:=2
              ENDIF
            CASE fl1->sum2<>0
              fl2->ozn_dox:=2
            CASE fl1->sum3<>0
              fl2->ozn_dox:=3
            CASE fl1->sum4<>0
              fl2->ozn_dox:=4
            CASE fl1->sum5<>0
              fl2->ozn_dox:=5
            CASE fl1->sum6<>0
              fl2->ozn_dox:=6
            CASE fl1->sum7<>0
              fl2->ozn_dox:=7
            CASE fl1->sum8<>0
              fl2->ozn_dox:=8
          ENDCASE

      ELSE // Больше одной выплаты
      ??"i<>1"
        IF fl1->sumall<=fl1->taxall
         m_pod:=0
        ELSE
          ?"||||||",fl1->stmall,fl1->taxall,fl1->stmall-fl1->taxall,fl1->tabn
          IF fl1->stmall-fl1->taxall<>0
          m_pod:=ROUND(MIN(fl1->sumall/(fl1->stmall-fl1->taxall)*fl1->taxall,fl1->taxall),2)
        ELSE
          m_pod:=0
        ENDIF
        ENDIF
?"continue"
         IF fl1->sum8<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=8
          IF fl1->stm8>=fl1->sum8 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm8-fl1->sum8
            fl2->s_dox:= fl1->stm8
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum8 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum8
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum7<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=7
            fl2->s_tax :=INT(fl1->stm7)*0.2
            fl2->s_dox:= fl1->stm7
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum6<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=6
            fl2->s_tax :=INT(fl1->stm6)*0.2
            fl2->s_dox:= fl1->stm6
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum5<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=5
          IF fl1->stm5>=fl1->sum5 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm5-fl1->sum5
            fl2->s_dox:= fl1->stm5
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum5 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum5
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum4<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=4
          IF fl1->stm4>=fl1->sum4 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm4-fl1->sum4
            fl2->s_dox:= fl1->stm4
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum4 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum4
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
         IF fl1->sum3<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=3
          IF fl1->stm3>=fl1->sum3 // Начисление превышает выплату
            fl2->s_tax :=fl1->stm3-fl1->sum3
            fl2->s_dox:= fl1->stm3
          ELSE
            fl2->st:="?"
            fl2->s_tax:= fl1->sum3 * m_pod /fl1->sumall // Пропорциональное вычисление
            fl2->s_dox:= fl2->s_tax+fl1->sum3
        ENDIF
            m_dox+=fl2->s_dox
            m_tax+=fl2->s_tax
        ENDIF
        IF m_dox<>fl1->sumall.OR.m_tax<>fl1->taxall
            ??m_dox,m_tax
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->s_tax :=m_pod-m_tax
            fl2->s_dox:= fl1->sumall+m_pod-m_dox
            IF fl1->sumall+fl1->taxall>fl1->stmall //Вылата превышает начисления
              fl2->st:="?"
            ENDIF
              IF fl1->kpn<>"4".AND.fl1->kpn<>"6".AND.fl1->kpn<>"7"
                // Основные работники
                fl2->ozn_dox:=1
                Fl2->ozn_pilg:=0
                DO CASE
                  CASE fl1->kpn=="1"
                    Fl2->ozn_pilg:=0
                    DO CASE
                      CASE fl1->kmn>="1".AND.fl1->kmn<"3"
                        Fl2->ozn_pilg:=1
                      CASE fl1->kmn>="3"
                        Fl2->ozn_pilg:=5
                      ENDCASE
                  CASE fl1->kpn=="2"
                    Fl2->ozn_pilg:=2
                  CASE fl1->kpn=="3"
                    Fl2->ozn_pilg:=3
                  CASE fl1->kpn=="5"
                    Fl2->ozn_pilg:=4
                  ENDCASE
              ELSE
                fl2->ozn_dox:=2
              ENDIF
//        ENDIF
        ENDIF


      ENDIF

   ENDIF

      fl1->(DBSKIP())
  ENDDO
  CLOSE Fl1
  CLOSE Fl2
// FILECOPY("kvart.dbf","kvart"+m_num+".dbf")
 SET CONSOLE ON
 set printer to
 set printer off
    SAVEPAR(1)
  ENDIF
  RETURN .t.

Function Work104
  LOCAL GetList:={},m_num:=a_menu[1],n,m_sum
  LOCAL m_month1,m_month2,m_koef,m_year,k_pod1,k_pod2
  LOCAL m_kod,m_kopu,m_str1,m_kod1,s_zan,m_gauge,m_078
  LOCAL m_codn,m_koef1,m_recno,m_s_tax1,m_s_dox1,m_s_101,m_st
  LOCAL m_kopu1,m_kopu2

  IF ANSWERu("Формувати звiт; за "+m_num+" квартал")==YES
    SAVEPAR()
    NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
    k_pod1  :=RESTVAR1("k_pod1","ZR")
    k_pod2  :=RESTVAR1("k_pod2","ZR")
    m_078   :=RESTVAR1("m_078","ZR")
    CLOSE myvar
    USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_kopu1:=ALLTRIM(RESTVAR1("m_kopu1","DR"))
    m_kopu2:=ALLTRIM(RESTVAR1("m_kopu2","DR"))
    CLOSE myvar

    CopyZag(m_num)
    DispMessage("Формування звiту; за "+m_num+" квартал")
    IF FILE(m_workpath+"kvart"+m_num+".dbf")
      FERASE(m_workpath+"kvart"+m_num+".dbf")
    ENDIF
    USE (m_workpath+"kvart") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin+STR(fl1->ozn_dox,2) TO (m_workpath+"kvart")
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_year:=PADR(RESTVAR1("m_year","DR"),4)
   CLOSE myvar
    DO CASE
  CASE m_num=="1"
    m_month1:=1;m_month2:=3
    m_date1:=CTOD("01/01/"+RIGHT(m_year,2));m_date2:=CTOD("31/03/"+RIGHT(m_year,2))
  CASE m_num=="2"
    m_month1:=4;m_month2:=6
    m_date1:=CTOD("01/04/"+RIGHT(m_year,2));m_date2:=CTOD("30/06/"+RIGHT(m_year,2))
  CASE m_num=="3"
    m_month1:=7;m_month2:=9
    m_date1:=CTOD("01/07/"+RIGHT(m_year,2));m_date2:=CTOD("30/09/"+RIGHT(m_year,2))
  CASE m_num=="4"
    m_month1:=10;m_month2:=12
    m_date1:=CTOD("01/10"+RIGHT(m_year,2));m_date2:=CTOD("32/12"+RIGHT(m_year,2))
ENDCASE

  NET USE (m_mainpath+"fz3") READONLY  NEW
  NET USE (m_mainpath+"fz2") READONLY  NEW
  NET USE (m_mainpath+"fz1") READONLY  NEW
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY
  m_gauge:=InitGauge("Вибiрка заробiтн. платнi",2)
  DO WHILE .NOT.fz1->(EOF())
      IF mnt_month(fz1->mnt) >= m_month1.AND.mnt_month(fz1->mnt)<=m_month2
         select fz2
         n=RECNO()
         LOCATE REST FOR fz1->vnum1=fz2->vnum1
         IF fz1->vnum1<>fz2->vnum1                  // Нарушена целостность БД ОТСУТСТВУЕТ СВЯЗКА fz1 - fz2
            GO n
            SKIP 1 ALIAS fz1
            LOOP
         ENDIF
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF fz1->vdoc<>38.AND.fz2->tabn<'6000'     // В документе должна быть запись в fz3
               sp10->(DS(fz2->tabn))
               IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
                  m_kod:=" 1"
                ELSE
                  m_kod:=" 2"
                ENDIF
               select fz3
               n=RECNO()
               LOCATE REST FOR fz2->vnum2=fz3->vnum2
               IF fz3->vnum2<>fz2->vnum2               // Нарушена целостность БД ОТСУТСТВУЕТ СВЯЗКА fz2 - fz3
                  GO n
                  SKIP 1 ALIAS fz2
                  LOOP
               ENDIF
               DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())
                   DbFl1(m_kod,fz2->tabn,m_num,m_year)
                    fl1->s_dox1+=fz3->sum
//                    Sp08->(DS(fz3->kopu))
                   DO CASE
                    CASE AT(fz3->kopu,m_kopu1)<>0
                      fl1->land+=fz3->sum
                    CASE AT(fz3->kopu,m_kopu2)<>0
                      fl1->property+=fz3->sum
                    OTHERWISE
                      fl1->zrpl+=fz3->sum
                  ENDCASE


                  SKIP 1 ALIAS fz3
               ENDDO
            ENDIF
            SKIP 1 ALIAS fz2
         ENDDO
      ENDIF
      fz1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fz1->(RECNO())/FZ1->(LASTREC()))
  ENDDO
  CLOSE BASE FZ1,FZ2,FZ3
  DelGauge(m_gauge)
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка виплаченної зарплати ",2)

//set printer to "t1.lst"
// set console to printer
//set printer on




  DO WHILE .NOT.flish->(EOF())
    IF ((Flish->kopu<>"800".AND.VAL(flish->month)>=m_month1.AND.VAL(flish->month)<=m_month2).OR.;
      (flish->kopu=="800".AND.(VAL(flish->month)+1>=m_month1.AND.VAL(flish->month)+1<=m_month2))).AND.flish->tabn<'6000'
      Sp08->(DS(flish->kopu))
      sp10->(DS(flish->tabn))
      m_kod:="  "
      IF (Sp08->p14<>" ".AND.Sp08->p14<>"0").OR.Flish->kopu==m_078.OR.Flish->kopu=='800'
        IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
            IF Sp08->p14=="2"
              m_kod:=" 1"
            ELSE
              m_kod:=" "+Sp08->p14
            ENDIF
         ELSE
              m_kod:=" 2"
         ENDIF
          IF Flish->kopu==m_078.OR.Flish->kopu=="800"
            m_kod:=" 1"
          ENDIF

          DbFl1(m_kod,flish->tabn,m_num,m_year)
          IF flish->kopu==m_078
            fl1->s_101-=flish->sum
          ELSE
            fl1->s_101+=flish->sum
            IF EMPTY(fl1->div).and..NOT.EMPTY(sp08->p14)
              fl1->div:=sp08->p14
            ENDIF

          ENDIF
          // Учесть выплаченную зарплату как 078 текущего месяца - 800 прошлого

      ENDIF

      IF Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2
          sp10->(DS(flish->tabn))
          IF Sp08->kopu==k_pod1
            m_kod:=" 1"
          ELSE
            m_kod:=" 2"
          ENDIF

          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->s_tax1+=Flish->sum
      ENDIF
    ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  SELECT fl1
  INDEX on fl1->tabn TO (m_workpath+"fl1a")
  COPY TO (m_workpath+"kvart"+m_num)
  CLOSE base fl1,sp10,sp08
  USE (m_workpath+"kvart"+m_num) ALIAS fl1 NEW
  INDEX on fl1->tin TO (m_workpath+"kvart"+m_num)

//  DELE FOR fl1->s_101==0
  m_codn:="********"
  m_gauge:=InitGauge("Вибiрка виплаченної зарплати ",2)
  n:=fl1->(LASTREC())
  Fl1->(DBGOTOP())
  m_s_101:=m_s_dox1:=m_s_tax1:=0
  DO WHILE .NOT.fl1->(EOF())

    IF m_codn<>fl1->tin
    m_codn:=fl1->tin
    m_recno:=fl1->(RECNO())
    m_s_101:=m_s_dox1:=m_s_tax1:=0
    m_st:=" "
    DO WHILE m_codn==fl1->tin.AND..NOT.fl1->(EOF())
       m_s_tax1+=fl1->s_tax1
       m_s_dox1+=fl1->s_dox1
       m_s_101+=fl1->s_101
      fl1->(DBSKIP())
    ENDDO
    fl1->(DBGOTO(m_recno))
    IF m_s_101>(m_s_dox1-m_s_tax1)
      m_st:="!"
      m_koef1:=1
    ELSE
      m_koef1:=m_s_101/(m_s_dox1-m_s_tax1)
    ENDIF
    IF m_s_tax1==0
      m_st:="*"
    ENDIF
//       ?m_codn,fl1->tabn, m_s_101,m_s_dox1,m_s_tax1
    ENDIF


    IF m_s_dox1<>0
        m_koef:=fl1->s_101/(m_s_dox1-m_s_tax1)
    ELSE
      fl1->st:="*" // DispError("Помилка на таб. номерi "+fl1->tabn)
      m_koef:=1
    ENDIF
    IF m_koef1>1
      m_koef:=fl1->s_101/m_s_101
      fl1->st:="!"
    ENDIF
    fl1->s_tax :=m_koef*m_s_tax1
    fl1->s_dox:=fl1->s_101 + fl1->s_tax
    IF fl1->ozn_dox=2.and.fl1->div="7"
       fl1->ozn_dox:=7
    ENDIF
    IF fl1->s_dox==0.and.fl1->s_tax1==0.and.fl1->s_101==0
      fl1->(DBDELETE())
    ENDIF
    Fl1->(DBSKIP())
  ENDDO
  PACK
  CLOSE Fl1
//  FILECOPY("kvart.dbf","kvart"+m_num+".dbf")
//set printer to
//set printer off
    SAVEPAR(1)
  ENDIF
  RETURN .t.
STATIC FUNCTION ReadMonths(s_month1,s_month2)
LOCAL N_WIN,GetList:={}
s_month1=s_month1+"       "
s_month2=s_month2+"       "
  n_win:=WOPEN(10,15,22,72)
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE + " " COLOR "w/bg"
  @0,2 SayDisp "Вибiр мiсяцiв" COLOR "n/w"
  SET ESCAPE ON
  SET CURSOR ON
  @02,2 SayDisp "Нарахування>" COLOR "n/bg"
  @03,2 SayDisp "Утримання>" COLOR "n/bg"
  @02,45 SayDisp m_date1 PICTURE "DD/MM/YYYY"  COLOR "n/bg"
  @03,45 SayDisp m_date2 PICTURE "DD/MM/YYYY" COLOR "n/bg"

  @02,20 GET s_month1 PICTURE "XXXXXXXXXXXXXXXX" COLOR "w/b,GR+/N"
  @03,20 GET s_month2 PICTURE "XXXXXXXXXXXXXXXX"  COLOR "w/b,GR+/N"
  READ
  s_month1=ALLTRIM(s_month1)+","
  s_month2=ALLTRIM(s_month2)+","

  WCLOSE(n_win)
  WSELECT(0)


RETURN .t.

Function Work23
  LOCAL GetList:={},m_num:=a_menu[1],n,m_sum
  LOCAL m_month1,m_month2,m_koef,m_year
  LOCAL s_month1,s_month2,s_month
  LOCAL m_codn2
  LOCAL m_kod,m_kopu,m_str1,m_kod1,s_zan,m_gauge
  LOCAL m_kopu1,m_kopu2,m_kopu3,m_kopu4,m_kopu5,k_pod1,k_pod2
  IF ANSWERu("Формувати звiт; за "+m_num+" квартал")==YES
    SAVEPAR()
    CopyZag(m_num)
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
k_pod1  :=RESTVAR1("k_pod1","ZR")
k_pod2  :=RESTVAR1("k_pod2","ZR")
 CLOSE myvar

    DispMessage("Формування звiту; за "+m_num+" квартал")
    IF FILE(m_workpath+"kvart"+m_num+".dbf")
      FERASE(m_workpath+"kvart"+m_num+".dbf")
    ENDIF
    USE (m_workpath+"kvart") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin+STR(fl1->ozn_dox,2) TO (m_workpath+"kvart")
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_year:=PADR(RESTVAR1("m_year","DR"),4)
    CLOSE myvar
    DO CASE
  CASE m_num=="1"
    m_month1:=1;m_month2:=3
    m_date1:=CTOD("01/01/"+RIGHT(m_year,2));m_date2:=CTOD("31/03/"+RIGHT(m_year,2))
    s_month1="1,2,3,"
    s_month2="0,2,3,"
  CASE m_num=="2"
    m_month1:=4;m_month2:=6
    m_date1:=CTOD("01/04/"+RIGHT(m_year,2));m_date2:=CTOD("30/06/"+RIGHT(m_year,2))
    s_month1="4,5,6,"
    s_month2="3,4,5,"
  CASE m_num=="3"
    m_month1:=7;m_month2:=9
    m_date1:=CTOD("01/07/"+RIGHT(m_year,2));m_date2:=CTOD("30/09/"+RIGHT(m_year,2))
    s_month1="7,8,9,"
    s_month2="6,7,8,"
  CASE m_num=="4"
    m_month1:=10;m_month2:=12
    m_date1:=CTOD("01/10"+RIGHT(m_year,2));m_date2:=CTOD("32/12"+RIGHT(m_year,2))
    s_month1="10,11,12,"
    s_month2="9,10,11,"
ENDCASE
// ReadMonths(@s_month1,@s_month2)

  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка сум",2)
  DO WHILE .NOT.flish->(EOF())
      s_month=ALLTRIM(STR(VAL(flish->month),2))+","
      IF AT(s_month,s_month1)<>0.OR.AT(s_month,s_month2)<>0
        Sp08->(DS(flish->kopu))
        Sp10->(DS(flish->tabn))
        IF Sp08->p14<>" ".AND.Sp08->p14<>"0"
          IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
            IF Sp08->p14=="2"
              m_kod:=" 1"
            ELSE
              IF Sp08->p14=="6"
                m_kod:=" 1"
              ELSE
                m_kod:=" "+Sp08->p14
              ENDIF
            ENDIF
          ELSE
              IF Sp08->p14=="6"
                m_kod:=" 6"
              ELSE
                 m_kod:=" 2"
              ENDIF
          ENDIF
          DbFl1(m_kod,flish->tabn,m_num,m_year)
// НАЧИСЛЕННАЯ ЗАРПЛАТА
          IF AT(s_month,s_month1)<>0
              fl1->s_dox+=flish->sum
          ENDIF
// ВЫПЛАЧЕННАЯ ЗАРПЛАТА
          IF m_kod==" 1" // Штатники
            IF Sp08->p14=="6" // пай
              IF AT(s_month,s_month1)<>0
                fl1->s_dox2+=flish->sum
              ENDIF
            ELSE
              IF AT(s_month,s_month2)<>0
                fl1->s_dox2+=flish->sum
              ENDIF
            ENDIF
          ELSE
            IF Sp08->p14=="6" // пай
              IF AT(s_month,s_month1)<>0
                fl1->s_dox2+=flish->sum
                fl1->s_tax2+=INT(flish->sum)*0.2
              ENDIF
            ELSE
              IF AT(s_month,s_month2)<>0
                fl1->s_dox2+=flish->sum
                fl1->s_tax2+=INT(flish->sum)*0.2
              ENDIF
            ENDIF
          ENDIF
    ENDIF
// Подоходный
      IF Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2
          sp10->(DS(flish->tabn))
          IF Sp08->kopu==k_pod1
              m_kod:=" 1"
              DbFl1(m_kod,flish->tabn,m_num,m_year)
              IF AT(s_month,s_month1)<>0
                fl1->s_tax+=flish->sum
              ENDIF
              IF AT(s_month,s_month2)<>0
                fl1->s_tax2+=flish->sum
              ENDIF
          ELSE
            IF AT(s_month,s_month1)<>0
m_codn2:=IF(EMPTY(Sp10->codn),PADR(flish->tabn,10),Sp10->codn)
fl1->(DS(m_codn2+" 6"))
IF .NOT.fl1->(FOUND())
              m_kod:=" 2"
else
              m_kod:=" 6"
endif

              DbFl1(m_kod,flish->tabn,m_num,m_year)
              fl1->s_tax+=flish->sum
            ENDIF
          ENDIF
      ENDIF
    ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  SELECT fl1
  INDEX on fl1->tabn TO (m_workpath+"fl1a")
  COPY TO (m_workpath+"kvart"+m_num)
  CLOSE base fl1,sp10,sp08
  USE (m_workpath+"kvart"+m_num) ALIAS fl1 NEW
/*
  Fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
    fl1->s_tax :=fl1->s_tax1
    fl1->s_dox:=fl1->s_101
    Fl1->(DBSKIP())
  ENDDO
*/
  PACK
  CLOSE Fl1
  SAVEPAR(1)
  ENDIF
  RETURN .t.
/*
function buhmonth(d)
if day(d)>25
 if month(d)=12
  return 1
 else
  return month(d)+1
 endif
endif
return month(d)
Function DbFl3(m_kod,m_tabn,m_num,m_year)
  LOCAL m_codn:=IF(EMPTY(Sp10->codn),PADR(m_tabn,10),Sp10->codn)
fl1->(DS(m_codn+m_kod))
IF .NOT.fl1->(FOUND())
  fl1->(DBAP())
  fl1->period:=VAL(m_num)
  fl1->rik:=VAL(m_year)
  fl1->tabn:=m_tabn
  fl1->tin:=m_codn
  fl1->ozn_dox:=VAL(m_kod)
  IF sp10->(FOUND())
    fl1->kpn:=sp10->kpn
    fl1->kmn:=sp10->kmn
    fl1->fio:=ALLTRIM(sp10->fam)+" "+LEFT(sp10->imja,1)+"."+LEFT(sp10->otch,1)+"."
    IF Sp10->dzch>=m_date1.AND.Sp10->dzch<=m_date2
      fl1->d_priyn:=Sp10->dzch
    ENDIF
    IF Sp10->(FIELDNUM("DUVL"))<>0
      IF Sp10->duvl>=m_date1.AND.Sp10->duvl<=m_date2
        fl1->d_zviln:=Sp10->duvl
      ENDIF
    ENDIF
    Fl1->ozn_pilg:=0
    DO CASE
      CASE sp10->kpn=="1"
        Fl1->ozn_pilg:=0
        DO CASE
          CASE sp10->kmn>="1".AND.sp10->kmn<"3"
            Fl1->ozn_pilg:=1
          CASE sp10->kmn>="3"
            Fl1->ozn_pilg:=5
          ENDCASE
      CASE sp10->kpn=="2"
        Fl1->ozn_pilg:=2
      CASE sp10->kpn=="3"
        Fl1->ozn_pilg:=3
      CASE sp10->kpn=="5"
        Fl1->ozn_pilg:=4
      ENDCASE
  ELSE
    Fl1->ozn_pilg:=-1
    Fl1->kpn:="?"
    Fl1->kmn:="?"
    fl1->fio:="????????????????????"
  ENDIF

ENDIF
RETURN .t.
*/
// Для Ивановки
Function Work15a
  LOCAL GetList:={},m_num:=a_menu[1],n,m_sum,i,j,n1,n2
  LOCAL m_month1,m_month2,m_koef,m_year,k_pod1,k_pod2
  LOCAL m_kod,m_kopu,m_str1,m_kod1,s_zan,m_gauge,m_078
  LOCAL m_codn,m_koef1,m_recno,m_s_tax1,m_s_dox1,m_s_101,m_st,m_pod
  LOCAL m_kopu1,m_kopu2,m_tax,m_dox

  IF ANSWERu("Формувати звiт; за "+m_num+" квартал")==YES
    SAVEPAR()
    NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
    k_pod1  :=RESTVAR1("k_pod1","ZR")
    k_pod2  :=RESTVAR1("k_pod2","ZR")
    m_078   :=RESTVAR1("m_078","ZR")
    CLOSE myvar
    USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_kopu1:=ALLTRIM(RESTVAR1("m_kopu1","DR"))
    m_kopu2:=ALLTRIM(RESTVAR1("m_kopu2","DR"))
    m_year:=PADR(RESTVAR1("m_year","DR"),4)
     CLOSE myvar

    CopyZag(m_num)
    DispMessage("Формування звiту; за "+m_num+" квартал "+m_year+ " р.")
    USE (m_workpath+"kvart") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin TO (m_workpath+"kvart")
    DO CASE
  CASE m_num=="1"
    m_month1:=1;m_month2:=3
    m_date1:=CTOD("01/01/"+RIGHT(m_year,2));m_date2:=CTOD("31/03/"+RIGHT(m_year,2))
  CASE m_num=="2"
    m_month1:=4;m_month2:=6
    m_date1:=CTOD("01/04/"+RIGHT(m_year,2));m_date2:=CTOD("30/06/"+RIGHT(m_year,2))
  CASE m_num=="3"
    m_month1:=7;m_month2:=9
    m_date1:=CTOD("01/07/"+RIGHT(m_year,2));m_date2:=CTOD("30/09/"+RIGHT(m_year,2))
  CASE m_num=="4"
    m_month1:=10;m_month2:=12
    m_date1:=CTOD("01/10"+RIGHT(m_year,2));m_date2:=CTOD("32/12"+RIGHT(m_year,2))
ENDCASE

  NET USE (m_mainpath+"fz3") READONLY  NEW
  NET USE (m_mainpath+"fz2") READONLY  NEW
  NET USE (m_mainpath+"fz1") READONLY  NEW
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY
  m_gauge:=InitGauge("Вибiрка заробiтн. платнi",2)
  DO WHILE .NOT.fz1->(EOF())
      IF mnt_month(fz1->mnt) >= m_month1.AND.mnt_month(fz1->mnt)<=m_month2
         select fz2
         n=RECNO()
         LOCATE REST FOR fz1->vnum1=fz2->vnum1
         IF fz1->vnum1<>fz2->vnum1                  // Нарушена целостность БД ОТСУТСТВУЕТ СВЯЗКА fz1 - fz2
            GO n
            SKIP 1 ALIAS fz1
            LOOP
         ENDIF
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF fz1->vdoc<>38     // В документе должна быть запись в fz3
               sp10->(DS(fz2->tabn))
               IF sp10->kpn=="1".OR.sp10->kpn="2".OR.sp10->kpn="3".OR.sp10->kpn="5"
                  m_kod:=" 1"
                ELSE
                  m_kod:=" 2"
                ENDIF
               select fz3
               n=RECNO()
               LOCATE REST FOR fz2->vnum2=fz3->vnum2
               IF fz3->vnum2<>fz2->vnum2               // Нарушена целостность БД ОТСУТСТВУЕТ СВЯЗКА fz2 - fz3
                  GO n
                  SKIP 1 ALIAS fz2
                  LOOP
               ENDIF
               DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())

                   DbFl1(m_kod,fz2->tabn,m_num,m_year)
//                    Sp08->(DS(fz3->kopu))
                   DO CASE
                    CASE AT(fz3->kopu,m_kopu1)<>0
                      fl1->stm7+=fz3->sum
                    CASE AT(fz3->kopu,m_kopu2)<>0
                      fl1->stm7+=fz3->sum
                    OTHERWISE
                      fl1->stm1+=fz3->sum
                  ENDCASE
                  SKIP 1 ALIAS fz3
               ENDDO
            ENDIF
            SKIP 1 ALIAS fz2
         ENDDO
      ENDIF
      fz1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fz1->(RECNO())/FZ1->(LASTREC()))
  ENDDO
  CLOSE BASE FZ1,FZ2,FZ3
  DelGauge(m_gauge)
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка виплаченної зарплати ",2)

 set printer to "t1.lst"
 set printer on
 SET CONSOLE OFF



  DO WHILE .NOT.flish->(EOF())
    IF (VAL(flish->month)>=m_month1.AND.VAL(flish->month)<=m_month2)
      IF Flish->kopu==k_pod1.OR.Flish->kopu==k_pod2.OR.Flish->kopu='139'
          sp10->(DS(flish->tabn))
          DbFl1(m_kod,flish->tabn,m_num,m_year)
          fl1->taxall+=Flish->sum
      ENDIF
    ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  USE (m_workpath+"kvart"+m_num) ALIAS fl2 NEW
  ZAP
  SELECT fl1

  fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
    ?"fl1->tabn=",fl1->tabn
      fl1->stmall=fl1->stm1+fl1->stm2+fl1->stm3+fl1->stm4+fl1->stm5+fl1->stm6+fl1->stm7+fl1->stm8
   IF fl1->stmall<>0
    ??"<>0",fl1->sumall,fl1->tabn
      // Формирование записей квартальных данных
      m_tax:=m_dox:=n1:=n2:=j:=i:=0
      IF fl1->stm7<>0;  j++;SETBIT(n2,7);  ENDIF
      IF fl1->stm1<>0;  j++;SETBIT(n2,8);  ENDIF
      // если только одно начисление
      m_st:=" "
      IF j==1
        ??"j=1"
        IF fl1->stmall=fl1->sumall+fl1->taxall
          m_tax :=fl1->taxall
          m_dox:=fl1->stmall
        ENDIF
        ??"fl2->dbap"
        fl2->(DBAP())
        fl2->period:=VAL(m_num)
        fl2->rik:=VAL(m_year)
        fl2->tabn:=fl1->tabn
        fl2->tin:=fl1->tin
        fl2->fio:=fl1->fio
        fl2->d_priyn:=fl1->d_priyn
        fl2->d_zviln:=fl1->d_zviln
        fl2->s_tax :=fl1->taxall
        fl2->s_dox:=fl1->stmall
        fl2->st:=m_st

          DO CASE
            CASE fl1->stm1<>0
              IF fl1->kpn<>"4".AND.fl1->kpn<>"6".AND.fl1->kpn<>"7"
                // Основные работники
                fl2->ozn_dox:=1
                Fl2->ozn_pilg:=0
                DO CASE
                  CASE fl1->kpn=="1"
                    Fl2->ozn_pilg:=0
                    DO CASE
                      CASE fl1->kmn>="1".AND.fl1->kmn<"3"
                        Fl2->ozn_pilg:=1
                      CASE fl1->kmn>="3"
                        Fl2->ozn_pilg:=5
                      ENDCASE
                  CASE fl1->kpn=="2"
                    Fl2->ozn_pilg:=2
                  CASE fl1->kpn=="3"
                    Fl2->ozn_pilg:=3
                  CASE fl1->kpn=="5"
                    Fl2->ozn_pilg:=4
                  ENDCASE
              ELSE
                fl2->ozn_dox:=2
              ENDIF
            CASE fl1->stm7<>0
              fl2->ozn_dox:=8
          ENDCASE

      ELSE // Больше одной выплаты
      ??"i<>1"
         m_pod:=fl1->taxall
            m_dox:=0
            m_tax:=0

         IF fl1->stm7<>0 //Выплата не 0
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->ozn_dox:=8
            fl2->s_tax :=fl1->stm7*0.13
            fl2->s_dox:= fl1->stm7
            m_dox:=fl2->s_dox
            m_tax:=fl2->s_tax
        ENDIF
        IF m_dox<>fl1->stmall.OR.m_tax<>fl1->taxall
            ??"rest= ",m_dox,m_tax
            fl2->(DBAP())
            fl2->period:=VAL(m_num)
            fl2->rik:=VAL(m_year)
            fl2->tabn:=fl1->tabn
            fl2->tin:=fl1->tin
            fl2->fio:=fl1->fio
            fl2->d_priyn:=fl1->d_priyn
            fl2->d_zviln:=fl1->d_zviln
            fl2->s_tax :=m_pod-m_tax
            fl2->s_dox:= fl1->stmall-m_dox
             IF fl1->kpn<>"4".AND.fl1->kpn<>"6".AND.fl1->kpn<>"7"
                // Основные работники
                fl2->ozn_dox:=1
                Fl2->ozn_pilg:=0
                DO CASE
                  CASE fl1->kpn=="1"
                    Fl2->ozn_pilg:=0
                    DO CASE
                      CASE fl1->kmn>="1".AND.fl1->kmn<"3"
                        Fl2->ozn_pilg:=1
                      CASE fl1->kmn>="3"
                        Fl2->ozn_pilg:=5
                      ENDCASE
                  CASE fl1->kpn=="2"
                    Fl2->ozn_pilg:=2
                  CASE fl1->kpn=="3"
                    Fl2->ozn_pilg:=3
                  CASE fl1->kpn=="5"
                    Fl2->ozn_pilg:=4
                  ENDCASE
              ELSE
                fl2->ozn_dox:=2
              ENDIF
//        ENDIF
        ENDIF
  ENDIF
  ENDIF

      fl1->(DBSKIP())
  ENDDO
  CLOSE Fl1
  CLOSE Fl2
// FILECOPY("kvart.dbf","kvart"+m_num+".dbf")
  USE (m_workpath+"kvart"+m_num) ALIAS fl1 NEW
  Fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
    fl1->s_tax2 :=fl1->s_tax
    fl1->s_dox2:=fl1->s_dox
    Fl1->(DBSKIP())
  ENDDO
  PACK


 SET CONSOLE ON
 set printer to
 set printer off
    SAVEPAR(1)
  ENDIF
  RETURN .t.

