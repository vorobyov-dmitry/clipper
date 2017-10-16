#include "new.ch"
MEMVAR m_platpath,m_temppath,m_bufpath,m_syspath,m_tabn,m_level
MEMVAR m_kassapath,a_menu,m_computer,m_sprpath,m_uchpath
Function UdZrpl
  LOCAL m_gauge,m_kopu:="100",m_gauge1,l_first:=.t.
  LOCAL l_nds:=.f.,m_count,n:=1
  LOCAL n_win1,n_error:=0,s_sum:=0
  LOCAL s_stm:=0,s_nds:=0,s_kvo:=0,n_count:=1,n1,GetList:={}
  LOCAL s_kvo1:=0,x01:=0,x02:=0,x03:=0
  LOCAL m_color,s_stm1:=0,m_ddoc1:=CTOD(""),m_ddoc2:=CTOD(""),m_screen
  LOCAL a_tabl:={}
  LOCAL m_nds1,m_recno1,m_maxnds,s_nds1
  IF m_level>3
    DispError("Ви не маєте повноважень на запуск цiєї программи;Звернiться до адмiнiстратора системи")
    RETURN .f.
  ENDIF
  IF ANSWERu("Заносити даннi iз накладних в рахунок зар. плати ?")<>YES
    RETURN .f.
  ENDIF
  m_SCREEN :=savescreen(9,15,16,74)
  DispBox(9,15,14,70,B_SINGLE+" ","w+/bg")
  Shadow(9,15,14,70)
  @ 10,17 sayDisp 'Занести данi по накладних в рахунок зар. платнi' COLOR "n/Bg"
  @ 11,17 sayDisp '           по КО з           по                 '  COLOR "n/Bg"
  m_ddoc1:=BOM(DATE()-10)
  @ 11,36 get m_ddoc1 COLOR "gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
  @ 11,50 get m_ddoc2 COLOR "gr+/N"  VALID m_ddoc2>=m_ddoc1
  SET ESCAPE ON
  read
  restscreen(9,15,16,74,m_screen)
  IF LASTKEY()==K_ESC
      set escape off
      set cursor off
      RETURN .F.
  ENDIF
  m_color:=SETCOLOR("w/b")
  Openfl1()
  InitNds()
  NET USE (m_platpath+"memvar") INDEX (m_platpath+"memvar") NEW ALIAS myvar
  m_kopu:=RestVar1("m_kopu1","NK")
  CLOSE myvar
  SELECT NAkl1
  SET FILTER TO nakl1->vdoc=="1" // Витрата
  Nakl1->(DBGOTOP())
  MyCreate("NAKL01","buf")
  SELECT buf
  INDEX ON buf->NumNakl+buf->kopu TO (m_temppath+"buf")
  m_gauge:=InitGauge("Вибiрка iз бази накладних",1)
  n:=nakl1->(LASTREC())
  IF FILE(m_platpath+"01.txt")
    NET USE (m_platpath+"arh") NEW
    IF arh->(NetDBAP())
      arh->name:="Зан. данних по утр. в рах. зар. платнi "
      arh->text:=MEMOREAD(m_platpath+"01.txt")
    ENDIF
    CLOSE arh
  ENDIF

  SETPRC(0,0)
  SET PRINTER TO (m_platpath+"01.txt")
  SET PRINTER ON
