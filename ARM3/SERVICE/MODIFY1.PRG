#include "new.ch"
FUNCTION modify1(var1)
LOCAL m_path:=IF(var1==NIL,"d:\buhgal\",alltrim(var1))
SET DELE ON
SET PRINTER TO (m_path+"ms\modify.txt")
SET PRINTER ON
SET CONSOLE OFF
Modifyfd1(m_path,"bf")
Modifyfd1(m_path,"mn")
ModifySp(m_path)
ModifySystem(m_path)
SET PRINTER TO
SET PRINTER OFF
SET CONSOLE ON

RETURN .t.
FUNCTION Modifyfd1(m_path1,m_path2)
LOCAL a_struct:={},m_message
// ����䨪��� fd1  � ���� � � �᭮���� ���� ������
m_message=DispMessage("����䨪��� 䠩�� Fd1")

USE (m_path1+m_path2+"\fd1") ALIAS fd1 NEW
a_struct:=DBSTRUCT()
DelMessage(m_message)
IF UPPER(a_struct[LEN(a_struct)][1])="PAJ"
m_message=DispMessage("����䨪��� 䠩�� Fd1;㦥 �뫠 �믮�����")
?"����䨪��� 䠩�� Fd1 㦥 �뫠 �믮�����"
ELSE
m_message=DispMessage("����䨪��� 䠩�� Fd1;���������� �⮫�� paj")
?"����䨪��� 䠩�� Fd1 ���������� �⮫�� paj"
Close fd1
FRENAME(m_path1+m_path2+"\fd1.dbf",m_path1+m_path2+"\fd1_1.old")
AADD(a_struct,{"paj","C",1,0})
DBCREATE(m_path1+m_path2+"\fd1.dbf",a_struct)
USE (m_path1+m_path2+"\fd1") ALIAS fd1
APPEND FROM (m_path1+m_path2+"\fd1_1.old")
CLose fd1
DelMessage(m_message)
m_message:=DispMessage("����䨪��� 䠩�� Fd1 �믮�����")
?"����䨪��� 䠩�� Fd1 �믮�����"
ENDIF
DelMessage(m_message)
RETURN .t.
FUNCTION ModifySystem(m_path)
LOCAL m_message
m_message=DispMessage("����䨪��� 䠩�� dbrowse")

USE (m_path+"SYSTEM\dbrowse") INDEX (m_path+"SYSTEM\dbrowse") ALIAS db NEW
IF (db->(DS(PADR("SP10",8)+"27")))
m_message=DispMessage("����䨪��� 䠩�� dbrowse;㦥 �뫠 �믮�����")
?"����䨪��� 䠩�� dbrowse 㦥 �뫠 �믮�����"
ELSE
m_message=DispMessage("����䨪��� 䠩�� dbrowse;���������� ��ப�")
?"����䨪��� 䠩�� dbrowse ���������� ��ப�"
  db->(DBAP())
  db->name:=PADR("SP10",8)
  db->col:="27"
  db->value:="sumpod"
  db->type:="01"
  db->heading:="�죮�"
  db->pict:="9999.99"
  db->print:=.t.
  db->cargo:="12,30,w+/b*"
ENDIF
Close db
DelMessage(m_message)

m_message=DispMessage("����䨪��� 䠩�� memvar")
USE (m_path+"SYSTEM\memvar") INDEX (m_path+"SYSTEM\memvar") ALIAS mem NEW
DelMessage(m_message)
IF (mem->(DS("ZR"+"x_pod")))
	m_message=DispMessage("����䨪��� 䠩�� memvar;㦥 �뫠 �믮�����")
	?"����䨪��� 䠩�� memvar 㦥 �뫠 �믮�����"
ELSE
	m_message=DispMessage("����䨪��� 䠩�� memvar;���������� ��ப�")
	?"����䨪��� 䠩�� memvar ���������� ��ப�"
  mem->(DBAP())
  mem->prg:="ZR"
  mem->name:="x_pod"
  mem->kod:="N"
  mem->value:="510"
  mem->comment:="�।�� ��. �죮�� "
ENDIF
Close mem
DelMessage(m_message)
RETURN .t.
Function ModifySp(m_path)
LOCAL a_struct:={},m_message
  USE (m_path+"sp\sp10") ALIAS sp10 NEW
  a_struct:=DBSTRUCT()
  IF UPPER(a_struct[LEN(a_struct)][1])="SUMPOD"
    m_message=DispMessage("����䨪��� �ࠢ�筨�� Sp10;㦥 �뫠 �믮�����")
    ?"����䨪��� �ࠢ�筨�� Sp10;㦥 �뫠 �믮�����"
  ELSE
    m_message=DispMessage("����䨪��� �ࠢ�筨�� Sp10")
    ?"����䨪��� �ࠢ�筨�� Sp10"
    Close sp10
    FRENAME(m_path+"sp\sp10.dbf",m_path+"sp\sp10_1.old")
    AADD(a_struct,{"sumpod","N",7,2})
    DBCREATE(m_path+"sp\sp10.dbf",a_struct)
    USE (m_path+"sp\sp10")  NEW
    APPEND FROM (m_path+"sp\sp10_1.old")
    REPLACE sp10->sumpod WITH 61.5 for sp10->kpn="1".OR.sp10->kpn="2"
    set INDEX TO (m_path+"sp\sp10")
    REINDEX
    set INDEX TO
    set INDEX TO (m_path+"sp\sp10a")
    REINDEX
    CLose sp10
    ENDIF
    DelMessage(m_message)
RETURN .t.
