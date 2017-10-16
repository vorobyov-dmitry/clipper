//~pl66~rm80~lm0~tm2~bm63~ff1
//~dh1~fn  ~da                                             ~pa
//9
//
//╔══════════════════════════════════════════════════════════
//║ Модуль: Browse.prg
//║ Автор: Шнайдеp В. О.
//║ Дата создания: 04-10-91.
//║ Содержит: процедуры : S_KR001
//║                       S_KR020
//║                       S_KR021
//║                       S_KR029
//║                       S_KR030
//║                       S_KR031
//║                       S_KR032
//║                       S_KR036
//║                       S_KR037
//║                       S_KR038
//║                       S_KR039
//║                       S_KR040
//║
//║           функции
//║                       ABROWSE
//║                       ABLOCK
//║                       ASKIPBR
//║                       AGET
//║                       CONNECT
//║                       DELDOC
//║                       DELFZ3
//║                       DELLINE
//║                       L_NOT_LAST
//║                       L_NOT_ONE
//║                       ME_FUNC
//║                       SERV1
//║                       S_F_DBE
//║                       SAYHEADSEP
//║                       SAYWDF
//║                       SDEL
//║                       SINS
//║                       SUSEFZ123
//║                       WDF_TABLE
//║                       _STAB
//║                       SARR01
//║                       SARR02
//║                       SARR03
//║                       SARR04
//║                       SARR05
//║                       SARR06
//║                       SARR07
//║                       SARR08
//║                       SARR09
//║                       SARR10
//║                       SARR24
//║                       SARR30
//║                       SSAY01
//║                       SSAY02
//║                       SSAY03
//║                       SSAY04
//║                       SSAY05
//║                       SSAY06
//║                       SSAY07
//║                       SSAY08
//║                       SSAY09
//║                       SSAY10
//║                       SSAY24
//║                       SSAY30
//║                       SENTER01
//║                       SENTER02
//║                       SENTER03
//║                       SENTER04
//║                       SENTER05
//║                       SENTER06
//║                       SENTER07
//║                       SENTER08
//║                       SENTER09
//║                       SENTER10
//║                       SENTER24
//║                       SENTER30
//║                       SWALIND
//║                       S_KR038_040
//║                       _SARR
//║
//║ Используемые внешние переменные:
//║                       MSG_CLR
//║                       VVOD_CLR
//║                       HL_CLR
//║                       HELLO1_CLR
//║                       P_NPR
//║                       M_DBSPATH
//║                       P_HELP_CODE
//║
//║ Используемые процедуры и функции:
//║                       ASKUSER
//║                       CALC
//║                       COPYDBFNTX
//║                       DELDBFNTX
//║                       HELP
//║                       INSERT
//║                       WAITMSG
//║                       Wait_Mig
//║                       WINDOW
//║                       REPLACERECORD
//║                       S_F_DBE
//║                       _FIO
//║                       _FIOFULL
//║
//║ Используемые файлы и внешние устройства:
//║                       WAL.CH
//║
//║                       REESTR.DBF
//║                       LOPEN.DBF
//║                       LRELAT.DBF
//║                       WDF.WDF
//║
//║                       FZ1T.DBF
//║                       FZ1AE.DBF
//║                       FZ1AP.DBF
//║                       FZ1AT.DBF
//║                       FZ1TP.DBF
//║                       FZ2.DBF
//║                       FZ2A.DBF
//║                       FZ2B.DBF
//║                       FZ2T.DBF
//║                       FZ2TP.DBF
//║
//║                       SP01.DBF
//║                       SP06.DBF
//║                       SP44.DBF
//║                       SP08.DBF
//║                       SP13A.DBF
//║                       SP13B.DBF
//║                       INV_A.DBF
//║                       INV_P.DBF
//║                       INV_T.DBF
//║
//║ Побочные эффекты:
//║ Ключи компиляции: /W /N
//║ Примечания:
//╚═══════
//

#include "wal.ch"
#define  REG_PROSMOTR   "просмотр"
#define  REG_KORRECT    "исправление"
#define BELL() ?Chr(7)
#DEFINE VVOD_CLR    'w/b,gr+/n,,,n/w'

// Файлы , связанные с FZ1
#ifdef _L_BRGD              // Нужна бригада-заказчик ?
   STATIC aF1 := {"FZ1AE","FZ1AP","FZ1AT","FZ1T","FZ1TP","FZ2B"}
#else
   STATIC aF1 := {"FZ1AE","FZ1AP","FZ1AT","FZ1T","FZ1TP"}
#endif

// Файлы , связанные с FZ2
STATIC aF2 := {"FZ2A","FZ2T","FZ2TP"}

// Справочники
STATIC aSp := {"SP01","SP02","SP03","SP04","SP05","SP06","SP44","SP08",;
               "SP09","SP10","SP13A","SP13B","SP16","SP20A","SP20B",;
               "SP20C","SP20","SP22","SP23","SP24","SP25","SP26",;
               "INV_T","INV_A","INV_P"}
STATIC aRel1       // Установленные связи с FZ1
STATIC aRel2       // Установленные связи с FZ3
STATIC move_block  // Позиционирование по файлам
STATIC numproc     // Код документа
STATIC lmore       // Флаг выхода
STATIC l_ins       // Флаг вставки
STATIC hseprow     // Высота шапки
STATIC achange     // Массив флагов редактирования
STATIC ab          // Объект TBROWSE


MEMVAR GetList

// PUBLIC - определены в Beginit.prg
MEMVAR msg_clr
MEMVAR hl_clr
MEMVAR hello1_clr
MEMVAR p_npr
MEMVAR m_syspath
MEMVAR m_dbspath
MEMVAR m_sprpath
MEMVAR p_help_code

// PRIVATE - переменные,определенные в ABROWSE
MEMVAR p_name
MEMVAR p_valid
MEMVAR p_pict
MEMVAR n_s
MEMVAR a_recno
MEMVAR p_value

// PRIVATE - переменные,определямые в S_KR***
MEMVAR m_reg
MEMVAR p_fz2
MEMVAR p_fz2t
MEMVAR p_fz2a
MEMVAR p_fz2tp
MEMVAR p_fz3
MEMVAR m_tabn
MEMVAR m_ntr
MEMVAR m_brgd
MEMVAR m_vrab
MEMVAR m_all
MEMVAR m_gnavt
MEMVAR m_ksash
MEMVAR m_topl
MEMVAR m_rashod
MEMVAR m_pr

//
//╔══════════════════════════════════════════════════════════
//║ Функция:  Abrowse( <y1>, <x1>, <y2>, <x2>,<__num> ) --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Оpганизация пpосмотpа и pедактиpования массива.
//║ Возвращает: NIL.
//║   Параметры:   < y1 > , < x1 > , < y2 > , < x2 > - гpаницы экpана
//║                < num > - упpавляющая пеpеменная(уникальный пpизнак
//║                          документа)
//║
//║ Используемые внешние переменные:
//║                 MSG_CLR
//║                 VVOD_CLR
//║                 HL_CLR
//║                 HELLO1_CLR
//║                 M_REG
//║
//║ Используемые процедуры и функции:
//║                 ABLOCK
//║                 ASKIPBR
//║                 AGET
//║                 SERV1
//║                 S_F_DBE
//║                 SARR**
//║                 SAYWDF
//║                 SDEL
//║                 SENTER**
//║                 SINS
//║                 SSAY**
//║                 SUSEFZ123
//║
//║                 ASKUSER
//║                 CALC
//║                 HELP
//║                 WAITMSG
//║                 Wait_Mig
//║                 WINDOW
//║                 S_F_DBE
//║
//║ Используемые файлы и внешние устройства:
//║                 REESTR.DBF
//║
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION     ABrowse( y1, x1, y2, x2,__num)

LOCAL i         // Служебная переменная - счетчик
LOCAL j         // Служебная переменная - счетчик
LOCAL n_c       // Буферная переменная для номера записи
LOCAL ss        // Буферная переменная для экрана
LOCAL col       // Объект TBCOLUMN
LOCAL m_len_col // Количество колонок в объекте
LOCAL key := 0  // Код клавиши
LOCAL m_curs    // Вид курсора
LOCAL m_exit    // SET(_SET_EXIT)
LOCAL aheading := {}       // Массив заголовков
LOCAL afootsep := {}       // Массив нижних разделителей
LOCAL acolsep := {}        // Массив разделителей колонок
LOCAL aheadsep := {}       // Массив верхних разделителей
LOCAL m_row                // Буфер для номера строки экрана
LOCAL m_col                // Буфер для номера солбца экрана
// Блок сообщения о попытке выйти за пределы  файла
LOCAL first_last := ;
      {|n|IF(n_c == fz1->(RECNO()),;
        waitMessage(IF(n,"Останнiй","Перший"),,.t.),)}
LOCAL s_files:={},m_screen
PRIVATE a_recno :={}       // Массив номенов записей
PRIVATE p_value :={}       // Массив значений полей
PRIVATE n_s := 1           // Счетчик строк
PRIVATE p_name  :={}       // Массив выражений полей
PRIVATE p_valid := {}      // Массив VALID
PRIVATE p_pict := {}       // Массив PICTURE
// PRIVATE m_tr
// Значения STATIC - переменных
hseprow := 0
l_ins :=.f.
lMore :=.t.
numproc := __num
achange := {}


