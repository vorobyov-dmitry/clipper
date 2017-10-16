#include "new.ch"
memvar m_workpath,m_temppath,m_sprpath,m_bufpath
Function Provod()
  LOCAL n_error,n_win1,m_gauge,m_mol:="  ",m_ddoc1:=DATE(),m_ddoc2:=DATE(),;
  m_log,m_kod1,n,n_count:=0,m_672000,k_nds,m_680000,k_77,;
  m_prise,m_15,m_pension,m_671000,m_810000,k_79,n_nds:=0,s_files:={}
  InitNds()
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
  NET USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") NEW ALIAS myvar
//  m_671000:=RestVar1("m_671000","NK")
//  m_672000:=RestVar1("m_672000","NK")
  m_680000:=RestVar1("m_680000","NK")
  m_810000:=RestVar1("m_810000","NK")
  m_pension:=RestVar1("m_pension","NK")
  k_77:=RestVar1("k_77","NK")
  k_79:=RestVar1("k_79","NK")
  k_nds:=RestVar1("k_nds","NK")
  m_15:=RestVar1("m_15","NK")
  CLOSE myvar
  USE (m_temppath+"buf1") INDEX (m_temppath+"buf1") NEW
  MyCreate("PROV01","prov")
  SETPRC(0,0)
  SET PRINTER TO (m_workpath+"41.txt")
  SET PRINTER ON
m_gauge:=InitGauge("Вибiрка iз накладних",2)
n_win1:=WOPEN(0,0,8,80,.t.)
Wselect(n_win1)
WBOX(12)
@-1,0 SayDisp PADC("Формування проводок по комiрнику ("+m_mol+")"+RTRIM(_mol(m_mol)),80) COLOR "n/w"
SETPOS(0,0)
?"Формування проводок по комiрнику ("+m_mol+")"+RTRIM(_mol(m_mol))
?" за перiод з " +My_Dtos(m_ddoc1)+" по  "  +My_Dtos(m_ddoc2)
 NET USE (m_workpath+"nakl1") NEW ALIAS nakl1
 NET USE (m_workpath+"nakl2") INDEX (m_workpath+"nakl2")   NEW ALIAS nakl2
 NET USE (m_workpath+"nakl3") INDEX (m_workpath+"nakl3")   NEW ALIAS nakl3
 NET USE (m_workpath+"spr01") INDEX (m_workpath+"spr01")   NEW ALIAS spr01
 NET USE (m_workpath+"kaptka1") INDEX (m_workpath+"kaptka1"),(m_workpath+"kaptka1a"),(m_workpath+"kaptka1b") ALIAS kaptka1 NEW
 NET USE (m_workpath+"FIRM01") INDEX (m_workpath+"FIRM01"),(m_workpath+"FIRM01A"),(m_workpath+"FIRM01B") NEW

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
              Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
              Prov->kopr:=Spr01->kpr
              Prov->dbt:=Kaptka1->ksash
              Prov->cod1:=Nakl2->kod
              Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
              Prov->stm:=nakl2->stm
              IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                Prov->glv:=nakl2->glv
              ELSE
                Prov->kvo2:=nakl2->glv
              ENDIF
              Prov->kplh:=nakl1->otp
              DO CASE
                CASE m_kod1=="Г ".OR.m_kod1=="Г2"
                  IF NumPotr(Nakl1->kopr) == "1"
                    ZanPred0()
                    ZanNds0(k_nds,m_680000)
                  ELSE
                    ZanTabn()
                    ZanNds1(k_nds,m_680000)
                  ENDIF
                CASE m_kod1=="Г1"
                  IF NumPotr(Nakl1->kopr) == "1"
                    ZanPred0()
                  ELSE
                    ZanTabn()
                  ENDIF
