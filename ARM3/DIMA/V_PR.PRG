#include  "New.ch"
/* Используемые подпрограммы
pShapka() - определение параметорв вставляемой шапки
v_cl_all  - закрытие всех файлов
setprinter() - установка шрифта принтера
endpage   - счет выводимых строк и вывод начала страницы
*/
MEMVAR m_vdoc,m_syspath,m_dbspath,m_temppath,GetList
#DEFINE N_PAPER 2
//
//╔══════════════════════════════════════════════════════════
//║ Процедура: v_pr039
//║ Автор: Воробьев Д.Л.
//║ Дата разработки: 09/25/91 06:00pm
//║ Параметры: нет
//║ Назначение: распечатка путевых листов
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства: Принтер
//                              FZ1 - >> FZ2 - >> FZ3
//                               │        │
//                            ┌──┴──┐     │
//                                     
//                          FZ1AE  FZ1AT  FZ2A

//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//
STATIC m_file:="          "
FUNCTION v_pr039   && Распечатка путевого листа грузового автомобиля

LOCAL i        :=0 //
LOCAL n        :=0 // номер записи
LOCAL n1       :=0 // номер записи
LOCAL m_proc1  :=0 // индикатор работы
LOCAL m_zapr   :=0 // ─┐
LOCAL m_otdn   :=0 //  │
LOCAL m_oths   :=0 //  │
LOCAL m_rgnor  :=0 //  │
LOCAL m_rgfak  :=0 //  │
LOCAL m_vnvs   :=0 //  │
LOCAL m_vndv   :=0 //  │
LOCAL m_prvs   :=0 //  │
LOCAL m_prpr   :=0 //  │
LOCAL m_prsn   :=0 //  │
LOCAL m_prtn   :=0 //  ╞═══>Итоги по столбцам
LOCAL m_kolez  :=0 //  │
LOCAL m_pgob   :=0 //  │
LOCAL m_pggr   :=0 //  │
LOCAL m_ptav   :=0 //  │
LOCAL m_vtkav  :=0 //  │
LOCAL m_sum    :=0 //  │
LOCAL m_avdn   :=0 //  │
LOCAL m_count  :=0 //  │
LOCAL m_rec    :=0 //  │
LOCAL m_vnum2  :=0 //  │
LOCAL m_vnum2a :=0 // ─┘
LOCAL l_first  :=.t. // Признак первой страницы
LOCAL l_vodarenda:=.f.
LOCAL m_vodarenda:=.f.,l1:=.f.
LOCAL  m_page    := 0 //Номер страницы
LOCAL  m_hsh      := 0 //Высота (количество строк) шапки (заголовка страницы)
LOCAL xcoor[35]       //Координаты начала столбцов
LOCAL m_left_margin   := 0 // Левая граница
LOCAL   m_ktab     := 0  //последняя позиция шапки
LOCAL   m_npch     := 0  //Номер пачки
// PRIVATE m_nmflsh1 := '039' Имя файла шапки
LOCAL   m_string   := '' //Шапка

// Открытие файлов с данными

USE (m_syspath+"sovhoz") NEW
m_vodarenda:=sovhoz->vodarenda
CLOSE sovhoz

USE (M_DBSPATH+"fz1") NEW
USE (m_dbspath+"fz2") NEW
USE (m_dbspath+"fz3") NEW
USE (m_dbspath+"fz1ae") NEW
USE (m_dbspath+"fz1at") NEW
USE (m_dbspath+"fz2a") NEW

pShapka('039',@m_hsh,@m_ktab,@xcoor,@m_left_margin,@m_string) // формирование переменной m_string ,m_ktab,xcoor{},m_kvstlb,m_ntab

v_in_crpr() // Формирование экрана

v_getnp(@m_npch)  // Ввод номера пачки

IF INKEY() == K_ESC
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
    v_cl_all()
    RETURN .t.
   ENDIF
ENDIF

SELECT fz1
IF m_npch<>0                                           && Если номер пачки задан, то
  SET FILTER TO fz1->npch=m_npch.AND.(fz1->vdoc==38.or.fz1->vdoc==39) &&    просматривать только эту пачку
ELSE
  SET FILTER TO (fz1->vdoc==38.or.fz1->vdoc==39)                 &&    просматривать все
ENDIF
//vdoc == 39 Путевой лист -  обычный
//vdoc == 38 Путевой лист -  эксплуатация
GOTO TOP
IF fz1->(eof())
  DispError(" Документы отсутствуют в базе данных " )
  v_cl_all()
  RETURN .t.
ENDIF

COUNT TO m_count
m_proc1 := InitGauge(" Друкування документiв ",2,2)
// SET DEVICE TO PRINTER
m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file);OpenPrn(m_file)
IF SetWidthPrn(m_ktab)
l1:=.t.
GOTO TOP
DO WHILE .NOT.fz1->(EOF())

//  ОТРАБОТКА ВСЕХ СВЯЗОК       FZ1 - >> FZ2 - >> FZ3
//                               │        │
//                            ┌──┴──┐     │
//                                     
//                          FZ1AE  FZ1AT  FZ2A

    m_proc1:=DispGauge(m_proc1,m_rec/m_count)
    m_rec++

   IF pFilpoz("fz2","vnum1","fz1")
      pFilpoz("fz2a","vnum2","fz2")
      IF fz1->vdoc<>38
         SELECT FZ2
         n :=RECNO()
         DO WHILE fz1->vnum1 == fz2->vnum1 .AND..NOT.EOF()
            m_vnum2 := fz2->vnum2
            SKIP
         ENDDO
         n1 := RECNO()
         SELECT fz3
         LOCATE FOR fz3->vnum2 == m_vnum2 REST
         IF .NOT.FOUND()
           GO n1
         ENDIF
         SELECT FZ2
         GO n
      ENDIF
   ENDIF
   pFilpoz("fz1at","vnum1","fz1")
   pFilpoz("fz1ae","vnum1","fz1")
//
//
//     ВСЕ СВЯЗКИ ОТРАБОТАНЫ
//
IF  ( ! PrnOnLine())
        SET DEVICE TO SCREEN
        v_cl_all()
        RETURN .t.
ENDIF
   KEYBOARD  ""
   l_first := .t.
   l_vodarenda:=.t.
   DO WHILE ;
   (fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())).OR.;
   (fz1at->vnum1 == fz1->vnum1.AND..NOT.fz1at->(EOF())).OR.;
   (fz2a->vnum2 == fz2->vnum2.AND.fz2->vnum1 == fz1->vnum1.and..NOT.fz2a->(EOF())).OR.;
   (fz3->vnum2 == m_vnum2.AND..NOT.fz3->(EOF()))

      IF( INKEY() == K_ESC )
          Beep()
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
            v_cl_all()
            RETURN .t.
          ENDIF
          KEYBOARD   ""
      ENDIF
      // вывод столбцов контрольки