n_win1:=WOPEN(0,0,8,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC("Занесення данних по утриманню сум  накладних в рахунок зар. платнi ",80) COLOR "n/w"
SETPOS(0,0)
?"Занесення данних по утр. в рах. зар. платнi"
?" за перiод з " +My_Dtos(m_ddoc1)+" по  "  +My_Dtos(m_ddoc2)
Wselect(0)
  DO WHILE .NOT.nakl1->(EOF())
    IF .not.IsBit(ASC(nakl1->state),3)  // Получено в счет зарплаты
    IF (nakl1->ddoc >=m_ddoc1.AND.nakl1->ddoc <=m_ddoc2.AND.nakl1->kod1=="З ").OR.;
       (nakl1->ddoc3>=m_ddoc1.AND.nakl1->ddoc3<=m_ddoc2.AND.nakl1->kod1=="З2".AND.IsBit(ASC(nakl1->state),2))

      IF Nakl1->(NetRLock())
        // Отметить как оплаченную
      nakl1->npch1:="  850";nakl1->ddoc1:=nakl1->ddoc;nakl1->sum1:=0
      nakl1->ndoc1:=nakl1->ndoc
      IF nakl1->kod1=="З2"
        s_kvo1++
      ENDIF
      s_kvo++
      nakl2->(DS(nakl1->vnum))
      Spr01->(DS(nakl1->kopr))
      s_stm:=0
      IF spr01->potr<>"5"
        IF EMPTY(nakl1->tabn)
            WSELECT(n_win1)
            ?"Попередження !!! Незаповнений табельний номер в накладнiй N "+nakl1->ndoc
            WSELECT(0)
        ENDIF
        DO WHILE .NOT.nakl2->(EOF()).AND.nakl1->vnum==nakl2->vnum
            Kaptka1->(DS(nakl2->kod))
            buf->(DBAP())
            buf->NumNakl:=nakl1->ndoc
            buf->tabn:=nakl1->tabn
            buf->kod :=nakl2->kod
            buf->ddoc:=nakl1->ddoc
            buf->kvo :=nakl2->kvo
            buf->sum :=nakl2->stm
            buf->sum1 :=kaptka1->prise2*nakl2->kvo
            buf->nds :=nakl2->nds
            buf->sum2:=nakl2->nds+nakl2->stm
            IF buf->nds<>0
              l_nds:=.t.
            ENDIF
//          buf->glv :=nakl2->glv
              IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                buf->glv:=nakl2->glv
              ELSE
                buf->kvo2:=nakl2->glv
              ENDIF
            buf->kopu:=IF(EMPTY(Kaptka1->kopu),m_kopu,Kaptka1->kopu)
            buf->dbt :=kaptka1->ksash2
            buf->crt :=kaptka1->ksash
            buf->kopr:=spr01->kpr
        IF EMPTY(buf->dbt)
          Wselect(n_win1)
          ?"Помилка при обробцi документа N ",nakl1->ndoc," за ",nakl1->ddoc
          ?"     Невизначен код реалiзацiї для ",nakl2->kod
          n_error++
          Wselect(0)
        ENDIF
            buf->mol :=nakl1->otp
            nakl1->sum1+=nakl2->stm+nakl2->nds
            s_stm+=nakl2->stm+nakl2->nds
            s_nds+=nakl2->nds
            s_stm1+=buf->sum1
          nakl2->(DBSKIP())
        ENDDO

      ELSE
        Nakl3->(DS(nakl1->vnum))
   m_nds1:=0
   m_recno1:=Nakl3->(RECNO())
   m_maxnds:=0
   s_nds1:=0
        DO WHILE .NOT.nakl3->(EOF()).AND.nakl1->vnum==nakl3->vnum
            Kaptka1->(DS(nakl2->kod))
            buf->(DBAP())
            buf->NumNakl:=nakl1->ndoc
            buf->tabn:=nakl3->tabn
            buf->kod :=nakl2->kod
            buf->ddoc:=nakl1->ddoc
            buf->kvo :=nakl3->kvo
            m_nds1:=ROUND(nakl2->stm * nakl3->stm /(nakl2->stm + nakl2->nds),2)
            buf->sum :=m_nds1
   IF m_nds1>m_maxnds
    m_maxnds:=m_nds1
    m_recno1:=buf->(RECNO())
  ENDIF
  s_nds1+=buf->sum
            buf->sum1 :=kaptka1->prise2*nakl3->kvo
//            buf->nds :=nakl3->nds
//            buf->sum2:=nakl3->nds+nakl3->stm
//            buf->sum2:=nakl3->stm-ROUND(nakl2->nds * nakl3->kvo /nakl2->kvo,2)
            buf->sum2:=nakl3->stm

//            IF buf->nds<>0
//              l_nds:=.t.
//            ENDIF
//            buf->glv :=nakl3->glv
              IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                buf->glv:=nakl3->glv
              ELSE //Иначе литры
                buf->kvo2:=nakl3->glv
              ENDIF
            buf->kopu:=IF(EMPTY(Kaptka1->kopu),m_kopu,Kaptka1->kopu)
            buf->dbt :=kaptka1->ksash2
            buf->crt :=kaptka1->ksash
            buf->kopr:=spr01->kpr
            buf->mol :=nakl1->otp
            nakl1->sum1+=buf->sum2
//            s_stm+=nakl3->nds+nakl3->stm
            s_stm+=nakl3->stm
            s_stm1+=buf->sum1
//            s_nds+=nakl3->nds
          nakl3->(DBSKIP())
        ENDDO
IF s_nds1<>nakl2->stm
  buf->(DBGOTO(m_recno1))
  buf->sum+=nakl2->stm-s_nds1
ENDIF
        IF EMPTY(buf->dbt)
          Wselect(n_win1)
          ?"Помилка при обробцi документа N ",nakl1->ndoc," за ",nakl1->ddoc
          ?"     Невизначен код реалiзацiї для ",nakl2->kod
          n_error++
          Wselect(0)
        ENDIF
        If Nakl2->nds<>0
          l_nds:=.t.
          buf->(DBAP())
          buf->NumNakl:=nakl1->ndoc
          buf->kod :=nakl2->kod
          buf->ddoc:=nakl1->ddoc
          buf->kvo :=0
          buf->sum :=0
          buf->nds :=nakl2->nds
          buf->sum2:=0
          buf->glv :=0
          buf->kvo2:=0
          buf->kopu:=IF(EMPTY(Kaptka1->kopu),m_kopu,Kaptka1->kopu)
          buf->dbt :=kaptka1->ksash2
          buf->crt :=kaptka1->ksash
          buf->kopr:=spr01->kpr
          buf->mol :=nakl1->otp
          s_nds    +=nakl2->nds
          nakl2->(DBSKIP())
        ENDIF
      ENDIF
      IF ROUND(nakl1->sum1,2)==ROUND(Nakl1->sum,2)
        nakl1->state:=CHR(SETBIT(ASC(nakl1->state),1))
      ELSE
        nakl1->state:=CHR(CLEARBIT(ASC(nakl1->state),1))
        Wselect(n_win1)
        ?"Помилка при обробцi документа N ",nakl1->ndoc," за ",nakl1->ddoc
        ?"     Сума накладної=",nakl1->sum," Cума утримань=",Nakl1->sum1
          n_error++
        Wselect(0)
      ENDIF
       s_sum+=s_stm
        nakl1->(DbUnlock())
  ELSE
    DispError("Неможливо заблокувати накладну "+nakl1->ndoc)
  ENDIF
  ENDIF
  ENDIF
    m_gauge:=DispGauge(m_gauge,n_count++/n)
    nakl1->(DBSKIP())
  ENDDO
  m_gauge:=DispGauge(m_gauge,1)
  buf->(DBGOTOP())
  m_count:=1
  x01:=s_sum;x02:=s_nds
  NET USE (m_sprpath+"sp45") READONLY
  DO WHILE .NOT.sp45->(EOF())
    AADD(a_tabl,{sp45->Scht1,sp45->Scht2,sp45->Scht3})
    sp45->(DBSKIP())
  ENDDO
  CLOSE sp45
  NET USE (m_bufpath+"fd1") NEW
  NET USE (m_bufpath+"fd2") NEW
  OpenFp(m_bufpath)
  NET USE (m_bufpath+"fvnum.dbr") ALIAS fv  NEW
  NET USE (m_sprpath+"sp10") INDEX  (m_sprpath+"sp10")  NEW

  IF (n_error==0.OR.ANSWERu("Знайдено помилок "+STR(n_error,2)+";заносити данi в базу")==YES);
     .AND.MyLOCK()
  DO WHILE .NOT. fd1->(EOF())
    IF fd1->oper=="N1".AND.fd1->ddoc>=m_ddoc1.AND.fd1->ddoc<=m_ddoc2
      IF l_first
        IF ANSWERu("База вже мiстить утримання за продукцiю;Удаляти цi документи?")<>YES
           EXIT
        ENDIF
        l_first:=.f.
      ENDIF
      IF pFilPoz1('fd1', {||(fd1->vnuma==fd2->vnuma)} , 'fd2')
        DO WHILE .NOT. fd2->(EOF()).AND.fd1->vnuma==fd2->vnuma
          fd2->(DBDELETE())
          fd2->(DBSKIP())
        ENDDO
      ENDIF
      fd1->(DBDELETE())
    ENDIF
    fd1->(DBSKIP())
  ENDDO


  DO WHILE .NOT. fp1->(EOF())
    IF fp1->oper=="N1".AND.fp1->ddoc>=m_ddoc1.AND.fp1->ddoc<=m_ddoc2
      IF l_first
        IF ANSWERu("База вже мiстить проводки за отриману продукцiю;Удаляти цi документи?")<>YES
           EXIT
        ENDIF
        l_first:=.f.
      ENDIF
        DO WHILE fp2->(DS(fp1->vnum))
          fp2->(DBDELETE())
        ENDDO
      fp1->(DBDELETE())
    ENDIF
    fp1->(DBSKIP())
  ENDDO
  buf->(DBGOTOP())
  m_gauge1:=InitGauge("Занесення утримань в буферну базу данних",2)
  m_count:=1;n:=2*buf->(LASTREC())
  DO WHILE .NOT. buf->(EOF())
         fd1->(DBAPPEND())
         fd1->npch:=850
         fd1->ndoc:=VAL(buf->NumNakl)
         DO CASE
          CASE buf->glv<>0
             fd1->vdoc:=3
          CASE buf->kvo<>0
             fd1->vdoc:=2
          OTHERWISE
          fd1->vdoc:=1
         ENDCASE
         fd1->kopu:=buf->kopu
         fd1->ddoc:=buf->ddoc
         fd1->vnuma:=fv->vnuma++
         fd1->oper:="N1"
//         fd1->mnt:=mnt_dtod(fd1->ddoc)
         fd1->mnt:=fv->mnt
         DO WHILE buf->kopu==fd1->kopu.AND.fd1->ndoc==VAL(buf->NumNakl).AND..NOT.buf->(EOF())
           fd2->(DBAPPEND())
           fd2->tabn:=buf->tabn
           fd2->kvo:=buf->kvo
           fd2->glv:=buf->glv
           fd2->sum:=buf->sum2
           x03+=fd2->sum
           fd2->vnuma:=fd1->vnuma
           m_gauge1:=DispGauge(m_gauge1,m_count++/n)
           buf->(DBSKIP())
         ENDDO
  ENDDO
  buf->(DBGOTOP())
  DO WHILE .NOT. buf->(EOF())
         fp1->(DBAPPEND())
         fp1->npch:="  850"
         fp1->ndoc:=buf->NumNakl
         fp1->vnum:=STR(fv->vnum++,7)
         fp1->mnt :=mnt_dtod(buf->ddoc)
         fp1->ddoc:=buf->ddoc
         fp1->oper:="N1"
         fp1->maket:="01"
         fp1->prim:="В рахунок зарплати"
        DO WHILE fp1->ndoc==buf->NumNakl.and..not.buf->(eof())
          // Дебет зарплаты - кредит реализации
           IF buf->sum2<>0.OR.buf->kvo<>0.OR.buf->sum2<>0
           fp2->(DBAPPEND())
           fp2->vnum:=fp1->vnum
           fp2->dbt:="6610"+buf->kopu //Зарплата
           fp2->cod1:=buf->tabn
           fp2->crt:=GetSchet70(buf->dbt,a_tabl)
           fp2->cod2:=buf->kod
           fp2->kopr:=buf->kopr
           fp2->otp :=buf->mol
           fp2->glv:=buf->glv
           fp2->kvo2:=buf->kvo2
           fp2->kvo:=buf->kvo
           fp2->stm:=buf->sum2 //полная стоимость
           x01-=fp2->stm
          // Кредит реализации - дебет фин. результата
           fp2->(DBAPPEND())
           fp2->vnum:=fp1->vnum
           fp2->dbt:=GetSchet70(buf->dbt,a_tabl) //Доход
           fp2->cod1:=buf->kod
           fp2->crt:=GetSchet79(buf->dbt,a_tabl) // фин результат
           fp2->cod2:=buf->kod
           fp2->kopr:=buf->kopr
           fp2->glv:=buf->glv
           fp2->kvo2:=buf->kvo2
           fp2->kvo:=buf->kvo
           fp2->stm:=buf->sum //чистая стоимость
           ENDIF
          //НДС
          IF buf->nds<>0
           fp2->(DBAPPEND())
           fp2->vnum:=fp1->vnum
           fp2->dbt:=GetSchet70(buf->dbt,a_tabl)  //Доход
           fp2->cod1:=buf->kod
           fp2->crt:=GetNdsksash(fp2->dbt) // НДС
           fp2->cod2:=buf->kod
           fp2->kopr:=buf->kopr
           fp2->glv:=buf->glv
           fp2->kvo2:=buf->kvo2
           fp2->kvo:=buf->kvo
           fp2->stm:=buf->nds //чистая стоимость
           x02-=fp2->stm
           ENDIF
           m_count++
           buf->(DBSKIP())
        ENDDO
        m_gauge1:=DispGauge(m_gauge1,m_count/n)
  ENDDO
  DelGauge(m_gauge1)
WSELECT(n_win1)
?" Реалiзацiя (кредит рахунку) -Дебет 6610   "+SumToStr(s_sum)
?" Занесено в зарплату                       "+SumToStr(x03)
?" ПДВ                                       "+SumToStr(s_nds)
?"   Помилки округл.                         "+SumToStr(x01)
?"   Помилки округл.                         "+SumToStr(x02)
?" Кiлькiсть накладних "+LTRIM(str(s_kvo))
?"   з них кiлькiсть по нат. премiї "+LTRIM(str(s_kvo1))
?" Занесення данних зроблено "+my_dtos(DATE())
?"                  виконав "+ALLTRIM(_Fio(m_tabn))
DBUNLOCKALL()
  ELSE
WSELECT(n_win1)
?" Реалiзацiя (кредит рахунку) -Дебет 6610 "+SumToStr(s_sum)
?" ПДВ                                       "+SumToStr(s_nds)
?" Кiлькiсть накладних "+LTRIM(str(s_kvo))
?"   з них кiлькiсть по нат. премiї "+LTRIM(str(s_kvo1))
?" Занесення данних не зроблено "+my_dtos(DATE())
?"                  не виконав "+ALLTRIM(_Fio(m_tabn))
DispError("Даннi про утримання в базу данних не занесенi")
  ENDIF
INKEY(5)
 Wclose(n_win1)
 CLOSE sp10
SET PRINTER OFF
SET PRINTER TO
  WSELECT(0)
  DelGauge(m_gauge)
  DBUNLOCKALL()
  SELECT NAkl1
  SET FILTER TO
  CLOSE BASE buf,FD1,FD2,fv,fp2,fp1
  CloseFl1()
//  FERASE(m_temppath+"buf")
  SETCOLOR(m_color)
  DBCOMMITALL()
RETURN .t.
Function MyCreate(var,m_alias,s1)
  LOCAL a_struct:={},m_path:=IF(s1==NIL,m_temppath,s1)
  SavePar()
  USE  (m_syspath+"Struct") INDEX (m_syspath+"Struct") NEW READONLY
  struct->(DS(var))
  DO WHILE .NOT.struct->(EOF()).AND.var==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
  DBCREATE(m_path+m_alias,a_struct)
  USE (m_path+m_alias ) NEW
  CLOSE struct
  SavePar(1)
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
STATIC Function MyLock()
LOCAL i:=1,m_var:=.f.
LOCAL l_fd1,l_fd2,l_funnum,l_fdbcr,l_fkvo2,l_fglv,l_fv
l_fd1:=l_fd2:=l_funnum:=l_fdbcr:=l_fkvo2:=l_fglv:=l_fv:=.f.

DO WHILE .NOT.(l_fd1.AND.l_fd2.AND.l_funnum.AND.l_fdbcr.AND.l_fv)
  IF .NOT.l_fd1
    IF fd1->(FLOCK())
      l_fd1:=.t.
    ELSE
      IF ALERT("Файл fd1 (Кассова вiдомicть);неможливо заблокувати !",{"Завершити","Продовжити"},"n/bg,w/b")==2
        LOOP
      ELSE
        RETURN .f.
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.l_fd2
    IF fd2->(FLOCK())
      l_fd2:=.t.
    ELSE
      IF ALERT("Файл fd2 (Кассова вiдомicть);неможливо заблокувати !",{"Завершити","Продовжити"},"n/bg,w/b")==2
        LOOP
      ELSE
        RETURN .f.
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.l_fUNNUM
    IF Fp1->(FLOCK())
      l_funnum:=.t.
    ELSE
      IF ALERT("Файл fp1 (Бухгалтерська справка);неможливо заблокувати !",{"Завершити","Продовжити"},"n/bg,w/b")==2
        LOOP
      ELSE
        RETURN .f.
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.l_fdbcr
    IF fp2->(FLOCK())
      l_fdbcr:=.t.
    ELSE
      IF ALERT("Файл fp2 (Бухгалтерська справка);неможливо заблокувати !",{"Завершити","Продовжити"},"n/bg,w/b")==2
        LOOP
      ELSE
        RETURN .f.
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.l_fv
    IF fv->(FLOCK())
      l_fv:=.t.
    ELSE
      IF ALERT("Файл fvnum (Службовий);неможливо заблокувати !",{"Завершити","Продовжити"},"n/bg,w/b")==2
        LOOP
      ELSE
        RETURN .f.
      ENDIF
    ENDIF
  ENDIF
ENDDO
RETURN .t.
STATIC FUNCTION MyLock1
LOCAL i:=1,m_var:=.f.
LOCAL l_funnum,l_fdbcr,l_fv
l_funnum:=l_fdbcr:=l_fv:=.f.

DO WHILE .NOT.(l_funnum.AND.l_fdbcr.AND.l_fv)
  IF .NOT.l_fUNNUM
    IF Fp1->(FLOCK())
      l_funnum:=.t.
    ELSE
      IF ALERT("Файл fp1 (Бухгалтерська справка);неможливо заблокувати !",{"Завершити","Продовжити"},"n/bg,w/b")==2
        LOOP
      ELSE
        RETURN .f.
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.l_fdbcr
    IF fp2->(FLOCK())
      l_fdbcr:=.t.
    ELSE
      IF ALERT("Файл fp2 (Бухгалтерська справка);неможливо заблокувати !",{"Завершити","Продовжити"},"n/bg,w/b")==2
        LOOP
      ELSE
        RETURN .f.
      ENDIF
    ENDIF
  ENDIF
  IF .NOT.l_fv
    IF fv->(FLOCK())
      l_fv:=.t.
    ELSE
      IF ALERT("Файл fvnum (Службовий);неможливо заблокувати !",{"Завершити","Продовжити"},"n/bg,w/b")==2
        LOOP
      ELSE
        RETURN .f.
      ENDIF
    ENDIF
  ENDIF
ENDDO
RETURN .T.
#command DISPERROR(<var3>,<var4>,<var1>,<var2>) => n_error++  ;;
        WSELECT(n_win1);;
        QOUT("Помилка ! КО ордер N "+STR(<var3>,5)+" за "+DTOC(<var4>));;
        QOUT(SPACE(5)) ;;
        QQOUT(<var1>) ;;
        QOUT(SPACE(5)) ;;
        QQOUT(<var2>);n_error++;;
        WSELECT(0);l_error:=.t.

#command DISPWARNING(<var3>,<var4>,<var1>,<var2>) =>  n_warning++ ;;
        WSELECT(n_win1);;
        QOUT("Попередження ! КО N "+STR(<var3>,5)+" за "+DTOC(<var4>)) ;;
        QOUT(SPACE(5)) ;;
        QQOUT(<var1>) ;;
        QOUT(SPACE(5)) ;;
        QQOUT(<var2>);n_warning++;;
        WSELECT(0)

Function kassa02
  LOCAL m_screen,m_ddoc1,m_ddoc2,m_file,m_sum1:=0,m_sum2:=0,m_sum2a:=0,m_sum1a:=0
  LOCAL i,j,k,n_warning:=0,n_error:=0,GetList:={},n_win1,m_color
  LOCAL a_nakl1:={},a_nakl2:={},m_ndoc,m_gauge,l_error:=.f.
  LOCAL s_files:={}
  IF m_level>3
    DispError("Ви не маєте повноважень на запуск цiєї программи;Звернiться до адмiнiстратора системи")
    RETURN .f.
  ENDIF
  IF ANSWERu("Заносити оплату накладних за готiвку ?")<>YES
    RETURN .f.
  ENDIF
  SopenFiles("100",@s_files)
  OpenFl1()
  SELECT NAkl1
  SET FILTER TO nakl1->vdoc=="1" // Витрата
  nakl1->(DBSETORDER(2))
  NET USE (m_kassapath+"fks08") NEW READONLY
  m_SCREEN :=savescreen(1,19,08,64)
  DispBox(1,19,06,62,B_SINGLE+" ","w+/bg")
  Shadow(1,19,06,62)
  m_ddoc1:=BOM(DATE()-10)
  @ 02,20 sayDisp 'Провести вiдмiтку оплати накладних ' COLOR "n/Bg"
  @ 03,20 sayDisp 'за готiвку по КО з          по      '  COLOR "n/Bg"
  @ 03,39 get m_ddoc1 COLOR "gr+/N"  VALID (SetDdoc2(m_ddoc1,@m_ddoc2))
  @ 03,51 get m_ddoc2 COLOR "gr+/N"  VALID m_ddoc2>=m_ddoc1
  SET ESCAPE ON
  read
  IF LASTKEY()==K_ESC
      set escape off
      set cursor off
      restscreen(1,19,08,64,m_screen)
      ScloseFile(s_files)
      CloseFl1()
      RETURN .F.
  ENDIF
  fks08->(DBGOTOP())
  m_gauge:=InitGauge("Вибiрка iз бази касових ордерiв",1)
  m_color:=SETCOLOR("w/b")
  n_win1:=WOPEN(0,0,8,80,.t.)
  Wselect(n_win1)
  WBOX(12)
  @-1,0 SayDisp PADC("Занесення данних по оплатi накладних за готiвку",80) COLOR "n/w"
  IF FILE(m_platpath+"02.txt")
    NET USE (m_platpath+"arh") NEW
    IF arh->(NetDBAP())
      arh->name:="ЗВIТ ПРО ВIДМ. ОПЛАТИ ЗА ГОТIВКУ "
      arh->text:=MEMOREAD(m_platpath+"02.txt")
    ENDIF
    CLOSE arh
  ENDIF
  SETPOS(0,0)
  SET PRINTER TO (m_platpath+"02.txt")
  SET PRINTER ON
  ?"ЗВIТ ПРО ВIДМIТКУ ОПЛАТИ ЗА ГОТIВКУ НАКЛАДНИХ"
  ?"    за перiод з "+my_dtos(m_ddoc1)+" по "+my_dtos(m_ddoc2)
  DO WHILE .not.fks08->(EOF())
//    IF LEFT(fks08->ksash,2)=="70".AND.fks08->ndoc1<>0.AND.fks08->ddoc<=m_ddoc2.AND.fks08->ddoc>=m_ddoc1
    IF LEFT(fks08->ksash,2)=="70".AND.fks08->ddoc<=m_ddoc2.AND.fks08->ddoc>=m_ddoc1
      a_nakl1:={fks08->ndoc,0,0,{},fks08->ddoc,IF(fks08->kpr<"100","0","1")}
      i:=fks08->ndoc;m_ndoc:=fks08->ndoc1
      DO WHILE .NOT.fks08->(EOF()).AND.fks08->ndoc1==m_ndoc.AND.i==fks08->ndoc
        a_nakl1[2]:=a_nakl1[2]+fks08->sum
        a_nakl1[3]:=a_nakl1[3]+fks08->nds
        AADD(a_nakl1[4],{fks08->ksash,fks08->sum,fks08->nds,fks08->kvo ,fks08->glv})
        fks08->(DBSKIP())
      ENDDO
      IF(a_nakl1[6]=="0",m_sum1+=a_nakl1[2],m_sum1a+=a_nakl1[2])
      IF nakl1->(DS(STR(m_ndoc,6))).AND..not.IsBit(ASC(nakl1->state),3)
        a_nakl2:={nakl1->ndoc,0,0,{},nakl1->ddoc}
        nakl2->(DS(nakl1->vnum))
        m_ndoc:=nakl1->vnum
        DO WHILE .NOT.nakl2->(EOF()).AND.nakl2->vnum==m_ndoc
          kaptka1->(DS(nakl2->kod))
          a_nakl2[2]:=a_nakl2[2]+nakl2->stm+nakl2->nds
          a_nakl2[3]:=a_nakl2[3]+nakl2->nds
          kaptka1->(DS(nakl2->kod))
          AADD(a_nakl1[4],{kaptka1->ksash2,nakl2->stm,nakl2->nds,nakl2->kvo ,nakl2->glv})
          nakl2->(DBSKIP())
        ENDDO
        l_error:=.f.
        IF a_nakl1[6]=="1" // Возврат за неполученную продукцию
          IF .NOT.ISBIT(ASC(nakl1->state),1)
            DispError(i,a_nakl1[5],;
          "Накл. N "+LTRIM(a_nakl2[1])+" за "+DTOC(a_nakl2[5]),"не вiдмiчена як оплачена")
          ENDIF
          IF ISBIT(ASC(nakl1->state),2)
            DispError(i,a_nakl1[5],;
          "Накл. N "+LTRIM(a_nakl2[1])+" за "+DTOC(a_nakl2[5]),"- продукцiя вiдпущена")
          ENDIF
        ENDIF
        IF a_nakl1[5]<a_nakl2[5]
          DispWarning(i,a_nakl1[5],;
          "Дата накладної N "+LTRIM(a_nakl2[1])+" за "+DTOC(a_nakl2[5]),"пiзнiша КО")
        ENDIF
        IF ROUND(a_nakl1[2],2)<>ROUND(a_nakl2[2],2)
          DispError(i,a_nakl1[5],;
          "Сума накладної N "+LTRIM(a_nakl2[1])+"("+ALLTRIM(STR(a_nakl2[2],10,2))+")"+" за "+DTOC(a_nakl2[5])+" не спiвпадає с сумою КО ["+ALLTRIM(STR(a_nakl1[2],10,2))+"]","")
        ELSE
          IF ROUND(a_nakl1[3],2)<>ROUND(a_nakl2[3],2)
            DispError(i,a_nakl1[5],;
            "ПДВ  накладної N "+LTRIM(a_nakl2[1])+"("+ALLTRIM(STR(a_nakl2[3],10,2))+")"+" за "+DTOC(a_nakl2[5])+" не спiвпадає з ПДВ  КО["+ALLTRIM(STR(a_nakl1[3],10,2))+"]","")
          ENDIF
        ENDIF
         IF .NOT.l_error
          IF nakl1->(NetRlock())
            IF a_nakl1[6]=="1" // Возврат за неполученную продукцию
              nakl1->state:=CHR(CLEARBIT(ASC(nakl1->state),1))
              m_sum2a+=a_nakl2[2]
              nakl1->npch1:="  801";nakl1->ddoc1:=a_nakl1[5];nakl1->sum1:=0
              nakl1->ndoc1:=STR(a_nakl1[1],6);nakl1->kod1:="Г "
            ELSE
              nakl1->state:=CHR(SETBIT(ASC(nakl1->state),1))
              m_sum2+=a_nakl2[2]
              nakl1->npch1:="  801";nakl1->ddoc1:=a_nakl1[5];nakl1->sum1:=a_nakl2[2]
              nakl1->ndoc1:=STR(a_nakl1[1],6);nakl1->kod1:="Г1"
            ENDIF
            nakl1->(DbUnlock())
          ELSE
            DispError("Неможливо заблокувати накладну")
          ENDIF
        ENDIF
      ELSE
        DispError(a_nakl1[1],a_nakl1[5],"вiдсутня накладна N "+ALLTRIM(STR(m_ndoc,6))+" сума ["+ALLTRIM(STR(a_nakl1[2],10,2))+"]","")
      ENDIF
   ELSE
    fks08->(DBSKIP())
   ENDIF
    WSELECT(0)
    m_gauge:=DispGauge(m_gauge,fks08->(RECNO())/Fks08->(LASTREC()))
  ENDDO
  CLOSE Fks08
  DelGauge(m_gauge)
WSELECT(n_win1)
?"Загальна сума касових ордерiв:"
?" Реалiзацiя "+SumToStr(m_sum1,14)+" Повернення :"+SumToStr(m_sum1a,14)
?"Загальна сума накладних      :"
?" Реалiзацiя "+SumToStr(m_sum2,14)+" Повернення :"+SumToStr(m_sum2a,14)
?" Занесення зроблено "+my_dtos(DATE())
?"           виконав "+ALLTRIM(_Fio(m_tabn))
WSELECT(0)
SET PRINTER OFF
SET DEVICE TO SCREEN
INKEY(5)
 Wclose(n_win1)
SET PRINTER OFF
  WSELECT(0)
  DelGauge(m_gauge)
  DBUNLOCKALL()
  SELECT NAkl1
  nakl1->(DBSETORDER(1))
  SET FILTER TO
  SETCOLOR(m_color)
  DBCOMMITALL()
    ScloseFile(s_files)
  CloseFl1()
RETURN .t.
Function MyMonth(n)
  LOCAL a_month:={;
"сiчень",;
"лютий",;
"березень",;
"квiтень",;
"травень",;
"червень",;
"липень",;
"серпень",;
"вересень",;
"жовтень",;
"листопад",;
"грудень"}
IF n>=1.AND.n<=12
  RETURN a_month[n]
ENDIF
RETURN ""
Function SetDdoc2(m_ddoc1,m_ddoc2)
  IF .NOT.EMPTY(m_ddoc1)
    m_ddoc2:=EOM(m_ddoc1)
  ENDIF
RETURN .t.
Function ViewOtch(var)
  LOCAL m_color,n_win1
  IF .NOT.FILE(m_platpath+var+'.txt')
    DispError("Данний звiт вiдсутнiй")
    RETURN .f.
  ENDIF
  m_color:=SETCOLOR("w/b")
n_win1:=WOPEN(4,0,20,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC(" Перегляд звiта",80) COLOR "n/w"
MEMOEDIT(MEMOREAD(m_platpath+var+'.txt'),0,0,MAXROW(),MAXCOL(),.f.,"f001",254)
WCLOSE(n_win1)
WSELECT(0)
SETCOLOR(m_color)
RETURN .t.
Function f001(var1,var2,var3)
  LOCAL m_file:=m_platpath+a_menu[LEN(a_menu)]+".txt"
  IF var1==1.OR.var1==2
    IF LASTKEY()==K_F2
      IF ALERT("Друкувати звiт ?",{"Да","Нi"},"n/bg,w/b")==1
        IF SPOOLACTIV().AND.SPOOLCOUNT()<6
          SPOOLADD(m_file)
        ELSE
          PRINTFILE(m_file,.t.)
        ENDIF
      ENDIF
    ENDIF
  ENDIF
RETURN 0
Function Ms03(vid)
  LOCAL m_color,m_ddoc1:=CTOD(""),m_ddoc2:=CTOD(""),m_screen
  LOCAL m_gauge,s_str,n_kod,i,n_kvo2,n_kvo,m_recno:=1
  LOCAL m_mol:="  ",m_page:=0,m_fio,n,GetList:={},a_shapka:={},m_name
  IF ANSWERu("Формувати звiт по комiрниковi;по накладних?")<>YES
    RETURN .f.
  ENDIF
  m_SCREEN :=savescreen(9,15,16,74)
  DispBox(9,15,14,70,B_SINGLE+" ","w+/bg")
  Shadow(9,15,14,70)
  @ 10,17 sayDisp '     Формувати звiт по виписаних накладних      ' COLOR "n/Bg"
  @ 11,17 sayDisp '                 з           по                 '  COLOR "n/Bg"
  @ 12,17 sayDisp 'по комiрнику                                    '  COLOR "n/Bg"
  m_ddoc1:=BOM(DATE()-10)
  @ 11,36 get m_ddoc1 COLOR "gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
  @ 11,50 get m_ddoc2 COLOR "gr+/N"  VALID m_ddoc2>=m_ddoc1
  @ 12,30 Get m_mol COLOR "GR+/N" VALID Sp02->(Sp_vl("SP02",,12,34,"_mol(Sp02->mol)","GR+/bg"))
  m_fio:=_mol(m_mol)
  SET ESCAPE ON
  read
  IF LASTKEY()==K_ESC
      set escape off
      set cursor off
      RETURN .F.
  ENDIF
  m_fio:=_mol(m_mol)
  m_color:=SETCOLOR("w/b")
  m_gauge:=InitGauge("Вибiрка iз бази накладних",2)
  OpenFl1()
  SELECT NAkl1
  SET FILTER TO nakl1->vdoc==vid // Витрата
  Nakl1->(DBGOTOP())
  SETPRC(0,0)
  OpenPrn(m_platpath+"03.txt")
  Screen->(DS("SHP003"))
  n:=MLCOUNT(screen->vd,254)
  FOR i:=2 TO n
    AADD(a_shapka,ALLTRIM(MEMOLINE(screen->vd,254,i)))
  NEXT
  m_name:=ALLTRIM(MEMOLINE(screen->vd,254,1))+IF(vid=="0","(приход)","(витрата )")+" "+m_mol+" "+m_fio
  n_Kod:=ATNUM("┴",a_shapka[n-1],2)
  n_kvo:=ATNUM("┴",a_shapka[n-1],3)
  n_kvo2:=ATNUM("┴",a_shapka[n-1],4)
  s_str:=REPLICATE("-",LEN(a_shapka[n-1]))
  SetWidthPrn(LEN(a_shapka[n-1]))
  a_shapka:=SetShapka(a_shapka)
  n:=Nakl1->(LASTREC())
  DO WHILE .NOT.nakl1->(EOF())
    IF nakl1->ddoc>=m_ddoc1.AND.nakl1->ddoc<=m_ddoc2.AND.nakl1->otp==m_mol.AND..not.IsBit(ASC(nakl1->state),3)
      nakl2->(DS(nakl1->vnum))
      DO WHILE .NOT.nakl2->(EOF()).AND.nakl1->vnum==nakl2->vnum
        IF INKEY()==K_ESC
          IF ANSWERu("Завершити программу?")==YES
            restscreen(9,15,16,74,m_screen)
            DelGauge(m_gauge)
            SELECT NAkl1
            SET FILTER TO
            SET PRINTER TO
            SET DEVICE TO SCREEN
            RETURN .f.
          ENDIF
        ENDIF
        SkipLinePrn(a_shapka,m_name)
        @PROW(),1 Say nakl1->ndoc
        kaptka1->(DS(nakl2->kod))
        @PROW(),n_kod Say LEFT(Kaptka1->name,33)
        @PROW(),n_kvo Say SumToStr(Nakl2->kvo,)
        @PROW(),n_kvo2 Say Nakl2->glv PICTURE "@z 999999.99"
        @PROW()+1,0 Say s_str
        nakl2->(DBSKIP())
      ENDDO
    ENDIF
    m_gauge:=DispGauge(m_gauge,m_recno++/n)
    nakl1->(DBSKIP())
  ENDDO
  n:=(GetEndPage()-PROW()-6)/2
  FOR i:=1 TO n
    @PROW()+2,0 SAY s_str
  NEXT
  @PROW()+2,0 Say "Звiт прийняв ___________________ "
  m_gauge:=DelGauge(m_gauge)
  restscreen(9,15,16,74,m_screen)
  SELECT NAkl1
  SET FILTER TO
  ClosePrn()
  IF SPOOLACTIV().AND.SPOOLCOUNT()<6
    SPOOLADD(m_platpath+"03.txt")
  ELSE
    FileToPrn(m_platpath+"03.txt")
  ENDIF
  CloseFl1()
RETURN .t.
Function FormMs04
  LOCAL i:=1,a_kod:={},n:=Nakl1->(LASTREC())
  LOCAL m_gauge,m_ddoc1:=CTOD(""),m_ddoc2:=CTOD(""),m_screen
  LOCAL a_struct:={{"tabn","C",4,0}},GetList:={},j
/*  IF ANSWERu("Формувати звiт по лiмiтованiй продукцiї")<>YES
    RETURN .f.
  ENDIF */
  m_SCREEN :=savescreen(9,15,16,74)
  DispBox(9,15,14,70,B_SINGLE+" ","w+/bg")
  Shadow(9,15,14,70)
  @ 10,17 sayDisp 'Вибрати данi по накладних лiмiтованої продукцiї' COLOR "n/Bg"
  @ 11,17 sayDisp 'по працiвникам   з           по                 '  COLOR "n/Bg"
  m_ddoc1:=BOM(DATE()-10)
  @ 11,36 get m_ddoc1 COLOR "gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
  @ 11,50 get m_ddoc2 COLOR "gr+/N"  VALID m_ddoc2>=m_ddoc1
  SET ESCAPE ON
  read
  restscreen(9,15,16,74,m_screen)
  IF LASTKEY()==K_ESC
      set escape off
      set cursor off
      RETURN .F.
  ENDIF
  USE (m_platpath+"Nakl4")
  IF NetErr()
    DispError("З файлом лiмiтованої продукцiї ;працює iнший користувач;перерахунок неможливий")
    RETURN .f.
  ENDIF
  NET USE (m_platpath+"Spr02") INDEX (m_platpath+"Spr02") NEW
  i:=1
  DO WHILE .NOT.Spr02->(EOF())
    AADD(a_struct,{"X"+STRZERO(i,3),"N",14,2})
    Spr02->(DBSKIP())
  ENDDO
  CLOSE Spr02
  CLOSE Nakl4
  DBCREATE(m_platpath+"Nakl4",a_struct)
  USE (m_platpath+"Nakl4") NEW
  INDEX ON Nakl4->tabn TO (m_platpath+"Nakl4")
  Nakl1->(DBSETORDER(0))
  Nakl1->(DBGOTOP())
  m_gauge:=InitGauge("Перегляд бази накладних")
  DO WHILe .NOT.Nakl1->(EOF())
    IF Nakl1->vdoc=="1".AND..NOT.IsBit(nakl1->state,3).AND.NumPotr(Nakl1->kopr)=="0"
      nakl2->(DS(nakl1->vnum))
      DO WHILE .NOT.nakl2->(EOF()).AND.nakl1->vnum==nakl2->vnum
          IF (j:=ASCAN(a_kod,{|x|(x[1]==nakl2->kod)}))<>0
            Nakl4->(DS(Nakl1->tabn))
            IF .NOT.Nakl4->(FOUND())
              Nakl4->(DBAPPEND())
              Nakl4->tabn:=Nakl1->tabn
            ENDIF
            Nakl4->(FIELDPUT(j+1,Nakl2->kvo+FIELDGET(j+1)))
          ENDIF
        nakl2->(DBSKIP())
      ENDDO
    ENDIF
    nakl1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,i++/n)
  ENDDO
  DelGauge(m_gauge)
  Nakl1->(DBSETORDER(1))
  CLOSE Nakl4
  // зберегти m_ddoc1 i m_ddoc2
  NET USE (m_platpath+"memvar") INDEX (m_platpath+"memvar") NEW ALIAS myvar
  SaveVar1("m_ddoc1",m_ddoc1,"N3")
  SaveVar1("m_ddoc2",m_ddoc2,"N3")
  FOR i:=1 TO LEN(a_kod)
    SaveVar1("X"+STRZERO(i,3),a_kod[i],"N3")
  NEXT
  CLOSE myvar
RETURN .t.
Function FormNal1()
  LOCAL m_ndoc,m_vnum,m_rec2,m_sum:=0,m_nds:=0,i,m_rec1
  LOCAL m_gauge,n,m_count:=1,m_screen,m_ddoc1,m_ddoc2,GetList:={},m_color,n_win1
  LOCAL s_kvo:=0,l1:=.f.,l2:=.f.,m_sum1:=0,m_nds1:=0,s_ndoc:="",s_ndoc1:="",l3
  LOCAL s_ndoc3:="",n_error:=0
   NET USE (m_platpath+"FVNUM") NEW
  fvnum->(DBGOTO(2))
  IF fvnum->(NetRlock())
    fvnum->reg:=SETBIT(fvnum->reg,m_computer)
    m_vnum:=fvnum->vnum
    fvnum->vnum:=fvnum->vnum+2
  ELSE
    DispError("Вiдмовлено в доступi")
    RETURN .f.
  ENDIF
  IF m_level>3
    DispError("Ви не маєте повноважень на запуск цiєї программи;Звернiться до адмiнiстратора системи")
    RETURN .f.
  ENDIF
  SAVEPAR()
  m_SCREEN :=savescreen(9,15,16,74)
  DispBox(9,15,14,70,B_SINGLE+" ","w+/bg")
  Shadow(9,15,14,70)
  @ 10,17 sayDisp 'Формувати податкову накладну в рахунок зар. платнi' COLOR "n/Bg"
  @ 11,17 sayDisp 'по накладних     з           по                 '  COLOR "n/Bg"
  m_ddoc1:=BOM(DATE()-10)
  @ 11,36 get m_ddoc1 COLOR "gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
  @ 11,50 get m_ddoc2 COLOR "gr+/N"  VALID m_ddoc2>=m_ddoc1
  SET ESCAPE ON
  read
  restscreen(9,15,16,74,m_screen)
  IF LASTKEY()==K_ESC
      set escape off
      set cursor off
      RETURN .F.
  ENDIF
  m_color:=SETCOLOR("w/b")
  OPenFl1()
  SELECT NAkl1
//  SET FILTER TO nakl1->vdoc=="1" // Витрата
  Nakl1->(DBGOTOP())
  n:=nakl1->(LASTREC())
  m_gauge:=InitGauge("Вибiрка iз бази накладних",1)
  IF FILE(m_platpath+"04.txt")
    NET USE (m_platpath+"arh") NEW
    IF arh->(NetDBAP())
      arh->name:="Формування под. накл. в рахунок зар. платнi "
      arh->text:=MEMOREAD(m_platpath+"04.txt")
    ENDIF
    CLOSE arh
  ENDIF
  SETPRC(0,0)
  SET PRINTER TO (m_platpath+"04.txt")
  SET PRINTER ON
  n_win1:=WOPEN(0,0,8,80,.t.)
  Wselect(n_win1)
  WBOX(12)
  @-1,0 SayDisp PADC("Формування податкової накладної по накладних в рахунок зар. платнi ",80) COLOR "n/w"
  SETPOS(0,0)
  ?"Формування податкової накладної по накладних в рахунок зар. платнi "
  ?" за перiод з " +My_Dtos(m_ddoc1)+" по  "  +My_Dtos(m_ddoc2)
  Wselect(0)
    m_sum:=0;m_nds:=0
    m_sum1:=0;m_nds1:=0
    DO WHILE .NOT.nakl1->(EOF())
      IF nakl1->ddoc1>=m_ddoc1.AND.nakl1->ddoc1<=m_ddoc2.AND.;
        nakl1->kod1=="З ".AND..not.IsBit(ASC(nakl1->state),3).AND.;
        IsBit(ASC(nakl1->state),1).AND.nakl1->vdoc=="1" // Получено в счет зарплаты i оплачено
        IF Nakl1->(NetRLock())
          nakl2->(DBSEEK(nakl1->vnum))
          s_kvo++
          DO WHILE nakl2->VNUM==nakl1->vnum.AND..NOT.nakl2->(EOF())
              IF nalog2->(NetDbAp())
                nalog2->NumNakl:=nakl1->ndoc
                nalog2->ddoc := nakl1->ddoc
                nalog2->kod  := nakl2->kod
                Kaptka1->(DS(nakl2->kod))
                nalog2->name := kaptka1->name
                nalog2->izm  := Kaptka1->izm
                nalog2->kvo  := nakl2->kvo
                nalog2->prise:= nakl2->prise
                IF  nakl2->nds<>0
                  nalog2->vnum := STR(m_vnum,6)
                  l1:=.t.
                  nalog2->sum1 :=nakl2->stm
                  nalog2->nds  := nakl2->nds
                  nalog2->stm  := nalog2->sum1 + nalog2->nds
                  m_sum+=nakl2->stm;m_nds+=nakl2->nds
                  l3:=.t.
                ELSE
                  l2:=.t.
                  l3:=.f.
                  nalog2->vnum := STR(m_vnum+1,6)
                  nalog2->sum4 :=nakl2->stm
                  nalog2->stm  := nalog2->sum4
                  m_sum1+=nakl2->stm;m_nds1+=nakl2->nds
                ENDIF
              ELSE
                DispError("Неможливо добавити строку в податкову накладну")
              ENDIF
              nalog2->(dbUnlock())
              nakl2->(Dbskip())
          ENDDO
          nakl1->ndoc2:=IF(l3,STR(fvnum->ndoc,LEN(nalog1->ndoc)),STR(fvnum->ndoc+1,LEN(nalog1->ndoc)))
          nakl1->ddoc2:=Date()
          s_ndoc1+=ALLTRIM(nakl1->ndoc)+","
          IF Nakl1->sum1<>Nakl1->sum
            s_ndoc3+=ALLTRIM(nakl1->ndoc)+","
          ENDIF
          nakl1->(DbUnlock())
        ENDIF
      ENDIF
      m_gauge:=DispGauge(m_gauge,m_count++/n)
      nakl1->(DBSKIP())
    ENDDO
  IF l1
    IF nalog1->(NetDbAp())
      nalog1->vnum:=STR(m_vnum,6)
      nalog1->ndoc:=STR(fvnum->ndoc,LEN(nalog1->ndoc))
      fvnum->ndoc:=fvnum->ndoc+1
      nalog1->ddoc:=DATE()
      s_ndoc+=ALLTRIM(nalog1->ndoc)
      SetPred01()
      Nalog1->vdoc:="1"
      nalog1->nds:=m_nds
      nalog1->sum:=m_sum
      nalog1->(dbUnlock())
    ELSE
          DispError("Неможливо добавити заголовок в податкову накладну")
    ENDIF
  ENDIF
  IF l2
    IF nalog1->(NetDbAp())
      nalog1->vnum:=STR(m_vnum+1,6)
      nalog1->ndoc:=STR(fvnum->ndoc,LEN(nalog1->ndoc))
      fvnum->ndoc:=fvnum->ndoc+1
      s_ndoc+=","+ALLTRIM(nalog1->ndoc)
      nalog1->ddoc:=DATE()
      SetPred01()
      Nalog1->vdoc:="1"
      nalog1->nds:=m_nds1
      nalog1->sum:=m_sum1
      nalog1->(dbUnlock())
    ELSE
          DispError("Неможливо добавити заголовок в податкову накладну")
    ENDIF
  ENDIF
  IF fvnum->(NetRlock())
//    fvnum->name:=BLANK(fvnum->name,.t.)
    fvnum->reg:=CLEARBIT(fvnum->reg,m_computer)
    fvnum->(DBCOMMIT())
    fvnum->(DbUnlock())
  ELSE
    DispError("Вiдмовлено в доступi")
  ENDIF
Wselect(n_win1)
?" Реалiзацiя (кредит 70 рахунку) -Дебет 70  "+SumToStr(m_sum+m_nds+m_sum1+m_nds1)
?"             ПДВ                           "+SumToStr(m_nds+m_nds1)
?" Кiлькiсть накладних "+LTRIM(str(s_kvo))
s_ndoc1:=LEFT(s_ndoc1,LEN(s_ndoc1)-1)
DO WHILE .NOT.EMPTY(s_ndoc1)
  i:=IF(LEN(s_ndoc1)>60,RAT(",",LEFT(s_ndoc1,60)),LEN(s_ndoc1))
  IF i==0
    i:=60
  ENDIF
  ?LEFT(s_ndoc1,i)
  s_ndoc1:=SUBSTR(s_ndoc1,i+1)
ENDDO
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") NEW
?" Занесення данних зроблено "+my_dtos(DATE())
?"                  виконав "+ALLTRIM(_Fio(m_tabn))
IF .NOT.EMPTY(s_ndoc3)
  ?"Увага !!! Рiзнi суми оплати i накладної по "+LEFT(s_ndoc3,LEN(s_ndoc3)-1)
ENDIF
?"Номер под. накладної N"+s_ndoc
INKEY(5)
WCLOSE(n_win1)
IF n_error<>0
  DispError("При формуваннi;податкової накладної;знайдено "+STR(n_error,2)+" помилок ")
ENDIF
CLOSE sp10
SET PRINTER OFF
SET PRINTER TO
DBCOMMITALL()
CloseFl1()
SAVEPAR(1)
RETURN .t.
Function FormNal2()
  LOCAL m_ndoc:=" ",m_vnum,m_rec2,m_sum:=0,m_nds:=0,i,m_rec1
  LOCAL m_gauge,n,m_count:=1,m_screen,m_ddoc1,m_ddoc2,GetList:={},m_color,n_win1,l3:=.f.
  LOCAL s_kvo:=0,s_kvo1:=0,m_sum1:=0,m_nds1:=0,s_ndoc:="",s_ndoc1:="",;
  m_sum0:=0,l1:=.f.,l2:=.f.,s_ndoc3:="",m_ndoc1:=" ",m_sum3:=0,m_nds3:=0
  LOCAL s_files:={}
  SopenFiles("100",@s_files)
  OpenFl1()
    NET USE (m_platpath+"FVNUM") NEW

  fvnum->(DBGOTO(2))
  IF fvnum->(NetRlock())
    fvnum->reg:=SETBIT(fvnum->reg,m_computer)
    m_vnum:=fvnum->vnum
    fvnum->vnum:=fvnum->vnum+2
  ELSE
    DispError("Вiдмовлено в доступi")
    ScloseFile(s_files)
    CloseFl1()
    RETURN .f.
  ENDIF
  IF m_level>3
    DispError("Ви не маєте повноважень на запуск цiєї программи;Звернiться до адмiнiстратора системи")
    ScloseFile(s_files)
    CloseFl1()
    RETURN .f.
  ENDIF
  SAVEPAR()
  m_SCREEN :=savescreen(9,15,16,74)
  DispBox(9,15,14,70,B_SINGLE+" ","w+/bg")
  Shadow(9,15,14,70)
  @ 10,17 sayDisp 'Формувати податкову накладну по накладних' COLOR "n/Bg"
  @ 11,17 sayDisp 'за готiвку       з           по                 '  COLOR "n/Bg"
  m_ddoc1:=BOM(DATE()-10)
  @ 11,36 get m_ddoc1 COLOR "gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
  @ 11,50 get m_ddoc2 COLOR "gr+/N"  VALID m_ddoc2>=m_ddoc1
  SET ESCAPE ON
  read
  restscreen(9,15,16,74,m_screen)
  IF LASTKEY()==K_ESC
      set escape off
      set cursor off
      RETURN .F.
  ENDIF
  m_color:=SETCOLOR("w/b")
  SELECT Nalog1
  Set FILTER TO nalog1->vdoc=="1"
  nalog1->(DBSETORDER(2))
  SELECT NAkl1
  SET FILTER TO nakl1->vdoc=="1" // Витрата
  Nakl1->(DBGOTOP())
  n:=nakl1->(LASTREC())
  m_gauge:=InitGauge("Вибiрка iз бази накладних",1)
  IF FILE(m_platpath+"05.txt")
    NET USE (m_platpath+"arh") NEW
    IF arh->(NetDBAP())
      arh->name:="Форм. под. накл. за готiвку "
      arh->text:=MEMOREAD(m_platpath+"05.txt")
    ENDIF
    CLOSE arh
  ENDIF
  SETPRC(0,0)
  SET PRINTER TO (m_platpath+"05.txt")
  SET PRINTER ON
  n_win1:=WOPEN(0,0,8,80,.t.)
  Wselect(n_win1)
  WBOX(12)
  @-1,0 SayDisp PADC("Формування податкової накладної по накладних за готiвку ",80) COLOR "n/w"
  SETPOS(0,0)
  ?"Формування податкової накладної по накладних за готiвку"
  ?" за перiод з " +My_Dtos(m_ddoc1)+" по  "  +My_Dtos(m_ddoc2)
  Wselect(0)
    m_sum1:=0;m_nds1:=0
    m_sum:=0;m_nds:=0
    DO WHILE .NOT.nakl1->(EOF())
      IF ((nakl1->ddoc1>=m_ddoc1.AND.nakl1->ddoc1<=m_ddoc2.AND.;
        (nakl1->kod1=="Г ".OR.nakl1->kod1=="Г1").AND.IsBit(ASC(nakl1->state),1)).OR.;
        (nakl1->ddoc3>=m_ddoc1.AND.nakl1->ddoc3<=m_ddoc2.AND.nakl1->kod1=="Г2".AND.IsBit(ASC(nakl1->state),2)));
        .AND..not.IsBit(ASC(nakl1->state),3)

        m_sum0+=nakl1->sum

        IF EMPTY(nakl1->ndoc2)
          l3:=.t.
        ELSE
          l3:=.t.
          IF Nalog1->(DS(nakl1->ndoc2))
            DO WHILE .NOT.Nalog1->(EOF()).AND.Nalog1->ndoc==nakl1->ndoc2.AND.Nalog1->ddoc<>nakl1->ddoc2
              Nalog1->(dbskip())
            ENDDO
            IF Nalog1->ndoc==nakl1->ndoc2.AND.Nalog1->ddoc==nakl1->ddoc2
              l3:=.f.
              IF AT(Nalog1->ndoc+",",s_ndoc3)==0
                s_ndoc3+=Nalog1->ndoc+","
              ENDIF
            ENDIF
          ENDIF
        ENDIF

        IF l3
          s_kvo1++
          IF Nakl1->(NetRLock())
            nakl2->(DBSEEK(nakl1->vnum))
            s_kvo++
            IF (NumPotr(nakl1->kopr)<>"1")
              DO WHILE nakl2->VNUM==nakl1->vnum.AND..NOT.nakl2->(EOF())
                  IF nalog2->(NetDbAp())
                    nalog2->NumNakl:=nakl1->ndoc
                    nalog2->ddoc := nakl1->ddoc1
  //                  nalog2->ddoc := nakl1->ddoc
                    nalog2->kod  := nakl2->kod
                    Kaptka1->(DS(nakl2->kod))
                    nalog2->name := kaptka1->name
                    nalog2->izm  := Kaptka1->izm
                    nalog2->kvo  := nakl2->kvo
                    nalog2->prise:= nakl2->prise
                    IF  nakl2->nds<>0
                      nalog2->vnum := STR(m_vnum,6)
                      l1:=.t.
                      nalog2->sum1 :=nakl2->stm
                      nalog2->nds  := nakl2->nds
                      nalog2->stm  := nalog2->sum1 + nalog2->nds
                      m_sum+=nakl2->stm;m_nds+=nakl2->nds
                      l3:=.t.
                    ELSE
                      l2:=.t.
                      l3:=.f.
                      nalog2->vnum := STR(m_vnum+1,6)
                      nalog2->sum4 :=nakl2->stm
                      nalog2->stm  := nalog2->sum4
                      m_sum1+=nakl2->stm;m_nds1+=nakl2->nds
                    ENDIF
                  ELSE
                    DispError("Неможливо добавити строку в податкову накладну")
                  ENDIF
                  nalog2->(dbUnlock())
                  nakl2->(Dbskip())
              ENDDO
              IF l3
                IF EMPTY(m_ndoc)
                  m_ndoc:=STR(fvnum->ndoc,LEN(nalog1->ndoc))
                  fvnum->ndoc:=fvnum->ndoc+1
                  s_ndoc+=ALLTRIM(m_ndoc)+","
                ENDIF
                nakl1->ndoc2:=m_ndoc
              ELSE
                IF EMPTY(m_ndoc1)
                  m_ndoc1:=STR(fvnum->ndoc,LEN(nalog1->ndoc))
                  fvnum->ndoc:=fvnum->ndoc+1
                  s_ndoc+=ALLTRIM(m_ndoc1)+","
                ENDIF
                nakl1->ndoc2:=m_ndoc1
              ENDIF
            ELSE
              IF Nakl2->(FOUND())
                  m_sum3:=0;m_nds3:=0
                  DO WHILE nakl2->VNUM==nakl1->vnum.AND..NOT.nakl2->(EOF())
                    IF nalog2->(NetDbAp())
                      nalog2->vnum := STR(fvnum->vnum,6)
                      nalog2->NumNakl:=nakl1->ndoc
                      nalog2->ddoc := nakl1->ddoc1
                      nalog2->kod  := nakl2->kod
                      Kaptka1->(DS(nakl2->kod))
                      nalog2->name := kaptka1->name
                      nalog2->izm  := Kaptka1->izm
                      nalog2->kvo  := nakl2->kvo
                      nalog2->prise:= nakl2->prise
                      IF  nakl2->nds<>0
                        nalog2->sum1 :=nakl2->stm
                        nalog2->nds  := nakl2->nds
                        nalog2->stm  := nalog2->sum1 + nalog2->nds
                        m_sum+=nakl2->stm;m_nds+=nakl2->nds
                      ELSE
                        nalog2->sum4 :=nakl2->stm
                        nalog2->stm  := nalog2->sum4
                        m_sum1+=nakl2->stm;m_nds1+=nakl2->nds
                      ENDIF
                    ELSE
                      DispError("Неможливо добавити строку в податкову накладну")
                    ENDIF
                    nalog2->(dbUnlock())
                    m_sum3+=nakl2->stm;m_nds3+=nakl2->nds
                    nakl2->(Dbskip())
                  ENDDO
                  IF nalog1->(NetDbAp())
                    nalog1->vnum:=STR(fvnum->vnum,6)
                    fvnum->vnum:=fvnum->vnum+1
                    nalog1->ndoc:=STR(fvnum->ndoc,LEN(nalog1->ndoc))
                    fvnum->ndoc:=fvnum->ndoc+1
                    nalog1->ddoc:=DATE()
                    SetPred01()
                    Nalog1->vdoc:="1"
                    Firm01->(DBSETORDER(2))
                    Firm01->(DS(nakl1->okpo))
                    Firm01->(DBSETORDER(1))
                    SetFirm01()
                    nalog1->nds:=m_nds
                    nalog1->sum:=m_sum
                    nalog1->(dbUnlock())
                    s_ndoc+=ALLTRIM(nalog1->ndoc)+","
                  ELSE
                    DispError("Неможливо добавити заголовок в податкову накладну")
                  ENDIF
                  nakl1->ndoc2:=nalog1->ndoc
              ENDIF
            ENDIF
            nakl1->ddoc2:=Date()
            s_ndoc1+=ALLTRIM(nakl1->ndoc)+","
            nakl1->(DbUnlock())
          ENDIF
        ENDIF
      ENDIF
      m_gauge:=DispGauge(m_gauge,m_count++/n)
      nakl1->(DBSKIP())
    ENDDO
  SELECT Nalog1
  Set FILTER TO
  IF l1
  IF nalog1->(NetDbAp())
    nalog1->vnum:=STR(m_vnum,6)
    nalog1->ndoc:=m_ndoc
    nalog1->ddoc:=DATE()
    SetPred01()
    Nalog1->vdoc:="1"
    nalog1->nds:=m_nds
    nalog1->sum:=m_sum
    nalog1->(dbUnlock())
  ELSE
        DispError("Неможливо добавити заголовок в податкову накладну")
  ENDIF
  ENDIF
  IF l2
    IF nalog1->(NetDbAp())
      nalog1->vnum:=STR(m_vnum+1,6)
      nalog1->ndoc:=m_ndoc1
      nalog1->ddoc:=DATE()
      SetPred01()
      Nalog1->vdoc:="1"
      nalog1->nds:=m_nds1
      nalog1->sum:=m_sum1
      nalog1->(dbUnlock())
    ELSE
          DispError("Неможливо добавити заголовок в податкову накладну")
    ENDIF
  ENDIF



  IF fvnum->(NetRlock())
    fvnum->reg:=CLEARBIT(fvnum->reg,m_computer)
    fvnum->(DBCOMMIT())
    fvnum->(DbUnlock())
  ELSE
    DispError("Вiдмовлено в доступi")
  ENDIF
WSELECT(n_win1)
?"   ------------ Cума накладних ------------------------"
?"   Реалiзацiя (кредит 70 рахунку)-Дебет 50 "+SumToStr(m_sum0)
IF .NOT.EMPTY(s_ndoc3)
  ?"Увага !!! Вже сформованi податковi накладнi N"+LEFT(s_ndoc3,LEN(s_ndoc3)-1)
ENDIF

?"   ------------ Cума податкової------------------------"
?"   Реалiзацiя (кредит 70 рахунку)-Дебет 50 "+SumToStr(m_sum+m_nds+m_sum1+m_nds1)
?"             ПДВ                           "+SumToStr(m_nds+m_nds1)
?"   Кiлькiсть накладних занесених в податкову "+LTRIM(str(s_kvo))
?""
?"Загальна кiлькiсть накладних "+LTRIM(str(s_kvo1))
s_ndoc1:=LEFT(s_ndoc1,LEN(s_ndoc1)-1)
DO WHILE .NOT.EMPTY(s_ndoc1)
  i:=IF(LEN(s_ndoc1)>60,RAT(",",LEFT(s_ndoc1,60)),LEN(s_ndoc1))
  IF i==0
    i:=60
  ENDIF
  ?LEFT(s_ndoc1,i)
  s_ndoc1:=SUBSTR(s_ndoc1,i+1)
ENDDO
?" Занесення данних зроблено "+my_dtos(DATE())
?"                  виконав "+ALLTRIM(_Fio(m_tabn))
?" Податкова накладна N "+LEFT(s_ndoc,LEN(s_ndoc)-1)
INKEY(5)
SET PRINTER OFF
SET PRINTER TO
DBCOMMITALL()
ScloseFile(s_files)
CloseFl1()
Close Fvnum
SAVEPAR(1)
RETURN .t.


Function Revizor01(v1,v2,v3)
  LOCAL  m_mol:="  ",m_ddoc1:=DATE(),m_ddoc2:=DATE(),l_first:=.t.
  LOCAL m_file1,s_kvo1:=0,s_kvo2:=0,s_ndoc1:="",s_ndoc2:="",s_files:={}
  LOCAL m_log,n,n_count:=0,n_win1,m_gauge,s_str1,a_kod:={},i,m_prise,n_error:=0,n_warning:=0
  // Ввiд матер. особи i дати
  SopenFiles("100",@s_files)
  IF v3==NIL
    IF .not.Get001(@m_mol,@m_ddoc1,@m_ddoc2)
      ScloseFile(s_files)
      RETURN .f.
    ENDIF
  ELSE
    m_mol:=v1;m_ddoc1:=v2;m_ddoc2:=v3
  ENDIF
  OPenFl1()
  //Вибiрка даних
  Nakl1->(DBGOTOP())
  MyCreate("NAKL39","buf1")
  MyCreate("NAKL40","buf2")
  SELECT buf1
  INDEX ON buf1->kod TO (m_temppath+"buf1")
  n:=nakl1->(LASTREC())
  IF FILE(m_platpath+"40.txt")
    NET USE (m_platpath+"arh") NEW
    IF arh->(NetDBAP())
      arh->name:="Перевiрка звiту комiрника"
      arh->text:=MEMOREAD(m_platpath+"40.txt")
    ENDIF
    CLOSE arh
  ENDIF
NET USE (m_platpath+"spr03.dbf") NEW ALIAS file3
m_gauge:=InitGauge("Вибiрка сальдо",2)
DO WHILE .NOT.File3->(EOF())
  IF m_mol==file3->mol.AND.mnt_dtod(m_ddoc1)==file3->mnt
    IF .NOT.buf1->(DS(file3->kod))
      buf1->(DBAP())
      buf1->kod  :=file3->kod
      buf1->ozn  :=file3->ozn
    ENDIF
    IF buf1->ozn<>file3->ozn
      Disperror("Помилка в залишках !!!; код виробництва рiзний "+file3->kod)
      n_error++
    ENDIF
      buf1->inkvo+=file3->kvo
      buf1->inglv+=file3->glv
      buf1->insum+=file3->stm
  ENDIF
  File3->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,File3->(RECNO())/File3->(LASTREC()))