//                  ZanNds0(k_nds,m_680000)
                CASE m_kod1=="П ".OR.m_kod1=="П1" // По перерахуванню
                  ZanPred0()
                CASE m_kod1=="П2"
                  ZanPred0()
                  ZanNds0(k_nds,m_680000)
                CASE m_kod1=="Б ".or.m_kod1=="Б2".or.m_kod1=="К " // Бартер
                  ZanPred0()
                  ZanNds0(k_nds,m_680000)
                CASE m_kod1=="Б1" // Бартер
                  ZanPred0()
//                  ZanNds0(k_nds,m_680000)
                  Prov->(DBAP())
                  Prov->ndoc:=nakl1->ndoc
                  Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
                  Prov->kopr:=k_nds
                  Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
                  IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                    Prov->glv:=nakl2->glv
                  ELSE
                    Prov->kvo2:=nakl2->glv
                  ENDIF
                  Firm01->(DBSETORDER(2))
                  Firm01->(DS(nakl1->okpo))
                  Firm01->(DBSETORDER(1))
                  Prov->dbt:="671"+RIGHT(Firm01->ksash,3)
                  Prov->crt:=m_680000
                  Prov->cod1:=Nakl1->okpo
                  Prov->cod2:=Nakl2->kod
//                  Prov->stm:=Nakl2->nds
                  Prov->stm:=n_nds*(nakl2->stm+nakl2->nds)
                  IF nakl2->nds<>0
                    Prov->(DBAP())
                    Prov->ndoc:=nakl1->ndoc
                    Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
                    Prov->kopr:=k_nds
                    Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
                    IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                      Prov->glv:=nakl2->glv
                    ELSE
                      Prov->kvo2:=nakl2->glv
                    ENDIF
                    Prov->dbt:="672"+RIGHT(Firm01->ksash,3)
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
                  Prov->brgd:=Nakl1->brgd
                CASE m_kod1=="Т " // Пiдзвiтнi особи
                  Prov->crt:=Nakl1->ksash
                  Prov->cod2:=Nakl1->tabn
                  ZanNds2(k_nds,m_680000)
                OTHERWISE
                  Wselect(n_win1)
                  ?"Помилка !!! Накладна N ",nakl1->ndoc," не проведена"
                  Wselect(0)
              ENDCASE
            CASE nakl1->vdoc>"0".and.m_log=="1" // расход без внутренней передачи
              Prov->(DBAP())
              Prov->ndoc:=nakl1->ndoc
              Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
              Prov->kopr:=Spr01->kpr
              Prov->cod2:=Nakl2->kod
              Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
              IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                Prov->glv:=nakl2->glv
              ELSE
                Prov->kvo2:=nakl2->glv
              ENDIF
              Prov->otp :=nakl1->otp
              Prov->crt:=Kaptka1->ksash
                  DO CASE
                      CASE m_kod1=="Г ".or.m_kod1=="Г1" // За готiвку
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                        IF NumPotr(Nakl1->kopr) == "1"
                          // Допомiжна по 76 рахунку
                          ZanPred()
                        ENDIF
                      CASE m_kod1=="Г2" // За готiвку
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                        IF NumPotr(Nakl1->kopr) == "1"
                          // Допомiжна по 76 рахунку
                          ZanPred()
                        ENDIF
                        ZanNds(k_nds,m_680000)
                      CASE m_kod1=="П ".or.m_kod1=="П2" // Поперерахуванню
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                        ZanPred()
                        ZanNds(k_nds,m_680000)
                      CASE m_kod1=="П1" // За готiвку
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                        ZanPred()
                      CASE m_kod1=="З ".or.m_kod1=="З2"// В рахунок заробiтньої плати
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                      CASE m_kod1=="Б ".OR.m_kod1=="К "
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                        ZanPred()
                        ZanNds(k_nds,m_680000)
                      CASE m_kod1=="Б1"
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                        ZanPred()
                        Prov->(DBAP())
                        Prov->ndoc:=nakl1->ndoc
                        Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
                        Prov->kopr:=k_nds
                        Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
                        IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                          Prov->glv:=nakl2->glv
                        ELSE
                          Prov->kvo2:=nakl2->glv
                        ENDIF
                        Firm01->(DBSETORDER(2))
                        Firm01->(DS(nakl1->okpo))
                        Firm01->(DBSETORDER(1))
                        Prov->crt:="671"+RIGHT(Firm01->ksash,3)
                        Prov->dbt:=kaptka1->ksash2
                        Prov->cod2:=Nakl1->okpo
                        Prov->cod1:=Nakl2->kod
                        Prov->stm:=Nakl2->nds
                        Prov->(DBAP())
                        Prov->ndoc:=nakl1->ndoc
                        Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
                        Prov->kopr:=k_nds
                        Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
                        IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                          Prov->glv:=nakl2->glv
                        ELSE
                          Prov->kvo2:=nakl2->glv
                        ENDIF
                        Prov->crt:="672"+RIGHT(Firm01->ksash,3)
                        Prov->dbt:=m_680000
                        Prov->cod2:=Nakl1->okpo
                        Prov->cod1:=Nakl2->kod
                        Prov->stm:=Nakl2->nds
                      CASE m_kod1=="Б2"
                        Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                        ZanPred()
                        ZanNds(k_nds,m_680000)
                      CASE m_kod1=="В " // Виробництво
                        IF LEFT(Kaptka1->ksash,2)<>"12" // Не мшп
                          Zanes03(Nakl1->ksash,;
                          IF(spr01->potr=="6",nakl1->gnavt,IF(spr01->potr=="7",nakl1->ntr,"")),Nakl1->brgd,.t.)
                        ELSE
                          Zanes03("122"+right(prov->crt,3),;
                          IF(spr01->potr=="6",nakl1->gnavt,IF(spr01->potr=="7",nakl1->ntr,"")),,.t.,k_77)
                          Prov->(DBAP())
                          Prov->ndoc:=nakl1->ndoc
                          Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
                          Prov->kopr:=m_15
                          Prov->cod2:=Nakl2->kod
                          Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
                          IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                            Prov->glv:=nakl2->glv
                          ELSE
                            Prov->kvo2:=nakl2->glv
                          ENDIF
                          Prov->crt:="131001"
                          Prov->brgd:=Nakl1->brgd
                          Prov->dbt:=Nakl1->ksash
                          Prov->stm:=nakl2->stm1
                         ENDIF
                        CASE m_kod1=="М " // IНШИЙ МВО
                          Zanes03(prov->crt,nakl2->kod,,.t.,k_77)
                          Prov->kplh:=Nakl1->mol
                        CASE m_kod1=="С " // Пенсiя
                          Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                          ZanPens(m_pension)
                          ZanNds(k_nds,m_680000)
                        CASE m_kod1=="Д " // Безповоротна допомога
                          Zanes03(kaptka1->ksash2,kaptka1->kod,,.f.)
                          ZanPens(m_810000)
                          ZanNds(k_nds,m_680000)
                        OTHERWISE
                          Wselect(n_win1)
                          ?"Помилка !!! Накладна N ",nakl1->ndoc," не проведена"
                          Wselect(0)
                    ENDCASE
          CASE nakl1->vdoc>"0".and.m_log=="0" // внутренняя передача одержання
              Prov->(DBAP())
              Prov->ndoc:=nakl1->ndoc
              Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
              Prov->kopr:=k_77
              Prov->dbt :=Kaptka1->ksash
              Prov->cod1:=Nakl2->kod
              Prov->crt :=Kaptka1->ksash
              Prov->cod2:=Nakl2->kod
              Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
              Prov->stm:=nakl2->stm1
              IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
                Prov->glv:=nakl2->glv
              ELSE
                Prov->kvo2:=nakl2->glv
              ENDIF
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
  NET USE (m_workpath+"NAKL5") new
  m_gauge:=InitGauge("Вибiрка даних по переводу ",2)
  DO WHILE .NOT.nakl5->(EOF())
  IF nakl5->ddoc>=m_ddoc1.AND.nakl5->ddoc<=m_ddoc2.and.Nakl5->mol==m_mol
      Prov->(DBAP())
      Prov->ndoc:=nakl5->ndoc
      Prov->ddoc:=IF(DAY(nakl5->ddoc)>25,CTOD(STUFF(DTOC(nakl5->ddoc),1,2,"25")),nakl5->ddoc)
      Kaptka1->(DS(nakl5->cod2))
      Prov->kopr:=k_79
      Prov->dbt :=Kaptka1->ksash
      Prov->cod1:=nakl5->cod2
      Kaptka1->(DS(nakl5->cod1))
      Prov->crt :=Kaptka1->ksash
      Prov->cod2:=nakl5->cod1
      Prov->kvo:=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl5->kvo
      Prov->stm:=nakl5->stm
      IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
        Prov->glv:=nakl5->glv
      ELSE
        Prov->kvo2:=nakl5->glv
      ENDIF
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
  Zanes02(m_mol,k_nds,m_ddoc1,m_ddoc2)
  WCLOSE(n_win1)
  wselect(0)
    ScloseFile(s_files)
  Close base buf1,prov,nakl1,nakl2,nakl3,firm01
  IF ANSWERu("Зберiгати таблицю проводок ?")==YES
    IF FILE(m_workpath+"PROV"+m_mol+".dbf")
      FERASE(m_workpath+"PROV"+m_mol+".dbf")
    ENDIF
    FILECOPY(m_temppath+"prov.dbf",m_workpath+"PROV"+m_mol+".dbf")
    STRFILE(m_mol+k_nds+DTOC(m_ddoc1)+DTOC(m_ddoc2)+"ьь",m_workpath+"PROV"+m_mol+".dbf",.t.)
  ENDIF