//      SkipLinePrn(a_shapka,m_name)
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
      IF l_first
         @ PROW() , xcoor[1]  SAY fz1->npch
         @ PROW() , xcoor[2]  SAY fz1->ndoc
         @ PROW() , xcoor[3]  SAY fz1->ddoc
         IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
            @ PROW() , xcoor[4]  SAY fz2->brgd
         ENDIF
         IF fz1ae->vnum1 == fz1->vnum1.AND..NOT.fz1ae->(EOF())
            @ PROW() , xcoor[5]  SAY fz1ae->gnavt PICTURE '9999'
         ENDIF
         IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
            @ PROW() , xcoor[6]  SAY fz2->tabn PICTURE '9999'
         ENDIF
      ENDIF
      IF fz1at->vnum1 == fz1->vnum1.AND..NOT.fz1at->(EOF())
         @ PROW() , xcoor[7]  SAY fz1at->kmtop
         @ PROW() , xcoor[8]  SAY fz1at->zapr PICTURE "999"
         m_zapr :=m_zapr + fz1at->zapr
         SKIP 1 ALIAS fz1at
      ENDIF
      IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
         @ PROW() , xcoor[9]   SAY fz2->ksash
         @ PROW() , xcoor[10]  SAY fz2->otdn   picture '99.9'
         m_otdn := m_otdn  + fz2->otdn
         @ PROW() , xcoor[11]  SAY fz2->oths   picture '999'
         m_oths := m_oths  + fz2->oths
      ENDIF
      IF l_first
         IF fz1ae->vnum1 == fz1->vnum1.AND..NOT.fz1ae->(EOF())
            @ PROW() , xcoor[12]  SAY fz1ae->rgnor PICTURE "999"
            m_rgnor := m_rgnor  + fz1ae->rgnor
            @ PROW() , xcoor[13]  SAY fz1ae->rgfak PICTURE "999"
            m_rgfak := m_rgfak  + fz1ae->rgfak
            @ PROW() , xcoor[14]  SAY fz1ae->vnvs
            m_vnvs := m_vnvs  + fz1ae->vnvs
            @ PROW() , xcoor[15]  SAY fz1ae->vndv
            m_vndv := m_vndv  + fz1ae->vndv
            @ PROW() , xcoor[16]  SAY fz1ae->prvs
            m_prvs := m_prvs  + fz1ae->prvs
            @ PROW() , xcoor[17]  SAY fz1ae->prpr
            m_prpr := m_prpr  + fz1ae->prpr
            @ PROW() , xcoor[18]  SAY fz1ae->prsn
            m_prsn := m_prsn  + fz1ae->prsn
            @ PROW() , xcoor[19]  SAY fz1ae->prtn
            m_prtn := m_prtn  + fz1ae->prtn
            @ PROW() , xcoor[20]  SAY fz1ae->kolez
            m_kolez := m_kolez  + fz1ae->kolez
         ENDIF
      ENDIF
      IF fz2a->vnum2 == fz2->vnum2.AND..NOT.fz2a->(EOF()) .AND.(fz1->vnum1 == fz2->vnum1)
         @ PROW() , xcoor[21]  SAY fz2a->pgob
         m_pgob := m_pgob  + fz2a->pgob
      ENDIF
      IF l_first
         IF fz1ae->vnum1 == fz1->vnum1.AND..NOT.fz1ae->(EOF())
            @ PROW() , xcoor[22]  SAY fz1ae->pggr
            m_pggr := m_pggr  + fz1ae->pggr
            @ PROW() , xcoor[23]  SAY fz1ae->ptav
            m_ptav := m_ptav  + fz1ae->ptav
         ENDIF
      ENDIF
      IF fz2a->vnum2 == fz2->vnum2.AND..NOT.fz2a->(EOF()).AND.(fz1->vnum1 == fz2->vnum1)
         @ PROW() , xcoor[24]-1  SAY fz2a->vtkav PICTURE '99999.9'
         m_vtkav := m_vtkav  + fz2a->vtkav
         SKIP 1 ALIAS fz2a
      ENDIF
      IF (fz1->vnum1 == fz2->vnum1)
         SKIP 1 ALIAS fz2
      ENDIF
      IF fz3->vnum2 == m_vnum2.AND..NOT.fz3->(EOF()) .AND.(fz1->vdoc<>38.AND.fz1->vdoc<>42.AND.fz1->vdoc<>44)
         i := 1
         DO WHILE fz3->vnum2 == m_vnum2.and..NOT.fz3->(EOF()).AND.i<=3
            @ PROW() , xcoor[23+i*2]  SAY fz3->kopu
            @ PROW() , xcoor[24+i*2]  SAY fz3->sum PICTURE "999.99"
            m_sum := m_sum  + fz3->sum
            SKIP 1 ALIAS fz3
            i := i+1
         ENDDO
      ENDIF
   IF m_vodarenda.AND.l_vodarenda
      IF i<>4
         @ PROW() , xcoor[23+i*2]  SAY 'ДДД'
         @ PROW() , xcoor[24+i*2]  SAY  fz1ae->dohod PICTURE '999.99'
         l_vodarenda:=.f.
      ENDIF
   ENDIF
      IF l_first
         IF fz1ae->vnum1 == fz1->vnum1.AND..NOT.fz1ae->(EOF())
            @ PROW() , xcoor[31]  SAY fz1ae->avdn
            m_avdn := m_avdn  + fz1ae->avdn
            SKIP 1 ALIAS fz1ae
         ENDIF
      ENDIF
   IF m_vodarenda.AND.l_vodarenda
      IF fz3->vnum2<> m_vnum2
         IF fz2->vnum1<>fz1->vnum1
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
            @ PROW() , xcoor[25]  SAY 'ДДД'
            @ PROW() , xcoor[26]  SAY fz1ae->dohod PICTURE '99999999'
            l_vodarenda:=.f.
         ELSE
            i:=1
         ENDIF
      ENDIF
   ENDIF

//
// Завершен вывод 1 - й строки
//
//
/*      IF fz3->vnum2 == m_vnum2.AND..NOT.fz3->(EOF()).AND.(fz1->vdoc<>38.AND.fz1->vdoc<>42.AND.fz1->vdoc<>44)
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
         i := 1
         DO WHILE fz3->vnum2 == m_vnum2.and..NOT.fz3->(EOF()).AND.i<=3
            @ PROW() , xcoor[23+i*2]  SAY fz3->kopu
            @ PROW() , xcoor[24+i*2]  SAY fz3->sum PICTURE '99999999'
            m_sum := m_sum  + fz3->sum
            SKIP 1 ALIAS fz3
            i := i+1
         ENDDO
      ENDIF
*/
      l_first :=.f.
   ENDDO

   SKIP 1 ALIAS fz1
ENDDO
@PROW()+2,0   say alltrim(str(m_zapr))
@prow(),pcol()+2 say alltrim(str(m_otdn))
@prow(),pcol()+2 say alltrim(str(m_oths))
@prow(),pcol()+2 say alltrim(str(m_rgnor))
@prow(),pcol()+2 say alltrim(str(m_rgfak))
@prow(),pcol()+2 say alltrim(str(m_vnvs))
@prow(),pcol()+2 say alltrim(str(m_vndv))
@prow(),pcol()+2 say alltrim(str(m_prvs))
@prow(),pcol()+2 say alltrim(str(m_prpr))
@prow(),pcol()+2 say alltrim(str(m_prsn))
@prow(),pcol()+2 say alltrim(str(m_prtn))
@prow(),pcol()+2 say alltrim(str(m_kolez))
@prow(),pcol()+2 say alltrim(str(m_pgob))
@prow(),pcol()+2 say alltrim(str(m_pggr))
@prow(),pcol()+2 say alltrim(str(m_ptav))
@prow(),pcol()+2 say alltrim(str(m_vtkav))
@prow(),pcol()+2 say alltrim(str(m_sum))
@prow(),pcol()+2 say alltrim(str(m_avdn))
ENDIF
v_cl_all()
Ppkontrl(l1,m_file)
RETURN .t.
//
//╔══════════════════════════════════════════════════════════
//║ Процедура: v_pr040  (  )
//║ Автор: Воробьев Д.Л.
//║ Дата разработки: 25-09-91.
//║ Назначение: Однотипно с модулем v_pr039
//║
//║ Параметры:  Однотипно с модулем v_pr039
//║
//║ Используемые внешние переменные: Однотипно с модулем v_pr039
//║
//║ Используемые процедуры и функции: Однотипно с модулем v_pr039
//║
//║ Используемые файлы и внешние устройства: Однотипно с модулем v_pr039
//║
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION v_pr040     &&   Распечатка путевого листа грузового автомобиля (прицепы)
LOCAL m_proc1  :=0
LOCAL i        :=0
LOCAL n        :=0
LOCAL m_vnum2  :=0
LOCAL m_vnum2a :=0
LOCAL m_zapr   :=0
LOCAL m_otdn   :=0
LOCAL m_oths   :=0
LOCAL m_rgnor  :=0
LOCAL m_rgfak  :=0
LOCAL m_vnvs   :=0
LOCAL m_vndv   :=0
LOCAL m_prvs   :=0
LOCAL m_prpr   :=0
LOCAL m_prsn   :=0
LOCAL m_prtn   :=0
LOCAL m_kolez  :=0
LOCAL m_pgob   :=0
LOCAL m_pggr   :=0
LOCAL m_ptav   :=0
LOCAL m_vtkav  :=0
LOCAL m_sum    :=0
LOCAL m_avdn   :=0
LOCAL m_pgob1  :=0
LOCAL m_pgob2  :=0
LOCAL m_pgob3  :=0
LOCAL m_ptpr   :=0
LOCAL m_vtkpr  :=0
LOCAL m_count  :=0
LOCAL m_rec    :=0
LOCAL l_first  :=.t.
LOCAL m_vodarenda:=.f.
LOCAL l_vodarenda:=.t.,l1:=.f.
LOCAL  m_page    := 0 //Номер страницы
LOCAL  m_hsh      := 0 //Высота (количество строк) шапки (заголовка страницы)
LOCAL xcoor[50]      /*  */
LOCAL m_left_margin   := 0    /*  */
LOCAL   m_ktab     := 0  //последняя позиция шапки
LOCAL   m_npch     := 0  //Номер пачки


// PRIVATE m_nmflsh1 := '040.txt'    /*  */
LOCAL  m_string   := ''   /*  */

USE (m_syspath+"sovhoz") NEW
m_vodarenda:=sovhoz->vodarenda
CLOSE sovhoz
USE (m_dbspath+"fz1") NEW
USE (m_dbspath+"fz2") NEW
USE (m_dbspath+"fz3") NEW
USE (m_dbspath+"fz1ae") NEW
USE (m_dbspath+"fz1at") NEW
USE (m_dbspath+"fz1ap") NEW
USE (m_dbspath+"fz2a") NEW

v_in_crpr()
v_getnp(@m_npch)
IF INKEY() == K_ESC
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
     v_cl_all()
     RETURN .t.
   ENDIF
ENDIF

pShapka('040',@m_hsh,@m_ktab,@xcoor,@m_left_margin,@m_string)

SELECT fz1
IF m_npch<>0                                           && Если номер пачки задан, то
  SET FILTER TO fz1->npch=m_npch.AND.fz1->vdoc==40 &&    просматривать только эту пачку
ELSE
  SET FILTER TO fz1->vdoc==40                 &&    просматривать все
ENDIF
GOTO TOP
IF fz1->(eof())
  DispError( " Документы отсутствуют в базе данных " )
  v_cl_all()
