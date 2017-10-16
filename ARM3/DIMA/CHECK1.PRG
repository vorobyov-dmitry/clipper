#include "new.ch"
#XCOMMAND CheckLink(<fz1>,<fz2>,<vnum1>) =>;
ChErr1(SELECT(<"fz1">),SELECT(<"fz2">),<"vnum1">);;
IF n_ret==0;n_fat:=1;l_exit:=.t.;EXIT;END;;
IF n_ret==1;LOOP;END
#XCOMMAND cherr2(<fz1>,<fz2>,<vnum1>) =>;
IF .NOT.ChErr03(<fz1>,<fz2>,<vnum1>);LOOP;END

#XCOMMAND CheckKod(<sp01>,<kod>,<fz1>,<name>) => ;
Checkww(SELECT(<"sp01">),<kod>,SELECT(<"fz1">),<name>)
#XCOMMAND SkipVnum(<fz1>,<fz2>,<vnum1>) =>SkipVn(SELECT(<"fz1">),SELECT(<"fz2">),<"vnum1">)
#XCOMMAND SetVnum(<fz1>,<fz2>,<vnum1>,<var>) =>SkipVn1(SELECT(<"fz1">),SELECT(<"fz2">),<"vnum1">,<var>)

MEMVAR m_bufpath,m_mainpath,m_sprpath,m_syspath,m_exepath,m_copypath
MEMVAR m_mash,m_oper,m_imja,m_temppath,m_tabn
MEMVAR m_computer
STATIC n_error:=0
STATIC n_ret:=0
FUNCTION  Checkbd()
LOCAL   i,j,n_err1:=0,n_err2:=0
LOCAL aMenu:={" БД за мiсяць"," БД з початку року"}
LOCAL aMenu2:={" Повнiстю"," Нарахування "," Утримання"," Лiкарнянi "," Бухгалтерськi проводки"}
LOCAL n_win1,l_code:=.t.
i:=MyMenu("Виберiть базу даних",aMenu,-3,.f.)
IF i==0
    RETURN .F.