ENDDO
DelGauge(m_gauge)
// CLOSE file3
  SETPRC(0,0)
  SET PRINTER TO (m_platpath+"40.txt")
  SET PRINTER ON
m_gauge:=InitGauge("Вибiрка iз накладних",2)
n_win1:=WOPEN(0,0,8,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC("Перевiрка звiту комiрника ("+m_mol+")"+RTRIM(_mol(m_mol)),80) COLOR "n/w"
SETPOS(0,0)
?"Перевiрка звiту комiрника ("+m_mol+")"+RTRIM(_mol(m_mol))
?" за перiод з " +My_Dtos(m_ddoc1)+" по  "  +My_Dtos(m_ddoc2)
Wselect(0)
  DO WHILE .NOT.nakl1->(EOF())
    IF nakl1->ddoc3>=m_ddoc1.AND.nakl1->ddoc3<=m_ddoc2.AND..not.IsBit(ASC(nakl1->state),3)
      IF ((nakl1->vdoc=="0".AND.nakl1->otp==m_mol).OR.(nakl1->vdoc<>"0".AND.(nakl1->otp==m_mol.or.nakl1->mol==m_mol)))
        IF (nakl1->vdoc=="0".AND.nakl1->otp==m_mol).OR.(nakl1->vdoc<>"0".AND.nakl1->mol==m_mol)
          m_log:="0" // ПРИХIД
          s_ndoc1+=nakl1->ndoc;s_kvo1++
        ELSE
          m_log:="1" // ВИТРАТА
          s_ndoc2+=nakl1->ndoc;s_kvo2++
        ENDIF
        nakl2->(DS(nakl1->vnum))
        DO WHILE .NOT.nakl2->(EOF()).AND.nakl1->vnum==nakl2->vnum
          IF .NOT.Kaptka1->(DS(nakl2->kod))
             WSELECT(n_win1)
              ?"** Помилка !!! Код("+nakl2->kod+") не визначен в довiднику "
              ?"    Накладна номер ",nakl1->ndoc
              n_error++
             WSELECT(0)
          ENDIF
          buf2->(DBAP())
          buf2->ndoc :=nakl1->ndoc
          buf2->kvo  :=nakl2->kvo
          buf2->log  :=m_log
          buf2->kod  :=nakl2->kod
          buf2->stm1 :=IF(m_log=="0",nakl2->stm,0)
          IF  .NOT.buf1->(DS(nakl2->kod))
            buf1->(DBAP())
            buf1->kod  :=Nakl2->kod
            IF m_log=="0".and.Spr01->potr=="2"  // обработать ситуацию от другого мол
                buf1->ozn  :="1"
            ENDIF
          ENDIF
          IF m_log=="0".AND.nakl1->vdoc>='1'.and.nakl2->stm1==0
             WSELECT(n_win1)
              ?"** Помилка !!! Код("+nakl2->kod+") накладної номер ",nakl1->ndoc," не протаксовано"
              n_error++
             WSELECT(0)
          ENDIF
          IF m_log=="0"
            buf1->dkvo+=nakl2->kvo
            buf1->dsum+=nakl2->stm
          ELSE
            IF nakl2->st==" "
              buf1->ckvo+=nakl2->kvo
              buf1->csum+=nakl2->stm
            ELSE
              buf1->dkvo-=nakl2->kvo
              buf1->dsum-=nakl2->stm
              WSELECT(n_win1)
              ?"Попередження !!! Код("+nakl2->kod+") накладної номер ",nakl1->ndoc," протаксовано вручну"
              WSELECT(0)
            ENDIF
            IF LEFT(kaptka1->ksash,2)=="12".AND.;
              (Spr01->potr=="2".or.Spr01->potr=="6".or.Spr01->potr=="7");
              .AND.kaptka1->month==0.and.kaptka1->km==0
              IF ASCAN(a_kod,buf1->kod)==0
                AADD(a_kod,buf1->kod)
             ENDIF
            ENDIF
          ENDIF
          nakl2->(DBSKIP())
        ENDDO
      ENDIF
    ENDIF
    m_gauge:=DispGauge(m_gauge,n_count++/n)
    nakl1->(DBSKIP())
  ENDDO
  m_gauge:=DispGauge(m_gauge,1)
  DelGauge(m_gauge)
  NET USE (m_platpath+"NAKL5") new
  m_gauge:=InitGauge("Вибiрка даних по переводу ",2)
  DO WHILE .NOT.nakl5->(EOF())
    IF nakl5->ddoc>=m_ddoc1.AND.nakl5->ddoc<=m_ddoc2.and.Nakl5->mol==m_mol
      IF  .NOT.buf1->(DS(nakl5->cod1))
        buf1->(DBAP())
        buf1->kod  :=Nakl5->cod1
      ENDIF
      buf1->ckvo+=nakl5->kvo
/*      IF Nakl5->(NEtRlock())
        nakl5->stm:=nakl5->kvo*IF((buf1->Dkvo+buf1->inkvo)<>0,(buf1->insum+buf1->Dsum)/(buf1->Dkvo+buf1->inkvo),0)
      ENDIF  */
      IF Nakl5->stm==0
         ?"** Помилка !!! Передача з коду("+nakl5->cod1+") документа номер ",nakl5->ndoc," не протаксована"
      ENDIF
      IF nakl5->kvo<>0.AND.buf1->inkvo<>0.AND.;
        ABS(buf1->insum/buf1->inkvo-nakl5->stm/nakl5->kvo)/ABS(nakl5->stm/nakl5->kvo)>0.15
         kaptka1->(DS(buf1->kod))
         ?"Попередження !!! Вiдхилення цiни по ("+nakl5->cod1+") "+ALLTRIM(kaptka1->name)+" Акт N",nakl5->ndoc
      ENDIF
      buf1->csum+=nakl5->stm
      IF  .NOT.buf1->(DS(nakl5->cod2))
        buf1->(DBAP())
        buf1->kod  :=Nakl5->cod2
      ENDIF
      buf1->dkvo+=nakl5->kvo
      buf1->dsum+=nakl5->stm
    ENDIF
    nakl5->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,NAKL5->(RECNO()/LASTREC()))
  ENDDO
  CLOSE nakl5
  DelGauge(m_gauge)
  buf2->(DBGOTOP())
  buf1->(DBGOTOP())
  wselect(n_win1)
  IF LEN(a_kod)>0
    ?" Не визначен термiн експлуатацiї кодiв:"
    a_kod:=ASORT(a_kod)
  FOR i:=1 TO LEN(a_kod)
    kaptka1->(DS(a_kod[i]))
    ?a_kod[i]," - ",kaptka1->name
  NEXT
    ?REPLICATE("-",60)
  ENDIF
  buf1->(DBGOTOP())
  DO WHILE .NOT.buf1->(EOF())
    IF buf1->insum<>0
      IF buf1->inkvo<>0
        buf1->prise1:=buf1->insum/buf1->inkvo
      ELSE
        kaptka1->(DS(buf1->kod))
        ?"** Помилка !!! Залишки("+buf1->kod+") "+kaptka1->name
        n_error++
      ENDIF
    ENDIF
    IF buf1->Dsum<>0
      IF buf1->Dkvo<>0
        buf1->prise2:=buf1->Dsum/buf1->Dkvo
      ELSE
        kaptka1->(DS(buf1->kod))
        ?"** Помилка !!! Прихiд ("+buf1->kod+") "+kaptka1->name
        n_error++
      ENDIF
    ENDIF
    IF buf1->prise1<>0.and.buf1->prise2<>0
      IF ABS(buf1->prise1-buf1->prise2)/ABS(buf1->prise2)>0.15
        kaptka1->(DS(buf1->kod))
        ?"Попередження !!! Змiна цiни по ("+buf1->kod+") "+kaptka1->name
        n_warning++
      ENDIF
    ENDIF
    IF buf1->inkvo+buf1->dkvo<buf1->ckvo
        kaptka1->(DS(buf1->kod))
      ?"** Помилка !!! Перевитрата ("+buf1->kod+") "+kaptka1->name
      n_error++
    ENDIF
    buf1->( DBSKIP())
  ENDDO
  l_first:=.t.
  buf1->(DBGOTOP())
  DO WHILE .NOT.buf1->(EOF())
    kaptka1->(DS(buf1->kod))
    buf1->prise3:=IF((buf1->Dkvo+buf1->inkvo)<>0,(buf1->insum+buf1->Dsum)/(buf1->Dkvo+buf1->inkvo),0)
    IF buf1->prise1<>0.and.buf1->prise2<>0
    IF buf1->prise1<>buf1->prise2
       IF l_first
