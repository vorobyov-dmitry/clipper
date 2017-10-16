#include "New.ch"
#define DOS_LETTERS  "€‚ƒ„…†‡‰‹‘’“”•–—™› ΅Ά£¤¥¦§¨©ª«¬­®―ΰαβγδεζηθικλμνξοπρςστυφχ"
#define WINDOWS_LETTERS "ΐΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡÒΣΤΥΦΧΨΩΪΫάέήίΰαβγδεζηθικλμνξοπρςστυφχψωϊϋόύώÿ¨ΈªΊ―Ώ΅Ά"
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
t01->s1:="Just Test ®αβ® β¥αβ ‚ΰ®΅μ¥Ά „¬¨βΰ¨© υυυυτττ σσσςςς iii¨¨¨¨II"
dbappend()

t01->s1:=dosToWin("Just Test ®αβ® β¥αβ ‚ΰ®΅μ¥Ά „¬¨βΰ¨© υυυυτττ σσσςςς iii¨¨¨¨II")
  close t01
RETURN .t.
Function dosToWin(strSource)
Local strResult
RETURN CHARREPL(DOS_LETTERS,strSource,WINDOWS_LETTERS,.t.)
