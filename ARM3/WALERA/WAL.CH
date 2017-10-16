//
//╔══════════════════════════════════════════════════════════
//║ Модуль: WAL.CH
//║ Автор: Шнайдеp В. О.
//║ Дата создания: 15-10-91.
//║ Примечания:  Файл заголовка
//╚═══════
//

#include "set.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "box.ch"
#include "dbstruct.ch"
#include "dbedit.ch"
#include "fileio.ch"
#include "memoedit.ch"



// Определение параметров по умолчанию.
// Пример:
//       DEFAULT .T. TO lOpen, ;
//                1  TO nPos , ;
//               "A" TO cString
#command DEFAULT <var2> TO <var1> [,<varN> TO <varM>] =>  ;
                                  <var1> := if(<var1> == NIL,<var2>,<var1>) ;
                                  [;<varM> := if(<varM> == NIL,<varN>,<varM>)]

// Команда вставки записи в текущей области
#command INSERT [WITHOUT <p: PROCESS>] =>    Insert([!<.p.>])

// Звуковой сигнал
#define NO_DOSTUP   TONE(1000,1)

// Коды классности для трактористов
#define M_KLASSTR "018,019"

// Коды классности для животноводов
#define M_KLASSGV "016,017"

// Коды классности для водителей
#define M_KLASSAV "020,021"

// Коды , по которым начисляется классность
#define M_KOPUTR  "001,002,008,052,053"

#define NOTDOC  'Документ не подключен к системе'

// Используются функцией WDF_TABLE и SAYWDF
#define ONE_TIME      2048
#define LEN_KEY       4
#define LEN_MARKER    7


#define L_TIME
//#define _L_BRGD

// .T. - расчет классности водителей авт-дням , иначе по времени в наряде
#define L_AVDN  .T.
#ifdef NEW_VER
#translate InitClock ( <var1> , <var2> , <var3>, <var4> , <var5> ) => SHOWTIME(<var3>,<var4>,.F.,"B/W")
#translate DelClock ( ) => SHOWTIME()
#endif
#command NET USE <(db)> [ALIAS <a>] [<new: NEW>] [<ro: READONLY>] [INDEX <(index1)> [, <(indexn)>]]  ;
                                                                        ;
      => dbUseArea(<.new.>,, <(db)>, <(a)>,.t., <.ro.>)                 ;
                                                                        ;
      [; dbSetIndex( <(index1)> )]                                      ;
      [; dbSetIndex( <(indexn)> )]

#translate  ANSWERu(<m_var>) => ALERT(<m_var>,{"Да","Нi"},"N/BG,w/b")
#DEFINE  YES 1
#translate DispError(<var>) =>   WaitMessage(<var>,"GR+/R,w+/R",.t.)

#define Wait_Mig() DispMessage("Ждите ...")