?
?"                 ТАБЛИЦЯ ПЕРЕРАХУНКУ ВАРТОСТI ТМЦ"
?"--------------------------------------------------------------------------"
?"| Код       |       Назва          | Попередня  | Одержано   | Середня   |"
?"|           |                      |   цiна     |            |  цiна     |"
?"--------------------------------------------------------------------------"
l_first:=.f.
ENDIF
        buf1->prise3:=(buf1->insum+buf1->Dsum)/(buf1->Dkvo+buf1->inkvo)
        ?"| "+buf1->kod+"| "+LEFT(kaptka1->name,20)+" | "+SumtoStr(buf1->prise1,10)+" | "+SumtoStr(buf1->prise2,10)+" | "+SumtoStr(buf1->prise3,10)
    ENDIF
    ENDIF
    buf1->( DBSKIP())
  ENDDO
  IF .NOT.l_first
?"--------------------------------------------------------------------------"
  ENDIF
buf2->(DBGOTOP())
DO WHILE .NOT.buf2->(EOF())
  IF buf2->log=="1"
    buf1->(DS(buf2->kod))
    m_prise:=IF((buf1->Dkvo+buf1->inkvo)<>0,(buf1->insum+buf1->Dsum)/(buf1->Dkvo+buf1->inkvo),0)
    buf2->stm1:=m_prise*buf2->kvo
  ENDIF
  IF buf2->stm1==0
      kaptka1->(DS(buf2->kod))
    ?"  Попередження !!! Вартiсть кода("+buf2->kod+") "+kaptka1->name
    ?"     Накладної N "+buf2->ndoc+" =0"
    n_warning++
  ENDIF
  buf2->(DBSKIP())