RETURN .t.
STATIC Function Zanes02(m_mol,k_nds,m_ddoc1,m_ddoc2)
LOCAL m_npch:=700+VAL(m_mol),l_first:=.T.,;
m_gauge,m_kod,l1,i
LOCAL m_browse,l_print,m_key,l_delete:=.t.,;
   m_br1,m_br2,l_pr1:={},l_pr2:={},;
   a_get:={},a_get1:={},a_get2:={}
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
  a_get1[4]:PreBlock:=a_get1[9]:PreBlock:=a_get1[11]:PreBlock:={||.f.}
  a_get1[12]:PreBlock:={||.t.}
  a_get1[3]:PostBlock:={||Sp05->(sp_vl("SP05","2"))}
  a_get1[5]:PostBlock:={||Sp01->(sp_vl("SP01","2"))}
  a_get1[6]:PostBlock:={||Sp02->(sp_vl("SP02","2"))}
  a_get1[7]:PostBlock:={||Sp02->(sp_vl("SP02","2"))}
  a_get1[8]:PostBlock:={||Sp44->(sp_vl("SP44"))}
  a_get1[10]:PostBlock:={||Sp44->(sp_vl("SP44"))}
  m_br2:=TBrowseDB(3,1,MAXROW()-1,MAXCOL()-1)
  m_br2:colorspec:='W/B,B/W,GR+/b,GR+/N,N/BG,w+/b'
  m_br2:colsep        := '│'
  m_br2:SkipBlock     := { |n| SkipDb(n) }
  m_br2:goBottomBlock := { ||  DBGOBOTTOM() }
  m_br2:goTopBlock    := { ||  DBGOTOP()  }
  m_br2:cargo:=m_br1:cargo:="Рух продукцiї по МВО "+m_mol+" "+ALLTRIM(_mol(m_mol))+" за перiод з "+DTOC(m_ddoc1)+" по "+DTOC(m_ddoc2)
  m_br2:freeze:=1
  ASIZE(a_get2,11)
  m_br2:AddColumn(m_br1:GetColumn(1));a_get2[1]:=a_get1[1]
  m_br2:AddColumn(m_br1:GetColumn(2));a_get2[2]:=a_get1[2]
  m_br2:AddColumn(m_br1:GetColumn(3));a_get2[3]:=a_get1[3]
  m_br2:AddColumn(m_br1:GetColumn(5));a_get2[4]:=a_get1[5]
  m_br2:AddColumn(m_br1:GetColumn(6));a_get2[5]:=a_get1[6]
  m_br2:AddColumn(m_br1:GetColumn(7));a_get2[6]:=a_get1[7]
  m_br2:AddColumn(m_br1:GetColumn(8));a_get2[7]:=a_get1[8]
  m_br2:AddColumn(m_br1:GetColumn(10));a_get2[8]:=a_get1[10]
  m_br2:AddColumn(m_br1:GetColumn(12));a_get2[9]:=a_get1[12]
  m_br2:AddColumn(m_br1:GetColumn(13));a_get2[10]:=a_get1[13]
  m_br2:AddColumn(m_br1:GetColumn(14));a_get2[11]:=a_get1[14]
  m_br2:AddColumn(m_br1:GetColumn(15));a_get2[12]:=a_get1[15]
  l_pr2:={.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.}
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
    CASE m_key==K_ALT_2
        m_browse:=m_br2;l_print:=l_pr2;a_get:=a_get2
        m_browse:rowPos:=1;m_browse:Colpos:=1
        m_browse:configure();m_browse:gotop()
         CASE m_Key == K_DEL                                    /* удаление записи */
                  IF (ANSWERu( "Ви дiiйсно бажаєте видалити строку ?" )==YES )
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
          USE (m_bufpath+"funnum") NEW
          USE (m_bufpath+"fdbcr") NEW
          USE (m_bufpath+"fglv") NEW
          USE (m_bufpath+"fvnum.dbr") NEW ALIAS fv
          DO WHILE .NOT. funnum->(EOF())
            IF funnum->oper=="N2".AND.funnum->ddoc>=m_ddoc1.AND.funnum->ddoc<=m_ddoc2.AND.m_npch==funnum->npch
              IF l_first
                IF ANSWERu("База вже мiстить проводки за отриману продукцiю;Удаляти цi документи?")<>YES
                   EXIT
                ENDIF
                l_first:=.f.
              ENDIF
              IF pFilPoz1('funnum', {||(funnum->vnum==fdbcr->vnum)} , 'fdbcr')
                DO WHILE .NOT. fdbcr->(EOF()).AND.funnum->vnum==fdbcr->vnum
                  fdbcr->(DBDELETE())
                  fdbcr->(DBSKIP())
                ENDDO
              ENDIF
              funnum->(DBDELETE())
            ENDIF
            funnum->(DBSKIP())
          ENDDO
          Prov->(DBSETFILTER({||(prov->kopr<>k_nds)},"prov->kopr<>k_nds"))
          Prov->(DBGOTOP())
          m_kod:=SPACE(30);l1:=.t.
          m_gauge:=InitGauge("Занесення даних",2)
          DO WHILE .NOT.Prov->(EOF())
            // Защелка временно