RETURN .t.
ENDIF
COUNT TO m_count
GOTO TOP
m_proc1 := InitGauge( " Друкування документiв ",2)
//SET DEVICE TO PRINTER
m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file);OpenPrn(m_file)
IF SetWidthPrn(m_ktab)
  l1:=.t.

DO WHILE .NOT.fz1->(EOF())

//  ОТРАБОТКА ВСЕХ СВЯЗОК       FZ1 ----------> FZ2 - >> FZ3
//                               │               │
//                   ┌────────┬──┴──┬┐           │
//                                           
//                 FZ1AP    FZ1AE  FZ1AT         FZ2A
   m_proc1:=DispGauge(m_proc1,m_rec/m_count)
   m_rec++
   IF pFilpoz("fz2","vnum1","fz1")
      pFilpoz("fz2a","vnum2","fz2")
      SELECT FZ2
      n :=RECNO()
      DO WHILE fz1->vnum1 == fz2->vnum1 .AND..NOT.EOF()
         m_vnum2 := fz2->vnum2
         SKIP
      ENDDO
      GO n
      SELECT fz3
      n := RECNO()
      LOCATE FOR fz3->vnum2 == m_vnum2  REST
      IF EOF()
         GO n
      ENDIF
      ENDIF
   pFilpoz("fz1at","vnum1","fz1")
   pFilpoz("fz1ae","vnum1","fz1")
   pFilpoz("fz1ap","vnum1","fz1")
//
//
//     ВСЕ СВЯЗКИ ОТРАБОТАНЫ
//
IF  ( ! PrnOnLine())
        SET DEVICE TO SCREEN
        v_cl_all()
        RETURN .f.
ENDIF
KEYBOARD  ""

   l_first := .t.
   l_vodarenda:=.t.

   DO WHILE ;
   l_first.OR.;
   (fz1at->vnum1 == fz1->vnum1.AND..NOT.fz1at->(EOF())).OR.;
   (fz3->vnum2 == m_vnum2.AND..NOT.fz3->(EOF()))
      INKEY()
        IF( INKEY() == K_ESC )
          Beep()
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
            v_cl_all()
            RETURN .t.
          ENDIF
          KEYBOARD   ""
        ENDIF
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)

   if l_first
      @ PROW() , xcoor[1]  SAY fz1->npch
      @ PROW() , xcoor[2]  SAY fz1->ndoc
      @ PROW() , xcoor[3]  SAY fz1->ddoc
      IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
         @ PROW() , xcoor[4]  SAY fz2->brgd
      ENDIF
      IF fz1ae->vnum1 == fz1->vnum1.AND..NOT.fz1ae->(EOF())
         @ PROW() , xcoor[5]  SAY fz1ae->gnavt
      ENDIF
      IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
         @ PROW() , xcoor[6]  SAY fz2->tabn
      ENDIF
      IF fz1ap->vnum1 == fz1->vnum1.AND..NOT.fz1ap->(EOF())
         @ PROW() , xcoor[7]  SAY fz1ap->gnp1
         @ PROW() , xcoor[8]  SAY fz1ap->gnp2
         @ PROW() , xcoor[9]  SAY fz1ap->gnp3
      ENDIF
   ENDIF
   IF fz1at->vnum1 == fz1->vnum1.AND..NOT.fz1at->(EOF())
      @ PROW() , xcoor[10]  SAY fz1at->kmtop
      @ PROW() , xcoor[11]  SAY fz1at->zapr
      m_zapr := m_zapr  + fz1at->zapr
      SKIP 1 ALIAS fz1at
   ENDIF
   IF l_first
       IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
          @ PROW() , xcoor[12]   SAY fz2->ksash
          @ PROW() , xcoor[13]  SAY fz2->otdn   picture '99.9'
          m_otdn   := m_otdn   + fz2->otdn
          @ PROW() , xcoor[14]  SAY fz2->oths   picture '999'
          m_oths   := m_oths   + fz2->oths
       ENDIF
       IF fz1ae->vnum1 == fz1->vnum1.AND..NOT.fz1ae->(EOF())
          @ PROW() , xcoor[15]  SAY fz1ae->rgnor
          m_rgnor:= m_rgnor+ fz1ae->rgnor
          @ PROW() , xcoor[16]  SAY fz1ae->rgfak
          m_rgfak:= m_rgfak+ fz1ae->rgfak
          @ PROW() , xcoor[17]  SAY fz1ae->vnvs
          m_vnvs:= m_vnvs+ fz1ae->vnvs
          @ PROW() , xcoor[18]  SAY fz1ae->vndv
          m_vndv  := m_vndv  + fz1ae->vndv
          @ PROW() , xcoor[19]  SAY fz1ae->prvs
          m_prvs  := m_prvs  + fz1ae->prvs
          @ PROW() , xcoor[20]  SAY fz1ae->prpr
          m_prpr  := m_prpr  + fz1ae->prpr
          @ PROW() , xcoor[21]  SAY fz1ae->prsn
          m_prsn := m_prsn + fz1ae->prsn
          @ PROW() , xcoor[22]  SAY fz1ae->prtn
          m_prtn  := m_prtn  + fz1ae->prtn
          @ PROW() , xcoor[23]  SAY fz1ae->kolez
          m_kolez := m_kolez + fz1ae->kolez
       ENDIF
       IF fz2a->vnum2 == fz2->vnum2.AND..NOT.fz2a->(EOF())
          @ PROW() , xcoor[24]  SAY fz2a->pgob
          m_pgob:= m_pgob+ fz2a->pgob
       ENDIF
       IF fz1ap->vnum1 == fz1->vnum1.AND..NOT.fz1ap->(EOF())
          @ PROW() , xcoor[25]  SAY fz1ap->pgob1
          m_pgob1:= m_pgob1+ fz1ap->pgob1
          @ PROW() , xcoor[26]  SAY fz1ap->pgob2
          m_pgob2:= m_pgob2+ fz1ap->pgob2
          @ PROW() , xcoor[27]  SAY fz1ap->pgob3
          m_pgob3:= m_pgob3+ fz1ap->pgob3
       ENDIF
       IF fz1ae->vnum1 == fz1->vnum1.AND..NOT.fz1ae->(EOF())
          @ PROW() , xcoor[28]  SAY fz1ae->pggr
          m_pggr := m_pggr + fz1ae->pggr
          @ PROW() , xcoor[29]  SAY fz1ae->ptav
          m_ptav  := m_ptav  + fz1ae->ptav
       ENDIF
       IF fz1ap->vnum1 == fz1->vnum1.AND..NOT.fz1ap->(EOF())
          @ PROW() , xcoor[30]  SAY fz1ap->ptpr
          m_ptpr := fz1ap->ptpr+ m_ptpr
       ENDIF
       IF fz2a->vnum2 == fz2->vnum2.AND..NOT.fz2a->(EOF())
          @ PROW() , xcoor[31]  SAY fz2a->vtkav
          m_vtkav := m_vtkav + fz2a->vtkav
          SKIP 1 ALIAS fz2a
       ENDIF
       IF fz1ap->vnum1 == fz1->vnum1.AND..NOT.fz1ap->(EOF())
          @ PROW() , xcoor[32]  SAY fz1ap->vtkpr
          m_vtkpr := m_vtkpr + fz1ap->vtkpr
          SKIP 1 ALIAS fz1ap
       ENDIF
   ENDIF
   IF fz3->vnum2 == m_vnum2.AND..NOT.fz3->(EOF())
      i := 1
      DO WHILE fz3->vnum2 == m_vnum2.and..NOT.fz3->(EOF()).AND.i<=4
         @ PROW() , xcoor[31+i*2]  SAY fz3->kopu
         @ PROW() , xcoor[32+i*2]  SAY fz3->sum PICTURE "9'999.99"
         m_sum := m_sum + fz3->sum
         SKIP 1 ALIAS fz3
         i := i+1
      ENDDO
   ENDIF
   IF m_vodarenda.AND.l_vodarenda
      IF i<5
         @ PROW() , xcoor[31+i*2]  SAY 'ДДД'
         @ PROW() , xcoor[32+i*2]  SAY  fz1ae->dohod PICTURE '99999999'
         l_vodarenda:=.f.
      ENDIF
   ENDIF
   IF l_first
      IF fz1ae->vnum1 == fz1->vnum1.AND..NOT.fz1ae->(EOF())
         @ PROW() , xcoor[41]  SAY fz1ae->avdn
         m_avdn  := m_avdn  + fz1ae->avdn
         SKIP 1 ALIAS fz1ae
      ENDIF
   ENDIF
//
// Завершен вывод 1 - й строки
//
//
 l_first :=.f.
   IF m_vodarenda.AND.l_vodarenda
      IF fz3->vnum2<> m_vnum2
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
            @ PROW() , xcoor[33]  SAY 'ДДД'
            @ PROW() , xcoor[34]  SAY fz1ae->dohod PICTURE '9999999'
            l_vodarenda:=.f.
      ENDIF
   ENDIF

 ENDDO
   SKIP 1 ALIAS fz2
   SKIP 1 ALIAS fz1
