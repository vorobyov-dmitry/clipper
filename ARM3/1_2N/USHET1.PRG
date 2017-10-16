#include "new.ch"
#include "menu.ch"
#define VDOC_UCHET "51"
MEMVAR m_mainpath,m_sprpath,m_copypath,m_syspath,m_mash,m_uchpath
MEMVAR m_oper,m_temppath
FUNCTION v_1_2
local m_DBTAVTO,;  // Затраты по автопарку
      m_DBTTRACT,; // Затраты по маш. - тр. парку
      m_DBTMONEY,; // Зарплата
      m_ktg,;     // Категории по которым не начисляются отпускные
      m_dbtsavto,;// Код спецтранспорта
      l_iszrtr,;  // Транзит зарплаты трактористов
      l_isgsmtr,; // Транзит ГСМ трактористов
      m_dbtgsm,;  // Субсчет ГСМ
      m_koddzt,;  // Код диз. топлива
      l_iskassa,; // Есть ли касса
      s_kopu   ,;   // Перечень удержаний по которым не выполнять проводки
      m_kopr1:="01",; //Код операции по заработной плате
      m_kopr2:="05",; //Код операции по ГСМ
      m_kopr3:="14",; //Код операции по усл. га
      m_kopr4:="15",; //Код операции по физ. га
      m_kopr5:="16",; //Код операции по т/км тракторов
      m_kopr6:="12",; //Код операции по т/км автомобилей
      m_kopr7:="22",; //Код операции по км автомобилей
      m_kopr8:="23",; //Код операции по авточасы
      m_molavto:="  ",; // Код мол авто
      m_moltr  :="  ",;   // Код мол трактористов
      l_part2  :=0,;    // Выполнять проводки
      n_gsm    :=0,;    // Номер ГСМ
      l_first  :=.t.,; // Признак первой записи
      n1:=0,m_pol,n_stm,n_kg,n_litr,s_subcode

LOCAL m_date,n_sum,m_month1,m_vnum,m_kpn,m_first,m_last,m_koef,m_prisea,;
n_row:=0,n_col:=3,getlist:={},l_delete,l_norma,l_kgm,m_078,l_tkmtr,m_vdoc
local A_1_2:={},i:=0,m_stm,n_pole1:=0,n_pole2:=0,m_month,m_proc1,m_sum1,m_mnt,;
      m_sum,m_crt,g_sum,m_npch,m_dbt,a_kmtop:={},a_kmtr:={},m_schtgsm,m_brgd2
LOCAL m_cod1,m_cod2
   LOCAL m_maxpredel:=0
// USE (m_mainpath+"fzz") NEW READONLY
// m_month:=VAL(fzz->month)
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
m_month:=RESTVAR1("m_month","ZR")
m_078 :=RESTVAR1("m_078","ZR")
l_norma:=RESTVAR1("l_norma","ZR")
l_kgm:=RESTVAR1("l_kgm","ZR")
l_tkmtr:=RESTVAR1("l_tkmtr","ZR")
m_maxpredel:=RESTVAR1("m_maxpredel"   ,"ZR")
if m_maxpredel==0
	m_maxpredel:=8520
ENDIF
CLOSE myvar

// Новое изменение в файле
USE (m_mainpath+"fvnum.dbr") NEW
m_mnt:=mnt_dtod(STOD(fvnum->year+STRZERO(m_month,2)+"20"))
m_date:=STOD(fvnum->year+STRZERO(m_month,2)+"20")
CLOSE FVNUM
IF ANSWERu("Виконувати аналiтичний облiк;працi i зароб. платнi;за "+mnt_dtoc(m_mnt)+";Ви впевненi?")<>YES
  RETURN .f.
ENDIF
@1,20,6,61 BOX B_DOUBLE+" " COLOR "w+/BG"
@3,21 SayDISp PADC(' Синтетичний облiк працi',40) COLOR "gr+/bg"
@4,21 SayDISP PADC('i зароб. платнi за '+mnt_dtoc(m_mnt),40)  COLOR "gr+/BG"
// USE (m_uchpath+"buf13a") NEW ALIAS Buf13
// n_pole1:=buf13->(fieldnum("sum1m"))
USE (m_uchpath+"inst1") INDEX  (m_uchpath+"inst1") new ALIAS myvar
RESTMEM m_DBTAVTO,m_DBTTRACT,m_DBTMONEY,m_ktg,m_dbtsavto,l_iszrtr,m_molavto
RESTMEM l_isgsmtr,m_dbtgsm,m_koddzt,l_iskassa,s_kopu,m_kopr1,m_kopr2,m_moltr
RESTMEM m_kopr3,m_kopr4,m_kopr5,m_kopr6,m_kopr7,m_kopr8,m_month1,l_part2,m_schtgsm
CLOSE myvar
//m_dbtmoney:=m_dbtmoney
OpenFl(m_month)
i:=0
DO WHILE .NOT.s_1_2->(EOF())
   i++
   AADD(a_1_2,{{ROUND(s_1_2->procent1/100,6),ROUND(s_1_2->procent2/100,6),ROUND(s_1_2->procent3/100,6)},;
   s_1_2->ksash,0,{0,0,0},{0,0,0},{},{0,0,0},{0,0,0},0,ALLTRIM(s_1_2->kopu),s_1_2->name})
//[1] - проценты массив из трех элементов
//[2] - шифр кредита
//[3] - отработано часов
//[4] -  накопительный итог сумма
//[5] - накопительный итог сумма начисления
//[6] - массив ШЗ на кторые не начислять
//[7] - номер записи для округления
//[8] - максимальное значение
//[9] - текущая сумма начисления
//[10] - коды оплат на которые не начислять
//[11] - название начисления
   IF len(ALLTRIM(s_1_2->f1))<>0;AADD(a_1_2[i][6],alltrim(s_1_2->f1));ENDIF
   IF len(ALLTRIM(s_1_2->f2))<>0;AADD(a_1_2[i][6],alltrim(s_1_2->f2));ENDIF
   IF len(ALLTRIM(s_1_2->f3))<>0;AADD(a_1_2[i][6],alltrim(s_1_2->f3));ENDIF
   IF len(ALLTRIM(s_1_2->f4))<>0;AADD(a_1_2[i][6],alltrim(s_1_2->f4));ENDIF
   IF len(ALLTRIM(s_1_2->f5))<>0;AADD(a_1_2[i][6],alltrim(s_1_2->f5));ENDIF
   IF len(ALLTRIM(s_1_2->f6))<>0;AADD(a_1_2[i][6],alltrim(s_1_2->f6));ENDIF
   s_1_2->(DBSKIP(1))