/*            IF EMPTY(prov->kopr)
              IF LEFT(prov->crt,2)=="07"
                prov->kopr:="09"
              ENDIF
              IF LEFT(prov->crt,2)=="05"
                prov->kopr:="23"
              ENDIF
            ENDIF */
            IF m_kod<>prov->ndoc+prov->kopr+prov->brgd+prov->otp+prov->kplh.OR.l1
              m_kod:=prov->ndoc+prov->kopr+prov->brgd+prov->otp+prov->kplh
              l1:=.f.
              funnum->(DBAPPEND())
              funnum->npch:=m_npch
              funnum->ndoc:=VAL(prov->Ndoc)
              funnum->vnum:=fv->vnum++
              funnum->kopr:=prov->kopr
              funnum->otp :=prov->otp
              funnum->kplh:=prov->kplh
              funnum->brgd:=prov->brgd
              funnum->ddoc:=prov->ddoc
              funnum->oper:="N2"
            ENDIF
            fdbcr->(DBAPPEND())
            fdbcr->cod1:=prov->cod1
            fdbcr->cod2:=prov->cod2
            fdbcr->dbt:=prov->dbt
            fdbcr->crt:=prov->crt
            fdbcr->glv:=prov->glv
            fdbcr->kvo2:=prov->kvo2
            fdbcr->kvo:=prov->kvo
            fdbcr->stm:=prov->stm
            fdbcr->vnum:=funnum->vnum
            funnum->vdoc:=61
            Prov->(DBSKIP())
            m_gauge:=DispGauge(m_gauge,prov->(RECNO()/LASTREC()/2))
          ENDDO
          Prov->(DBSETFILTER({||(prov->kopr==k_nds)},"prov->kopr==k_nds"))
          Prov->(DBGOTOP())
          l1:=.t.
          DO WHILE .NOT.Prov->(EOF())
            IF l1
              funnum->(DBAPPEND())
              funnum->npch:=m_npch
              funnum->ndoc:=1
              funnum->vnum:=fv->vnum++
              funnum->kopr:=prov->kopr
              funnum->otp :=prov->otp
              funnum->kplh:=prov->kplh
              funnum->brgd:=prov->brgd
              funnum->ddoc:=prov->ddoc
              funnum->oper:="N2"
              l1:=.f.
              funnum->vdoc:=61
            ENDIF
            fdbcr->(DBAPPEND())
            fdbcr->dbt:=prov->dbt
            fdbcr->cod1:=prov->cod1
            fdbcr->cod2:=prov->cod2
            fdbcr->crt:=prov->crt
            fdbcr->glv:=prov->glv
            fdbcr->kvo2:=prov->kvo2
            fdbcr->kvo:=prov->kvo
            fdbcr->stm:=prov->stm
            fdbcr->vnum:=funnum->vnum
            fdbcr->ndoc:=prov->ndoc
            Prov->(DBSKIP())
            m_gauge:=DispGauge(m_gauge,0.5+prov->(RECNO()/LASTREC()/2))
          ENDDO
        CLOSE Base funnum,fv,fdbcr,fglv
        SELECT prov
    ENDCASE
  ENDDO
   SAVEPAR(1)