ENDDO
@PROW()+2,0   say alltrim(str(m_zapr))
@prow(),pcol()+2 say alltrim(str(m_otdn))
@prow(),pcol()+2 say alltrim(str(m_oths))
@prow(),pcol()+2 say alltrim(str(m_rgnor))
@prow(),pcol()+2 say alltrim(str(m_rgfak))
@prow(),pcol()+2 say alltrim(str(m_vnvs))
@prow(),pcol()+2 say alltrim(str(m_vndv))
@prow(),pcol()+2 say alltrim(str(m_prvs))
@prow(),pcol()+2 say alltrim(str(m_prpr))
@prow(),pcol()+2 say alltrim(str(m_prsn))
@prow(),pcol()+2 say alltrim(str(m_prtn))
@prow(),pcol()+2 say alltrim(str(m_kolez))
@prow(),pcol()+2 say alltrim(str(m_pgob))
@prow(),pcol()+2 say alltrim(str(m_pgob1))
@prow(),pcol()+2 say alltrim(str(m_pgob2))
@prow(),pcol()+2 say alltrim(str(m_pgob3))
@prow(),pcol()+2 say alltrim(str(m_pggr))
@prow(),pcol()+2 say alltrim(str(m_ptav))
@prow(),pcol()+2 say alltrim(str(m_ptpr))
@prow(),pcol()+2 say alltrim(str(m_vtkav))
@prow(),pcol()+2 say alltrim(str(m_vtkpr))
@prow(),pcol()+2 say alltrim(str(m_sum))
@prow(),pcol()+2 say alltrim(str(m_avdn))
ENDIF
v_cl_all()
Ppkontrl(l1,m_file)
RETURN .t.

FUNCTION v_pr031     &&  Индивидуальный наряд

LOCAL i        :=0,l1:=.f.
LOCAL m_proc1  :=0
LOCAL l_first  :=.t.
LOCAL m_count  := 0
LOCAL m_rec    :=0
LOCAL  m_page    := 0 //Номер страницы
LOCAL  m_hsh      := 0 //Высота (количество строк) шапки (заголовка страницы)
LOCAL xcoor[18]
LOCAL m_left_margin   := 0
LOCAL   m_ktab     := 0  //последняя позиция шапки
LOCAL   m_npch     := 0  //Номер пачки
LOCAL   m_sum[3]
// PRIVATE m_nmflsh1 := '031.txt'
LOCAL   m_string   := ''

m_sum[1] := 0
m_sum[2] := 0
m_sum[3] := 0
USE (m_dbspath+"fz1") NEW
USE (m_dbspath+"fz2") NEW
USE (m_dbspath+"fz3") NEW

pShapka('031',@m_hsh,@m_ktab,@xcoor,@m_left_margin,@m_string)
v_in_crpr()
v_getnp(@m_npch)
IF INKEY() == K_ESC
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
    v_cl_all()
    RETURN .t.
   ENDIF
ENDIF

SELECT fz1
IF m_npch<>0                             && Если номер пачки задан, то
  SET FILTER TO fz1->npch=m_npch.AND.fz1->vdoc==m_vdoc &&    просматривать только эту пачку
ELSE
  SET FILTER TO fz1->vdoc==m_vdoc                 &&    просматривать все
ENDIF
GOTO TOP
IF fz1->(eof())
   DispError( " Документы отсутствуют в базе данных " )
   v_cl_all()
RETURN .t.
ENDIF
COUNT TO m_count
m_proc1 := InitGauge( " Друкування документiв ",2)
// SET DEVICE TO PRINTER
m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file);OpenPrn(m_file)
IF SetWidthPrn(m_ktab)
  l1:=.t.

GOTO TOP
DO WHILE .NOT.fz1->(EOF())


//  ОТРАБОТКА ВСЕХ СВЯЗОК       FZ1 - >> FZ2 - >> FZ3
//
//
//
//


    m_proc1:=DispGauge(m_proc1,m_rec/m_count)
    m_rec++

   IF pFilpoz("fz2","vnum1","fz1")
      pFilpoz("fz3","vnum2","fz2")
   ENDIF
//
//
//     ВСЕ СВЯЗКИ ОТРАБОТАНЫ
//

IF  ( ! PrnOnLine())
        SET DEVICE TO SCREEN
        v_cl_all()
        RETURN .f.
ENDIF
    KEYBOARD  ""
   l_first  :=.t.
   DO WHILE ;
   (fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())).OR.;
   (fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF()).AND.;
   (l_first.OR.(fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF()))))

      INKEY()
        IF( INKEY() == K_ESC )
          Beep()
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
            v_cl_all()
            RETURN .t.
          ENDIF
          KEYBOARD   ""
        ENDIF
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
   IF l_first
      @ PROW() , xcoor[1]  SAY fz1->npch
      @ PROW() , xcoor[2]  SAY fz1->ndoc
      @ PROW() , xcoor[3]  SAY fz1->ddoc
      IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
         @ PROW() , xcoor[4]  SAY fz2->tabn
      ENDIF
   ENDIF
   IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
      @ PROW() , xcoor[5]  SAY fz2->brgd
      @ PROW() , xcoor[6]  SAY fz2->ksash
      @ PROW() , xcoor[7]  SAY fz2->vrab
      @ PROW() , xcoor[8] SAY fz2->otdn
      m_sum[1] := m_sum[1] + fz2->otdn
      @ PROW() , xcoor[9] SAY fz2->oths
      m_sum[2] := m_sum[2] + fz2->oths
   ENDIF
   IF fz3->vnum2 == fz2->vnum2.AND.(fz1->vnum1 == fz2->vnum1).AND..NOT.fz3->(EOF())
    IF .NOT.l_first
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
      l_first := .f.
    ENDIF

      DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF())
         i := 1
         DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF()).AND.i<=3
            @ PROW() , xcoor[8+i*2]  SAY fz3->kopu
            @ PROW() , xcoor[9+i*2]  SAY fz3->sum PICTURE "9'999.99"
            m_sum[3] := m_sum[3] + fz3->sum
            SKIP 1 ALIAS fz3
            i := i+1
         ENDDO
      ENDDO
   ENDIF
   SKIP 1 ALIAS fz2
   l_first  :=.f.
   ENDDO
   SKIP 1 ALIAS fz1
ENDDO
v_saysum(m_sum)
v_cl_all()
ENDIF
Ppkontrl(l1,m_file)
RETURN .t.

FUNCTION v_pr032     &&  Бригадный наряд

LOCAL i       :=0,l1:=.f.
LOCAL l_first  :=.t.
LOCAL m_proc1   :=0
LOCAL m_count  :=0
LOCAL m_rec    :=0
LOCAL  m_page    := 0 //Номер страницы
LOCAL  m_hsh      := 0 //Высота (количество строк) шапки (заголовка страницы)
LOCAL  xcoor[18]
LOCAL m_left_margin   := 0
LOCAL   m_ktab     := 0  //последняя позиция шапки
LOCAL   m_npch     := 0  //Номер пачки


LOCAL   m_sum[3]
// PRIVATE m_nmflsh1 := '032.txt'
LOCAL   m_string   := ''

m_sum[1] := 0
m_sum[2] := 0
m_sum[3] := 0

USE (m_dbspath+"fz1") NEW
USE (m_dbspath+"fz2") NEW
USE (m_dbspath+"fz3") NEW

pShapka('032',@m_hsh,@m_ktab,@xcoor,@m_left_margin,@m_string)
v_in_crpr()
v_getnp(@m_npch)
IF INKEY() == K_ESC
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
    v_cl_all()
    RETURN .t.
   ENDIF
ENDIF

SELECT fz1
IF m_npch<>0                                           && Если номер пачки задан, то
  SET FILTER TO fz1->npch=m_npch.AND.fz1->vdoc==32&&    просматривать только эту пачку
ELSE
  SET FILTER TO fz1->vdoc==32                 &&    просматривать все
ENDIF
GOTO TOP
IF fz1->(eof())
   DispError( " Документы отсутствуют в базе данных " )
   v_cl_all()
RETURN .t.
ENDIF
COUNT TO m_count
m_proc1 := InitGauge( " Друкування документiв ",2)
// set device to PRINTER
m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file);OpenPrn(m_file)
IF SetWidthPrn(m_ktab)
  l1:=.t.

GOTO TOP
DO WHILE .NOT.fz1->(EOF())


//  ОТРАБОТКА ВСЕХ СВЯЗОК       FZ1 - >> FZ2 - >> FZ3
//
//
//
//

    m_proc1:=DispGauge(m_proc1,m_rec/m_count)
    m_rec++
   IF pFilpoz("fz2","vnum1","fz1")
      pFilpoz("fz3","vnum2","fz2")
   ENDIF

//
//
//     ВСЕ СВЯЗКИ ОТРАБОТАНЫ
//

IF  ( ! PrnOnLine())
        SET DEVICE TO SCREEN
        v_cl_all()
        RETURN .f.
