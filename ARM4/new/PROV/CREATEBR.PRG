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
    // ����� ��設��ࠬ��
    dbrowse->name:="M"+m_mash
    // ����� �⮫��
    dbrowse->col := strzero(i,2)
    // ���祭�� �⮫��
    dbrowse->value:=struct->field_name
    DO CASE
      CASE struct->field_type=="C".OR.struct->field_type=="D"
        dbrowse->type:="01"
      CASE struct->field_type=="N"
       IF AT("STM",struct->field_name)<>0 // stm ����
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
      dbrowse->heading:="�����;��窨"
    CASE AT("NDOC",struct->field_name)<>0
      dbrowse->heading:="�����;����"
    CASE AT("DDOC",struct->field_name)<>0
      dbrowse->heading:="���"
    CASE AT("STM",struct->field_name)<>0
      dbrowse->heading:="�㬠"
    CASE AT("KVO",struct->field_name)<>0
      dbrowse->heading:="�i��i���"
    CASE AT("GLV",struct->field_name)<>0
      dbrowse->heading:="���i�"
    CASE AT("BRGD",struct->field_name)<>0
      dbrowse->heading:="�ࣤ"
    CASE AT("KOPR",struct->field_name)<>0
      dbrowse->heading:="����"
    CASE AT("KPLH",struct->field_name)<>0
      dbrowse->heading:="����."
    CASE AT("NAME",struct->field_name)<>0
      dbrowse->heading:="         �����           "
    CASE AT("COD",struct->field_name)<>0
      dbrowse->heading:="��. ��� "
    CASE AT("MNT",struct->field_name)<>0
      dbrowse->heading:="���i��"
  ENDCASE
  IF AT("DB",struct->field_name)<>0
      dbrowse->heading:="�����;"+ALLTRIM(dbrowse->heading)
  endif
  IF AT("CR",struct->field_name)<>0
      dbrowse->heading:="�।i�;"+ALLTRIM(dbrowse->heading)
  endif
  IF AT("OUT",struct->field_name)<>0
      dbrowse->heading:="���i��� ;"+ALLTRIM(dbrowse->heading)
  endif
  IF AT("IN",struct->field_name)<>0
      dbrowse->heading:="��i��� ;"+ALLTRIM(dbrowse->heading)
  endif
  ENDIF
  dbrowse->print:=.t.
    struct->(DBSKIP())
    i++
  ENDDO
ELSE
  DispError("������� ��設��ࠬ�� �� �������� ")
ENDIF
CLOSE ALL


RETURN .T.