RETURN .t.
FUNCTION DispProv(var)
local m_screen,i:=0,j:=0,n_menu:=1,m_str,n_win
LOCAL x:=4,y:=1,a_dir:=DIRECTORY(m_workpath+"prov??.dbf")
local m_browse,m_col,m_key,a_choice:={},n,m_row:=1,m_skip
n:=LEN(a_dir)
FOR i:=n TO 1 STEP -1
  m_str:=FILESTR(m_workpath+a_dir[i][1],22,a_dir[i][2]-22)
  IF RIGHT(m_str,2)<>"ьь"
   ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
  ENDIF
NEXT
n:=LEN(a_dir)
FOR i:=1 TO n
  m_str:=FILESTR(m_workpath+a_dir[i][1],22,a_dir[i][2]-22)
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
m_col:block:={|| REM01(a_choice[m_row][1])}
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
    FERASE(m_workpath+a_dir[m_row][1])
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
    USE (m_workpath+a_dir[m_row][1]) ALIAS Prov NEW
    Zanes02(SUBSTR(a_choice[m_row,2],1,2),SUBSTR(a_choice[m_row,2],3,2),;
    CTOD(SUBSTR(a_choice[m_row,2],5,8)),CTOD(SUBSTR(a_choice[m_row,2],13,8)))
    CLOSE prov
    STRFILE(a_choice[m_row,2],m_workpath+a_dir[m_row][1],.t.)