ENDIF
    KEYBOARD  ""
   l_first  :=.t.
   DO WHILE ;
   (fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())).OR.;
   (fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF()).AND.;
   (l_first.OR.(fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF()))))

      INKEY()
        IF( INKEY() == K_ESC )
          Beep()
          IF( ANSWERu("Прервати друк,;Ви впевненi ?")==YES)
            v_cl_all()
            RETURN .t.
          ENDIF
          KEYBOARD   ""
        ENDIF

      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)

   IF l_first
      @ PROW() , xcoor[1]  SAY fz1->npch
      @ PROW() , xcoor[2]  SAY fz1->ndoc
      @ PROW() , xcoor[3]  SAY fz1->ddoc
      IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
         @ PROW() , xcoor[4]  SAY fz2->brgd
         @ PROW() , xcoor[5]  SAY fz2->ksash
         @ PROW() , xcoor[6]  SAY fz2->vrab
      ENDIF
   ENDIF
   IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
      @ PROW() , xcoor[7]  SAY fz2->tabn
      @ PROW() , xcoor[8] SAY fz2->otdn
      @ PROW() , xcoor[9] SAY fz2->oths
      m_sum[1] := m_sum[1] + fz2->otdn
      m_sum[2] := m_sum[2] + fz2->oths
   ENDIF
   IF fz3->vnum2 == fz2->vnum2.AND.(fz1->vnum1 == fz2->vnum1).AND..NOT.fz3->(EOF())
      l_first  :=.t.
      DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF())
         i := 1
         IF .NOT.l_first
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
         ENDIF
         l_first  :=.f.
         DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF()).AND.i<=3
            @ PROW() , xcoor[8+i*2]  SAY fz3->kopu
            @ PROW() , xcoor[9+i*2]  SAY fz3->sum   PICTURE "9'999.99"
            m_sum[3] := m_sum[3] + fz3->sum
            SKIP 1 ALIAS fz3
            i := i+1
         ENDDO
      ENDDO
   ENDIF
   SKIP 1 ALIAS fz2
   l_first  :=.f.
   ENDDO
   SKIP 1 ALIAS fz1
ENDDO
v_saysum(m_sum)
ENDIF
v_cl_all()
Ppkontrl(l1,m_file)
RETURN .t.

FUNCTION v_pr036     &&  Учетный лист тракториста - машиниста

LOCAL i       :=0     /*  */
LOCAL m_proc1 :=0     /*  */
LOCAL n       :=0     /*  */
LOCAL l_first  :=.t.   /*  */
LOCAL m_vpga  := 0
LOCAL m_vptn  := 0
LOCAL m_otnsm := 0,l1:=.f.
LOCAL m_oths  := 0
LOCAL m_rtnor := 0
LOCAL m_rtfak := 0
LOCAL m_rgfak1:= 0
LOCAL m_sum   := 0
LOCAL m_vpug  := 0
LOCAL m_otdn  := 0
LOCAL m_ostnm := 0
LOCAL m_zapr  := 0
LOCAL m_otmd  := 0
LOCAL m_otms  := 0
LOCAL m_count  :=0     /*  */
LOCAL m_rec    :=0     /*  */
LOCAL  m_page    := 0 //Номер страницы
LOCAL  m_hsh      := 0 //Высота (количество строк) шапки (заголовка страницы)
LOCAL m_left_margin   := 0    /*  */
LOCAL   m_ktab     := 0  //последняя позиция шапки
LOCAL   m_npch     := 0  //Номер пачки


LOCAL xcoor[35]      /*  */
// PRIVATE m_nmflsh1 := '036.txt'    /*  */
LOCAL   m_string   := ''   /*  */


USE (m_dbspath+"fz1") NEW
USE (m_dbspath+"fz2") NEW
USE (m_dbspath+"fz3") NEW
USE (m_dbspath+"fz1t") NEW
USE (m_dbspath+"fz2t") NEW

pShapka('036',@m_hsh,@m_ktab,@xcoor,@m_left_margin,@m_string)
v_in_crpr()
v_getnp(@m_npch)
IF INKEY() == K_ESC
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
     v_cl_all()
     RETURN .t.
   ENDIF
ENDIF

SELECT fz1
if m_npch<>0                                           && Если номер пачки задан, то
  set filter to fz1->npch=m_npch.AND.fz1->vdoc==36&&    просматривать только эту пачку
else
  set filter to fz1->vdoc==36                 &&    просматривать все
endif
GOTO TOP
IF fz1->(eof())
  DispError( " Документы отсутствуют в базе данных " )
  v_cl_all()
  RETURN .t.
ENDIF
COUNT TO m_count
m_proc1 := InitGauge( " Друкування документiв ",2)
// set device to PRINTER
m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file);OpenPrn(m_file)
IF SetWidthPrn(m_ktab)
  l1:=.t.

GOTO TOP
DO WHILE .NOT.fz1->(EOF())


//  ОТРАБОТКА ВСЕХ СВЯЗОК       FZ1 - >> FZ2 - >> FZ3
//                               │        │
//                               │        │
//                                       
//                             FZ1T       FZ2T

    m_proc1:=DispGauge(m_proc1,m_rec/m_count)
    m_rec++
   m_rgfak1 :=0


   IF pFilpoz("fz2","vnum1","fz1")
      pFilpoz("fz3","vnum2","fz2")
      pFilpoz("fz2t","vnum2","fz2")
   ENDIF
   pFilpoz("fz1t","vnum1","fz1")
//
//
//     ВСЕ СВЯЗКИ ОТРАБОТАНЫ
//
IF  ( ! PrnOnLine())
        SET DEVICE TO SCREEN
        v_cl_all()
        RETURN .f.
ENDIF
KEYBOARD  ""
   l_first  :=.t.
   DO WHILE ;
   (fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())).OR.;
   (fz2t->vnum2 == fz2->vnum2.AND..NOT.fz2t->(EOF()).AND.;
   (l_first.OR.(fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())))).OR.;
   (fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF()).AND.;
   (l_first.OR.(fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF()))))
      INKEY()
        IF( INKEY() == K_ESC )
          BeepErr()
          IF( ANSWERu("Прервати друк,;Ви впевненi ?")==YES)
            v_cl_all()
            RETURN .t.
          ENDIF
          KEYBOARD   ""
        ENDIF
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)

   IF l_first
      @ PROW() , xcoor[1]  SAY fz1->npch
      @ PROW() , xcoor[2]  SAY fz1->ndoc
      @ PROW() , xcoor[3]  SAY fz1->ddoc
      IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
         @ PROW() , xcoor[4]  SAY fz2->tabn
      ENDIF
      IF fz1t->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
         @ PROW() , xcoor[5]  SAY fz1t->ntr
      ENDIF
   ENDIF
   IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
      @ PROW() , xcoor[6]  SAY fz2->brgd
      @ PROW() , xcoor[7]  SAY fz2->ksash
      @ PROW() , xcoor[8]  SAY fz2->vrab
   ENDIF
   IF fz2t->vnum2 == fz2->vnum2.AND.fz2->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
      @ PROW() , xcoor[9]  SAY fz2t->vpga
      m_vpga := m_vpga + fz2t->vpga
      @ PROW() , xcoor[10]  SAY fz2t->vptn
      m_vptn := m_vptn + fz2t->vptn
      @ PROW() , xcoor[11]  SAY fz2t->otnsm
      m_otnsm := m_otnsm + fz2t->otnsm
      @ PROW() , xcoor[12]  SAY fz2->oths
      m_oths := m_oths + fz2->oths
      @ PROW() , xcoor[13]  SAY fz2t->rtnor
      m_rtnor := m_rtnor + fz2t->rtnor
      @ PROW() , xcoor[14]  SAY fz2t->rtfak
      m_rtfak := m_rtfak + fz2t->rtfak
      m_rgfak1 :=m_rgfak1+fz2t->rtfak
   ENDIF
   IF fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF())
      i := 1
      DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF()).AND.i<=3
         @ PROW() , xcoor[13+i*2]  SAY fz3->kopu
         @ PROW() , xcoor[14+i*2]  SAY fz3->sum  PICTURE "999.99"
         m_sum  := m_sum  + fz3->sum
         SKIP 1 ALIAS fz3
         i := i+1
      ENDDO
   ENDIF
   IF fz2t->vnum2 == fz2->vnum2.AND.fz2->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
      @ PROW() , xcoor[21]  SAY fz2t->vpug
      m_vpug := m_vpug + fz2t->vpug
      SKIP 1 ALIAS fz2t
   ENDIF
   IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
      @ PROW() , xcoor[22]  SAY fz2->otdn
      m_otdn := m_otdn + fz2->otdn
   ENDIF
   IF l_first
      IF fz1t->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
//       @ PROW() , xcoor[23]  SAY fz1t->ostnm
//       m_ostnm := m_ostnm + fz1t->ostnm
         @ PROW() , xcoor[23]  SAY fz1t->zapr
         m_zapr := m_zapr + fz1t->zapr
      ENDIF
   ENDIF
// IF fz1t->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
//    @ PROW() , xcoor[25]  SAY fz1t->ostnm+fz1t->zapr-m_rgfak1 PICTURE '9999'
// ENDIF
   IF l_first
      IF fz1t->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
         @ PROW() , xcoor[24]  SAY fz1t->otmd
         m_otmd := m_otmd + fz1t->otmd
         @ PROW() , xcoor[25]  SAY fz1t->otms
         m_otms := m_otms + fz1t->otms
      ENDIF
   ENDIF
// Завершен вывод 1 - й строки
//
//
   IF fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF())
      i := 1
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
      DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF()).AND.i<=3
         @ PROW() , xcoor[13+i*2]  SAY fz3->kopu
         @ PROW() , xcoor[14+i*2]  SAY fz3->sum  PICTURE "999.99"
         m_sum  := m_sum  + fz3->sum
         SKIP 1 ALIAS fz3
         i := i+1
      ENDDO
   ENDIF
   SKIP 1 ALIAS fz2
   l_first  :=.f.
   ENDDO
   SKIP 1 ALIAS fz1