ENDDO
CLOSE s_1_2
a_1_2[1,2]:=m_dbtmoney
m_proc1 := InitGauge(" Перегляд основної бази " ,1)
// Выборка информации из основной базы данных
  DO WHILE .NOT.fz1->(EOF())
    m_proc1:=DispGauge(m_proc1, fz1->( RECNO() ) / fz1->( LASTREC() ) )
      IF fz1->mnt== m_mnt
         IF .NOT.pFilPoz ( 'fz2' , 'vnum1' , 'fz1' )
              fz1->(DBSKIP());LOOP
         ENDIF
        IF fz1->VDOC >= 34 .AND. fz1->vdoc<= 37.AND..NOT.pFilPoz ( 'fz1t' , 'vnum1' , 'fz1' )
            fz1->(DBSKIP())
            LOOP
        ENDIF
        IF fz1->vdoc >= 38 .AND. fz1->vdoc<= 44 &&Путевой лист
          IF .NOT.pFilPoz ( 'fz1ae' , 'vnum1' , 'fz1' ).OR.;
                  .NOT.pFilPoz ( 'fz1at' , 'vnum1' , 'fz1' )
              fz1->(DBSKIP());LOOP
          ENDIF
        ENDIF
          m_crt:=m_dbtmoney
          m_brgd2:="  "
          m_cod1:=SPACE(10)
          m_cod2:=SPACE(10)
          DO CASE
            CASE fz1->vdoc >= 34 .AND. fz1->vdoc<= 37 &&Трактора
                m_vdoc := '0'
                inv_t->(DBSEEK(fz1t->ntr))
                m_brgd2:=inv_t->brgd
                m_crt:=inv_t->ksash
                IF IsAnCodTract(m_crt)
                  m_cod2:=PADR(fz1t->ntr,10)
                ENDIF

            CASE fz1->vdoc >= 38 .AND. fz1->vdoc<= 44 &&Путевой лист
                m_vdoc := '1'
                inv_a->(DBSEEK(fz1ae->gnavt))
                m_brgd2:=inv_a->brgd
                m_crt:=inv_a->KSASH
                IF IsAnCodAvto(m_crt)
                  m_cod2:=PADR(fz1ae->gnavt,10)
                ENDIF
                IF .NOT.buf5->(DBSEEK(fz1at->kmtop+m_crt+m_cod2+fz2->tabn+mnt_dtod(fz1->ddoc)))
                  buf5->(DBAPPEND())
                  buf5->kmtop := fz1at->kmtop
                  buf5->dbt  := m_crt
                  buf5->cod1 := m_cod2
                  buf5->tabn := fz2->tabn
                  buf5->mnt  := mnt_dtod(fz1->ddoc)
                ENDIF
                buf5->rtfak += IF(l_norma,fz1ae->rgnor,fz1ae->rgfak)
                IF ASCAN(a_kmtop,{|x|(x[1]==fz1at->kmtop.AND.x[7]==mnt_dtod(fz1->ddoc))})==0
                  AADD(a_kmtop,{fz1at->kmtop,0,0,0,0,0,mnt_dtod(fz1->ddoc)})
                ENDIF
            OTHERWISE
                m_vdoc := '2'
          ENDCASE
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            m_sum := 0
            sp10->(DBSEEK(fz2->tabn))
            m_pol:=IF(UPPER(Sp10->pol)=="М","1","0")
            DO CASE
               CASE sp10->kpn=="6".OR.sp10->kpn=="7"
                   m_kpn:="6"
               CASE sp10->inv=="1"
                   m_kpn:="7"
              OTHERWISE
                m_kpn:="0"
            ENDCASE

            l_first:=.t.
            IF fz1->vdoc<>38.AND.fz1->vdoc<>42.AND.fz1->vdoc<>44     // В документе должна быть запись в fz3
               IF .NOT.pFilPoz ( 'fz3' , 'vnum2' , 'fz2' )
                  fz2->(DBSKIP(1))
                  LOOP
               ELSE
                  DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())
                    Buf1App(m_vdoc,fz2->brgd,m_brgd2,fz2->ksash,m_cod1,fz2->vrab,m_crt,m_cod2,m_kpn,fz3->kopu,l_first,fz2->oths,fz2->otdn,fz3->sum,fz2->tabn)
                    Buf8App(fz2->tabn,m_pol,IF(sp10->kpn=="4","4",m_kpn),@l_first,fz2->otdn,fz2->oths,fz3->sum)
                    fz3->(DBSKIP())
                  ENDDO
               ENDIF
            ELSE
              Buf1App(m_vdoc,fz2->brgd,m_brgd2,fz2->ksash,m_cod1,fz2->vrab,m_crt,m_cod2,m_kpn,fz3->kopu,l_first,fz2->oths,fz2->otdn,fz3->sum)
              Buf8App(fz2->tabn,m_pol,IF(sp10->kpn=="4","4",m_kpn),@l_first,fz2->otdn,fz2->oths,fz3->sum)
            ENDIF
            IF fz1->VDOC >= 38 .AND. fz1->vdoc<= 44 &&Путевой лист
               IF pFilPoz ( 'fz2a' , 'vnum2' , 'fz2' )
                  IF .NOT.buf4->(DBSEEK(fz2->brgd+m_brgd2+fz2->ksash+m_crt+m_cod2))
                     buf4->(DBAPPEND())
                     buf4->brgd1  := fz2->brgd
                     buf4->brgd2 := m_brgd2
                     buf4->dbt   := fz2->ksash
                     buf4->crt   := m_crt
                     buf4->cod2  := m_cod2
                  ENDIF
                  IF m_crt==m_dbtsavto
                     buf4->avtohs+= fz2->oths
                   ELSE
                     IF fz2a->vtkav=0
                        buf4->pgob+= fz2a->pgob
                     ELSE
                        buf4->vtkav+= fz2a->vtkav
                     ENDIF
                  ENDIF
               ENDIF
            ENDIF
            IF fz1->VDOC >= 34 .AND. fz1->vdoc<= 37 &&Трактора
               IF pFilPoz ( 'fz2t' , 'vnum2' , 'fz2' )
                  DO CASE
                      CASE m_dbttract==LEFT(m_crt,LEN(m_dbttract))
                        IF .NOT.buf3->(DBSEEK(fz2->brgd+m_brgd2+fz2->ksash+fz2->vrab+m_crt+m_cod2))
                          buf3->(DBAPPEND())
                          buf3->brgd1  := fz2->brgd
                          buf3->brgd2  := m_brgd2
                          buf3->dbt   := fz2->ksash
                          buf3->vrab  := fz2->vrab
                          buf3->crt   := m_crt
                          buf3->cod2  := m_cod2
                        ENDIF
                          IF fz1->vdoc==37.AND.l_tkmtr
                            IF pFilPoz ( 'fz2tp' , 'vnum2' , 'fz2' )
                               buf3->vptkm +=  fz2tp->vtktr
                            ENDIF
                           ELSE
                              buf3->vpug  +=  fz2t->vpug
                           ENDIF
                      OTHERWISE
                        IF ASCAN(a_kmtr,{|x|(x[1]==inv_t->kmtr)})==0
                          AADD(a_kmtr,{inv_t->kmtr,0,0,0})
                        ENDIF
                        IF .NOT.buf7->(DBSEEK(fz2->brgd+m_brgd2+fz2->ksash+fz2->vrab+m_crt+INV_T->KMTR+m_cod2))
                          buf7->(DBAPPEND())
                          buf7->brgd1  := fz2->brgd
                          buf7->brgd2  := m_brgd2
                          buf7->dbt   := fz2->ksash
                          buf7->vrab  := fz2->vrab
                          buf7->crt   := PADR(m_crt,7)
                          buf7->kmtr  := inv_t->kmtr
                          buf7->cod2  := m_cod2
                        ENDIF
                           buf7->vpfg  +=  fz2t->vpga
                  ENDCASE
                  IF .NOT.buf9->(DS(fz2->tabn+fz2->brgd+m_brgd2+fz2->ksash+fz2->vrab+m_crt+m_cod2+mnt_dtod(fz1->ddoc)))
                          buf9->(DBAPPEND())
                          buf9->brgd1  := fz2->brgd
                          buf9->brgd2  := m_brgd2
                          buf9->dbt   := fz2->ksash
                          buf9->vrab  := fz2->vrab
                          buf9->crt   := PADR(m_crt,7)
                          buf9->cod2  := m_cod2
                          buf9->tabn  := fz2->tabn
                          buf9->mnt   := mnt_dtod(fz1->ddoc)
                  ENDIF
                  buf9->rtfak += IF(l_norma,fz2t->rtnor,fz2t->rtfak)
                  IF ASCAN(a_kmtop,{|x|(x[1]==m_koddzt.AND.x[7]==mnt_dtod(fz1->ddoc))})==0
                    AADD(a_kmtop,{m_koddzt,0,0,0,0,0,mnt_dtod(fz1->ddoc)})
                  ENDIF
               ENDIF
            ENDIF
            SKIP 1 ALIAS fz2
         ENDDO
      ENDIF
      SKIP 1 ALIAS fz1
 ENDDO

  DispGauge(m_proc1, 1)
  //Сформированы промежуточные файлы (информация выбрана)
//   deldbfntx('sp10')
CLOSE base fz1,fz1t,fz2,fz3,fz1ae,fz1at,fz2a,fz2t,fz2tp
UdalPrev(m_mnt)
SET PRINTER TO (m_mash+"45.txt")
SET PRINT ON
SET CONSOLE OFF
?replicate("=",75)
?"Синтетичний i аналiтичний облiк працi i зароб. платнi за "+NTOcmonth(m_month)+" мiсяць"
?"Виконан ",DATE(),TIME()
?"Таблиця нарахувань на зар. платню"
FOR i:=2 TO LEN(a_1_2)
  ?"Назва ",a_1_2[i,11]
  ?"   Процент для осн. робiтникiв  ",NumToStr(ROUND(a_1_2[i,1,1]*100,3),6,3)
  ?"   Процент для договорiв        ",NumToStr(ROUND(a_1_2[i,1,2]*100,3),6,3)
  ?"   Процент для iнвалiдiв        ",NumToStr(ROUND(a_1_2[i,1,3]*100,3),6,3)
  ?"   Не нараховувати на ШВВ "
  AEVAL(a_1_2[i][6],{|x|QQOUT(x),QQOUT(" ")})
  ?"   Не нараховувати на коди оплат ",a_1_2[i,10]
NEXT

// Выполнение начислений на зароботную плату
buf1->(dbgotop())

calcPrevMax(m_maxpredel)

buf1->(dbgotop())
DO WHILE .not.buf1->(EOF())
  FOR I:=1 TO LEN(a_1_2)
      a_1_2[i,9]:=0
  NEXT
  			// Определяем какие проценты использовать
   DO CASE
    CASE buf1->kpn=="0";n1:=1 // основные работники
    s_subcode:="1"
    CASE buf1->kpn=="6";n1:=2 // по договорам подряда
    s_subcode:="2"
    CASE buf1->kpn=="7";n1:=3 // инвалиды
    s_subcode:="3"
    OTHERWISE;n1:=4
    s_subcode:="4"
  ENDCASE
  FOR i:=2 TO LEN(a_1_2)
  	Sp08->(DS(buf1->kopu))
  	IF ISDIGIT(sp08->p02)
  	  IF (i==(VAL(sp08->p02)+1))
  			a_1_2[i,9]:=ROUND(a_1_2[i,1][n1]*buf1->sum,2)
          a_1_2[i,4][n1]+=buf1->sum
          a_1_2[i,5][n1]+=a_1_2[i,9]
          // Запоминаем максимальное значение для дописывания округления
          IF a_1_2[i,8][n1]<a_1_2[i,9]
        	a_1_2[i,7][n1]:=buf1->(RECNO())
        	a_1_2[i,8][n1]:=a_1_2[i,9]
          ENDIF
        ENDIF
      ENDIF
  NEXT
     DO CASE
      CASE buf1->kpn=="0"
        a_1_2[1,4][1]+=buf1->sum
        a_1_2[1,5][1]+=buf1->sum
      CASE buf1->kpn=="7"
        a_1_2[1,4][2]+=buf1->sum
        a_1_2[1,5][2]+=buf1->sum
      OTHERWISE
        a_1_2[1,4][3]+=buf1->sum
        a_1_2[1,5][3]+=buf1->sum
    ENDCASE
  a_1_2[1,3]+=buf1->oths
  a_1_2[1,9]:=buf1->sum
  m_dbt:=IF(buf1->vdoc=='2',buf1->dbt,buf1->crt)
//  a_1_2[1,2]:=m_dbtmoney+s_subcode
//  IF(buf1->kpn=="0","01",IF(buf1->kpn=="6","06","07"))    //+Right(buf1->kopu,2)

  FOR i:=1 TO LEN(a_1_2)
    IF a_1_2[i,9]<>0.OR.i==1
