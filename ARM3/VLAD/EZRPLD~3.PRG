#include "NEW.ch"
#DEFINE N_POD 1
#DEFINE N_PEN 2
#DEFINE N_PRF 3
#DEFINE N_ISP 4
#DEFINE N_BOLN 5
#DEFINE N_STRAH 6
MEMVAR m_mainpath,m_sprpath,m_syspath,m_bufpath,m_temppath,m_level,m_mash
MEMVAR m_imja,m_copypath
Function  Zarpl (var1)
   LOCAL m_month       := 0       /* введенный бухгалтерский месяц */
   LOCAL m_month1      := 0       /* бухгалтерский месяц,
                                     за который выполнялся расчет */
   LOCAL s_month       := '00'    /* введенный бухгалтерский месяц
                                     ( символьный) */
   LOCAL next_month    := 0       /* следующий бухгалтерский месяц */
   LOCAL SumProfsojuz  := 0       /* сумма профсоюзных взносов */
   LOCAL SumPensija    := 0       /* сумма начисленной пенсии */
   LOCAL SumPensNalog  := 0       /* налог в пенсионный фонд */
   LOCAL SumNalog2  := 0       /* налог в пенсионный фонд */
//   LOCAL SumZan        := 0       /* В фонд занятости */
   LOCAL Sum09         := 0       /* удержания по справочнику sp09 */
   LOCAL m_tabn1,i,m_097,m_110,SumPod2:=0
   LOCAL m_proc1,m_proc2,m_fcsh,m_fshzp
   LOCAL m_sum,m_sum01,m_numr,SumPodohod:=0,SumPcht,k_pcht,s_mtp
   LOCAL  k_isp1,k_isp2,k_prf,k_mtp,m_078,ll
   LOCAL s_pens1:=0,s_pens2:=0,s_pens3:=0,s_pens4:=0,s_pens5:=0
   LOCAL k_pod1,k_pod2
   LOCAL k_pen1,k_pen2,k_pen3,k_pen4,k_pen5
   LOCAL x_pens1:=0,x_pens2:=0,x_pens3:=0,x_pens4:=0,x_pens5:=0
   LOCAL n_pens1:=0,n_pens2:=0,n_pens3:=0,n_pens4:=0,n_pens5:=0
   LOCAL x_kvo1:=0,x_kvo2:=0,sum_boln:=0
   LOCAL k_strah3,s_strah3:=0,x_strah3:=0
   LOCAL x_pod:=510,p_pod:=15
   LOCAL p_minimum:=525
   LOCAL n_prof:=0.01,m_mnt,l_first
   LOCAl l_sov  :=.T.,l_f1,a_sp08:={},j,k_nat,s_nat
	// !!!!! ВНИМАНИЕ  КОНТРОЛЬ ЗА СООТВЕТСТВИЕМ ДАННЫХ ТАБЛИЦ
	//       ПОДОХОД. НАЛОГА И РАЗМЕРОМ МАССИВА
   LOCAL a_tab1:={},a_tab2:={}
   LOCAL nMinAlim:=0,m_message,m_dbt:=0,m_crt:=0
   LOCAL   s_ind:=0,s_inc:=0,s_db:=0
   LOCAL   s_cr:=0,s_outd:=0,s_outc:=0
   LOCAL  x_podoh:=0,x_pens:=0
   LOCAL x_800:=0
   LOCAL  s_SumAll:=0,s_sovm:=0,s_podoh:=0,s_pens:=0
   LOCAL  s_podoha:=0
   LOCAL x_isp:=0,x_prof:=0,k_boln:="141",s_boln:=15
   LOCAL x_strah0:=0,predelPod:=0
   LOCAL m_maxpredel:=0
   LOCAL s_mode:=IF(EMPTY(var1),"",var1)
   Local m_kpn

IF m_level<>0
  DispError("Ви не маєте повноважень на запуск цiєї програми")
  RETURN .F.
ENDIF
   //начальное присвоение подоходных таблиц
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW READONLY
  i:=1
  DO WHILE .NOT.sp08->(EOF()).AND.sp08->kopu<"100"
    AADD(a_sp08,{sp08->kopu,0,sp08->name8})
    // подоходный
    IF sp08->p01=="1" ;a_sp08[i,2]:=SETBIT(a_sp08[i,2],1); ENDIF
    //пенсионный
    IF sp08->p02=="1" ;a_sp08[i,2]:=SETBIT(a_sp08[i,2],N_PEN); ENDIF
    IF sp08->p02=="2" ;a_sp08[i,2]:=SETBIT(a_sp08[i,2],N_BOLN); ENDIF
     // профсоюзный
    IF sp08->p03=="1" ;a_sp08[i,2]:=SETBIT(a_sp08[i,2],3); ENDIF
    // исполнительный
    IF sp08->p04=="1" ;a_sp08[i,2]:=SETBIT(a_sp08[i,2],4); ENDIF
    // Фонд занятости
    //    IF sp08->p08=="1" ;a_sp08[i,2]:=SETBIT(a_sp08[i,2],5); ENDIF
    // Фонд соцстраха
    //IF sp08->p18=="1" ;a_sp08[i,2]:=SETBIT(a_sp08[i,2],6); ENDIF
    // подоходный - пай
    IF sp08->p01=="2" ;a_sp08[i,2]:=SETBIT(a_sp08[i,2],7); ENDIF
    sp08->(DBSKIP()); i++
  ENDDO
  NET USE (m_sprpath+"sp26")  NEW READONLY
  	sp26->(DBEVAL({||AADD(a_tab1,{sp26->level,sp26->const,sp26->prc/100})}))
  CLOSE sp26
  NET USE (m_sprpath+"sp27")  NEW
  	sp27->(DBEVAL({||AADD(a_tab2,{sp27->level,sp27->const,sp27->prc/100})}))
  CLOSE sp27

  nMinAlim:=17

NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
x_pod   :=RESTVAR1("x_pod","ZR")
p_pod   :=RESTVAR1("p_pod","ZR")
p_minimum:=RESTVAR1("p_minimum","ZR")