ENDDO
@PROW()+2,0 SAY ALLTRIM(STR(m_vpga  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_vptn  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_otnsm ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_oths  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_rtnor ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_rtfak ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_sum   ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_vpug  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_otdn  ))
// @prow(),pcol()+2 SAY ALLTRIM(STR(m_ostnm ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_zapr  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_otmd  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_otms  ))
ENDIF
v_cl_all()
Ppkontrl(l1,m_file)
RETURN .t.
FUNCTION v_pr037     &&  Путевой лист тракториста - машиниста

LOCAL i       :=0     /*  */
LOCAL m_proc1 :=0     /*  */
LOCAL n       :=0     /*  */
LOCAL l_first  :=.t.   /*  */
LOCAL m_oths  := 0
LOCAL m_rtnor := 0
LOCAL m_rtfak := 0
LOCAL m_rgfak1:= 0
LOCAL m_sum   := 0
LOCAL m_vpug  := 0
LOCAL m_otdn  := 0
LOCAL m_ostnm := 0
LOCAL m_zapr  := 0
LOCAL m_otmd  := 0
LOCAL m_otms  := 0
LOCAL m_prtn  := 0
LOCAL m_vtktr := 0
LOCAL m_pgob  := 0
LOCAL m_pggr  := 0
LOCAL m_kolez := 0
LOCAL m_count  :=0     /*  */
LOCAL m_rec    :=0     /*  */
LOCAL  m_page    := 0 //Номер страницы
LOCAL  m_hsh      := 0 //Высота (количество строк) шапки (заголовка страницы)
LOCAL m_left_margin   := 0    /*  */
LOCAL   m_ktab     := 0  //последняя позиция шапки
LOCAL   m_npch     := 0  //Номер пачки


LOCAL xcoor[35]      /*  */
// PRIVATE m_nmflsh1 := '037.txt'    /*  */
LOCAL   m_string   := ''   /*  */


USE (m_dbspath+"fz1") NEW
USE (m_dbspath+"fz2") NEW
USE (m_dbspath+"fz3") NEW
USE (m_dbspath+"fz1t") NEW
USE (m_dbspath+"fz2t") NEW
USE (m_dbspath+"fz2tp") NEW
pShapka('037',@m_hsh,@m_ktab,@xcoor,@m_left_margin,@m_string)
v_in_crpr()
v_getnp(@m_npch)
IF INKEY() == K_ESC
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
     v_cl_all()
     RETURN .t.
   ENDIF
ENDIF

SELECT fz1
if m_npch<>0                                           && Если номер пачки задан, то
  set filter to fz1->npch=m_npch.AND.fz1->vdoc==37     &&    просматривать только эту пачку
else
  set filter to fz1->vdoc==37                          &&    просматривать все
endif
GOTO TOP
IF fz1->(eof())
  DispError( " Документы отсутствуют в базе данных " )
  v_cl_all()
  RETURN .t.
ENDIF
COUNT TO m_count
m_proc1 := InitGauge( " Друкування документiв ",2)
// set device to PRINTER
m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file);OpenPrn(m_file)
SetWidthPrn(m_ktab)

GOTO TOP
DO WHILE .NOT.fz1->(EOF())


//  ОТРАБОТКА ВСЕХ СВЯЗОК       FZ1 - >> FZ2 - >> FZ3
//                               │        │
//                               │        │
//                                       
//                             FZ1T       FZ2T

    m_proc1:=DispGauge(m_proc1,m_rec/m_count)
    m_rec++
   m_rgfak1 :=0


   IF pFilpoz("fz2","vnum1","fz1")
      pFilpoz("fz3","vnum2","fz2")
      pFilpoz("fz2t","vnum2","fz2")
      pFilpoz("fz2tp","vnum2","fz2")
   ENDIF
   pFilpoz("fz1t","vnum1","fz1")
//
//
//     ВСЕ СВЯЗКИ ОТРАБОТАНЫ
//
IF  ( ! PrnOnLine())
        SET DEVICE TO SCREEN
        v_cl_all()
        RETURN .f.
ENDIF
    KEYBOARD  ""
   l_first  :=.t.
   DO WHILE ;
   (fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())).OR.;
   (fz2t->vnum2 == fz2->vnum2.AND..NOT.fz2t->(EOF()).AND.;
   (l_first.OR.(fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())))).OR.;
   (fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF()).AND.;
   (l_first.OR.(fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF()))))
      INKEY()
        IF( INKEY() == K_ESC )
          Beep()
          IF( ANSWERu("Прервати друк,;Ви впевненi ?")==YES)
            v_cl_all()
            RETURN .t.
          ENDIF
          KEYBOARD   ""
        ENDIF
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)

   IF l_first
      @ PROW() , xcoor[1]  SAY fz1->npch
      @ PROW() , xcoor[2]  SAY fz1->ndoc
      @ PROW() , xcoor[3]  SAY fz1->ddoc
      IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
         @ PROW() , xcoor[4]  SAY fz2->tabn
      ENDIF
      IF fz1t->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
         @ PROW() , xcoor[5]  SAY fz1t->ntr
      ENDIF
   ENDIF
   IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
      @ PROW() , xcoor[6]  SAY fz2->brgd
      @ PROW() , xcoor[7]  SAY fz2->ksash
      @ PROW() , xcoor[8]  SAY fz2->vrab
      @ PROW() , xcoor[9]  SAY fz2->oths PICTURE "99"
      m_oths := m_oths + fz2->oths
   IF fz2t->vnum2 == fz2->vnum2
      @ PROW() , xcoor[10]  SAY fz2t->otnsm PICTURE "99.9"
   ENDIF
//      @ PROW() , xcoor[10]  SAY fz2->otdn PICTURE "99.9"
//      m_otdn := m_otdn + fz2->otdn
      m_otdn := m_otdn + fz2t->otnsm
   ENDIF
   IF fz2tp->vnum2 == fz2->vnum2.AND.fz2->vnum1 == fz1->vnum1
      @ PROW() , xcoor[11]  SAY fz2tp->prtn
      m_prtn := m_prtn + fz2tp->prtn
      @ PROW() , xcoor[12]  SAY fz2tp->vtktr PICTURE "99999.9"
      m_vtktr := m_vtktr + fz2tp->vtktr
   ENDIF
   IF fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF())
      i := 1
      DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF()).AND.i<=3
         @ PROW() , xcoor[11+i*2]  SAY fz3->kopu
         @ PROW() , xcoor[12+i*2]  SAY fz3->sum  PICTURE "999.99"
         m_sum  := m_sum  + fz3->sum
         SKIP 1 ALIAS fz3
         i := i+1
      ENDDO
   ENDIF
   IF fz2t->vnum2 == fz2->vnum2.AND.fz2->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
      @ PROW() , xcoor[19]  SAY fz2t->vpug PICTURE "999.9"
      m_vpug := m_vpug + fz2t->vpug
   ENDIF
   IF fz2tp->vnum2 == fz2->vnum2.AND.fz2->vnum1 == fz1->vnum1
      @ PROW() , xcoor[20]  SAY fz2tp->pgob  PICTURE "99999"
      m_pgob := m_pgob + fz2tp->pgob
      @ PROW() , xcoor[21]  SAY fz2tp->pggr  PICTURE "99999"
      m_pggr := m_pggr  + fz2tp->pggr
   ENDIF
   IF fz2t->vnum2 == fz2->vnum2.AND.fz2->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
      @ PROW() , xcoor[22]  SAY fz2t->rtnor
      m_rtnor := m_rtnor + fz2t->rtnor
      @ PROW() , xcoor[23]  SAY fz2t->rtfak
      m_rtfak := m_rtfak + fz2t->rtfak
      m_rgfak1 := m_rgfak1 + fz2t->rtfak
      SKIP 1 ALIAS fz2t
   ENDIF
   IF fz2tp->vnum2 == fz2->vnum2.AND.fz2->vnum1 == fz1->vnum1
      @ PROW() , xcoor[24]  SAY fz2tp->kolez
      m_kolez := m_kolez + fz2tp->kolez
      SKIP 1 ALIAS fz2tp
   ENDIF
   IF l_first
      IF fz1t->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
//       @ PROW() , xcoor[25]  SAY fz1t->ostnm
//       m_ostnm := m_ostnm + fz1t->ostnm
         @ PROW() , xcoor[25]  SAY fz1t->zapr
         m_zapr := m_zapr + fz1t->zapr
      ENDIF
   ENDIF
// IF fz1t->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
//    @ PROW() , xcoor[27]  SAY fz1t->ostnm+fz1t->zapr-m_rgfak1 PICTURE '9999'
// ENDIF
   IF l_first
      IF fz1t->vnum1 == fz1->vnum1.AND..NOT.fz1t->(EOF())
         @ PROW() , xcoor[26]  SAY fz1t->otmd
         m_otmd := m_otmd + fz1t->otmd
         @ PROW() , xcoor[27]  SAY fz1t->otms
         m_otms := m_otms + fz1t->otms
      ENDIF
   ENDIF