//      buf13->(FIELDPUT(n_pole1+i-1,FIELDGET(n_pole1+i-1)+a_1_2[i,9]))
      DO CASE
        CASE buf1->vdoc=="0" //трактора
          bufprApp("5",SPACE(4),m_kopr1,buf1->brgd2,"  ","  ",buf1->crt,buf1->cod2,;
          TRIM(a_1_2[i,2])+s_subcode,PADR(buf1->kopu,10),0,0,IF(i==1,buf1->oths,0),a_1_2[i,9])
          IF l_iszrtr
            bufprApp("5",SPACE(4),m_kopr1,buf1->brgd1,buf1->brgd2,"  ",buf1->dbt,buf1->cod1,;
            buf1->crt,buf1->cod2,0,0,IF(i==1,buf1->oths,0),a_1_2[i,9])
          ENDIF
        CASE buf1->vdoc=="1" //автомобили
          bufprApp("2",SPACE(4),m_kopr1,buf1->brgd2,"  ","  ",buf1->crt,buf1->cod2,;
          TRIM(a_1_2[i,2])+s_subcode,PADR(buf1->kopu,10),0,0,IF(i==1,buf1->oths,0),a_1_2[i,9])
        OTHERWISE
          bufprApp("0",SPACE(4),m_kopr1,buf1->brgd1,buf1->brgd2,"  ",buf1->dbt,buf1->cod1,;
          TRIM(a_1_2[i,2])+s_subcode,PADR(buf1->kopu,10),0,0,IF(i==1,buf1->oths,0),a_1_2[i,9])
       ENDCASE
   ENDIF
  NEXT
  buf1->(DBSKIP())
ENDDO

// ?"ВЫПОЛНЕНИЕ ОКРУГЛЕНИЯ"
FOR i:=2 TO LEN(a_1_2)
  FOR n1:=1 TO 3
    m_sum:=a_1_2[i,4][n1]*a_1_2[i,1][n1]
    m_sum1:=ROUND(m_sum,2)
    m_sum:=m_sum1-a_1_2[i,5][n1]
    IF m_sum<>0
      buf1->(DBGOTO(a_1_2[i,7][n1]))
      bufprApp("0",SPACE(4),m_kopr1,buf1->brgd1,buf1->brgd2,"  ",buf1->dbt,buf1->cod1,buf1->crt,buf1->cod2,0,0,IF(i==1,buf1->kvo,0),m_sum)
      a_1_2[i,5][n1]+=m_sum
    ENDIF
  NEXT
NEXT

g_sum:=0
?"=============Заробiтня платня i нарахування на неї========="
FOR n1:=1 TO 3
  ?" Cума ",SumToStr(a_1_2[1,4,n1],12)
  g_sum+=a_1_2[1][5][n1]
NEXT
?"Разом з 70       Сума ",SumToStr(a_1_2[1,4,1]+a_1_2[1,4,2]+a_1_2[1,4,3],12)
FOR i:=2 TO LEN(a_1_2)
  FOR n1:=1 TO 3
    ?" Cума ",SumToStr(a_1_2[i,4,n1],12)," % ",NumToStr(ROUND(a_1_2[i,1,n1]*100,3),6,3)," Нарах. ", SUMtoStr(a_1_2[i][5][n1],12)
    g_sum+=a_1_2[i][5][n1]
  NEXT
    ?"Разом з   ",a_1_2[i][2],"Сума ",;
    SumToStr(a_1_2[i,4,1]+a_1_2[i,4,2]+a_1_2[i,4,3],12),;
    " Нарах. ", SUMtoStr(a_1_2[i][5][1]+a_1_2[i][5][2]+a_1_2[i][5][3],12)
NEXT
? "Вiдроблено годин ", a_1_2[1,3],"Сума усiх нарахувань",SumToStr(g_sum)
SayPeople()
a_kmtr:=ASORT(a_kmtr,,,{|x,y|(y[1]>x[1])})
a_kmtop:=ASORT(a_kmtop,,,{|x,y|((y[7]+y[1])>(x[1]+x[7]))})
// n_gsm:=ASCAN(a_kmtop,{|x|IF(x[1]==m_koddzt,.t.,.f.)})
// Ввод параметров перекачки
SET COLOR TO "n/bg,gr+/n"
@2,2,22,78 BOX B_DOUBLE + " "
SHADOW(2,2,22,78)
@2,2 SayDisp "╔══════════════════════ Установка параметрiв ═══════════════════════"
@3,2 SayDisp "╟──────────────Автопарк────────────────Машино-тракторний парк───────────────╢"
@4,3 SayDisp "Код оп. т/км "+m_kopr6+" Цiна "
@4,33 GET sp23->tkm
@5,3 SayDisp "Код оп. км   "+m_kopr7+" Цiна "
@5,33 GET sp23->km
@6,3 SayDisp "Код оп. автогод."+m_kopr7+" ШВЗ "+m_dbtsavto+" Цiна "
@6,33 GET sp23->avhs
@4,42 SayDisp "Код оп. умовн. га   "+m_kopr3+" Цiна "
@4,70 GET sp23->truga
@5,42 SayDisp "Код оп. т/км тракт. "+m_kopr5+" Цiна "
@5,70 GET sp23->trtkm
READ
br1(@a_kmtop,m_month)
br2(@a_kmtr)
//Разноска Автопарка
?"============АВТОПАРК========================="

buf4->(DBCLEARINDEX())
buf4->(DBGOTOP())
n_pole1:=n_pole2:=m_sum:=m_sum1:=m_stm:=g_sum:=0
DO While .NOT.buf4->(EOF())
  IF buf4->pgob<>0
      bufprApp("4",SPACE(4),m_kopr7,buf4->brgd1,buf4->brgd2,SPACE(2),buf4->dbt,SPACE(10),;
      buf4->crt,buf4->cod2,0,0,buf4->pgob,ROUND(buf4->pgob*sp23->km,2))
      n_pole2+=ROUND(buf4->pgob*sp23->km,2)
      n_pole1+=buf4->pgob
   ENDIF
  IF buf4->vtkav<>0
      bufprApp("4",SPACE(4),m_kopr6,buf4->brgd1,buf4->brgd2,SPACE(2),buf4->dbt,SPACE(10),;
      buf4->crt,buf4->cod2,0,0,buf4->vtkav,ROUND(buf4->vtkav*sp23->tkm,2))
      m_sum+=ROUND(buf4->vtkav*sp23->tkm,2)
      m_sum1+=buf4->vtkav
   ENDIF
  IF buf4->avtohs<>0
      bufprApp("4",SPACE(4),m_kopr7,buf4->brgd1,buf4->brgd2,SPACE(2),buf4->dbt,SPACE(10),;
      buf4->crt,buf4->cod2,0,0,buf4->avtohs,ROUND(buf4->avtohs*sp23->avhs,2))
      m_stm+=ROUND(buf4->avtohs*sp23->avhs,2)
      g_sum+=buf4->avtohs
   ENDIF
   buf4->(DBSKIP())
EndDO
?"Тонно - км",m_sum1,"Цiна",sp23->tkm,"Сума",m_sum
?"Км пробiгу",n_pole1,"Цiна",sp23->km,"Сума",n_pole2
?"Автогодини",g_sum,"Цiна",sp23->avhs,"Сума",m_stm
buf5->(DBCLEARINDEX())
buf5->(DBGOTOP())
DO While .NOT.buf5->(EOF())
    i:=ASCAN(a_kmtop,{|x|(x[1]==buf5->kmtop.AND.x[7]==buf5->mnt)})
    bufprApp("3",buf5->tabn,m_kopr2,"  ","  ",m_molavto,buf5->dbt,buf5->cod1,;
    m_dbtgsm+buf5->kmtop,SPACE(10),0,buf5->rtfak,buf5->rtfak*a_kmtop[i,2],buf5->rtfak*a_kmtop[i,2]*a_kmtop[i,3])
    a_kmtop[i,4]+=buf5->rtfak
    a_kmtop[i,5]+=buf5->rtfak*a_kmtop[i,2]
    a_kmtop[i,6]+=buf5->rtfak*a_kmtop[i,2]*a_kmtop[i,3]
    buf5->(DBSKIP())
EndDO
?"Проводки по пальному по "+IF(l_norma,"нормi","факту")
FOR i:=1 TO LEN(a_kmtop)
  IF a_kmtop[i][4]<>0.OR.a_kmtop[i][5]<>0.OR.a_kmtop[i][6]<>0
  ?mnt_data(a_kmtop[i][7]),"ПММ",a_kmtop[i][1],sp44->naim7,"Коэф=",a_kmtop[i][2],"Цiна",a_kmtop[i][3]
  ?"  Лiтри",a_kmtop[i][4],"Кг",SumTostr(a_kmtop[i][5],18),"Сума",SumTostr(a_kmtop[i][6],20)
  ENDIF
  a_kmtop[i][4]:=a_kmtop[i][5]:=a_kmtop[i][6]:=0
NEXT
?"=======МАШИНО-ТРАКТОРНИЙ ПАРК==============="
IF l_isgsmtr
  ?" ППМ на ШВЗ "
ELSE
  ?" ППМ збирається  на ШВЗ машино - тракторном парку "
ENDIF
IF l_iszrtr
  ?" Зарплата на ШВЗ "
ELSE
  ?" Зарплата  збирається на ШВЗ машино - тракторного парку "
