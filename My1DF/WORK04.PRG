#include "new.ch"
MEMVAR a_menu,m_mainpath,m_sprpath,m_workpath,m_syspath,l_sov
STATIC M_date1,M_date2
Function Work22(m_var1)
  LOCAL GetList:={},m_num:=a_menu[1],n,m_sum,i
  LOCAL m_month1,m_month2,m_koef,m_year
  LOCAL s_month1,s_month2,a_tin:={},s_month3,s_month4
  LOCAL m_kod,m_kopu,m_str1,m_kod1,s_zan,m_gauge
  LOCAL m_plg1,m_pilg1,m_pilg2,m_pilg3,m_078,s_month
  LOCAL m_tin,m_month,m_kpn,m_fio,m_d_priyn,m_d_zviln,m_sum_pilg,m_period
  LOCAL  m_rik,m_tabn,sum_nar:=0,sum_dox,sum_901,sum_taxn,sum_taxp,sum_ved,m_ozn_pilg
  LOCAL m_regim:=IF(EMPTY(m_var1),"0",m_var1)
  LOCAL s1:=0,s2:=0,s3:=0
//  LOCAL m_kopu1,m_kopu2,m_kopu3,m_kopu4,m_kopu5
LOCAL k_pod1,k_pod2,s_sumpod,s_sumn
LOCAL x_pod:=510
  IF ANSWERu("Формувати звiт; за "+m_num+" квартал")==YES
    SAVEPAR()
    CopyZag(m_num)
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  k_pod1  :=RESTVAR1("k_pod1","ZR")
  k_pod2  :=RESTVAR1("k_pod2","ZR")
    m_078   :=RESTVAR1("m_078","ZR")
    x_pod   :=RESTVAR1("x_pod","ZR")
 CLOSE myvar

    DispMessage("Формування звiту; за "+m_num+" квартал")
/*
    IF FILE(m_workpath+"kvart"+m_num+"a.dbf")
      FERASE(m_workpath+"kvart"+m_num+"a.dbf")
    ENDIF
    USE (m_workpath+"kvarta") NEW ALIAS Fl2
    ZAP
*/
    IF FILE(m_workpath+"kvart"+m_num+".dbf")
      FERASE(m_workpath+"kvart"+m_num+".dbf")
    ENDIF
    USE (m_workpath+"kvart") NEW ALIAS Fl1
    ZAP
    INDEX ON fl1->tin+STR(fl1->ozn_dox,2) TO (m_workpath+"kvart")
  USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") ALIAS myvar NEW
    m_pilg1:=RESTVAR1("m_pilg1","DR")
    m_pilg2:=RESTVAR1("m_pilg2","DR")
    m_pilg3:=RESTVAR1("m_pilg3","DR")
    m_year:=PADR(RESTVAR1("m_year","DR"),4)
    s_sumpod:=RESTVAR1("s_sumpod","DR")
    s_sumn:=RESTVAR1("s_sumn","DR")
    m_kod:=RESTVAR1("m_kod","DR")
    CLOSE myvar
  SET PRINTER TO (m_workpath+"01.txt")
  SET CONSOLE OFF
  SET PRINTER ON
    DO CASE
  CASE m_num=="1"
    m_month1:=1;m_month2:=3
    m_date1:=CTOD("01/01/"+RIGHT(m_year,2));m_date2:=CTOD("31/03/"+RIGHT(m_year,2))
    s_month1=",1,2,3,"
    s_month2=",1,2,3,"
    s_month4=",1,2,3,"
    s_month3=",01,02,00,"
  CASE m_num=="2"
    m_month1:=4;m_month2:=6
    m_date1:=CTOD("01/04/"+RIGHT(m_year,2));m_date2:=CTOD("30/06/"+RIGHT(m_year,2))
    s_month1=",4,5,6,"
    s_month2=",4,5,6,"
    s_month4=",4,5,6,"
    s_month3=",04,05,03,"
  CASE m_num=="3"
    m_month1:=7;m_month2:=9
    m_date1:=CTOD("01/07/"+RIGHT(m_year,2));m_date2:=CTOD("30/09/"+RIGHT(m_year,2))
    s_month1=",7,8,9,"
    s_month2=",7,8,9,"
    s_month4=",7,8,9,"
    s_month3=",07,08,06,"
  CASE m_num=="4"
    m_month1:=10;m_month2:=12
    m_date1:=CTOD("01/10/"+RIGHT(m_year,2));m_date2:=CTOD("31/12/"+RIGHT(m_year,2))
    s_month1=",10,11,12,"
    s_month4=",10,11,12,"
    s_month3=",10,11,09,"