ENDCASE
ENDDO
RESTSCREEN(x,y ,x+20,y+76,m_screen)
RETURN .t.
/*
Function TestProv
  USE (m_temppath+"prov") NEW
  Zanes02("05","52",CTOD("01/09/98"),CTOD("30/09/98"))
  CLOSE Prov
RETURN .t.
*/
STATIC Function Zanes03(m_dbt,m_cod1,m_brgd,l_stm,m_kopr)
LOCAL m_prise
IF m_brgd<>NIL
  Prov->brgd:=m_brgd
ENDIF
IF m_kopr<>NIL
  Prov->kopr:=m_kopr
ENDIF
Prov->dbt:=m_dbt
Prov->cod1:=m_cod1
IF nakl2->st==" "
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
  Prov->stm:=Nakl2->stm1
ENDIF
RETURN .T.
Function ZakrPer
  LOCAL m_file1,m_file2,m_gauge,a_struct:={}
  LOCAL m_mol:="  ",m_ddoc1:=CTOD(""),m_ddoc2:=CTOD("")
  LOCAL l_kvo2:=.f.,i,j,k,m_key,GetList:={},s1,s3
  LOCAL n_win,m_screen,l_filter:=.f.,s2:="",n,l_doc:=.f.
  LOCAL n_file1,n_file2,n_kapt,n_file3,m_mnt:="    ",m_mnt2
  LOCAL m_message,m001,n01
  NET USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") NEW ALIAS myvar
  m_mnt:=RestVar1("m_mnt1","NK")
  CLOSE myvar
