#include "set.ch"
#include "setcurs.ch"
#include "directry.ch"
#include "inkey.ch"
MEMVAR m_bufpath
MEMVAR m_mainpath
MEMVAR m_sprpath
MEMVAR m_syspath
MEMVAR m_mash
MEMVAR m_virtvdisk
MEMVAR m_shapka

#define  BEEP_ASK TONE( 3000, 0 )
Function Check(var)
   // ----------------------------------------------------
   // --- УСТАHОВKА ПАРАМЕТРОВ, ОБЩИХ ДЛЯ ВСЕЙ СИСТЕМЫ ---
   // ----------------------------------------------------
   SetCancel ( .f. )
   SetCursor ( SC_NONE )

   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )

   SET CENTURY       OFF
   SET DATE          BRITISH

   CLEAR SCREEN

// -------------------------------------
// --- ОБ'ЯВЛЕHИЕ ВHЕШHИХ ПЕРЕМЕHHЫХ ---
// -------------------------------------
   PUBLIC   p_help_code  := 0                     // параметр для экранного HELP
   PUBLIC   txt_clr      := 'bg+/b,n/bg'          // основной цвет символов
   PUBLIC   msg_clr      := 'gr+/r'               // цвет сообщений об ошибках
   PUBLIC   msg_mig_clr  := 'gr+*/r'              // цвет сообщений
                                                  // об ошибках с мерцанием
   PUBLIC   msg1_clr     := 'w+*/bg'              // цвет сообщений с мерцанием
   PUBLIC   box_clr      := 'w/b'                 // цвет рамок и т.п.
   PUBLIC   hlp_clr      := 'n/w,gr+/w'           // цвет справок ( help'а )
   PUBLIC   psw_clr      := 'w+/bg,n/n'           // цвет пароля
   PUBLIC   hello_clr    := 'gr+/b'               // цвет обычного приветствия
   PUBLIC   head_clr     := 'r+/b'                // цвет начальной заставки
   PUBLIC   dos_clr      := SetColor ()           // цвет MS-DOS
   PUBLIC   str_clr      := 'w+/n'                // цвет
   PUBLIC   mnu_clr      := 'w+/b,n/w'            // цвет меню
   PUBLIC   ten_clr      := 'w/n'                 // цвет тени
   PUBLIC   phn_clr      := 'n/w'                 // цвет фона
   PUBLIC   vvod_clr     := 'w+/b,gr+/n,,,w+/b'   // цвет экрана ввода-вывода
   PUBLIC   vvod_mig_clr := 'w+*/b,gr+/n,,,w+/b'  // цвет экрана ввода-вывода
                                                  // с мерцанием
   PUBLIC   hello1_clr   := 'w+/bg,w+/n'          // цвет при вводе даты
   PUBLIC   poisk_clr    := 'gr+/bg'              // цвет шапки окна запроса
                                                  // при поиске и переходе
   PUBLIC   hl_clr       := 'n/w,gr+/n'           // цвет выделенного пункта
                                                  // при экранном вводе-выводе

   PUBLIC   m_dbspath   := ''              // каталог с текущей БД
   PUBLIC   m_bufpath   := 'd:\buhgal\bf'  // каталог с буферной БД
   PUBLIC   m_mainpath  := 'd:\buhgal\mn'  // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp'  // каталог со справочниками
   PUBLIC   m_exepath   := 'd:\buhgal\bh'  // каталог для .EXE модуля пакета
   PUBLIC   m_shapka    := 'd:\buhgal\nf'  // каталог для шапок машинограмм
   PUBLIC   m_mash      := 'd:\buhgal\ms'  // каталог для машинограмм
   PUBLIC   m_struct    := 'd:\buhgal\st'  // каталог с пустыми структурами
                                           // файлов
   PUBLIC   m_syspath   := 'd:\buhgal\js'  // каталог с  системной информацией
   PUBLIC   m_vdisk     := 'd:\buhgal\vd'  // электронный диск !!!!!!!!!!!!!!!
   PUBLIC   m_virtvdisk := 'd:\buhgal\vd'  // псевдоэлектронный диск
   PUBLIC   m_copypath  := 'd:\buhgal\cp'  // каталог для копий
   IF var<>NIL
    IF FILE("INIT.DBF")
      USE init NEW Readonly
      IF VAL(var)>=1.AND.VAL(var)<=LASTREC()
        DBGOTO(VAL(var))
         m_bufpath   := ALLTRIM(init->bf)
         m_mainpath  := ALLTRIM(init->mn)
         m_sprpath   := ALLTRIM(init->sp)
         m_exepath   := ALLTRIM(init->bh)
         m_shapka    := ALLTRIM(init->nf)
         m_mash      := ALLTRIM(init->ms)
         m_struct    := ALLTRIM(init->st)
         m_syspath   := ALLTRIM(init->js)
         m_vdisk     := ALLTRIM(init->vd)
         m_virtvdisk := ALLTRIM(init->vd)
         m_copypath  := ALLTRIM(init->cp)
      ENDIF
      CLOSE init
    ENDIF
  ENDIF
  USE  (m_syspath+"\menu") INDEX  (m_syspath+"\menu")
  ChkBd()
RETURN .t.


//
//╔══════════════════════════════════════════════════════════
//║ Функция: Chkbd()
//║ Автор: Сульженко С.A.
//║ Дата разработки: 14-10-91.
//║ Назначение: Инициализация программы проверки целостности БД
//║ Возвращает: нет
//║ Параметры: нет
//║ Используемые внешние переменные: нет
//║ Используемые процедуры и функции: gCheck(), gAch(), WaitMsg()
//║ Используемые файлы и внешние устройства: нет
//║ Побочные эффекты: нет
//║ Примечания: нет
//╚═══════
//
FUNCTION  Chkbd()
   LOCAL   nCurs     := 0                    /* текущий SET  */
   LOCAL   cMenu     := {"bf","mn","sp"}     /* массив проверяемых директорий */
   LOCAL   cColor    := {}                   /* установки цвета */
   LOCAL   aMenu[2]                          /* меню */
   LOCAL   aAch[2]                           /* пункт меню */
   LOCAL   bCrPrint, bCrFile, bUn            /* настройка вывода, отмена */
      LOCAL   i                                 /*  */

nCurs := SET(_SET_CURSOR,SC_NONE)

/* Основное меню */
aMenu[1] := {;
            " Выход",;
            " Буферная база данных ",;
            " Основная база данных ",;
            " Справочники, инвент. карточки ";
            }