move_block := ;
      {|k,l,log|log:=(k#0 .and. !EMPTY(fz1->(DBFILTER()))),;
            IF(log,l:=SAVESCREEN(10,29,13,51),),;
            IF(log,   Wait_Mig()             ,),;
            fz1->(DBSKIP(k)),n_s:=1,;
            IF(fz1->(EOF()),fz1->(DBSKIP(-1)),),;
            &("sarr"+numproc)(),;
            ab:panhome(),;
            ab:GoTop(),;
            ab:refreshall(),;
            IF(log,RESTSCREEN(10,29,13,51,l),)}
SET DELETED ON

// Чтение информации для создания объекта
NET USE (m_syspath+"reestra") INDEX (m_syspath+"reestra") NEW READONLY alias reestr
DBSEEK(numproc,.f.)
DBEVAL({||AADD(p_NAME,reestr->pole),;
          AADD(acolsep,&(reestr->colsep)),;
          AADD(aheadsep,&(reestr->headsep)),;
          AADD(achange,reestr->change),;
          AADD(aheading,&(reestr->pname)),;
          AADD(afootsep,&(reestr->footsep)),;
          AADD(p_valid,reestr->pvalid),;
          AADD(p_pict,&(reestr->ppicture));
        },,{||reestr->koddoc == numproc})
CLOSE reestr

// Открываем файлы
// SETCURSOR(SC_NONE)
Wait_Mig()
sUseFz123(,@s_files)

// Проверяем, есть ли записи
IF fz1->(EOF())
   lMore := .f.
   DispError('Документи вiдсутнi.;Hатиснить любу клавiшу для повернення в меню.  ')
ELSE

   // Формируем массивы
   &("sarr"+numproc)()
//_printPArr()
//   m_curs  := SET( _SET_CURSOR, 0 )
   m_exit  := SET( _SET_EXIT, .T. )

   m_len_col :=  LEN( p_value[1] )

   // Создаем объект

   ab := TBrowseNew( y1, x1, y2, x2 )
   ab:ColorSpec := "w/b,n/w,GR+/B,w+/b"

     FOR   i :=  1    TO    m_len_col          /* Цикл по столбцам */
       col := TBColumnNew( "", aBlock( i ) )
       col:colsep := acolsep[i]
       col:footsep := afootsep[i]
       col:headsep := aheadsep[i]
       col:heading := aheading[i]
       col:ColorBlock:=IF(achange[i],{||{4,2}},{||{3,2}})
       ab:AddColumn( col )
     NEXT

   ab:SkipBlock := { |x|  aSkipBr( x )  }
   ab:GoTopBlock    := { || n_s := 1  }
   ab:GoBottomBlock := { || n_s := LEN(p_value) }

   AEVAL(aheading,{|a|hseprow:=MAX(hseprow,;
                   LEN(a)-LEN(STRTRAN(a,";","")))})
   // Выводим видеоформу
   SAYWDF(numproc)

   @ y1-1,0         SAY "╠"+REPLICATE("═",78)+"╣"
   @ y1+hseprow+1,0 SAY "╟"+REPLICATE("─",78)+"╢"
   IF ab:nbottom # 24
      @ y2,0        SAY "╠"+REPLICATE("═",78)+"╣"
   END
END
   // Опрос клавиш
   DO WHILE lMore
       @0,39 SAY mnt_dtoc(fz1->mnt) COLOR "GR+/b*"

      // Если пустой документ
      IF LEN(p_value)==0
         DispError('В документi №'+STR(Fz1->ndoc,5)+' Пачка №'+STR(fz1->npch,3)+' вiдсутнi записи.;Його необхiдно знищити ! ')
        IF ALERT("Уничтожать документ?",{"Нет","Да"},"N/bg,B/w")==2
           deldoc()
        ENDIF
        EVAL(Move_Block,1)
        EVAL(first_last,.t.)
        LOOP
      END

      // Стабилизация объекта

      _Stab()
// _printPArr()

      m_row:=ROW()
      m_col:=COL()
//      SETCURSOR(SC_NONE)

      // Выводим шапку
      &("ssay"+numproc)()
      SETPOS(m_row,m_col)

      SETCOLOR(VVOD_CLR)


      // Ждем клавишу
      key := INKEY(0)

      n_c := fz1->(RECNO())
      IF( !ab:Stable )
         LOOP
      END


      // Независимо от положения курсора
      IF  key == K_DEL .and. m_reg # REG_PROSMOTR

         // Удаление записи

         IF ANSWERu(('Ви дiйсно бажаєте знищити '+IF(!ab:autolite,'документ ?','запис ?')))==YES
            sDel()
         END

      ELSEIF  key == K_F7

         // Пропустить документы

         ss := SAVESCREEN(0,0,24,79)
         i := 0
         SET(_SET_ESCAPE,.T.)
//         SETCURSOR(SC_NORMAL)
         SETCOLOR(HELLO1_CLR)
         @6,24,10,55  BOX B_DOUBLE+" " COLOR "gr+/BG"
         @ 07,25 SAY 'Сколько документов пропустить?'
         @ 09,39 GET i picture '999999'
         READ
         SET(_SET_ESCAPE,.F.)
//         SETCURSOR(SC_NONE)

         // Если ENTER

         IF LASTKEY()#K_ESC.and.i#0
            RESTSCREEN(0,0,24,79, ss)
            Wait_Mig()
            SELECT  fz1
            EVAL(Move_Block,i)
            RESTSCREEN(0,0,24,79, ss)
            EVAL(first_last,i>0)
         END
         RESTSCREEN(0,0,24,79, ss)

      ELSEIF  key == K_F8

         // Выбрать документ

         ss := SAVESCREEN(0,0,24,79)
         SELECT  fz1
         SETCOLOR(hl_clr)
         @1,1,22,38  BOX B_DOUBLE+" " COLOR (hl_clr)
         dbedit(2,2,21,37,;
              {'fz1->(" "+STR(npch)+"   "+STR(ndoc)+"    "'+;
                                               '+DTOC(ddoc)+"  ")'},;
              's_f_dbe','',{'N пач. N док.     Дата'})
         RESTSCREEN(0,0,24,79, ss)
         EVAL(Move_Block,0)

      ELSEIF  key == K_ESC

         // Выход ???

         IF ANSWERu(' Завершити работу ? ')==YES
            lMore := .f.
         END
       ELSEIF key == K_F12

            lMore := .f.

      ELSEIF  key == K_F10

         // Расчеты

         Calc()

      ELSEIF  key == K_F1

         // Помощь

         help()

      ELSEIF  key == K_CTRL_HOME

         // На первый документ

         fz1->(DBGOTOP())
         EVAL(Move_Block,0)

      ELSEIF  key == K_CTRL_END

         // На последний документ

         fz1->(DBGOBOTTOM())
         EVAL(Move_Block,0)

      ELSEIF  key == K_F2

         // На 1 документ вперед

         EVAL(Move_Block,1)
         EVAL(first_last,.t.)

      ELSEIF  key == K_F3

         // На 1 документ назад

         EVAL(Move_Block,-1)
         EVAL(first_last,.f.)

      ELSEIF  key == K_F4

         // На 20 документов назад

         EVAL(Move_Block,-20)
         EVAL(first_last,.f.)

      ELSEIF  key == K_F5

         // На 20 документов вперед

         EVAL(Move_Block,20)
         EVAL(first_last,.t.)

      ELSEIF  key == K_F6

         // Поиск документа

         ss := SAVESCREEN(0,0,24,79)
         i := {fz1->npch,fz1->ndoc}
         SET(_SET_ESCAPE,.T.)
//         SETCURSOR(SC_NORMAL)
         SETCOLOR(hello1_clr)
         @ 6,27,11,52  BOX B_DOUBLE+" " COLOR "gr+/BG"
         @ 07,30 say 'Введiть номер пачки' COLOR "w+/BG"
         @ 08,39 get i[1] picture '999' COLOR "w+/BG,GR+/N"
         @ 09,28 say 'Введiть номер документа' COLOR "w+/BG"
         @ 10,38 get i[2] picture '99999'COLOR "w+/BG,GR+/N"
         READ
//         SETCURSOR(SC_NONE)
         SET(_SET_ESCAPE,.F.)
         RESTSCREEN(0,0,24,79, ss)
         IF LASTKEY()<>K_ESC.and.;
                  (i[1]#fz1->npch.or.i[2]#fz1->ndoc)
            Wait_Mig()
            SELECT  fz1
            n_c := fz1->(RECNO())
            fz1->(DBGOTOP())
            LOCATE FOR IF(i[2]==0,.t.,fz1->ndoc==i[2]) ;
                       .and. fz1->npch==i[1] ;
                   WHILE INKEY()#K_ESC
            RESTSCREEN(0,0,24,79, ss)
            IF FOUND()
               EVAL(Move_Block,0)
            ELSEIF LASTKEY()#K_ESC
               DispError(' Документ N '+;
                    TRANSFORM(i[2],'99999')+;
                    ' в пачцi N '+TRANSFORM(i[1],'999')+;
                    ' не знайден. ')
               GO (n_c)
            ELSE
               waitMessage('Пошук завершено!')
               GO (n_c)
            END
         END
         RESTSCREEN(0,0,24,79, ss)



      // Курсор на строке
      ELSEIF ab:autolite


         IF key == K_LEFT

            // Влево

            IF ab:colpos == 1
            ELSEIF ( p_value[n_s][ab:colpos-1] # NIL)
               ab:Left()
            ELSE

               // Перескочить через пустые поля

               FOR i = 1 TO ab:colpos - 1
                  IF p_value[n_s,ab:colpos - i] # NIL
                      EXIT
                  END
               NEXT
               IF i # ab:colpos
                  FOR j = 1 TO i ; ab:left() ; NEXT
                  _Stab()
               END
            END

         ELSEIF  key == K_RIGHT

            // Вправо

            IF ab:colpos == ab:colcount
            ELSEIF p_value[n_s,ab:colpos+1] # NIL
               ab:Right()
            ELSE

               // Перескочить через пустые поля

               FOR i = 1 TO ab:colcount-ab:colpos
                  IF p_value[n_s ,ab:colpos+i] # NIL
                     EXIT
                  END
               NEXT
               IF i # ab:colcount-ab:colpos + 1
                  FOR j = 1 TO i ; ab:right() ; NEXT
                  _Stab()
               END
            END
         ELSEIF  key == K_UP

            // Вверх

            IF n_s == 1

               // На шапку

               ab:autolite := .f.
               ab:dehilite()
               ab:panhome()
            ELSEIF p_value[n_s-1,ab:colpos] # NIL
                ab:Up()
            ELSE

               // Перескочить через пустые поля

               FOR i = 1 TO n_s - 1
                  IF p_value[n_s - i,ab:colpos] # NIL
                     EXIT
                  END
               NEXT
               IF i # n_s
                  DISPBEGIN()
                  FOR j = 1 TO i
                    WHILE( ! ab:stabilize() ) ;  END
                    ab:up()
                  NEXT
                  DISPEND()
                  _Stab()
               END
            END
         ELSEIF  key == K_DOWN
            IF n_s == len(p_value)

            ELSEIF p_value[n_s+1,ab:colpos] # NIL
               ab:Down()
            ELSE

               // Перескочить через пустые поля

               FOR i = 1 TO len(p_value)-n_s
                  IF p_value[n_s + i,ab:colpos] # NIL
                     EXIT
                  END
               NEXT
               IF i # len(p_value)-n_s + 1
                  DISPBEGIN()
                  FOR j = 1 TO i
                     WHILE( ! ab:stabilize() ) ;  END
                     ab:down()
                  NEXT
                  DISPEND()
                  _Stab()
               END
            END

         ELSEIF  key == K_PGDN

            // Страница вниз

            ab:PageDown()
            SERV1()

         ELSEIF  key == K_CTRL_PGUP

            // Первая строка

            ab:GoTop()
            SERV1()

         ELSEIF  key == K_CTRL_PGDN

            // Последняя строка

            ab:GoBottom()
            SERV1()

         ELSEIF  key == K_PGUP

            // Страница вверх

            IF n_s # 1
               ab:PageUp()
               SERV1()
            ELSE

               // На шапку

               ab:autolite := .f.
               ab:dehilite()
               ab:panhome()
            END

         ELSEIF  key == K_HOME

            // В первую колонку

            ab:panHome()
            IF p_value[n_s,1] == NIL
               FOR i = 2 TO ab:colcount
                  ab:right()
                  IF(p_value[n_s,i] # NIL)
                     EXIT
                  END
               NEXT
               _Stab()
            END

         ELSEIF  key == K_END

            // В последнюю колонку

            ab:panEnd()
            IF p_value[n_s,ab:colcount] == NIL
               FOR i = ab:colcount-1 TO 1 STEP -1
                  ab:left()
                  IF(p_value[n_s,i] # NIL)
                     EXIT
                  END
               NEXT
               _Stab()
            END

         ELSEIF  key == K_ENTER .and. m_reg # REG_PROSMOTR

            // Редактировать поле

            aGet(  )

         ELSEIF  key == K_INS  .and. m_reg # REG_PROSMOTR

            // Вставить запись

            l_ins := sins()

         END
      ELSEIF !ab:autolite

         // Курсор на шапке

         IF  key == K_DOWN .or. key == K_PGDN .or. key == K_CTRL_PGDN

            // На строки

            ab:autolite := .t.
            &("ssay"+numproc)()
            ab:hilite()

         ELSEIF  key == K_ENTER.and. m_reg # REG_PROSMOTR

            // Редактировать шапку

            &("senter"+numproc)()

         END
      END
   END

// Грохаем STATIC переменные

numproc := NIL
lmore   := NIL
l_ins   := NIL
hseprow := NIL
move_block := NIL
ab := NIL

// Закрываем файлы
sUsefz123(.f.,@s_files)

SET( _SET_EXIT, m_exit )
// SET( _SET_CURSOR, m_curs )
RETURN  NIL



//
//╔══════════════════════════════════════════════════════════
//║ Функция: ABLOCK( < n >) --> bColumn.
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Создание блока для колонки.
//║ Возвращает: bColumn - блок для колонки.
//║ Параметры: <n> - номеp колонки
//║
//║ Используемые внешние переменные:
//║                 N_S
//║                 P_PICT
//║                 P_VALUE
//║
//║ Используемые процедуры и функции:
//║
//║ Используемые файлы и внешние устройства:
//║
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION    aBlock(i)

LOCAL  c := LTRIM( STR( i ))    // Номер колонки - строка

RETURN &("{||TRANSFORM(IF(p_value[n_s]["+c+"]!=NIL,p_value[n_s]["+c+;
           "],''),p_pict["+c+"])}")


//║ Функция:  ASKIPBR( <x> ) --> nCount
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение:  SKIP - блок
//║ Возвращает: nCount - количество шагов, на котоpое можно пеpейти.
//║ Параметры:  < n >  - количество шагов, на котоpое нужно пеpейти.
//║
//║ Используемые внешние переменные:
//║                 N_S
//║                 P_VALUE
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION     aSkipBr( x )
LOCAL   nCount := 0                       // Счетчик шагов
LOCAL   len := LEN( p_value )             // Счетчик шагов

IF x==0.AND.n_s<=len
  DO CASE
    CASE NUMPROC=="01"
      IF p_value[n_s,3]<>NIL
      sp06->(DBSEEK(p_value[n_s,3]));p_value[n_s,4]:=Sp06->naim6
      ENDIF
      IF p_value[n_s,5]<>NIL
      sp10->(DBSEEK(p_value[n_s,5]));p_value[n_s,6]:=_fio()
      ENDIF
    CASE NUMPROC=="24"
      IF p_value[n_s,2]<>NIL
      sp44->(DBSEEK(p_value[n_s,2]));p_value[n_s,3]:=sp44->naim7
      ENDIF
    CASE NUMPROC=="09".or.NUMPROC=="10".or.NUMPROC=="30"
      IF p_value[n_s,1]<>NIL
      sp44->(DBSEEK(p_value[n_s,1]));p_value[n_s,2]:=sp44->naim7
      ENDIF
    CASE NUMPROC=="02".or.NUMPROC=="04"
      IF p_value[n_s,2]<>NIL
      sp10->(DBSEEK(p_value[n_s,2]));p_value[n_s,1]:=_fio()
      ENDIF
    CASE NUMPROC=="05".or.NUMPROC=="06"
      IF p_value[n_s,3]<>NIL
      sp10->(DBSEEK(p_value[n_s,3]));p_value[n_s,4]:=_fio()
      ENDIF
    CASE NUMPROC=="03"
      IF p_value[n_s,4]<>NIL
      sp06->(DBSEEK(p_value[n_s,4]));p_value[n_s,5]:=Sp06->naim6
      ENDIF
      IF p_value[n_s,2]<>NIL
      sp44->(DBSEEK(p_value[n_s,2]));p_value[n_s,3]:=sp44->naim7
      ENDIF
  ENDCASE
  RETURN 0
ENDIF


   IF( x > 0 )
     WHILE nCount < x
        IF n_s+nCount >= len ; EXIT ; END
        nCount++
     END
   ELSEIF (x < 0)
     WHILE nCount > x
        IF n_s+nCount <= 1 ; EXIT ; END
        nCount--
     END
   END
   n_s += nCount

RETURN( ncount )


//║ Функция:  AGET( ) --> NIL
//║ Назначение:  Редактиpование поля объекта
//║ Возвращает: NIL
//║ Используемые внешние переменные:
//║              AB
//║              L_INS
//║              ACHANGE
//║              P_VALUE
//║              N_S
//║              P_PICT
//║              P_VALID
//║              P_NAME
//║              A_RECNO
STATIC FUNCTION    aGet( )

LOCAL key                           // Код клавиши
LOCAL ins := SETKEY(K_INS)          // Запомнили состояние
LOCAL se := SET(_SET_ESCAPE,!l_ins) // Запомнили состояние
LOCAL colpos := ab:colpos           // Номер колонки

// Обнулили флаг
l_ins := .f.

   // Если можно редактировать
   IF  achange[ colpos ]
//      SETKEY(K_INS,{||SETCURSOR(IF(ReadInsert(!ReadInsert()),;
//                                               SC_NORMAL,SC_INSERT))}  )
//      SETCURSOR( IF(ReadInsert(), SC_INSERT, SC_NORMAL) )
      @  ROW(), COL()  GET p_value[n_s][colpos]   ;
                       PICTURE p_pict[colpos]   ;
                       VALID EVAL(&("{||"+p_valid[colpos]+"}"))
      READ
      key := LASTKEY()
 //     SETCURSOR(0)
      SETKEY( K_INS, ins )
      IF LASTKEY() # K_ESC

         // Если не ESC

         ab:refreshCurrent()
         &(SUBSTR(p_name[colpos],1,AT("->",p_name[colpos])-1))->;
                                           (DBGOTO(a_recno[n_s,colpos]))
         &(p_name[colpos]) := p_value[n_s][colpos]
      END
  END
  SET(_SET_ESCAPE,se)
RETURN   NIL
//║ Функция: CONNECT( <ab> ) --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Восстанавливает pазделители объекта с видеофоpмой.
//║ Возвращает: NIL
//║ Параметры:  <ab>       -  TBrowse object.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты: Задеpжка пpи стабилизации объекта.
//║ Примечания:
//╚═══════
//

STATIC FUNCTION connect(ab)

// Что ищем
#define STRING_SEARCH    "┌─┬┐═╒╤╕"
#define STRING2_SEARCH   "─╔═╦╗╓╥╖"

// Что восстанавливаем
#define STRING_REPLACE   "├┴┼┤╧╞╪╡"
#define STRING2_REPLACE  "╨╠╩╬╣╟╫╢"


LOCAL nStr := ab:ntop-2    //  Строка в объекте для чтения

// Прочитали строку, удалили аттрибуты
LOCAL cStringOld:= STRTRAN(TRANSFORM(SAVESCREEN(nStr,1,nStr+1,78),;
                                              REPLICATE("XЇ",78*2)),"Ї")
// Обрезали рамку
LOCAL cString   := SUBSTR(cStringOld,1,78)

LOCAL clr := ab:colorspec              // Цвет вывода
LOCAL i := 0                           // Текущая позиция
LOCAL k                                // Смещение
LOCAL row:=ROW(),col:=COL()            // Координаты входа
LOCAL bufo                             // Буфер для строки-источника
LOCAL bufn                             // Буфер для строки-приемника
LOCAL l_buf                            // Что нашли ?

cStringOld := SUBSTR(cStringOld,79)

   // Пока находим
   WHILE EVAL({|x1,x2|x1:=AT("│",cString),;
                   x2:=AT("║",cString),;
              k:=IF(x1==0,x2,IF(x2==0,x1,MIN(x1,x2))),l_buf:=(k==x1),k})#0
      i += k
      bufo := SUBSTR(cStringOld,i,1)
      bufn := SUBSTR(IF(l_buf,STRING_REPLACE,STRING2_REPLACE) ,;
                       AT(bufo,IF(l_buf,STRING_SEARCH,STRING2_SEARCH) ),1)
      // Если еще нет, выводим
      IF bufo # bufn
         SETPOS(nStr+1,i)
         DISPOUT(bufn,clr)
      END
      cString := SUBSTR(cString,k+1)
   END

// Восстанавливаем координаты
SETPOS(row,col)

#undef STRING_SEARCH
#undef STRING_REPLACE
#undef STRING2_SEARCH
#undef STRING2_REPLACE
RETURN NIL


//
//╔══════════════════════════════════════════════════════════
//║ Функция: DELDOC() --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Удаление документа.
//║ Возвращает: NIL
//║ Параметры:
//║ Используемые внешние переменные:
//║                AREL1
//║                AREL2
//║                LMORE
//║                WAIT_BLOCK
//║                MOVE_BLOCK
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║             FZ1.DBF
//║             FZ2.DBF
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION deldoc()
LOCAL i := 0         // Служебная переменная-счетчик
LOCAL j := 0         // Служебная переменная-счетчик
LOCAL na             // Номер области файла в связке с FZ1
LOCAL na2            // Номер области файла в связке с FZ2

   // Отработали связи, удалили запись FZ1
   fz1->(DBGOTO(RECNO()))
   fz1->(DBDELETE())
   FOR i = 0 TO LEN(arel1)   // По связям FZ1

      // Удаляем в ведомых из AREL1

      na := SELECT(IF(i==0,"FZ2",arel1[i]))

      WHILE (na)->vnum1==fz1->vnum1
         (na)->(DBGOTO(RECNO()))
         (na)->(DBDELETE())

         IF i==0

            // Если идем по FZ2

            FOR j = 0 TO LEN(arel2)

               // Удаляем в ведомых из AREL2

               na2 := SELECT(IF(j==0,"FZ3",arel2[j]))

               WHILE (na2)->vnum2==fz2->vnum2
                  (na2)->(DBDELETE())
                  (na2)->(DBSKIP())
               END
            NEXT
         END
         (na)->(DBSKIP())
      END

   NEXT

  // Ушли с удаленной
  fz1->(DBSKIP())

  IF(fz1->(EOF()))

     fz1->(DBSKIP(-1))
     IF(fz1->(BOF()))

        // Если документов нет

        lMore := .f.
        DispError('  Видаленi усi документи. ')
     END
END
IF lMore

   // Отработали связи

   EVAL(Move_Block,0)
END

RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: DELFZ3() --> L_YES
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Удалить запись в FZ3
//║ Возвращает: L_YES - Запись удалена ?
//║ Параметры:
//║ Используемые внешние переменные:
//║                P_VALUE
//║                A_RECNO
//║                N_S
//║                P_FZ3
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║                FZ3.DBF
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION delfz3()
LOCAL l_yes := .F.

   // Идем на удаляемую запись
   fz3->(DBGOTO(a_recno[n_s,p_fz3[1]]))
   IF l_yes:=(a_recno[n_s,1] == NIL)

      // Если в строке только код оплат

      fz3->(DBDELETE())
      ADEL(p_value,n_s)
      ADEL(a_recno,n_s)
   ELSEIF l_yes:=(a_recno[n_s,1] # NIL .and. n_s+1<=LEN(p_value) .and. ;
               p_value[n_s+1,1] == NIL)

      // Если в строке не только код оплат

      fz3->(DBDELETE())

      // Сдвигаем вверх оставшиеся коды

      p_value[n_s,p_fz3[1] ] := p_value[n_s+1,p_fz3[1] ]
      p_value[n_s,p_fz3[2]]  := p_value[n_s+1,p_fz3[2]]
      a_recno[n_s,p_fz3[1] ] := a_recno[n_s+1,p_fz3[1] ]
      a_recno[n_s,p_fz3[2]]  := a_recno[n_s+1,p_fz3[2]]
      ADEL(p_value,n_s+1)
      ADEL(a_recno,n_s+1)
   END
   IF l_yes

      // Если удалили запись

      ASIZE(p_value,LEN(p_value)-1)
      ASIZE(a_recno,LEN(a_recno)-1)
   END
RETURN ( l_yes )

//
//╔══════════════════════════════════════════════════════════
//║ Функция: DELLINE() --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Удаление стpоки документа.
//║ Возвращает: NIL
//║ Параметры:
//║ Используемые внешние переменные:
//║                NUMPROC
//║                P_VALUE
//║                A_RECNO
//║                N_S
//║                P_FZ2
//║                P_FZ3
//║                AREL2
//║ Используемые процедуры и функции:
//║                L_NOT_LAST
//║ Используемые файлы и внешние устройства:
//║                FZ2.DBF
//║                FZ3.DBF
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION delline()
LOCAL j                        // Счетчик
LOCAL sd := .f.                // Служебный флаг
LOCAL na2                      // Номер области файла в связке с FZ2
LOCAL otdnbuf                  // Буфер для fz2->OTDN
LOCAL m_vnum2                  // Буфер для fz2->VNUN2

    IF (numproc == "07" .or. numproc == "08") .and. ! L_NOT_LAST()

       // Если учет.лист или пут. лист трактора
       // Пеpеносим дни на последний шифp затpат,если удален последний

       fz2->(DBGOTO(a_recno[n_s,p_fz2[1]]))
       otdnbuf := fz2->otdn

       fz2->(DBSKIP(-1))
       fz2->otdn := otdnbuf
    END
    IF (numproc == "09") .and. ! L_NOT_LAST()

       // Если пут. лист автомобиля
       // Пеpеносим коды оплат на последний шифp затpат,
       // если удален последний

       fz2->(DBGOTO(a_recno[n_s-1,p_fz2[1]]))
       m_vnum2 := fz2->vnum2
       p_value[n_s-1,p_fz3[1]] := p_value[n_s,p_fz3[1]]
       p_value[n_s-1,p_fz3[2]] := p_value[n_s,p_fz3[2]]
       fz3->kopu := p_value[n_s,p_fz3[1]]
       fz3->sum  := p_value[n_s,p_fz3[2]]

       FOR j = n_s+1 TO LEN(p_value)
          fz3->(DBGOTO(a_recno[j,p_fz3[1]]))
          fz3->vnum2 := m_vnum2
       NEXT
    END

    fz2->(DBGOTO(a_recno[n_s,p_fz2[1]]))
    fz2->(DBDELETE())
    ADEL(p_value,n_s)
    ADEL(a_recno,n_s)
    ASIZE(p_value,LEN(p_value)-1)
    ASIZE(a_recno,LEN(a_recno)-1)
    FOR j = 0 TO LEN(arel2)

       na2 := SELECT(IF(j==0,"FZ3",arel2[j]))

       WHILE (na2)->vnum2==fz2->vnum2
          (na2)->(DBDELETE())
          (na2)->(DBSKIP())
          IF j == 0 .and. sd
             ADEL(p_value,n_s)
             ADEL(a_recno,n_s)
             ASIZE(p_value,LEN(p_value)-1)
             ASIZE(a_recno,LEN(a_recno)-1)
          END
          sd := .T.
       END
    NEXT

RETURN NIL



//
//╔══════════════════════════════════════════════════════════
//║ Функция: L_NOT_LAST() --> L_NOT_LAST
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Опpеделить, не последняя ли текущая стpока из
//║             существующих в документе.
//║ Возвращает: .T. - если текущая стpока документа не последняя.
//║ Параметры:
//║ Используемые внешние переменные:
//║             P_VALUE
//║             N_S
//║             AB
//║             P_FZ3
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION L_NOT_LAST()
RETURN IF(ASCAN(p_fz3,ab:colpos) ==0,;
           ASCAN(p_value,{|a|a[1] # NIL},n_s+1) # 0,.F.)


//
//╔══════════════════════════════════════════════════════════
//║ Функция: L_NOT_ONE() --> L_NOT_ONE
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Опpеделить, не единственная ли стpока в документе.
//║ Возвращает: .T. - если текущая стpока документа не единственная.
//║ Параметры:
//║ Используемые внешние переменные:
//║             P_VALUE
//║             N_S
//║             AB
//║             P_FZ3
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION L_NOT_ONE()
LOCAL Count := 0          // Счетчик строк

// Считаем ненулевые стpоки по FZ2
IF ASCAN(p_fz3,ab:colpos) ==0
   AEVAL(p_value,{|a|IF(a[1]#NIL,Count++,)})
END
RETURN (Count > 1)


//
//╔══════════════════════════════════════════════════════════
//║ Функция: ME_FUNC( < mode > ) --> nRet
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Обработка клавиш в MEMOEDIT().
//║ Возвращает: Код возврата MEMOEDIT
//║ Параметры:  Режим MEMOEDIT.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION me_func(mode)
IF mode == ME_IDLE
   KEYBOARD CHR(K_ESC)
END
RETURN ME_DEFAULT

//
//╔══════════════════════════════════════════════════════════
//║ Функция: SERV1() --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Отpаботка запpещения захода на "пустое поле".
//║ Возвращает: NIL
//║ Параметры:
//║ Используемые внешние переменные:
//║              N_S
//║              P_VALUE
//║              AB
//║ Используемые процедуры и функции:
//║              _STAB
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION SERV1()
LOCAL i , j      // Счетчики циклов


DISPBEGIN()

//  Стабилизируем объект
_Stab()

// Если вышли за пределы массива или на пустое поле
IF n_s > LEN(p_value) .or. p_value[n_s,ab:colpos] == NIL
   FOR i = 1 TO len(p_value)-n_s

      // Ищем непустое поле вниз

      IF p_value[n_s + i,ab:colpos] # NIL
         EXIT
      END
   NEXT
   IF i # len(p_value)-n_s + 1

      // Если нашли

      DISPBEGIN()
      FOR j = 1 TO i ; ab:down() ; NEXT
      DISPEND()
      _Stab()

   ELSE

      // Если не нашли

      FOR i = 1 TO n_s - 1

        // Ищем непустое поле вверх

         IF p_value[n_s - i,ab:colpos] # NIL
            EXIT
         END
      NEXT
      IF i # n_s

      // Если нашли

         DISPBEGIN()
         FOR j = 1 TO i ; ab:up() ; NEXT
         DISPEND()
      _Stab()
      END
   END
END
DISPEND()

RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: S_F_DBE()
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Обpаботка клавиш в DBEDIT() пpи выбоpе документа.
//║ Возвращает: Код возвpата в DBEDIT().
//║ Параметры:
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION  s_f_dbe()
LOCAL old_recno:= RECNO()     // Запомнили положение в файле
LOCAL key := LASTKEY()        // Запомнили клавишу

   IF key == K_ESC

      DBGOTO( old_recno )

   ELSEIF key == K_RETURN

   ELSE

      RETURN DE_CONT

   END
RETURN DE_ABORT

//
//╔══════════════════════════════════════════════════════════
//║ Функция: SayHeadSep(<oTb>, <nHigh>, <nTip>) --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение:  Вывод pазделителей шапки.
//║ Возвращает:  NIL
//║ Параметры:   <oTb>       -  TBrowse object
//║              <nHigh>     -  макс. высота шапки в строках
//║              <nTip>      -  тип линии над шапкой
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты: Задеpжка пpи стабилизации объекта.
//║ Примечания:
//╚═══════
//

STATIC FUNCTION   SayHeadSep(oTb, nHigh, nTip)
#define   SINGLE    1
#define   DOUBLE    2

#define   CHAR_1   '│'
#define   CHAR_2   '║'

#define   TIP_1    '─'
#define   TIP_2    '═'

#define   HEAD_1   '┬'
#define   HEAD_2   '╥'
#define   HEAD_3   '╦'
#define   HEAD_4   '╤'
 LOCAL   nTop := oTb:nTop - 1, nLeft := oTb:nLeft, nRight :=oTb:nRight,;
         nBottom := oTb:nBottom - 1, cClr := oTb:colorSpec
 LOCAL   cBuf := SAVESCREEN(nBottom, nLeft, nBottom, nRight)
 LOCAL   aX := {}, aChar := {}, aHead := {}
 LOCAL   nX := 0, nPos := 0, nI, nK, y := ROW(), x := COL()

  WHILE(.T.)
    IF((nPos := AT(CHAR_1, cBuf)) != 0)
      AADD(aChar, CHAR_1)
      AADD(aHead, IF(nTip == SINGLE, HEAD_1, HEAD_4))
    ELSEIF((nPos := AT(CHAR_2, cBuf)) != 0)
      AADD(aChar, CHAR_2)
      AADD(aHead, IF(nTip == SINGLE, HEAD_2, HEAD_3))
    ELSE
      EXIT
    END
    AADD(aX, (nX += (nPos + 1)/2) + nLeft - 1)
    cBuf := SUBSTR(cBuf, nPos + 2)
  END

  IF( ! EMPTY(aX))
    SETPOS(nTop, nLeft)
    DISPOUT( REPLICATE( IF(nTip == SINGLE, TIP_1, TIP_2),;
                        nRight - nLeft + 1),;
             cClr)
    FOR  nI := 1  TO  LEN(aX)
      SETPOS(nTop, aX[nI])
      DISPOUT(aHead[nI], cClr)
        FOR  nK := 1  TO  nHigh
          SETPOS(nTop + nK, aX[nI])
          DISPOUT(aChar[nI], cClr)
        NEXT
    NEXT
  END

  SETPOS(y, x)

#undef   SINGLE
#undef   DOUBLE

#undef   CHAR_1
#undef   CHAR_2

#undef   TIP_1
#undef   TIP_2

#undef   HEAD_1
#undef   HEAD_2
#undef   HEAD_3
#undef   HEAD_4
RETURN NIL


//
//╔══════════════════════════════════════════════════════════
//║ Функция: SAYWDF(<cnum>) --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Вывод видеоформы.
//║ Возвращает: NIL
//║ Параметры:  < cnum > - упpавляющая пеpеменная
//║ Используемые внешние переменные:
//║              VVOD_CLR
//║ Используемые процедуры и функции:
//║              ME_FUNC
//║              DELCLOCK
//║ Используемые файлы и внешние устройства:
//║              WDF.WDF
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION SAYWDF(num)
// Выводим форму
Screen->(DBSEEK("VD"+num))
SETCOLOR(VVOD_CLR)
MEMOEDIT(screen->vd,1,0,24,79,.F.,"ME_FUNC",81)
DISPBOX(0,0,24,79,2)
SETPOS(0,5)
DISPOUT(p_npr,"GR+/B")
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: SDEL( ) --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Обpаботка удаления записи.
//║ Возвращает: NIL
//║ Параметры:
//║ Используемые внешние переменные:
//║                AB
//║                P_FZ3
//║                WAIT_BLOCK
//║                N_S
//║ Используемые процедуры и функции:
//║                DELDOC
//║                DELLINE
//║                DELFZ3
//║                SERV1
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION sdel()
LOCAL f := .t.            // Можно удалять ?

IF ab:autolite

   // Если находимся не на шапке

   IF (f := L_NOT_ONE())
      delline()
   ELSEIF ASCAN(p_fz3,ab:colpos) # 0

   // Поле FZ3

      f := delfz3()
   END
   IF !f
      DispError('Запис не може бути знищено !')
   END
   ab:refreshall()
   n_s := MIN(n_s,LEN(p_value))
   SERV1()
ELSE

   //Если находимся на шапке

   deldoc()
END
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: SINS( ) --> lins
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Вставка записи в файл FZ3.
//║ Возвращает: Если запись вставлена , .T. ,иначе .F.
//║ Параметры:
//║ Используемые внешние переменные:
//║             P_FZ3
//║             AB
//║             A_RECNO
//║             N_S
//║             P_VALUE
//║ Используемые процедуры и функции:
//║             INSERT
//║             ASKUSER
//║ Используемые файлы и внешние устройства:
//║             FZ3.DBF
//║ Побочные эффекты:  Если вставка пpоизводится в большой(поpядка
//║   нескольких тысяч записей) файл , пpосесс очень долгий, т.к.
//║   вставка пpоизводится физически.
//║ Примечания:
//╚═══════
//

STATIC FUNCTION sins()
LOCAL i         // Параметр цикла
LOCAL m_vnum2   // FZ3->VNUM2
LOCAL lins      // Флаг выполнения вставки

   IF ASCAN(p_fz3,ab:colpos) # 0.and. ;  // Поле FZ3
              ANSWERu('Добавити запис?')==YES

      // Поле FZ3 и подтверждение

      fz3->(DBGOTO(a_recno[n_s,p_fz3[1]]))
      DBSELECTAREA("fz3")

      m_vnum2 := fz3->vnum2

      // Вставка

      DBSETORDER(0)
      lins := INSERT()
      DBSETORDER(1)

      IF lins

         // Если успешно

         REPLACE fz3->vnum2 with m_vnum2
         ASIZE(p_value,LEN(p_value)+1)
         AINS(p_value,n_s+1)
         ASIZE(a_recno,LEN(a_recno)+1)
         AINS(a_recno,n_s+1)
         p_value[n_s+1]:=ARRAY(LEN(p_value[n_s]))
         a_recno[n_s+1]:=ARRAY(LEN(a_recno[n_s]))
         p_value[n_s+1, p_fz3[1]] := fz3->kopu
         p_value[n_s+1,p_fz3[2]] := fz3->sum
         a_recno[n_s+1,p_fz3[1]]  := a_recno[n_s+1,p_fz3[2]] := ;
                                                          fz3->(RECNO())
         FOR i = 1 TO LEN(a_recno)
            IF a_recno[i,p_fz3[1]]>=A_recno[n_s+1,p_fz3[1]].and. i#n_s+1
               a_recno[i,p_fz3[1]]++
               a_recno[i,p_fz3[2]]++
            END
         NEXT
         ab:down()
         KEYBOARD CHR(K_LEFT)+CHR(K_RETURN)
         ab:refreshall()
      END
   ELSE
      TONE(125,1)
   END

RETURN lins

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sUseFz123(<lopenclose>) --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение:  Подготовить файлы к работе либо закрыть их
//║ Возвращает:  NIL
//║ Параметры:   [ < lopenclose > ] - если .T. - откpыть файлы , иначе
//║                                   закpыть. По умолчанию - .T.
//║ Используемые внешние переменные:
//║               NUMPROC
//║               M_DBSPATH
//║               AREL1
//║               AREL2
//║               AF1
//║               AF2
//║               ASP
//║ Используемые процедуры и функции:
//║               COPYDBFNTX
//║               DELDBFNTX
//║ Используемые файлы и внешние устройства:
//║               LOPEN.DBF
//║               LOPEN.NTX
//║               LRELAT.DBF
//║               LRELAT.NTX
//║               FZ1.DBF
//║               FZ1.NTX
//║               FZ2.DBF
//║               FZ2.NTX
//║               FZ3.DBF
//║               FZ3.NTX
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION sUseFz123(lopenclose,s_files)
LOCAL i,n:=LEN(aSp)
FIELD Finput,Foutput

DEFAULT .t. TO lopenclose

IF lopenclose
   // Откpываем служебный файл LOPEN
NET USE (m_syspath+"LOPENA") INDEX (m_syspath+"LOPENA") ALIAS lopen NEW READONLY
   DBSEEK(numproc)
   // Откpываем служебный файл LRELAT
NET USE (m_syspath+"LRELAT") INDEX (m_syspath+"LRELAT") NEW READONLY
   DBSEEK(numproc)

   // Откpываем FZ1
   DBUseArea(.T.,,m_dbspath+"FZ1")
   // Устанавливаем фильтp
   IIF(!EMPTY(lopen->fz1filter),;
       DBSETFILTER(&("{||"+lopen->fz1filter+"}"),lopen->fz1filter),)

   // Откpываем FZ2
   DBUseArea(.T.,,m_dbspath+"FZ2")
   DBSetIndex(m_dbspath+"FZ2")
   FZ1->(DBSETRELATION("FZ2",{||STR(FZ1->VNUM1,7)},"STR(FZ1->VNUM1,7)"))

   // Откpываем FZ3
   DBUseArea(.T.,,m_dbspath+"FZ3")
   DBSetIndex(m_dbspath+"FZ3")
   FZ2->(DBSETRELATION("FZ3",{||STR(FZ2->VNUM2,7)},"STR(FZ2->VNUM1,7)"))

   aRel1 := {}
   aRel2 := {}

   // Откpываем остальные файлы
   AEVAL(aF1,{|a|IF(lopen->(FIELDGET(FIELDPOS("L"+a))),;
      EVAL({|a|DBUseArea(.T.,,m_dbspath+a),;
               DBSetIndex(m_dbspath+a),;
        FZ1->(DBSETRELATION(a,{||STR(FZ1->VNUM1,7)},;
                                                 "STR(FZ1->VNUM1,7)")),;
        AADD(aRel1,a)},a),NIL)})
   AEVAL(aF2,{|a|IF(lopen->(FIELDGET(FIELDPOS("L"+a))),;
      EVAL({|a|DBUseArea(.T.,,m_dbspath+a),;
              DBSetIndex(m_dbspath+a),;
        FZ2->(DBSETRELATION(a,{||STR(FZ2->VNUM2,7) },;
                                                 "STR(FZ2->VNUM2,7)")),;
        AADD(aRel2,a)},a),NIL)})


   // Откpываем необходимые спpавочники
   FOR i:=1 TO n
//    ?i,"||||",aSp[i]
    IF lopen->(FieldGET(FIELDPOS("L"+aSp[i])))
      SopenFiles(aSp[i],@s_files)
    ENDIF
  NEXT
   // Закpываем служебный файл LOPEN
   sele sp08
   set filter to sp08->kopu<"100"
   lopen->(DBCLOSEAREA())
   // Устанавливаем связи
   lrelat;
       ->(;
          DBEVAL({||IF(SELECT(finput)#0.and.SELECT(foutput)#0,;
               &(finput);
                  ->(;
                    DBSETRELATION(lrelat->foutput,;
                                  &("{||"+lrelat->frelation+"}"),;
                                  lrelat->frelation)),;
                    NIL;
                    );
                    },,{||numproc==lrelat->koddoc};
                );
         )
   // Закpываем служебный файл LRELAT
   lrelat->(DBCLOSEAREA())
   fz1->(DBGOTOP())
ELSE
   DBCOMMITALL()
   fz1->(DBCLOSEAREA())
   fz2->(DBCLOSEAREA())
   fz3->(DBCLOSEAREA())
   AEVAL(aF1,{|a|IF(SELECT(a)#0,&(a)->(DBCLOSEAREA()),)})
   AEVAL(aF2,{|a|IF(SELECT(a)#0,&(a)->(DBCLOSEAREA()),)})
   ScloseFiles(s_files)
ENDIF
RETURN NIL



//
//╔══════════════════════════════════════════════════════════
//║ Функция: _STAB() --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Стабилизация объекта.
//║ Возвращает: NIL
//║ Параметры:
//║ Используемые внешние переменные:
//║             AB
//║             HSEPROW
//║ Используемые процедуры и функции:
//║             SAYHEADSEP
//║             CONNECT
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION _STAB()
DISPBEGIN()
   // Стабилизиpуется объект.
   WHILE( ! ab:stabilize() ) ;  END

   // Восстанавливаются pазделители шапки
   SAYHEADSEP(ab,hseprow+1,2)

   // Восстанавливаются pазделители с видеофоpмой
   connect(ab)
DISPEND()
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Группа функций SARR** - служебные функции для формирования
//║ рабочих массивов и переменных обработки конкретных документов
//║
//║ К ним относятся функции :
//║                       SARR01
//║                       SARR02
//║                       SARR03
//║                       SARR04
//║                       SARR05
//║                       SARR06
//║                       SARR07
//║                       SARR08
//║                       SARR09
//║                       SARR10
//║                       SARR24
//║                       SARR30
//║                       _SARR
//║
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║
//║ Назначение: формирование рабочих массивов и
//║             переменных обработки конкретных документов
//║ Возвращают: NIL
//║ Параметры:  Нет.
//║ Примечания: Особенности каждой функции описаны ниже
//╚═══════
//

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr01() --> NIL
//║ Документ: Универсальный реестр по зарплате.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║              _SARR
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION Sarr01()
RETURN _sarr()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr02() --> NIL
//║ Документ: Бpигадный наpяд.
//║ Используемые внешние переменные:
//║              M_BRGD
//║              M_KSASH
//║              M_VRAB
//║ Используемые процедуры и функции:
//║              _SARR
//║ Используемые файлы и внешние устройства:
//║              FZ2.DBF
//║              SP01.DBF
//║              SP06.DBF
//║              sp44.DBF
//╚═══════
//
FUNCTION Sarr02()
  Sp01->(DBSEEK(fz2->brgd))
  Sp44->(DBSEEK(fz2->ksash))
  Sp06->(DBSEEK(fz2->vrab))
m_brgd  := {fz2->brgd,sp01->naim1}
m_ksash := {fz2->ksash,sp44->naim7}
m_vrab  := {fz2->vrab,sp06->naim6}
RETURN _sarr()


//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr03() --> NIL
//║ Документ: Индивидуальный наpяд.
//║ Используемые внешние переменные:
//║              M_TABN
//║ Используемые процедуры и функции:
//║              _SARR
//║              _FIOFULL
//║ Используемые файлы и внешние устройства:
//║              FZ2.DBF
//╚═══════
//
FUNCTION Sarr03()
  Sp10->(DBSEEK(fz2->tabn))
m_tabn  := {fz2->tabn,_fiofull()}
RETURN _sarr()


//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr04() --> NIL
//║ Документ: Табель учета рабочего времени.
//║ Используемые внешние переменные:
//║              M_BRGD
//║ Используемые процедуры и функции:
//║              _SARR
//║ Используемые файлы и внешние устройства:
//║              FZ2.DBF
//║              SP01.DBF
//╚═══════
//
//
FUNCTION Sarr04()
  Sp01->(DBSEEK(fz2->brgd))
m_brgd  := {fz2->brgd,sp01->naim1}
RETURN _sarr()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr05() --> NIL
//║ Документ: Оплата отпускных.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║              _SARR
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION Sarr05()
RETURN _sarr()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr06() --> NIL
//║ Документ: Оплата больничных.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║              _SARR
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION Sarr06()
RETURN _sarr()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr07() --> NIL
//║ Документ: Учетный лист такториста-машиниста.
//║ Используемые внешние переменные:
//║                    P_VALUE
//║                    A_RECNO
//║                    M_BRGD
//║                    M_TABN
//║                    M_NTR
//║                    P_FZ3
//║                    P_FZ2
//║                    P_FZ2T
//║                    P_NAME
//║ Используемые процедуры и функции:
//║                    _FIO
//║ Используемые файлы и внешние устройства:
//║                    FZ1.DBF
//║                    FZ1T.DBF
//║                    FZ2.DBF
//║                    FZ2T.DBF
//║                    FZ2B.DBF
//║                    FZ3.DBF
//║                    SP01.DBF
//║                    SP13B.DBF
//╚═══════
//
FUNCTION Sarr07()

LOCAL i   , j     // Счетчики циклов

p_value := {}
a_recno := {}

// Определяем поля шапки
#ifdef _L_BRGD
    m_brgd  := {fz2b->brgd,sp01->naim1}
#endif
m_tabn  := {fz2->tabn,_fio()}
m_ntr   := {fz1t->ntr,sp13b->naim13b,fz1t->ostnm,fz1t->zapr,;
                                                  fz1t->otmd,fz1t->otms}
// Заполняем массивы P_VALUE и A_RECNO

WHILE fz2->vnum1 == fz1->vnum1 .and. !fz2->(EOF())
    // По записям FZ2

    AADD(p_value,ARRAY(p_fz3[2]))
    AADD(a_recno,ARRAY(p_fz3[2]))

    FOR i = 1 TO LEN(p_fz2)
       p_value[LEN(p_value),p_fz2[i]] := &(p_name[p_fz2[i]])
       a_recno [LEN(a_recno) ,p_fz2[i]] := fz2->(RECNO())
    NEXT
    FOR i = 1 TO LEN(p_fz2t)
       p_value[LEN(p_value),p_fz2t[i]] := &(p_name[p_fz2t[i]])
       a_recno [LEN(a_recno) ,p_fz2t[i]] := fz2t->(RECNO())
    NEXT


    IF !fz3->(EOF())
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
    END
    fz3->(DBSKIP())
    WHILE fz3->vnum2 == fz2->vnum2
       // По записям FZ3

       AADD(p_value,ARRAY(p_fz3[2]))
       AADD(a_recno,ARRAY(p_fz3[2]))
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
       fz3->(DBSKIP())
    END

    FZ2->(DBSKIP())
END

RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr08() --> NIL
//║ Документ: Путевой лист тактора.
//║ Используемые внешние переменные:
//║                    P_VALUE
//║                    A_RECNO
//║                    M_BRGD
//║                    M_TABN
//║                    M_NTR
//║                    P_FZ3
//║                    P_FZ2
//║                    P_FZ2T
//║                    P_FZ2TP
//║                    P_NAME
//║ Используемые процедуры и функции:
//║                    _FIO
//║ Используемые файлы и внешние устройства:
//║                    FZ1.DBF
//║                    FZ1T.DBF
//║                    FZ2.DBF
//║                    FZ2T.DBF
//║                    FZ2TP.DBF
//║                    FZ2B.DBF
//║                    FZ3.DBF
//║                    SP01.DBF
//║                    SP13B.DBF
//╚═══════
//
FUNCTION Sarr08()
LOCAL i   , j        // Счетчики циклов

p_value := {}
a_recno := {}

// Определяем поля шапки
#ifdef _L_BRGD
    m_brgd  := {fz2b->brgd,sp01->naim1}
#endif
m_tabn  := {fz2->tabn,_fio()}
m_ntr   := {fz1t->ntr,sp13b->naim13b,fz1t->ostnm,fz1t->zapr,fz1t->otmd,;
                                                             fz1t->otms}


// Заполняем массивы P_VALUE и A_RECNO
WHILE fz2->vnum1 == fz1->vnum1 .and. !fz2->(EOF())

    // По записям FZ2
    AADD(p_value,ARRAY(p_fz3[2]))
    AADD(a_recno,ARRAY(p_fz3[2]))

    FOR i = 1 TO LEN(p_fz2)
       p_value[LEN(p_value),p_fz2[i]] := &(p_name[p_fz2[i]])
       a_recno [LEN(a_recno) ,p_fz2[i]] := fz2->(RECNO())
    NEXT
    FOR i = 1 TO LEN(p_fz2t)
       p_value[LEN(p_value),p_fz2t[i]] := &(p_name[p_fz2t[i]])
       a_recno [LEN(a_recno) ,p_fz2t[i]] := fz2t->(RECNO())
    NEXT
    FOR i = 1 TO LEN(p_fz2tp)
       p_value[LEN(p_value),p_fz2tp[i]] := &(p_name[p_fz2tp[i]])
       a_recno [LEN(a_recno) ,p_fz2tp[i]] := fz2tp->(RECNO())
    NEXT
//@0,0 SAY fz3->(EOF())

    IF !fz3->(EOF())
//@1+LEN(p_value),0 SAY fz3->vnum2
//@1+LEN(p_value),20 SAY fz3->sum
//@7,10 SAY LEN(p_fz3)
//@8,10 SAY LEN(p_value[LEN(p_value)])
//@9,10 SAY LEN(a_recno [LEN(a_recno)])
//@10,10 SAY LEN(p_name)
       FOR i = 1 TO LEN(p_fz3)
//@11,10 SAY i 
//@12,10 SAY p_name[p_fz3[i]] 
//@13,10 SAY fz3->(RECNO()) 
//INKEY(0)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
    END
    fz3->(DBSKIP())
    WHILE fz3->vnum2 == fz2->vnum2

       // По записям FZ3
       AADD(p_value,ARRAY(p_fz3[2]))
       AADD(a_recno,ARRAY(p_fz3[2]))
//@1+LEN(p_value),0 SAY fz3->vnum2
//@1+LEN(p_value),20 SAY fz3->sum
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
       fz3->(DBSKIP())
    END
    FZ2->(DBSKIP())
END
//INKEY(0)
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr09() --> NIL
//║ Документ: Путевой лист грузового автомобиля.
//║ Используемые внешние переменные:
//║                    P_VALUE
//║                    A_RECNO
//║                    M_BRGD
//║                    M_TABN
//║                    M_GNAVT
//║                    M_TOPL
//║                    M_ALL
//║                    P_FZ3
//║                    P_FZ2
//║                    P_FZ2A
//║                    P_NAME
//║ Используемые процедуры и функции:
//║                    _FIO
//║ Используемые файлы и внешние устройства:
//║                    FZ1.DBF
//║                    FZ1AE.DBF
//║                    FZ1AT.DBF
//║                    FZ2.DBF
//║                    FZ2A.DBF
//║                    FZ3.DBF
//║                    SP01.DBF
//╚═══════
//
FUNCTION Sarr09()

FIELD vnvs,vndv,prvs,prpr,prsn,prtn,kolez,pggr,ptav,avdn,dohod

LOCAL i   , j        // Счетчики циклов
p_value := {}
a_recno := {}
m_tabn  := {fz2->tabn,_fio()}
m_brgd  := {fz2->brgd,sp01->naim1}
m_gnavt := fz1ae->gnavt
m_topl  := {}
m_all := ARRAY(10)
FOR i = 1 TO 3
   AADD(m_topl,{SPACE(20),SPACE(2),0,0})
END
i := 0
WHILE  fz1at->vnum1==fz1->vnum1 .and. i<3
sp44->(DBSEEK(fz1at->kmtop))
m_topl[++i,1]:=sp44->naim7
m_topl [i,2]:=fz1at->kmtop
m_topl [i,3]:=fz1at->zapr
m_topl [i,4]:=fz1at->(RECNO())
fz1at->(DBSKIP())
END
m_rashod := {fz1ae->rgnor,fz1ae->rgfak}
m_all := fz1ae->({vnvs,vndv,prvs,prpr,prsn,prtn,kolez,pggr,ptav,avdn,dohod})

// Заполняем массивы P_VALUE и A_RECNO
WHILE fz2->vnum1 == fz1->vnum1 .and. !fz2->(EOF())

    // По записям FZ2
    AADD(p_value,ARRAY(p_fz3[2]))
    AADD(a_recno,ARRAY(p_fz3[2]))

    FOR i = 1 TO LEN(p_fz2)
       p_value[LEN(p_value),p_fz2[i]] := &(p_name[p_fz2[i]])
       a_recno [LEN(a_recno) ,p_fz2[i]] := fz2->(RECNO())
    NEXT
    FOR i = 1 TO LEN(p_fz2a)
       p_value[LEN(p_value),p_fz2a[i]] := &(p_name[p_fz2a[i]])
       a_recno [LEN(a_recno) ,p_fz2a[i]] := fz2a->(RECNO())
    NEXT


    IF !fz3->(EOF())
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
    END
    fz3->(DBSKIP())
    WHILE fz3->vnum2 == fz2->vnum2
       // По записям FZ3
       AADD(p_value,ARRAY(p_fz3[2]))
       AADD(a_recno,ARRAY(p_fz3[2]))
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
       fz3->(DBSKIP())
    END

    FZ2->(DBSKIP())
END

RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr10() --> NIL
//║ Документ: Путевой лист грузового автомобиля(эксплуатация).
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                   SARR09
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION Sarr10()
RETURN sArr09()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr24() --> NIL
//║ Документ: Индивид. наряд помощника тракториста.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                  SARR03
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION Sarr24()
RETURN Sarr03()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Sarr30() --> NIL
//║ Документ: Путевой лист грузового автомобиля(с прицепом)
//║ Используемые внешние переменные:
//║                    P_VALUE
//║                    A_RECNO
//║                    M_BRGD
//║                    M_TABN
//║                    M_GNAVT
//║                    M_TOPL
//║                    M_ALL
//║                    M_PR
//║                    P_FZ3
//║                    P_FZ2
//║                    P_FZ2A
//║                    P_NAME
//║ Используемые процедуры и функции:
//║                    _FIO
//║ Используемые файлы и внешние устройства:
//║                    FZ1.DBF
//║                    FZ1AE.DBF
//║                    FZ1AT.DBF
//║                    FZ1AP.DBF
//║                    FZ2.DBF
//║                    FZ2A.DBF
//║                    FZ3.DBF
//║                    SP01.DBF
//╚═══════
//
FUNCTION Sarr30()

FIELD vnvs,vndv,prvs,prpr,prsn,prtn,kolez,pggr,ptav,avdn,dohod
FIELD gnp1,gnp2,gnp3,pgob1,pgob2,pgob3,ptpr,vtkpr
LOCAL i   , j   // Счетчики циклов
p_value := {}
a_recno := {}
  Sp01->(DBSEEK(fz2->brgd))
  Sp10->(DBSEEK(fz2->tabn))
m_tabn  := {fz2->tabn,_fio()}
m_brgd  := {fz2->brgd,sp01->naim1}
m_gnavt := fz1ae->gnavt
m_pr    := fz1ap->({gnp1,gnp2,gnp3,pgob1,pgob2,pgob3,ptpr,vtkpr})
m_topl  := {}
FOR i = 1 TO 3
   AADD(m_topl,{SPACE(20),SPACE(2),0,0})
END
i := 0
WHILE  fz1at->vnum1==fz1->vnum1 .and. i<3
sp44->(DBSEEK(fz1at->kmtop))
m_topl[++i,1]:=sp44->naim7
m_topl [i,2]:=fz1at->kmtop
m_topl [i,3]:=fz1at->zapr
m_topl [i,4]:=fz1at->(RECNO())
fz1at->(DBSKIP())
END
m_rashod := {fz1ae->rgnor,fz1ae->rgfak}
m_all := fz1ae->({vnvs,vndv,prvs,prpr,prsn,prtn,kolez,pggr,;
                                 ptav,avdn,fz2a->pgob,fz2a->vtkav,fz1ae->dohod})

// Заполняем массивы P_VALUE и A_RECNO
WHILE fz2->vnum1 == fz1->vnum1 .and. !fz2->(EOF())

    // По записям FZ2
    AADD(p_value,ARRAY(p_fz3[2]))
    AADD(a_recno,ARRAY(p_fz3[2]))

    FOR i = 1 TO LEN(p_fz2)
       p_value[LEN(p_value),p_fz2[i]] := &(p_name[p_fz2[i]])
       a_recno [LEN(a_recno) ,p_fz2[i]] := fz2->(RECNO())
    NEXT

    IF !fz3->(EOF())
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
    END
    fz3->(DBSKIP())
    WHILE fz3->vnum2 == fz2->vnum2
       // По записям FZ3
       AADD(p_value,ARRAY(p_fz3[2]))
       AADD(a_recno,ARRAY(p_fz3[2]))
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
       fz3->(DBSKIP())
    END
    FZ2->(DBSKIP())
END
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: _sarr() --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение: Фоpмиpование массивов A_RECNO и P_VALUE пpи связке
//║               FZ1 -->> FZ2 -->> FZ3.
//║ Возвращает: NIL
//║ Параметры:
//║ Используемые внешние переменные:
//║               P_VALUE
//║               A_RECNO
//║               P_FZ2
//║               P_FZ3
//║               P_NAME
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║                    FZ1.DBF
//║                    FZ2.DBF
//║                    FZ3.DBF
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION _sarr()
LOCAL i    // Счетчик циклов

p_value := {}
a_recno  := {}

// Заполняем массивы P_VALUE и A_RECNO
WHILE fz2->vnum1 == fz1->vnum1 .and. !fz2->(EOF())

    // По записям FZ2

    AADD(p_value,ARRAY(p_fz3[2]))
    AADD(a_recno,ARRAY(p_fz3[2]))

    FOR i = 1 TO LEN(p_fz2)
       p_value[LEN(p_value),p_fz2[i]] := &(p_name[p_fz2[i]])
       a_recno [LEN(a_recno) ,p_fz2[i]] := fz2->(RECNO())
    NEXT
    IF !fz3->(EOF())
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
    END
    fz3->(DBSKIP())
    WHILE fz3->vnum2 == fz2->vnum2

       // По записям FZ3

       AADD(p_value,ARRAY(p_fz3[2]))
       AADD(a_recno,ARRAY(p_fz3[2]))
       FOR i = 1 TO LEN(p_fz3)
          p_value[LEN(p_value),p_fz3[i]] := &(p_name[p_fz3[i]])
          a_recno [LEN(a_recno) ,p_fz3[i]] := fz3->(RECNO())
       NEXT
       fz3->(DBSKIP())
    END
    FZ2->(DBSKIP())
END
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Группа функций SSAY** - служебные функции для вывода
//║                         шапки конкретных документов
//║
//║ К ним относятся функции :
//║                       SSAY01
//║                       SSAY02
//║                       SSAY03
//║                       SSAY04
//║                       SSAY05
//║                       SSAY06
//║                       SSAY07
//║                       SSAY08
//║                       SSAY09
//║                       SSAY10
//║                       SSAY24
//║                       SSAY30
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║
//║ Назначение: Вывод шапки конкретноых документов
//║ Возвращают: NIL
//║ Параметры:  Нет.
//║ Примечания: Особенности каждой функции описаны ниже
//╚═══════
//


//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY01()
//║ Документ: Универсальный реестр по зарплате.
//║ Используемые внешние переменные:
//║              AB
//║              P_NPR
//║              VVOD_CLR
//║              HL_CLR
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//

FUNCTION sSAY01()

   //  Вывод шапки документа
   SETCOLOR(IF(!ab:autolite,hl_clr,"w+/B"))
   @ 03,42 SAY fz1->npch picture '999'
   @ 05,46 SAY fz1->ndoc picture '99999'
   @ 05,02 SAY fz1->ddoc
   @ 05,12 SAY p_npr COLOR "GR+/B"
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY02 ()
//║ Документ: Бpигадный наpяд.
//║ Используемые внешние переменные:
//║              AB
//║              P_NPR
//║              VVOD_CLR
//║              HL_CLR
//║              M_BRGD
//║              M_KSASH
//║              M_VRAB
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//

FUNCTION sSAY02()
   //  Вывод шапки документа
   SETCOLOR(IF(!ab:autolite,hl_clr,"w+/B"))
   @ 03,44 SAY fz1->npch picture '999'
   @ 05,46 SAY fz1->ndoc picture '99999'
   @ 05,02 SAY fz1->ddoc

   @ 7,16 SAY m_brgd [1] PICTURE '99'
   @ 8,16 SAY m_ksash[1] PICTURE '9999999'
   @ 9,16 SAY m_vrab [1] PICTURE '999'
   @ 7,23 SAY m_brgd [2]  COLOR "GR+/B"
   @ 8,23 SAY m_ksash[2]                       COLOR "GR+/B"
   @ 9,23 SAY m_vrab [2]                       COLOR "GR+/B"
   @ 05,12 SAY p_npr PICTURE REPLICATE("X",21) COLOR "GR+/B"
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY03 ()
//║ Документ: Индивидуальный наpяд.
//║ Используемые внешние переменные:
//║              AB
//║              P_NPR
//║              VVOD_CLR
//║              HL_CLR
//║              M_TABN
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//

FUNCTION sSAY03()

   //  Вывод шапки документа
   SETCOLOR(IF(!ab:autolite,hl_clr,"w+/B"))
   @ 03,44 SAY fz1->npch picture '999'
   @ 05,46 SAY fz1->ndoc picture '99999'
   @ 05,02 SAY fz1->ddoc

   @ 8,10 SAY m_tabn [1]
   @ 8,25 SAY m_tabn [2] COLOR "GR+/B"
   @ 05,12 SAY p_npr PICTURE REPLICATE("X",21) COLOR "GR+/B"
RETURN NIL
//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY04()
//║ Документ: Табель учета рабочего времени.
//║ Используемые внешние переменные:
//║              AB
//║              P_NPR
//║              VVOD_CLR
//║              HL_CLR
//║              M_BRGD
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//

FUNCTION sSAY04()
   //  Вывод шапки документа
   SETCOLOR(IF(!ab:autolite,hl_clr,"w+/B"))
   @ 03,68 SAY fz1->npch picture '999'
   @ 05,72 SAY fz1->ndoc picture '99999'
   @ 05,02 SAY fz1->ddoc

   @ 5,35 SAY m_brgd [1]
   @ 5,38 SAY m_brgd [2] COLOR "GR+/B"
   @ 05,12 SAY p_npr PICTURE REPLICATE("X",21) COLOR "GR+/B"
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY05()
//║ Документ: Оплата отпускных.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                SSAY01
//║ Используемые файлы и внешние устройства:
//╚═══════
//

FUNCTION sSAY05()
RETURN sSAY01()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY06()
//║ Документ: Оплата больничных.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                SSAY01
//║ Используемые файлы и внешние устройства:
//╚═══════
//

FUNCTION sSAY06()
RETURN sSAY01()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY07()
//║ Документ: Учетный лист такториста-машиниста.
//║ Используемые внешние переменные:
//║              AB
//║              P_NPR
//║              VVOD_CLR
//║              HL_CLR
//║              M_BRGD
//║              M_TABN
//║              M_NTR
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//

FUNCTION sSAY07()
LOCAL s := 0
   //  Вывод шапки документа
   SETCOLOR(IF(!ab:autolite,hl_clr,"w+/B"))
   @ 03,41 SAY fz1->npch picture '999'
   @ 06,39 SAY fz1->ndoc picture '99999'
   @ 4,4   SAY fz1->ddoc

   #ifdef _L_BRGD
       @ 6,9  SAY m_brgd [1]
       @ 6,12 SAY m_brgd [2] COLOR "GR+/B"
   #endif
   @ 04,15 SAY p_npr PICTURE REPLICATE("X",21) COLOR "GR+/B"

   @ 4,74 SAY m_tabn[1]
   @ 4,46 SAY m_tabn[2] COLOR "GR+/B"
   @ 6,73 SAY m_ntr[1] PICTURE '99999'
   @ 6,46 SAY m_ntr[2] COLOR "GR+/B"
   @ 9,2  SAY m_ntr[3] PICTURE "9999.9"
   @ 9,12 SAY m_ntr[4] PICTURE "9999.9"
   @ 9,21 SAY TRANSFORM(m_ntr[3]+;
                        m_ntr[4]-;
                        EVAL({||AEVAL(p_value,{|a|IF(a[1]#NIL,;
                                    s+=a[p_fz2t[LEN(p_fz2t)-1]],NIL)}),;
                                    s}),;
                "99999")  COLOR "GR+/B"
   @ 8,56 SAY m_ntr[5] PICTURE "99.9"
   @ 9,56 SAY m_ntr[6] PICTURE "99.9"


RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY08()
//║ Документ: Путевой лист тактора.
//║              AB
//║              P_NPR
//║              VVOD_CLR
//║              HL_CLR
//║              M_BRGD
//║              M_TABN
//║              M_NTR
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//

FUNCTION sSAY08()
LOCAL s := 0
   //  Вывод шапки документа
   SETCOLOR(IF(!ab:autolite,hl_clr,"w+/B"))
   @ 3,45 SAY fz1->npch picture '999'
   @ 5,44 SAY fz1->ndoc picture '99999'
   @ 5,4  SAY fz1->ddoc
   #ifdef _L_BRGD
       @ 9,51 SAY m_brgd [1]
       @ 9,54 SAY m_brgd [2] COLOR "GR+/B"
   #endif

   @ 05,15 SAY p_npr PICTURE REPLICATE("X",21) COLOR "GR+/B"

   @ 7,9  SAY m_tabn[1]
   @ 7,14 SAY m_tabn[2] COLOR "GR+/B"
   @ 7,53 SAY m_ntr[1] PICTURE '99999'
   @ 7,59 SAY m_ntr[2] COLOR "GR+/B"
   @ 5,52 SAY m_ntr[3] PICTURE "9999.9"
   @ 5,61 SAY m_ntr[4] PICTURE "9999.9"
   @ 5,72 SAY TRANSFORM(m_ntr[3]+;
                        m_ntr[4]-;
                        EVAL({||AEVAL(p_value,{|a|IF(a[1]#NIL,;
                                    s+=a[p_fz2tp[LEN(p_fz2tp)]],NIL)}),;
                                    s}),;
                "99999")  COLOR "GR+/B"
   @  9,30 SAY m_ntr[5] PICTURE "99.9"
   @ 10,30 SAY m_ntr[6] PICTURE "99.9"
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY09()
//║ Документ: Путевой лист грузового автомобиля.
//║              AB
//║              VVOD_CLR
//║              HL_CLR
//║              M_BRGD
//║              M_TABN
//║              M_GNAVT
//║              M_TOPL
//║              M_ALL
//║              M_RASHOD
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//

FUNCTION sSAY09()

   //  Вывод шапки документа

   SETCOLOR(IF(!ab:autolite,hl_clr,"w+/B"))
   @ 1,10 SAY fz1->npch picture '999'
   @ 1,38 SAY fz1->ndoc picture '99999'
   @ 1,64 SAY fz1->ddoc
   @ 2,10 SAY m_brgd[1] PICTURE "99"
   @ 2,13 SAY m_brgd[2] COLOR "GR+/B"
   @ 2,44 SAY m_tabn[1]
   @ 2,52 SAY m_tabn[2] COLOR "GR+/B"
   @ 4,20 SAY m_gnavt

   @ 5,25 SAY m_topl[1,1]  COLOR "GR+/B"
   @ 5,46 SAY m_topl[1,2]
   @ 5,50 SAY m_topl[1,3]   PICTURE "9999"

//   @ 6,25 SAY m_topl[2,1]  COLOR "GR+/B"
   @ 6,46 SAY IF(!EMPTY(m_topl[2,2]),m_topl[2,2],"")
   @ 6,50 SAY IF(!EMPTY(m_topl[2,3]),TRANSFORM(m_topl[2,3],"9999"),"")

//   @ 7,25 SAY m_topl[3,1]  COLOR "GR+/B"
   @ 7,46 SAY IF(!EMPTY(m_topl[3,2]),m_topl[3,2],"")
   @ 6,50 SAY IF(!EMPTY(m_topl[3,3]),TRANSFORM(m_topl[3,3],"9999"),"")

   @ 7,58 SAY m_rashod[1]   PICTURE "9999"
   @ 7,65 SAY m_rashod[2]   PICTURE "9999"

   @ 17,01  SAY m_all[1] PICTURE "999"
   @ 17,05  SAY m_all[2] PICTURE "999"
   @ 17,10  SAY m_all[3] PICTURE "999"
   @ 17,15  SAY m_all[4] PICTURE "999"
   @ 17,22  SAY m_all[5] PICTURE "999"
   @ 17,31  SAY m_all[6] PICTURE "999"
   @ 17,37  SAY m_all[7] PICTURE "999"
   @ 17,48  SAY m_all[8] PICTURE "99999"
   @ 17,55  SAY m_all[9] PICTURE "999.99"
   @ 17,71  SAY m_all[10] PICTURE "99.9"
RETURN NIL


//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY10()
//║ Документ: Путевой лист грузового автомобиля(эксплуатация).
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                SSAY09
//║ Используемые файлы и внешние устройства:
//╚═══════
//

FUNCTION sSAY10()
RETURN sSay09()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY24()
//║ Документ: Индивид. наряд помощника тракториста.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                SSAY03
//║ Используемые файлы и внешние устройства:
//╚═══════
//

FUNCTION sSAY24()
RETURN ssay03()

//
//╔══════════════════════════════════════════════════════════
//║ Функция: sSAY30()
//║ Документ: Путевой лист грузового автомобиля(с прицепом)
//║ Используемые внешние переменные:
//║              AB
//║              VVOD_CLR
//║              HL_CLR
//║              M_BRGD
//║              M_TABN
//║              M_GNAVT
//║              M_TOPL
//║              M_ALL
//║              M_RASHOD
//║              M_PR
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//

FUNCTION sSAY30()

   //  Вывод шапки документа
DISPBEGIN()
   SETCOLOR(IF(!ab:autolite,hl_clr,"w+/B"))
   @ 1,10 SAY fz1->npch picture '999'
   @ 1,38 SAY fz1->ndoc picture '99999'
   @ 1,64 SAY fz1->ddoc
   @ 2,10 SAY m_brgd[1] PICTURE "99"
   @ 2,13 SAY m_brgd[2] COLOR "GR+/B"
   @ 2,44 SAY m_tabn[1]
   @ 2,52 SAY m_tabn[2] COLOR "GR+/B"
   @ 4,20 SAY m_gnavt
   @ 5,20 SAY m_pr[1]
   @ 6,20 SAY m_pr[2]
   @ 7,20 SAY m_pr[3]


   @ 5,25 SAY m_topl[1,1]  COLOR "GR+/B"
   @ 5,46 SAY m_topl[1,2]
   @ 5,50 SAY m_topl[1,3]   PICTURE "9999"

//   @ 6,25 SAY m_topl[2,1]  COLOR "GR+/B"
   @ 6,46 SAY IF(!EMPTY(m_topl[2,2]),m_topl[2,2],"")
   @ 6,50 SAY IF(!EMPTY(m_topl[2,3]),TRANSFORM(m_topl[2,3],"9999"),"")

//   @ 7,25 SAY m_topl[3,1]  COLOR "GR+/B"
   @ 7,46 SAY IF(!EMPTY(m_topl[3,2]),m_topl[3,2],"")
   @ 6,50 SAY IF(!EMPTY(m_topl[3,3]),TRANSFORM(m_topl[3,3],"9999"),"")

   @ 7,58 SAY m_rashod[1]   PICTURE "9999"
   @ 7,65 SAY m_rashod[2]   PICTURE "9999"

   @ 18,01  SAY m_all[1] PICTURE "999"  // vnvs
   @ 18,05  SAY m_all[2] PICTURE "999"  // vndv
   @ 18,10  SAY m_all[3] PICTURE "999"  // prvs
   @ 18,16  SAY m_all[4] PICTURE "999"  // prpr
   @ 18,24  SAY m_all[5] PICTURE "999"     // prsn
   @ 18,30  SAY m_all[6] PICTURE "999"     // prtn
   @ 18,36  SAY m_all[7] PICTURE "999"     // kolez

   @ 12,53  SAY m_all[11] PICTURE "99999"  // pgob
   @ 13,53  SAY m_pr[4] PICTURE "99999"    // pgob1
   @ 14,53  SAY m_pr[5] PICTURE "99999"    // pgob2
   @ 15,53  SAY m_pr[6] PICTURE "99999"    // pgob3
   @ 18,53  SAY m_all[8] PICTURE "99999"   // pggr
   @ 10,73  SAY m_all[9] PICTURE "999.99"  // ptav
   @ 11,73  SAY m_pr[7]  PICTURE "999.99"  // ptpr
   @ 14,71  SAY m_all[12] PICTURE "999999.9" // vtkav
   @ 15,71  SAY m_pr[8] PICTURE "999999.9"   // vtkpr
   @ 18,66  SAY m_all[10] PICTURE "99.9"
DISPEND()
RETURN NIL


//
//╔══════════════════════════════════════════════════════════
//║ Группа функций SENTER** - служебные функции для редактирования
//║                           шапки конкретных документов
//║
//║ К ним относятся функции :
//║                       SENTER01
//║                       SENTER02
//║                       SENTER03
//║                       SENTER04
//║                       SENTER05
//║                       SENTER06
//║                       SENTER07
//║                       SENTER08
//║                       SENTER09
//║                       SENTER10
//║                       SENTER24
//║                       SENTER30
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║
//║ Назначение: Редактирование шапки конкретноых документов
//║ Возвращают: NIL
//║ Параметры:  Нет.
//║ Примечания: Особенности каждой функции описаны ниже
//╚═══════
//


//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER01()
//║ Документ: Универсальный реестр по зарплате.
//║ Используемые внешние переменные:
//║              "GR+/B"
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//╚═══════
//
FUNCTION senter01()
LOCAL a1 := fz1->npch
LOCAL a2 := fz1->ndoc
LOCAL a3 := fz1->ddoc
LOCAL s := SET(_SET_ESCAPE,.t.)

@ 3,42 GET a1 VALID !EMPTY(a1) COLOR VVOD_CLR
@ 5,46 GET a2 VALID !EMPTY(a2) COLOR VVOD_CLR
@ 5,2  GET a3 VALID !EMPTY(a3) COLOR VVOD_CLR
// SETCURSOR(SC_NORMAL)
READ
SET(_SET_ESCAPE,s)
// SETCURSOR(SC_NONE)
IF LASTKEY() # K_ESC
   fz1->npch:=a1
   fz1->ndoc:=a2
   fz1->ddoc:=a3
END
RETURN NIL



//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER02 ()
//║ Документ: Бpигадный наpяд.
//║ Используемые внешние переменные:
//║              VVOD_CLR
//║              M_BRGD
//║              M_KSASH
//║              M_VRAB
//║              A_RECNO
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//║              FZ2.DBF
//║              SP01.DBF
//║              sp44.DBF
//║              SP06.DBF
//╚═══════
//
FUNCTION senter02()
LOCAL a1 := fz1->npch
LOCAL a2 := fz1->ndoc
LOCAL a3 := fz1->ddoc,m_tr
LOCAL a4 := m_brgd [1]
LOCAL a5 := m_ksash[1]
LOCAL a6 := m_vrab [1]

LOCAL s := SET(_SET_ESCAPE,.t.)
@ 3,44 GET a1 VALID !EMPTY(a1) COLOR VVOD_CLR
@ 5,46 GET a2 VALID !EMPTY(a2) COLOR VVOD_CLR
@ 5,2  GET a3 VALID !EMPTY(a3) COLOR VVOD_CLR
@ 7,16 GET m_brgd[1] PICTURE 'XX' ;
       VALID ( EVAL({||m_tr:=sp01->(sp_vl("SP01","2",7,23,"sp01->naim1","GR+/B")),;
                    IF(m_tr,m_brgd[2]:=sp01->naim1,""),m_tr}))
@ 8,16 GET m_ksash[1]  PICTURE 'XXXXXXX' ;
       VALID  ( EVAL({||m_tr:=sp44->(sp_vl('SP44',,8,23,'sp44->naim7',"GR+/B")),;
                      IF(m_tr,m_ksash[2]:=sp44->naim7,""),m_tr}))
@ 9,16 GET m_vrab[1] PICTURE '999' ;
       VALID  ( EVAL({||m_tr:=sp06->(sp_vl("SP06","2",9,23,"sp06->naim6","GR+/B")),;
              IF(m_tr,m_vrab[2]:=sp06->naim6,""),m_tr}))
// SETCURSOR(SC_NORMAL)
READ
SET(_SET_ESCAPE,s)
// SETCURSOR(SC_NONE)
IF UPDATED()
   fz1->npch:=a1
   fz1->ndoc:=a2
   fz1->ddoc:=a3
       AEVAL(a_recno,{|p|IF(p[2]#NIL,EVAL({|p1|fz2->(DBGOTO(p1[2])),;
                                       fz2->brgd := m_brgd [1],;
                                       fz2->ksash:=m_ksash[1],;
                                       fz2->vrab :=m_vrab [1]},p),NIL)})
END
RETURN NIL


//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER03 ()
//║ Документ: Индивидуальный наpяд.
//║ Используемые внешние переменные:
//║              VVOD_CLR
//║              M_TABN
//║              A_RECNO
//║ Используемые процедуры и функции:
//║              _FIOFULL
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//║              FZ2.DBF
//║              SP10.DBF
//╚═══════
//
FUNCTION senter03()
LOCAL a1 := fz1->npch
LOCAL a2 := fz1->ndoc
LOCAL a3 := fz1->ddoc,m_tr
LOCAL a4 := m_tabn [1]

LOCAL s := SET(_SET_ESCAPE,.t.)
@ 3,44 GET a1 VALID !EMPTY(a1) COLOR VVOD_CLR
@ 5,46 GET a2 VALID !EMPTY(a2) COLOR VVOD_CLR
@ 5,2  GET a3 VALID !EMPTY(a3) COLOR VVOD_CLR
@ 8,10 GET m_tabn[1] PICTURE '9999' ;
       VALID  ( EVAL({||m_tr:=sp10->(sp_vl("SP10",,8,25,"_fiofull()","GR+/B")),;
              IF(m_tr,m_tabn[2]:=_fiofull(),""),m_tr}))

// SETCURSOR(SC_NORMAL)
READ
SET(_SET_ESCAPE,s)
// SETCURSOR(SC_NONE)
IF LASTKEY() # K_ESC
   fz1->npch:=a1
   fz1->ndoc:=a2
   fz1->ddoc:=a3
   IF  a4 != m_tabn [1]
       AEVAL(a_recno,{|p|IF(p[1]#NIL,EVAL({|p1|fz2->(DBGOTO(p1[1])),;
                                      fz2->tabn := m_tabn [1]},p),NIL)})
   END
END
RETURN NIL


//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER04()
//║ Документ: Табель учета рабочего времени.
//║ Используемые внешние переменные:
//║              VVOD_CLR
//║              M_BRGD
//║              A_RECNO
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//║              FZ2.DBF
//║              SP01.DBF
//╚═══════
//
FUNCTION senter04()
LOCAL a1 := fz1->npch
LOCAL a2 := fz1->ndoc
LOCAL a3 := fz1->ddoc
LOCAL a4 := m_brgd [1],m_tr

LOCAL s := SET(_SET_ESCAPE,.t.)
@ 3,68 GET a1 VALID !EMPTY(a1) COLOR VVOD_CLR
@ 5,72 GET a2 VALID !EMPTY(a2) COLOR VVOD_CLR
@ 5,2  GET a3 VALID !EMPTY(a3) COLOR VVOD_CLR

@ 5,35 GET m_brgd[1] PICTURE 'XX' ;
       VALID  ( EVAL({||m_tr:=sp01->(sp_vl("SP01","2",5,38,"sp01->naim1","GR+/B")),;
              IF(m_tr,m_brgd[2]:=sp01->naim1,""),m_tr}))

// SETCURSOR(SC_NORMAL)
READ
SET(_SET_ESCAPE,s)
// SETCURSOR(SC_NONE)
IF LASTKEY() # K_ESC
   fz1->npch:=a1
   fz1->ndoc:=a2
   fz1->ddoc:=a3
   IF  a4 != m_brgd [1]
       AEVAL(a_recno,{|p|IF(p[1]#NIL,EVAL({|p1|fz2->(DBGOTO(p1[1])),;
                                      fz2->brgd := m_brgd [1]},p),NIL)})
   END
END
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER05()
//║ Документ: Оплата отпускных.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                SENTER01
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION senter05()
RETURN senter01()


//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER06()
//║ Документ: Оплата больничных.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                SENTER01
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION senter06()
RETURN senter01()


//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER07()
//║ Документ: Учетный лист такториста-машиниста.
//║ Используемые внешние переменные:
//║              VVOD_CLR
//║              M_BRGD
//║              M_TABN
//║              M_NTR
//║              P_VALUE
//║              P_FZ2T
//║ Используемые процедуры и функции:
//║              _FIO
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//║              FZ1T.DBF
//║              FZ2.DBF
//║              FZ2B.DBF
//║              SP01.DBF
//║              SP10.DBF
//║              INV_T.DBF
//║              SP13B.DBF
//╚═══════
//
FUNCTION senter07()

LOCAL i,m_tr
LOCAL s := SET(_SET_ESCAPE,.t.)
LOCAL j := 0
@ 3,41 GET fz1->npch VALID !EMPTY(fz1->npch) COLOR VVOD_CLR
@ 6,39 GET fz1->ndoc VALID !EMPTY(fz1->ndoc) COLOR VVOD_CLR
@ 4,4  GET fz1->ddoc VALID !EMPTY(fz1->ddoc) COLOR VVOD_CLR
#ifdef _L_BRGD
    @ 6,9 GET m_brgd [1]  PICTURE '99' ;
          VALID ( EVAL({||m_tr:=sp01->(sp_vl("SP01","2",6,12,"sp01->naim1","GR+/B")),;
              IF(m_tr,m_brgd[2]:=sp01->naim1,""),m_tr}))

#endif

   @ 4,74 GET m_tabn[1] PICTURE "9999" ;
                 VALID  ( EVAL({||m_tr:=sp10->(sp_vl("SP10",,4,46,"_fio()","GR+/B")),;
              IF(m_tr,m_tabn[2]:=_fiofull(),""),m_tr}))

   @ 6,73 GET m_ntr[1] PICTURE '@K 99999' ;
                 VALID  EVAL({||m_ntr[1]:=PADL(ALLTRIM(m_ntr[1]),5),;
                      inv_t->(sp_vl('INV_T',,6,46,'sp13b->naim13b',"GR+/B"))})
   @ 9,2  GET m_ntr[3] PICTURE "9999.9"
   @ 9,12 GET m_ntr[4] PICTURE "9999.9" VALID EVAL({||SETPOS(9,21),;
                      DISPOUT(TRANSFORM(m_ntr[3]+;
                        m_ntr[4]-;
                        EVAL({||AEVAL(p_value,;
                                      {|a|IF(a[1]#NIL,;
                                          j+=a[p_fz2t[LEN(p_fz2t)-1]],;
                                          NIL)}),;
                                          j}),;
                "99999")),.t.})
   @ 8,56 GET m_ntr[5] PICTURE "99.9"
   @ 9,56 GET m_ntr[6] PICTURE "99.9"

// SETCURSOR(SC_NORMAL)
READ
SET(_SET_ESCAPE,s)
// SETCURSOR(SC_NONE)
IF LASTKEY() # K_ESC
   #ifdef _L_BRGD
       fz2b->brgd := m_brgd[1]
   #endif
   i := 0
   AEVAL(a_recno,{|p|i++,IF(p[1]#NIL,EVAL({|p1|s:=i,;
                                                  fz2->(DBGOTO(p1[1])),;
                                fz2->otdn := 0,fz2->tabn:=m_tabn[1]},;
                                                               p),NIL)})
   fz2->(DBGOTO(a_recno[s,1]))
   fz2->otdn := m_ntr[5]
   fz1t->otms := m_ntr[6]
   fz1t->otmd := m_ntr[5]
   fz1t->ntr :=m_ntr[1]
   fz1t->ostnm := m_ntr[3]
   fz1t->zapr := m_ntr[4]
END
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER08()
//║ Документ: Путевой лист тактора.
//║ Используемые внешние переменные:
//║              VVOD_CLR
//║              M_BRGD
//║              M_TABN
//║              M_NTR
//║              A_RECNO
//║ Используемые процедуры и функции:
//║              _FIO
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//║              FZ1T.DBF
//║              FZ2.DBF
//║              FZ2B.DBF
//║              SP01.DBF
//║              SP10.DBF
//║              INV_T.DBF
//║              SP13B.DBF
//╚═══════
//
FUNCTION senter08()

LOCAL i,m_tr
LOCAL s := SET(_SET_ESCAPE,.t.)
LOCAL j := 0
@ 3,45 GET fz1->npch VALID !EMPTY(fz1->npch) COLOR VVOD_CLR
@ 5,44 GET fz1->ndoc VALID !EMPTY(fz1->ndoc) COLOR VVOD_CLR
@ 5,4  GET fz1->ddoc VALID !EMPTY(fz1->ddoc) COLOR VVOD_CLR

#ifdef _L_BRGD
    @ 9,51 GET m_brgd [1]  PICTURE '99' ;
          VALID ( EVAL({||m_tr:=sp01->(sp_vl("SP01",,9,54,"sp01->naim1","GR+/B")),;
              IF(m_tr,m_brgd[2]:=sp01->naim1,""),m_tr}))
#endif
   @ 7,9 GET m_tabn[1] PICTURE "9999" ;
                 VALID  ( EVAL({||m_tr:=sp10->(sp_vl("SP10",,7,14,"_fio()","GR+/B")),;
                        IF(m_tr,m_tabn[2]:=_fiofull(),""),m_tr}))
   @ 7,53 GET m_ntr[1] PICTURE '@K 99999' ;
                    VALID  EVAL({||m_ntr[1]:=PADL(ALLTRIM(m_ntr[1]),5),;
                      inv_t->(sp_vl('INV_T',,7,59,'sp13b->naim13b',"GR+/B"))})
   @ 5,52  GET m_ntr[3] PICTURE "9999.9"
   @ 5,61 GET m_ntr[4] PICTURE "9999.9" VALID EVAL({||SETPOS(5,72),;
                      DISPOUT(TRANSFORM(m_ntr[3]+;
                        m_ntr[4]-;
                        EVAL({||AEVAL(p_value,;
                              {|a|IF(a[1]#NIL,j+=a[p_fz2t[LEN(p_fz2t)-;
                                        1]],NIL)}),;
                                           j}),;
                "99999")),.t.})
   @ 9,30 GET m_ntr[5] PICTURE "99.9"
   @ 10,30 GET m_ntr[6] PICTURE "99.9"

// SETCURSOR(SC_NORMAL)
READ
 SET(_SET_ESCAPE,s)
// SETCURSOR(SC_NONE)
IF LASTKEY() # K_ESC
   i := 0
   AEVAL(a_recno,{|p|i++,IF(p[1]#NIL,EVAL({|p1|s:=i,;
                                                  fz2->(DBGOTO(p1[1])),;
                          fz2->otdn := 0,fz2->tabn:=m_tabn[1]},p),NIL)})
   fz2->(DBGOTO(a_recno[s,1]))
   fz2->otdn := m_ntr[5]
   fz1t->(REPLACERecord({,m_ntr[1],m_ntr[4],m_ntr[3],m_ntr[5],;
                                                             m_ntr[6]}))
#ifdef _L_BRGD
   fz2b->brgd := m_brgd [1]
#endif
END
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER09()
//║ Документ: Путевой лист грузового автомобиля.
//║ Используемые внешние переменные:
//║              VVOD_CLR
//║              M_BRGD
//║              M_TABN
//║              M_GNAVT
//║              M_TOPL
//║              M_ALL
//║              M_RASHOD
//║ Используемые процедуры и функции:
//║              _FIO
//║              REPLACERECORD
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//║              FZ1AT.DBF
//║              FZ1AE.DBF
//║              FZ2.DBF
//║              SP01.DBF
//║              SP10.DBF
//║              INV_A.DBF
//║              SP13A.DBF
//╚═══════
//
FUNCTION senter09()
LOCAL a1 := fz1->npch
LOCAL a2 := fz1->ndoc
LOCAL a3 := fz1->ddoc,m_tr

LOCAL s := SET(_SET_ESCAPE,.t.)
@ 1,10 GET a1 VALID !EMPTY(a1) COLOR VVOD_CLR
@ 1,38 GET a2 VALID !EMPTY(a2) COLOR VVOD_CLR
@ 1,64  GET a3 VALID !EMPTY(a3) COLOR VVOD_CLR
@ 2,10 GET m_brgd[1] PICTURE '99' ;
       VALID  ( EVAL({||m_tr:=sp01->(sp_vl("SP01","2",2,13,"sp01->naim1","GR+/B")),;
              IF(m_tr,m_brgd[2]:=sp01->naim1,""),m_tr}))

@ 2,44 GET m_tabn[1] PICTURE '9999' ;
       VALID  ( EVAL({||m_tr:=sp10->(sp_vl("SP10",,2,52,"_fio()","GR+/B")),;
              IF(m_tr,m_tabn[2]:=_fiofull(),""),m_tr}))

   @ 4,20 GET m_gnavt VALID inv_a->(sp_vl("INV_A"))

   @ 5,46 GET m_topl[1,2]  ;
       VALID ( EVAL({||m_tr:=sp44->(DBSEEK(GetGsm()+m_topl[1,2])),;
                     m_topl[1,1]:=sp44->naim7,m_tr}))
   @ 5,50 GET m_topl[1,3]  PICTURE "9999"

   @ 7,58 GET m_rashod[1]   PICTURE "9999"
   @ 7,65 GET m_rashod[2]   PICTURE "9999"

   @ 17,01  GET m_all[1] PICTURE "999"
   @ 17,05  GET m_all[2] PICTURE "999"
   @ 17,10  GET m_all[3] PICTURE "999"
   @ 17,15  GET m_all[4] PICTURE "999"
   @ 17,22  GET m_all[5] PICTURE "999"
   @ 17,31  GET m_all[6] PICTURE "999"
   @ 17,37  GET m_all[7] PICTURE "999"
   @ 17,48  GET m_all[8] PICTURE "99999"
   @ 17,55  GET m_all[9] PICTURE "999.99"
   @ 17,71  GET m_all[10] PICTURE "99.9"


// SETCURSOR(SC_NORMAL)
READ
SET(_SET_ESCAPE,s)
// SETCURSOR(SC_NONE)
IF UPDATED()
   fz1->npch:=a1
   fz1->ndoc:=a2
   fz1->ddoc:=a3
   AEVAL(a_recno,{|p|IF(p[1]#NIL,EVAL({|p1|fz2->(DBGOTO(p1[1])),;
                                           fz2->brgd := m_brgd [1],;
                                      fz2->tabn :=m_tabn  [1]},p),NIL)})
   fz1at->(DBGOTO(m_topl[1,4]))
   fz1at->kmtop := m_topl[1,2]
   fz1at->zapr  := m_topl[1,3]


   IF !EMPTY(m_topl[2,1])
   fz1at->(DBGOTO(m_topl[2,4]))
   fz1at->kmtop := m_topl[2,2]
   fz1at->zapr  := m_topl[2,3]
   END

   IF !EMPTY(m_topl[3,1])
   fz1at->(DBGOTO(m_topl[3,4]))
   fz1at->kmtop := m_topl[3,2]
   fz1at->zapr  := m_topl[3,3]
   END
   fz1ae->(ReplaceRecord({,m_gnavt,m_rashod[1],m_rashod[2],m_all[1],;
                          m_all[2],m_all[3],m_all[4],m_all[5],m_all[6],;
                          m_all[7],m_all[8],m_all[9],m_all[10]}))
END

RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER10()
//║ Документ: Путевой лист грузового автомобиля(эксплуатация).
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                SENTER09
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION senter10()
RETURN sEnter09()


//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER24()
//║ Документ: Индивид. наряд помощника тракториста.
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║                SENTER03
//║ Используемые файлы и внешние устройства:
//╚═══════
//
FUNCTION senter24()
RETURN senter03()


//
//╔══════════════════════════════════════════════════════════
//║ Функция: SENTER30()
//║ Документ: Путевой лист грузового автомобиля(с прицепом)
//║ Используемые внешние переменные:
//║              VVOD_CLR
//║              M_BRGD
//║              M_TABN
//║              M_GNAVT
//║              M_TOPL
//║              M_ALL
//║              M_RASHOD
//║              M_PR
//║ Используемые процедуры и функции:
//║              _FIO
//║              REPLACERECORD
//║ Используемые файлы и внешние устройства:
//║              FZ1.DBF
//║              FZ1AP.DBF
//║              FZ1AT.DBF
//║              FZ1AE.DBF
//║              FZ2.DBF
//║              FZ2A.DBF
//║              SP01.DBF
//║              SP10.DBF
//║              INV_A.DBF
//║              SP13A.DBF
//╚═══════
//
FUNCTION senter30()
LOCAL a1 := fz1->npch
LOCAL a2 := fz1->ndoc
LOCAL a3 := fz1->ddoc,m_tr

LOCAL s := SET(_SET_ESCAPE,.t.)
@ 1,10 GET a1 VALID !EMPTY(a1) COLOR VVOD_CLR
@ 1,38 GET a2 VALID !EMPTY(a2) COLOR VVOD_CLR
@ 1,64 GET a3 VALID !EMPTY(a3) COLOR VVOD_CLR
@ 2,10 GET m_brgd[1] PICTURE '99' ;
       VALID  ( EVAL({||m_tr:=sp01->(sp_vl("SP01","2",2,13,"sp01->naim1","GR+/B")),;
              IF(m_tr,m_brgd[2]:=sp01->naim1,""),m_tr}))
@ 2,44 GET m_tabn[1] PICTURE '9999' ;
       VALID  ( EVAL({||m_tr:=sp10->(sp_vl("SP10",,2,52,"_fio()","GR+/B")),;
              IF(m_tr,m_tabn[2]:=_fiofull(),""),m_tr}))
@ 4,20 GET m_gnavt VALID inv_a->(sp_vl("INV_A"))
@ 5,20 GET m_pr[1] VALID inv_a->(sp_vl("INV_A"))
@ 6,20 GET m_pr[2] VALID inv_a->(sp_vl("INV_A","2"))
@ 7,20 GET m_pr[3] VALID inv_a->(sp_vl("INV_A","2"))

   @ 5,46 GET m_topl[1,2]  ;
       VALID ( EVAL({||m_tr:=sp44->(DBSEEK(GetGsm()+m_topl[1,2])),;
                     m_topl[1,1]:=sp44->naim7,m_tr}))
   @ 5,50 GET m_topl[1,3]  PICTURE "9999"


   @ 7,58 GET m_rashod[1]   PICTURE "9999"
   @ 7,65 GET m_rashod[2]   PICTURE "9999"

   @ 18,01  GET m_all[1] PICTURE "999"
   @ 18,05  GET m_all[2] PICTURE "999"
   @ 18,10  GET m_all[3] PICTURE "999"
   @ 18,16  GET m_all[4] PICTURE "999"
   @ 18,24  GET m_all[5] PICTURE "999"
   @ 18,30  GET m_all[6] PICTURE "999"
   @ 18,36  GET m_all[7] PICTURE "999"

   @ 12,53  GET m_all[11] PICTURE "99999"  // pgob
   @ 13,53  GET m_pr[4] PICTURE "99999"    // pgob1
   @ 14,53  GET m_pr[5] PICTURE "99999"    // pgob2
   @ 15,53  GET m_pr[6] PICTURE "99999"    // pgob3
   @ 18,53  GET m_all[8] PICTURE "99999"   // pggr

   @ 10,73  GET m_all[9] PICTURE "999.99"  // ptav
   @ 11,73  GET m_pr[7]  PICTURE "999.99"  // ptpr


   @ 14,71  GET m_all[12] PICTURE "999999.9" // vtkav
   @ 15,71  GET m_pr[8] PICTURE "999999.9"   // vtkpr

   @ 18,66  GET m_all[10] PICTURE "99.9"


// SETCURSOR(SC_NORMAL)
READ
SET(_SET_ESCAPE,s)
// SETCURSOR(SC_NONE)
IF UPDATED()
   fz1->npch:=a1 ; fz1->ndoc:=a2 ; fz1->ddoc:=a3
   AEVAL(a_recno,{|p|IF(p[1]#NIL,EVAL({|p1|fz2->(DBGOTO(p1[1])),;
                                           fz2->brgd := m_brgd [1],;
                                      fz2->tabn :=m_tabn  [1]},p),NIL)})
   fz1at->(DBGOTO(m_topl[1,4]))
   fz1at->kmtop := m_topl[1,2] ; fz1at->zapr  := m_topl[1,3]


   IF !EMPTY(m_topl[2,1])
   fz1at->(DBGOTO(m_topl[2,4]))
   fz1at->kmtop := m_topl[2,2] ; fz1at->zapr  := m_topl[2,3]
   END

   IF !EMPTY(m_topl[3,1])
   fz1at->(DBGOTO(m_topl[3,4]))
   fz1at->kmtop := m_topl[3,2]
   fz1at->zapr  := m_topl[3,3]
   END
   fz1ae->(ReplaceRecord({,m_gnavt,m_rashod[1],m_rashod[2],m_all[1],;
                          m_all[2],m_all[3],m_all[4],m_all[5],m_all[6],;
                           m_all[7],m_all[8],m_all[9],m_all[10]}))

   fz2a ->pgob  :=  m_all[11]  ; fz2a ->vtkav :=  m_all[12]

   fz1ap->(ReplaceRecord({,m_pr[1], m_pr[2], m_pr[3],m_pr[4],;
                           m_pr[5],m_pr[6],;
                           m_pr[7],m_pr[8],m_all[10]}))
END
RETURN NIL


//
//╔══════════════════════════════════════════════════════════
//║ Группа процедур S_KR*** - процедуры корректировки конкретных
//║                           документов
//║ К ним относятся процедуры :
//║                       S_KR001
//║                       S_KR032
//║                       S_KR031
//║                       S_KR030
//║                       S_KR020
//║                       S_KR021
//║                       S_KR021
//║                       S_KR037
//║                       S_KR039
//║                       S_KR038
//║                       S_KR029
//║                       S_KR040
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║
//║ Назначение: Редактирование конкретноых документов
//║ Параметры:  <m_reg> - pежим pаботы ("пpосмотp","испpавление").
//║ Примечания: Особенности каждой процедуры описаны ниже
//╚═══════
//

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr001
//║ Документ: Универсальный реестр по зарплате.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr001
   PARAMETERS m_reg
   PRIVATE p_fz2 := {1,2,3,4,5,6,7,8}
   PRIVATE p_fz3 := {9,10}
   p_help_code := 101
   ABROWSE(7,1,22,78,"01")
RETURN


//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr032
//║ Документ: Бpигадный наpяд.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr032
   PARAMETERS m_reg
   p_help_code := 102
   PRIVATE p_fz2 := {1,2,3,4}
   PRIVATE p_fz3 := {5,6}
   PRIVATE m_ksash
   PRIVATE m_vrab
   PRIVATE m_brgd

   ABROWSE(11,1,24,78,"02")
RETURN


//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr031
//║ Документ: Индивидуальный наpяд.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr031
   PARAMETERS m_reg
   p_help_code := 103
   PRIVATE p_fz2 := {1,2,3,4,5,6,7}
   PRIVATE p_fz3 := {8,9}
   PRIVATE m_tabn
   PRIVATE m_vrab
   PRIVATE m_brgd

   ABROWSE(10,1,22,78,"03")
RETURN

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr030
//║ Документ: Табель учета рабочего времени.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr030
   PARAMETERS m_reg
   p_help_code := 106
   PRIVATE p_fz2 := {1,2,3,4,5,6}
   PRIVATE p_fz3 := {7,8}
   PRIVATE m_brgd

   ABROWSE(7,1,22,78,"04")
RETURN



//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr020
//║ Документ: Оплата отпускных.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr020
   PARAMETERS m_reg
   p_help_code := 104
   PRIVATE p_fz2 := {1,2,3,4,5,6}
   PRIVATE p_fz3 := {7,8}
   ABROWSE(7,1,22,78,"05")
RETURN

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr021
//║ Документ: Оплата больничных.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr021
   PARAMETERS m_reg
   p_help_code := 105
   PRIVATE p_fz2 := {1,2,3,4,5,6}
   PRIVATE p_fz3 := {7,8}
   ABROWSE(7,1,22,78,"06")
RETURN



//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr036
//║ Документ: Учетный лист такториста-машиниста.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr036
   PARAMETERS m_reg
   p_help_code := 107
   PRIVATE p_fz2 := {1,2,3,7}
   PRIVATE p_fz2t := {4,5,6,8,9,10}
   PRIVATE p_fz3 := {11,12}
   PRIVATE m_brgd,m_tabn,m_ntr

   ABROWSE(11,1,24,78,"07")
RETURN

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr037
//║ Документ: Путевой лист тактора.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr037
   PARAMETERS m_reg
   p_help_code := 108
   PRIVATE p_fz2 := {1,2,3,4}
   PRIVATE p_fz2t := {5,8,12,13}
   PRIVATE p_fz2tp := {6,7,9,10,11}
//   PRIVATE p_fz3 := {14,15}
   PRIVATE p_fz3 := {13,14}
   PRIVATE m_tabn,m_ntr,m_brgd

   ABROWSE(12,1,24,78,"08")
RETURN

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr039
//║ Документ: Путевой лист грузового автомобиля.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║              S_KR038_040
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr039
   PARAMETERS m_reg

   p_help_code := 109
   PRIVATE m_brgd
   PRIVATE p_fz2 := {1,2,5,6}
   PRIVATE p_fz2a:= {3,4}
   PRIVATE p_fz3 := {7,8}
   PRIVATE m_gnavt
   PRIVATE m_tabn
   PRIVATE m_topl ,m_rashod
   PRIVATE m_all
   s_kr038_040()
   ABROWSE(19,1,24,78,"09")
   s_kr038_040(.f.)
RETURN

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr038
//║ Документ: Путевой лист грузового автомобиля(эксплуатация).
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║              S_KR038_040
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr038
   PARAMETERS m_reg
   PRIVATE m_brgd
   PRIVATE p_fz2 := {1,2,5,6}
   PRIVATE p_fz2a:= {3,4}
   PRIVATE p_fz3 := {7,8}
   PRIVATE m_gnavt
   PRIVATE m_tabn
   PRIVATE m_topl ,m_rashod
   PRIVATE m_all
   p_help_code := 109
   s_kr038_040()
   ABROWSE(19,1,24,78,"10")
   s_kr038_040(.f.)
RETURN


//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr029
//║ Документ: Индивид. наряд помощника тракториста.
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr029
   PARAMETERS m_reg
   p_help_code := 112
   PRIVATE p_fz2 := {1,2,3,4,5,6,7}
   PRIVATE p_fz3 := {8,9}
   PRIVATE m_tabn
   PRIVATE m_vrab
   PRIVATE m_brgd
   ABROWSE(10,1,22,78,"24")
RETURN



//
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_kr040
//║ Документ: Путевой лист грузового автомобиля(с прицепом)
//║ Используемые внешние переменные:
//║              P_HELP_CODE
//║ Используемые процедуры и функции:
//║              ABROWSE
//║              S_KR038_040
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

PROCEDURE s_kr040
   PARAMETERS m_reg
   PRIVATE m_brgd
   PRIVATE p_fz2 := {1,2,3,4}
   PRIVATE p_fz3 := {5,6}
   PRIVATE m_gnavt
   PRIVATE m_tabn
   PRIVATE m_topl ,m_rashod
   PRIVATE m_all
   PRIVATE m_pr
   p_help_code := 109
   s_kr038_040()
   ABROWSE(20,1,24,78,"30")
   s_kr038_040(.f.)
RETURN

//
//╔══════════════════════════════════════════════════════════
//║ Функция: s_kr038_040([<lcreate>]) --> NIL
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 04-10-91.
//║ Назначение:  Создание справочника марок топлива.
//║ Возвращает:  NIL
//║ Параметры: [< lCreate >] - Создать/удалить файл(по умолчанию .T.)
//║ Используемые внешние переменные:
//║              M_SPRPATH
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║                sp44.DBF
//║                sp44.NTX
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

STATIC FUNCTION s_kr038_040(lCreate)
DEFAULT .T. TO lCreate
IF lCreate
END
RETURN NIL

STATIC PROCEDURE _printPArr()
Local i,j
@10,0 SAY ""
FOR i=1 to LEN(p_value)
@ROW()+1,0 SAY ""
FOR j=1 to LEN(p_value[i])
  @ROW(),COL()+1 SAY p_value[i,j] COLOR "G+/N"
  IF COL()>60
     @ROW()+1,0 SAY "" COLOR "G+/N"
  END
NEXT
NEXT
inkey(0)
RETURN