ENDDO
?"Звiт мiстить накладних по приходу",s_kvo1
DO WHILE .NOT.EMPTY(s_ndoc1)
  i:=IF(LEN(s_ndoc1)>60,RAT(",",LEFT(s_ndoc1,60)),LEN(s_ndoc1))
  IF i==0
    i:=60
  ENDIF
  ?LEFT(s_ndoc1,i)
  s_ndoc1:=SUBSTR(s_ndoc1,i+1)
ENDDO
?"Звiт мiстить накладних по витратi",s_kvo2
DO WHILE .NOT.EMPTY(s_ndoc2)
  i:=IF(LEN(s_ndoc2)>60,RAT(",",LEFT(s_ndoc2,60)),LEN(s_ndoc2))
  IF i==0
    i:=60
  ENDIF
  ?LEFT(s_ndoc2,i)
  s_ndoc2:=SUBSTR(s_ndoc2,i+1)
ENDDO
IF n_error<>0
  ?"Загальна кiлькiсть помилок =",STR(n_error,3)
ENDIF
IF n_warning<>0
  ?"Загальна кiлькiсть попереджень =",STR(n_warning,3)
ENDIF
?" Перевiрку звiта зроблено "+my_dtos(DATE())
?"                 виконав "+ALLTRIM(_Fio(m_tabn))
  WSELECT(0)
  WCLOSE(n_win1)
  set print off
  SET PRINTER TO
  CLOSE BASE buf1,buf2,file3
  ScloseFile(s_files)
  CloseFl1()
RETURN n_error



Function Provod()
  LOCAL n_error,n_win1,m_gauge,m_mol:="  ",m_ddoc1:=DATE(),m_ddoc2:=DATE(),m_nds,;
  m_log,m_kod1,n,n_count:=0,m_672000,k_77,;
  m_prise,m_15,m_pension,m_671000,m_810000,k_79,n_nds:=0,s_files:={},a_tabl:={}

  InitNds()
  NET USE (m_sprpath+"sp45") READONLY
  DO WHILE .NOT.sp45->(EOF())
    AADD(a_tabl,{sp45->Scht1,sp45->Scht2,sp45->Scht3})
    sp45->(DBSKIP())
  ENDDO
  CLOSE sp45
  SopenFiles("100",@s_files)
  n_nds:=GetNds()/(1+GetNds())
    IF .not.Get001(@m_mol,@m_ddoc1,@m_ddoc2)
      RETURN .f.
    ENDIF
  n_error:=Revizor01(m_mol,m_ddoc1,m_ddoc2)
  IF n_error<>0
    Viewotch("40")
    IF ANSWERu("Звiт мiстить "+STR(n_error,3)+" помилок;Виконувати формування проводок")<>YES
      RETURN .f.
    ENDIF
  ENDIF
  NET USE (m_platpath+"memvar") INDEX (m_platpath+"memvar") NEW ALIAS myvar
  m_810000:=RestVar1("m_810000","NK")
  m_pension:=RestVar1("m_pension","NK")
  k_77:=RestVar1("k_77","NK")
  k_79:=RestVar1("k_79","NK")
//  k_nds:=RestVar1("k_nds","NK")
  m_15:=RestVar1("m_15","NK")
  CLOSE myvar
  USE (m_temppath+"buf1") INDEX (m_temppath+"buf1") NEW
  MyCreate("PROV01","prov")
  SETPRC(0,0)
  SET PRINTER TO (m_platpath+"41.txt")
  SET PRINTER ON
