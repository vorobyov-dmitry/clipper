#include "new.ch"
FUNCTION modify5(var1)
LOCAL m_path,m_date
LOCAL s1:=LOWER(EXENAME())
IF var1==NIL
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       s1:=LEFT(s1,ATTOKEN(s1,"\")-1)
       m_path:=s1

ELSE
m_path:=alltrim(var1)
ENDIF
SET DELE ON
SET PRINTER TO (m_path+"ms\modify5.txt")
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
mdmemvar("ZR","k_pen1","C"," ��. ����⮪ (��)","201")
mdmemvar("ZR","n_pens1","N"," ��. ����⮪ (��)","0.036")

mdmemvar("ZR","k_pen2","C"," ��. ����⮪ (��������)","202")
mdmemvar("ZR","n_pens2","N"," ��. ����⮪ (��������)","0.036")

mdmemvar("ZR","k_pen3","C"," ��. ����⮪ (�������)","203")
mdmemvar("ZR","n_pens3","N"," ��. ����⮪ (�������)","0.026")

mdmemvar("ZR","k_pen4","C"," ��. ����⮪ - ���� (��)","204")
mdmemvar("ZR","n_pens4","N"," ��. ����⮪- ����  (��)","0.02")

mdmemvar("ZR","k_pen5","C"," ��. ����⮪  - ����  (��������)","205")
mdmemvar("ZR","n_pens5","N"," ��. ����⮪ (��������)","0.02")

Close mem

m_message=DispMessage("����䨪��� 䠩�� dbrowse")
USE (m_path+"SYSTEM\dbrowse") INDEX (m_path+"SYSTEM\dbrowse") ALIAS db NEW
IF (db->(DS(PADR("SP08",8)+"04")))
	m_message=DispMessage("����䨪��� 䠩�� dbrowse;��ࠢ����� ��ப� "+db->heading+' '+db->valid)
	?"����䨪��� 䠩�� dbrowse "+db->heading
	db->valid:='p==" ".OR.p=="1".OR.p=="2"'
ENDIF
Close db
m_message=DispMessage("����䨪��� 䠩�� S_1_2B.DBF")
USE (m_path+"1_2\S_1_2B.DBF")  ALIAS db NEW
db->(DBGOTO(2))
db->name:='��. ���᮪ ��.'
db->procent1:=37.19
db->procent2:=34.70
db->procent3:=8.41
db->kopu=''
db->(DBGOTO(3))
db->name:='��. ���᮪ ����. '
db->procent1:=33.20
db->procent2:=0.00
db->procent3:=33.20
db->kopu=''
Close db
DelMessage(m_message)
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