ENDIF
buf3->(DBCLEARINDEX())
buf3->(DBGOTOP())
n_pole1:=n_pole2:=m_sum:=m_sum1:=m_stm:=g_sum:=n_sum:=0
DO While .NOT.buf3->(EOF())
  IF buf3->vpug<>0
    bufprApp("5",SPACE(4),m_kopr3,buf3->brgd1,buf3->brgd2,SPACE(2),buf3->dbt,SPACE(10),;
    buf3->crt,buf3->cod2,0,0,buf3->vpug,ROUND(buf3->vpug*sp23->truga,2))
      n_pole2+=ROUND(buf3->vpug*sp23->truga,2)
      n_pole1+=buf3->vpug
   ENDIF
  IF buf3->vptkm<>0
      bufprApp("5",SPACE(4),m_kopr5,buf3->brgd1,buf3->brgd2,SPACE(2),buf3->dbt,SPACE(10),;
      buf3->crt,buf3->cod2,0,0,buf3->vptkm,buf3->vptkm*sp23->trtkm)
      m_sum+= buf3->vptkm*sp23->trtkm
      m_sum1+=buf3->vptkm
   ENDIF
   buf3->(DBSKIP())
EndDO
?"Умовнi Га",n_pole1,"Цiна",sp23->truga,"Вартiсть",n_pole2
?"Тонно - км",m_sum1,"Цiна",sp23->trtkm,"Вартiсть",m_sum
buf7->(DBCLEARINDEX())
buf7->(DBGOTOP())
n_pole1:=n_pole2:=0
DO While .NOT.buf7->(EOF())
  IF buf7->vpfg<>0
      i:=ASCAN(a_kmtr,{|x|(x[1]==buf7->kmtr)})
      bufprApp("5",SPACE(4),m_kopr4,buf7->brgd1,buf7->brgd2,SPACE(2),buf7->dbt,SPACE(10),;
      buf7->crt,buf7->cod2,0,0,buf7->vpfg,buf7->vpfg*a_kmtr[i,2])
      a_kmtr[i,3]+=buf7->vpfg
      a_kmtr[i,4]+=buf7->vpfg*a_kmtr[i,2]
   ENDIF
   buf7->(DBSKIP())
EndDO
buf9->(DBCLEARINDEX())
buf9->(DBGOTOP())
DO While .NOT.buf9->(EOF())
  IF buf9->rtfak<>0
      // проводка на списание ГСМ
    n_gsm:=ASCAN(a_kmtop,{|x|(x[1]==m_koddzt.AND.x[7]==buf9->mnt)})
    IF .NOT.l_kgm
      n_litr:=buf9->rtfak
      n_kg  :=ROUND(buf9->rtfak*a_kmtop[n_gsm,2],2)
      n_stm :=ROUND(buf9->rtfak*a_kmtop[n_gsm,2]*a_kmtop[n_gsm,3],2)
    ELSE
      n_litr:=ROUND(IF(a_kmtop[n_gsm,2]==0,0,buf9->rtfak/a_kmtop[n_gsm,2]),2)
      n_kg  :=buf9->rtfak
      n_stm :=ROUND(buf9->rtfak*a_kmtop[n_gsm,3],2)
    ENDIF
    bufprApp("6",buf9->tabn,m_kopr2,buf9->brgd2,"  ",m_moltr,buf9->crt,buf9->cod2,;
    m_dbtgsm+m_koddzt,SPACE(10),0,n_litr,n_kg,n_stm)
        a_kmtop[n_gsm,4]+=n_litr
        a_kmtop[n_gsm,5]+=n_kg
        a_kmtop[n_gsm,6]+=n_stm
      IF l_isgsmtr
        bufprApp("6",buf9->tabn,m_kopr2,buf9->brgd1,buf9->brgd2,SPACE(2),buf9->dbt,SPACE(10),;
        buf9->crt,buf9->cod2,0,n_litr,n_kg,n_stm)
      ENDIF
   ENDIF
   buf9->(DBSKIP())
EndDO
AEVAL(a_kmtr,{|x|sp13b->(DBSEEK(x[1])),;
 QOUT("Код марки комбайна",x[1]," ",sp13b->naim13b,;
"Цiна фiз. га = ",x[2]),QOUT("  Кiлькiсть",x[3],"Сума",x[4])})
?"Проводки по пальному по "+IF(l_norma,"нормi","факту")
??" в "+IF(l_kgm,"кiлограмах "," лiтрах ")
FOR i:=1 TO LEN(a_kmtop)
  IF a_kmtop[i][4]<>0.OR.a_kmtop[i][5]<>0.OR.a_kmtop[i][6]<>0
  ?mnt_data(a_kmtop[i][7]),"ПММ",a_kmtop[i][1],sp44->naim7,"Коэф=",a_kmtop[i][2],"Цiна",a_kmtop[i][3]
  ?"  Лiтри",a_kmtop[i][4],"Кг",SumTostr(a_kmtop[i][5],18),"Сума",SumTostr(a_kmtop[i][6],20)
  ENDIF
  a_kmtop[i][4]:=a_kmtop[i][5]:=a_kmtop[i][6]:=0
NEXT
?'Проводки по утриманням'
USE (m_mainpath+"flish") NEW
flish->(DBGOBOTTOM())
m_stm:=g_sum:=0
DO WHILE .NOT.flish->(Bof()).AND.(VAL(flish->month)>=m_month-1.OR.VAL(flish->month)==1)
   IF flish->kopu == m_078.AND.VAL(flish->month)==m_month
      m_stm+=flish->sum
   ENDIF
   IF flish->kopu == '800'.AND.VAL(flish->month)==m_month-1
      g_sum+=flish->sum
   ENDIF
   IF VAL(flish->month)==m_month
    IF Sp25->(DS(flish->kopu))
      IF RIGHT(RTRIM(sp25->crt),4)<>"ТТТТ"
         m_kopr1:=sp25->crt
      ELSE
         m_kopr1:=SUBSTR(sp25->crt,1,3)+flish->tabn
      ENDIF


      IF IsAnCodTabn(m_kopr1).OR.RIGHT(RTRIM(sp25->crt),4)=="ТТТТ"
        IF .NOT. buf2->(DBSEEK(flish->kopu+sp25->kopr+m_kopr1+PADR(flish->tabn,10)+sp25->dbt))
            buf2->(DBAPPEND())
            buf2->crt:=m_kopr1
            IF IsAnCodTabn(m_kopr1)
              buf2->cod2:=padr(flish->tabn,10)
            ENDIF
            buf2->kopu:=flish->kopu
            buf2->dbt:=sp25->dbt
            IF IsAnCodTabn(buf2->dbt)
              buf2->cod1:=padr(flish->tabn,10)
            ENDIF
            buf2->kopr:=sp25->kopr
        ENDIF
      ELSE
        IF .NOT. buf2->(DBSEEK(flish->kopu+sp25->kopr+m_kopr1+SPACE(10)+sp25->dbt))
            buf2->(DBAPPEND())
            buf2->crt:=m_kopr1
            buf2->kopu:=flish->kopu
            buf2->dbt:=sp25->dbt
            IF IsAnCodTabn(buf2->dbt)
              buf2->cod1:=padr(flish->tabn,10)
            ENDIF
            buf2->kopr:=sp25->kopr
        ENDIF
      ENDIF
      buf2->stm+=flish->sum
      buf2->glv+=flish->oths
      buf2->kvo+=flish->otdn
    ENDIF
   ENDIF
   SKIP -1 ALIAS flish
ENDDO
CLOSE flish
IF .not.l_iskassa
  bufprApp("8",SPACE(4),SPACE(2),SPACE(2),SPACE(2),SPACE(2),m_dbtmoney,SPACE(10),;
  '500001',SPACE(10),0,0,0,g_sum-m_stm)
  ?'Дебет 70 - Кредит 50',SumToStr(g_sum-m_stm,12) ," - сума випл. зар. платнi"
  ?"Розр. як сума кода 800 мин. мiсяця ",SumToStr(g_sum,12), " мiнус код 078 ",SumToStr(m_stm,12)
ENDIF
uder(m_month,m_dbtmoney)
IF l_part2==1 // Заносить  проводки  на 2-ю часть
  Zanes(m_month,m_date,m_mnt)
ENDIF
?REPLICATE("=",80)
?
?
?STRZERO(m_month,2)+m_oper+DTOS(DATE())+TIME()+"ZZ"
SET PRINTER TO
SET PRINT Off
SET CONSOLE On
FILECOPY(m_mash+"45.txt",m_mash+"45"+STRZERO(m_month,2)+".txt")
CLOSE base buf1,buf2,buf3,buf4,buf5,buf7,bufpr,buf8,buf9
CLOSE base sp10,inv_a,sp44,sp22,sp13b,inv_t,sp25,sp23,sp08
CLOSE base fp2,fp1
COMMIT
// WaitMessage("Проiндексуйте основну базу у проводках")
RETURN .t.
STATIC Function RestVar(m_name)
myvar->(DBSEEK(PADR(LOWER(ALLTRIM(m_name)),12)))
DO CASE
  CASE myvar->kod=="C"
    RETURN (ALLTRIM(myvar->value))
  CASE myvar->kod=="N"
    RETURN (VAL(myvar->value))
  CASE myvar->kod=="L"
    RETURN (IF(AT(UPPER(ALLTRIM(myvar->value)),"1TYД")<>0,.t.,.f.))
  CASE myvar->kod=="D"
    RETURN (CTOD(ALLTRIM(myvar->value)))
ENDCASE
RETURN (0)
STATIC Function SaveVar(m_name,m_value)
myvar->(DBSEEK(PADR(LOWER(ALLTRIM(m_name)),12)))
IF .NOT.myvar->(FOUND())
  myvar->(DBAPPEND())
  myvar->name:=m_name