m_gauge:=InitGauge("Вибiрка iз накладних",2)
n_win1:=WOPEN(0,0,8,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC("Формування проводок по комiрнику ("+m_mol+")"+RTRIM(_mol(m_mol)),80) COLOR "n/w"
SETPOS(0,0)
?"Формування проводок по комiрнику ("+m_mol+")"+RTRIM(_mol(m_mol))
?" за перiод з " +My_Dtos(m_ddoc1)+" по  "  +My_Dtos(m_ddoc2)
 NET USE (m_platpath+"nakl1") NEW ALIAS nakl1
 NET USE (m_platpath+"nakl2") INDEX (m_platpath+"nakl2")   NEW ALIAS nakl2
 NET USE (m_platpath+"nakl3") INDEX (m_platpath+"nakl3")   NEW ALIAS nakl3
 NET USE (m_platpath+"spr01") INDEX (m_platpath+"spr01")   NEW ALIAS spr01
 NET USE (m_platpath+"kaptka1") INDEX (m_platpath+"kaptka1"),(m_platpath+"kaptka1a"),(m_platpath+"kaptka1b") ALIAS kaptka1 NEW
 NET USE (m_platpath+"FIRM01") INDEX (m_platpath+"FIRM01"),(m_platpath+"FIRM01A"),(m_platpath+"FIRM01B") NEW

Wselect(0);n:=nakl1->(LASTREC())
  DO WHILE .NOT.nakl1->(EOF())
    IF nakl1->ddoc3>=m_ddoc1.AND.nakl1->ddoc3<=m_ddoc2.AND..not.IsBit(ASC(nakl1->state),3)
      IF ((nakl1->vdoc=="0".AND.nakl1->otp==m_mol).OR.(nakl1->vdoc<>"0".AND.nakl1->otp==m_mol))
        IF (nakl1->vdoc=="0".AND.nakl1->otp==m_mol).OR.(nakl1->vdoc<>"0".AND.nakl1->mol==m_mol)
          m_log:="0" // ПРИХIД
        ELSE
          m_log:="1" // ВИТРАТА
        ENDIF
        nakl2->(DS(nakl1->vnum))
        Spr01->(DS(nakl1->kopr))
        m_kod1:=nakl1->kod1
        DO WHILE .NOT.nakl2->(EOF()).AND.nakl1->vnum==nakl2->vnum
          Kaptka1->(DS(nakl2->kod))
          DO CASE
            CASE nakl1->vdoc=="0"  // приход
              Prov->(DBAP())
              Prov->ndoc:=nakl1->ndoc
              Prov->ddoc:=nakl1->ddoc3
              Prov->kopr:=Spr01->kpr
              Prov->dbt:=Kaptka1->ksash
              Prov->cod1:=Nakl2->kod
              Prov->stm:=nakl2->stm
              SetKvo()
              Prov->kplh:=nakl1->otp
              DO CASE
                CASE m_kod1=="Г ".OR.m_kod1=="Г2"
                  IF NumPotr(Nakl1->kopr) == "1"
                    ZanPred0();ZanNds0()
                  ELSE
                    ZanTabn();ZanNds1()
                  ENDIF
                CASE m_kod1=="Г1"
                  IF NumPotr(Nakl1->kopr) == "1"
                    ZanPred0()
                  ELSE
                    ZanTabn()
                  ENDIF
                CASE m_kod1=="П ".OR.m_kod1=="П1" // По перерахуванню
                  ZanPred0() // Оплачено 1-е событие
                CASE m_kod1=="П2"
                  ZanPred0();ZanNds0() // Получено первое событие
                CASE m_kod1=="Б ".or.m_kod1=="Б2".or.m_kod1=="К " // Бартер
                  IF NumPotr(Nakl1->kopr) == "1"
                    ZanPred0();ZanNds0()
                  ELSE
                  IF NumPotr(Nakl1->kopr) == "8" // частное лицо
                    ZanPerson();ZanNds1()
                  else
                    ZanTabn();ZanNds1()
                  ENDIF
                  ENDIF
                CASE m_kod1=="Б1" // Бартер
                  ZanPred0()
                  Prov->(DBAP())
                  Prov->ndoc:=nakl1->ndoc
                  Prov->ddoc:=nakl1->ddoc3
                  Prov->kopr:=GetNdsKopr()
                  SetKvo()
                  Prov->dbt:="643"+RIGHT(SetFirmKsash(nakl1->okpo),3)
                  Prov->crt:=GetNdsKsash(kaptka1->ksash2)
                  Prov->cod1:=Nakl1->okpo
                  Prov->cod2:=Nakl2->kod
                  Prov->stm:=n_nds*(nakl2->stm+nakl2->nds)
                  IF nakl2->nds<>0
                    Prov->(DBAP())
                    Prov->ndoc:=nakl1->ndoc
                    Prov->ddoc:=nakl1->ddoc3
                    Prov->kopr:=GetNdsKopr()
                    SetKvo()
                    Prov->dbt:="644"+RIGHT(SetFirmKsash(nakl1->okpo),3)
                    Prov->crt:=Firm01->ksash
                    Prov->cod2:=Nakl1->okpo
                    Prov->cod1:=Nakl2->kod
                    Prov->stm:=Nakl2->nds
                  ENDIF
                CASE m_kod1=="В " // Виробництво
                  Prov->crt:=Nakl1->ksash
                  IF spr01->potr=="6"
                    Prov->cod2:=Nakl1->gnavt
                  ENDIF
                  IF spr01->potr=="7"
                    Prov->cod2:=Nakl1->ntr
                  ENDIF
                  Prov->brgd2:=Nakl1->brgd
                CASE m_kod1=="Т " // Пiдзвiтнi особи
                  Prov->crt:=Nakl1->ksash
                  Prov->cod2:=Nakl1->tabn
                  ZanNds2()
                OTHERWISE
                  Wselect(n_win1)
                  ?"Помилка !!! Накладна N ",nakl1->ndoc," не проведена"
                  Wselect(0)
              ENDCASE
          CASE nakl1->vdoc=="3".OR.nakl1->vdoc=="2"
               Prov->(DBAP())
                Prov->ndoc:=nakl1->ndoc
                Prov->ddoc:=nakl1->ddoc3
                Prov->kopr:=k_77
                Prov->dbt :="2034"+RIGHT(ALLTRIM(Nakl2->kod),2)
                Prov->cod1:=Nakl2->kod
                Prov->crt :="2031"+RIGHT(ALLTRIM(Nakl2->kod),2)
                Prov->cod2:=Nakl2->kod
                Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
                Prov->stm:=nakl2->stm1
                Prov->kvo2:=nakl2->glv
                Prov->kplh:=nakl1->mol
                Prov->tabn:=Nakl1->tabn
                Prov->otp :=nakl1->otp
                Prov->kplh:=nakl1->mol
                IF nakl1->vdoc=="2"
                  Prov->vdoc:=1;Prov->ntr:=Nakl1->ntr
                ELSE
                  Prov->vdoc:=2;Prov->gnavt:=Nakl1->gnavt
                ENDIF
            CASE nakl1->vdoc>"0".and.m_log=="1" // расход без внутренней передачи
              Prov->(DBAP())
              Prov->ndoc:=nakl1->ndoc
              Prov->ddoc:=nakl1->ddoc3
              Prov->kopr:=Spr01->kpr
              Prov->cod2:=Nakl2->kod
              setKvo()
              Prov->otp :=nakl1->otp
              Prov->crt:=Kaptka1->ksash
                  DO CASE
                      CASE m_kod1=="Г ".or.m_kod1=="Г1" // За готiвку
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                        IF NumPotr(Nakl1->kopr) == "1"
                          // Допомiжна по 76 рахунку
                          ZanPred(a_tabl)
                        ENDIF
                      CASE m_kod1=="Г2" // За готiвку
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                        IF NumPotr(Nakl1->kopr) == "1"
                          // Допомiжна по 76 рахунку
                          ZanPred(a_tabl)
                        ENDIF
                        ZanNds(a_tabl)
                      CASE m_kod1=="П ".or.m_kod1=="П2" // Поперерахуванню
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                        ZanPred(a_tabl)
                        ZanNds(a_tabl)
                      CASE m_kod1=="П1" // По перерахуванню предоплата
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                        ZanPred(a_tabl)
                      CASE m_kod1=="З ".or.m_kod1=="З2"// В рахунок заробiтньої плати
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                      CASE m_kod1=="Б ".OR.m_kod1=="К "
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                        ZanPred(a_tabl)
                        ZanNds(a_tabl)
                      CASE m_kod1=="Б1"
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                        ZanPred(a_tabl)
                        Prov->(DBAP())
                        Prov->ndoc:=nakl1->ndoc
                        Prov->ddoc:=nakl1->ddoc3
                        Prov->kopr:=GetNdsKopr()
//                        setKvo()
                        Prov->crt:="643"+RIGHT(SetFirmKsash(nakl1->okpo),3)
                        Prov->dbt:=kaptka1->ksash2
                        Prov->cod2:=Nakl1->okpo
                        Prov->cod1:=Nakl2->kod
                        Prov->stm:=Nakl2->nds
                        Prov->(DBAP())
                        Prov->ndoc:=nakl1->ndoc
                        Prov->ddoc:=nakl1->ddoc3
                        Prov->kopr:=GetNdsKopr()
//                        SetKvo()
                        Prov->crt:="644"+RIGHT(SetFirmKsash(nakl1->okpo),3)
//                        Prov->dbt:=m_680000
                        Prov->dbt:=GetNdsKsash(kaptka1->ksash2)
                        Prov->cod2:=Nakl1->okpo
                        Prov->cod1:=Nakl2->kod
                        Prov->stm:=Nakl2->nds
                      CASE m_kod1=="Б2"
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                        ZanPred(a_tabl)
                        ZanNds(a_tabl)
                      CASE m_kod1=="В " // Виробництво
                          Zanes03(Nakl1->ksash,;
                          IF(spr01->potr=="6",nakl1->gnavt,IF(spr01->potr=="7",nakl1->ntr,"")),Nakl1->brgd,.t.,,a_tabl)
                        CASE m_kod1=="М " // IНШИЙ МВО
                          Zanes03(prov->crt,nakl2->kod,,.t.,k_77,a_tabl)
                          Prov->kplh:=Nakl1->mol
                        CASE m_kod1=="С " // Пенсiя
                          Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                          ZanPens(m_pension)
                          ZanNds(a_tabl)
                        CASE m_kod1=="Д " // Безповоротна допомога
                          Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.,,a_tabl)
                          ZanPens(m_810000)
                          ZanNds(a_tabl)
                        OTHERWISE
                          Wselect(n_win1)
                          ?"Помилка !!! Накладна N ",nakl1->ndoc," не проведена"
                          Wselect(0)
                    ENDCASE
          CASE nakl1->vdoc>"0".and.m_log=="0" // внутренняя передача одержання
              Prov->(DBAP())
              Prov->ndoc:=nakl1->ndoc
              Prov->ddoc:=nakl1->ddoc3
              Prov->kopr:=k_77
              Prov->dbt :=Kaptka1->ksash
              Prov->cod1:=Nakl2->kod
              Prov->crt :=Kaptka1->ksash
              Prov->cod2:=Nakl2->kod
              Prov->stm:=nakl2->stm1
              setKvo()
              Prov->kplh:=nakl1->mol
              Prov->otp :=nakl1->otp
           OTHERWISE
                Wselect(n_win1)
                ?"Помилка !!! Накладна N ",nakl1->ndoc," не проведена"
                Wselect(0)

        ENDCASE
          nakl2->(DBSKIP())
        ENDDO
      ENDIF
    ENDIF
    m_gauge:=DispGauge(m_gauge,n_count++/n)
    nakl1->(DBSKIP())
  ENDDO
  DelGauge(m_gauge)
  NET USE (m_platpath+"NAKL5") new
  m_gauge:=InitGauge("Вибiрка даних по переводу ",2)
  DO WHILE .NOT.nakl5->(EOF())
  IF nakl5->ddoc>=m_ddoc1.AND.nakl5->ddoc<=m_ddoc2.and.Nakl5->mol==m_mol
      Prov->(DBAP())
      Prov->ndoc:=nakl5->ndoc
      Prov->ddoc:=nakl5->ddoc
      Kaptka1->(DS(nakl5->cod2))
      Prov->kopr:=k_79
      Prov->dbt :=Kaptka1->ksash
      Prov->cod1:=nakl5->cod2
      Kaptka1->(DS(nakl5->cod1))
      Prov->crt :=Kaptka1->ksash
      Prov->cod2:=nakl5->cod1
//       SetKvo()
    Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl5->kvo
    IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
      Prov->glv:=nakl5->glv
    ELSE
      Prov->kvo2:=nakl5->glv
    ENDIF

      Prov->stm:=nakl5->stm
      Prov->kplh:=nakl5->mol
      Prov->otp :=nakl5->mol
    ENDIF
    nakl5->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,NAKL5->(RECNO()/LASTREC()))
  ENDDO
  CLOSE nakl5
  DelGauge(m_gauge)
  SET PRINTER OFF
  SET PRINTER TO
  Prov->(DBGOTOP())
  Zanes02(m_mol,GetNdsKopr(),m_ddoc1,m_ddoc2)
  WCLOSE(n_win1)
  wselect(0)
    ScloseFile(s_files)
  Close base buf1,prov,nakl1,nakl2,nakl3,firm01
  IF ANSWERu("Зберiгати таблицю проводок ?")==YES
    IF FILE(m_platpath+"PROV"+m_mol+".dbf")
      FERASE(m_platpath+"PROV"+m_mol+".dbf")
    ENDIF
    FILECOPY(m_temppath+"prov.dbf",m_platpath+"PROV"+m_mol+".dbf")
    STRFILE(m_mol+GetNdsKopr()+DTOC(m_ddoc1)+DTOC(m_ddoc2)+"ьь",m_platpath+"PROV"+m_mol+".dbf",.t.)
  ENDIF