/* Вспомогательное меню */
aMenu[2] := {;
            " Выход ",;
            " Принтер ",;
            " Диск D: ";
            }
bCrPrint := { || SET(_SET_CONSOLE,.F.),;
                 SET(_SET_PRINTER,.T.),;
                 WaitMsg( 16, "Подготовьте принтер к работе" +;
                                " и нажмите любую клавишу!",,, .F. ),;
                 IF( ISPRINTER(),, EVAL( bCrPrint ) ) }
bCrFile  := { || SET(_SET_CONSOLE,.F.),;
                 SET(_SET_PRINTER,.T.),;
                 SET(_SET_PRINTFILE,m_mash+"\46.txt") }
bUn      := { || SET(_SET_CONSOLE,.T.),;
                 SET(_SET_PRINTER,.F.) }

cColor := SETCOLOR( "N+/W" )
CLS
SETCOLOR( "W+/B,,,,BG/B" )

DO WHILE .T.

    aAch[1] := gAch( 5, 22, aMenu[1])
    IF ( aAch[1][6] == 1 .OR. aAch[1][6] == 0)
        EXIT
    ELSE
        SETPOS( 5, 24 )
        DISPOUT( aMenu[1][ aAch[1][6] ], "R+/B" )
        aAch[2] := gAch( 6, 24, aMenu[2] )
        IF ( aAch[2][6] == 1 .OR. aAch[2][6] == 0)
            RESTSCREEN( aAch[2][1], aAch[2][2], aAch[2][3], aAch[2][4], aAch[2][5] )
            LOOP
        ELSE
            IF( aAch[2][6] != 3, EVAL( bCrPrint ), EVAL( bCrFile ) )
            IF ( gCheck( cMenu[ aAch[1][6] - 1 ] ) ==  -1 )
                SET(_SET_CURSOR,nCurs)
                SETCOLOR( cColor )
                EVAL( bUn )
                RETURN ( NIL )
            ENDIF
            EVAL( bUn )
        ENDIF

        RESTSCREEN( aAch[2][1], aAch[2][2], aAch[2][3], aAch[2][4], aAch[2][5] )

    ENDIF

ENDDO

/* шапка для просмотра ф. отчета */
DBUSEAREA( .T.,, ( m_shapka+"\msh" ) );  DBSETINDEX( ( m_shapka+"\msh" ) )
IF ( msh->( DBSEEK( STR(46, 3) ) ) )
    msh->p002 := DATE()
    msh->p007 := STRZERO( MONTH( DATE() ), 2 )
ELSE
    msh->( DBAPPEND() )
    msh->p002 := DATE()
    msh->p007 := STRZERO( MONTH( DATE() ), 2 )
ENDIF
msh->( DBCLOSEAREA() )

SET(_SET_CURSOR,nCurs)
SETCOLOR(cColor)

RETURN ( NIL )

//
//╔══════════════════════════════════════════════════════════
//║ Функция: gCheck( cFunc )
//║ Автор: Сульженко С.A.
//║ Дата разработки: 10-10-91.
//║ Назначение: ПРОВЕРКА ЦЕЛОСТНОСТИ БАЗЫ ДАННЫХ
//║ Возвращает: NIL - прерывание, окончание
//║             -1  - фатальный сбой БД
//║ Параметры: <cFunc> - выбор БД ( "bf", "mn", "sp" )
//║ Используемые внешние переменные:m_bufpath, m_mainpath,
//║             m_sprpath, m_syspath, m_mash, m_virtvdisk
//║ Используемые файлы и внешние устройства: \mn, \bf, \sp, \js\menu.dbf
//║ Используемые процедуры и функции: AskUser(), WaitMsg(), Workinit(),
//║             WorkWindow(), WorkDisplay(), WorkDel(), Window(),
//║             Buhmonth(), gErrBd(), gDoc()
//║ Побочные эффекты: нет
//║ Примечания: нет
//╚═══════
//
FUNCTION  gCheck( cFunc )
   LOCAL   nCurs     := 0             /* текущий SET  */
   LOCAL   nRec      := 0             /* текущая запись  */
   LOCAL   nMonth    := 0             /* бухгалтерский месяц */
   LOCAL   cDbspath  := ""            /* текущий маршрут */
   LOCAL   aDirSp    := {}            /* массив инфоpмации о файлах D:...\sp  */
   LOCAL   aFiNamSp  := {}            /* массив имен файлов D:...\sp */
   LOCAL   aArFil    := {}            /* массив открытых файлов */
   LOCAL   aDbf      := {}            /* массив структуры */
   LOCAL   xValKey                    /* значение ключевого поля */
   LOCAL   aProc     := {}, nSt, nEnd /* индикатор процеса */
   LOCAL   i         := 0             /*  */
   /* переменные для вывода контрольных сумм */
   /* fz1ae */
   LOCAL   nRGNOR := 0, nRGFAK := 0, nVNVS  := 0, nVNDV := 0
   LOCAL   nPRVS  := 0, nPRPR  := 0, nPRSN  := 0, nPRTN := 0
   LOCAL   nKOLEZ := 0, nPGGR  := 0, nPTAV  := 0, nAVDN := 0
 //LOCAL   nDOHOD := 0
   /* fz1ap */
   LOCAL   nPGOB1 := 0, nPGOB2 := 0, nPGOB3 := 0, nPTPR := 0
   LOCAL   nVTKPR := 0, nVNUS  := 0
   /* fz1at */
   LOCAL   nZAPR  := 0
   /* fz1t */
   LOCAL   nZAPR_ := 0, nOSTNM := 0, nOTMD  := 0, nOTMS := 0
   /* fz2 */
   LOCAL   nOTDN  := 0, nOTHS  := 0
   /* fz2a */
   LOCAL   nPGOB  := 0, nVTKAV  := 0
   /* fz2t */
   LOCAL   nVPGA  := 0, nVPTN  := 0, nVPUG  := 0, nRTNOR := 0
   LOCAL   nOTNSM := 0
   /* fz3 */
   LOCAL   nSum1  := 0
   /* fdbcr */
   LOCAL   nKvo1  := 0, nSTM := 0
   /* fglv */
   LOCAL   nGlv1  := 0
   /* fkvo2 */
   LOCAL   nKVO2  := 0
   /* fd2 */
   LOCAL   nSum2  := 0, nKvo3 := 0, nGlv2 := 0
   LOCAL   m_month:='00'

nCurs := SET(_SET_CURSOR,SC_NONE)
SET(_SET_DELETED,.T.)