ENDIF
j:=MyMenu(amenu[i],aMenu2,0,.f.)
IF j==0;RETURN .F.;ENDIF
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
l_code:=RESTVAR1("l_code","CH")
CLOSE myvar
SETPRC(0,0)
SET PRINTER TO (m_mash+"46.txt")
SET PRINTER ON
n_win1:=WOPEN(0,0,8,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC("Перевiрка даних",80) COLOR "n/w"
SETPOS(0,0)
n_error:=0
IF j==1.OR.j==2;CheckBd1(IF(i==2,m_mainpath,m_bufpath),l_code);ENDIF
IF j==1.OR.j==3;CheckBd2(IF(i==2,m_mainpath,m_bufpath),l_code);ENDIF
IF j==1.OR.j==4;CheckBd4(IF(i==2,m_mainpath,m_bufpath),l_code);ENDIF
IF j==1.OR.j==5;CheckBd3(IF(i==2,m_mainpath,m_bufpath),l_code);ENDIF
INKEY(5)
Wclose(n_win1)
DobMs1(STRZERO(MONTH(DATE()),2),STRZERO(MONTH(DATE()),2))
SET PRINTER OFF
SET PRINTER TO
WSELECT(0)
IF n_error<>0
  RETURN .f.
ENDIF
RETURN .T.

Function VostBd()
LOCAL   i,j,n_err1:=0,n_err2:=0
LOCAL aMenu:={" БД за мiсяць"," БД з початку року"}
LOCAL aMenu2:={" Повнiстю"," Нарахування "," Утримання"," Лiкарнянi "," Бухгалтерськi проводки"}
LOCAL n_win1
i:=MyMenu("Виберiть базу даних",aMenu,-3,.f.)
IF i==0;RETURN .F.;ENDIF
j:=MyMenu(amenu[i],aMenu2,0,.f.)
IF j==0;RETURN .F.;ENDIF
  SETPRC(0,0)
  SET PRINTER TO (m_mash+"46.txt")
  SET PRINTER ON
  n_win1:=WOPEN(0,0,8,80,.t.)
  Wselect(n_win1)
  WBOX(12)
  @-1,0 SayDisp PADC('Лiкування даних',80) COLOR "n/w"
  SETPOS(0,0)
  n_error:=0
n_error:=0
IF j==1.OR.j==2;Chan01(IF(i==2,m_mainpath,m_bufpath),.t.);ENDIF
IF j==1.OR.j==3;Chan02(IF(i==2,m_mainpath,m_bufpath),.t.);ENDIF
IF j==1.OR.j==4;Chan04(IF(i==2,m_mainpath,m_bufpath),.t.);ENDIF
IF j==1.OR.j==5;Chan03(IF(i==2,m_mainpath,m_bufpath),.t.);ENDIF
IndBd(IF(i==2,m_mainpath,m_bufpath))
INKEY(5)
Wclose(n_win1)
DobMs1(STRZERO(MONTH(DATE()),2),STRZERO(MONTH(DATE()),2))
SET PRINTER OFF
SET PRINTER TO
WSELECT(0)
return .t.


STATIC Function Checkbd1(m_path,l_code)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge
LOCAL l_buf
LOCAL nRGNOR ,nRGFAK ,nVNVS,nVNDV,nPRVS,nPRPR,nPRSN,nPRTN,nKOLEZ,nPGGR,nPTAV
LOCAL nAVDN,nPGOB1,nPGOB2,nPGOB3,nPTPR,nVTKPR,nVNUS,nZAPR,nZAPR_,nOTMD,nOTMS
LOCAL nOTDN,nOTHS,nPGOB,nVTKAV,nVPGA,nVPTN,nVPUG,nRTNOR,nOTNSM,nSum1,nOSTNM
LOCAL s_sum,s_otdn,s_oths
// Перевiрка структури нарахувань
  l_buf:=IF(m_path==m_mainpath,.f.,.t.)
  /* открытие справочников */
  SopenFiles("091",@s_file)
  NET USE (m_path+"fz1") NEW
  NET USE (m_path+"fz2") NEW
  NET USE (m_path+"fz2t") NEW
  NET USE (m_path+"fz2a") NEW
  NET USE (m_path+"fz2tp") NEW
  NET USE (m_path+"fz3") NEW
  NET USE (m_path+"fz1t") NEW
  NET USE (m_path+"fz1ap") NEW
  NET USE (m_path+"fz1ae") NEW
  NET USE (m_path+"fz1at") NEW
  NET USE (m_path+"fvnum.dbr") NEW ALIAS fvnum

  ?"-----Перевiрка нарахувань-----------------------------------"
  IF m_path==m_mainpath
    ?"База даних з початку року"
  ELSE
    IF m_path==m_bufpath
      ?"База даних за мiсяць"
    ELSE
      ?"******* База даних не визначена"
    ENDIF
  ENDIF
  ?"Зроблена "+DMY(DATE())+" Оператор " +_fioFull(m_tabn)
  //Проверка на уникальность внутреннего номера
  n_err1:=CheckVnum(SELECT("fz1"),{||fz1->vnum1})
  IF n_err1<>0
    ?" Знайдено " +STR(n_err1,6) + " подвоєних кодiв при перевiрцi файла FZ1"
  ENDIF
  n_err2:=CheckVnum(SELECT("fz2"),{||fz2->vnum2})
  IF n_err2<>0
    ?" Знайдено " +STR(n_err2,6) + " подвоєних кодiв при перевiрцi файла FZ2"
  ENDIF

  /* проход по fz1 */
  fz1->( DBGOTOP() )
  m_gauge:=InitGauge("Перевiрка нарахувань",2)
  l_exit:=.f.
  nRGNOR :=nRGFAK :=nVNVS:=nVNDV:=nPRVS:=nPRPR:=nPRSN:=nPRTN:=nKOLEZ:=nPGGR:=nPTAV:=0
  nAVDN:=nPGOB1:=nPGOB2:=nPGOB3:=nPTPR:=nVTKPR:=nVNUS:=nZAPR:=nZAPR_:=nOTMD:=nOTMS:=0
  nOTDN:=nOTHS:=nPGOB:=nVTKAV:=nVPGA:=nVPTN:=nVPUG:=nRTNOR:=nOTNSM:=nSum1:=nOSTNM:=0
  m_npch:=fz1->npch;m_vdoc:=fz1->vdoc;m_ndoc:=0
  fz1->(DBGOTOP());fz2->(DBGOTOP());fz3->(DBGOTOP())
  fz2t->(DBGOTOP());fz2a->(DBGOTOP());fz2tp->(DBGOTOP())
  fz1t->(DBGOTOP());fz1ap->(DBGOTOP());fz1ae->(DBGOTOP())
  fz1at->(DBGOTOP())
  ?"Пачка     Кiльк."
  ?"      документiв  Сума           Днi    Години   Тип документа "
  s_sum:=s_otdn:=s_oths:=0
  DO WHILE ( fz1->( !EOF() ) ).AND.n_fat==0

      /* подсчет количества документов */
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати перевiрку ?")==YES
            ?"Перевiрка нарахувань прервана. Виконано  " +STR(100*fz1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
      IF l_buf
        IF mnt_month(fz1->mnt)<>month( fz1->ddoc )
            ?" Попередження ! Мiсяць документа не спiвпадає з мiсяцем розрахунку"
            ?? " Пачка:",fz1->npch,". Номер док.:",fz1->ndoc
        ENDIF
        IF fz1->mnt<>fvnum->mnt
            ?" Попередження !!! Не спiвпадає перiод розрахунку "
            ?? " Пачка:",fz1->npch,". Номер док.:",fz1->ndoc
            n_err3++
          ENDIF
      ENDIF
     /* проверка связки fz1->>fz2 */
     CheckLink(fz1,fz2,vnum1)
        /* если совпадение по внутренним номерам */
        DO WHILE ( fz1->vnum1 == fz2->vnum1 .AND. fz2->( !EOF() ) ).AND.n_fat==0

           /* проход по одинаковым внутренним номерам в fz2 */
           IF l_code
              IF .NOT.EMPTY(fz2->brgd);CheckKod(sp01,fz2->brgd,fz1,"бригади");ENDIF
              IF .NOT.EMPTY(fz2->vrab);CheckKod(sp06,fz2->vrab,fz1,"вида працi");ENDIF
              CheckKod(sp10,fz2->tabn,fz1,"таб. номера")
              CheckKod(sp44,fz2->ksash,fz1,"рахунка витрат")
           ENDIF

           IF ( fz1->vdoc >= 34 .AND. fz1->vdoc <= 37 )
              CheckLink(fz2,fz2T,vnum2)
                 DO WHILE ( fz2t->vnum2 == fz2->vnum2 .AND. fz2t->( !EOF() ) )
                    nVPGA  := nVPGA  + fz2t->vpga
                    nVPTN  := nVPTN  + fz2t->vptn
                    nVPUG  := nVPUG  + fz2t->vpug
                    nRTNOR := nRTNOR + fz2t->rtnor
                    nOTNSM := nOTNSM + fz2t->otnsm
                    fz2t->( DBSKIP() )
                 ENDDO
           ENDIF

           IF ( fz1->vdoc >= 38 .AND. fz1->vdoc <= 44 )

              CheckLink(fz2,fz2a,vnum2)
                 DO WHILE ( fz2a->vnum2 == fz2->vnum2 .AND. fz2a->( !EOF() ) )
                    nPGOB  := nPGOB  + fz2a->pgob
                    nVTKAV := nVTKAV + fz2a->vtkav
                    fz2a->( DBSKIP() )
                 ENDDO

           ENDIF

           IF ( fz1->vdoc == 37 )
              CheckLink(fz2,fz2tp,vnum2)
              DO WHILE ( fz2tp->vnum2 == fz2->vnum2 .AND. fz2tp->( !EOF() ) )
                    fz2tp->( DBSKIP() )
              ENDDO
           ENDIF
           IF ( fz1->vdoc != 38 .AND. fz1->vdoc != 42 .AND. fz1->vdoc != 44 )            // ТРАКТОРА
              CheckLink(fz2,fz3,vnum2)
              DO WHILE ( fz3->vnum2 == fz2->vnum2 .AND. fz3->( !EOF() ) )
                IF l_code
                    CheckKod(sp08,fz3->kopu,fz1,"оплат")
                ENDIF
                nSum1 := nSum1 + fz3->sum
                s_sum+=fz3->sum
                fz3->( DBSKIP() )
              ENDDO
           ENDIF
           nOTDN := nOTDN + fz2->otdn
           nOTHS := nOTHS + fz2->oths
           s_otdn+=fz2->otdn
           s_oths+=fz2->oths
           fz2->( DBSKIP() )
        ENDDO
         IF ( fz1->vdoc >= 34 .AND. fz1->vdoc <= 37 )
             CheckLink(fz1,fz1t,vnum1)
               DO WHILE ( fz1t->vnum1 == fz1->vnum1 .AND. fz1t->( !EOF() ) )
                  IF l_code
                    CheckKod(inv_t,fz1t->ntr,fz1,"номер тракт.")
                  ENDIF
                  nZAPR_ := nZAPR_ + fz1t->zapr
                  nOSTNM := nOSTNM + fz1t->ostnm
                  nOTMD  := nOTMD  + fz1t->otmd
                  nOTMS  := nOTMS  + fz1t->otms
                  fz1t->( DBSKIP() )
               ENDDO
         ENDIF

     IF ( fz1->vdoc == 40 )

        /* проверка связки fz1->fz1ap */
           CheckLink(fz1,fz1ap,vnum1)
           DO WHILE ( fz1ap->vnum1 == fz1->vnum1 .AND. fz1ap->( !EOF() ) )
              IF EMPTY( fz1ap->gnp1 ).AND.l_code
                    CheckKod(inv_p,fz1ap->gnp1,fz1,"номер прич. 1")
              ENDIF
              IF EMPTY( fz1ap->gnp2 ).AND.l_code
                    CheckKod(inv_p,fz1ap->gnp2,fz1,"номер прич. 2")
              ENDIF
              IF EMPTY( fz1ap->gnp3 ).AND.l_code
                    CheckKod(inv_p,fz1ap->gnp3,fz1,"номер прич. 3")
              ENDIF
              nPGOB1 := nPGOB1 + fz1ap->pgob1
              nPGOB2 := nPGOB2 + fz1ap->pgob2
              nPGOB3 := nPGOB3 + fz1ap->pgob3
              nPTPR  := nPTPR  + fz1ap->ptpr
              nVTKPR := nVTKPR + fz1ap->vtkpr
              nVNUS  := nVNUS  + fz1ap->vnus
              fz1ap->( DBSKIP() )

           ENDDO

     ENDIF

     IF ( fz1->vdoc >= 38 .AND. fz1->vdoc <= 44 )

        /* проверка связки fz1->fz1ae */
        CheckLink(fz1,fz1ae,vnum1)
           DO WHILE ( fz1ae->vnum1 == fz1->vnum1 .AND. fz1ae->( !EOF() ) )
              IF l_code
                  CheckKod(inv_a,fz1ae->gnavt,fz1,"номер автом.")
              ENDIF
              nRGNOR := nRGNOR + fz1ae->rgnor
              nRGFAK := nRGFAK + fz1ae->rgfak
              nVNVS  := nVNVS  + fz1ae->vnvs
              nVNDV  := nVNDV  + fz1ae->vndv
              nPRVS  := nPRVS  + fz1ae->prvs
              nPRPR  := nPRPR  + fz1ae->prpr
              nPRSN  := nPRSN  + fz1ae->prsn
              nPRTN  := nPRTN  + fz1ae->prtn
              nKOLEZ := nKOLEZ + fz1ae->kolez
              nPGGR  := nPGGR  + fz1ae->pggr
              nPTAV  := nPTAV  + fz1ae->ptav
              nAVDN  := nAVDN  + fz1ae->avdn
              fz1ae->( DBSKIP() )
           ENDDO

     ENDIF

     IF ( fz1->vdoc >= 38 .AND. fz1->vdoc <= 44 )

        /* проверка связки fz1->fz1at */
        CheckLink(fz1,fz1at,vnum1)
           DO WHILE ( fz1at->vnum1 == fz1->vnum1 .AND. fz1at->( !EOF() ) )
              IF l_code
                    IF .NOT.sp22->(DS(mnt_dtod(fz1->ddoc)+fz1at->kmtop))
                        ?"  Увага, не визн. темп. коєф. пального ",fz1at->kmtop," для мiсяця ", mnt_dtod(fz1->ddoc)
                        ??"   Пачка:",fz1->npch,"N",fz1->ndoc
//                      CheckKod(sp22, STRZERO(month(fz1->ddoc),2)+fz1at->kmtop,fz1,"код пального")
                    ENDIF
              ENDIF
              nZAPR  := nZAPR  + fz1at->zapr
              fz1at->( DBSKIP() )
           ENDDO
     ENDIF
     fz1->(DBSKIP())
     m_ndoc++
     m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
      IF m_npch<>fz1->npch.OR.m_vdoc<>fz1->vdoc
        ?STR(m_npch,6), " - " ,STR(m_ndoc,3),SumToStr(s_sum,10),NumToStr(s_otdn,9,1),NumToStr(s_oths,10,0),SayVdoc1(m_vdoc)
        m_npch:=fz1->npch;m_vdoc:=fz1->vdoc;m_ndoc:=0
        s_sum:=s_otdn:=s_oths:=0
      ENDIF
  ENDDO

  IF .NOT.l_exit
    ?"Перевiрка нарахувань завершена"
    ? " Контр. сумма "
  /* fz1ae */
  ?" * Витрата пального норма   (авт.)* ", STR( nRGNOR, 20, 3 )
  ?" * Витрата пального факт.   (авт.)* ", STR( nRGFAK, 20, 3 )
  ?" * Час в нарядi    автомобiля     * ", STR( nVNVS, 20, 3 )
  ?" * Час авт. в нарядi в русi       * ", STR( nVNDV, 20, 3 )
  ?" * Прост.  авт. разом             * ", STR( nPRVS, 20, 3 )
  ?" * Прост.  авт. разом погр/разгр  * ", STR( nPRPR, 20, 3 )
  ?" * Прост.  авт. понад норми       * ", STR( nPRSN, 20, 3 )
  ?" * Прост.  авт. по тех. неспрвн.  * ", STR( nPRTN, 20, 3 )
  ?" * Кiл.   їздок з вантажем  (авт.)* ", STR( nKOLEZ, 20, 3 )
  ?" * Пробiг з вантаж          (авт.)* ", STR( nPGGR, 20, 3 )
  ?" * Перевезено тонн разом    (авт.)* ", STR( nPTAV, 20, 3 )
  ?" * Вiдроблено автомобiле-днiв     * ", STR( nAVDN, 20, 3 )
  /* fz1ap */
  ?" * Пробiг  заг.   прицепа 1 (авт.)* ", STR( nPGOB1, 20, 3 )
  ?" * Пробiг  заг.   прицепа 2 (авт.)* ", STR( nPGOB2, 20, 3 )
  ?" * Пробiг  заг.   прицепа 3 (авт.)* ", STR( nPGOB3, 20, 3 )
  ?" * Перевезено тонн на приц. (авт.)* ", STR( nPTPR, 20, 3 )
  ?" * Виконано   т-км на приц. (авт.)* ", STR( nVTKPR, 20, 3 )
  ?" * Час   в нарядi прицепа   (авт.)* ", STR( nVNUS, 20, 3 )
  /* fz1at */
  ?" * Заправлено, л            (авт.)* ", STR( nZAPR, 20, 3 )
  /* fz1t */
  ?" * Заправлено               (тр-р)* ", STR( nZAPR_, 20, 3 )
  ?" * Вiдроблено машино-днiв   (тр-р)* ", STR( nOTMD, 20, 3 )
  ?" * Вiдроблено машино-змiн   (тр-р)* ", STR( nOTMS, 20, 3 )
  /* fz2 */
  ?" * Вiдроблено днiв                * ", STR( nOTDN, 20, 3 )
  ?" * Вiдроблено годин               * ", STR( nOTHS, 20, 3 )
  /* fz2a */
  ?" * Пробiг загальний               * ", STR( nPGOB, 20, 3 )
  ?" * Виконане  т/км автомобiлем     * ", STR( nVTKAV, 20, 3 )
  /* fz2t */
  ?" * Виконано  гектар         (тр-р)* ", STR( nVPGA, 20, 3 )
  ?" * Виконано  тонн           (тр-р)* ", STR( nVPTN, 20, 3 )
  ?" * Виконано  умовних  гектар(тр-р)* ", STR( nVPUG, 20, 3 )
  ?" * Витрата пального по нормi(тр-р)* ", STR( nRTNOR, 20, 3 )
  ?" * Вiдроблено нормо-змiн    (тр-р)* ", STR( nOTNSM, 20, 3 )
  /* fz3 */
  ? " * Сума оплати працi              * ", STR( nSum1, 20, 3 )
  ENDIF
  ScloseFiles(s_file)
  CLOSE BASE fz1,fz2,fz2t,fz2a,fz2tp,fz3,fz1t,fz1ap,fz1ae,fz1at,fvnum
  DelGauge(m_gauge)
  IF n_fat==0.AND.n_error==0
    return .t.
ENDIF
RETURN .f.
STATIC Function CheckVnum(m_alias,m_code)
LOCAL m_gauge
LOCAL m_file:=TEMPFILE(m_temppath,"ntx")
LOCAL m_er:=0,m_vnum,m_rec,i:=1
FERASE(m_file)
DBSELECTAREA(m_alias)
m_gauge:=InitGauge("Перевiрка унiкальностi кодiв файла "+ALIAS(),2)
DBCREATEINDEX(m_file,"VNUM",m_code,.f.)
m_vnum:=EVAL(m_code)
DBGOTOP()
m_rec:=RECNO()
DBSKIP()
DO WHILE .NOT.EOF()
  IF m_vnum==EVAL(m_code)
    ?"  !!! Помилка, подвоєння VNUM ",EVAL(m_code),"# ",STR(m_rec,6),"# ",STR(RECNO(),6)
    m_er++
  ENDIF
  m_vnum:=EVAL(m_code)
  m_rec:=RECNO()
  DBSKIP()
  m_gauge:=DispGauge(m_gauge,i++/LASTREC())
ENDDO
DBCLEARINDEX()
FERASE(m_file)
delGauge(m_gauge)
RETURN m_er
STATIC FUNCTION Sayvdoc1(m_vdoc)
DO CASE
  CASE m_vdoc==39
    RETURN ("Подор. лист ")
  CASE m_vdoc==38
    RETURN ("Подор. лист ( эксплуатацiя )")
  CASE m_vdoc==40
    RETURN ("Подор. лист з причепом")
  CASE m_vdoc==37
    RETURN ("Подор. лист трактора")
  CASE m_vdoc==36
    RETURN ("Обл. лист тракториста 2")
  CASE m_vdoc==29
    RETURN ("Iнд. наряд помiчника тракториста")
  CASE m_vdoc==30
    RETURN ("Табель")
  CASE m_vdoc==31
    RETURN ("Наряд iнд.")
  CASE m_vdoc==32
    RETURN ("Наряд  бригадний")
  CASE m_vdoc==20
    RETURN ("Вiдпуска")
  CASE m_vdoc==21
    RETURN ("Лiкарняний лист")
  CASE m_vdoc==1
    RETURN ("Унiв. реєстр")
ENDCASE
RETURN ""
STATIC Function ChErr1(n1,n2,m_str)
LOCAL b1:=(n1)->(FIELDBLOCK(m_str))
LOCAL b2:=(n2)->(FIELDBLOCK(m_str))
LOCAL r1:=(n1)->(RECNO())
LOCAL r2:=(n2)->(RECNO())
LOCAL r2a:=0
LOCAL m_vnum
n_ret:=4
IF  (n1)->(EVAL(b1))==(n2)->(EVAL(b2))
  RETURN .f.
ENDIF
(n2)->(DBEVAL({||NIL},,{||(n1)->(EVAL(b1))<>(n2)->(EVAL(b2))}))
IF (n1)->(EVAL(b1))<>(n2)->(EVAL(b2)).OR.(n2)->(EOF())
  ?" Помилка !!!",ALIAS(n1),"->",ALIAS(n2),m_str,"=",(n1)->(EVAL(b1))," #",STR((n1)->(RECNO()),6)
  IF (n1)->(FIELDNUM("NPCH"))<>0.AND.(n1)->(FIELDNUM("NDOC"))<>0
    ??" Пачка ",(n1)->npch," N",(n1)->ndoc
  ENDIF
  (n2)->(DBGOTO(r2))
   n_error++
  RETURN .f.
ELSE
  r2a:=(n2)->(RECNO())
  (n2)->(DBGOTO(r2))
  (n1)->(DBEVAL({||NIL},,{||(n1)->(EVAL(b1))<>(n2)->(EVAL(b2))}))
  IF (n1)->(EVAL(b1))<>(n2)->(EVAL(b2)).OR.(n1)->(EOF())
    ?" Помилка !!!",ALIAS(n2),"=>",ALIAS(n1),m_str,"=",(n2)->(EVAL(b2)),"#",STR((n2)->(RECNO()),6)
    (n1)->(DBGOTO(r1))
    n_error++
    m_vnum:=(n2)->(EVAL(b2))
    (n2)->(DBEVAL({||NIL},,{||m_vnum==(n2)->(EVAL(b2))}))
//    (n2)->(DBSKIP()) // пропуск помилкового
    n_ret:=1
    RETURN .f.
  ENDIF
ENDIF
?"  Фатальна помилка !!! ",ALIAS(n1),STR(r1,6),ALIAS(n2),STR(r2a,6)
?"                       ",ALIAS(n1),STR((n1)->(RECNO()),6),ALIAS(n2),STR(r2,6)
n_error++
n_ret:=0
RETURN .t.

STATIC Function chan01(m_path)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge,k:=0,i
LOCAL a_file:={"fz1","fz2","fz2t","fz2a","fz2tp","fz3",;
"fz1t","fz1ap","fz1ae","fz1at"}

FOR i:=1 TO LEN(a_file)
  FILECOPY(m_path+a_file[i]+".dbf"   ,m_temppath+a_file[i]+".dbf"   )
  USE (m_temppath+a_file[i])   NEW
NEXT
  ?"-----Лiкування бази даних нарахувань-----------------------------------"
  ?"Зроблено "+DMY(DATE())+" Оператор "  + m_imja
  /* проход по fz1 */
  m_gauge:=InitGauge("Лiкування нарахувань",2)
  l_exit:=.f.
DO WHILE .NOT.l_exit
  FOR i:=1 TO LEN(a_file)
    SELECT(a_file[i])
    DBGOTOP()
  NEXT
//  fz1->(DBGOTOP())
//  fz2->(DBGOTOP())
  n_error:=0;k++
  ?STR(k,3)," перегляд бази даних"
  DO WHILE ( fz1->( !EOF() ) ).AND.n_fat==0
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати лiкуванння ?")==YES
            ?"Лiкування  нарахувань прервано. Виконано  " +STR(100*fz1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
      cherr2(SELECT("Fz1"),SELECT("Fz2"),"Vnum1")
        /* если совпадение по внутренним номерам */
        DO WHILE ( fz1->vnum1 == fz2->vnum1 .AND. fz2->( !EOF() ) ).AND.n_fat==0
           IF ( fz1->vdoc >= 34 .AND. fz1->vdoc <= 37 )
                 cherr2(SELECT("Fz2"),SELECT("Fz2t"),"Vnum2")
                 SkipVnum(fz2,fz2t,vnum2)
           ENDIF
           IF ( fz1->vdoc >= 38 .AND. fz1->vdoc <= 44 )
                 cherr2(SELECT("Fz2"),SELECT("Fz2a"),"Vnum2")
                 SkipVnum(fz2,fz2a,vnum2)
           ENDIF
           IF ( fz1->vdoc == 37 )
              cherr2(SELECT("Fz2"),SELECT("Fz2tp"),"Vnum2")
              SkipVnum(fz2,fz2tp,vnum2)
           ENDIF
           IF ( fz1->vdoc != 38 .AND. fz1->vdoc != 42 .AND. fz1->vdoc != 44 )            // ТРАКТОРА
              cherr2(SELECT("Fz2"),SELECT("Fz3"),"Vnum2")
              SkipVnum(fz2,fz3,vnum2)
           ENDIF
           fz2->( DBSKIP() )
        ENDDO
         IF ( fz1->vdoc >= 34 .AND. fz1->vdoc <= 37 )
              cherr2(SELECT("Fz1"),SELECT("Fz1t"),"Vnum1")
              SkipVnum(fz1,fz1t,vnum1)
         ENDIF
     IF ( fz1->vdoc == 40 )
           cherr2(SELECT("Fz1"),SELECT("Fz1ap"),"Vnum1")
           SkipVnum(fz1,fz1ap,vnum1)
     ENDIF
     IF ( fz1->vdoc >= 38 .AND. fz1->vdoc <= 44 )
          cherr2(SELECT("Fz1"),SELECT("Fz1ae"),"Vnum1")
           SkipVnum(fz1,fz1ae,vnum1)
     ENDIF
     IF ( fz1->vdoc >= 38 .AND. fz1->vdoc <= 44 )
        cherr2(SELECT("Fz1"),SELECT("Fz1at"),"Vnum1")
           SkipVnum(fz1,fz1at,vnum1)
     ENDIF
     fz1->(DBSKIP())
     m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
  IF n_error==0
    EXIT
  ENDIF
ENDDO
DelGauge(m_gauge)
  DelGauge(m_gauge)
IF .NOT.l_exit
  IF ANSWERu("Виконувати перекодiровку; внутр. номерiв нарахувань?")==YES
    ?"Перекодiровка внутр. номерiв"
    perekod1(m_path,a_file)
  ENDIF
  CLOSE BASE fz1,fz2,fz2t,fz2a,fz2tp,fz3,fz1t,fz1ap,fz1ae,fz1at
  ?"Лiкування завершено"
  IF n_error==0
    FOR i:=1 TO LEN(a_file)
      k:=FERASE(m_path+a_file[i]+".dbf")
      IF k==-1
        DispError("Помилка при видаленнi файла "+a_file[i]+";База даних"+m_path+" зруйнована")
      ELSE
        FILECOPY(m_temppath+a_file[i]+".dbf",m_path+a_file[i]+".dbf")
      ENDIF
    NEXT
  ENDIF
   RETURN .t.
ENDIF
CLOSE BASE fz1,fz2,fz2t,fz2a,fz2tp,fz3,fz1t,fz1ap,fz1ae,fz1at
return .F.
STATIC Function ChErr03(n1,n2,m_str)
LOCAL b1:=(n1)->(FIELDBLOCK(m_str))
LOCAL b2:=(n2)->(FIELDBLOCK(m_str))
LOCAL r1:=(n1)->(RECNO())
LOCAL r2:=(n2)->(RECNO())
LOCAL r2a:=0,m_vnum
IF (n1)->(EVAL(b1))==(n2)->(EVAL(b2))
  RETURN .t.
ENDIF
(n2)->(DBEVAL({||NIL},,{||(n1)->(EVAL(b1))<>(n2)->(EVAL(b2))}))
IF (n1)->(EVAL(b1))<>(n2)->(EVAL(b2))
  ?" Видалення !!!",ALIAS(n1),"->",ALIAS(n2),m_str,"=",(n1)->(EVAL(b1))," #",STR((n1)->(RECNO()),6)
  IF (n1)->(FIELDNUM("NPCH"))<>0.AND.(n1)->(FIELDNUM("NDOC"))<>0
    ??" Пачка ",(n1)->npch," N",(n1)->ndoc
  ENDIF
  (n1)->(DBDELETE())
  (n1)->(DBSKIP())
  (n2)->(DBGOTO(r2))
   n_error++
  RETURN .f.
ELSE
  r2a:=(n2)->(RECNO())  // Запись с соотвествующим VNUM
  (n2)->(DBGOTO(r2))
  (n1)->(DBEVAL({||NIL},,{||(n1)->(EVAL(b1))<>(n2)->(EVAL(b2))}))
  IF (n1)->(EVAL(b1))<>(n2)->(EVAL(b2))
    ?" Видалення !!!",ALIAS(n2),"=>",ALIAS(n1),m_str,"=",(n2)->(EVAL(b2)),"#",STR((n2)->(RECNO()),6)
    ??"по #",STR(r2a-1,6)
    (n1)->(DBGOTO(r1))
    n_error++
    m_vnum:= (n2)->(EVAL(b2))
  // А если полностью вырезать ???
   (n2)->(DBEVAL({||(n2)->(DBDELETE())},,{||r2a>(n2)->(RECNO())}))

//    (n2)->(DBEVAL({||(n2)->(DBDELETE())},,{||m_vnum==(n2)->(EVAL(b2))}))

//    (n2)->(DBDELETE())
//    (n2)->(DBSKIP()) // пропуск помилковогo
    RETURN .t.
  ENDIF
ENDIF
?"  Фатальна помилка !!! ",ALIAS(n1),STR(r1,6),ALIAS(n2),STR(r2a,6)
?"                       ",ALIAS(n1),STR((n1)->(RECNO()),6),ALIAS(n2),STR(r2,6)
?"     Видалення записiв "+ALIAS(n2)
(n1)->(DBGOTO(r1))
(n2)->(DBGOTO(r2))
??"з",STR((n2)->(RECNO()),6),"по",STR(r2a-1,6)
(n2)->(DBEVAL({||(n2)->(DBDELETE())},,{||((n2)->(RECNO())<r2a)}))
n_error++
RETURN .f.
STATIC FUNCTION perekod1(m_path,a_file,x1,x2)
LOCAL m_gauge,m_vnum1,m_vnum2,i

m_gauge:=InitGauge("Перекодiровка",2)
IF x1==NIL.OR.x2==NIL
  DO CASE
    CASE m_path==m_mainpath
      m_vnum1:=1;m_vnum2:=1
    CASE m_computer>=1.AND.m_computer<=8
      m_vnum2:=m_vnum1:=m_computer*100000
    OTHERWISE
      m_vnum2:=m_vnum1:=100000
  ENDCASE
ELSE
  m_vnum1:=x1;m_vnum2:=x2
ENDIF

  FOR i:=1 TO LEN(a_file)
    SELECT(a_file[i])
    DBGOTOP()
  NEXT
  DO WHILE ( fz1->( !EOF() ) )
        DO WHILE ( fz1->vnum1 == fz2->vnum1 .AND. fz2->( !EOF() ) )
           IF ( fz1->vdoc >= 34 .AND. fz1->vdoc <= 37 )
              SetVnum(fz2,fz2t,vnum2,m_vnum2)
           ENDIF
           IF ( fz1->vdoc >= 38 .AND. fz1->vdoc <= 44 )
              SetVnum(fz2,fz2a,vnum2,m_vnum2)
           ENDIF
           IF ( fz1->vdoc == 37 )
              SetVnum(fz2,fz2tp,vnum2,m_vnum2)
           ENDIF
           IF ( fz1->vdoc != 38 .AND. fz1->vdoc != 42 .AND. fz1->vdoc != 44 )            // ТРАКТОРА
              SetVnum(fz2,fz3,vnum2,m_vnum2)
           ENDIF
           fz2->vnum2:=m_vnum2
           fz2->vnum1:=m_vnum1
           fz2->( DBSKIP() )
           m_vnum2++
        ENDDO
         IF ( fz1->vdoc >= 34 .AND. fz1->vdoc <= 37 )
              SetVnum(fz1,fz1t,vnum1,m_vnum1)
         ENDIF
     IF ( fz1->vdoc == 40 )
              SetVnum(fz1,fz1ap,vnum1,m_vnum1)
     ENDIF
     IF ( fz1->vdoc >= 38 .AND. fz1->vdoc <= 44 )
              SetVnum(fz1,fz1ae,vnum1,m_vnum1)
              SetVnum(fz1,fz1at,vnum1,m_vnum1)
     ENDIF
     fz1->vnum1:=m_vnum1
     fz1->(DBSKIP())
     m_vnum1++
     m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
  NET USE (m_path+"FVNUM.dbr") NEW
  IF fvnum->(NetRlock())
    fvnum->vnum1:=m_vnum1
    fvnum->vnum2:=m_vnum2
  ENDIF
  close fvnum

RETURN .T.
STATIC Function Checkbd2(m_path,l_code)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge
LOCAL l_buf
LOCAL s_sum,s_kvo,s_glv
LOCAL nSum2:=0,nKvo3:=0,nGlv2:=0
// Перевiрка структури утримань
  l_buf:=IF(m_path==m_mainpath,.f.,.t.)
  /* открытие справочников */
  SopenFiles("092",@s_file)
  NET USE (m_path+"fd1") NEW
  NET USE (m_path+"fd2") NEW
  NET USE (m_path+"fvnum.dbr") NEW ALIAS fvnum

  ?"-----Перевiрка утримань-----------------------------------"
  ?"Зроблена "+DMY(DATE())+" Оператор " +_fioFull(m_tabn)
  //Проверка на уникальность внутреннего номера
  n_err1:=CheckVnum(SELECT("fd1"),{||fd1->vnuma})
  IF n_err1<>0
    ?" Знайдено " +STR(n_err1,6) + " подвоєних кодiв при перевiрцi файла FD1"
  ENDIF
  fd1->( DBGOTOP() )
  m_gauge:=InitGauge("Перевiрка утримань",2)
  l_exit:=.f.
  m_npch:=fd1->npch;m_ndoc:=0
  ?"Пачка     Кiльк."
  ?"      документiв  Сума          Кiлькiсть Голiв "
  s_sum:=s_kvo:=s_glv:=0
  DO WHILE ( fd1->( !EOF() ) ).AND.n_fat==0

      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати перевiрку ?")==YES
            ?"Перевiрка утримнь прервана. Виконано  " +STR(100*fd1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
      IF l_buf
        IF mnt_month(fd1->mnt)<>month( fd1->ddoc )
            ?" Попередження ! Мiсяць документа не спiвпадає з мiсяцем розрахунку"
            ?? " Пачка:",fd1->npch,". Номер док.:",fd1->ndoc
        ENDIF
        IF fd1->mnt<>fvnum->mnt
            ?" Попередження !!! Не спiвпадає перiод розрахунку "
            ?? " Пачка:",fd1->npch,". Номер док.:",fd1->ndoc
            n_err3++
          ENDIF
      ENDIF
      CheckLink(fd1,fd2,vnuma)
           IF l_code
              CheckKod(sp08,fd1->kopu,fd1,"утримань")
           ENDIF
        /* если совпадение по внутренним номерам */
        DO WHILE ( fd1->vnuma == fd2->vnuma .AND. fd2->( !EOF() ) )
           IF l_code
              CheckKod(sp10,fd2->tabn,fd1,"таб. номер")
           ENDIF
           s_sum+=fd2->sum
           s_kvo+=fd2->kvo
           s_glv+=fd2->glv
           nSum2 := nSum2 + fd2->sum
           nKvo3 := nKvo3 + fd2->kvo
           nGlv2 := nGlv2 + fd2->glv
           fd2->( DBSKIP() )
        ENDDO
     fd1->(DBSKIP())
     m_ndoc++
     m_gauge:=DispGauge(m_gauge,fd1->(RECNO()/LASTREC()))
      /* подсчет количества документов */
      IF m_npch<>fd1->npch
        ?STR(m_npch,6), " - " ,STR(m_ndoc,3),SumToStr(s_sum,10),NumToStr(s_kvo,10,2),NumToStr(s_glv,10,0)
        m_npch:=fd1->npch;m_ndoc:=0
        s_sum:=s_kvo:=s_glv:=0
      ENDIF
  ENDDO

  IF .NOT.l_exit
    ?"Перевiрка утримань завершена"
    ? " Контр. сумма "
    ?"  Сума         ", SumToSTR( nSum2, 12)
    ?"  Кiлькiсть    ", NumToSTR( nKvo3, 12, 2)
    ?"  Голiв        ",NumToSTR( nGlv2, 10)
  ENDIF
  ScloseFiles(s_file)
  CLOSE BASE fd1,fd2,fvnum
  DelGauge(m_gauge)
  IF n_fat==0.AND.n_error==0
    return .t.
  ENDIF
RETURN .f.
STATIC Function Chan02(m_path)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge,k:=0,i
LOCAL a_file:={"fd1","fd2"}

FOR i:=1 TO LEN(a_file)
  FILECOPY(m_path+a_file[i]+".dbf"   ,m_temppath+a_file[i]+".dbf"   )
  USE (m_temppath+a_file[i])   NEW
NEXT
  ?"-----Лiкування бази даних утримань -----------------------------------"
  ?"Зроблено "+DMY(DATE())+" Оператор "  + m_imja
  m_gauge:=InitGauge("Лiкування утримань",2)
  l_exit:=.f.
DO WHILE .NOT.l_exit
  FOR i:=1 TO LEN(a_file)
    SELECT(a_file[i])
    DBGOTOP()
  NEXT
  n_error:=0;k++
  ?STR(k,3)," перегляд бази даних"
  DO WHILE ( fd1->( !EOF() ) ).AND.n_fat==0
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати лiкуванння ?")==YES
            ?"Лiкування  утримань прервано. Виконано  " +STR(100*fd1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
      cherr2(SELECT("Fd1"),SELECT("Fd2"),"Vnuma")
        /* если совпадение по внутренним номерам */
        SkipVnum(fd1,fd2,vnuma)
     fd1->(DBSKIP())
     m_gauge:=DispGauge(m_gauge,fd1->(RECNO()/LASTREC()))
  ENDDO
  IF n_error==0
    EXIT
  ENDIF
ENDDO
DelGauge(m_gauge)
IF .NOT.l_exit
  IF ANSWERu("Виконувати перекодiровку; внутр. номерiв утримань?")==YES
    ?"Перекодiровка внутр. номерiв"
    perekod2(m_path,a_file)
  ENDIF
  ?"Лiкування завершено"
  CLOSE BASE fd1,fd2
  IF n_error==0
    FOR i:=1 TO LEN(a_file)
      k:=FERASE(m_path+a_file[i]+".dbf")
      IF k==-1
        DispError("Помилка при видаленнi файла "+a_file[i]+";База даних"+m_path+" зруйнована")
      ELSE
        FILECOPY(m_temppath+a_file[i]+".dbf",m_path+a_file[i]+".dbf")
      ENDIF
    NEXT
  ENDIF
return .t.
ENDIF
CLOSE BASE fd1,fd2
return .f.
STATIC FUNCTION perekod2(m_path,a_file,x1)
LOCAL m_gauge,m_vnuma,i

m_gauge:=InitGauge("Перекодiровка",2)
IF x1==NIL
DO CASE
  CASE m_path==m_mainpath
    m_vnuma:=1
  CASE m_computer>=1.AND.m_computer<=8
    m_vnuma:=m_computer*100000
  OTHERWISE
    m_vnuma:=100000
ENDCASE
ELSE
  m_vnuma:=x1
ENDIF

  FOR i:=1 TO LEN(a_file)
    SELECT(a_file[i])
    DBGOTOP()
  NEXT
  DO WHILE ( fd1->( !EOF() ) )
     SetVnum(fd1,fd2,vnuma,m_vnuma)
     fd1->vnuma:=m_vnuma
     fd1->(DBSKIP())
     m_vnuma++
     m_gauge:=DispGauge(m_gauge,fd1->(RECNO()/LASTREC()))
  ENDDO
  NET USE (m_path+"FVNUM.dbr") NEW
  IF fvnum->(NetRlock())
    fvnum->vnuma:=m_vnuma
  ENDIF
  close fvnum
RETURN .T.

STATIC Function Checkbd3(m_path,l_code)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge
LOCAL l_buf,s_glv:=0,s_kvo1:=0,s_kvo2:=0,n_sum:=0,n_kvo1:=0,n_kvo2:=0
LOCAL s_sum:=0,n_glv:=0
  l_buf:=IF(m_path==m_mainpath,.f.,.t.)
  /* открытие справочников */
  SopenFiles("093",@s_file)
  NET USE (m_path+"funnum") NEW
  NET USE (m_path+"fkvo2") NEW
  NET USE (m_path+"fglv") NEW
  NET USE (m_path+"fdbcr") NEW
  NET USE (m_path+"ftabn") NEW
  NET USE (m_path+"fntr") NEW
  NET USE (m_path+"fgnavt") NEW
  NET USE (m_path+"fvnum.dbr") NEW ALIAS fvnum

  ?"-----Перевiрка проводок-----------------------------------"
  ?"Зроблена "+DMY(DATE())+" Оператор " +_fioFull(m_tabn)
  //Проверка на уникальность внутреннего номера
  n_err1:=CheckVnum(SELECT("funnum"),{||funnum->vnum})
  IF n_err1<>0
    ?" Знайдено " +STR(n_err1,6) + " подвоєних кодiв при перевiрцi файла FUNNUM"
  ENDIF
  m_gauge:=InitGauge("Перевiрка проводок",2)
  l_exit:=.f.
  funnum->(DBGOTOP());fdbcr->(DBGOTOP());fkvo2->(DBGOTOP())
  fglv->(DBGOTOP());ftabn->(DBGOTOP());fntr->(DBGOTOP())
  fgnavt->(DBGOTOP())
  ?"Пачка     Кiльк."
  ?"      документiв    Сума           Кiлькiсть 1 Кiлькiсть 2  Голiв"
  s_sum:=s_kvo1:=s_kvo2:=s_glv:=0
  m_npch:=funnum->npch;m_ndoc:=0
  DO WHILE ( funnum->( !EOF() ) ).AND.n_fat==0
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати перевiрку ?")==YES
            ?"Перевiрка проводок прервана. Виконано  " +STR(100*funnum->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
/*      IF l_buf
        IF mnt_month(funnum->mnt)<>month( funnum->ddoc )
            ?" Попередження ! Мiсяць документа не спiвпадає з мiсяцем розрахунку"
            ?? " Пачка:",funnum->npch,". Номер док.:",funnum->ndoc
        ENDIF
        IF funnum->mnt<>fvnum->mnt
            ?" Попередження !!! Не спiвпадає перiод розрахунку "
            ?? " Пачка:",funnum->npch,". Номер док.:",funnum->ndoc
            n_err3++
          ENDIF
      ENDIF
*/
      CheckLink(funnum,fdbcr,vnum)
           IF l_code
              IF .NOT.EMPTY(funnum->brgd)
                CheckKod(sp01,funnum->brgd,funnum,"бригади")
              ENDIF
              IF .NOT.EMPTY(funnum->kopr)
                CheckKod(sp05,funnum->kopr,funnum,"операцiї")
              ENDIF
              IF .NOT.EMPTY(funnum->otp)
                CheckKod(sp02,funnum->otp,funnum,"вiдправникa")
              ENDIF
              /* проверка поля funnum->kplh по sp02 */
              IF .NOT.EMPTY(funnum->kplh)
                CheckKod(sp02,funnum->kplh,funnum,"одержувача")
              ENDIF
           ENDIF
        /* если совпадение по внутренним номерам */
        DO WHILE ( funnum->vnum == fdbcr->vnum .AND. fdbcr->( !EOF() ) )
           IF l_code
              CheckKod(sp44,fdbcr->dbt,funnum,"дебетa")
              CheckKod(sp44,fdbcr->crt,funnum,"кредiта")
           ENDIF
           s_sum+=fdbcr->stm
           s_kvo2+=fdbcr->kvo
           n_sum+=fdbcr->stm
           n_kvo2+=fdbcr->kvo
            n_Glv+=fdbcr->glv
            s_glv+=fdbcr->glv
            n_KVO1 +=fdbcr->kvo2
            s_KVO1 +=fdbcr->kvo2
           fdbcr->( DBSKIP() )
        ENDDO
     IF ( funnum->vdoc >= 200 .AND. funnum->vdoc <= 299 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
            CheckLink(funnum,fglv,vnum)
           DO WHILE ( fglv->vnum == funnum->vnum .AND. fglv->( !EOF() ) )
              n_Glv+=fglv->glv
              s_glv+=fglv->glv
              fglv->( DBSKIP() )
           ENDDO

     ENDIF
     IF ( funnum->vdoc >= 100 .AND. funnum->vdoc <= 199 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
            CheckLink(funnum,fkvo2,vnum)
           DO WHILE ( fkvo2->vnum == funnum->vnum .AND. fkvo2->( !EOF() ) )
              n_KVO1 +=fkvo2->kvo2
              s_KVO1 +=fkvo2->kvo2
              fkvo2->( DBSKIP() )
           ENDDO

     ENDIF

     IF ( funnum->vdoc == 1 .OR. funnum->vdoc == 2  .OR. funnum->vdoc == 4  .OR. funnum->vdoc == 5 )
           CheckLink(funnum,ftabn,vnum)
           DO WHILE ( ftabn->vnum == funnum->vnum .AND. ftabn->( !EOF() ) )
              IF  l_code
                CheckKod(sp10,ftabn->tabn,funnum,"таб. номер")
              ENDIF
              ftabn->( DBSKIP() )
           ENDDO
     ENDIF
     IF ( funnum->vdoc == 1  .OR. funnum->vdoc == 4 )
        CheckLink(funnum,fntr,vnum)
           DO WHILE ( fntr->vnum == funnum->vnum .AND. fntr->( !EOF() ) )
              IF l_code
                CheckKod(inv_t,inv_t->invnum,funnum,"трактору")
              ENDIF
              fntr->( DBSKIP() )
           ENDDO

     ENDIF
     IF ( funnum->vdoc == 2  .OR. funnum->vdoc == 5 )
        /* проверка связки funnum->fgnavt */
        CheckLink(funnum,fgnavt,vnum)
           DO WHILE ( fgnavt->vnum == funnum->vnum .AND. fgnavt->( !EOF() ) )
              IF  l_code
                CheckKod(inv_a,inv_a->gnavt,funnum,"гар. номера")
              ENDIF
              fgnavt->( DBSKIP() )
           ENDDO

     ENDIF
     funnum->(DBSKIP())
     m_ndoc++
     m_gauge:=DispGauge(m_gauge,funnum->(RECNO()/LASTREC()))
      /* подсчет количества документов */
      IF m_npch<>funnum->npch
        ?STR(m_npch,6), " - " ,STR(m_ndoc,3),SumToStr(s_sum,14),NumToStr(s_kvo1,10,2),NumToStr(s_kvo2,10,2),NumToStr(s_glv,10,0)
        m_npch:=funnum->npch;m_ndoc:=0
        s_sum:=s_kvo1:=s_kvo2:=s_glv:=0
      ENDIF
  ENDDO
  DelGauge(m_gauge)
  IF .NOT.l_exit
    ?"Перевiрка проводок завершена"
    ? " Контр. сумма "
    ?"  Сума         ", SumToSTR( n_Sum, 14)
    ?"  Кiлькiсть    ", SumToSTR( n_Kvo1, 14)
    ?"  Кiлькiсть   2", SumToSTR( n_Kvo2, 14)
    ?"  Голiв        ",NumToSTR( n_Glv, 12)
  ENDIF
  ScloseFiles(s_file)
  CLOSE BASE funnum,fdbcr,fgnavt,fntr,fkvo2,ftabn,fglv,fvnum
  IF n_fat==0.AND.n_error==0
    return .t.
  ENDIF
RETURN .f.
STATIC Function Chan03(m_path)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge,k:=0,i
LOCAL a_file:={"funnum","fdbcr","fkvo2","fglv","ftabn","fntr","fgnavt"}

FOR i:=1 TO LEN(a_file)
  FILECOPY(m_path+a_file[i]+".dbf"   ,m_temppath+a_file[i]+".dbf"   )
  USE (m_temppath+a_file[i])   NEW
NEXT
  ?"-----Лiкування бази даних проводок-----------------------------------"
  ?"Зроблено "+DMY(DATE())+" Оператор "  + m_imja
  m_gauge:=InitGauge("Лiкування проводок",2)
  l_exit:=.f.
DO WHILE .NOT.l_exit
  FOR i:=1 TO LEN(a_file)
    SELECT(a_file[i])
    DBGOTOP()
  NEXT
  n_error:=0;k++
  ?STR(k,3)," перегляд бази даних"
  DO WHILE ( funnum->( !EOF() ) ).AND.n_fat==0
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати лiкуванння ?")==YES
            ?"Лiкування  проводок прервано. Виконано  " +STR(100*funnum->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
      cherr2(SELECT("funnum"),SELECT("fdbcr"),"vnum")
        /* если совпадение по внутренним номерам */
      DO WHILE ( funnum->vnum == fdbcr->vnum .AND. fdbcr->( !EOF() ) )
           fdbcr->( DBSKIP() )
      ENDDO
     IF ( funnum->vdoc >= 200 .AND. funnum->vdoc <= 299 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
           ChErr2(SELECT("funnum"),SELECT("fglv"),"vnum")
           SkipVnum(funnum,fglv,vnum)
     ENDIF
     IF ( funnum->vdoc >= 100 .AND. funnum->vdoc <= 199 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
           ChErr2(SELECT("funnum"),SELECT("fkvo2"),"vnum")
           SkipVnum(funnum,fkvo2,vnum)
     ENDIF

     IF ( funnum->vdoc == 1 .OR. funnum->vdoc == 2  .OR. funnum->vdoc == 4  .OR. funnum->vdoc == 5 )
           /* если нарушена целостность */
           ChErr2(SELECT("funnum"),SELECT("ftabn"),"vnum")
           SkipVnum(funnum,ftabn,vnum)
     ENDIF
     IF ( funnum->vdoc == 1  .OR. funnum->vdoc == 4 )
           ChErr2(SELECT("funnum"),SELECT("fntr"),"vnum")
           SkipVnum(funnum,fntr,vnum)
     ENDIF
     IF ( funnum->vdoc == 2.OR.funnum->vdoc == 5 )
           ChErr2(SELECT("funnum"),SELECT("fgnavt"),"vnum")
           SkipVnum(funnum,fgnavt,vnum)
     ENDIF
     funnum->(DBSKIP())
     m_gauge:=DispGauge(m_gauge,funnum->(RECNO()/LASTREC()))
  ENDDO
  IF n_error==0
    EXIT
  ENDIF
ENDDO
DelGauge(m_gauge)
IF .NOT.l_exit
  IF ANSWERu("Виконувати перекодiровку; внутр. номерiв проводок?")==YES
    ?"Перекодiровка внутр. номерiв"
    perekod3(m_path,a_file)
  ENDIF
  ?"Лiкування завершено"
  CLOSE BASE funnum,fdbcr,fkvo2,ftabn,fglv,fntr,fgnavt
  IF n_error==0
    FOR i:=1 TO LEN(a_file)
      k:=FERASE(m_path+a_file[i]+".dbf")
      IF k==-1
        DispError("Помилка при видаленнi файла "+a_file[i]+";База даних"+m_path+" зруйнована")
      ELSE
        FILECOPY(m_temppath+a_file[i]+".dbf",m_path+a_file[i]+".dbf")
      ENDIF
    NEXT
  ENDIF
return .t.
ENDIF
  CLOSE BASE funnum,fdbcr,fkvo2,ftabn,fglv,fntr,fgnavt
return .f.
STATIC FUNCTION perekod3(m_path,a_file,x1)
LOCAL m_gauge,m_vnum,i

m_gauge:=InitGauge("Перекодiровка",2)
IF x1==NIL
DO CASE
  CASE m_path==m_mainpath
    m_vnum:=1
  CASE m_computer>=1.AND.m_computer<=8
    m_vnum:=m_computer*100000
  OTHERWISE
    m_vnum:=100000
ENDCASE
ELSE
  m_vnum:=x1
ENDIF

  FOR i:=1 TO LEN(a_file)
    SELECT(a_file[i])
    DBGOTOP()
  NEXT
  DO WHILE ( funnum->( !EOF() ) )
     SetVnum(funnum,fdbcr,vnum,m_vnum)
     IF ( funnum->vdoc >= 200 .AND. funnum->vdoc <= 299 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
        SetVnum(funnum,fglv,vnum,m_vnum)
     ENDIF
     IF ( funnum->vdoc >= 100 .AND. funnum->vdoc <= 199 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )
        SetVnum(funnum,fkvo2,vnum,m_vnum)
     ENDIF
     IF ( funnum->vdoc == 1 .OR. funnum->vdoc == 2  .OR. funnum->vdoc == 4  .OR. funnum->vdoc == 5 )
           /* если нарушена целостность */
        SetVnum(funnum,ftabn,vnum,m_vnum)
     ENDIF
     IF ( funnum->vdoc == 1  .OR. funnum->vdoc == 4 )
        SetVnum(funnum,fntr,vnum,m_vnum)
     ENDIF
     IF ( funnum->vdoc == 2.OR.funnum->vdoc == 5 )
        SetVnum(funnum,fgnavt,vnum,m_vnum)
     ENDIF
     funnum->vnum:=m_vnum
     funnum->(DBSKIP())
     m_vnum++
     m_gauge:=DispGauge(m_gauge,funnum->(RECNO()/LASTREC()))
  ENDDO
  NET USE (m_path+"FVNUM.dbr") NEW
  IF fvnum->(NetRlock())
    fvnum->vnum:=m_vnum
  ENDIF
  close fvnum
RETURN .T.

STATIC Function Checkbd4(m_path,l_code)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc:=0,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge
LOCAL l_buf
LOCAL s_sum,s_kvo,s_glv
LOCAL nSum2:=0,nKvo3:=0,nGlv2:=0
// Перевiрка структури утримань
  l_buf:=IF(m_path==m_mainpath,.f.,.t.)
  /* открытие справочников */
  SopenFiles("094",@s_file)
  NET USE (m_path+"boln1") NEW
  NET USE (m_path+"boln2") NEW
  INDEX ON boln2->vnumc TO (m_path+"boln2")

  NET USE (m_path+"fvnum.dbr") NEW ALIAS fvnum

  ?"-----Перевiрка лiкарняних-----------------------------------"
  ?"Зроблена "+DMY(DATE())+" Оператор " +_fioFull(m_tabn)
  //Проверка на уникальность внутреннего номера
  n_err1:=CheckVnum(SELECT("boln1"),{||boln1->vnumc})
  IF n_err1<>0
    ?" Знайдено " +STR(n_err1,6) + " подвоєних кодiв при перевiрцi файла boln1"
  ENDIF
  boln1->( DBGOTOP() )
  m_gauge:=InitGauge("Перевiрка лiкарняного",2)
  l_exit:=.f.
  s_sum:=s_kvo:=0
  DO WHILE ( boln1->( !EOF() ) ).AND.n_fat==0
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати перевiрку ?")==YES
            ?"Перевiрка лiкарняних прервана. Виконано  " +STR(100*boln1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF
//      CheckLink(boln1,boln2,vnumc)
           IF l_code
              CheckKod(sp08,boln1->kopu,boln1,"оплати")
              CheckKod(sp10,boln1->tabn,boln1,"таб. номер")
              CheckKod(sp44,boln1->ksash,boln1,"рахунок")
           ENDIF
        /* если совпадение по внутренним номерам */
      IF .NOT.boln2->(DS(boln1->vnumc))
        ?" Помилка !!! boln1->boln2 vnumc=",boln1->vnumc," #",STR(boln1->(RECNO()),6)
        n_error++
      ELSE
        DO WHILE ( boln1->vnumc == boln2->vnumc .AND. boln2->( !EOF() ) )
           IF l_code
           ENDIF
           s_sum+=boln2->sum5
           boln2->( DBSKIP() )
        ENDDO
       ENDIF
     boln1->(DBSKIP())
     m_ndoc++
     m_gauge:=DispGauge(m_gauge,boln1->(RECNO()/LASTREC()))
  ENDDO
  IF .NOT.l_exit
    ?"Перевiрка лiкарняних завершена"
    ? " Контр. сумма "
    ?"  Сума         ", SumToSTR( s_Sum, 12)
    ?" Загальна кiлькiсть документiв ", SumToSTR( m_ndoc, 6)
  ENDIF
  ScloseFiles(s_file)
  CLOSE BASE boln1,boln2,fvnum
  DelGauge(m_gauge)
  IF n_fat==0.AND.n_error==0
    return .t.
  ENDIF
RETURN .f.
STATIC Function Chan04(m_path)
LOCAL s_file:={},n_err1:=0,n_err2:=0,m_npch,m_ndoc,m_vdoc,n_err3:=0
LOCAL l_exit:=.f.,n_fat:=0,m_gauge,k:=0,i
LOCAL a_file:={"boln1","boln2"}

FOR i:=1 TO LEN(a_file)
  FILECOPY(m_path+a_file[i]+".dbf"   ,m_temppath+a_file[i]+".dbf"   )
  USE (m_temppath+a_file[i])   NEW
NEXT
  ?"-----Лiкування бази даних лiкарняних -----------------------------------"
  ?"Зроблено "+DMY(DATE())+" Оператор "  + m_imja
  m_gauge:=InitGauge("Лiкування лiкарняних",2)
  l_exit:=.f.
  sele boln2
  INDEX ON boln2->vnumc TO (m_temppath+"boln2")

DO WHILE .NOT.l_exit
  FOR i:=1 TO LEN(a_file)
    SELECT(a_file[i])
    DBGOTOP()
  NEXT
  n_error:=0;k++
  ?STR(k,3)," перегляд бази даних"
  DO WHILE ( boln1->( !EOF() ) ).AND.n_fat==0
      IF( INKEY() == K_ESC )
         IF ANSWERu("Прервати лiкуванння ?")==YES
            ?"Лiкування  лiкарняних прервано. Виконано  " +STR(100*boln1->(RECNO()/LASTREC()),6,2) + "%"
            l_exit:=.t.
            EXIT
         ENDIF
      ENDIF


//      cherr2(SELECT("boln1"),SELECT("boln2"),"vnumc")
        IF .NOT.boln2->(DS(boln1->vnumc))
          ?" Видалення !!! boln1->boln2 vnumc=",boln1->vnumc," #",STR(boln1->(RECNO()),6)
          ??" Cерiя ",boln1->ser," N",boln1->num
         ENDIF
        /* если совпадение по внутренним номерам */
//        SkipVnum(boln1,boln2,vnumc)
     boln1->(DBSKIP())
     m_gauge:=DispGauge(m_gauge,boln1->(RECNO()/LASTREC()))
  ENDDO
  IF n_error==0
    EXIT
  ENDIF
ENDDO
DelGauge(m_gauge)
IF .NOT.l_exit
  IF ANSWERu("Виконувати перекодiровку; внутр. номерiв лiкарняних?")==YES
    ?"Перекодiровка внутр. номерiв"
    perekod4(m_path,a_file)
  ENDIF
  ?"Лiкування завершено"
  CLOSE BASE boln1,boln2
  IF n_error==0
    FOR i:=1 TO LEN(a_file)
      k:=FERASE(m_path+a_file[i]+".dbf")
      IF k==-1
        DispError("Помилка при видаленнi файла "+a_file[i]+";База даних"+m_path+" зруйнована")
      ELSE
        FILECOPY(m_temppath+a_file[i]+".dbf",m_path+a_file[i]+".dbf")
      ENDIF
    NEXT
  ENDIF
return .t.
ENDIF
CLOSE BASE boln1,boln2
return .f.
STATIC FUNCTION perekod4(m_path,a_file,x1)
LOCAL m_gauge,m_vnumc,i

m_gauge:=InitGauge("Перекодiровка",2)
IF x1==NIL
DO CASE
  CASE m_path==m_mainpath
    m_vnumc:=1
  CASE m_computer>=1.AND.m_computer<=8
    m_vnumc:=m_computer*100000
  OTHERWISE
    m_vnumc:=100000
ENDCASE
ELSE
  m_vnumc:=x1
ENDIF
  boln1->(DBGOTOP())
  DO WHILE .not.(boln1->(EOF()))
//     SetVnum(boln1,boln2,vnumc,STR(m_vnumc,6))
     DO WHILE boln2->(DS(boln1->vnumc))
      boln2->vnumc:=STR(m_vnumc,6)
     ENDDO
     boln1->vnumc:=STR(m_vnumc,6)
     boln1->(DBSKIP())
     m_vnumc++
     m_gauge:=DispGauge(m_gauge,boln1->(RECNO()/LASTREC()))
  ENDDO
  NET USE (m_path+"FVNUM.dbr") NEW
  IF fvnum->(NetRlock())
    fvnum->vnumc:=m_vnumc
  ENDIF
  close fvnum
RETURN .T.



FUNCTION  Zapbd()
LOCAL aMenu2:={" Повнiстю"," Нарахування "," Утримання","Лiкарнянi"," Бухгалтерськi проводки"}
LOCAL n_win1,j
LOCAL a_bd1:={"fz1","fz2","fz2t","fz2a","fz2tp","fz3",;
"fz1t","fz1ap","fz1ae","fz1at"}
LOCAL a_bd2:={"fd1","fd2"}
LOCAL a_bd3:={"boln1","boln2"}
LOCAL a_bd4:={"funnum","fdbcr","fkvo2","fglv","ftabn","fntr","fgnavt"}
    j:=MyMenu("Виберiть документи",aMenu2,0,.f.)
    IF j==0
      RETURN .f.
    ENDIF
    DO CASE
      CASE j==1
        ZapFl(a_bd1)
        ZapFl(a_bd2)
        ZapFl(a_bd3)
        ZapFl(a_bd4)
      CASE j==2
        ZapFl(a_bd1)
      CASE j==3
        ZapFl(a_bd2)
      CASE j==4
        ZapFl(a_bd3)
      CASE j==5
        ZapFl(a_bd4)
    ENDCASE
RETURN .t.

STATIC Function ZapFl(a_file)
LOCAL i,n:=LEN(a_file),m_path:=m_bufpath,m_str
LOCAL spisok:={}
FOR i:=1 TO n
  IF ISBIT(FILEATTR(m_path+a_file[i]+".dbf"),6)
    AADD(spisok,a_file[i])
  ENDIF
NEXT
IF .NOT.EMPTY(spisok)
  m_str:="Увага !!! Не зроблена копiя файлiв "
  FOR i:=1 TO LEN(spisok)
    m_str+=spisok[i]+" "
  NEXT
  m_str+=";Данi будуть загубленi !!!"
  m_str+=";"+"Виконувати очистку бази"
  BeepErr()
  IF ALERT(m_str,{"Нi","Так"},"gr+/r,r/gr+")<>2
    RETURN .F.
  ENDIF
ENDIF
FOR i:=1 TO n
  USE (m_path+a_file[i]) NEW
  ZAP
  USE
NEXT
IndBd(m_bufpath)
RETURN .t.
Function CopyBd()
 LOCAL a_file:={},i,a1
LOCAL aMenu:={" БД за мiсяць"," БД з початку року","Довiдники"}
i:=MyMenu("Виберiть базу даних",aMenu,-3,.f.)
DO CASE
  CASE i==0
    return .f.
  CASE i==1
    a1:=DIRECTORY(m_bufpath+"*.*")
    FOR i:=1 TO LEN(a1)
      AADD(a_file,m_bufpath+a1[i,1])
    NEXT
    CopyFl(a_file,"База за мiсяць")
    RETURN .T.
  CASE i==2
    a1:=DIRECTORY(m_mainpath+"*.*")
    FOR i:=1 TO LEN(a1)
      AADD(a_file,m_mainpath+a1[i,1])
    NEXT
    CopyFl(a_file,"База з початку року")
    RETURN .T.
  CASE i==3
    a1:=DIRECTORY(m_sprpath+"*.*")
    FOR i:=1 TO LEN(a1)
      AADD(a_file,m_sprpath+a1[i,1])
    NEXT
    CopyFl(a_file,"Довiдники")
    RETURN .T.
ENDCASE
RETURN .f.
Function Copybdln()
  LOCAL m_path,m_gauge,a1:={},i,a_file:={}
  LOCAL a_choice:={"Повнiстю","База з початку року","Довiдники"}
  IF .NOT.NETWORK()
    DispError("Комп'ютерна мережа не активна")
    RETURN .f.
  ENDIF
  IF m_comPuter <> 1
    DispError("Це не основний комп'ютер ;Копiювання баз не можливо")
    RETURN .F.
  ENDIF
  IF .NOT.SelNetPath(m_path)
    RETURN .f.
  ENDIF
  i:=MyMenu("Виберiть базу",a_choice,,.f.)
  IF i==0
      return .f.
  ENDIF
  IF  i==1.OR.i==2
      a_file:=DIRECTORY(m_mainpath+"*.*")
      FOR i:=1 TO LEN(a_file)
        AADD(a1,m_mainpath+a_file[i,1])
      NEXT
  ENDIF
  IF  i==1.OR.i==3
      a_file:=DIRECTORY(m_sprpath+"*.*")
      FOR i:=1 TO LEN(a_file)
        AADD(a1,m_sprpath+a_file[i,1])
      NEXT
  ENDIF
  m_gauge:=InitGauge("Копiювання на допомiжний комп'ютер",2)
  FOR i:=1 TO LEN(a1)
    FILECOPY(a1[i],LEFT(m_path,1)+SUBSTR(a1[i],2))
    m_gauge:=DispGauge(m_gauge,i/LEN(a1))
  NEXT
RETURN .t.
STATIC Function  SelNetPath(m_netpath)  // Вибiр мереж. дiску
  LOCAL a_choice:={},i,j,n,cLocalName
 i:=0
  DO WHILE .t.
    cLocalName:=NETLOCNAME(i)
    i++
    IF EMPTY(cLocalName)
      EXIT
    ENDIF
    IF FILE(LEFT(cLocalName,1)+SUBSTR(m_exepath,2)+"computer.txt")
      AADD(a_choice,cLocalName+" "+MEMOREAD(LEFT(cLocalName,1)+SUBSTR(m_exepath,2)+"computer.txt"))
    ENDIF
  ENDDO
  IF EMPTY(a_choice)
    DispError("В мережi не знайдено бази Барсу")
    RETURN .f.
  ENDIF
  i:=MyMenu("Вибiр мережевої бази даних",a_choice)
  IF i==0
    RETURN .f.
  ENDIF
  m_netpath:=LEFT(a_choice[i],1)+SUBSTR(m_bufpath,2)
RETURN .t.
Function  DobBd()
  LOCAL m_path,m_gauge,m_netpath,m_message,i
  LOCAL aMenu2:={" Повнiстю"," Нарахування "," Утримання"," Лiкарнянi "," Бухгалтерськi проводки"}
  LOCAL a_choice1:={" З БД за мiсяць" ," По мережi"," З дiскети"}
  LOCAL a2:={{"fz1","fz2","fz2t","fz2a","fz2tp","fz3",;
"fz1t","fz1ap","fz1ae","fz1at"},{"fd1","fd2"},{"boln1","boln2"},;
{"funnum","fdbcr","fkvo2","fglv","ftabn","fntr","fgnavt"}}
  LOCAL a1:={},l1:=.t.,l2:=.t.,l3:=.t.,l4:=.t.
/*  IF m_computer<>1
    DispError("Це не основний компьютер")
    RETURN .f.
  ENDIF
  IF NETDISK(LEFT(m_mainpath,1))
    DispError("Основна база розмiщена;не на даному комп'ютерi")
    RETURN .f.
  ENDIF
*/
  i:=MyMenu("Виберiть базу",a_choice1,-3,.f.)
  DO CASE
    CASE i==0
      RETURN .f.
    CASE i==1
      i:=MyMenu(A_CHOICE1[i],aMenu2,0,.f.)
      DO CASE
        CASE i==0
          RETURN .F.
        CASE i==1
          AEVAL(a2[1],{|x|AADD(a1,x)})
          AEVAL(a2[2],{|x|AADD(a1,x)})
          AEVAL(a2[3],{|x|AADD(a1,x)})
          AEVAL(a2[4],{|x|AADD(a1,x)})
          l1:=.t.;l2:=.t.;l3:=.t.;l4:=.t.
        CASE i==2
          AEVAL(a2[1],{|x|AADD(a1,x)})
          l1:=.t.;l2:=.f.;l3:=.f.;l4:=.f.
        CASE i==3
          AEVAL(a2[2],{|x|AADD(a1,x)})
          l1:=.f.;l2:=.t.;l3:=.f.;l4:=.f.
        CASE i==4
          AEVAL(a2[3],{|x|AADD(a1,x)})
          l1:=.f.;l2:=.f.;l3:=.t.;l4:=.f.
        CASE i==5
          AEVAL(a2[4],{|x|AADD(a1,x)})
          l1:=.f.;l2:=.f.;l3:=.f.;l4:=.t.
      ENDCASE
      m_message:=DispMessage("Додавання з;бази за мiсяць")
      AppeBd(m_bufpath,a1,l1,l2,l3,l4)
      IndBd(m_mainpath)
      IndBd(m_bufpath)
    CASE i==2
      IF SelNetPath(@m_netpath)
        i:=MyMenu(A_CHOICE1[i],aMenu2,0,.f.)
        IF i==0
          RETURN .F.
        ENDIF
        m_message:=DispMessage("Додавання ;по мережi")
      DO CASE
        CASE i==0
          RETURN .F.
        CASE i==1
          AEVAL(a2[1],{|x|AADD(a1,x)})
          AEVAL(a2[2],{|x|AADD(a1,x)})
          AEVAL(a2[3],{|x|AADD(a1,x)})
          AEVAL(a2[4],{|x|AADD(a1,x)})
          l1:=.t.;l2:=.t.;l3:=.t.;l4:=.t.
        CASE i==2
          AEVAL(a2[1],{|x|AADD(a1,x)})
          l1:=.t.;l2:=.f.;l3:=.f.;l4:=.f.
        CASE i==3
          AEVAL(a2[2],{|x|AADD(a1,x)})
          l1:=.f.;l2:=.t.;l3:=.f.;l4:=.f.
        CASE i==4
          AEVAL(a2[3],{|x|AADD(a1,x)})
          l1:=.f.;l2:=.f.;l3:=.t.;l4:=.f.
        CASE i==5
          AEVAL(a2[4],{|x|AADD(a1,x)})
          l1:=.f.;l2:=.f.;l3:=.f.;l4:=.t.
      ENDCASE
        AppeBd(m_netpath,a1,l1,l2,l3,l4)
        IndBd(m_mainpath)
        IndBd(m_netpath)
      ENDIF
    CASE i==2
        IF Restfl1()
          AEVAL(a2[1],{|x|AADD(a1,x)})
          AEVAL(a2[2],{|x|AADD(a1,x)})
          AEVAL(a2[3],{|x|AADD(a1,x)})
          AEVAL(a2[4],{|x|AADD(a1,x)})
        m_message:=DispMessage("Додавання ;з дiскети")
        FOR i:=1 TO LEN(a1)
          IF UPPER(LEFT(m_temppath,1))==UPPER(LEFT(m_copypath,1))
            FILEMOVE(m_temppath+a1[i]+".dbf",m_copypath+a1[i]+".dbf")
          ELSE
            FILECOPY(m_temppath+a1[i]+".dbf",m_copypath+a1[i]+".dbf")
          ENDIF
        NEXT
        AppeBd(m_copypath,a1,.t.,.t.,.t.,.t.)
        IndBd(m_mainpath)
        ENDIF
  ENDCASE
return .T.
Function Perek()
  LOCAL a1:={"fz1","fz2","fz2t","fz2a","fz2tp","fz3",;
"fz1t","fz1ap","fz1ae","fz1at","fd1","fd2","boln1","boln2"},M_MESSAGE
      m_message:=DispMessage("Додавання з;бази за мiсяць")
      IF AppeBd(m_bufpath,a1,.T.,.T.,.T.,.F.)
        IndBd(m_mainpath)
        IndBd(m_bufpath)
        RETURN .T.
      ENDIF
delmessage(m_message)
RETURN .F.

/*
Function Perek()
  LOCAL a1:={"fz1","fz2","fz2t","fz2a","fz2tp","fz3",;
"fz1t","fz1ap","fz1ae","fz1at","fd1","fd2","boln1","boln2"}
LOCAL l_copy,i,a_file:={},n_win1,m_path:=m_bufpath,m_vnum1,m_vnum2,m_vnumc,m_vnuma
      SETPRC(0,0)
      SET PRINTER TO (m_mash+"46.txt")
      SET PRINTER ON
      n_win1:=WOPEN(0,0,8,80,.t.)
      Wselect(n_win1)
      WBOX(12)
      @-1,0 SayDisp PADC("Перевiрка даних",80) COLOR "n/w"
      SETPOS(0,0)
      n_error:=0
      IF .not.Checkbd1(m_path,.f.)
        IF ContApp("нарахувань",n_win1)
          RETURN .f.
        ENDIF
      ENDIF
      IF .not.Checkbd2(m_path,.f.)
        IF ContApp("утримань",n_win1)
          RETURN .f.
        ENDIF
      ENDIF
      IF .not.Checkbd4(m_path,.f.)
        IF ContApp("лiкарняних",n_win1)
          RETURN .f.
        ENDIF
      ENDIF
      DobMs1(STRZERO(MONTH(DATE()),2),STRZERO(MONTH(DATE()),2))
      Wclose(n_win1)
      SET PRINTER OFF
      SET PRINTER TO
      WSELECT(0)
      FOR i:=1 TO LEN(a1)
        FILECOPY(m_mainpath+a1[i]+".dbf",m_temppath+a1[i]+".dbf")
        FILECOPY(m_bufpath+a1[i]+".dbf",m_copypath+a1[i]+".dbf")
      NEXT
      NET USE (m_mainpath+"FVNUM.dbr") NEW
      IF fvnum->(NetRlock())
        m_vnum1:= fvnum->vnum1
        m_vnum2:= fvnum->vnum2
        m_vnuma:= fvnum->vnuma
        m_vnumc:= fvnum->vnumc
      ELSE
        close fvnum
        RETURN .F.
      ENDIF
      close fvnum
      FOR i:=1 TO LEN(a1)
        USE (m_copypath+a1[i]) NEW
      NEXT
      Perekod1(m_mainpath,a1,m_vnum1,m_vnum2)
      Perekod2(m_mainpath,a1,m_vnuma)
      Sele boln2
      INDEX ON boln2->vnumc TO (m_path+"boln2")
      Perekod4(m_mainpath,a1,m_vnumc)
      FOR i:=1 TO LEN(a1)
        DBSELECTAREA(a1[i])
        DBCLOSEAREA()
      NEXT
      FOR i:=1 TO LEN(a1)
        USE (m_temppath+a1[i]) NEW ALIAS File1
        APPEND FROM (m_copypath+a1[i])
        FERASE(m_copypath+a1[i]+".dbf")
        CLOSE File1
      NEXT
      FOR i:=1 TO LEN(a1)
        USE (m_path+a1[i]) NEW ALIAS File1
        ZAP
        CLOSE File1
      NEXT
      FOR i:=1 TO LEN(a1)
        FERASE(m_mainpath+a1[i]+".dbf")
        IF UPPER(LEFT(m_temppath,1))==UPPER(LEFT(m_mainpath,1))
          FILEMOVE(m_temppath+a1[i]+".dbf",m_mainpath+a1[i]+".dbf")
        ELSE
          FILECOPY(m_temppath+a1[i]+".dbf",m_mainpath+a1[i]+".dbf")
        ENDIF
      NEXT
      IndBd(m_bufpath)
      IndBd(m_mainpath)
RETURN .t.
*/

STATIC Function ContApp(s_str,n_win1)
  BeepErr()
  IF ALERT("При перевiрцi "+s_str+"нарахувань знайденi помилки;Продовжити ?",{"Нi","Так"},"gr+/r,r/gr+")<>2
    DispError("Додавання не виконано")
    INKEY(5)
    Wclose(n_win1)
    DobMs1(STRZERO(MONTH(DATE()),2),STRZERO(MONTH(DATE()),2))
    SET PRINTER OFF
    SET PRINTER TO
    WSELECT(0)
    RETURN .t.
  ENDIF
RETURN .F.

STATIC Function AppeBd(m_path,a1,l1,l2,l3,l4)
LOCAL l_copy,i,a_file:={},n_win1
LOCAL m_vnum1,m_vnum2,m_vnumc,m_vnuma,m_vnum
      l_copy:=.f.
      FOR i:=1 TO LEN(a1)
        IF IsBit(FILEATTR(m_path+a1[i]+".dbf"),6)
          l_copy:=.t.
          EXIT
        ENDIF
      NEXT
      IF l_copy
        IF ANSWERu("Дуже рекомендую зробити копiю;бази даних!;Робити копiю?")==YES
          a_file:={}
          FOR i:=1 TO LEN(a1)
            AADD(a_file,m_path+a1[i]+".dbf")
          NEXT
          COpyFl(a_file,"База даних за мiсяць")
        ENDIF
      ENDIF
      SETPRC(0,0)
      SET PRINTER TO (m_mash+"46.txt")
      SET PRINTER ON
      n_win1:=WOPEN(0,0,8,80,.t.)
      Wselect(n_win1)
      WBOX(12)
      @-1,0 SayDisp PADC("Перевiрка даних",80) COLOR "n/w"
      SETPOS(0,0)
      n_error:=0
      IF l1
      IF .not.Checkbd1(m_path,.f.)
        IF ContApp("нарахувань",n_win1)
          RETURN .f.
        ENDIF
      ENDIF
      ENDIF
      IF l2
      IF .not.Checkbd2(m_path,.f.)
        IF ContApp("утримань",n_win1)
          RETURN .f.
        ENDIF
      ENDIF
      ENDIF
      IF l3
      IF .not.Checkbd4(m_path,.f.)
        IF ContApp("лiкарняних",n_win1)
          RETURN .f.
        ENDIF
      ENDIF
      ENDIF
      IF l4
      IF .not.Checkbd3(m_path,.f.)
        IF ContApp("проводок",n_win1)
          RETURN .f.
        ENDIF
      ENDIF
      ENDIF
      INKEY(5)
      DobMs1(STRZERO(MONTH(DATE()),2),STRZERO(MONTH(DATE()),2))
      Wclose(n_win1)
      SET PRINTER OFF
      SET PRINTER TO
      WSELECT(0)
      FOR i:=1 TO LEN(a1)
        FILECOPY(m_mainpath+a1[i]+".dbf",m_temppath+a1[i]+".dbf")
        IF m_path<>m_copypath
          FILECOPY(m_path+a1[i]+".dbf",m_copypath+a1[i]+".dbf")
        ENDIF
        USE (m_copypath+a1[i]) NEW
      NEXT
      NET USE (m_mainpath+"FVNUM.dbr") NEW
      IF fvnum->(NetRlock())
        m_vnum1:= fvnum->vnum1
        m_vnum2:= fvnum->vnum2
        m_vnum := fvnum->vnum
        m_vnuma:= fvnum->vnuma
        m_vnumc:= fvnum->vnumc
      ELSE
        close fvnum
        RETURN .F.
      ENDIF
      close fvnum
      IF l1
        Perekod1(m_mainpath,a1,m_vnum1,m_vnum2)
      ENDIF
      IF l2
        Perekod2(m_mainpath,a1,m_vnuma)
      ENDIF
      IF l3
        Sele boln2
        INDEX ON boln2->vnumc TO (m_path+"boln2")
        Perekod4(m_mainpath,a1,m_vnumc)
      ENDIF
      IF l4
        Perekod3(m_mainpath,a1,m_vnum)
      ENDIF
      FOR i:=1 TO LEN(a1)
        DBSELECTAREA(a1[i])
        DBCLOSEAREA()
      NEXT
      FOR i:=1 TO LEN(a1)
        USE (m_temppath+a1[i]) NEW ALIAS File1
        APPEND FROM (m_copypath+a1[i])
        FERASE(m_copypath+a1[i]+".dbf")
        CLOSE File1
      NEXT
      IF   m_path<>m_copypath
        FOR i:=1 TO LEN(a1)
          USE (m_path+a1[i]) NEW ALIAS File1
          ZAP
          CLOSE File1
        NEXT
      ENDIF
      FOR i:=1 TO LEN(a1)
        FERASE(m_mainpath+a1[i]+".dbf")
        IF UPPER(LEFT(m_temppath,1))==UPPER(LEFT(m_mainpath,1))
          FILEMOVE(m_temppath+a1[i]+".dbf",m_mainpath+a1[i]+".dbf")
        ELSE
          FILECOPY(m_temppath+a1[i]+".dbf",m_mainpath+a1[i]+".dbf")
        ENDIF
      NEXT

RETURN .t.

Function EditMnt()
  LOCAL GetList:={}
     NET USE (m_bufpath+"fvnum.dbr") NEW
     IF fvnum->(NetRlock())
      @9,9,11,70 BOX B_DOUBLE+" " COLOR "w+/BG"
      @10,12 SayDisp "Розрахунковий перiод" COLOR "GR+/BG"
      @10,33 GET fvnum->mnt PICTURE "99.99" COLOR "GR+/N"
      GetList[1]:Block:={|x|IF(x==NIL,RIGHT(field->mnt,2)+"."+LEFT(field->mnt,2),field->mnt:=RIGHT(x,2)+LEFT(x,2))}
      GetList[1]:PostBlock:={|p|(EMPTY(LEFT(p,2)).AND.EMPTY(RIGHT(p,2))).OR.(LEFT(p,2)>="01".AND.LEFT(p,2)<="12".AND.RIGHT(p,2)<="99".AND.RIGHT(p,2)>="00")}
      READ
      fvnum->(DbUnlock())
    ENDIF
    CLOSE fvnum
RETURN .t.
STATIC FUNCTION Checkww(n1,kod,n2,name)
IF .NOT.(n1)->(DS(kod))
  ?"  Увага, не визн. код "+name, kod
  ??"   Пачка:",(n2)->npch,"N",(n2)->ndoc
ENDIF
return .t.
STATIC FUNCTION SkipVn(n1,n2,s1)
LOCAL b1:=(n1)->(FIELDBLOCK(s1))
LOCAL b2:=(n2)->(FIELDBLOCK(s1))
DO WHILE (n1)->(EVAL(b1))==(n2)->(EVAL(b2)).AND..NOT.(n2)->(EOF())
  (n2)->(DBSKIP())
ENDDO
RETURN .t.
STATIC FUNCTION SkipVn1(n1,n2,s1,v1)
LOCAL b1:=(n1)->(FIELDBLOCK(s1))
LOCAL b2:=(n2)->(FIELDBLOCK(s1))
DO WHILE (n1)->(EVAL(b1))==(n2)->(EVAL(b2)).AND..NOT.(n2)->(EOF())
  (n2)->(EVAL(b2,v1))
  (n2)->(DBSKIP())
ENDDO
RETURN .t.