// Завершен вывод 1 - й строки
//
//
   DO WHILE  fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF())
      i := 1
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
      DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF()).AND.i<=3
         @ PROW() , xcoor[11+i*2]  SAY fz3->kopu
         @ PROW() , xcoor[12+i*2]  SAY fz3->sum  PICTURE "999.99"
         m_sum  := m_sum  + fz3->sum
         SKIP 1 ALIAS fz3
         i := i+1
      ENDDO
   ENDDO
   SKIP 1 ALIAS fz2
   l_first  :=.f.
   ENDDO
   SKIP 1 ALIAS fz1
ENDDO
@PROW()+2,2 SAY ALLTRIM(STR(m_oths  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_otdn  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_prtn  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_vtktr ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_sum   ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_vpug  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_pgob  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_pggr  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_kolez ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_rtnor ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_rtfak ))
// @prow(),pcol()+2 SAY ALLTRIM(STR(m_ostnm ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_zapr  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_otmd  ))
@prow(),pcol()+2 SAY ALLTRIM(STR(m_otms  ))
v_cl_all()
Ppkontrl(.t.,m_file)
/*
IF SPOOLACTIV().AND.SPOOLCOUNT()<6
SPOOLADD(m_file)
ELSE
 DispError("Распечатка в фоновом режиме невозможна")
 PRINTFILE(m_file,.t.)
ENDIF
*/
RETURN .t.
FUNCTION v_pr002    && Кассовая ведомость


LOCAL  s_sum :=0     /*  */
LOCAL  s_glv :=0     /*  */
LOCAL l_first  :=.t.   /*  */
LOCAL  s_kvo :=0     /*  */
LOCAL  n     :=0     /*  */
LOCAL m_proc1  :=0     /*  */
LOCAL m_count  :=0     /*  */
LOCAL m_rec    :=0     /*  */
LOCAL  m_page    := 0 //Номер страницы
LOCAL  m_hsh      := 0 //Высота (количество строк) шапки (заголовка страницы)
local m_left_margin   := 7    /*  */
LOCAL   m_ktab     := 0  //последняя позиция шапки
LOCAL   m_npch     := 0  //Номер пачки

LOCAL xcoor[10]      /*  */
// PRIVATE m_nmflsh1 := '002.txt'    /*  */
LOCAL   m_string   := ''   /*  */


use (m_dbspath+"fd1") NEW
use (m_dbspath+"fd2") NEW
pShapka('002',@m_hsh,@m_ktab,@xcoor,@m_left_margin,@m_string)

v_in_crpr()
v_getnp(@m_npch)
IF INKEY() == K_ESC
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
    v_cl_fd()
    RETURN .t.
   ENDIF
ENDIF

SELECT fd1
if m_npch<>0                                 && Если номер пачки задан, то
  set filter to fd1->npch=m_npch                  &&    просматривать только эту пачку
endif
goto top
IF fd1->(eof())
  DispError( " Документы отсутствуют в базе данных " )
    v_cl_fd()
RETURN .t.
ENDIF
COUNT TO m_count
m_proc1 := InitGauge( " Друкування документiв ",2)
// set device to PRINTER
m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file);OpenPrn(m_file)
SetWidthPrn(m_ktab)

goto top
do while  .not.eof()

    m_proc1:=DispGauge(m_proc1,m_rec/m_count)
    m_rec++
IF  ( ! PrnOnLine())
        v_cl_fd()
        RETURN .f.
ENDIF
KEYBOARD  ""

      INKEY()
        IF( INKEY() == K_ESC )
          Beep()
          IF( ANSWERu("Прервати друк,;Ви впевненi ?")==YES)
            v_cl_fd()
            RETURN .t.
          ENDIF
          KEYBOARD   ""
        ENDIF
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
    @prow(),xcoor[1] SAY fd1->NPCH
    @prow(),xcoor[2] SAY fd1->NDOC
    @prow(),xcoor[3] SAY fd1->DDOC
    @prow(),xcoor[4] SAY fd1->kopu
   pFilpoz("fd2","vnuma","fd1")
   l_first := .t.
 do while fd1->vnumA == fd2->vnuma.AND..not.fd2->(eof())
    IF .NOT.l_first
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
     ENDIF
     l_first  :=.f.
     @prow(),xcoor[5] SAY FD2->tabn
     @prow(),xcoor[6] SAY fd2->glv PICTURE '@Z'
     s_glv := s_glv + fd2->glv
     @prow(),xcoor[7] SAY fd2->kvo PICTURE '@Z'
     s_kvo := s_kvo + fd2->kvo
     @prow(),xcoor[8] SAY Fd2->SuM
     s_sum := s_sum + fd2->sum
     skip ALIAS fd2
   ENDDO
 select Fd1
 skip
enddo
@PROW()+2,0  say s_glv
@prow(),pcol()+2 say s_kvo
@prow(),pcol()+2 say s_sum
v_cl_fd()
Ppkontrl(.t.,m_file)
/*
IF SPOOLACTIV().AND.SPOOLCOUNT()<6
  SPOOLADD(m_file)
ELSE
// DispError("Распечатка в фоновом режиме невозможна")
 PRINTFILE(m_file,.t.)
ENDIF
*/
RETURN .t.

*******************************************************************

FUNCTION v_pr001     &&  Универсальный реестр по зарплате

LOCAL i       :=0     /*  */
LOCAL l_first  :=.t.   /*  */
LOCAL m_proc1  :=0     /*  */
LOCAL m_count  :=0     /*  */
LOCAL m_rec    :=0     /*  */
LOCAL m_nmflsh1 := '001'
LOCAL  m_page    := 0 //Номер страницы
LOCAL  m_hsh      := 0 //Высота (количество строк) шапки (заголовка страницы)
LOCAL m_left_margin   := 0    /*  */
LOCAL   m_ktab     := 0  //последняя позиция шапки
LOCAL   m_npch     := 0  //Номер пачки
LOCAL xcoor[17]      /*  */
LOCAL   m_sum[3]      /*  */
LOCAL   m_string   := ''   /*  */


m_sum[1] := 0
m_sum[2] := 0
m_sum[3] := 0
USE (m_dbspath+"fz1") NEW
USE (m_dbspath+"fz2") NEW
USE (m_dbspath+"fz3") NEW
IF m_vdoc == 30
   m_nmflsh1 := '030'
ELSE
   IF m_vdoc == 20
      m_nmflsh1 := '020'
   ELSE
      IF m_vdoc == 21
         m_nmflsh1 := '021'
      ENDIF
   ENDIF
ENDIF
pShapka(m_nmflsh1,@m_hsh,@m_ktab,@xcoor,@m_left_margin,@m_string)

v_in_crpr()
v_getnp(@m_npch)
IF INKEY() == K_ESC
   IF( ANSWERu("ПРЕРВАТИ друк , Ви впевненi ?")==YES)
    v_cl_all()
    RETURN .t.
   ENDIF
ENDIF


SELECT fz1
IF (m_vdoc == 30 .OR. m_vdoc == 20 .OR. m_vdoc == 21)
   IF  m_npch<>0
        set filter to fz1->npch=m_npch.and.fz1->vdoc=m_vdoc
   ELSE
        set filter to fz1->vdoc=m_vdoc
   ENDIF
ELSE
   IF  m_npch<>0
        set filter to fz1->npch=m_npch
   ENDIF
ENDIF
goto top
IF fz1->(eof())
  DispError( " Документы отсутствуют в базе данных " )
    v_cl_all()
RETURN .t.
ENDIF
COUNT TO m_count
m_proc1 := InitGauge( " Друкування документiв ",2)
// set device to PRINTER
m_file:=TEMPFILE(m_temppath,"prn");FERASE(m_file);OpenPrn(m_file)
SetWidthPrn(m_ktab)
GOTO TOP
DO WHILE .NOT.fz1->(EOF())


//  ОТРАБОТКА ВСЕХ СВЯЗОК       FZ1 - >> FZ2 - >> FZ3
//
//
//
//


    m_proc1:=DispGauge(m_proc1,m_rec/m_count)
    m_rec++


   IF pFilpoz("fz2","vnum1","fz1")
      pFilpoz("fz3","vnum2","fz2")
   ENDIF
//
//
//     ВСЕ СВЯЗКИ ОТРАБОТАНЫ
//
IF  ( ! PrnOnLine())
        v_cl_all()
        RETURN .f.