IF ( cFunc == "bf".OR. cFunc == "mn" )

  cDbspath := IF( cFunc == "bf", m_bufpath, m_mainpath )
  IF ( cFunc == "bf" )
    cDbspath := m_bufpath
    QOUT( "<<<< ПРОВЕРКА БУФЕРНОЙ БД >>>>","    Дата проверки ",DATE())
  ELSE
    cDbspath := m_mainpath
    QOUT( "<<<< ПРОВЕРКА ОСНОВНОЙ БД >>>>","    Дата проверки ",DATE() )
  ENDIF

  /* ПРОВЕРКА первой части */
  //                        ╔═══╗
  //                        ║fz1║
  //                        ╚═╤═╝
  //          ┌───────┬───────┼───────┬───────┐
  //         ^│      ^│     ^^│      ^│     ^^│
  //       ╔══╧══╗ ╔══╧══╗ ╔══╧══╗ ╔══╧═╗   ╔═╧═╗
  //       ║fz1ae║ ║fz1ap║ ║fz1at║ ║fz1t║   ║fz2║
  //       ╚═════╝ ╚═════╝ ╚═════╝ ╚════╝   ╚═╤═╝
  //                            ┌──────┬──────┼──────┐
  //                          ?^│     ^│     ^│    ^^│
  //                         ╔══╧═╗ ╔══╧═╗ ╔══╧══╗ ╔═╧═╗
  //                         ║fz2a║ ║fz2t║ ║fz2tp║ ║fz3║
  //                         ╚════╝ ╚════╝ ╚═════╝ ╚═══╝

  aProc:= Workinit(20,10,22,70, " Проверка первой части " )
  WorkWindow(aProc)

  /* открытие справочников */
  DBUSEAREA( .T.,, ( cDbspath+"\fz1" ) )
     AADD( aArFil,"fz1" )
     nMonth := Buhmonth( fz1->ddoc )
  DBUSEAREA( .T.,, ( cDbspath+"\fz2" ) )
     AADD( aArFil,"fz2" )
  DBUSEAREA( .T.,, ( cDbspath+"\fz2t" ) )
    AADD( aArFil,"fz2t" )
  DBUSEAREA( .T.,, ( cDbspath+"\fz2a" ) )
    AADD( aArFil,"fz2a" )
  DBUSEAREA( .T.,, ( cDbspath+"\fz2tp" ) )
    AADD( aArFil,"fz2tp" )
  DBUSEAREA( .T.,, ( cDbspath+"\fz3" ) )
     AADD( aArFil,"fz3" )
  DBUSEAREA( .T.,, ( cDbspath+"\fz1t" ) )
     AADD( aArFil,"fz1t" )
  DBUSEAREA( .T.,, ( cDbspath+"\fz1ap" ) )
     AADD( aArFil,"fz1ap" )
  DBUSEAREA( .T.,, ( cDbspath+"\fz1ae" ) )
     AADD( aArFil,"fz1ae" )
  DBUSEAREA( .T.,, ( cDbspath+"\fz1at" ) )
     AADD( aArFil,"fz1at" )

  QOUT( "╔════Проверка первой части═══════════════════════════════════" )
  nEnd := fz1->( LASTREC() )
  nSt  := 0

  //Проверка на уникальность внутреннего номера
  gErrVnum( "fz1", "fz1->vnum1", cDbspath )

  /* проход по fz1 */
  fz1->( DBGOTOP() )
  DO WHILE ( fz1->( !EOF() ) )

      /* подсчет количества документов */
      gDoc( "fz1", fz1->npch, nEnd, "9" )

      IF( INKEY() == K_ESC )
         BEEP_ASK
         IF( AskUser( 15,"ПРЕРВАТЬ проверку , Вы уверены ?",,,,, .F. ) )
            WorkDel(aProc)
            QOUT( "╚═══Проверка первой части прервана═══════════════════════════" )
            i := 1
            EXIT
         ENDIF
         KEYBOARD   ""
      ENDIF

     IF ( cDbspath == m_bufpath  )
        IF ( nMonth != Buhmonth( fz1->ddoc ) )
           QOUT( "║ ПРЕДУПР:Месяц док. не совп-т с пред. док." )
           QQOUT( " Пачка:",fz1->npch,". Номер док.:",fz1->ndoc )
           nMonth := Buhmonth( fz1->ddoc )
        ENDIF
     ENDIF

     /* проверка связки fz1->>fz2 */
     IF ( fz1->vnum1 != fz2->vnum1 .OR. fz2->( EOF() ) )

        /* если нарушена целостность */
        IF ( gErrBd( "fz1", "fz2", "vnum1" ) == -1 )
           SET(_SET_CURSOR,nCurs)
           AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
           WorkDel(aProc)
           RETURN ( -1 )
        ENDIF

     ENDIF

        /* если совпадение по внутренним номерам */
        DO WHILE ( fz1->vnum1 == fz2->vnum1 .AND. fz2->( !EOF() ) )

           /* проход по одинаковым внутренним номерам в fz2 */
           IF ( fz1->vdoc >= 34 .AND. fz1->vdoc <= 37 )

              IF ( fz2->vnum2 != fz2t->vnum2 .OR. fz2t->( EOF() ) )
                 /* если нарушена целостность */
                 IF ( gErrBd( "fz2", "fz2t", "vnum2" ) == -1 )
                    SET(_SET_CURSOR,nCurs)
                    AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
                    WorkDel(aProc)
                    RETURN ( -1 )
                 ENDIF
              ENDIF

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

              IF (  fz2->vnum2 != fz2a->vnum2 .OR. fz2a->( EOF() ) )
                 /* если нарушена целостность */
                 IF ( gErrBd( "fz2", "fz2a", "vnum2" ) == -1 )
                    SET(_SET_CURSOR,nCurs)
                    AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
                    WorkDel(aProc)
                    RETURN ( -1 )
                 ENDIF
              ENDIF

                 DO WHILE ( fz2a->vnum2 == fz2->vnum2 .AND. fz2a->( !EOF() ) )
                    nPGOB  := nPGOB  + fz2a->pgob
                    nVTKAV := nVTKAV + fz2a->vtkav
                    fz2a->( DBSKIP() )
                 ENDDO

           ENDIF

           IF ( fz1->vdoc == 37 )

              IF (  fz2->vnum2 != fz2tp->vnum2 .OR. fz2tp->( EOF() ) )
                 /* если нарушена целостность */
                 IF ( gErrBd( "fz2", "fz2tp", "vnum2" ) == -1 )
                    SET(_SET_CURSOR,nCurs)
                    AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
                    WorkDel(aProc)
                    RETURN ( -1 )
                 ENDIF
              ENDIF

                 DO WHILE ( fz2tp->vnum2 == fz2->vnum2 .AND. fz2tp->( !EOF() ) )
                    fz2tp->( DBSKIP() )
                 ENDDO

           ENDIF

           IF ( fz1->vdoc != 38 .AND. fz1->vdoc != 42 .AND. fz1->vdoc != 44 )            // ТРАКТОРА

              IF ( fz2->vnum2 != fz3->vnum2 .OR. fz3->( EOF() ) )
                 /* если нарушена целостность */
                 IF ( gErrBd( "fz2", "fz3", "vnum2" ) == -1 )
                    SET(_SET_CURSOR,nCurs)
                    AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
                    WorkDel(aProc)
                    RETURN ( -1 )
                 ENDIF
              ENDIF

                 DO WHILE ( fz3->vnum2 == fz2->vnum2 .AND. fz3->( !EOF() ) )
                    nSum1 := nSum1 + fz3->sum
                    fz3->( DBSKIP() )
                 ENDDO

           ENDIF

           nOTDN := nOTDN + fz2->otdn
           nOTHS := nOTHS + fz2->oths
           fz2->( DBSKIP() )

        ENDDO

     IF ( fz1->vdoc >= 34 .AND. fz1->vdoc <= 37 )

        /* проверка связки fz1->fz1t */
        IF ( fz1->vnum1 != fz1t->vnum1 .OR. fz1t->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "fz1", "fz1t", "vnum1" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( fz1t->vnum1 == fz1->vnum1 .AND. fz1t->( !EOF() ) )
              nZAPR_ := nZAPR_ + fz1t->zapr
              nOSTNM := nOSTNM + fz1t->ostnm
              nOTMD  := nOTMD  + fz1t->otmd
              nOTMS  := nOTMS  + fz1t->otms
              fz1t->( DBSKIP() )
           ENDDO

     ENDIF

     IF ( fz1->vdoc == 40 )

        /* проверка связки fz1->fz1ap */
        IF ( fz1->vnum1 != fz1ap->vnum1 .OR. fz1ap->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "fz1", "fz1ap", "vnum1" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( fz1ap->vnum1 == fz1->vnum1 .AND. fz1ap->( !EOF() ) )


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
        IF ( fz1->vnum1 != fz1ae->vnum1 .OR. fz1ae->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "fz1", "fz1ae", "vnum1" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( fz1ae->vnum1 == fz1->vnum1 .AND. fz1ae->( !EOF() ) )
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
        IF ( fz1->vnum1 != fz1at->vnum1 .OR. fz1at->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "fz1", "fz1at", "vnum1" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( fz1at->vnum1 == fz1->vnum1 .AND. fz1at->( !EOF() ) )
              nZAPR  := nZAPR  + fz1at->zapr
              fz1at->( DBSKIP() )
           ENDDO

     ENDIF

     fz1->( DBSKIP() )
     WorkDisplay( aProc,++nSt/nEnd )

  ENDDO

  IF ( i != 1 )
    WorkDisplay( aProc,1 )
    QOUT( "╚═══Проверка первой части окончена═══════════════════════════" )
  ELSE
    i := 0
  ENDIF

  /* закрытие */
  fz1  ->( DBCLOSEAREA() )
  fz2  ->( DBCLOSEAREA() )
  fz2t ->( DBCLOSEAREA() )
  fz2a ->( DBCLOSEAREA() )
  fz2tp->( DBCLOSEAREA() )
  fz3  ->( DBCLOSEAREA() )
  fz1t ->( DBCLOSEAREA() )
  fz1ap->( DBCLOSEAREA() )
  fz1ae->( DBCLOSEAREA() )
  fz1at->( DBCLOSEAREA() )

  WorkDel(aProc)

  /* ПРОВЕРКА второй части */
  //                       ╔══════╗
  //                       ║funnum║
  //                       ╚═══╤══╝
  //       ┌───────┬───────┬───┴───┬───────┬──────┐
  //     ^^│      ^│      ^│      ^│      ^│     ^│
  //    ╔══╧══╗ ╔══╧═╗ ╔═══╧══╗ ╔══╧══╗ ╔══╧═╗ ╔══╧══╗
  //    ║fdbcr║ ║fglv║ ║fgnavt║ ║fkvo2║ ║fntr║ ║ftabn║
  //    ╚═════╝ ╚════╝ ╚══════╝ ╚═════╝ ╚════╝ ╚═════╝

  ASIZE( aArFil,0 )
  aProc:= Workinit(20,10,22,70, " Проверка второй части " )
  WorkWindow(aProc)

  DBUSEAREA( .T.,, ( cDbspath+"\funnum" ) )
     AADD( aArFil,"funnum" )
     IF ( Buhmonth( funnum->ddoc ) != 0 )
        nMonth := Buhmonth( funnum->ddoc )
     ENDIF
  DBUSEAREA( .T.,, ( cDbspath+"\fdbcr" ) )
     AADD( aArFil,"fdbcr" )
  DBUSEAREA( .T.,, ( cDbspath+"\fglv" ) )
     AADD( aArFil,"fglv" )
  DBUSEAREA( .T.,, ( cDbspath+"\fkvo2" ) )
     AADD( aArFil,"fkvo2" )
  DBUSEAREA( .T.,, ( cDbspath+"\ftabn" ) )
     AADD( aArFil,"ftabn" )
  DBUSEAREA( .T.,, ( cDbspath+"\fntr" ) )
     AADD( aArFil,"fntr" )
  DBUSEAREA( .T.,, ( cDbspath+"\fgnavt" ) )
     AADD( aArFil,"fgnavt" )


  QOUT( "╔═══Проверка второй части════════════════════════════════════" )
  nEnd := funnum->( LASTREC() )
  nSt  := 0

  //Проверка на уникальность внутреннего номера
  gErrVnum( "funnum", "funnum->vnum", cDbspath )

  /* проход по funnum */
  funnum->( DBGOTOP() )
  DO WHILE ( funnum->( !EOF() ) )

      gDoc( "funnum", funnum->npch, nEnd, "8" )

      IF( INKEY() == K_ESC )
         BEEP_ASK
         IF( AskUser( 15,"ПРЕРВАТЬ проверку , Вы уверены ?",,,,, .F. ) )
            WorkDel(aProc)
            QOUT( "╚═══Проверка второй части прервана═══════════════════════════" )
            i := 1
            EXIT
         ENDIF
         KEYBOARD   ""
      ENDIF

     IF ( cDbspath == m_bufpath  )
        IF ( nMonth != Buhmonth( funnum->ddoc ) )
           QOUT( "║ ПРЕДУПР:Месяц док. не совп. с пред. док." )
           QQOUT( " Пачка:",funnum->npch,". Номер док.:",funnum->ndoc )
           nMonth := Buhmonth( funnum->ddoc )
        ENDIF
     ENDIF
     /* проверка связки funnum->>fdbcr */
     IF ( funnum->vnum != fdbcr->vnum .OR. fdbcr->( EOF() ) )
        /* если нарушена целостность */
        IF ( gErrBd( "funnum", "fdbcr", "vnum" ) == -1 )
           SET(_SET_CURSOR,nCurs)
           AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
           WorkDel(aProc)
           RETURN ( -1 )
        ENDIF
     ENDIF

        DO WHILE ( fdbcr->vnum == funnum->vnum .AND. fdbcr->( !EOF() ) )


           nKvo1 := nKvo1 + fdbcr->kvo
           nSTM  := nSTM  + fdbcr->stm
           fdbcr->( DBSKIP() )

        ENDDO

     IF ( funnum->vdoc >= 200 .AND. funnum->vdoc <= 299 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )

        /* проверка связки funnum->fglv */
        IF ( funnum->vnum != fglv->vnum .OR. fglv->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "funnum", "fglv", "vnum" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( fglv->vnum == funnum->vnum .AND. fglv->( !EOF() ) )
              nGlv1 := nGlv1 + fglv->glv
              fglv->( DBSKIP() )
           ENDDO

     ENDIF

     IF ( funnum->vdoc >= 100 .AND. funnum->vdoc <= 199 ) .OR.;
           ( funnum->vdoc >= 300 .AND. funnum->vdoc <= 399 )

        /* проверка связки funnum->fkvo2 */
        IF ( funnum->vnum != fkvo2->vnum .OR. fkvo2->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "funnum", "fkvo2", "vnum" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( fkvo2->vnum == funnum->vnum .AND. fkvo2->( !EOF() ) )
              nKVO2 := nKVO2 + fkvo2->kvo2
              fkvo2->( DBSKIP() )
           ENDDO

     ENDIF

     IF ( funnum->vdoc == 1 .OR. funnum->vdoc == 2  .OR. funnum->vdoc == 4  .OR. funnum->vdoc == 5 )

        /* проверка связки funnum->ftabn */
        IF ( funnum->vnum != ftabn->vnum .OR. ftabn->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "funnum", "ftabn", "vnum" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( ftabn->vnum == funnum->vnum .AND. ftabn->( !EOF() ) )
              ftabn->( DBSKIP() )
           ENDDO

     ENDIF

     IF ( funnum->vdoc == 1  .OR. funnum->vdoc == 4 )

        /* проверка связки funnum->fntr */
        IF ( funnum->vnum != fntr->vnum .OR. fntr->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "funnum", "fntr", "vnum" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( fntr->vnum == funnum->vnum .AND. fntr->( !EOF() ) )
              fntr->( DBSKIP() )
           ENDDO

     ENDIF

     IF ( funnum->vdoc == 2  .OR. funnum->vdoc == 5 )

        /* проверка связки funnum->fgnavt */
        IF ( funnum->vnum != fgnavt->vnum .OR. fgnavt->( EOF() ) )
           /* если нарушена целостность */
           IF ( gErrBd( "funnum", "fgnavt", "vnum" ) == -1 )
              SET(_SET_CURSOR,nCurs)
              AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
              WorkDel(aProc)
              RETURN ( -1 )
           ENDIF
        ENDIF

           DO WHILE ( fgnavt->vnum == funnum->vnum .AND. fgnavt->( !EOF() ) )
              fgnavt->( DBSKIP() )
           ENDDO

     ENDIF

     funnum->( DBSKIP() )
     WorkDisplay( aProc,++nSt/nEnd )

  ENDDO

  IF ( i != 1 )
    WorkDisplay( aProc,1 )
    QOUT( "╚═══Проверка второй части окончена═══════════════════════════" )
  ELSE
    i := 0
  ENDIF

  funnum  ->( DBCLOSEAREA() )
  fdbcr   ->( DBCLOSEAREA() )
  fglv    ->( DBCLOSEAREA() )
  fkvo2   ->( DBCLOSEAREA() )
  ftabn   ->( DBCLOSEAREA() )
  fntr    ->( DBCLOSEAREA() )
  fgnavt  ->( DBCLOSEAREA() )

  WorkDel(aProc)

  /* ПРОВЕРКА третьей части */
  //    ╔═══╗
  //    ║fd1║
  //    ╚═╤═╝
  //      │
  //    ^^│
  //    ╔═╧═╗
  //    ║fd2║
  //    ╚═══╝

  ASIZE( aArFil,0 )
  aProc:= Workinit(20,10,22,70, " Проверка третьей части " )
  WorkWindow(aProc)

  DBUSEAREA( .T.,, ( cDbspath+"\fd1" ) )
     AADD( aArFil,"fd1" )
     IF ( Buhmonth( fd1->ddoc ) != 0 )
        nMonth := Buhmonth( fd1->ddoc )
     ENDIF
  DBUSEAREA( .T.,, ( cDbspath+"\fd2" ) )
     AADD( aArFil,"fd2" )

  QOUT( "╔═══Проверка третьей части═══════════════════════════════════" )
  nEnd := fd1->( LASTREC() )
  nSt  := 0

  //Проверка на уникальность внутреннего номера
  gErrVnum( "fd1", "fd1->vnuma", cDbspath )

  /* проход по fd1 */
  fd1->( DBGOTOP() )
  DO WHILE ( fd1->( !EOF() ) )

      gDoc( "fd1", fd1->npch, nEnd, "9" )

      IF( INKEY() == K_ESC )
         BEEP_ASK
         IF( AskUser( 15,"ПРЕРВАТЬ проверку , Вы уверены ?",,,,, .F. ) )
            WorkDel(aProc)
            QOUT( "╚═══Проверка третьей части прервана══════════════════════════" )
            i := 1
            EXIT
         ENDIF
         KEYBOARD   ""
      ENDIF

     IF ( cDbspath == m_bufpath  )
        IF ( nMonth != Buhmonth( fd1->ddoc ) )
           QOUT( "║ ПРЕДУПР:Месяц док. не совп. с пред. док." )
           QQOUT( " Пачка:",fd1->npch,". Номер док.:",fd1->ndoc )
           nMonth := Buhmonth( fd1->ddoc )
        ENDIF
     ENDIF


     /* проверка связки fd1->>fd2 */
     IF ( fd1->vnuma != fd2->vnuma .OR. fd2->( EOF() ) )
        /* если нарушена целостность */
        IF ( gErrBd( "fd1", "fd2", "vnuma" ) == -1 )
           SET(_SET_CURSOR,nCurs)
           AEVAL( aArFil, { |x| (x)->( DBCLOSEAREA() ) } )
           WorkDel(aProc)
           RETURN ( -1 )
        ENDIF
     ENDIF

        DO WHILE ( fd2->vnuma == fd1->vnuma .AND. fd2->( !EOF() ) )

           nSum2 := nSum2 + fd2->sum
           nKvo3 := nKvo3 + fd2->kvo
           nGlv2 := nGlv2 + fd2->glv
           fd2->( DBSKIP() )

        ENDDO

     fd1->( DBSKIP() )
     WorkDisplay( aProc,++nSt/nEnd )

  ENDDO

  IF ( i != 1 )
    WorkDisplay( aProc,1 )
    QOUT( "╚═══Проверчка третьей части окончена═════════════════════════" )
  ELSE
    i := 0
  ENDIF

  fd1  ->( DBCLOSEAREA() )
  fd2  ->( DBCLOSEAREA() )

  WorkDel(aProc)

  IF ( cFunc == "bf" )
    QOUT( "╔═Контр. сумма по БУФЕРНОЙ БД за ", STRZERO( nMonth, 2 ),;
              "месяц═══════════════════" )
  ELSE
    QOUT( "╔═Контр. сумма по ОСНОВНОЙ БД════════════════════════════════" )
  ENDIF

  /* fz1ae */
  QOUT( "║ * Расход горючего по норме (авт.)* ", STR( nRGNOR, 20, 3 ), " *" )
  QOUT( "║ * Расход горючего факт.    (авт.)* ", STR( nRGFAK, 20, 3 ), " *" )
  QOUT( "║ * Время в наряде  автомобиля     * ", STR( nVNVS, 20, 3 ), " *" )
  QOUT( "║ * Время авт. в наряде в движ.    * ", STR( nVNDV, 20, 3 ), " *" )
  QOUT( "║ * Простой авт. всего             * ", STR( nPRVS, 20, 3 ), " *" )
  QOUT( "║ * Простой авт. всего погр/разгр  * ", STR( nPRPR, 20, 3 ), " *" )
  QOUT( "║ * Простой авт. сверх нормы       * ", STR( nPRSN, 20, 3 ), " *" )
  QOUT( "║ * Простой авт. по тех. неисправн.* ", STR( nPRTN, 20, 3 ), " *" )
  QOUT( "║ * Кол-во ездок с грузом    (авт.)* ", STR( nKOLEZ, 20, 3 ), " *" )
  QOUT( "║ * Пробег с грузом          (авт.)* ", STR( nPGGR, 20, 3 ), " *" )
  QOUT( "║ * Перевезено тонн всего    (авт.)* ", STR( nPTAV, 20, 3 ), " *" )
  QOUT( "║ * Отработано автомобиле-дней     * ", STR( nAVDN, 20, 3 ), " *" )
//IF ( sovhoz->dohod == .T. )
//  QOUT( "║ * Доход                          * ", STR( nDOHOD, 20, 3 ), " *" )
//ENDIF
  /* fz1ap */
  QOUT( "║ * Пробег  общий  прицепа 1 (авт.)* ", STR( nPGOB1, 20, 3 ), " *" )
  QOUT( "║ * Пробег  общий  прицепа 2 (авт.)* ", STR( nPGOB2, 20, 3 ), " *" )
  QOUT( "║ * Пробег  общий  прицепа 3 (авт.)* ", STR( nPGOB3, 20, 3 ), " *" )
  QOUT( "║ * Перевезено тонн на приц. (авт.)* ", STR( nPTPR, 20, 3 ), " *" )
  QOUT( "║ * Выполнено  т-км на приц. (авт.)* ", STR( nVTKPR, 20, 3 ), " *" )
  QOUT( "║ * Время в наряде прицепа   (авт.)* ", STR( nVNUS, 20, 3 ), " *" )
  /* fz1at */
  QOUT( "║ * Заправлено, л            (авт.)* ", STR( nZAPR, 20, 3 ), " *" )
  /* fz1t */
  QOUT( "║ * Заправлено               (тр-р)* ", STR( nZAPR_, 20, 3 ), " *" )
  QOUT( "║ * Остаток на начало месяца (тр-р)* ", STR( nOSTNM, 20, 3 ), " *" )
  QOUT( "║ * Отработано машино-дней   (тр-р)* ", STR( nOTMD, 20, 3 ), " *" )
  QOUT( "║ * Отработано машино-смен   (тр-р)* ", STR( nOTMS, 20, 3 ), " *" )
  /* fz2 */
  QOUT( "║ * Отработано дней                * ", STR( nOTDN, 20, 3 ), " *" )
  QOUT( "║ * Отработано смен                * ", STR( nOTHS, 20, 3 ), " *" )
  /* fz2a */
  QOUT( "║ * Пробег общий                   * ", STR( nPGOB, 20, 3 ), " *" )
  QOUT( "║ * Выполнено т/км автомобилем     * ", STR( nVTKAV, 20, 3 ), " *" )
  /* fz2t */
  QOUT( "║ * Выполнено гектар         (тр-р)* ", STR( nVPGA, 20, 3 ), " *" )
  QOUT( "║ * Выполнено тонн           (тр-р)* ", STR( nVPTN, 20, 3 ), " *" )
  QOUT( "║ * Выполнено условных гектар(тр-р)* ", STR( nVPUG, 20, 3 ), " *" )
  QOUT( "║ * Расход топлива по норме  (тр-р)* ", STR( nRTNOR, 20, 3 ), " *" )
  QOUT( "║ * Отработано нормо-смен    (тр-р)* ", STR( nOTNSM, 20, 3 ), " *" )
  /* fz3 */
  QOUT( "║ * Сумма  оплаты труда            * ", STR( nSum1, 20, 3 ), " *" )
  /* fdbcr */
  QOUT( "║ * Количество 2 по бухг. проводкам* ", STR( nKvo1, 20, 3 ), " *" )
  QOUT( "║ * Сумма        по бухг. проводкам* ", STR( nSTM, 20, 3 ), " *" )
  /* fglv */
  QOUT( "║ * Кол-во голов по бухг. проводкам* ", STR( nGlv1, 20, 3 ), " *" )
  /* fkvo2 */
  QOUT( "║ * Количество 1 (Зачетный вес )   * ", STR( nKVO2, 20, 3 ), " *" )
  /* fd2 */
  QOUT( "║ * Сумма         по касс. вед-ти  * ", STR( nSum2, 20, 3 ), " *" )
  QOUT( "║ * Количество    по касс. вед-ти  * ", STR( nKvo3, 20, 3 ), " *" )
  QOUT( "║ * Кол-во голов  по касс. вед-ти  * ", STR( nGlv2, 20, 3 ), " *" )
  QOUT( "╚════════════════════════════════════════════════════════════" )

ENDIF
QOUT( "<<<< ПРОВЕРКА БД ОКОНЧЕНА >>>>" )
//sovhoz->( DBCLOSEAREA() )
SET(_SET_CURSOR,nCurs)

RETURN ( NIL )

//
//╔══════════════════════════════════════════════════════════
//║ Функция:  gErrBd()
//║ Автор: Сульженко С.A.
//║ Дата разработки: 10.04.91.
//║ Назначение: проверка связок ведущего и ведомого файлов в случае
//║             прямого несовпадения
//║ Возвращает: NIL
//║             -1  - фатальная ошибка ( перекрестная ссылка )
//║ Параметры:  cF1  - имя ведущего файла
//║             cF2  - имя ведомого файла
//║             cFld - имя проверяемого поля
//║ Используемые внешние переменные: нет
//║ Используемые процедуры и функции: нет
//║ Используемые файлы и внешние устройства: нет
//║ Побочные эффекты: нет
//║ Примечания: ищет в ведомом, перемещает указ. на найденную запись,
//║             при этом проверяет предыдущие на наличие перекрестной ссылки
//╚═══════
//
FUNCTION  gErrBd( cF1, cF2, cFld  )
   LOCAL nRecF1  := 0     /* номер записи в cF1 */
   LOCAL n1RecF2 := 0     /* номер записи в cF2 */
   LOCAL n2RecF2 := 0     /* номер записи в cF2 */
   LOCAL nWorkAr := 0     /* текущая рабочая область */
   LOCAL xValF2           /* значение поля cF2 */
   LOCAL n_count:=0

nWorkAr := SELECT()
DBSELECTAR( cF2 )
n1RecF2 := RECNO()

/* поиск проводки в ведомом файле */
// DBEVAL( { || NIL },, { || ( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) ) != ( cF1 )->( FIELDGET( FIELDPOS( cFld ) ) ),50 } )
DO WHILE .NOT.EOF().AND.( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) ) != ( cF1 )->( FIELDGET( FIELDPOS( cFld ) ) ).AND.n_count<50
IF INKEY()==K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"w/bg,gr+/b")==1
  ?"Программа снята пользователем"
  RETURN -1
ENDIF
DBSKIP();N_count++
ENDDO
n_count:=0

// IF ( ( cF2 )->( EOF() ) )
IF (cF2)->(FIELDGET(FIELDPOS(cFld)))!=(cF1)->(FIELDGET(FIELDPOS(cFld)))
   /* только заголовок */
   DBGOTO( n1RecF2 )
   QOUT( "║ ОШИБКА : Связка "+cF1+"->>"+cF2+". Только заголовок." )
   QOUT( "║        - В "+cF2+" нет "+cFld+"=",( cF1 )->( FIELDGET( FIELDPOS( cFld ) ) ),;
            "Запись N:", ( cF1 )->( RECNO() ) )

ELSE

   n2RecF2 := ( cF2 )->( RECNO() )
   DBGOTO( n1RecF2 )
   DBSELECTAR( cF1 )
   nRecF1 := RECNO()
   n_count:=0
IF INKEY()==K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"w/bg,gr+/b")==1
  ?"Программа снята пользователем"
  RETURN -1
ENDIF
   /* проход до найденной и поиск в ведущем */
   DO WHILE ( ( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) );
           != ( cF1 )->( FIELDGET( FIELDPOS( cFld ) ) ) )      // .AND.n_count<100

      n1RecF2 := ( cF2 )->( RECNO() )
      xValF2  := ( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) )

      /* поиск в ведущем */
//      DBEVAL( { || NIL },, { || ( cF1 )->( FIELDGET( FIELDPOS( cFld ) ) )!= ( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) ),50 } )
DO WHILE .NOT.EOF().AND.( cF1 )->( FIELDGET( FIELDPOS( cFld ) ) )!= ( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) ).AND.n_count<50
IF INKEY()==K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"w/bg,gr+/b")==1
  ?"Программа снята пользователем"
  RETURN -1
ENDIF
DBSKIP();n_count++
ENDDO
//      IF ( ( cF1 )->( EOF() ) )
      IF ( cF1 )->( FIELDGET( FIELDPOS( cFld ) ) )!= ( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) )

         /* отсутсвует заголовок */
         QOUT( "║ ОШИБКА : Связка "+cF1+"->>"+cF2+". Отсутствует заголовок." )
         QOUT( "║        - В "+cF1+" нет "+cFld+"=",( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) ),;
                  "Запись N:",( cF2 )->( RECNO() ) )
         DBGOTO( nRecF1 )

         DO WHILE ( ( cF2 )->( FIELDGET( FIELDPOS( cFld ) ) ) == xValF2 ).AND..NOT.(cF2)->(EOF())