IF .not.GetPer(m_mnt)
  RETURN .f.
ENDIF
m_mnt2:=mnt_inc(m_mnt)
m_ddoc1:=CTOD("01/"+RIGHT(m_mnt,2)+"/"+left(m_mnt,2))
m_ddoc2:=EOM(m_ddoc1)
m_message := DispMessage("Закриваю розрахунковий перiод;з "+dtoc(m_ddoc1)+" по "+dtoc(m_ddoc2))
IF NETDISK(LEFT(m_workpath,1))
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  s2+=m_file1+","
  FILECOPY(m_workpath+"nakl1.dbf",m_file1)
  USE (m_file1) NEW READONLY ALIAS file1
  n_file1:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_workpath+"nakl2.dbf",m_file1)
  m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
  s2+=m_file1+","+m_file2+","
  FILECOPY(m_workpath+"nakl2.ntx",m_file2)
  USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS File2
  n_file2:=SELECT()
  m_file1:=TEMPFILE(m_temppath,"dbf");FERASE(m_file1)
  FILECOPY(m_workpath+"kaptka1.dbf",m_file1)
  m_file2:=TEMPFILE(m_temppath,"ntx");FERASE(m_file2)
  FILECOPY(m_workpath+"kaptka1.ntx",m_file2)
  s2+=m_file1+","+m_file2+","
  USE (m_file1) INDEX (m_file2) NEW READONLY  ALIAS KAPTKA
  n_kapt:=SELECT()
ELSE
  OPenFl1()
  n_file1:=SELECT("NAKL1")
  n_file2:=SELECT("NAKL2")
  n_kapt:=SELECT("KAPTKA1")
ENDIF
NET USE (m_workpath+"spr03.dbf") NEW  ALIAS File3
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
NET USE (m_workpath+"NAKL5") new
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
IF NETDISK(LEFT(m_workpath,1))
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
NET USE (m_workpath+"memvar") INDEX (m_workpath+"memvar") NEW ALIAS myvar
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
STATIC Function ZanNds(k_nds,m_680000)
IF Nakl2->nds<>0
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
  Prov->kopr:=k_nds
  Prov->crt:=m_680000
  Prov->dbt:=kaptka1->ksash2
  Prov->cod1:=Nakl2->kod
  Prov->stm:=nakl2->nds
