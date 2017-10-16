#define BELL() ?Chr(7)
//
//╔══════════════════════════════════════════════════════════
//║ Модуль: SLIBRARY.PRG
//║ Автор: Шнайдеp В. О.
//║ Дата создания: 09-10-91.
//║ Содержит: процедуры
//║           функции
//║ Используемые внешние переменные:
//║
//║ Используемые процедуры и функции:
//║
//║ Используемые файлы и внешние устройства:
//║
//║ Побочные эффекты:
//║ Ключи компиляции: /w/n
//║ Примечания:
//╚═══════
//

#include "wal.ch"

MEMVAR getlist

// PUBLIC - определены в Beginit.prg
MEMVAR m_syspath
MEMVAR p_help_code
MEMVAR vvod_clr
MEMVAR p_npr
MEMVAR m_sprpath

// PRIVATE - определена в пограммах ввода
MEMVAR arr1



//
//╔══════════════════════════════════════════════════════════
//║ Процедура: F013_1
//║ Автор: Шнайдер В. О.
//║ Дата разработки: 29/05/91
//║ Параметры:
//║ Назначение: Организация предварительного ввода
//║ Используемые внешние переменные: массив с именем ARR1
//║ ARR1:={{<текст к полю>,<начальное значение>,<длина>,<блок VALID>},...}
//║
//║
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION f013_1()

#define HELPCODE  198

MEMVAR arrlmax
LOCAL oldHelpCode := p_help_code
LOCAL se :=SET(_SET_ESCAPE,.T.)
LOCAL col,row
LOCAL arrtmax := arrlmax := 0,;
        lenarr := LEN(arr1) ,i,lenght
FOR i=1 to  lenarr
  arrtmax:=MAX(arrtmax,LEN(arr1[i,1]))
  arrlmax:=MAX(arrlmax,arr1[i,3])
NEXT
lenght=arrlmax+arrtmax+3            && Длина наибольшей строки экрана
col=INT((80-lenght)/2)
row=INT((25-2*lenarr+1)/2)
SETCOLOR(vvod_clr)
clear
@ 0,0 to 24,79 double
@ 0,5 say p_npr
FOR i=1 TO lenarr
    @ row+(i-1)*2-1,col SAY PADR(arr1[i,1],arrtmax)+ ': '
NEXT

p_help_code := HELPCODE
FOR i=1 TO lenarr
    @ row+(i-1)*2-1,col+arrtmax+2 GET arr1[i,2]  ;
                 PICTURE REPLICATE('9',arr1[i,3]) ;
        VALID EVAL(arr1[i,4])
    READ
    IF LASTKEY()==K_ESC
       EXIT
    END
NEXT
p_help_code := oldHelpCode

SET(_SET_ESCAPE,se)

#undef HELPCODE

RETURN NIL


//
//╔══════════════════════════════════════════════════════════
//║ Процедура: A61
//║ Автор: Шнайдер В. О.
//║ Дата разработки: 29/05/91
//║ Параметры:
//║ Назначение: Корректировка массива предварительно введенных значений
//║ Используемые внешние переменные: ARR1
//║ Используемые процедуры и функции: Window
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION a61()

#define HELPCODE  197

MEMVAR  _1,_2,_3
LOCAL  ss,re:=READEXIT(.t.),se:=SET(_SET_ESCAPE),bAction:=SETKEY(K_F9,NIL)
LOCAL arrtmax:=0 , arrlmax:=0,lenarr:=LEN(arr1),lenght,col,row,co:=SETCOLOR()
LOCAL i := 0
LOCAL getlist := {}
LOCAL oldHelpCode := p_help_code
PRIVATE _1,_2,_3
FOR i=1 to  lenarr
  arrtmax:=MAX(arrtmax,LEN(arr1[i,1]))
  arrlmax:=MAX(arrlmax,arr1[i,3])
NEXT
lenght := arrlmax + arrtmax + 3     && Длина наибольшей строки экрана
col    := INT((80-lenght)/2)-1
row    := INT((25-lenarr+1)/2)-1
ss     := SAVESCREEN(row,col,row+lenarr+2,col+lenght+5)

SETCOLOR('w+/bg,w+/n,,,w+/bg')
@row,col,row+lenarr+1,col+lenght+3 BOX B_DOUBLE + " " COLOR "GR+/BG"
FOR i=1 TO lenarr
    @ row+i,col+2 SAY PADR(arr1[i,1],arrtmax)+ ': '
    @ row+i,col+arrtmax+4 SAY arr1[i,2]  PICTURE  REPLICATE('9',arr1[i,3])
NEXT
SET(_SET_ESCAPE,.T.)
FOR i=1 TO lenarr

_1:='arr1['+str(i)+',2]'
_2:='arr1['+str(i)+',3]'
_3:='arr1['+str(i)+',4]'

@ row+i,col+arrtmax+4 GET &_1 ;
        PICTURE REPLICATE('9',&_2) VALID EVAL(&_3)

NEXT

p_help_code := HELPCODE
READ
p_help_code := oldhelpcode

RESTSCREEN(row,col,row+lenarr+2,col+lenght+5,ss)
SETCOLOR(co)
SET(_SET_ESCAPE,se)
READEXIT(re)
SETKEY(K_F9,bAction)