ENDIF
DO CASE
  CASE VALTYPE(m_value)=="C"
    myvar->kod:="C"
    myvar->value:=m_value
  CASE VALTYPE(m_value)=="D"
    myvar->kod:="D"
    myvar->value:=DTOC(m_value)
  CASE VALTYPE(m_value)=="N"
    myvar->kod:="N"
    myvar->value:=ALLTRIM(STR(m_value))
  CASE VALTYPE(m_value)=="L"
    myvar->kod:="L"
    myvar->value:=IF(m_value,"1","0")
ENDCASE
RETURN (0)
Function br1(a_kmtop,m_month)
  LOCAL   m_br,; // BROWSE обьект марок горючего
  m_col,m_key,N_ROW:=1,n:=LEN(a_kmtop),i,GetList:={}
  IF LEN(a_kmtop)==0
    RETURN .T.
  ENDIF

  m_br:=TBROWSENEW(7,3,20,42)
  m_br:ColorSpec:="W/b,b/w,w/r,r/w"
  m_br:SkipBlock:={|x|MySkip(x,@n_row,n)}
  m_br:GoTopBlock:={||n_row:=1};m_br:GoBottomBlock:={||n_row:=n}
  m_br:ColSep:='│'
  m_col:=TBColumnNew()
  m_col:block:={||mnt_data(a_kmtop[n_row,7])}
  m_col:heading:="Мiсяць"
  m_col:colorBlock:={||IF(a_kmtop[n_row,2]<>0.AND.a_kmtop[n_row,3]<>0,{1,2},{3,4})}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  m_col:=TBColumnNew()
  m_col:block:={||sp44->(DBSEEK("0610"+a_kmtop[n_row,1])),a_kmtop[n_row,1]+" "+sp44->naim7}
  m_col:heading:="Марка  палива"
  m_col:colorBlock:={||IF(a_kmtop[n_row,2]<>0.AND.a_kmtop[n_row,3]<>0,{1,2},{3,4})}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_col:width:=15
  m_br:AddColumn(m_col)
  m_col:=TBColumnNew()
  m_col:block:={|x|IF(x==NIL,TRANSFORM(a_kmtop[n_row,2],"9.999"),a_kmtop[n_row,2]:=x)}
  m_col:heading:="Темп.;коэфф."
  m_col:colorBlock:={||{1,2}}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  m_col:=TBColumnNew()
  m_col:block:={|x|IF(x==NIL,TRANSFORM(a_kmtop[n_row,3],'99999.99'),a_kmtop[n_row,3]:=x)}
  m_col:heading:="Цiна"
  m_col:colorBlock:={||{1,2}}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  FOR i:=1 to LEN(a_kmtop)
    sp22->(DBSEEK(a_kmtop[i,7]+a_kmtop[i,1]))
    a_kmtop[i,2]:=sp22->koef
    a_kmtop[i,3]:=sp22->prise
  NEXT
  m_br:ColPos:=3
  SET ESCAPE OFF
  DO WHILE .T.
      m_br:refreshCurrent()
    STABILIZE BROWSE m_br
    DO CASE
      CASE m_br:ColPos==3
        @ROW(),COL() Get a_kmtop[n_row,2] PICTURE "9.999" COLOR "w/b,GR+/N"
        READ
        DO CASE
          CASE  LASTKEY()==K_F12.OR.LASTKEY()==K_CTRL_END
            EXIT
          CASE  LASTKEY()==K_UP.AND.n_row<>1
            m_br:up();m_br:right()
          OTHERWISE
            m_br:Right()
        ENDCASE
     CASE m_br:ColPos==4
        @ROW(),COL() Get a_kmtop[n_row,3] PICTURE '99999.99' COLOR "w/b,GR+/N"
        READ
        DO CASE
          CASE  LASTKEY()==K_F12.OR.LASTKEY()==K_CTRL_END
            EXIT
          CASE  LASTKEY()==K_UP
            m_br:left()
          OTHERWISE
            IF n_row==n
              m_br:refreshCurrent()
              STABILIZE BROWSE m_br
              m_br:AutoLite:=.f.
              m_br:Dehilite()
              EXIT
            ENDIF
            m_br:down();m_br:Left()
          ENDCASE
      ENDCASE
  ENDDO
  FOR i:=1 to LEN(a_kmtop)
    sp22->(DBSEEK(a_kmtop[i,7]+a_kmtop[i,1]))
    IF .NOT.sp22->(FOUND())
      sp22->(NetDbAp())
      sp22->mnt:=a_kmtop[i,7]
      sp22->kmtop:=a_kmtop[i,1]
      Sp22->(DbUnlock())
    ENDIF
    IF Sp22->(NetRlock())
      sp22->koef  :=a_kmtop[i,2]
      sp22->prise :=a_kmtop[i,3]
    ENDIF
    Sp22->(DbUnlock())
  NEXT
RETURN .t.

Function br2(a_kmtr)
  LOCAL   m_br,; // BROWSE обьект марок горючего
  m_col,m_key,N_ROW:=1,n:=LEN(a_kmtr),GetList:={},i
IF LEN(a_kmtr)>0
  m_br:=TBROWSENEW(7,43,20,76)
  m_br:ColorSpec:="W/b,b/w,w/r,r/w"
  m_br:SkipBlock:={|x|MySkip(x,@n_row,n)}
  m_br:GoTopBlock:={||n_row:=1};m_br:GoBottomBlock:={||n_row:=n}
  m_br:ColSep:='│'
  m_col:=TBColumnNew()
  m_col:block:={||sp13b->(DBSEEK(a_kmtr[n_row,1])),a_kmtr[n_row,1]+" "+sp13b->naim13b}
  m_col:heading:="Марка комбайна"
  m_col:colorBlock:={||IF(a_kmtr[n_row,2]<>0,{1,2},{3,4})}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  m_col:=TBColumnNew()
  m_col:block:={|x|IF(x==NIL,TRANSFORM(a_kmtr[n_row,2],'99999.99'),a_kmtr[n_row,2]:=x)}
  m_col:heading:="Вартiсть;фiз. га "
  m_col:colorBlock:={||{1,2}}
  m_Col:headsep    := "┬─"
  m_col:colsep:="│"
  m_col:footsep:="╧═"
  m_br:AddColumn(m_col)
  FOR i:=1 to LEN(a_kmtr)
    sp13b->(DBSEEK(a_kmtr[i,1]))
    a_kmtr[i,2]:=sp13b->stm
  NEXT
  m_br:ColPos:=2
  SET ESCAPE OFF
  DO WHILE .T.
    m_br:refreshCurrent()
    STABILIZE BROWSE m_br
    @ROW(),COL() Get a_kmtr[n_row,2] PICTURE '99999.99'  COLOR "w/b,GR+/N"
    READ
      DO CASE
      CASE  LASTKEY()==K_F12.OR.LASTKEY()==K_CTRL_END
        EXIT
    CASE  LASTKEY()==K_UP.AND.n_row<>1
      m_br:up()
    OTHERWISE
    IF n_row==n
      m_br:refreshCurrent()
      STABILIZE BROWSE m_br
      m_br:AutoLite:=.f.
      m_br:Dehilite()
      EXIT
    ENDIF
    m_br:down()
  ENDCASE
  ENDDO
  FOR i:=1 to LEN(a_kmtr)
    IF sp13b->(DBSEEK(a_kmtr[i,1]))
      sp13b->(NetRlock())
      sp13b->stm:=a_kmtr[i,2]
      sp13b->(DbUnlock())
    ENDIF
  NEXT
ENDIF
RETURN .t.

STATIC Function mySkip(x,n_row,n)
  Local i:=IF(x>0,MIN(n-n_row,x),MAX(x,1-n_row))
  n_row+=i
RETURN i
Static Function uder(m_month,m_dbtmoney)
LOCAL m_kopr1,m_kopr2,m_prise1:=0,m_prise2:=0
SELECT buf2
m_prise1 :=0
buf2->(DBGOTOP())
DO WHILE .NOT.buf2->(EOF())
   m_kopr1:=buf2->kopr
   m_kopr2:=buf2->kopu
   sp08->(DBSEEK(m_kopr2))
    m_prise2  :=0
   ?'Операцiя - ',m_kopr1,' Вид утримання ',m_kopr2,sp08->name8
   DO WHILE .NOT.buf2->(EOF()).AND.m_kopr1==buf2->kopr.AND.m_kopr2==buf2->kopu
      sp44->(dbseek(buf2->crt))
      ?'Дебет '+buf2->dbt+' - Кредит '+buf2->crt,NumTostr(buf2->glv,7),SumToStr(buf2->kvo,16),SumToStr(buf2->stm,12)
      bufprApp("8",SPACE(4),m_kopr1,SPACE(2),SPACE(2),SPACE(2),buf2->dbt,buf2->cod1,;
      buf2->crt,buf2->cod2,buf2->glv,0,buf2->kvo,buf2->stm)
      m_prise2+=buf2->stm
      m_prise1+=buf2->stm
      SKIP ALIAS buf2
   ENDDO
   ?'Разом---------',SumToStr(m_prise2,12)
ENDDO
?'РАЗОМ ******',SumToStr(m_prise1,20)
RETURN .t.