IF INKEY()==K_ESC.AND.ALERT("Выйти из программы?",{"Да","Нет"},"w/bg,gr+/b")==1
  ?"Программа снята пользователем"
  RETURN -1
ENDIF
            ( cF2 )->( DBSKIP() )
         ENDDO

      ELSE

         /* фатальная ошибка */
         QOUT( "!!ОШИБКА: Связка "+cF1+"->>"+cF2+". Фатальная ошибка." )
         QOUT( "      - Пересечение связок. Поле ",cFld,". Номера записей:" )
         QOUT( "        "+cF1+":",nRecF1,"->"+cF2+":",n2RecF2," и "+;
                        cF1+":",( cF1 )->( RECNO() ),"->"+cF2+":",n1RecF2 )
         RETURN ( -1 )

      ENDIF

   ENDDO

ENDIF

DBSELECTAR( nWorkAr )

RETURN ( NIL )

//
//╔══════════════════════════════════════════════════════════
//║ Функция: gDoc()
//║ Автор: Сульженко С.A.
//║ Дата разработки: 16-10-91.
//║ Назначение: Вывод номера пачки, кол. документов
//║             и вида документов
//║ Возвращает: NIL
//║ Параметры: cAls  - имя файла
//║            nNpch - номер пачки
//║            nCol  - кол. записей в файле
//║            cNum  - внутрен. номер в menu.dbf
//║ Используемые внешние переменные: нет
//║ Используемые процедуры и функции: gTxtMenu()
//║ Используемые файлы и внешние устройства: \js\menu.dbf
//║ Побочные эффекты: нет
//║ Примечания: нет
//╚═══════
//
FUNCTION  gDoc( cAls, nNpch, nCol, cNum  )
    STATIC nBasNpch := 0    /* базовый номер пачки */
    STATIC nBasVdoc := 0    /* базовый вид документа */
    STATIC i        := 0    /*  */
    STATIC n        := 1    /*  */