RETURN .t.
STATIC Function Zanes02(m_mol,k_nds,m_ddoc1,m_ddoc2)
LOCAL l_first:=.T.,;
m_gauge,m_kod,l1,i
LOCAL m_browse,l_print,m_key,l_delete:=.t.,;
   m_br1,m_br2,l_pr1:={},l_pr2:={},;
   a_get:={},a_get1:={},a_get2:={},;
   m_npch:="7"+STRZERO(MONTH(m_ddoc1),2)+m_mol
   SAVEPAR()
  USE (m_sprpath+"sp18") INDEX  (m_sprpath+"sp18") NEW
  Prov->(DBGOTOP())
  DO WHILE .NOT.PROV->(EOF())
    IF .NOT.Sp18->(DS(LEFT(Prov->dbt,2)+Prov->kopr+LEFT(Prov->crt,2)))
      Prov->st:="?"
    ENDIF
    Prov->(Dbskip())
  ENDDO
  CLOSE Sp18

  SELECT Prov
  Prov->(DBGOTOP())

  CrList1("PROV",@m_br1,@l_pr1)
  m_br1:freeze:=1
  ASIZE(a_get1,m_br1:ColCount)
  FOR i:=1 TO LEN(a_get1)
    a_get1[i]:=GetNew()
    a_get1[i]:Block:=m_br1:GetColumn(i):Block
    a_get1[i]:ColorSpec:="gr+/n,gr+/n"
  NEXT
  a_get1[4]:PreBlock:=a_get1[6]:PreBlock:=a_get1[10]:PreBlock:={||.f.}
  a_get1[3]:PostBlock:={||Sp05->(sp_vl("SP05","2"))}
  a_get1[5]:PostBlock:={||Sp44->(sp_vl("SP44"))}
  a_get1[7]:PostBlock:={||Sp02->(sp_vl("SP02","2"))}
  a_get1[8]:PostBlock:={||Sp01->(sp_vl("SP01","2"))}
  a_get1[9]:PostBlock:={||Sp44->(sp_vl("SP44"))}
  a_get1[11]:PostBlock:={||Sp02->(sp_vl("SP02","2"))}
  a_get1[12]:PostBlock:={||Sp01->(sp_vl("SP01","2"))}
  m_br2:=TBrowseDB(3,1,MAXROW()-1,MAXCOL()-1)
  m_br2:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_br2:colsep        := '│'
  m_br2:SkipBlock     := { |n| SkipDb(n) }
  m_br2:goBottomBlock := { ||  DBGOBOTTOM() }
  m_br2:goTopBlock    := { ||  DBGOTOP()  }
  m_br2:cargo:=m_br1:cargo:="Рух продукцiї по МВО "+m_mol+" "+ALLTRIM(_mol(m_mol))+" за перiод з "+DTOC(m_ddoc1)+" по "+DTOC(m_ddoc2)
  m_br2:freeze:=1
  ASIZE(a_get2,12)
  m_br2:AddColumn(m_br1:GetColumn(1));a_get2[1]:=a_get1[1]
  m_br2:AddColumn(m_br1:GetColumn(3));a_get2[2]:=a_get1[3]
  m_br2:AddColumn(m_br1:GetColumn(5));a_get2[3]:=a_get1[5]
  m_br2:AddColumn(m_br1:GetColumn(7));a_get2[4]:=a_get1[7]
  m_br2:AddColumn(m_br1:GetColumn(8));a_get2[5]:=a_get1[8]
  m_br2:AddColumn(m_br1:GetColumn(9));a_get2[6]:=a_get1[9]
  m_br2:AddColumn(m_br1:GetColumn(11));a_get2[7]:=a_get1[11]
  m_br2:AddColumn(m_br1:GetColumn(12));a_get2[8]:=a_get1[12]
  m_br2:AddColumn(m_br1:GetColumn(13));a_get2[09]:=a_get1[13]
  m_br2:AddColumn(m_br1:GetColumn(14));a_get2[10]:=a_get1[14]
  m_br2:AddColumn(m_br1:GetColumn(15));a_get2[11]:=a_get1[15]
  m_br2:AddColumn(m_br1:GetColumn(16));a_get2[12]:=a_get1[16]
  l_pr2:={.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.}
  m_browse:=m_br1;l_print:=l_pr1;a_get:=a_get1
  DISPLAYLIST
  DO WHILE .t.
    m_browse:refReshCurrent()
    m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},"w/b")
    m_key:=0
    keyboard ""
    DO WHILE .NOT.(m_browse:stabilize()) .AND.((m_key:=inkey())==0)
    ENDDO
    IF m_browse:stabilize()
      m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},"w+/b")
      m_browse:ColorRect({m_browse:RowPos,m_browse:ColPos,m_browse:RowPos,m_browse:ColPos},"b/w")
    ENDIF
    IF m_key==0
      m_key:=INKEY(0)
    ENDIF
    Winsay
    DO CASE
      CASE m_key==K_ALT_1
        m_browse:=m_br1;l_print:=l_pr1;a_get:=a_get1
        m_browse:rowPos:=1;m_browse:Colpos:=1
        m_browse:configure();m_browse:gotop()
        /*
    CASE m_key==K_ALT_5   // тимчасова заглушка
      i:=Prov->(RECNO())
      Prov->(DBGOTOP())
      DO WHILE .NOT.Prov->(EOF())
            IF EMPTY(prov->kopr)
              IF LEFT(prov->crt,2)=="07"
                prov->kopr:="09"
              ENDIF
              IF LEFT(prov->crt,2)=="05"
                prov->kopr:="23"
              ENDIF
            ENDIF
        Prov->(DBSKIP())
      ENDDO
      Prov->(DBGOTO(i))
      m_browse:refreshAll()

*/
      CASE m_key==K_SH_F6
        ShftF6a(m_browse)
      SCAN  BROWSE m_browse KEY m_key
      SEARCH  BROWSE m_browse KEY m_key
      RANGE  BROWSE m_browse KEY m_key
      CONT SEARCH  BROWSE m_browse KEY m_key
    CASE m_key==K_ALT_2
        m_browse:=m_br2;l_print:=l_pr2;a_get:=a_get2
        m_browse:rowPos:=1;m_browse:Colpos:=1
        m_browse:configure();m_browse:gotop()
         CASE m_Key == K_DEL                                    /* удаление записи */
                  IF (ANSWERu( "Ви дiйсно бажаєте видалити строку ?" )==YES )
                  IF Prov->(NetRlock())
                     Prov->(dbdelete())
                     Prov->(Dbunlock())
                     Prov->(DBSKIP(1))
                     IF Prov->(EOF())
                      Prov->(DBSKIP(-1))
                    ENDIF
                     m_browse:RefreshAll()
                  ENDIF
                  ENDIF
      CASE m_key==K_ENTER
            STABILIZE BROWSE m_browse
            Prov->(DBGOTO(RECNO()))
            IF Prov->(NetRlock())
              a_get[m_browse:ColPos]:Row:=ROW()
              a_get[m_browse:ColPos]:Col:=COL()
              READMy({a_get[m_browse:ColPos]})
              prov->(dbUnlock())
            ENDIF

      DEAL BROWSE m_browse KEY m_key
      PRINT BROWSE m_browse KEY m_key
    CASE m_key=K_ALT_W

  OpenFp(m_bufpath)
  NET USE (m_bufpath+"fvnum.dbr") ALIAS fv  NEW
  IF MyLock1()
    DO WHILE .NOT. fp1->(EOF())
      IF fp1->oper=="N2".AND.fp1->ddoc>=m_ddoc1.AND.fp1->ddoc<=m_ddoc2.AND.fp1->npch==m_npch
        IF l_first
          IF ANSWERu("База вже мiстить проводки за отриману продукцiю;Удаляти цi документи?")<>YES
           EXIT
          ENDIF
          l_first:=.f.
        ENDIF
        DO WHILE fp2->(DS(fp1->vnum))
          fp2->(DBDELETE())
        ENDDO
        fp1->(DBDELETE())
      ENDIF
      fp1->(DBSKIP())
    ENDDO
    Prov->(DBGOTOP())
    m_kod:=SPACE(6);l1:=.t.
    m_gauge:=InitGauge("Занесення даних",2)
    DO WHILE .NOT.Prov->(EOF())
      IF prov->vdoc==1.OR.prov->vdoc==2
        Fp1->(DBAPPEND())
//        fp1->npch:="  850"
       fp1->npch:=m_npch
        fp1->ndoc:=prov->ndoc
        fp1->vnum:=STR(fv->vnum++,7)
        fp1->mnt :=mnt_dtod(prov->ddoc)
        fp1->ddoc:=prov->ddoc
        fp1->oper:="N2"
        fp1->tabn:=prov->tabn
        IF prov->vdoc==1   // Трактористи
           fp1->maket:="03" // Трактористи
           fp1->num:=prov->ntr
        ELSE
          fp1->maket:="02"   // Водiї
          fp1->num:=prov->gnavt
        ENDIF
        fp2->(DBAPPEND())
        fp2->vnum:=fp1->vnum
        fp2->dbt:=prov->dbt
        fp2->cod1:=prov->cod1
        fp2->kplh :=prov->kplh
        fp2->crt:=prov->crt
        fp2->cod2:=prov->cod2
        fp2->otp :=prov->otp
        fp2->kopr:=prov->kopr
        fp2->glv:=prov->glv
        fp2->kvo2:=prov->kvo2
        fp2->kvo:=prov->kvo
        fp2->stm:=prov->stm //полная стоимость
      ELSE
        IF m_kod<>Prov->ndoc
         Fp1->(DBAPPEND())
//         fp1->npch:="  850"
//        fp1->npch:="7"+STRZERO(MONTH(fp1->ddoc),2)+m_mol
       fp1->npch:=m_npch
         fp1->ndoc:=prov->ndoc
         fp1->vnum:=STR(fv->vnum++,7)
         fp1->mnt :=mnt_dtod(prov->ddoc)
         fp1->ddoc:=prov->ddoc
         fp1->oper:="N2"
         fp1->maket:="01"
         m_kod:=fp1->ndoc
        ENDIF
        fp2->(DBAPPEND())
        fp2->vnum:=fp1->vnum
        fp2->brgd1:=prov->brgd1
        fp2->brgd2:=prov->brgd2
        fp2->dbt:=prov->dbt
        fp2->cod1:=prov->cod1
        fp2->kplh :=prov->kplh
        fp2->crt:=prov->crt
        fp2->cod2:=prov->cod2
        fp2->otp :=prov->otp
        fp2->kopr:=prov->kopr
        fp2->glv:=prov->glv
        fp2->kvo2:=prov->kvo2
        fp2->kvo:=prov->kvo
        fp2->stm:=prov->stm //полная стоимость
      ENDIF
      Prov->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,prov->(RECNO()/LASTREC()))
    ENDDO
    DelGauge(m_gauge)
ENDIF
DBCOMMITALL()
  CLOSE fv
  CLOSE fp2
  CLOSE fp1
  SELECT prov
  m_browse:goTop()
  m_browse:refreshAll()
 ENDCASE
  ENDDO
   SAVEPAR(1)
RETURN .t.
FUNCTION DispProv(var)
local m_screen,i:=0,j:=0,n_menu:=1,m_str,n_win
LOCAL x:=4,y:=1,a_dir:=DIRECTORY(m_platpath+"prov??.dbf")
local m_browse,m_col,m_key,a_choice:={},n,m_row:=1,m_skip
LOCAL s_files:={}
SopenFiles("100",@s_files)
n:=LEN(a_dir)
FOR i:=n TO 1 STEP -1
  m_str:=FILESTR(m_platpath+a_dir[i][1],22,a_dir[i][2]-22)
  IF RIGHT(m_str,2)<>"ьь"
   ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
  ENDIF
NEXT
n:=LEN(a_dir)
FOR i:=1 TO n
  m_str:=FILESTR(m_platpath+a_dir[i][1],22,a_dir[i][2]-22)
  AADD(a_choice,;
  {LEFT("Рух продукцiї по МВО "+LEFT(m_str,2)+" "+ALLTRIM(_mol(LEFT(m_str,2)));
   +" за перiод з "+SUBSTR(m_str,5,8)+" по "+SUBSTR(m_str,13,8),65),m_str})
NEXT
IF LEN(a_dir)==0
  DispError("Масива проводок не знайдено")
  RETURN .f.
ENDIF
n:=LEN(a_dir)
m_screen:=SAVESCREEN (x,y ,x+20,y+76)
@x,y,x+18,y+74 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ("n/bg")
@x,y+2 SayDisp 'Перелiк звiтiв про рух' COLOR "w+/Bg"
SHADOW(x,y,x+18,y+74 )
m_browse:=TBrowseNew(x+1,y+1,x+17,y+73)
m_browse:colorspec:='N/BG,B/W,w+/b*'
m_browse:colsep        := '│'
m_browse:skipBlock:={|m_count|;
m_skip:=IF(m_count>=0,;
IF(m_row+m_count>n,n-m_row,m_count),;
IF(m_row+m_count>=1,m_count,-m_row+1)),m_row+=m_skip,m_skip}
m_browse:goBottomBlock := { ||m_row:=n}
m_browse:goTopBlock    := { ||m_row:=1}
m_col:=TBColumnNew()
m_col:block:={||REM01(a_choice[m_row][1])}
m_col:heading:="Назва звiту"
m_Col:colorblock:=  {||{1,2}}
m_Col:headsep    := "┬─";m_col:colsep:="│"
m_col:width:=70
m_browse:addColumn(m_col)
DO WHILE .t.
  IF LEN(a_choice)==0
    EXIT
  ENDIF

STABILIZE BROWSE m_browse
m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{3,3})
m_key:=Inkey(0)
m_browse:ColorRect({m_browse:RowPos,1,m_browse:RowPos,m_browse:colCount},{1,1})
DO CASE
  CASE m_key==K_DEL.AND.ANSWERu("Видалити звiт?")==YES
    FERASE(m_platpath+a_dir[m_row][1])
    ADEL(a_dir,m_row);ASIZE(a_dir,LEN(a_dir)-1)
    ADEL(a_choice,m_row);ASIZE(a_choice,LEN(a_choice)-1)
    IF m_row>LEN(a_dir)
      m_row:=LEN(a_dir);m_browse:rowPos:=m_browse:rowPos-1;m_browse:configure()
    ENDIF
    n:=n-1
    IF n==0
      EXIT
    ENDIF
    m_browse:RefreshAll()
  CASE m_key==K_ESC
    EXIT
  CASE m_key==K_UP
    m_browse:up();m_browse:refreshCurrent()
  CASE m_key==K_DOWN
    m_browse:down();m_browse:refreshCurrent()
  CASE m_key==K_ENTER
    USE (m_platpath+a_dir[m_row][1]) ALIAS Prov NEW
    Zanes02(SUBSTR(a_choice[m_row,2],1,2),SUBSTR(a_choice[m_row,2],3,2),;
    CTOD(SUBSTR(a_choice[m_row,2],5,8)),CTOD(SUBSTR(a_choice[m_row,2],13,8)))
    CLOSE prov
    STRFILE(a_choice[m_row,2],m_platpath+a_dir[m_row][1],.t.)
ENDCASE
ENDDO
RESTSCREEN(x,y ,x+20,y+76,m_screen)
ScloseFile(s_files)
RETURN .t.
/*
Function TestProv
  USE (m_temppath+"prov") NEW
  Zanes02("05","52",CTOD("01/09/98"),CTOD("30/09/98"))
  CLOSE Prov
RETURN .t.
*/
STATIC Function Zanes03(m_dbt,m_cod1,m_brgd1,l_stm,m_kopr,a_tabl)
LOCAL m_prise,m_stm
LOCAL a_prov:={}
IF m_brgd1<>NIL;Prov->brgd1:=m_brgd1;ENDIF
IF m_kopr<>NIL;Prov->kopr:=m_kopr;ENDIF
IF LEFT(m_dbt,2)=="79" // реализация
  Prov->dbt:=GetSchet90(m_dbt,a_tabl)
ELSE
  Prov->dbt:=m_dbt
ENDIF
Prov->cod1:=m_cod1
IF nakl2->st==" " // таксировка  стоимости списания
  buf1->(DS(Nakl2->kod))
  m_prise:=IF((buf1->Dkvo+buf1->inkvo)<>0,(buf1->insum+buf1->Dsum)/(buf1->Dkvo+buf1->inkvo),0)
  Prov->stm:=m_prise*nakl2->kvo
  IF Nakl2->(NetRlock())
    Nakl2->stm1:=Prov->stm
    IF l_stm
      Nakl2->stm:=Prov->stm
      IF nakl2->kvo<>0
        Nakl2->prise:=Nakl2->stm/nakl2->kvo
      ENDIF
    ENDIF
    Nakl2->(dbUnlock())
  ENDIF
ELSE
  Prov->stm:=Nakl2->stm1 // Ручное списание
ENDIF
IF LEFT(m_dbt,2)=="79" // реализация
  a_prov:={;
  prov->ndoc,prov->kopr,prov->type,; // 1,2,3
  prov->dbt,prov->crt,prov->cod1,prov->cod2,; // 4,5,6,7
  prov->glv,prov->kvo2,prov->kvo,prov->stm,; // 8,9,10,11
  prov->ddoc,prov->ndoc1,prov->vdoc}
  Prov->(DBAP())    // Вторая проводка на 79
  prov->ndoc :=a_prov[ 1]
  prov->kopr :=a_prov[ 2]
  prov->type :=a_prov[ 3]
  prov->dbt  :=m_dbt
  prov->crt  :=a_prov[ 4]
  prov->cod1 :=a_prov[ 6]
  prov->cod2 :=a_prov[ 6] // Дублирование кода
  prov->glv  :=a_prov[ 8]
  prov->kvo2 :=a_prov[ 9]
  prov->kvo  :=a_prov[10]
  prov->stm  :=a_prov[11]
  prov->ddoc :=a_prov[12]
  prov->ndoc1:=a_prov[13]
  prov->vdoc :=a_prov[14]
ENDIF
RETURN .T.
Function ZakrPer
  LOCAL m_file1,m_file2,m_gauge,a_struct:={}
  LOCAL m_mol:="  ",m_ddoc1:=CTOD(""),m_ddoc2:=CTOD("")
  LOCAL l_kvo2:=.f.,i,j,k,m_key,GetList:={},s1,s3
  LOCAL n_win,m_screen,l_filter:=.f.,s2:="",n,l_doc:=.f.
  LOCAL n_file1,n_file2,n_kapt,n_file3,m_mnt:="    ",m_mnt2
  LOCAL m_message,m001,n01
  NET USE (m_platpath+"memvar") INDEX (m_platpath+"memvar") NEW ALIAS myvar
  m_mnt:=RestVar1("m_mnt1","NK")
  CLOSE myvar
IF .not.GetPer(m_mnt)
  RETURN .f.
ENDIF
m_mnt2:=mnt_inc(m_mnt)
m_ddoc1:=CTOD("01/"+RIGHT(m_mnt,2)+"/"+left(m_mnt,2))
m_ddoc2:=EOM(m_ddoc1)
m_message := DispMessage("Закриваю розрахунковий перiод;з "+dtoc(m_ddoc1)+" по "+dtoc(m_ddoc2))
IF NETDISK(LEFT(m_platpath,1))
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  s2+=m_file1+","
  FILECOPY(m_platpath+"nakl1.dbf",m_file1)
  USE (m_file1) NEW READONLY ALIAS file1
  n_file1:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_platpath+"nakl2.dbf",m_file1)
  m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
  s2+=m_file1+","+m_file2+","
  FILECOPY(m_platpath+"nakl2.ntx",m_file2)
  USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS File2
  n_file2:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_platpath+"kaptka1.dbf",m_file1)
  m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
  FILECOPY(m_platpath+"kaptka1.ntx",m_file2)
  s2+=m_file1+","+m_file2+","
  USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS KAPTKA
  n_kapt:=SELECT()