STATIC Function Zanes(m_month,m_date,m_mnt)
LOCAL m_vnum,m_ndoc,m_npch,m_kopr1,m_prise4,m_vdoc
USE (m_mainpath+"fvnum.dbr") NEW
m_vnum := fvnum->vnum
m_npch :=900+m_month
bufpr->(DBCLEARINDEX())
SELECT bufpr
DELETE FOR bufpr->glv==0.AND.bufpr->kvo==0.AND.bufpr->kvo2==0.AND.bufpr->stm==0
INDEX ON  bufpr->vdoc+bufpr->tabn TO (m_temppath+"bufpr")
bufpr->(DBGOTOP())
m_prise4:=1
DO WHILE .NOT.bufpr->(EOF())
   fp1->(DBAP())
   fp1->vnum:=str(m_vnum++,7)
   fp1->ndoc:=STR(m_prise4,6)
   fp1->npch:= STR(m_npch,5)
   fp1->maket:= VDOC_UCHET
   fp1->ddoc:= m_date
   fp1->mnt:=m_mnt
   fp1->dvv := date()
   fp1->oper:= 'WW'
   fp1->tabn:=bufpr->tabn
   m_prise4 := m_prise4+1
   m_vdoc:=bufpr->vdoc
   DO WHILE .NOT.bufpr->(EOF()).AND.m_vdoc==bufpr->vdoc.AND.bufpr->tabn==fp1->tabn
      fp2->(DBAPPEND())
      fp2->vnum:=fp1->vnum
      fp2->kopr:= bufpr->kopr
      fp2->brgd1:= bufpr->brgd1
      fp2->brgd2:= bufpr->brgd2
      fp2->otp := bufpr->otp
      fp2->dbt:= bufpr->dbt
      fp2->cod1:= bufpr->cod1
      fp2->crt:= bufpr->crt
      fp2->cod2:= bufpr->cod2
      fp2->kvo:= bufpr->kvo
      fp2->kvo2:= bufpr->kvo2
      fp2->glv :=bufpr->glv
      fp2->stm:= bufpr->stm
      bufpr->(DBSKIP())
    ENDDO
   ENDDO
fvnum->vnum:=m_vnum
CLOSE fvnum
RETURN .t.

STATIC FUNCTION OpenFl(m_month)
LOCAL l_delete
CrStruct("USCH00","bufpr")
USE (m_temppath+"bufpr") NEW ALIAS bufpr
INDEX ON bufpr->vdoc+bufpr->tabn+bufpr->kopr+bufpr->brgd1+bufpr->brgd2+bufpr->otp+bufpr->dbt+bufpr->cod1+bufpr->crt+bufpr->cod2  to (m_temppath+"bufpr")
CrStruct("USCH01","buf1")
USE (m_temppath+"buf1") NEW ALIAS buf1
INDEX ON buf1->vdoc+buf1->brgd1+buf1->brgd2+buf1->dbt+buf1->cod1+buf1->vrab+buf1->crt+buf1->cod2+buf1->kpn+buf1->kopu+buf1->tabn  to (m_temppath+"buf1")
CrStruct("USCH02","buf2")
USE (m_temppath+"buf2") NEW ALIAS buf2
INDEX ON buf2->kopu+buf2->kopr+buf2->crt+buf2->cod2+buf2->dbt  to (m_temppath+"buf2")
CrStruct("USCH03","buf3")
USE (m_temppath+"buf3") NEW ALIAS buf3
INDEX ON buf3->brgd1+buf3->brgd2+buf3->dbt+buf3->vrab+buf3->crt+buf3->cod2  to (m_temppath+"buf3")
CrStruct("USCH04","buf4")
USE (m_temppath+"buf4") NEW ALIAS buf4
INDEX ON buf4->brgd1+buf4->brgd2+buf4->dbt+buf4->crt+buf4->cod2  to (m_temppath+"buf4")
CrStruct("USCH05","buf5")
USE (m_temppath+"buf5") NEW ALIAS buf5
INDEX ON buf5->kmtop+buf5->dbt+buf5->cod1+buf5->tabn+buf5->mnt  to (m_temppath+"buf5")
CrStruct("USCH07","buf7")
USE (m_temppath+"buf7") NEW ALIAS buf7
INDEX ON buf7->brgd1+buf7->brgd2+buf7->dbt+buf7->vrab+buf7->crt+buf7->kmtr+buf7->cod2 to (m_temppath+"buf7")
CrStruct("USCH08","buf8")
USE (m_temppath+"buf8") NEW ALIAS buf8
INDEX ON buf8->tabn to (m_temppath+"buf8")
CrStruct("USCH09","buf9")
USE (m_temppath+"buf9") NEW ALIAS buf9
INDEX ON buf9->tabn+buf9->brgd1+buf9->brgd2+buf9->dbt+buf9->vrab+buf9->crt+buf9->cod2+buf9->mnt to (m_temppath+"buf9")
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW
NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44") NEW
NET USE (m_sprpath+"sp22") INDEX (m_sprpath+"sp22") NEW
NET USE (m_sprpath+"sp13b") INDEX (m_sprpath+"sp13b") NEW
NET USE (m_sprpath+"sp25") INDEX (m_sprpath+"sp25") NEW
NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08") NEW
NET USE (m_sprpath+"sp23") INDEX (m_sprpath+"sp23") NEW
NET USE (m_sprpath+"inv_a") INDEX (m_sprpath+"inv_a") NEW
NET USE (m_sprpath+"inv_t") INDEX (m_sprpath+"inv_t") NEW
USE (m_mainpath+"fz1") NEW
USE (m_mainpath+"fz1t") NEW
USE (m_mainpath+"fz2") NEW
SET RELATION TO fz2->tabn INTO sp10
USE (m_mainpath+"fz3") NEW
USE (m_mainpath+"fz1ae") NEW
USE (m_mainpath+"fz1at") NEW
USE (m_mainpath+"fz2a") NEW
USE (m_mainpath+"fz2t") NEW
USE (m_mainpath+"fz2tp") NEW
use (m_uchpath+"s_1_2b") ALIAS s_1_2 NEW
Return .t.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION pFilPoz(m_nmfl_1, m_nmpl_1, m_nmfl_2)

LOCAL  m_fict_zap,n1:=(m_nmfl_1)->(FIELDNUM(ALLTRIM(m_nmpl_1)))
LOCAL  m_fict_al,n2:=(m_nmfl_2)->(FIELDNUM(ALLTRIM(m_nmpl_1)))
m_fict_al := SELECT()
SELECT (m_nmfl_1)
m_fict_zap :=  RECNO()
LOCATE  REST  FOR  (m_nmfl_1)->(FIELDGET(n1))==(m_nmfl_2)->(FIELDGET(n2))
IF  FOUND()
     SELECT( m_fict_al )
     RETURN( .T. )
   ELSE
     GOTO m_fict_zap
     SELECT( m_fict_al )
     RETURN( .F. )
ENDIF
RETURN .t.
STATIC FUNCTION SayPeople()
LOCAL a_sum:= {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}
LOCAL a_kvo:= {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}
LOCAL a_otdn:={{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}}
LOCAL a_stm:={},m_file,m_buf:=SPACE(12),j,n1
LOCAL a_oths:={{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}},i
m_file:=FOPEN(m_uchpath+"Tabl1.txt")
IF m_file<>0
DO WHILE .t.
  i:=FREAD(m_file,@m_buf,12)
  IF i<>12
    EXIT
  ENDIF
  AADD(a_stm,{VAL(m_buf),0,0,0,0,0})
ENDDO
FCLOSE(m_file)
ENDIF
n1:=LEN(a_stm)
buf8->(DBGOTOP())
DO WHILE .NOT.BUF8->(EOF())
  DO CASE
    CASE buf8->kpn=="4"
      i:=2
    CASE buf8->kpn=="6"
      i:=3
    CASE buf8->kpn=="7"
      i:=4
    OTHERWISE
      i:=1
  ENDCASE
  a_sum [i][1] +=buf8->sum
  a_otdn[i][1]+=buf8->otdn
  a_oths[i][1]+=buf8->oths
  a_kvo [i][1] +=1
  IF buf8->pol=="0"
    a_sum [i][2] +=buf8->sum
    a_otdn[i][2]+=buf8->otdn
    a_oths[i][2]+=buf8->oths
    a_kvo [i][2] +=1
  ENDIF
  FOR j:=1 TO n1
    IF buf8->sum<a_stm[j,1]
      a_stm[j,i+1]:=a_stm[j,i+1]+1
      a_stm[j,6]+=buf8->sum
      EXIT
    ENDIF
  NEXT
  Buf8->(DBSKIP())