ENDCASE
ReadMonths(@s_month1,@s_month2,@s_month3)
IF LASTKEY()=K_ESC
  return
ENDIF

?" Прiйняття i звiльнення з "+DTOS(m_date1)+" по   "+DTOS(m_date2)
?s_month1
?s_month2
?s_month3
//----"+m_num
//["+m_year
// ************"+DTOS(m_date1)+"   "+DTOS(m_date2)

  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW  READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW  READONLY
  NET USE (m_mainpath+"flish") READONLY  NEW
  m_gauge:=InitGauge("Вибiрка сум",2)
  DO WHILE .NOT.flish->(EOF())
  	s_month=","+ALLTRIM(STR(VAL(flish->month),2))+","
      IF AT(s_month,s_month1)<>0.OR.AT(s_month,s_month2)<>0
        Sp08->(DS(flish->kopu))
        Sp10->(DS(flish->tabn))
        IF Sp08->p01=="1".AND.flish->kopu<'100'
          DbFl20()
          fl1->s_nar+=flish->sum
        ENDIF
        IF flish->kopu<>'110'.AND.flish->kopu>='100'.AND.flish->kopu<='500'
          DbFl20()
            fl1->s_dox+=flish->sum
        ENDIF
        IF (Sp08->kopu==k_pod1.OR.Sp08->kopu==k_pod2)
          DbFl20()
            fl1->s_taxn+=flish->sum
            s1+=flish->sum
        ENDIF
        IF flish->kopu == '098'
          DbFl20()
          fl1->sum_ved-=flish->sum
        ENDIF
      ENDIF
      IF AT(flish->month,s_month3)<>0.AND.flish->kopu=='800'
         Sp10->(DS(flish->tabn))
          DbFl20()
          fl1->sum_ved+=flish->sum
       ENDIF
    flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/Flish->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE FLISH
  SELECT fl1
  SET INDEX TO
  INDEX ON fl1->tin+STR(fl1->ozn_dox,2) TO (m_workpath+"kvarta")
  COPY STRUCTURE TO (m_workpath+"kvart"+m_num)
  USE (m_workpath+"kvart"+m_num) ALIAS fl2 NEW
  ZAP
  INDEX ON fl2->tin+STR(fl2->ozn_dox,2)+STR(fl2->ozn_pilg,2) TO (m_workpath+"kvrt"+m_num)
  SELECT fl1
  fl1->(DBGOTOP())
// Очищаем пустые записи
    sum_nar:=0
  DO WHILE .NOT.fl1->(EOF())
    IF  (fl1->s_nar==0) .AND. (fl1->s_dox==0) .AND. (fl1->s_taxn==0) .AND. (fl1->s_taxp==0).AND.(fl1->sum_ved==0)
      Fl1->(DBDELETE())
    ENDIF
    sum_nar+=fl1->s_nar
    fl1->rik:=VAL(m_year)
    Fl1->(DBSKIP())
  ENDDO
// Распределяем подоходный налог
  fl1->(DBGOTOP())
  DO WHILE .NOT.fl1->(EOF())
    m_tin:=fl1->tin
//    m_month:=fl1->month
    m_kpn:=fl1->kpn
    m_fio:=fl1->fam
    m_d_priyn:=fl1->d_priyn
    m_d_zviln:=fl1->d_zviln
    m_sum_pilg:=Fl1->sum_pilg
    IF m_sum_pilg==0
      m_ozn_pilg:=0
    ELSE
      IF m_sum_pilg==m_pilg1
         m_ozn_pilg:=1
      ELSE
        IF m_sum_pilg==m_pilg2
         m_ozn_pilg:=2
        ELSE
          IF m_sum_pilg==m_pilg3
            m_ozn_pilg:=3
          ELSE
            m_ozn_pilg:=0
?"Не известная сумма льготы ",m_sum_pilg," код ",m_tin,"фио",m_fio
//?"Не известная сумма льготы ",m_sum_pilg," код ",m_tin
          ENDIF
        ENDIF
      ENDIF
    ENDIF
//    fl1->s_taxp:=fl1->s_taxn* s_sumpod /s1
    fl1->s_taxp:=fl1->s_taxn
    s2+=fl1->s_taxp
// Распределяем начисления на зар. плату
//sum_ved:=fl1->s_nar*s_sumn /sum_nar
  fl2->(DBAP())
  fl2->NP:=fl2->(RECNO())