IF ( nBasNpch != nNpch .AND. n== 1 )
    nBasNpch := nNpch
    nBasVdoc := (cAls)->vdoc
    i++
    n := 2
ELSEIF ( nBasNpch != nNpch )
    nBasNpch := nNpch
    nBasVdoc := (cAls)->vdoc
    i := 1
ELSE
    i++
ENDIF

(cAls)->( DBSKIP() )
IF ( (cAls)->( EOF() ) )
    (cAls)->( DBSKIP(-1) )
    nBasNpch := 0
    i        := 0
    n        := 1
ELSE
    (cAls)->( DBSKIP(-1) )
ENDIF
RETURN ( NIL )

//
//╔══════════════════════════════════════════════════════════
//║ Функция:  gAch()
//║ Автор: Сульженко С.A.
//║ Дата разработки: 18-10-91.
//║ Назначение: Вывод меню и определение выбр. пункта
//║ Возвращает: массив, содержащий координаты используемой области
//║             экрана, переменную образа экрана и пункт меню:
//║             0 - выход по ESC
//║ Параметры: nTop, nLeft - координаты верхнего угла окна
//║            aPunct      - массив пунктов меню
//║ Используемые внешние переменные: нет
//║ Используемые процедуры и функции: Window()
//║ Используемые файлы и внешние устройства: нет
//║ Побочные эффекты: нет
//║ Примечания: ограничение на 5 пунктов меню
//╚═══════
//
FUNCTION gAch( nTop, nLeft, aPunct )
  LOCAL y1,y2,x1,x2                 /* координаты окна  */
  LOCAL aMas  := {}                 /* массив вывода */
  LOCAL cBuf  := ""                 /* образ экрана */
  LOCAL nMenu := 0                  /* пункт меню */