ENDDO
?"Осн. робiтники=",NumTostr(a_kvo[1][1],5,0),"Днiв =",NumTostr(a_otdn[1][1],8,1),"Годин =",NumTostr(a_oths[1][1],9,2),"Сума =",SumTostr(a_sum[1][1],12)
?"   З них жiнки=",NumTostr(a_kvo[1][2],5,0),"Днiв =",NumTostr(a_otdn[1][2],8,1),"Годин =",NumTostr(a_oths[1][2],9,2),"Сума =",SumTostr(a_sum[1][2],12)
?"     Сумiсники=",NumTostr(a_kvo[2][1],5,0),"Днiв =",NumTostr(a_otdn[2][1],8,1),"Годин =",NumTostr(a_oths[2][1],9,2),"Сума =",SumTostr(a_sum[2][1],12)
?"   З них жiнки=",NumTostr(a_kvo[2][2],5,0),"Днiв =",NumTostr(a_otdn[2][2],8,1),"Годин =",NumTostr(a_oths[2][2],9,2),"Сума =",SumTostr(a_sum[2][2],12)
?"По договорам  =",NumTostr(a_kvo[3][1],5,0),"Днiв =",NumTostr(a_otdn[3][1],8,1),"Годин =",NumTostr(a_oths[3][1],9,2),"Сума =",SumTostr(a_sum[3][1],12)
?"   З них жiнки=",NumTostr(a_kvo[3][2],5,0),"Днiв =",NumTostr(a_otdn[3][2],8,1),"Годин =",NumTostr(a_oths[3][2],9,2),"Сума =",SumTostr(a_sum[3][2],12)
?"      Iнвалiди=",NumTostr(a_kvo[4][1],5,0),"Днiв =",NumTostr(a_otdn[4][1],8,1),"Годин =",NumTostr(a_oths[4][1],9,2),"Сума =",SumTostr(a_sum[4][1],12)
?"   З них жiнки=",NumTostr(a_kvo[4][2],5,0),"Днiв =",NumTostr(a_otdn[4][2],8,1),"Годин =",NumTostr(a_oths[4][2],9,2),"Сума =",SumTostr(a_sum[4][2],12)
?"Разом         =",NumTostr(a_kvo[1][1]+a_kvo[2][1]+a_kvo[3][1]+a_kvo[4][1],5,0)
??" Днiв =",NumTostr(a_otdn[1][1]+a_otdn[2][1]+a_otdn[3][1]+a_otdn[4][1],8,1)
??" Годин =",NumTostr(a_oths[1][1]+a_oths[2][1]+a_oths[3][1]+a_oths[4][1],9,2)
??" Сума =",SumTostr(a_sum[1][1]+a_sum[2][1]+a_sum[3][1]+a_sum[4][1],12)
?"Разом  жiнки  =",NumTostr(a_kvo[1][2]+a_kvo[2][2]+a_kvo[3][2]+a_kvo[4][2],5,0)
??" Днiв =",NumTostr(a_otdn[1][2]+a_otdn[2][2]+a_otdn[3][2]+a_otdn[4][2],8,1)
??" Годин =",NumTostr(a_oths[1][2]+a_oths[2][2]+a_oths[3][2]+a_oths[4][2],9,2)
??" Сума =",SumTostr(a_sum[1][2]+a_sum[2][2]+a_sum[3][2]+a_sum[4][2],12)
i:=0
?"                        Осн.   Сумiс-   По до-  Iнва-  Разом  Усього    "
?"                    робiтники   ники   говорам  лiди          нараховано"
FOR j:=1 TO n1
  ?SumToSTR(i,8)+" до " +SumToSTR(a_stm[j,1],10)
  ??NUmToStr(a_stm[j,2],6),NUmToStr(a_stm[j,3],6),NUmToStr(a_stm[j,4],6),NUmToStr(a_stm[j,5],6)
  ??NUmToStr(a_stm[j,5]+a_stm[j,4]+a_stm[j,3]+a_stm[j,2],6)
  ??NumToStr(a_stm[j,6],14)
  i:=a_stm[j,1]
NEXT
RETURN .t.

Function ViewProc
  LOCAL m_browse,m_col,l_print:={},l_delete:=.t.,m_get
  LOCAL m_key,s_file:={}
  LOCAL m_get1:=GetNew(),m_get2:=GetNew()
  m_get2:PostBlock:={||sp44->(Sp_vl("SP44"))}
  // Создание BROWSE объекта
  SavePar()
  m_get1:ColorSpec:="Gr+/n,Gr+/n"
  m_get2:ColorSpec:="Gr+/n,Gr+/n"
  SopenFiles("SP44",@s_file)
  USE (m_uchpath+"s_1_2b") NEW
  CLEARWIN(0,0,MAXROW(),MAXCOL(),"w/b")
  @0,0 SayDisp PADC("Проценти нарахувань по зар. платнi",79) COLOR "GR+/B"
  @1,0,MAXROW()-12,MAXCOL() BOX B_DOUBLE COLOR "w/b"
  m_browse:=TBrowseDB(2,1,MAXROW()-12,MAXCOL()-1)
  m_browse:colorspec:='W/B,B/W,w+/b,w+/b'
  m_browse:colsep        := '│'
  m_browse:SkipBlock     := { |n| SkipDb(n) }
  m_browse:goBottomBlock := { ||  DBGOBOTTOM() }
  m_browse:goTopBlock    := { ||  DBGOTOP()  }
  // Описание блоков
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->name)
      m_col:heading:="   Назва; нарахування"
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(s_1_2b->ksash)
      m_col:heading:="Ан. код;нарах."
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->procent1)
      m_col:heading:="    % ;для осн.;роб."
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->procent2)
      m_col:heading:="   % ;для дог."
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->procent3)
      m_col:heading:="  % ;для iнв."
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->f1)
      m_col:heading:="Шифр ;облiку 1"
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->f2)
      m_col:heading:="Шифр ;облiку 2"
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->f3)
      m_col:heading:="Шифр ;облiку 3"
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->f4)
      m_col:heading:="Шифр ;облiку 4"
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->f5)
      m_col:heading:="Шифр ;облiку 5"
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->f6)
      m_col:heading:="Шифр ;облiку 6"
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
      m_Col           := TBColumnNew()
      m_col:block:=COLBR(field->kopu)
      m_col:heading:="Коди оплат "
      AADD(l_print,.t.);m_Col:colorblock:=  {|| {1,2}}
      m_Col:headsep    := "┬─";m_col:colsep:="│";m_col:footsep:="╧═"
     m_browse:addColumn(m_col)
    m_browse:freeze        := 2
  DO WHILE .t.
    m_browse:refReshCurrent()
    STABILIZE BROWSE m_browse
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{3,3})
    m_browse:ColorRect({m_browse:RowPos,m_browse:colPos,m_browse:RowPos,m_browse:colPos},{2,2})
    SP44->(DBSEEK(s_1_2b->ksash))
    @13,0  SayDisp "Нарахування" COLOR "w/B"
    @ROW(),13  SayDisp s_1_2b->name  COLOR "w+/B"
    @ROW(),35  SayDisp "Кредiт" COLOR "w/B"
    @ROW(),42 SayDisp s_1_2b->ksash  COLOR "w+/B*"
    @ROW(),49 SayDisp SP44->naim7  COLOR "Gr+/B"
    @ROW()+1,8 SayDisp " Осн. робiтники  По договорам  Iнвалiди" COLOR "w/B"
    @ROW()+1,0 SayDisp "Процент"  COLOR "w/B"
    @ROW(),15 SayDisp s_1_2b->procent1 COLOR "w+/B*"
    @ROW(),30 SayDisp s_1_2b->procent2 COLOR "w+/B*"
    @ROW(),45 SayDisp s_1_2b->procent3 COLOR "w+/B*"
    @ROW()+1,0  SayDisp "Субрахунки i рахунки на якi не начисляти нарахування "   COLOR "w/B"
    SP44->(DBSEEK(PADR(RTRIM(s_1_2b->f1),6,"0")))
    @ROW()+1,5  SayDisp s_1_2b->f1   COLOR "w+/B*"
    @ROW(),15 SayDisp SP44->naim7  COLOR "Gr+/B"
    SP44->(DBSEEK(PADR(RTRIM(s_1_2b->f4),6,"0")))
    @ROW(),40  SayDisp s_1_2b->f4   COLOR "w+/B*"
    @ROW(),48 SayDisp SP44->naim7  COLOR "Gr+/B"
    SP44->(DBSEEK(PADR(RTRIM(s_1_2b->f2),6,"0")))
    @ROW()+1,5  SayDisp s_1_2b->f2   COLOR "w+/B*"
    @ROW(),15 SayDisp SP44->naim7  COLOR "Gr+/B"
    SP44->(DBSEEK(PADR(RTRIM(s_1_2b->f5),6,"0")))
    @ROW(),40  SayDisp s_1_2b->f5   COLOR "w+/B*"
    @ROW(),48 SayDisp SP44->naim7  COLOR "Gr+/B"
    SP44->(DBSEEK(PADR(RTRIM(s_1_2b->f3),6,"0")))
    @ROW()+1,5  SayDisp s_1_2b->f3   COLOR "w+/B*"
    @ROW(),15 SayDisp SP44->naim7  COLOR "Gr+/B"
    SP44->(DBSEEK(PADR(RTRIM(s_1_2b->f6),6,"0")))
    @ROW(),40  SayDisp s_1_2b->f6   COLOR "w+/B*"
    @ROW(),48 SayDisp SP44->naim7  COLOR "Gr+/B"
    @ROW()+1,0  SayDisp "Коди оплат на якi не начисляти нарахування "   COLOR "w/B"
    @ROW()+1,0  SayDisp s_1_2b->kopu   COLOR "w+/B*"
    m_key:=INKEY(0)
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{1,1})
    DO CASE
      DEAL BROWSE m_browse KEY m_key
      CASE m_key==K_ENTER.AND.s_1_2b->(RECNO())<>1
        STABILIZE BROWSE m_browse
        IF m_browse:ColPos<>2
           m_get:=m_get1
        ELSE
           m_get:=m_get2
        ENDIF
        m_get:Row:=ROW();m_get:Col:=COL()
        m_get:Block:=m_browse:GetColumn(m_browse:ColPos):block
        SET ESCAPE ON
        ReadMy({m_get})
        SET ESCAPE OFF
    ENDCASE
  ENDDO
ScloseFiles(@s_file)
// CLOSE BASE s_1_2b,SPTABL,SPTABL1,VIEW,Screen
CLOSE BASE s_1_2b
  SavePar(1)
RETURN .t.
FUNCTION SkipDb(n)
    LOCAL  ncount  := 0
IF n > 0
   DO WHILE ncount < n
        DBSKIP()
       // Если конец файла
       IF  EOF()
          DBSKIP( -1 )
          EXIT
       END
       ncount++
   ENDDO
ELSEIF n < 0
   DO WHILE ncount > n
       DBSKIP( -1 )
       IF BOF()
          EXIT
       END
       ncount--
   ENDDO
END
RETURN ( ncount )
Function EditVar()
  LOCAL a_get:={},a_data:={},i,n,n_pole:=1,n_win,m_key,s_file:={}
LOCAL a_name:={"m_dbtavto","m_dbttract","m_dbtmoney","m_dbtsavto",;
      "l_iszrtr","l_isgsmtr","m_dbtgsm","m_koddzt","l_iskassa",;
      "m_kopr1","m_kopr2","m_kopr3", "m_kopr4",;
      "m_kopr5","m_kopr6","m_kopr7","m_kopr8","m_molavto","m_moltr",;
      "l_part2"}
