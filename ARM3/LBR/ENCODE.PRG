#include "New.ch"
#define DOS_LETTERS  "������������������������������������������������������������������������"
#define WINDOWS_LETTERS "������������������������������������������������������������������������"
Function encode
  test01()
RETURN .t.
Function listCode()
LOCAL i
SET PRINTER TO "enc.lst"
SET PRINTER ON
FOR i:=32 TO 255
??CHR(i)

NEXT
SET PRINTER OFF
SET PRINTER TO


RETURN .t.
Function test01
  Local GetList:={}
CLEAR
?LEN(DOS_LETTERS)
?LEN(WINDOWS_LETTERS)
use t01
dbappend()
t01->s1:=DOS_LETTERS
dbappend()
t01->s1:=dosToWin(DOS_LETTERS)
dbappend()
t01->s1:="Just Test ����� ��� �஡쥢 ����਩ ������� ������ iii������II��"
dbappend()

t01->s1:=dosToWin("Just Test ����� ��� �஡쥢 ����਩ ������� ������ iii������II��")
  close t01
RETURN .t.
Function dosToWin(strSource)
Local strResult
RETURN CHARREPL(DOS_LETTERS,strSource,WINDOWS_LETTERS,.t.)