y1 := nTop
y2 := nTop + 6
x1 := nLeft
x2 := nLeft+36

cBuf := SAVESCREEN(y1,x1,y2+1,x2+2)
Window( y1,x1,y2,x2 )

DO WHILE .T.
  KEYBOARD   ""
  nMenu := ACHOICE( y1+1, x1+1, y2-1, x2-1, aPunct,,, 2 )
  DO CASE
    CASE  nMenu == 0
      IF ( LASTKEY() == K_ESC )
        EXIT
      ELSE
        LOOP
      ENDIF
    OTHERWISE
      EXIT
  ENDCASE
ENDDO

RETURN ( aMas := { y1, x1, y2+1, x2+2, cBuf, nMenu } )

//
//╔══════════════════════════════════════════════════════════
//║ Функция:  gTxtMenu()
//║ Автор: Сульженко С.A.
//║ Дата разработки: 19-10-91.
//║ Назначение: Определение вида документа
//║ Возвращает: cText - наименование документа
//║ Параметры: cNum   - внутрен. номер в menu.dbf
//║            nVdoc  - номер вида документа
//║ Используемые внешние переменные: нет.
//║ Используемые процедуры и функции: нет.
//║ Используемые файлы и внешние устройства: \js\menu.dbf
//║ Побочные эффекты: нет.
//║ Примечания: нет.
//╚═══════
//
FUNCTION gTxtMenu( cNum, nVdoc )
  LOCAL nRec  := 0                         /* номер текущей записи */
  LOCAL cText := ""                        /* вид документа */

