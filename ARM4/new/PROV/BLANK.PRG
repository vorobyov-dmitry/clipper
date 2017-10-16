#include "new.ch"
#include "memoedit.ch"
#include "menu.ch"
static M_REG:=1
Function EditBlnk()
LOCAL m_str:=""
@0,0,MAXROW(),MAXCOL() BOX B_DOUBLE+" " COLOR "w/b"
SET COLOR TO "gr+/B"
m_reg:=1
m_str:=MEMOEDIT(m_str,1,1,MAXROW()-1,MAXCOL()-1,.t.,"MyFunc",255)
MEMOWRIT("01.lst",m_str)
RETURN .t.
Function  MyFunc(Mode,x,y)
  LOCAL i
  i:=LASTKEY()
  DO CASE
    CASE i==K_ESC.AND.m_reg==2
      m_reg:=1
      @0,10 SayDisp "อออออออออออออออ" Color "w+/b"
      RETURN ME_IGNORE
    CASE i==294
      m_reg:=2
      @0,10 SayDisp " ซ๎ข ญญ๏ ซiญiฉ" Color "w+/b"
      RETURN ME_IGNORE
    CASE m_reg==2
      DO CASE
        CASE i==ASC("6")
          DO CASE
            CASE LEFT(SCREENSTR(x-1,y,1)) =="ณยรลฟดฺ"  x+1,y ="ณมรลูดภ"

              m_chr:="ล"
            CASE x-1,y  x+1,y <>
              m_chr:="ฤ"

          KeyBoard chr(K_LEFT)+m_chr
          RETURN ME_DEFAULT
        CASE i==ASC("4")
          KeyBoard chr(K_LEFT)+"ฤ"+chr(K_LEFT)+chr(K_LEFT)
          RETURN ME_DEFAULT
        CASE i==ASC("2")
          KeyBoard chr(K_LEFT)+"ณ"+CHR(K_LEFT)+CHR(K_DOWN)
          RETURN ME_DEFAULT
        CASE i==ASC("8")
          KeyBoard chr(K_LEFT)+"ณ"+CHR(K_LEFT)+CHR(K_UP)
          RETURN ME_DEFAULT
      ENDCASE
    CASE i==K_F12.OR.i==K_CTRL_END
      RETURN K_CTRL_W
  ENDCASE

RETURN ME_DEFAULT