k_prf   :=RESTVAR1("k_prf","ZR")
k_pen1  :=RESTVAR1("k_pen1","ZR")
k_pen2  :=RESTVAR1("k_pen2","ZR")
k_pen3  :=RESTVAR1("k_pen3","ZR")
k_pen4  :=RESTVAR1("k_pen4","ZR")
k_pen5  :=RESTVAR1("k_pen5","ZR")

n_pens1  :=RESTVAR1("n_pens1","ZR")
n_pens2  :=RESTVAR1("n_pens2","ZR")
n_pens3  :=RESTVAR1("n_pens3","ZR")
n_pens4  :=RESTVAR1("n_pens4","ZR")
n_pens5  :=RESTVAR1("n_pens5","ZR")


k_pod1  :=RESTVAR1("k_pod1","ZR")
k_pod2  :=RESTVAR1("k_pod2","ZR")
k_isp1  :=RESTVAR1("k_isp1","ZR")
k_isp2  :=RESTVAR1("k_isp2","ZR")
k_pcht  :=RESTVAR1("k_pcht" ,"ZR")
n_prof  :=RESTVAR1("n_prof" ,"ZR")
m_sum01 :=RESTVAR1("m_sum01","ZR")
m_097   :=RESTVAR1("m_097"  ,"ZR")
m_110   :=RESTVAR1("m_110"  ,"ZR")
m_078 :=RESTVAR1("m_078","ZR")
l_sov   :=RESTVAR1("l_sov"  ,"ZR")
m_month1:=RESTVAR1("m_month","ZR")
m_numr  :=RESTVAR1("m_numr" ,"ZR")
k_boln   :=RESTVAR1("k_boln"   ,"ZR")
s_boln   :=RESTVAR1("s_boln"   ,"ZR")
m_maxpredel:=RESTVAR1("m_maxpredel"   ,"ZR")
if m_maxpredel==0
	m_maxpredel:=8520
ENDIF
//x_strah0  :=RESTVAR1("x_strah","ZR")

next_month := If ( m_month1 == 12 , 1 , m_month1 + 1 )

   // Разрешается перерасчет ( m_month == m_month1 )  или расчет
   // за следующий месяц ( m_month == next_month )
ll=GetTypeCalc()
IF ll==1 
	s_mode:='AVANS'
ENDIF	

   DO WHILE m_month != m_month1 .AND. m_month != next_month
      m_month := GetMonth1(m_month1,next_month)
      IF m_month == -1          // Если вышли по <ESC>, то возврат в меню
         CLOSE myvar
         RETURN .f.
      ENDIF
   ENDDO
   
  IF m_month==m_month1
    m_numr:=m_numr+1
    l_f1:=.f.
  ELSE
    m_numr:=1
    l_f1:=.t.
  ENDIF
   SAVEVAR1("m_month",m_month,"ZR")
   SAVEVAR1("m_numr",m_numr,"ZR")
   CLOSE myvar
   s_month := StrZero ( m_month, 2 )
   next_month := m_month + 1
    @1,20,6,61 BOX B_DOUBLE+" " COLOR "w+/BG"
    @3,21 SayDISp PADC(' Розрахунок зарплати ',40) COLOR "gr+/bg"
    @4,21 SayDISP PADC(' за '+NTOCMONTH(m_month)+' мiсяць',40)  COLOR "gr+/BG"
   IF ANSWERu('"Перекачати" БД за мiсяць в БД з початку року (1-а частина)')==YES
    IF .NOT. Perek()
      RETURN .F.
    ENDIF
   ENDIF
   OpenFl(s_month,m_month)
   Udal(s_month,next_month,m_110,m_097)
   // по файлам fz1, fz2, fz3 формируем файлы flish0, flish1