nRec := menu->( RECNO() )
menu->( DBGOTOP() )
menu->( DBEVAL( { || NIL },, { || ALLTRIM( menu->num ) != cNum .OR. ;
                         menu->p_vdoc !=  nVdoc } ) )
cText := menu->text
menu->( DBGOTO( nRec ) )

RETURN ( cText )

//
//╔══════════════════════════════════════════════════════════
//║ Функция:  gErrVnum( cFiNam, cVnum, cPath )
//║ Автор: Сульженко С.А.
//║ Дата разработки: 23-11-91.
//║ Назначение: проверка на уникальность вн. номера ведущего файла
//║ Возвращает: NIL
//║ Параметры: <cFiNam> - имя файла
//║            <cVnum>  - наименование поля вн. номера
//║            <cPath>  - директория.
//║ Используемые внешние переменные: нет.
//║ Используемые процедуры и функции: нет.
//║ Используемые файлы и внешние устройства: БД.
//║ Побочные эффекты: нет.
//║ Примечания: нет.
//╚═══════
//
STATIC FUNCTION gErrVnum( cFiNam, cVnum, cPath )
  LOCAL xVal := 0                            /* значение ключевого поля */

//Создание временного инд. файла
(cFiNam)->( DBCREATEINDEX( cPath + "\" + "Uniq", cVnum,;
                              &("{ ||" + cVnum + "}") ) )
(cFiNam)->( DBGOTOP() )

DO WHILE !( (cFiNam)->( EOF() ) )
  xVal := &( (cFiNam)->( INDEXKEY(0) ) )
  (cFiNam)->( DBSKIP() )
  IF ( (cFiNam)->( EOF() ) )
    EXIT
  ELSEIF ( &( (cFiNam)->( INDEXKEY(0) ) ) == xVal )
    QOUT( "║ ОШИБКА : Файл " + cFiNam + ". Внутренний номер ",;
                                    &cVnum, " не уникален." )
  ENDIF
ENDDO

//Уничтожение временного инд. файла
(cFiNam)->( DBCLEARINDEX() )
(cFiNam)->( DBGOTOP() )
(cFiNam)->( FERASE( cPath + "\" + "Uniq.ntx" ) )

RETURN ( NIL )