ENDIF
RETURN .T.
STATIC FUNCTION ZanPred()
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
  Prov->kopr:=Spr01->kpr
  Prov->cod1:=Nakl1->okpo
  Prov->cod2:=Nakl2->kod
  Prov->kvo :=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
  IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
    Prov->glv:=nakl2->glv
  ELSE
    Prov->kvo2:=nakl2->glv
  ENDIF
//  Prov->glv :=nakl2->glv
  Prov->otp :=nakl1->otp
  Firm01->(DBSETORDER(2))
  Firm01->(DS(nakl1->okpo))
  Firm01->(DBSETORDER(1))
  Prov->dbt :=Firm01->ksash
  Prov->crt :=Kaptka1->ksash2
  prov->stm :=Nakl2->stm+Nakl2->nds
RETURN .t.
STATIC FUNCTION ZanPens(m_pension)
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
  Prov->kopr:=Spr01->kpr
  Prov->cod2:=Nakl2->kod
  Prov->kvo :=IF(kaptka1->koef==0,1,kaptka1->koef)*nakl2->kvo
  IF UPPER(LEFT(kaptka1->izm2,3))=="ГОЛ"
    Prov->glv:=nakl2->glv
  ELSE
    Prov->kvo2:=nakl2->glv
  ENDIF
//  Prov->glv :=nakl2->glv
  Prov->otp :=nakl1->otp
  Prov->dbt :=m_pension
  Prov->crt :=Kaptka1->ksash2
  prov->stm :=Nakl2->stm+nakl2->nds
RETURN .t.
STATIC FUNCTION ZanPred0()
  Firm01->(DBSETORDER(2))
  Firm01->(DS(Nakl1->okpo))
  Firm01->(DBSETORDER(1))
  Prov->crt:=Firm01->ksash
  Prov->cod2:=Nakl1->okpo
RETURN .t.
STATIC FUNCTION ZanTabn()
  Prov->crt:="71"
  Prov->cod2:=Nakl1->tabn
RETURN .t.
STATIC FUNCTION ZanPod()
  Prov->crt:="71"
  Prov->cod2:=nakl1->tabn
RETURN .t.
STATIC Function ZanNds0(k_nds,m_680000)
IF Nakl2->nds<>0
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
  Prov->kopr:=k_nds
  Prov->dbt:=m_680000
//  Prov->crt:=kaptka1->ksash
  Firm01->(DBSETORDER(2))
  Firm01->(DS(Nakl1->okpo))
  Firm01->(DBSETORDER(1))
  Prov->crt:=Firm01->ksash
  Prov->cod2:=Nakl1->okpo
  Prov->cod1:=Nakl2->kod
  Prov->stm:=nakl2->nds
ENDIF
RETURN .T.
STATIC Function ZanNds1(k_nds,m_680000)
IF Nakl2->nds<>0
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
  Prov->kopr:=k_nds
  Prov->dbt:=m_680000
  Prov->crt:="71"
  Prov->cod2:=Nakl1->tabn
  Prov->cod1:=Nakl2->kod
  Prov->stm:=nakl2->nds
ENDIF
RETURN .T.
STATIC Function ZanNds2(k_nds,m_680000)
IF Nakl2->nds<>0
  Prov->(DBAP())
  Prov->ndoc:=nakl1->ndoc
  Prov->ddoc:=IF(DAY(nakl1->ddoc3)>25,CTOD(STUFF(DTOC(nakl1->ddoc3),1,2,"25")),nakl1->ddoc3)
  Prov->kopr:=k_nds
  Prov->dbt:=m_680000
  Prov->crt:=Nakl1->ksash
  Prov->cod2:=Nakl1->tabn
  Prov->cod1:=Nakl2->kod
  Prov->stm:=nakl2->nds
ENDIF
RETURN .T.