//   evodarenda()
   SELECT fz1
   GOTO TOP
   m_proc1 := InitGauge ("Вибiрка нарахувань по первiчних документах",1)
   m_proc2 := InitGauge ( "Розрахунок утримань",2 )
   DO WHILE ! fz1->( Eof () )
      IF mnt_month ( fz1->mnt ) == m_month
         m_mnt:=IF(MONTH(fz1->ddoc)==m_month,SPACE(4),mnt_dtod(fz1->ddoc))
         IF pFilPoz ( 'fz2' , 'vnum1' , 'fz1' )
            DO WHILE fz2->vnum1 == fz1->vnum1 .AND. !fz2->(EOF())
               // проходим по записям fz2, связанным с текущей записью fz1
               Sp10->(DS(fz2->tabn))
              IF .NOT.flish1->(DS(fz2->tabn))
                flish1->(DBAP())
                flish1->tabn:=fz2->tabn
                x_kvo1++
              ENDIF
               flish1->otdn+=fz2->otdn
               flish1->oths+=fz2->oths
              IF .NOT.fnpch->(DS(fz2->tabn))
                fnpch->(DBAP())
                fnpch->tabn:=fz2->tabn
                fnpch->month:=s_month
              ENDIF
              IF AT(STR(fz1->npch,3),fnpch->n1)==0
                fnpch->n1:=ALLTRIM(fnpch->n1)+STR(fz1->npch,3)+","
              ENDIF

               IF fz1->vdoc != 38
                  // не эксплуатация автопарка
                  l_first:=.t.
                  IF pFilPoz ( 'fz3' , 'vnum2' , 'fz2' )
                     DO WHILE fz3->vnum2 == fz2->vnum2 .AND. !fz3->(EOF())
                        // проходим по записям fz3, связанным
                        // с текущей записью fz2
                        IF .NOT. flish0->(DS(fz2->tabn + fz3->kopu + m_mnt +"Z" ))
                          flish0->(DBAP())
                          flish0->mnt:=m_mnt
                          flish0->tabn  := fz2->tabn
                          flish0->kopu  := fz3->kopu
                          flish0->month := s_month
                          flish0->st    :="Z"
                        ENDIF
                        flish0->sum   += fz3->sum
                        IF l_first
                          flish0->otdn+=fz2->otdn
                          flish0->oths+=fz2->oths
                          l_first:=.f.
                        ENDIF
                        IF fz3->sum<>0
                          s_sumall+=fz3->sum
                          IF sp10->kpn=="4".OR.sp10->kpn=="6".OR.sp10->kpn=="7"
                            s_sovm+=fz3->sum
                          ENDIF
                          j:=ASEEK(@a_sp08,fz3->kopu)
                          IF j<>0
                            IF ISBIT(a_sp08[j][2],N_POD); flish1->sum1+=fz3->sum; s_podoh+=fz3->sum ; ENDIF
                            IF ISBIT(a_sp08[j][2],7); flish1->sum1a+=fz3->sum; s_podoha+=fz3->sum ; ENDIF
                            IF ISBIT(a_sp08[j][2],N_PRF); flish1->sum2+=fz3->sum;ENDIF
                            IF ISBIT(a_sp08[j][2],N_PEN); flish1->sum5+=fz3->sum; s_pens+=fz3->sum ; ENDIF
                            IF ISBIT(a_sp08[j][2],N_BOLN); flish1->sum3+=fz3->sum; sum_boln+=fz3->sum ; ENDIF
                            IF ISBIT(a_sp08[j][2],N_ISP); flish1->sum7+=fz3->sum; ENDIF
                          ENDIF
                           // сумма к получению
                          flish1->sum4 += fz3->sum
                          s_cr+=fz3->sum
                        ENDIF
                        fz3->(dbskip())
                     ENDDO
                  ENDIF
                ELSE
                  IF fz2->otdn<>0.AND.fz2->oths<>0
                    IF .NOT.flish0->(DBSEEK(fz2->tabn + "000" + m_mnt +"Z" ))
                      flish0->(DBAPPEND())
                      flish0->mnt   :=m_mnt
                      flish0->tabn  :=fz2->tabn
                      flish0->kopu  :="000"
                      flish0->month := s_month
                      flish0->st    :="Z"
                    ENDIF
                    flish0->otdn+=fz2->otdn
                    flish0->oths+=fz2->oths
                  ENDIF
                  l_first:=.f.
              ENDIF
             fz2->(DBSKIP())
            ENDDO
         ENDIF
      ENDIF
      fz1->(dbskip())
      m_proc1:=DispGauge( m_proc1 , Fz1->(RECNO()/LASTREC()))
   ENDDO
   m_proc1:=DispGauge ( m_proc1 , 1.00 )

   // дописываем в файлы flish и удаляем файл flish0

   SELECT  Flish0
   DELE FOR flish0->sum==0.and.flish0->otdn==0.and.flish0->oths==0
   CLOSE flish0
   SELECT flish
   APPEND FROM (m_temppath+"flish0")
   // расчет налогов и удержаний
   x_kvo1:=flish1->(LASTREC())
   flish1->(DBGOTOP())
   m_fshzp := flish1->( LastRec () ) * 3
   m_fcsh  := 0
   DO WHILE ! flish1->( Eof () )
      m_tabn1 := flish1->tabn
      IF .NOT.sp10->(DBSEEK(m_tabn1))
        DispError("Не знайден у довiднику працiвникiв;таб. номер "+m_tabn1)
      ENDIF

      // расчет профсоюзных взносов
      SumProfsojuz := 0
      IF sp10->kvz == '1'.AND.flish1->sum2>0
        SumProfsojuz := ROUND(n_prof * flish1->sum2,2)
        Dob1(SumProfsojuz,k_prf,flish1->sum2,'910',m_tabn1,s_month,"911")
      ENDIF
      x_prof+=SumProfsojuz
      

      SumPensNalog :=0
      SumNalog2 :=0
      DO CASE
               CASE sp10->kpn=="6".OR.sp10->kpn=="7" //по договорам
                   m_kpn:="2"		
               CASE sp10->inv=="1" // инвалиды
                   m_kpn:="1"
              OTHERWISE   // основные работники
                  m_kpn:="0"
      ENDCASE
      		
      // расчет налога в пенсионный фонд
    IF flish1->sum5>0
    	if flish1->sum5 > m_maxpredel
		flish1->sum5 := m_maxpredel
	ENDIF
      DO CASE
               CASE m_kpn=='0'
               		SumPensNalog :=ROUND(n_pens1 * flish1->sum5,2)
               		x_pens1+=SumPensNalog
               		s_pens1+=flish1->sum5
               		Dob1(SumPensNalog,k_pen1,flish1->sum5,"921",m_tabn1,s_month,"931")
               CASE m_kpn=='1'
               		SumPensNalog :=ROUND(n_pens2 * flish1->sum5,2)
               		x_pens2+=SumPensNalog
               		s_pens2+=flish1->sum5
               		Dob1(SumPensNalog,k_pen2,flish1->sum5,"922",m_tabn1,s_month,"932")
               CASE m_kpn=='2'
               		SumPensNalog :=ROUND(n_pens3 * flish1->sum5,2)
               		x_pens3+=SumPensNalog
               		s_pens3+=flish1->sum5
               		Dob1(SumPensNalog,k_pen3,flish1->sum5,"923",m_tabn1,s_month,"933")
      ENDCASE
    ENDIF
    IF flish1->sum3>0  // больничные 
      DO CASE
               CASE m_kpn=='0'
               		SumNalog2 :=ROUND(n_pens4 * flish1->sum3,2)
               		x_pens4+=SumNalog2
               		s_pens4+=flish1->sum3
               		Dob1(SumNalog2,k_pen4,flish1->sum3,"924",m_tabn1,s_month,"934")
               CASE m_kpn=='1'
               		SumNalog2 :=ROUND(n_pens5 * flish1->sum3,2)
               		x_pens5+=SumNalog2
               		s_pens5+=flish1->sum3
               		Dob1(SumNalog2,k_pen5,flish1->sum3,"925",m_tabn1,s_month,"935")
       ENDCASE
    ENDIF	

// Расчет подоходного налога
    SumPodohod:=0
IF  sp10->kpn == '4'.OR.sp10->kpn == '6'.OR.sp10->kpn == '7'  // Совместители и паевики
   SumPodohod:=ROUND((flish1->sum1-SumPensNalog-SumNalog2)*(p_pod/100),2)
   x_podoh+=SumPodohod
   IF SumPodohod > 0
    FlishAp(s_month,m_tabn1,k_pod2, 0,0,SumPodohod,"","")
    flish1->sum4-=SumPodohod
   ENDIF
   FlishAp(s_month,m_tabn1,"902",0,0,flish1->sum1,"!","")
