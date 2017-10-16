#define RUSS 1
#include "new.ch"
#include "set.ch"
STATIC a_cur:={},s_delim:="'."
Static m_language:=1
STATIC m_poisk1:="",m_poisk2:="",m_poisk3:="",m_poisk4:=""
#define DOS_LETTERS  "€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡¢£¤¥¦§¨©ª«¬­®¯àáâãäåæçèéêëìíîïðñòóôõö÷"
#define WINDOWS_LETTERS "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ¨¸ªº¯¿¡¢"
Function conv5
use nakl1
  DO WHILE ( nakl1->( RECNO() )<11110 )

nakl1->fio1=winToDos(nakl1->fio1)
nakl1->fio2=winToDos(nakl1->fio2)
nakl1->dov=winToDos(nakl1->dov)
nakl1->ksash=winToDos(nakl1->ksash)
nakl1->kod1=winToDos(nakl1->kod1)
nakl1->(DBSKIP())
ENDDO
close all

RETURN .t.


Function dosToWin(strSource)
Local strResult
RETURN CHARREPL(DOS_LETTERS,strSource,WINDOWS_LETTERS,.t.)

Function winToDos(strSource)
Local strResult
RETURN CHARREPL(WINDOWS_LETTERS,strSource,DOS_LETTERS,.t.)

