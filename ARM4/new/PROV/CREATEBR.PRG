#include "new.ch"
FUNCTION CreateBr(VAR)
LOCAL m_gauge,m_path:=IF(var==NIL,"",var)
LOCAL m_mash:="00",GetList:={},i
  SET DELE ON
USE (m_path+"STRUCT") INDEX (m_path+"STRUCT") NEW
USE (m_path+"DBROWSE") INDEX (m_path+"DBROWSE") NEW
clear
@10,10 get m_mash PICTURE "99"
READ
IF struct->(DS("M"+m_mash+"   "))
  i:=1
  DO WHILE .NOT.struct->(EOF()).AND.struct->name=="M"+m_mash+"   "
   IF RTRIM(struct->field_name)<>"LEVEL".and.;
      RTRIM(struct->field_name)<>"COUNT".AND.;
      RTRIM(struct->field_name)<>"TYPE".AND.;
      RTRIM(struct->field_name)<>"TYPE1"
    dbrowse->(DBAP())
    // Номер машинограммы
    dbrowse->name:="M"+m_mash
    // Номер столбца
    dbrowse->col := strzero(i,2)
    // Значение столбца
    dbrowse->value:=struct->field_name
    DO CASE
      CASE struct->field_type=="C".OR.struct->field_type=="D"
        dbrowse->type:="01"
      CASE struct->field_type=="N"
       IF AT("STM",struct->field_name)<>0 // stm поле
        dbrowse->type:="03"
      ELSE
        dbrowse->type:="04"
        dbrowse->width:=struct->field_dec
      ENDIF
    OTHERWISE
      dbrowse->type:="01"
  ENDCASE
  DO CASE
    CASE AT("NPCH",struct->field_name)<>0
      dbrowse->heading:="Номер;пачки"
    CASE AT("NDOC",struct->field_name)<>0
      dbrowse->heading:="Номер;докум"
    CASE AT("DDOC",struct->field_name)<>0
      dbrowse->heading:="Дата"
    CASE AT("STM",struct->field_name)<>0
      dbrowse->heading:="Сума"
    CASE AT("KVO",struct->field_name)<>0
      dbrowse->heading:="Кiлькiсть"
    CASE AT("GLV",struct->field_name)<>0
      dbrowse->heading:="Голiв"
    CASE AT("BRGD",struct->field_name)<>0
      dbrowse->heading:="Бргд"
    CASE AT("KOPR",struct->field_name)<>0
      dbrowse->heading:="Опер"
    CASE AT("KPLH",struct->field_name)<>0
      dbrowse->heading:="Одерж."
    CASE AT("NAME",struct->field_name)<>0
      dbrowse->heading:="         Назва           "
    CASE AT("COD",struct->field_name)<>0
      dbrowse->heading:="Ан. код "
    CASE AT("MNT",struct->field_name)<>0
      dbrowse->heading:="Перiод"
  ENDCASE
  IF AT("DB",struct->field_name)<>0
      dbrowse->heading:="Дебет;"+ALLTRIM(dbrowse->heading)
  endif
  IF AT("CR",struct->field_name)<>0
      dbrowse->heading:="Кредiт;"+ALLTRIM(dbrowse->heading)
  endif
  IF AT("OUT",struct->field_name)<>0
      dbrowse->heading:="Вихiдна ;"+ALLTRIM(dbrowse->heading)
  endif
  IF AT("IN",struct->field_name)<>0
      dbrowse->heading:="Вхiдна ;"+ALLTRIM(dbrowse->heading)
  endif
  ENDIF
  dbrowse->print:=.t.
    struct->(DBSKIP())
    i++
  ENDDO
ELSE
  DispError("Структура машинограмми не знайдена ")
ENDIF
CLOSE ALL


RETURN .T.