//   FlishAp(s_month,m_tabn1,"952",0,0,flish1->sum1,"!","")
  // ПОДОХОДНЫЙ С ПАЯ
  IF (flish1->sum1a>0)
    SumPod2:=ROUND(flish1->sum1a*(p_pod/100),2)
    IF SumPod2 > 0
      FlishAp(s_month,m_tabn1,k_pod2,0,0,SumPod2,"","")
      flish1->sum4-=SumPod2
      FlishAp(s_month,m_tabn1,"903",0,0,flish1->sum1a,"!","")
    ENDIF
   ENDIF
  SumPodohod+=SumPod2
ELSE
	// Льгота
	IF (s_mode!='AVANS')
	predelPod:=x_pod
		IF VAL(sp10->kmn)>0
			predelPod:=x_pod*VAL(sp10->kmn)
		ENDIF
	ELSE
		predelPod=0
	ENDIF	
	m_sum :=flish1->sum1+flish1->sum1a
	IF (m_sum>predelPod)
		SumPodohod:=ROUND((m_sum-SumPensNalog-SumNalog2)*(p_pod/100),2)
	ELSE
		SumPodohod:=ROUND((m_sum-SumPensNalog-SumNalog2-sp10->sumPod)*(p_pod/100),2)
		IF SumPodohod<0
			SumPodohod:=0
		ENDIF
	ENDIF
	x_podoh+=SumPodohod
	IF SumPodohod > 0
		FlishAp(s_month,m_tabn1,k_pod1,0,0,SumPodohod,"","")
		flish1->sum4-=SumPodohod
	ENDIF
	FlishAp(s_month,m_tabn1,'901',0,0,m_sum,"!","")
//	FlishAp(s_month,m_tabn1,'951', 0,0,m_sum,"!","")
ENDIF
      // расчет исполнительных листов SP15
      IF Sp15->(DBSEEK(m_tabn1))
         DO WHILE sp15->tabn == m_tabn1 .AND. ! sp15->(Eof())
            m_sum:=Sum09 :=SumPcht:=0
            IF sp15->month < m_month;sp15->(DBSKIP());LOOP;ENDIF
            IF AT(sp15->kopu,k_isp2)==0              /* не алименты */
               IF sp15->procent<>0
                m_sum:=flish1->sum7
                Sum09 := ROUND(m_sum*sp15->procent * 0.01,2)
// Модификация для Комсомольца вычет больничных

                IF (sp15->kopu==k_boln)
                  IF m_sum>s_boln
                    m_sum:=s_boln
                  ENDIF
                ENDIF
//

              ELSE
                Sum09 := Sp15->sum
              ENDIF
            ELSE                                    /* если алименты */
               m_sum:=flish1->sum7-SumPodohod-SumPensNalog