ELSE
  OPenFl1()
  n_file1:=SELECT("NAKL1")
  n_file2:=SELECT("NAKL2")
  n_kapt:=SELECT("KAPTKA1")
ENDIF
NET USE (m_platpath+"spr03.dbf") NEW  ALIAS File3
n_file3:=SELECT()

a_struct:=File3->(dbstruct())
n01:=LEN(a_struct)
m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
DBCREATE(m_file1,a_struct)
USE (m_file1) NEW ALIAS buf
m001:=m_file1
m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
INDEX ON field->mol+field->kod TO (m_file2)
s2+=m_file1+","+m_file2
m_gauge:=InitGauge("Вибiрка сальдо",2)
DO WHILE .NOT.(n_file3)->(EOF())
  IF mnt_dtod(m_ddoc1)==(n_file3)->mnt
    buf->(DS((n_file3)->mol+(n_file3)->kod))
    IF .NOT.BUF->(FOUND())
      buf->(DBAP())
      buf->kod:=(n_file3)->kod
      buf->mol:=(n_file3)->mol
      buf->mnt:=m_mnt2
    ENDIF
    buf->kvo+=(n_file3)->kvo
    buf->glv+=(n_file3)->glv
    buf->stm+=(n_file3)->stm
  ENDIF
  (n_file3)->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,(n_file3)->(RECNO())/(n_file3)->(LASTREC()))
ENDDO
DelGauge(m_gauge)
NET USE (m_platpath+"NAKL5") new
m_gauge:=InitGauge("Вибiрка даних по переводу ",2)
DO WHILE .NOT.nakl5->(EOF())
  IF nakl5->ddoc>=m_ddoc1.AND.nakl5->ddoc<=m_ddoc2
    buf->(DS(nakl5->mol+nakl5->cod1))
    IF .NOT.BUF->(FOUND())
      buf->(DBAP())
      buf->kod:=nakl5->cod1
      buf->mol:=nakl5->mol
      buf->mnt:=m_mnt2
    ENDIF
    buf->kvo-=nakl5->kvo
    buf->glv-=nakl5->glv
    buf->stm-=nakl5->stm
    buf->(DS(nakl5->mol+nakl5->cod2))
    IF .NOT.BUF->(FOUND())
      buf->(DBAP())
      buf->kod:=nakl5->cod2
      buf->mol:=nakl5->mol
      buf->mnt:=m_mnt2
    ENDIF
    buf->kvo+=nakl5->kvo
    buf->glv+=nakl5->glv
    buf->stm+=nakl5->stm
  ENDIF
  nakl5->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,NAKL5->(RECNO()/LASTREC()))
ENDDO
CLOSE nakl5
DelGauge(m_gauge)
m_gauge:=InitGauge("Вибiрка iнформацiї з накладних",2)
(n_file1)->(DBGOTOP())
DO WHILE .NOT.(n_file1)->(EOF())
    IF (n_file1)->ddoc3>=m_ddoc1.AND.(n_file1)->ddoc3<=m_ddoc2.AND..not.IsBit(ASC((n_file1)->state),3).AND.IsBit(ASC((n_file1)->state),2)
        (n_file2)->(DS((n_file1)->vnum))
        DO WHILE .NOT.(n_file2)->(EOF()).AND.(n_file2)->vnum==(n_file1)->vnum
            buf->(DS((n_file1)->otp+(n_file2)->kod))
            IF .NOT.BUF->(FOUND())
              buf->(DBAP())
              buf->kod:=(n_file2)->kod
              buf->mol:=(n_file1)->otp
              buf->mnt:=m_mnt2
            ENDIF
            IF (n_file1)->vdoc>="1"
              buf->kvo-=(n_file2)->kvo
              buf->glv-=(n_file2)->glv
              buf->stm-=(n_file2)->stm1
              IF (n_file1)->kod1="М "
                buf->(DS((n_file1)->mol+(n_file2)->kod))
                IF .NOT.BUF->(FOUND())
                  buf->(DBAP())
                  buf->kod:=(n_file2)->kod
                  buf->mol:=(n_file1)->mol
                  buf->mnt:=m_mnt2
                ENDIF
                buf->kvo+=(n_file2)->kvo
                buf->glv+=(n_file2)->glv
                buf->stm+=(n_file2)->stm
              ENDIF
            ELSE
                buf->kvo+=(n_file2)->kvo
                buf->glv+=(n_file2)->glv
                buf->stm+=(n_file2)->stm
            ENDIF
          (n_file2)->(DBSKIP())
        ENDDO
  ENDIF
  (n_file1)->(DBSKIP())
  m_gauge:=DispGauge(m_gauge,(n_file1)->(RECNO())/(n_file1)->(LASTREC()))
ENDDO
DelGauge(m_gauge)
File3->(Flock())

File3->(DBGOTOP())
DO WHILE .NOT.File3->(EOF())
  IF  file3->mnt==m_mnt2
    File3->(DBDELETE())
  ENDIF
  File3->(DBSKIP())
ENDDO


buf->(DBGOTOP())
DO WHILE .NOT.buf->(EOF())
  File3->(DBAP())
  FOR i:=1 TO n01
    file3->(FIELDPUT(i,buf->(FIELDGET(i))))
  NEXT
  buf->(DBSKIP())
ENDDO

CLOSE BASE buf
// SELE file3
// APPEND FROM (M001)
file3->(dbUnlock())
IF NETDISK(LEFT(m_platpath,1))
 CLOSE BASE file1,File2,File3,Kaptka
ELSE
 CLOSE file3
 CloseFl1()
ENDIF
/*
n:=NumToken(s2,",")
FOR i:=1 TO n
  FERASE(TOKEN(s2,",",i))
NEXT
NET USE (m_platpath+"memvar") INDEX (m_platpath+"memvar") NEW ALIAS myvar
  SaveVar1("m_mnt1",m_mnt2,"NK")
CLOSE myvar
*/
RETURN .t.
STATIC Function Getper(m_mnt)
LOCAL s1:=MyCmonth(VAL(RIGHT(m_mnt,2)))+" 19"+LEFT(m_mnt,2),i
  i:=ALERT("Закривати перiод ?",{"Вiдмова",s1},"w+/bg,gr+/w")
  DO CASE
    CASE i==0.or.i==1
      return .f.
    CASE i==2
      Return .t.
  ENDCASE
RETURN .f.
STATIC Function ZanNds(a_tabl)
LOCAL m_ksash:=GetSchet70(Kaptka1->ksash2,a_tabl)
IF Nakl2->nds<>0
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=nakl1->ddoc3
  Prov->kopr:=GetNdsKopr()
  Prov->crt:=GetNdsKsash(Kaptka1->ksash2)
//  Prov->crt:=m_680000
  Prov->dbt:=m_ksash
  Prov->cod1:=Nakl2->kod
  Prov->stm:=nakl2->nds
ENDIF
RETURN .T.
STATIC FUNCTION ZanPred(a_tabl)
// Проводка по предприятию
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=nakl1->ddoc3
  Prov->kopr:=Spr01->kpr
  Prov->cod1:=Nakl1->okpo
  Prov->cod2:=Nakl2->kod
  SetKvo()
  Prov->otp :=nakl1->otp
  Prov->dbt :="36"+SUBSTR(SetFirmKsash(nakl1->okpo),3)
  Prov->crt :=GetSchet70(Kaptka1->ksash2,a_tabl)
  prov->stm :=Nakl2->stm+Nakl2->nds
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=nakl1->ddoc3
  Prov->kopr:=Spr01->kpr
  Prov->cod1:=Nakl2->kod
  Prov->cod2:=Nakl1->okpo
  SetKvo()
  Prov->otp :=nakl1->otp
  Prov->dbt :=GetSchet70(Kaptka1->ksash2,a_tabl)
  Prov->crt :=Kaptka1->ksash2
  prov->stm :=Nakl2->stm

RETURN .t.
STATIC FUNCTION ZanPens(m_pension,a_tabl)
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=nakl1->ddoc3
  Prov->kopr:=Spr01->kpr
  Prov->cod2:=Nakl2->kod
  SetKvo()
  Prov->otp :=nakl1->otp
  Prov->dbt :=m_pension
  Prov->crt :=Kaptka1->ksash2
  prov->stm :=Nakl2->stm+nakl2->nds
RETURN .t.
STATIC FUNCTION ZanPred0() // Занесение реквизитов предприятия в кредит
  Prov->crt:="63"+SUBSTR(SetFirmKsash(nakl1->okpo),3);Prov->cod2:=Nakl1->okpo
RETURN .t.
STATIC FUNCTION ZanTabn()
  Prov->crt:="372"
  Prov->cod2:=Nakl1->tabn
RETURN .t.
STATIC FUNCTION ZanPerson()
  Prov->crt:="6854000"
  Prov->cod2:=Nakl1->codn
RETURN .t.
STATIC FUNCTION ZanPod()
  Prov->crt:="372"
  Prov->cod2:=nakl1->tabn
RETURN .t.
STATIC Function ZanNds0()
IF Nakl2->nds<>0
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=nakl1->ddoc3
  Prov->kopr:=GetNdsKopr()
  Prov->dbt:=GetNdsDbt()
//  Prov->crt:=SetFirmKsash(nakl1->okpo)
  Prov->crt:="63"+SUBSTR(SetFirmKsash(nakl1->okpo),3);Prov->cod2:=Nakl1->okpo
  Prov->cod2:=Nakl1->okpo
  Prov->cod1:=Nakl2->kod
  Prov->stm:=nakl2->nds
ENDIF
RETURN .T.
STATIC Function ZanNds1()
IF Nakl2->nds<>0
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=nakl1->ddoc3
  Prov->kopr:=GetNdsKopr()
  Prov->dbt:=GetNdsDbt()
  Prov->crt:="372"
  Prov->cod2:=Nakl1->tabn
  Prov->cod1:=Nakl2->kod
  Prov->stm:=nakl2->nds
ENDIF
RETURN .T.
STATIC Function ZanNds2()
IF Nakl2->nds<>0
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=nakl1->ddoc3
  Prov->kopr:=GetNdsKopr()
  Prov->dbt:=GetNdsDbt()
//  Prov->kopr:=k_nds
//  Prov->dbt:=m_680000
  Prov->crt:=Nakl1->ksash
  Prov->cod2:=Nakl1->tabn
  Prov->cod1:=Nakl2->kod
  Prov->stm:=nakl2->nds
ENDIF
RETURN .T.
Function ShftF6a(m_browse)
LOCAl m_ndoc:=BLANK(prov->ndoc,.t.),;
m_recno:=prov->(RECNO()),;
m_screen:=SaveScreen(13,10,15,52),GetList:={}
// ВВести номер документа
SET ESCAPE ON
@13,10,15,52 BOX B_DOUBLE+" " COLOR "w+/BG"
@13,12 SayDisp " Введiть номер документа " COLOR "GR+/BG"
@14,12 Get m_ndoc VALID (m_ndoc:=JustRight(m_ndoc),.t.) COLOR "GR+/N"
READ
RestScreen(13,10,15,52,m_screen)
IF LASTKEY()<>K_ESC
    m_recno:=prov->(RECNO())
    prov->(DBEVAL({||.t.},,{||(m_ndoc<>prov->ndoc)},,,))
    IF .NOT.prov->(EOF())
      m_browse:rowPos:=1;m_browse:Configure();m_browse:RefreshAll()
    ELSE
      prov->(DBGOTO(m_recno))
      DispError("Документ N "+m_ndoc+" не знайден")
    ENDIF
ENDIF
RETURN .t.
STATIC FUNCTION OpenFp(m_path)
LOCAL l_index :=.f.
IF MoreNew(m_path+"Fp1.dbf",m_path+"Fp1.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp1.dbf",m_path+"Fp1a.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp2.dbf",m_path+"Fp2.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp2.dbf",m_path+"Fp2a.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp2.dbf",m_path+"Fp2b.ntx");l_index:=.t.;ENDIF
IF MoreNew(m_path+"Fp2.dbf",m_path+"Fp2c.ntx");l_index:=.t.;ENDIF
IF l_index
  Reindex(m_path)
ENDIF

  NET USE (m_path+"Fp1") INDEX (m_path+"Fp1"),(m_path+"Fp1a")  NEW
  DBSETORDER(1)
  NET USE (m_path+"Fp2") INDEX (m_path+"Fp2"),(m_path+"Fp2a"),(m_path+"Fp2b"),(m_path+"Fp2c")  NEW
  DBSETORDER(1)
return .t.
STATIC FUNCTION MoreNew(m_file1,m_file2)
IF FILEDATE(m_file1)>FILEDATE(m_file2)
  return .t.
ELSE
 IF FILEDATE(m_file1)==FILEDATE(m_file2).AND.;
     FILETIME(m_file1)>FILETIME(m_file2)
    return .t.
 ENDIF
ENDIF
RETURN .F.
Function Reindex(Var)
  LOCAL  m_path:=var
  LOCAL m_gauge,m_message
  IF .NOT.EMPTY(var)
    m_path:=Var
  ENDIF
  m_message:=DispMessage("Iндексацiя "+IF(m_path!=m_bufpath,"основної",;
  IF(m_path==m_bufpath,"буферної",""))+";бази даних ")
  m_gauge:=InitGauge("Iндексацiя",2)
  NET USE (m_path+"Fp1") NEW
  IF Fp1->(NETFlock())
    DispGauge(m_gauge,0.05)
    INDEX ON Fp1->Npch+Fp1->ndoc TO  (m_path+"Fp1a")
    INDEX ON Fp1->vnum TO  (m_path+"Fp1")
    DispGauge(m_gauge,0.1)
    NET USE (m_path+"Fp2")  NEW
      IF Fp2->(NETFlock())
        SET RELATION TO Fp2->vnum INTO Fp1
        INDEX ON Fp2->vnum TO (m_path+"Fp2")
        DispGauge(m_gauge,0.25)
        INDEX ON Fp1->npch+Fp1->ndoc+Fp2->vnum TO (m_path+"Fp2a")
        DispGauge(m_gauge,0.5)
        INDEX ON Fp2->dbt+Fp2->cod1+Fp2->crt+Fp2->cod2 TO (m_path+"Fp2b")
        DispGauge(m_gauge,0.75)
        INDEX ON Fp2->crt+Fp2->cod2+Fp2->dbt+Fp2->cod1 TO (m_path+"Fp2c")
        DispGauge(m_gauge,1.0)
      ELSE
        DelGauge(m_gauge)
        Fp1->(DBUNLOCK())
        CLOSE BASE Fp1,Fp2
        DelMessage(m_message)
        RETURN .f.
     ENDIF
  ELSE
    DelGauge(m_gauge)
    CLOSE BASE Fp1
    DelMessage(m_message)
    RETURN .f.
  ENDIF
  DelGauge(m_gauge)
  Fp1->(DBUNLOCK());Fp2->(DBUNLOCK())
  CLOSE BASE Fp1,Fp2
  DelMessage(m_message)
RETURN .t.
STATIC FUNCTION GetSchet70(m_ksash,a_tabl)
LOCAL i:=ASCAN(a_tabl,{|x|x[2]==LEFT(m_ksash,4)})
IF i==0
  RETURN "7000"+RIGHT(m_ksash,3)
ENDIF
RETURN a_tabl[i,3]+RIGHT(m_ksash,3)
STATIC FUNCTION GetSchet90(m_ksash,a_tabl)
LOCAL i:=ASCAN(a_tabl,{|x|x[2]==LEFT(m_ksash,4)})
IF i==0
  RETURN "9000"+RIGHT(m_ksash,3)
ENDIF
RETURN a_tabl[i,1]+RIGHT(m_ksash,3)
STATIC FUNCTION GetSchet79(m_ksash,a_tabl)
LOCAL i:=ASCAN(a_tabl,{|x|x[2]==LEFT(m_ksash,4)})
IF i==0
  RETURN "9000"+RIGHT(m_ksash,3)
ENDIF
RETURN a_tabl[i,2]+RIGHT(m_ksash,3)
Function RestVar(m_name)
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
STATIC FUNCTION SetKvo()
    Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
    IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
      Prov->glv:=nakl2->glv
    ELSE
      Prov->kvo2:=nakl2->glv
    ENDIF
RETURN .T.
STATIC FUNCTION SetFirmKsash(m_okpo)
                  Firm01->(DBSETORDER(2))
                  Firm01->(DS(m_okpo))
                  Firm01->(DBSETORDER(1))
RETURN firm01->ksash