#undef HELPCODE

RETURN NIL


FUNCTION sdoc(nPosNpch,nColNpch,nPosNdoc,nColNdoc,m_npch,m_ndoc)
   SET(_SET_ESCAPE,.T.)
      IF EMPTY(m_npch)
         @ nPosNpch,nColNpch GET m_npch PICTURE '999'
         READ
         IF EMPTY(m_npch)
            SET(_SET_ESCAPE,.F.)
            RETURN .F.
         END
      END
      @ nPosNpch,nColNpch SAY STRZERO(m_npch,3)
      WHILE .t.
         @ nPosNdoc,nColNdoc GET m_ndoc PICTURE '99999'
         READ
         IF EMPTY( m_ndoc ) .or. LASTKEY( ) == K_ESC
               @ nPosNpch,nColNpch GET m_npch PICTURE '999'
               READ
               IF LASTKEY()==K_ESC  .or. EMPTY(m_npch)
                  SET(_SET_ESCAPE,.F.)
                  RETURN .F.
               END
               LOOP
         ELSE
            EXIT
         END
      END
      SET(_SET_ESCAPE,.F.)
RETURN (m_ndoc#0.and.m_npch#0)

FUNCTION  CopyDbfNtx(f)

USE (m_sprpath+"f") INDEX (m_sprpath+"f")  NEW

RETURN .f.



//
//╔══════════════════════════════════════════════════════════
//║ Функция:  DelDbfNtx
//║ Автор: Шнайдер В. О.
//║ Дата разработки: 17/05/91
//║ Параметры:  имя файла - справочника без расширения
//║ Возвращает:  .T.-если файл существовал на виртуальном
//║              диске
//║ Используемые внешние переменные:
//╚═══════
//

FUNCTION  DelDbfNtx(f)
LOCAL   s

IF VALTYPE(f)=="C"
   s := SELECT(f)
   IF s # 0
    (s)->(DBCLOSEAREA())
  ENDIF
ENDIF
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Функция: Insert()
//║ Автор: Шнайдер В. О.
//║ Дата разработки: 24/06/91
//║ Возвращает: NIL , Вставляет в файл пустую запись после текущей
//║                   и позиционируется на ней
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION Insert(_l)
   MEMVAR astruct
   LOCAL  reccur := IF( RECNO()=LASTREC()+1,LASTREC(),RECNO()),d:=SET(_SET_DELETED,.F.)
   LOCAL  rk,i,m_process,aarray
   LOCAL  lMORE := .t.
   LOCAL  io := INDEXORD()
   LOCAL   sf := DBFILTER()
   DEFAULT .T. TO _l
   rk := (LASTREC()-RECNO() > 100 .and. _l)
   PRIVATE aStruct:=DBSTRUCT()
   SET FILTER TO

   IF(rk,m_process :=InitGauge(" Перемещено записей "),)

   DBGOBOTTOM() ; aarray:=ExpFields() ; DBAPPEND()

   WHILE RECNO() > reccur+1 .and. (lmore := INKEY()#K_ESC)
      FOR i = 1 TO LEN(aarray)-1
         REPLACE &(astruct[i,DBS_NAME]) WITH aarray[i]
      NEXT
      IF(ATAIL(aarray),DBDELETE(),DBRECALL())
      DBSKIP(-2) ; aarray:=ExpFields() ; DBSKIP()
      IF(rk,m_process:=DISpGauge(m_process,(LASTREC()-RECNO())/(LASTREC()-reccur)),NIL)
   END
   IF lMore
   FOR i = 1 TO LEN(aarray)-1
      REPLACE &(astruct[i,DBS_NAME]) WITH ;
        IF(astruct[i,DBS_TYPE]$'CM',Space(astruct[i,DBS_LEN]),IF(astruct[i,DBS_TYPE]='N',0,IF(astruct[i,DBS_TYPE]='D',Ctod(Space(8)),.F.)))
   NEXT
   DBRECALL()
   ELSE
      DBGOTO( reccur)
   END
   SET(_SET_DELETED,d)

   IF !EMPTY(sf)
      SET FILTER TO (sf)
   END
   DBSETORDER(io)
   IF(rk,DelGauge(m_process),NIL)
RETURN lMore

STATIC FUNCTION ExpFields()
MEMVAR astruct
LOCAL  record :={} , f
AEVAL(astruct,{|a|f:=a[DBS_NAME],AADD(record,FIELDGET(FIELDPOS(f)))})
AADD(record,DELETED())
RETURN record

//
//╔══════════════════════════════════════════════════════════
//║ Функция:
//║ Автор: Шнайдер В. О.
//║ Дата разработки: 02/07/91
//║ Параметры:
//║ Возвращает:
//║ Используемые внешние переменные:
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//

FUNCTION ReplaceRecord(a_field_value)
LOCAL   i := 1
LOCAL   f
AEVAL(a_field_value,{|a|IF(TYPE(f:=FIELDNAME(i))==VALTYPE(a),;
       FIELDPUT(FIELDPOS(f),a),NIL),i++};
     )
RETURN NIL