//               m_sum:=flish1->sum7-SumPodohod

               nMinAlim:=a_tab1[1,1]*0.5
               IF sp15->procent<>0
                Sum09 := ROUND(Max ( nMinAlim, ( m_sum * sp15->procent * 0.01) ),2)
              ELSE
                Sum09 := Sp15->sum
              ENDIF
            ENDIF
            SumPcht:=ROUND(Sum09*sp15->prc1 * 0.01 * 1.2 ,2) // ???????? ПДВ
            AppAlim(Sp15->num,m_tabn1,Sp15->procent,Sp15->mnt,Sp15->prc1,;
            m_month,Sp15->fam,Sp15->addr,Sp15->kopu,flish1->otdn,Flish1->sum7,;
            SumPodohod,Sum09,SumPcht,m_sum)
            IF sum09 <> 0
               FlishAp(s_month,m_tabn1,sp15->kopu,0,0,sum09,"","");flish1->sum4 -=flish->sum
            ENDIF
            IF SumPcht<>0
               FlishAp(s_month,m_tabn1,k_pcht,0,0,SumPcht,"","");flish1->sum4 -=flish->sum
             ENDIF
             sp15->(DBSKIP())
             x_isp+=sum09+SumPcht
         ENDDO
      ENDIF
      flish1->(DBSKIP())
      m_proc2:=DispGauge( m_proc2 ,  ( m_fcsh++ ) / m_fshzp )
   ENDDO
   m_proc2 := DispGauge ( m_proc2 , 0.33 )
   // расчет удержаний ( фиксированные суммы ) по справочнику sp15
   sp09->(DBGOTOP())
  DO WHILE sp09->kopu < '100' .AND..NOT. Sp09->(Eof())
      sp09->(DBSKIP())                    /* не используем доплаты */
  ENDDO
   DO WHILE ! Sp09->(Eof ())
      Sum09 := 0
      IF sp09->month < s_month.OR.sp09->procent != 0
         // если последний месяц удеpжаний ( доплат ) по спpавочнику sp09
         // меньше, чем введенный бухгалтеpский месяц, то не удеpживаем
         // ( не доплачиваем ), а пеpеходим на следующую запись.
         // проценты не удерживаем
         sp09->(DBSKIP())
         LOOP
      ENDIF
         Sum09 := sp09->sum
      IF sum09 > 0
         // высчитываем удержание из суммы к получению
        IF .NOT.flish1->(DS(sp09->tabn))
          flish1->(DBAP())
          flish1->tabn:=sp09->tabn
        ENDIF
        flish1->sum4 -=Sum09
         FlishAp(s_month,sp09->tabn,sp09->kopu,0,0,sum09,"","")
         x_isp+=flish->sum
      ENDIF
      sp09->(DBSKIP())
   ENDDO

   // добавляю из файлов fd1 и fd2 записи за текущий месяц
   // в файлы flish ( все записи, если новый расчет, и все записи, кроме
   // кодов '097' и '110', если перерасчет ) и flish1 ( все записи, кроме
   // кодов '097' и '110' )
   flish1->(DBGOTOP())
   DO WHILE .NOT.flish1->(EOF())
    flish1->sum3:=flish1->sum4
    flish1->(DBSKIP())
  ENDDO
   USE (m_temppath+"flish0") NEW
   ZAP
   INDEX ON flish0->tabn + flish0->kopu +flish0->mnt+flish0->st TO (m_temppath+"flish0")
   SELECT fd1
   GOTO TOP
   m_fshzp := fd1->( LastRec () ) * 3
   m_fcsh  := 0
   DO WHILE ! fd1->( Eof () )
      IF mnt_month ( fd1->mnt ) == m_month
         m_mnt:=IF(MONTH(fd1->ddoc)==m_month,SPACE(4),mnt_dtod(fd1->ddoc))
         IF pFilPoz ( 'fd2' , 'vnuma' , 'fd1' )
            DO WHILE fd1->vnuma == fd2->vnuma.AND..NOT.fd2->(EOF())
               IF fd2->sum != 0 .AND. ( m_month != m_month1 .OR.;
                                        ( m_month == m_month1 .AND.;
                                          fd1->kopu != m_097 .AND.;
                                          fd1->kopu != m_110 ) )
                        IF .NOT. flish0->(DS(fd2->tabn + fd1->kopu + m_mnt+fd1->paj ))
                          flish0->(DBAP())
                          flish0->mnt:=m_mnt
                          flish0->tabn  := fd2->tabn
                          flish0->kopu  := fd1->kopu
                          flish0->month := s_month
                          flish0->st    := fd1->paj
                        ENDIF
                        flish0->sum   +=fd2->sum
                        flish0->otdn  +=fd2->kvo
                        flish0->oths  +=fd2->glv

                  IF fd1->kopu != m_097 .AND. fd1->kopu != m_110
                     IF .NOT.Flish1->(DS(fd2->tabn))
                      Flish1->(DBAP())
                      Flish1->tabn:=Fd2->tabn
                    ENDIF
                     flish1->sum4+=If(fd1->kopu<'100',fd2->sum,If(fd1->kopu<='500',-fd2->sum,0))
                     IF fd1->kopu != m_078
                      flish1->sum3+=If(fd1->kopu<'100',fd2->sum,If(fd1->kopu<='500',-fd2->sum,0))
                     ENDIF
                  ENDIF
                ENDIF
               IF fd1->kopu==m_078
                s_inc+=fd2->sum
               ENDIF
               IF fd1->kopu>="100"
                s_db+=fd2->sum
              ELSE
                s_cr+=fd2->sum
              ENDIF
              IF .NOT.fnpch->(DS(fd2->tabn))
                fnpch->(DBAP())
                fnpch->tabn:=fd2->tabn
                fnpch->month:=s_month
              ENDIF
              IF AT(STR(fd1->npch,3),fnpch->n2)==0
                fnpch->n2:=ALLTRIM(fnpch->n2)+STR(fd1->npch,3)+","
              ENDIF
              IF AT(fd1->kopu,k_isp1+","+k_isp2)<>0
                AppAlim("",fd2->tabn,0,mnt_dtod(fd1->ddoc),0,m_month,"","",fd1->kopu,0,0,;
                0,fd2->sum,0,0)
              ENDIF
               fd2->(DBSKIP())
            ENDDO
         ENDIF
      ENDIF
      SELECT fd1
      SKIP
      m_proc2:=DispGauge(m_proc2 ,0.33 + ( m_fcsh++ ) / m_fshzp )
   ENDDO

   SELECT  Flish0
   DELE FOR flish0->sum==0.and.flish0->otdn==0.and.flish0->oths==0
   CLOSE flish0
   SELECT flish
   APPEND FROM (m_temppath+"flish0")


   m_proc2:=DispGauge ( m_proc2 , 0.67 )

   // добавляю в flish1 остаток прошлого месяца из flish ( коды '097' и '110' )
   flish1->(DBGOTOP())
   DO WHILE .NOT.flish1->(EOF())
    IF flish1->sum3<>0
      FlishAp(s_month,flish1->tabn,'801',0,0,flish1->sum3,"","")
    ENDIF
    flish1->(DBSKIP())
  ENDDO

   flish->(DBGOTOP())
   DO WHILE ! flish->( Eof () )

      IF flish->month == s_month
         IF flish->kopu == m_097
            IF .NOT.Flish1->(DS(flish->tabn))
               Flish1->(DBAP())
               flish1->tabn := flish->tabn
            ENDIF
            flish1->sum4+=flish->sum
//            flish1->inc+=flish->sum
            s_inc+=flish->sum
         ELSEIF flish->kopu == m_110
            IF .NOT.Flish1->(DS(flish->tabn))
               Flish1->(DBAP())
               flish1->tabn := flish->tabn
            ENDIF
            s_ind+=flish->sum
            flish1->sum4-=flish->sum