ENDIF
    KEYBOARD  ""
   l_first  :=.t.
   DO WHILE ;
   (fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())).OR.;
   (fz3->vnum2 == fz2->vnum2.AND..NOT.fz3->(EOF()).AND.;
   (l_first.OR.(fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF()))))

      INKEY()
        IF( INKEY() == K_ESC )
          Beep()
          IF( ANSWERu("Прервати друк,;Ви впевненi ?")==YES)
            v_cl_all()
            RETURN .t.
          ENDIF
          KEYBOARD   ""
        ENDIF

      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
   IF l_first
      @ PROW() , xcoor[1]  SAY fz1->npch
      @ PROW() , xcoor[2]  SAY fz1->ndoc
      @ PROW() , xcoor[3]  SAY fz1->ddoc
   ENDIF
   IF fz2->vnum1 == fz1->vnum1.AND..NOT.fz2->(EOF())
      IF m_vdoc <> 30 .OR. l_first
         @ PROW() , xcoor[4]  SAY fz2->brgd
      ENDIF
      @ PROW() , xcoor[5]  SAY fz2->ksash
      @ PROW() , xcoor[6]  SAY fz2->vrab
      @ PROW() , xcoor[7]  SAY fz2->tabn
      @ PROW() , xcoor[8] SAY fz2->otdn
      @ PROW() , xcoor[9] SAY fz2->oths
      m_sum[1] := m_sum[1] + fz2->otdn
      m_sum[2] := m_sum[2] + fz2->oths
   ENDIF
   IF fz3->vnum2 == fz2->vnum2.AND.(fz1->vnum1 == fz2->vnum1).AND..NOT.fz3->(EOF())
      l_first  :=.t.
      DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF())
         i := 1
         IF .NOT.l_first
      endpage(@m_page,m_left_margin,m_hsh,m_ktab,m_string)
         ENDIF
         l_first  :=.f.
         DO WHILE fz3->vnum2 == fz2->vnum2.AND.fz1->vnum1 == fz2->vnum1.AND..NOT.fz3->(EOF()).AND.i<=3
            @ PROW() , xcoor[8+i*2]  SAY fz3->kopu
            @ PROW() , xcoor[9+i*2]  SAY fz3->sum PICTURE "9'999.99"
            m_sum[3] := m_sum[3] + fz3->sum
            SKIP 1 ALIAS fz3
            i := i+1
         ENDDO
      ENDDO
   ENDIF
   SKIP 1 ALIAS fz2
   l_first  :=.f.
   ENDDO
SKIP 1 ALIAS fz1
ENDDO
v_saysum(m_sum)
v_cl_all()
Ppkontrl(.t.,m_file)
/*
IF SPOOLACTIV().AND.SPOOLCOUNT()<6
SPOOLADD(m_file)
ELSE
 DispError("Распечатка в фоновом режиме невозможна")
 PRINTFILE(m_file,.t.)
ENDIF
*/
RETURN .t.

FUNCTION ENDPAGE(m_page,m_left_margin,m_hsh,m_ktab,m_string)
**********************************************************************
*Процедура:ENDPAGE
*Автор: Воробьев Д.Л.
*Версия:2.00
*Дата: 19-03-90
*Используемые  файлы :   HET
*Используемые  переменные :
*                            M_PAGE   - Счетчик страниц
*                            M_ENDPAGE- Количество строк на страницу
*                            M_LEFT_MARGIN - Левая граница печати
*                            M_KTAB   - Правая граница печати
*                            M_STRING - Шапка распечатки
*                            M_HSH    - Высота шапки
************************************************************************
LOCAL i := 0    /*  */

if m_page=0.or.prow()>=GetEndPage()
   IF m_page<>0
    StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
   ENDIF
   m_page=m_page+1
   SETPRC(0,0)
   @0,m_left_margin say date()
   @0,(m_ktab-LEN(ALLTRIM(MEMOLINE(m_string,254,1))))/2  SAY ALLTRIM(MEMOLINE(m_string,254,1))
   @0,m_ktab-9 say 'Лист N '+STRZERO(m_page,2)
   FOR i=3 TO m_hsh
      @i-2,m_left_margin SAY  ALLTRIM(MEMOLINE(m_string,254,i))
   NEXT
endif
@ prow()+1,0 SAY ''
RETURN .t.

//
//╔══════════════════════════════════════════════════════════
//║ Процедура:
//║ Автор: Воробьев Д.Л.
//║ Дата разработки: 04/26/91 11:20pm
//║ Параметры:
//║ Назначение:
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION v_in_crpr
   @1,25,5,55 BOX B_DOUBLE+" " COLOR "GR+/BG"
   @3,29 SayDisp "Друк документiв" COLOR "W+/BG"

RETURN .t.
//
//╔══════════════════════════════════════════════════════════
//║ Процедура: v_getnp  (  )
//║ Автор: Воробьев Д.Л.
//║ Дата разработки: 25-09-91.
//║ Назначение: Ввод номера пачки
//║
//║ Параметры:
//║
//║ Используемые внешние переменные:
//║
//║ Используемые процедуры и функции:
//║
//║ Используемые файлы и внешние устройства:
//║
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION v_getnp(m_npch)
             local m_str := ''
             set escape on
             set cursor on
             m_str :=savescreen(9,19,15,64)
             @9,19,13,62 BOX B_DOUBLE+" " COLOR "GR+/BG"
             @ 10,20 sayDisp 'Введiть номер пачки або 0 для друку ' COLOR "w+/BG"
             @ 11,20 sayDisp '       всiєї бази данних  ' COLOR "w+/BG"
             @ 12,20 sayDisp '       Номер пачки   '     COLOR "w+/BG"
             @ 12,39 get m_npch picture '999' COLOR "W+/BG,GR+/N"
             read
             set escape off
             set cursor off
             restscreen(9,19,15,64,m_str)
RETURN .t.


FUNCTION v_cl_all

ClosePrn()
IF SELECT('fz1') <> 0
   CLOSE fz1
ENDIF
IF SELECT('fz2') <> 0
   CLOSE fz2
ENDIF
IF SELECT('fz3') <> 0
   CLOSE fz3
ENDIF
IF SELECT('fz1t') <> 0
   CLOSE fz1t
ENDIF
IF SELECT('fz1ae') <> 0
   CLOSE fz1ae
ENDIF
IF SELECT('fz1ap') <> 0
   CLOSE fz1ap
ENDIF
IF SELECT('fz1at') <> 0
   CLOSE fz1at
ENDIF
IF SELECT('fz2t') <> 0
   CLOSE fz2t
ENDIF
IF SELECT('fz2tp') <> 0
   CLOSE fz2tp
ENDIF
IF SELECT('fz2a') <> 0
   CLOSE fz2a
ENDIF

RETURN .t.

FUNCTION  v_saysum(m_sum)
 LOCAL i:=0     /*  */
 LOCAL n:=0     /*  */
 n:=len(m_sum)
 @PROW()+2,0   say alltrim(str(m_sum[1]))
 FOR i:=2 TO n
   @PROW(),PCOL()+2 say alltrim(str(m_sum[i]))
 NEXT
RETURN .t.

FUNCTION v_cl_fd
  ClosePrn()
CLOSE base fd1,fd2
RETURN .t.

STATIC FUNCTION pShapka(m_nmflsh1,m_hsh,m_ktab,xcoor,m_left_margin,m_string)
/* ------------- параметры шапки ----------------------------------*/

#define   m_maxlong     254            //  максимальная длина шапки
#define   m_sh1tab       "└"           //  символ начала таблицы
#define   m_sh2tab       "┴"           //  символ середины таблицы
#define   m_sh3tab       "┘"           //  символ конца таблицы

LOCAL lnsh[ 40 ],i,m_kvstlb:=0,m_ntab:=0    //  построчный образ шапки
screen->(DS("R"+m_nmflsh1))
m_string:=screen->vd
m_hsh = MLCOUNT( m_string,m_maxlong )                //  подсчитали к-во строк
FOR  i = 1 TO m_hsh
     lnsh[ i ] = MEMOLINE( m_string, m_maxlong, i,,.T. ) // разбили шапку по строкам
     lnsh[ i ] = MEMOTRAN( lnsh[ i ], "",)
NEXT
* определение последней значащей строки шапки
i = m_hsh                                         // # посл строки таблицы
DO  WHILE  (  AT( m_sh1tab, lnsh[ i ]  ) = 0    .AND. i > 0 )
      i = i - 1
ENDDO
m_hsh  = i                                   // переопределили высоту шапки
m_ntab = AT( m_sh1tab, lnsh[ m_hsh ]  )        // позиция начала таблицы
m_ktab = AT( m_sh3tab, lnsh[ m_hsh ]  )        // позиция завершения таблицы
IF m_ntab = 0 .OR. m_ktab = 0                  // определение корректности шапки
?'считанная шапка  - ???????'
   RETURN(.F.)
**  окончить подпрограмму !!!!!!
ENDIF
IF  m_ntab > 1                                 // сдвигать шапку влево
    FOR  i = 1 TO m_hsh
      lnsh[ i ] = SUBSTR( lnsh[ i ], m_ntab, m_ktab)
    NEXT
    m_ktab = m_ktab - m_ntab + 1               // переопределяем нач и
    m_ntab = 1                                 // конец шапки
ENDIF
m_kvstlb = 1                                   // подсчет к-ва столбцов
xcoor[ 1 ] = 1 +  m_left_margin                //  координата X1
FOR  i = m_ntab  TO  m_ktab
     IF ( m_sh2tab = SUBSTR( lnsh[ m_hsh ] , i, 1 ) )     // поиск столбца
           m_kvstlb = m_kvstlb + 1                          // к-во столбцов
           xcoor[ m_kvstlb ] = i + m_left_margin          //  координата
     ENDIF
NEXT
xcoor[ m_kvstlb + 1 ] = m_ktab + m_left_margin
m_ktab = m_ktab +  m_left_margin                      // переопределяем нач и
m_ntab = m_ntab +  m_left_margin                      // конец шапки

RETURN(.T.)
STATIC Function Ppkontrl(l1,m_file)
IF l1
  IF SPOOLACTIV().AND.SPOOLCOUNT()<6
    SPOOLADD(m_file)
  ELSE
    MyPrintFile(m_file)
  ENDIF
ENDIF
RETURN .T.