//  fl2->PERIOD:=m_period
  fl2->RIK:=VAL(m_year)
  fl2->KOD:=m_kod
  fl2->TYP:=0
  fl2->TIN:=fl1->tin
  fl2->tabn:=fl1->tabn
  fl2->fam:=fl1->fam
  fl2->d_priyn:=fl1->d_priyn
  fl2->d_zviln:=fl1->d_zviln
  fl2->S_NAR:=fl1->s_nar
  fl2->S_DOX :=fl1->S_DOX+fl1->sum_ved
  fl2->sum_ved:=fl1->sum_ved
  fl2->OZN_DOX:=1
  fl2->OZN_PILG:=0
  fl2->s_taxp:=fl1->s_taxp
  fl2->s_taxn:=fl1->s_taxn

    Fl1->(DBSKIP())
ENDDO
//            ?"Надо было распределить подоходного  ",s_sumpod," распределено ",s2
//            ?"Надо было распределить начислений",s_sumn," распределено ",s3
SELE fl2
// INDEX on field->fam +STR(field->ozn_dox,2)  TO (m_workpath+"kvart"+m_num+"a")
// INDEX on field->tin+STR(fl1->ozn_dox,2) TO (m_workpath+"kvart"+m_num+"b")



  SET CONSOLE ON
  SET PRINTER OFF
  SET PRINTER TO



  CLOSE base fl1,sp10,sp08,Fl2
  SAVEPAR(1)
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


function buhmonth(d)
if day(d)>25
 if month(d)=12
  return 1
 else
  return month(d)+1
 endif
endif
return month(d)


STATIC FUNCTION ReadMonths(s_month1,s_month2,s_month3)
LOCAL N_WIN,getlist:={}
s_month1=s_month1+"       "
s_month2=s_month2+"       "
s_month3=s_month3+"       "
  n_win:=WOPEN(10,15,23,72)
  @0,0,MAXROW(),MAXCOL() BOX B_SINGLE + " " COLOR "w/bg"
  @0,2 SayDisp "Вибiр мiсяцiв" COLOR "n/w"
  SET ESCAPE ON
  SET CURSOR ON
  @02,2 SayDisp "Нарахування>" COLOR "n/bg"
  @03,2 SayDisp "Утримання>" COLOR "n/bg"
  @04,2 SayDisp "Плат. вiдомiсть>" COLOR "n/bg"
//  @05,2 SayDisp "Прикази >" COLOR "n/bg"
  @02,20 GET s_month1 PICTURE "XXXXXXXXXXXXXXXX" COLOR "w/b,GR+/N"
  @03,20 GET s_month2 PICTURE "XXXXXXXXXXXXXXXX"  COLOR "w/b,GR+/N"
  @04,20 GET s_month3 PICTURE "XXXXXXXXXXXXXXXX"  COLOR "w/b,GR+/N"
//  @05,20 GET s_month4 PICTURE "XXXXXXXXXXXXXXXX"  COLOR "w/b,GR+/N"
  READ
  s_month1=ALLTRIM(s_month1)
  s_month2=ALLTRIM(s_month2)
  s_month3=ALLTRIM(s_month3)
//  s_month4=ALLTRIM(s_month4)
  WCLOSE(n_win)
  WSELECT(0)


RETURN .t.


Function DbFl20()
  LOCAL m_codn:=IF(EMPTY(Sp10->codn),PADL(sp10->tabn,10),Sp10->codn)

fl1->(DS(m_codn))
IF .NOT.fl1->(FOUND())
IF EMPTY(Sp10->codn)
  ?"Кто код будет заполнять для таб. номера",Sp10->tabn
  IF EMPTY(m_codn)
    m_codn:="-1"+Sp10->tabn
  ENDIF
ENDIF

  fl1->(DBAP())
  fl1->tabn:=sp10->tabn
  fl1->tin:=m_codn
  IF sp10->(FOUND())
    fl1->kpn:=sp10->kpn
    fl1->fam:=ALLTRIM(sp10->fam)+" "+LEFT(sp10->imja,1)+"."+LEFT(sp10->otch,1)+"."
    IF Sp10->dzch>=m_date1.AND.Sp10->dzch<=m_date2
      fl1->d_priyn:=Sp10->dzch
      ?" Новий працiвник "+sp10->tabn+" "+DTOS(Sp10->dzch)
    ENDIF
    IF Sp10->(FIELDNUM("DUVL"))<>0
      IF Sp10->duvl>=m_date1.AND.Sp10->duvl<=m_date2
      ?" Звiльнено "+sp10->tabn+" "+DTOS(Sp10->duvl)
        fl1->d_zviln:=Sp10->duvl
      ENDIF
    ENDIF
    Fl1->sum_pilg:=sp10->sumpod
  ELSE
    Fl1->kpn:="?"
    fl1->fam:="????????????????????"
  ENDIF
ENDIF
RETURN .t.