//            flish1->ind:=flish->sum
         ENDIF
      ENDIF

      flish->(DBSKIP())
   ENDDO

   // записываю сумму к получению и остатки в файл flish

   flish1->(DBGOTOP())
   m_fshzp := flish1->( LastRec () ) * 3
   m_fcsh  := 0
   DO WHILE ! flish1->( Eof () )
      IF flish1->sum4>0
        s_outc+=flish1->sum4
      ELSE
        IF flish1->sum4<0
          s_outd+=ABS(flish1->sum4)
        ENDIF
      ENDIF
      IF flish1->sum4 >= m_sum01
              FlishAp(s_month,flish1->tabn,'800',0,0,ROUND(Int ( flish1->sum4/m_sum01 )*m_sum01,2),"","")
              x_800+=flish->sum
              Flish1->sum4:=Flish1->sum4 - flish->sum
              sp10->(DBSEEK(flish->tabn))
              IF .NOT.sp10->(FOUND())
                Sp10->(DBAPPEND())
                Sp10->tabn:=flish->tabn
              ENDIF
              IF Sp10->(NetRlock())
                Sp10->sum1:=flish->sum
                Sp10->(dbUnlock())
              ENDIF
              IF flish1->sum4<>0
                  FlishAp(StrZero ( m_month+1 , 2 ),flish1->tabn,m_097,0,0,flish1->sum4,"","")
              ENDIF
      ELSE
         IF flish1->sum4 > 0
            FlishAp(StrZero ( m_month+1 , 2 ),flish1->tabn,m_097,0,0,flish1->sum4,"","")
         ELSE
            IF flish1->sum4 <> 0
               FlishAp(StrZero ( m_month+1 , 2 ),flish1->tabn,m_110,0,0,Abs ( flish1->sum4 ),"","")
              IF .NOT.sp10->(DBSEEK(flish->tabn))
                Sp10->(NetDBAP())
                Sp10->tabn:=flish->tabn
                Sp10->sum1:=-flish->sum
                Sp10->(DbUnlock())
              ELSE
                IF Sp10->(NetRlock())
                  Sp10->sum1:=-flish->sum
                  Sp10->(DbUnlock())
                ENDIF
              ENDIF
            ENDIF
         ENDIF
      ENDIF
      x_kvo2++
      flish1->(DBSKIP())
      m_proc2:=DispGauge ( m_proc2 , 0.67 + ( m_fcsh++ ) / m_fshzp )
   ENDDO

   m_proc2:=DispGauge ( m_proc2 , 1.00 )

   //завеpшаем pаботу
   DelGauge(m_proc2)
   CLOSE Base flish1,sp09,sp10,fzn,Sp15

   Formfl01(m_month,l_f1)


   CLOSE Base fd1,fd2,fz1,fz2,fz3,flish,sp08,fnpch
   USE (m_mainpath+"fnpch") NEW
   DELE FOR fnpch->month==s_month
   APPEND FROM (m_temppath+"fnpch")
   CLOSE fnpch
   IF FILE(m_copypath+"flish.dbf")
    FERASE(m_copypath+"flish.dbf")
  ENDIF

    IF UPPER(LEFT(m_mainpath,1))==UPPER(LEFT(m_copypath,1))
      FILEMOVE(m_mainpath+"flish.dbf",m_copypath+"flish.dbf")
    ELSE
      FILECOPY(m_mainpath+"flish.dbf",m_copypath+"flish.dbf")
      FERASE(m_mainpath+"flish.dbf")
    ENDIF
    IF UPPER(LEFT(m_temppath,1))==UPPER(LEFT(m_mainpath,1))
      FILEMOVE(m_temppath+"flish.dbf",m_mainpath+"flish.dbf")
    ELSE
      FILECOPY(m_temppath+"flish.dbf",m_mainpath+"flish.dbf")
    ENDIF


   USE (m_mainpath+"d52") NEW
   DELETE FOR d52->month==m_month.AND.d52->subsch='700'
   d52->(DBAP())
   d52->month :=  m_month
   d52->sumd  :=  m_dbt
   d52->sumc  :=  m_crt
   d52->subsch:=  '700'
   CLOSE d52
    set printer TO (m_mash+"49.txt")
    set device to printer
      IF l_sov
        s_db+=SumPodohod
      ENDIF
      s_db+=SumProfsojuz
      s_db+=SumPensNalog
@PROW()+1,0 SAY "РОЗРАХУНОК ЗАРПЛАТИ за "+MyCMonth(m_month)+" N"+STR(m_numr,3)
@PROW()+1,0 SAY IF (s_mode!='AVANS','   Остаточний','      АВАНС')

@PROW()+1,0 SAY "Виконан "+m_imja+"  Дата "+DMY(DATE())+" Час "+TIME()
@PROW()+1,0 SAY "Нараховано зарплати"
@PROW(),20 SAY SumTOStr(s_sumall,14)
@PROW()+1,0 SAY "     по договорах"
@PROW(),20 SAY SumTOStr(s_sovm,14)
@PROW()+1,0 SAY "Суми для розрахунку"
@PROW()+1,0 SAY "  Прибуткового"
@PROW(),20 SAY SumTOStr(s_podoh,14)
@PROW(),40 SAY SumTOStr(s_podoha,14)
@PROW()+1,0 SAY "  Пенсiонного"
@PROW(),20 SAY SumTOStr(s_pens1,14)
@PROW(),40 SAY SumTOStr(s_pens2,14)
@PROW(),60 SAY SumTOStr(s_pens3,14)
@PROW()+1,20 SAY SumTOStr(s_pens4,14)
@PROW(),40 SAY SumTOStr(s_pens5,14)
@PROW()+1,20 SAY SumTOStr(s_pens,14)
@PROW()+1,0 SAY "  Лiкарняного"
@PROW(),20 SAY SumTOStr(sum_boln,14)
@PROW()+1,0 SAY "Податки:"
@PROW()+1,0 SAY "  Прибутковий"
@PROW(),20 SAY SumTOStr(x_podoh,14)
@PROW()+1,0 SAY "  Пенсiонний"
@PROW(),20 SAY SumTOStr(x_pens1,14)
@PROW(),40 SAY SumTOStr(x_pens2,14)
@PROW(),60 SAY SumTOStr(x_pens3,14)
@PROW()+1,20 SAY SumTOStr(x_pens4,14)
@PROW(),40 SAY SumTOStr(x_pens5,14)
@PROW()+1,20 SAY SumTOStr(x_pens,14)
@PROW()+1,0 SAY "Сума до оплати"
@PROW(),20 SAY SumTOStr(x_800,14)
@PROW()+1,0 SAY "Кiлькiсть працiвникiв"
@PROW(),22 SAY NumTOStr(x_kvo1,8,0)
@PROW()+1,0 SAY "Особистих рахункiв"
@PROW(),20 SAY NumTOStr(x_kvo2,5,0)
@PROW()+1,0 SAY "Предел для соц. льготы="
@PROW(),25 SAY SumTOStr(x_pod,14)

@PROW()+1,0 SAY "Процент подоходного="
@PROW(),25 SAY SumTOStr(p_pod,14)

@PROW()+1,0 SAY "прожиточный минимум ="
@PROW(),25 SAY SumTOStr(p_minimum,14)
@PROW()+1,0 SAY " предел для удержаний в пенсионный фонд и социальные взносы ="
@PROW(),25 SAY SumTOStr(m_maxpredel,14)

