#include "buh.ch"
#command NET USE <(db)> [ALIAS <a>] [<new: NEW>] [<ro: READONLY>] [INDEX <(index1)> [, <(indexn)>]]  ;
      => NetUse(<.new.>,, <(db)>, <(a)>, <.ro.>)                 ;
      [; dbSetIndex( <(index1)> )]                               ;
      [; dbSetIndex( <(indexn)> )]

STATIC c_disk:=" "
#DEFINE   HIGHER 10
#DEFINE   M_ROWFIRST INT((MAXROW()-m_high)/2)+i
#DEFINE   M_COLFIRST INT((MAXCOL()-m_width)/2)+i
/*
#define COLOR_NORM  1
#define COLOR_HIGH  2
#define COLOR_TITEL 3
#define COLOR_TABL  4

#define MONO1  "W/N"
#define MONO2  "+W/N"
#define MONO3  "N/W"
#define MONO4  "+W/N"
#define COLOR1 "+W/BG"
#define COLOR2 "+G/BG"
#define COLOR3 "+RG/BG"
#define COLOR4 "+W/W"
*/
MEMVAR m_workpath,m_sprpath,m_syspath,m_bufpath,m_platpath
STATIC k_nds1,k_nds2,k_nds3,k_ndsDbt
STATIC k_ndsKopr,m_nds,s_nds1,s_nds2
FUNCTION CopyKass1
  LOCAL i,m_size,m_ddoc,a_dir:={},m_str,m_set,;
        l_fks04:=.f.,l_fks02:=.f.,m_prc,m_copy:=1
    DO WHILE .t.
    IF ANSWER("Копировать данные на дискету")==YES
      c_disk:=GetFloppy()
      IF UPPER(c_disk)>="A"
        /* СПИСОК ФАЙЛОВ ДЛЯ КОПИРОВАНИЯ */
        // fks02,fks03,fks04,fksp**,Fksd**
        IF SELECT("fks04")==0
           USE (m_workpath+"fks04") NEW
           l_fks04:=.t.
        ENDIF
        m_ddoc:=SUBSTR(DTOC(fks04->ddoc),7,2)+SUBSTR(DTOC(fks04->ddoc),4,2)+SUBSTR(DTOC(fks04->ddoc),1,2)
        If l_fks04
          CLOSE fks04
        ENDIF
        IF SELECT("fks02")==0
          USE (m_workpath+"fks02") NEW
          l_fks02:=.t.
        ENDIF
        fks02->(DBGOTOP())
        fks02->(DBEVAL({||AADD(a_dir,{UPPER(ALLTRIM(fks02->name))+".DBF",fks02->month})}))
        IF l_fks02
          CLOSE fks02
        ENDIF
        m_size:=FILESIZE(m_workpath+"FKS02.DBF")+ FILESIZE(m_workpath+"FKS03.DBF")+FILESIZE(m_workpath+"FKS04.DBF")+FILESIZE(m_workpath+"FKS07.DBF")
        AEVAL(a_dir,{|x|m_size+=FILESIZE(m_workpath+x[1])})
        DO WHILE .T.
          i:=NextDisk(c_disk)
          IF .NOT.i
            RETURN .F.
          ENDIF
          IF DISKFREE(c_disk)<m_size+3000
              WaitMessage("На дискетте нет свободного места;Втавьте следующую дискетту","GR+/R,w+/r",.T.)
              LOOP
          ENDIF
          EXIT
        ENDDO
        IF i
          m_str:=DispMessage("Копирование данных на дискетту "+c_disk)
          m_prc := InitGauge(" Копирование данных на дискету",2)