LOCAL a_str:={;
"Шифр витрат автопарку",;
"            тракторiв",;
"          зар. платнi",;
"   спецавтотранспорту",;
"Транзит зар. платнi трактористiв",;
"Транзит ПММ трактористiв",;
"Субрахунок           ПММ",;
"Код дизельного палива",;
"Є каса",;
"Код операцiї зар. платнi",;
"                     ПММ",;
"              умовних га",;
"                 фiз. га",;
"          т/км тракторiв",;
"        т/км автомобiлей",;
"          км автомобiлей",;
"               автогодин",;
"Код МВО шоферiв",;
"     трактористiв",;
"1-заносити пров. у 2-у частину"}

  SavePar()
SopenFiles("SP05",@s_file)
USE (m_uchpath+"inst1") INDEX  (m_uchpath+"inst1") new ALIAS myvar
@0,0,MAXROW(),MAXCOL() BOX B_DOUBLE+" " COLOR "w/b"
  n:=LEN(a_name)
  ASIZE(a_data,n)
  ASIZE(a_get,n)
  FOR n_pole:=1 TO n
    a_data[n_pole]:=RestVar(a_name[n_pole])
    a_get[n_pole]:=GetNew()
    a_get[n_pole]:row:=n_pole
    a_get[n_pole]:col:=36
    a_get[n_pole]:Block:={|x|IF(x==NIL,a_data[n_pole],a_data[n_pole]:=x)}
    a_get[n_pole]:ColorSpec:="w+/b*,gr+/n"
    @n_pole,1 SayDisp a_str[n_pole] COLOR "w/b"
    a_get[n_pole]:Display()
    IF n_pole>=10.AND.n_pole<=17
      a_get[n_pole]:PostBlock:={||Sp05->(Sp_vl("SP05"))}
    ENDIF
  NEXT

  n_pole:=1
  DO WHILE .t.
    a_get[n_pole]:ColorSpec:="b/w,b/w"
    a_get[n_pole]:Display()
    m_key:=INKEY(0)
    a_get[n_pole]:ColorSpec:="w+/b*,gr+/n"
    a_get[n_pole]:Display()
  DO CASE
    CASE m_key==K_ESC
      EXIT
    CASE m_key==K_UP
      n_pole:=IF(n_pole==1,n,n_pole-1)
    CASE m_key==K_DOWN
      n_pole:=IF(n_pole==n,1,n_pole+1)
    CASE m_key==K_ENTER
      ReadMy({a_get[n_pole]})
      IF LASTKEY()<>K_ESC
        SaveVar(a_name[n_pole],a_data[n_pole])
      ENDIF
  ENDCASE
  ENDDO
  ScloseFiles(@s_file)
  CLOSE myvar
  SavePar(1)
RETURN .t.

STATIC Function UdalPrev(m_mnt)
USE (m_mainpath+"fp2") INDEX (m_mainpath+"fp2")  NEW
USE (m_mainpath+"fp1") NEW
// Если расчет выполнялся не первый раз удаляются данные предыдущего расчета
LOCATE FOR fp1->maket == VDOC_UCHET .AND. fp1->mnt == m_mnt
DO WHILE .NOT.fp1->(EOF())
  IF Fp2->(DS(Fp1->vnum))
    SELECT fp2
    DELETE WHILE fp2->vnum == fp1->vnum
  ENDIF
  SELECT fp1
  DELETE
  CONTINUE
ENDDO
RETURN .t.

Function IsAnCodAvto(m_ksash)
  Sp44->(DS(m_ksash))
  IF Sp44->type1 == "6"
    RETURN .T.
  ENDIF
return .f.
Function IsAnCodTract(m_ksash)
  Sp44->(DS(m_ksash))
  IF Sp44->type1 == "7"
    RETURN .T.
  ENDIF
return .f.
Function IsAnCodTabn(m_ksash)
  Sp44->(DS(m_ksash))
  IF Sp44->type1 == "2"
    RETURN .T.
  ENDIF
return .f.
STATIC FUNCTION Buf1App(m_vdoc,m_brgd1,m_brgd2,m_dbt,m_cod1,m_vrab,m_crt,m_cod2,m_kpn,m_kopu,l_first,m_oths,m_otdn,m_sum,m_tabn)
m_brgd1 :=PADR(m_brgd1,2)
m_brgd2 :=PADR(m_brgd2,2)
m_dbt   :=PADR(m_dbt  ,7)
m_cod1  :=PADR(m_cod1,10)
m_vrab  :=PADR(m_vrab ,3)
m_crt   :=PADR(m_crt  ,7)
m_cod2  :=PADR(m_cod2,10)
m_kopu  :=PADR(m_kopu ,3)
IF .NOT.buf1->(DBSEEK(m_vdoc + m_brgd1 + m_brgd2 + m_dbt +m_cod1+ m_vrab + m_crt+m_cod2+m_kpn+m_kopu+m_tabn))
    buf1->(DBAPPEND())
    buf1->vdoc  := m_vdoc
    buf1->brgd1 := m_brgd1
    buf1->brgd2 := m_brgd2
    buf1->dbt   := m_dbt
    buf1->cod1  := m_cod1
    buf1->vrab :=  m_vrab
    buf1->kopu :=  m_kopu
    buf1->crt  :=  m_crt
    buf1->cod2  := m_cod2
    buf1->kpn  :=  m_kpn
    buf1->tabn  :=  m_tabn
ENDIF
IF l_first
  buf1->oths += m_oths
  buf1->otdn += m_otdn
ENDIF
buf1->sum  += m_sum
RETURN .T.
STATIC FUNCTION   Buf8App(m_tabn,m_pol,m_kpn,l_first,m_otdn,m_oths,m_sum)
IF .NOT.Buf8->(DS(m_tabn))
  buf8->(DBAP())
  buf8->tabn:=m_tabn
  buf8->pol:= m_pol
  buf8->kpn :=m_kpn
ENDIF
IF l_first
  buf8->otdn+=m_otdn
  buf8->oths += m_oths
  l_first:=.f.
ENDIF
buf8->sum  += m_sum
RETURN .T.
STATIC FUNCTION bufprApp(m_vdoc,m_tabn,m_kopr,m_brgd1,m_brgd2,m_otp,m_dbt,m_cod1,m_crt,m_cod2,m_glv,m_kvo2,m_kvo,m_stm)
m_brgd1 :=PADR(m_brgd1,2)
m_brgd2 :=PADR(m_brgd2,2)
m_dbt   :=PADR(m_dbt  ,7)
m_cod1  :=PADR(m_cod1,10)
m_crt   :=PADR(m_crt  ,7)
m_cod2  :=PADR(m_cod2,10)
m_kopr  :=PADR(m_kopr ,2)
m_otp   :=PADR(m_otp  ,2)
IF .NOT.bufpr->(DS( m_vdoc+m_tabn+m_kopr+m_brgd1+m_brgd2+m_otp+m_dbt+m_cod1+m_crt+m_cod2))
    bufpr->(DBAP())
    bufpr->vdoc  :=  m_vdoc
    bufpr->tabn  :=  m_tabn
    bufpr->kopr  :=  m_kopr
    bufpr->brgd1 :=  m_brgd1
    bufpr->brgd2 :=  m_brgd2
    bufpr->otp   :=  m_otp
    bufpr->dbt   :=  m_dbt
    bufpr->cod1  :=  m_cod1
    bufpr->crt   :=  m_crt
    bufpr->cod2  :=  m_cod2
ENDIF
    bufpr->glv   +=  m_glv
    bufpr->kvo2  +=  m_kvo2
    bufpr->kvo   +=  m_kvo
    bufpr->stm   +=  m_stm
return .t.
STATIC FUNCTION calcPrevMax(m_predel)
LOCAL m_sum1,m_sum0:=0,m_sum2,m_sum3,m_koef
?" Перев. на макс суми"
SELECT buf1
COPY FIELDS tabn,sum TO (m_temppath+"buf1A")
USE (m_temppath+"buf1A") NEW ALIAS buf1A
INDEX ON buf1A->tabn TO (m_temppath+"buf1A")
TOTAL ON buf1A->tabn FIELDS sum TO  (m_temppath+"buf1tabn")
USE (m_temppath+"buf1tabn") NEW ALIAS buf1tabn
INDEX ON buf1tabn->tabn to (m_temppath+"buf1tabn")
SELECT buf1
buf1tabn->(DBGOTOP())
DO WHILE .NOT.buf1tabn->(EOF())
  IF (buf1tabn->sum>m_predel)
    ?" Таб. номер ",buf1tabn->tabn," первищує макс сумму ",buf1tabn->sum
    m_sum1:=buf1tabn->sum-m_predel
    m_sum0+=m_sum1
    m_koef:=m_predel / buf1tabn->sum
    ?" Суму зменшено на ",m_sum1 , " m_koef = ",m_koef
    REPLACE buf1->sum WITH m_koef * buf1->sum FOR buf1->tabn==buf1tabn->tabn
    SUM buf1->sum TO m_sum2  FOR buf1->tabn==buf1tabn->tabn
    m_sum3 :=ROUND(m_predel-m_sum2,2)
    IF  m_sum3<> 0
      LOCATE FOR buf1->tabn==buf1tabn->tabn
      ? " Помiлка окр. ",m_sum3, " RECNO=",recno()
//      buf1->sum+=m_sum3
   ENDIF
  ENDIF
  buf1tabn->(DBSKIP())
ENDDO
?"Завершена m_sum=",m_sum0
CLOSE base buf1A,buf1tabn
return .t.