s_db+=x_podoh+x_pens+x_isp+x_prof
@PROW()+1,0 SAY "70 рахунок  "
@PROW()+1,0 SAY "Дебет "
@PROW(),16 SAY SumTOStr(s_ind,14)
@PROW(),31 SAY SumTOStr(s_db,14)
@PROW(),46 SAY SumTOStr(s_outd,14)
@PROW(),PCOL()+2 SAY s_outd PICTURE "999'999'999.99"
@PROW()+1,0 SAY "Кредiт"
@PROW(),16 SAY SumTOStr(s_inc,14)
@PROW(),31 SAY SumTOStr(s_cr,14)
@PROW(),46 SAY SumTOStr(s_outc,14)
s_sumall:=ROUND(s_ind-s_inc+s_db-s_cr-s_outd+s_outc,2)
IF s_sumall<>0
  @PROW()+1,0 SAY "********* "+ALLTRIM(SumToStr(s_sumall,12))
ENDIF
/*
@PROW()+1,0 SAY "Таблиця податку"
@PROW()+1,0 SAY "Неоподаткований мiнiмум="+SumToStr(a_tab1[1,1])
@PROW()+1,0 SAY "З            0 по     "+SumToStr(a_tab1[1,1],10)+" не оподатковувається"
  FOR i:=1 TO LEN(a_tab1)-1
    @PROW()+1,0 SAY "З "+SumToStr(a_tab1[i,1],12)+" по "+SumToStr(a_tab1[i+1,1],12)+TRANSFORM(a_tab1[i,3]*100,"999")+"% + "+SumToStr(a_tab1[i,2],10)
  NEXT
@PROW()+1,0 SAY "З "+SumToStr(a_tab1[LEN(a_tab1),1],12)+" и далi         "+TRANSFORM(a_tab1[LEN(a_tab1),3]*100,"999")+"% + "+SumToStr(a_tab1[LEN(a_tab1),2],10)
*/
Dobms("01",s_month)
@PROW()+1,0 SAY ""
set device to screen
set printer TO
//   DBCOMMITALL()

RETURN .t.
STATIC Function  Udal(s_month,next_month,m_110,m_097)
   // Удаление из flish всех записей введенного бухгалтерского месяца,
   // кроме кодов '097' и '110', а также всех записей следующего месяца с
   // кодами '097' и '110'.
   IF FILE(m_temppath+"flish"+".dbf")
      FERASE(m_temppath+"flish"+".dbf")
   ENDIF
   FILECOPY(m_mainpath+"flish"+".dbf"   ,m_temppath+"flish"+".dbf"   )
   USE (m_temppath+"flish") NEW
   flish->(DBGOTOP())
   DO WHILE .NOT.flish->(EOF())
     IF ( flish->month == s_month.AND.flish->kopu != m_097.AND.flish->kopu != m_110 ) ;
        .OR. ;
        (Val(flish->month)==next_month.AND.(flish->kopu==m_097.OR.flish->kopu == m_110))
        flish->(DBDELETE())
      ENDIF
//      IF AT(fz3->kopu,k_mtp)<>0  ; flish1->summtpy+=flish->sum;ENDIF
//      IF AT(fz3->kopu,k_nat)<>0  ; flish1->sumnaty+=flish->sum;ENDIF
      flish->(DBSKIP(1))
    ENDDO
RETURN .t.
STATIC FUnction OpenFl(s_month,m_month)
   // открываем необходимые файлы

   NET USE (m_sprpath+"sp09")  INDEX (m_sprpath+"sp09")  NEW   // Спр. пр. оплат и уд.
   NET USE (m_sprpath+"sp15")  INDEX (m_sprpath+"sp15")  NEW   // Спр. исполнительных листов
   NET USE (m_sprpath+"sp10")  INDEX (m_sprpath+"sp10")  NEW   // Спр. работников
   DO WHILE .NOT.sp10->(EOF())
    IF Sp10->(NetRlock())
      sp10->sum1:=0
      Sp10->(DbUnlock())
    ENDIF
    sp10->(DBSKIP())
   ENDDO
   USE (m_mainpath+"fzn") NEW             // Файл машинограммы алиментов
   DELE FOR fzn->month==m_month
   USE (m_mainpath+"fd1") NEW
   USE (m_mainpath+"fd2") NEW
   USE (m_mainpath+"fz1") NEW
   USE (m_mainpath+"fz2") NEW
   USE (m_mainpath+"fz3") NEW

    CrStruct("ZARPL3","fnpch")
    USE (m_temppath+"Fnpch") NEW
    INDEX ON fnpch->tabn TO (m_temppath+"fnpch")
    CrStruct("ZARPL1","flish0")
    USE (m_temppath+"Flish0") NEW
    INDEX ON flish0->tabn + flish0->kopu +flish0->mnt TO (m_temppath+"flish0")
    CrStruct("ZARPL2","flish1")
    USE (m_temppath+"Flish1") NEW
    INDEX ON flish1->tabn TO (m_temppath+"flish1")
RETURN .t.
Function GetMonth1(n1,n2)
  LOCAL i:=ALERT("Виберiть мiсяць розрахунку ",{"Вiдмова",MyCmonth(n1),MyCmonth(n2)},"w+/bg,gr+/w")
  DO CASE
    CASE i==0.or.i==1
      return -1
    CASE i==2
      return n1
    CASE i==3
      return n2
  ENDCASE
RETURN -1
Function GetTypeCalc()
  LOCAL i:=ALERT("Виберiть тип розрахунку ",{"Вiдмова","Аванс","Остаточний"},"w+/bg,gr+/w")
  DO CASE
    CASE i==0.or.i==1
      return -1
    CASE i==2
      return 1
    CASE i==3
      return 2
  ENDCASE
RETURN -1

STATIC Function Dob1(m_sum1,m_kopu1,m_sum2,m_kopu2,m_tabn1,s_month,m_kopu3)
IF m_sum1>0
    FlishAp(s_month,m_tabn1,m_kopu1,0,0,m_sum1,"","")
    flish1->sum4 -= flish->sum
    FlishAp(s_month,m_tabn1,m_kopu2,0,0,m_sum2,"!","")
ELSE
    FlishAp(s_month,m_tabn1,m_kopu3,0,0,m_sum2,"!","")
ENDIF
return .t.
STATIC Function FlishAp(m_month,m_tabn,m_kopu,m_otdn,m_oths,m_sum,m_st,m_mnt)
 Flish->(DBAP())
 Flish->month :=m_month
 Flish->tabn  :=m_tabn
 Flish->kopu  :=m_kopu
 Flish->otdn  :=m_otdn
 Flish->oths  :=m_oths
 Flish->sum   :=m_sum
 Flish->st    :=m_st
 Flish->mnt   :=m_mnt