//          WorkWindow(m_prc)
          m_set:=SSETVERIFY(.T.)
          FILECOPY(m_workpath+"fks03.DBF",c_disk+":\"+m_ddoc+"k3.dbf")
          m_copy+=FILESIZE(m_workpath+"fks03.DBF")
          DispGauge(m_prc,m_copy/m_size)
          FILECOPY(m_workpath+"fks02.DBF",c_disk+":\"+m_ddoc+"k2.dbf")
          m_copy+=FILESIZE(m_workpath+"fks02.DBF")
          DispGauge(m_prc,m_copy/m_size)
          FILECOPY(m_workpath+"fks04.DBF",c_disk+":\"+m_ddoc+"k4.dbf")
          m_copy+=FILESIZE(m_workpath+"fks04.DBF")
          DispGauge(m_prc,m_copy/m_size)
          FILECOPY(m_workpath+"fks07.DBF",c_disk+":\"+m_ddoc+"k7.dbf")
          m_copy+=FILESIZE(m_workpath+"fks07.DBF")
          DispGauge(m_prc,m_copy/m_size)
          AEVAL(a_dir,;
          {|x|;
           FILECOPY(m_workpath+x[1],;
           c_disk+":\"+IF(LEFT(x[1],4)=="FKSP",m_ddoc+x[2]+"."+SUBSTR(x[1],5,2)+"P",;
           m_ddoc+"."+SUBSTR(x[1],5,3))),;
           m_copy+=FILESIZE(m_workpath+x[1]),;
            DispGauge(m_prc,m_copy/m_size)})
          SSETVERIFY(m_set)
          DelMessage(m_str)
          IF ALERT("Повторить копирование;на другую дискету?",{"Нет","Да"},"n/bg,w/b")<2
            RETURN .f.
          ENDIF
          DelGauge(m_prc)
        ENDIF
      ELSE
        RETURN .f.
      ENDIF
    ELSE
      EXIT
    ENDIF
    ENDDO
RETURN .t.
STATIC FUNCTION NextDisk(c_disk)
  LOCAL m_str
  DO WHILE .T.
    WaitMessage("Вставьте дискетту в дисковод "+c_disk+";и нажмите любую клавишу",,.T.)
    DO WHILE .NOT.DISKREADY(c_disk)
      IF INKEY()==K_ESC
        IF ALERT("Прервать копирование;Вы уверенны ?",{"Да","Нет"})==1
          RETURN .F.
        ENDIF
      ENDIF
    ENDDO
    IF .NOT.DISKREADYW(c_disk)
      WaitMessage("ДИСКЕТТА защищена от записи;Замените дискетту",,.T.)
      KEYBOARD " "
      LOOP
    ENDIF
    EXIT
  ENDDO
RETURN .T.
STATIC FUNCTION GetFloppy()
  LOCAL a_choice:={},i
  FOR i:=1 TO NUMDISKF()
    AADD(a_choice,STR(i,1)+" Дисковод "+CHR(ASC("A")-1+i))
  NEXT
RETURN(CHR(ASC("A")-1+my_menu("Выбор дисковода",a_choice)))
STATIC Function My_Menu(m_name,a_choice,m_count,l_clear)
  LOCAL m_WIDTH:=0,m_high,m_screen,m_key,i:=IF(m_count==NIL,0,m_count),;
  l_restore:=IF(l_clear==NIL,.t.,l_clear)
  AADD(a_choice,NIL)
  AINS(a_choice,1)
  a_choice[1]:="0 Выход"
  AEVAL(a_choice,{|p|IF(LEN(p)>m_width,m_width:=LEN(p),NIL)})
  IF(LEN(m_name)>m_width,m_width:=LEN(m_name),NIL)
  IF(LEN(a_choice)>HIGHER,m_high:=HIGHER,m_high:=LEN(a_choice))
  m_screen:=SAVESCREEN(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1+1,M_COLFIRST+m_width+1+2)
  @M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1,M_COLFIRST+m_width+1 ;
  BOX B_DOUBLE_SINGLE+SPACE(1) COLOR (VVOD_CLR)
  @M_ROWFIRST-1,M_COLFIRST SayDisp m_name COLOR (HEAD_CLR)
  SHADOW(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1,M_COLFIRST+m_width+1)
  SETCOLOR(MNU_CLR)
  m_key:=ACHOICE(M_ROWFIRST,M_COLFIRST,M_ROWFIRST+m_high,M_COLFIRST+m_width,a_choice)
  ADEL(a_choice,1)
  ASIZE(a_choice,LEN(a_choice)-1)
  IF(l_restore,RESTSCREEN(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1+1,M_COLFIRST+m_width+1+2,m_screen),NIL)
  RETURN( IF(m_key==1.OR.m_key==AC_ABORT,0,m_key-1))

FUNCTION My_Format(c_dsk)
  LOCAL x,a_choice:={},c_disk
  clearwin(0,0,maxrow(),maxcol(),"n/w","░")
  IF EMPTY(c_dsk)
    c_disk:=GetFloppy()
    IF c_disk=="@"
      RETURN .F.
    ENDIF
  ELSE
    c_disk:=c_dsk
  ENDIF
  DO Case
    CASE FLOPPYTYPE(c_disk)==1
      x:=DF(c_disk,360,.F.)
    CASE FLOPPYTYPE(c_disk)==2
      a_choice:={"360","720","1200"}
      x:=My_menu("Емкость дисковода",a_choice)
      IF x==0
        RETURN .F.
      ENDIF
      x:=VAL(a_choice[x])
      x:=DF(c_disk,x,.F.)
    CASE FLOPPYTYPE(c_disk)==3
      x:=DF(c_disk,360,.F.)
    CASE FLOPPYTYPE(c_disk)==4
      a_choice:={"720","1440"}
      x:=My_menu("Емкость дисковода",a_choice)
      IF x==0
        RETURN .F.
      ENDIF
      x:=VAL(a_choice[x])
      x:=DF(c_disk,x,.F.)
    OTHERWISE
      RETURN .F.
  EndCASE
  IF x==0
    RETURN .T.
  ENDIF
  RETURN .F.
STATIC FUNCTION InsDisk(c_disk)
  LOCAL m_str
    WaitMessage("Вставьте дискетту в дисковод "+c_disk+";и нажмите любую клавишу",,.T.)
    DO WHILE .NOT.DISKREADY(c_disk)
      IF INKEY()==K_ESC
        IF ALERT("Прервать копирование;Вы уверенны ?",{"Да","Нет"})==1
          DelMessage(m_str)
          RETURN .F.
        ENDIF
      ENDIF
    ENDDO
RETURN .T.
#command DISPERROR(<var1>,<var2>) => n_error++  ;;
        DEVPOS(PROW()+1,0) ;;
        DEVOUT("Ошибка ! Ордер N "+STR(fks03->ndoc,3)) ;;
        DEVPOS(PROW(),PCOL()+2) ;;
        DEVOUT(<var1>) ;;
        DEVPOS(PROW(),PCOL()+2) ;;
        DEVOUT(<var2>)

#command DISPWARNING(<var1>,<var2>) =>  n_warning++ ;;
        DEVPOS(PROW()+1,0) ;;
        DEVOUT("Предупреждение ! Ордер N "+STR(fks03->ndoc,3)) ;;
        DEVPOS(PROW(),PCOL()+2) ;;
        DEVOUT(<var1>) ;;
        DEVPOS(PROW(),PCOL()+2) ;;
        DEVOUT(<var2>)

FUNCTION  D_copy_main
LOCAL m_saldo,m_file,a_plved:={},a_kved:={},m_screen,l_append,m_prc1,;
      i:=0,m_vdoc:=0,;
      m_kopr1,m_size:=0,a_file:={},m_ddoc,c_disk,n_warning:=0,n_error:=0,;
      m_prc,m_ksash1,m_kopr2,m_log,m_sum,m_scht,x1,m_kopr,m_ndoc,m_ssuda:="340"
i:=ALERT("Выполнять учет кассы;Вы уверены?",{"Да","Нет"},"n/w,n/bg")
IF i<>1
  RETURN .f.
ENDIF
NET USE (m_workpath+"inst1") INDEX  (m_workpath+"inst1") new ALIAS myvar
RESTMEM m_ssuda
CLOSE myvar

/*
USE (m_workpath+"inst1") INDEX  (m_workpath+"inst1") new ALIAS myvar
RESTMEM m_okrugl
CLOSE myvar */
USE (m_workpath+"fks02") INDEX (m_workpath+"fks02") NEW
USE (m_workpath+"fks03") NEW
USE (m_workpath+"fks04") NEW
USE (m_workpath+"fks05") NEW
USE (m_workpath+"fks06") INDEX (m_workpath+"fks06") NEW
ZAP
REINDEX

m_ddoc:=RIGHT(DTOS(fks04->ddoc),6)
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10") READONLY NEW
NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44") READONLY NEW
USE (m_workpath+"fks07") INDEX (m_workpath+"fks07") READONLY NEW


CLEARWIN(1,0,MAXROW(),MAXCOL(),'N/W','░')
m_prc := InitGAUGE(" Проверка кассовой книги")
// WorkWindow(m_prc)
OpenPrn(m_workpath+"check.lst")
i:=1
@0,0 Say "=================== ПРОВЕРКА КАССОВОЙ КНИГИ ЗА "+DTOC(fks04->ddoc)+"==================="
DO WHILE .NOT.fks03->(EOF())
   DispGauge(m_prc,(fks03->(recno()))/fks03->(LASTREC()))
   IF .NOT.fks07->(DBSEEK(fks03->kpr))
      DISPWARNING("Не найден код кассовой операции в справочнике кассовых операций",fks03->kpr)
   ENDIF
   IF .NOT.sp44->(DBSEEK(fks03->ksash))
      DISPWARNING("Не найден код шифра затрат ",fks03->ksash)
   ENDIF
   IF .NOT.EMPTY(fks03->tabn)
      IF .NOT.sp10->(DBSEEK(fks03->tabn))
         DISPWARNING("Не найден код табельного номера",fks03->tabn)
      ENDIF
   ENDIF
//   x1:=ROUND(ROUND(((fks03->prcn/100/(1+fks03->prcn/100))*fks03->sum)/m_okrugl,0)*m_okrugl,2)
   x1:=ROUND(((fks03->prcn/100/(1+fks03->prcn/100))*fks03->sum),2)
   IF fks03->nds<>0.AND.fks03->nds<>x1
    DISPWARNING("Сумма НДС не соотв. проценту",fks03->nds)
   ENDIF
   IF fks03->ndoc1<>0
      m_file:=""
      IF fks03->kpr=='101'
         m_file:="FKSP"+STRZERO(fks03->ndoc1,2)
         IF ASCAN(a_plved,fks03->ndoc1)<>0
            DISPERROR("Повторяется номер ведомости",fks03->ndoc1)
            fks03->(DBSKIP(1))
            LOOP
         ENDIF
         AADD(a_plved,fks03->ndoc1)
      ENDIF
      IF fks03->kpr=='102'
         m_file:="FKSD"+STRZERO(fks03->ndoc1,3)
         IF ASCAN(a_kved,fks03->ndoc1)<>0
            DISPERROR("Повторяется номер ведомости",fks03->ndoc1)
            fks03->(DBSKIP(1))
            LOOP
         ENDIF
         AADD(a_kved,fks03->ndoc1)
      ENDIF
      IF .NOT.EMPTY(m_file)
      IF .NOT.fks02->(DBSEEK(m_file))
         DISPERROR("Не найден итог по ведомости номер",fks03->ndoc1)
      ELSE
         IF fks02->sum<>fks03->sum
               DISPERROR("Не совпадает итог по ведомости номер",fks03->ndoc1)
         ELSE
            IF .NOT.FILE(m_workpath+m_file+".DBF")
               DISPERROR("Отсутствует файл ведомости номер",fks03->ndoc1)
            ELSE
               AADD(a_file,m_file+".dbf")
            ENDIF
         ENDIF
      ENDIF
      ENDIF
   ENDIF
   fks03->(DBSKIP(1))
ENDDO
@PROW()+1,0 Say REPLICATE("=",60)
ClosePrn()
IF n_error==0.AND.n_warning==0
  WaitMessage("Проверка прошла успешно","n/bg,w+/bg")
ELSE
  IF n_error>0
    WaitMessage("При проверке обнаружено;"+STR(n_error,2)+" ошибок","gr+/r,w+/r")
    i:=ALERT("Выводить отчет",{"На экран","На принтер"},"W/b,n/bg")
    DO CASE
      CASE i==1
        MEMOEDIT(MEMOREAD(m_workpath+"CHECK.LST"),5,2,22,78)
      CASE i==2
        FILEPRINT(m_workpath+"CHECK.LST")
     ENDCASE
        CLOSE fks03
        CLOSE fks06
        CLOSE fks04
        CLOSE fks02
        CLOSE sp10
        CLOSE fks07
        CLOSE sp44
        RETURN .f.
  ELSE
    WaitMessage("При проверке обнаружено;"+STR(n_warning,2)+" предупреждений","gr+/r,w+/r")
    i:=ALERT("Выводить отчет",{"На экран","На принтер"},"W/b,n/bg")
    DO CASE
      CASE i==1
        MEMOEDIT(MEMOREAD(m_workpath+"CHECK.LST"),5,2,22,78)
      CASE i==2
        FILEPRINT(m_workpath+"CHECK.LST")
      ENDCASE
    i:=ALERT("Выполнять учет кассы",{"Нет","Да"},"n/w,n/bg")
    IF i<>2
        CLOSE fks03
        CLOSE fks06
        CLOSE fks04
        CLOSE fks02
        CLOSE sp10
        CLOSE fks07
        CLOSE sp44
        RETURN .f.
    ENDIF
  ENDIF
ENDIF
 CopyKass1()
 InitNds1()
 InitAksbor(@m_ksash1,@m_kopr2)
 m_prc1 := InitGauge(" Перекачка документов ",2)
// WorkWindow( m_prc1 )
//   USE (m_workpath+"fks07") INDEX (m_workpath+"fks07")   NEW
   USE (m_workpath+"fks08") NEW
   USE (m_workpath+"fks09") NEW
   USE (m_bufpath+"fd1") NEW
   USE (m_bufpath+"fd2") NEW
   USE (m_bufpath+"fp1") NEW
   USE (m_bufpath+"fp2") NEW
   USE (m_bufpath+"fvnum.dbr") NEW ALIAS fvnum
   fks03->(DBGOTOP())
   m_kopr:=""
   m_saldo:=fks04->saldo
  fks09->(DBAPPEND())
  FOR i:=1 TO fks04->(FCOUNT())
    fks09->(FIELDPUT(fks09->(FIELDPOS(fks04->(FIELDNAME(i)))),fks04->(FIELDGET(i))))
  NEXT
  m_ndoc:=-1
  DO While .NOT.fks03->(EOF())
      DispGauge(m_prc1,fks03->(RECNO())/fks03->(LASTREC()))
      fks08->(DBAPPEND())
      FOR i:=1 TO fks03->(FCOUNT())
        fks08->(FIELDPUT(fks08->(FIELDPOS(fks03->(FIELDNAME(i)))),fks03->(FIELDGET(i))))
      NEXT
      fks08->ddoc:=fks04->ddoc
      m_scht:=LEFT(fks03->ksash,3)
      m_log:=IF(fks03->kpr<'100'.OR.fks03->kpr=='107','1','0')
      m_sum:=IF(fks03->kpr<>'107',fks03->sum,-fks03->sum)
      fks06->(DBSEEK(m_log+m_scht))
      IF .NOT.fks06->(FOUND())
        fks06->(DBAPPEND())
        fks06->ddoc:=fks04->ddoc
        fks06->scht:=m_scht
        fks06->log:=m_log
        fks06->sum:=0
      ENDIF
      fks06->sum+=m_sum
      m_kopr:=fks03->kopr
      IF fks03->ndoc<>m_ndoc
         fp1->(DBAPPEND())
         fp1->npch:="  801"
         fp1->ndoc:=STR(fks03->ndoc,6)
         fp1->vnum:=STR(fvnum->vnum++,7)
         fp1->mnt :=mnt_dtod(fks04->ddoc)
         fp1->maket:="01"
         fp1->oper:="KS"
         fp1->ddoc:=fks04->ddoc
         m_ndoc:=fks03->ndoc
      ENDIF
      fp2->(DBAPPEND())
      fp2->vnum:=fp1->vnum
      fp2->kopr:=m_kopr
      fp2->dbt:=IF(fks03->kpr<"100".OR.fks03->kpr=="107",fks03->scht,fks03->ksash)
      fp2->crt:=IF(fks03->kpr>="100".AND.fks03->kpr<>"107",fks03->scht,fks03->ksash)
      fp2->kvo:=IF(fks03->kpr=="107",-fks03->kvo,fks03->kvo)
      fp2->glv:=IF(fks03->kpr=="107",-fks03->glv,fks03->glv)
      fp2->kvo2:=IF(fks03->kpr=="107",-fks03->kvo2,fks03->kvo2)
      fp2->stm:=IF(fks03->kpr<>"107",fks03->sum,-fks03->sum)
      m_saldo+=IF(fks03->kpr<"100",fks03->sum,-fks03->sum)

// обработка 46 счета
      IF SCHT(fp2->crt)=="70".OR.SCHT(fp2->crt)=="71"  // РЕАЛИЗАЦИЯ
          // 2-Я ПРОВОДКА ДЕБЕТ 70 КРЕДИТ 79 - НДС
          fp2->(DBAPPEND())
          fp2->vnum:=fp1->vnum
          fp2->kopr:=m_kopr
          fp2->dbt:=IF(fks03->kpr<"100".OR.fks03->kpr=="107",fks03->ksash,"79"+SUBSTR(fks03->ksash,3))
          fp2->crt:=IF(fks03->kpr>="100".AND.fks03->kpr<>"107",fks03->ksash,"79"+SUBSTR(fks03->ksash,3))
          fp2->kvo:=IF(fks03->kpr=="107",-fks03->kvo,fks03->kvo)
          fp2->glv:=IF(fks03->kpr=="107",-fks03->glv,fks03->glv)
          fp2->kvo2:=IF(fks03->kpr=="107",-fks03->kvo2,fks03->kvo2)
          fp2->stm:=IF(fks03->kpr<>"107",fks03->sum-fks03->nds,-fks03->sum+fks03->nds)
          IF .NOT.EMPTY(fks03->tabn)
            fp2->cod1:=fp2->cod2:=fks03->tabn
          ENDIF

            IF fks03->kpr<"100".OR.fks03->kpr=="107"
                fp2->(DBAPPEND())
                fp2->kopr:=GetNdsKopr()
                fp2->vnum:=fp1->vnum
                fp2->dbt:=fks03->ksash
                fp2->crt:=GetNdsKsash(fp2->dbt)
                fp2->stm:=IF(fks03->kpr<>"107",fks03->nds,-fks03->nds)
            ELSE
              fp2->(DBAPPEND())
              fp2->vnum:=fp1->vnum
              fp2->kopr:=GetNdsKopr()
              fp2->crt:=fks03->ksash
              fp2->dbt:=GetNdsDbt()
              fp2->stm:=fks03->nds
        ENDIF
      ENDIF

      //нА ЗАРПЛАТУ

      IF .NOT.EMPTY(fks03->tabn)
         fks07->(DBSEEK(fks03->kpr))
         fd1->(DBAPPEND())
         fd1->npch:=801
         fd1->ndoc:=fks03->ndoc
         fd1->vdoc:=1
         fd1->kopu:=fks07->kopu
         fd1->ddoc:=fks04->ddoc
         fd1->mnt :=mnt_dtod(fks04->ddoc)
         fd1->vnuma:=fvnum->vnuma++
         fd2->(DBAPPEND())
         fd2->tabn:=fks03->tabn
         fd2->sum:=fks03->sum
         fd2->vnuma:=fd1->vnuma
      ENDIF
      IF fks03->ndoc1<>0
         m_file:=""
         IF fks03->kpr=='101'
            m_file:="FKSP"+STRZERO(fks03->ndoc1,2)
         ENDIF
         IF fks03->kpr=='102'
            m_file:="FKSD"+STRZERO(fks03->ndoc1,3)
         ENDIF
         IF .NOT.EMPTY(m_file)
            l_append:=.F.
            DBUSEAREA(.T.,,m_workpath+m_file,'fks01')
            DO WHILE .NOT.fks01->(EOF())
               IF IF(fks03->kpr=='101',.NOT.fks01->tk,.t.)
                  fd2->(DBAPPEND())
                  fd2->tabn:=fks01->tabn
                  fd2->sum:=fks01->sum
                  fd2->vnuma:=fvnum->vnuma
                  l_append:=.t.
               ENDIF
               fks01->(DBSKIP(1))
            ENDDO
            IF l_append
               fd1->(DBAPPEND())
               fd1->npch:=801
               fd1->ndoc:=fks03->ndoc1
               fd1->vdoc:=1
//               fd1->kopu:=IF(fks03->kpr=='101','098','101')
IF fks03->kpr=='101'
  fd1->kopu:='098'
ELSE
IF fks03->ndoc1<500
  fd1->kopu:='101'
ELSE
  fd1->kopu:=m_ssuda
ENDIF
ENDIF
//               fd1->kopu:=IF(fks03->kpr=='101','098','101')
               fd1->ddoc:=fks04->ddoc
               fd1->mnt :=mnt_dtod(fks04->ddoc)
               fd1->vnuma:=fvnum->vnuma++
            ENDIF
            CLOSE fks01
            // Сохранить файл

            FERASE(m_workpath+m_file+".dbf")
            IF fks02->(DBSEEK(m_file))
               fks02->(DBDELETE())
            ENDIF
         ENDIF
      ENDIF
      fks03->(DBSKIP(1))
   EndDO
   CLOSE fd1
   CLOSE fd2
   CLOSE fp1
   CLOSE fp2
   CLOSE fvnum
   SELECT fks03
   ZAP
   fks09->otsaldo:=m_saldo
   fks04->saldo:=m_saldo
   fks04->ddoc:=fks04->ddoc+1
   DelGauge(m_prc)
   DelGauge(m_prc1)

CLOSE fks03
CLOSE fks07
CLOSE fks08
CLOSE fks09
CLOSE fks06
SELE   fks05
append from (m_workpath+"fks06")
CLOSE fks05
CLOSE fks04
CLOSE fks02
CLOSE sp10
CLOSE sp44
DelGauge(m_prc)
RETURN .T.
FUNCTION RestKass1
  LOCAL i,m_size,m_ddoc,a_dir:={},m_str,m_set,a_choice:={},;
        l_fks04:=.f.,l_fks02:=.f.,m_prc,m_copy:=1
    IF ANSWER("Восстанавливать данные с дискеты")==YES
      c_disk:=GetFloppy()
      IF UPPER(c_disk)>="A"
        /* СПИСОК ФАЙЛОВ ДЛЯ ВОССТАНОВЛЕНИЯ */
        // fks02,fks03,fks04,fksp**,Fksd**
        a_dir:=DIRECTORY(c_disk+":*.*")
        a_dir:=ASORT(a_dir,,,{|x,y|x[1]>y[1]})
        FOR i:=1 TO LEN(a_dir)
          IF UPPER(SUBSTR(a_dir[i,1],7,2))=="K3".AND.;
            ISDIGIT(LEFT(a_dir[i,1],6)).AND.UPPER(SUBSTR(a_dir[i,1],10,3))="DBF"
             AADD(a_choice,SUBSTR(a_dir[i,1],5,2)+" "+;
             PADR(NTOCMONTH(VAL(SUBSTR(a_dir[i,1],3,2))),14)+SUBSTR(a_dir[i,1],1,2)+"г.")
           ENDIF
        NEXT
        i:=my_menu("Базы данных на дискете "+c_disk+":",a_choice)
        IF i>0
           m_size:=0
           m_ddoc:=SUBSTR(a_choice[i],-4,2)+STRZERO(CTOMONTH(ALLTRIM(SUBSTR(a_choice[i],4,14))),2);
           +LEFT(a_choice[i],2)
           AEVAL(a_dir,{|x|m_size+=IF(LEFT(x[1],6)==m_ddoc,x[2],0)})
           m_prc := InitGAUGE(" Восстановление данных с дискеты",2)
//           WorkWindow(m_prc)
           m_set:=SSETVERIFY(.T.)
            FOR i:=1 TO LEN(a_dir)
              IF LEFT(a_dir[i,1],6)==m_ddoc
                m_copy+=a_dir[i,2]
                DO CASE
                  CASE UPPER(SUBSTR(a_dir[i,1],7,1))=="K"
                    FERASE(m_workpath+"FKS0"+SUBSTR(a_dir[i,1],8,1)+".DBF")
                    FILECOPY(c_disk+":"+a_dir[i,1],m_workpath+"FKS0"+SUBSTR(a_dir[i,1],8,1)+".DBF")
                  CASE SUBSTR(a_dir[i,1],7,1)=="."
                    FERASE(m_workpath+"FKSD"+SUBSTR(a_dir[i,1],8,3)+".DBF")
                    FILECOPY(c_disk+":"+a_dir[i,1],m_workpath+"FKSD"+SUBSTR(a_dir[i,1],8,3)+".DBF")
                  CASE ISDIGIT(SUBSTR(a_dir[i,1],10,2)).AND.SUBSTR(a_dir[i,1],9,1)=='.'
                    FERASE(m_workpath+"FKSP"+SUBSTR(a_dir[i,1],7,2)+".DBF")
                    FILECOPY(c_disk+":"+a_dir[i,1],m_workpath+"FKSP"+SUBSTR(a_dir[i,1],10,2)+".DBF")
                ENDCASE
                DispGauge(m_prc,m_copy/m_size)
              ENDIF
            NEXT
            USE (m_workpath+"fks02") INDEX (m_workpath+"fks02") NEW
            REINDEX
            CLOSE fks02
         ENDIF
      ENDIF
    ENDIF

RETURN .t.
STATIC Function InitNds1
  NET USE (m_platpath+"NDS") READONLY NEW
  m_nds:=nds->nds/100  //;m_nds:=m_nds/(1+m_nds)
  k_nds1:=nds->ksash
  k_nds2:=nds->ksash2
  k_nds3:=nds->ksash3
  k_ndsDbt:=nds->ksash4
  k_ndsKopr:=nds->kopr
  s_nds1:=ALLTRIM(nds->Scht)
  s_nds2:=ALLTRIM(nds->Scht2)
  CLOSE Nds
RETURN .t.
Function GetNdsKsash(m_ksash)
  LOCAL m_subsch:=LEFT(m_ksash,3)
  IF AT(m_subsch,s_nds1)<>0
    RETURN k_nds1
  ENDIF
  IF AT(m_subsch,s_nds2)<>0
    RETURN k_nds2
  ENDIF
RETURN k_nds3
Function GetNdsDbt()
  RETURN k_ndsDbt

Function GetNdsKopr()
RETURN k_ndsKopr
EXTERNAL testfl
EXTERNAL MyFormat
