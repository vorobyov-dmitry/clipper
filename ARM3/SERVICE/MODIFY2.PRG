#include "new.ch"
FUNCTION modify2(var1)
LOCAL m_path,m_date
LOCAL s1:=LOWER(EXENAME())
IF var1==NIL
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_path:=s1

ELSE
m_path:=alltrim(var1)
ENDIF
IF (FILE(m_path+"BH\raschet.exe"))
  m_date := FileDate(m_path+"BH\raschet.exe")
  IF m_date<>CTOD("02/02/08")
     DispError("����  raschet.exe ��  �� �������� !!!; ������� ��� ��易⥫쭮")
  ENDIF
ELSE
  DispError("����  raschet.exe �� ������ � "+m_path+"BH")
  return .t.
ENDIF
SET DELE ON
SET PRINTER TO (m_path+"ms\modify2.txt")
SET PRINTER ON
SET CONSOLE OFF
//Modifyfd1(m_path,"bf")
//Modifyfd1(m_path,"mn")
//ModifySp(m_path)
ModifySystem(m_path)
SET PRINTER TO
SET PRINTER OFF
SET CONSOLE ON

RETURN .t.
FUNCTION ModifySystem(m_path)
LOCAL m_message
m_message=DispMessage("����䨪��� 䠩�� memvar")
USE (m_path+"SYSTEM\memvar") INDEX (m_path+"SYSTEM\memvar") ALIAS mem NEW
REINDEX
DelMessage(m_message)
mdmemvar("ZR","x_pod","N","�।�� ��. �죮�� ","890")
mdmemvar("ZR","p_minimum","N"," �஦�� ������ ","633")
mdmemvar("ZR","x_strah","N"," ������ ��� ��.���� ","633")
mdmemvar("ZR","m_maxpredel","N"," ���孨� �।�� ��������������� ","9495")
Close mem
m_message=DispMessage("����䨪��� 䠩�� struct")
USE (m_path+"SYSTEM\struct") INDEX (m_path+"SYSTEM\struct") ALIAS st NEW
REINDEX
mdstruct("USCH01","TABN","C",4,0)
DelMessage(m_message)
m_message=DispMessage("����䨪��� �ࠢ�筨�� ࠡ�⭨���")
ModifySp(m_path)
DelMessage(m_message)
m_message=DispMessage("��������� ��業⮢ �� ᨭ�. ���� ")
ModifyUch(m_path)
RETURN .t.
STATIC function mdmemvar(m_prg,m_name,m_kod,m_comment,m_value)
LOCAL m_val2
IF (mem->(DS(m_prg+m_name)))
	m_val2:=TRIM(mem->value)
	IF m_val2!=m_value
		IF ANSWERu(" �������� ���祭�� "+m_comment +"; � ��ண� "+m_val2+"; �� �����  " +m_value+"?")==YES
  			mem->value:=m_value
		ENDIF
	ENDIF
ELSE
	IF ANSWERu(" ��������  ���祭�� "+m_comment +";" +m_value+"?")==YES
  		mem->(DBAP())
  		mem->prg:=m_prg
  		mem->name:=m_name
  		mem->kod:=m_kod
  		mem->value:=m_value
  		mem->comment:=m_comment
	ENDIF
ENDIF
RETURN .t.
STATIC function mdstruct(m_prg,m_name,m_kod,m_length,m_dec)
IF (st->(DS(m_prg)))
	DO while ( .NOT.st->(EOF()) .AND.  st->name==m_prg)
		IF (TRIM(st->field_name)==m_name) 
			RETURN .t.
		ENDIF
	st->(DBSKIP())
	ENDDO
ENDIF
	IF ANSWERu(" ��������  ���祭�� "+m_prg +";" +m_name+"?")==YES
  		st->(DBAP())
  		st->name:=m_prg
  		st->field_name:=m_name
  		st->field_type:=m_kod
  		st->Field_len:=m_length
      		st->field_dec:=m_dec
	ENDIF
return .t.
STATIC Function ModifySp(m_path)
IF ANSWERu(" �������� � �ࠢ�筨�� ࠡ�⭨���;  ���祭�� �죮�� 200 �� 257.5 ?")==YES
	USE (m_path+"sp\sp10") NEW 
    	REPLACE sp10->sumpod WITH 257.50   for sp10->sumpod==200
	CLOSE sp10
ENDIF
return .t.
STATIC FUNCTION ModifyUch(m_path)
IF ANSWERu(" �������� � ��業�� ���᫥��� ���ᨮ����� ;  �� 19.92 , 19.92 , 4 ?")==YES
	USE (m_path+"1_2\s_1_2b.dbf ") NEW  ALIAS uch
GO 2
uch->procent1:=19.92
uch->procent2:=19.92
uch->procent3:=4
use
ENDIF
return .t.