RETURN .T.

STATIC Function CountPod(m_tabn1,a_tab1,a_tab2,s_month,k_pod1,k_pod2,l_sov,SumStrah)
  LOCAL SumPodohod:=0,SumPodNal,i,n:=LEN(a_tab1)
      // расчет подоходного налога
      SumPodohod := 0
//      SumPodNal:=INT(flish1->sum1 - SumStrah )
      SumPodNal:=INT(flish1->sum1)
      IF Sp10->kpn<>"0"
      IF Sp10->kpn<>"4".AND.Sp10->kpn<>"6"
      DO CASE
				CASE sp10->kpn == '1'  /*  таблица 1 */
          // Таблица 1
         IF VAL(sp10->kmn)>0.AND.flish1->sum1<740
            SumPodNal-=VAL(sp10->kmn)*a_tab1[1,1]
         ENDIF
        CASE sp10->kpn == '2'  /*  таблица 3 льгота 5 минимумов  */
           SumPodNal-=4*a_tab1[1,1]
				CASE sp10->kpn == '3'  /*  таблица 4 льгота 10 минимумов */
           SumPodNal-=9*a_tab1[1,1]
        CASE sp10->kpn == '5'  /*  таблица 5 льгота 15 минимумов */
           SumPodNal-=14*a_tab1[1,1]
      ENDCASE
      FOR i:=n  TO 1 STEP -1
          IF SumPodNal>a_tab1[i,1]
            SumPodohod:=(SumPodNal-a_tab1[i,1])*a_tab1[i,3]+a_tab1[i,2]
            EXIT
          ENDIF
      NEXT
      IF VAL(sp10->kmn)>2
        SumPodohod:=SumPodohod/2
      ENDIF
      ELSE
         FOR i:=LEN(a_tab2)  TO 1 STEP -1
            IF flish1->sum1>=a_tab2[i,2]
               SumPodohod:=(SumPodNal-a_tab2[i,2])*a_tab2[i,3]+a_tab2[i,1]
               EXIT
            ENDIF
         NEXT
      ENDIF
      SumPodohod:=ROUND(SumPodohod,2)
      IF SumPodohod > 0
           FlishAp(s_month,m_tabn1,IF(sp10->kpn == '4'.OR.sp10->kpn == '6'.OR.sp10->kpn == '7',k_pod2,k_pod1),;
           0,0,SumPodohod,IF(l_sov.OR.sp10->kpn == '4'.OR.sp10->kpn == '6'.OR.sp10->kpn == '7'.OR.sp10->kass>="90","","*"),"")
         IF l_sov.OR.sp10->kpn == '4'.OR.sp10->kpn == '6'.OR.sp10->kpn == '7'.OR.(sp10->kass>="90") // ЕСЛИ ЭТО СОВХОЗ ИЛИ СОВМЕСТИТЕЛЬ или колхоз и нанятый
           flish1->sum4-=SumPodohod
         endif
      ENDIF
      ENDIF
      FlishAp(s_month,m_tabn1,;
      IF(sp10->kpn == '4'.OR.sp10->kpn == '6'.OR.sp10->kpn == '7',"902",'901'),;
      0,0,INT(flish1->sum1),"!","")
      FlishAp(s_month,m_tabn1,;
      IF(sp10->kpn == '4'.OR.sp10->kpn == '6'.OR.sp10->kpn == '7',"952",'951'),;
      0,0,flish1->sum1,"!","")

RETURN SumPodohod

STATIC Function AppAlim(m_num,m_tabn,m_procent,m_mnt,m_prc1,;
m_month,m_fam,m_addr,m_kopu,m_otdn,m_SumAll,SuPodohod,m_sum,SumPcht,m_sum5)
  Fzn->(DBAP())
  Fzn->num    :=m_num   //Номер исп. листа
  Fzn->tabn   :=m_tabn  // таб. номер
  Fzn->procent:=m_procent  // процент исп. листа
  Fzn->mnt    :=m_mnt   // исправление за какой месяц
  Fzn->prc1   :=m_prc1 // процент почты
  Fzn->month  :=m_month //  расчетный месяц исп. листа
  Fzn->fam    :=m_fam  // Кому
  Fzn->addr   :=m_addr //Адрес
  Fzn->kopu   :=m_kopu // код удержания
  Fzn->otdn   :=m_otdn  // отработано дней
  Fzn->sum1   :=m_SumAll  // начисл. сума
  Fzn->sum2   :=SuPodohod // подоходный
  Fzn->Sum3   :=m_sum     // сумма исполнительного
  Fzn->Sum4   :=SumPcht // сумма почтового сбора
  Fzn->sum5   :=m_sum5  // Сумма с которой уд. алименты
RETURN .t.
STATIC FUNCTION Formfl01(m_month1,l_first)
LOCAL m_year,m_year1,m_proc2,m_month,i,m_kod
  USE (m_mainpath+"fvnum.dbr") NEW
  m_year1:=fvnum->year
  CLOSE fvnum
m_proc2:=InitGauge("Формування файла довiдки")
IF l_first
  FERASE(m_mainpath+"fl02.dbf")
  FERASE(m_mainpath+"fl02.ntx")
  FILECOPY(m_mainpath+"fl01.dbf",m_mainpath+"fl02.dbf")
  FILECOPY(m_mainpath+"fl01.ntx",m_mainpath+"fl02.ntx")
ELSE
  FERASE(m_mainpath+"fl01.dbf")
  FERASE(m_mainpath+"fl01.ntx")
  FILECOPY(m_mainpath+"fl02.dbf",m_mainpath+"fl01.dbf")
  FILECOPY(m_mainpath+"fl02.ntx",m_mainpath+"fl01.ntx")
ENDIF
USE (m_mainpath+"fl01") NEW
INDEX ON fl01->year+fl01->tabn+fl01->kopu TO (m_mainpath+"fl01")
// USE (m_mainpath+"flish") NEW
flish->(DBGOTOP())
DO WHILE .NOT.flish->(EOF())
  IF flish->month==STRZERO(m_month1,2)
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
