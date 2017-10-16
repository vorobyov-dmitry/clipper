#include "New.ch"
#define DOS_LETTERS  "€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡¢£¤¥¦§¨©ª«¬­®¯àáâãäåæçèéêëìíîïðñòóôõö÷"
#define WINDOWS_LETTERS "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ¨¸ªº¯¿¡¢"
Function encode
  test01()
RETURN .t.
Function test01
  Local GetList:={}
CLEAR
?LEN(DOS_LETTERS)
?LEN(WINDOWS_LETTERS)
use DRF1 ALIAS drf
DO WHILE .NOT.EOF()
drf->FULLN_U :=dosToWin(drf->FULLN_U )
drf->NAME_U :=dosToWin(drf->NAME_U )
drf->FATH_U :=dosToWin(drf->FATH_U )
DBSKIP()
ENDDO
use
RETURN .t.
Function dosToWin(strSource)
Local strResult
RETURN CHARREPL(DOS_LETTERS,strSource,WINDOWS_LETTERS,.t.)
