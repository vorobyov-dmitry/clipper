#include "new.ch"
Function buf1(var)
  LOcal n,m_path:=IF(var==NIL,"D:\buhgal\mn\",var)
  LOCAL m_month
  SET DELE ON
USE ("buf1") NEW
INDEX ON buf1->month+buf1->tabn+buf1->kopu to ("buf1")
USE (m_path+"fz1") NEW
USE (m_path+"fz2") NEW
USE (m_path+"fz3") NEW

  DO WHILE .NOT.fz1->(EOF())
       m_month:=buhmonth(fz1->ddoc)
         select fz2
         n=RECNO()
         LOCATE REST FOR fz1->vnum1=fz2->vnum1
         IF fz1->vnum1<>fz2->vnum1                  //  àãè¥­  æ¥«®áâ­®áâì „ ’‘“’‘’‚“…’ ‘‚Ÿ‡Š€ fz1 - fz2
            GO n
            SKIP 1 ALIAS fz1
            LOOP
         ENDIF
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF fz1->vdoc<>38     // ‚ ¤®ªã¬¥­â¥ ¤®«¦­  ¡ëâì § ¯¨áì ¢ fz3
               select fz3
               n=RECNO()
               LOCATE REST FOR fz2->vnum2=fz3->vnum2
               IF fz3->vnum2<>fz2->vnum2               //  àãè¥­  æ¥«®áâ­®áâì „ ’‘“’‘’‚“…’ ‘‚Ÿ‡Š€ fz2 - fz3
                  GO n
                  SKIP 1 ALIAS fz2
                  LOOP
               ENDIF
                  IF .NOT.buf1->(DBSEEK(STRZERO(m_month,2)+fz2->tabn+fz3->kopu))
                     buf1->(DBAP())
                     buf1->tabn:=fz2->tabn
                     buf1->kopu:=fz3->kopu
                  ENDIF
                     buf1->otdn+=fz2->otdn
                     buf1->oths+=fz2->oths
            ELSE
                  IF .NOT.buf1->(DBSEEK(STRZERO(m_month,2)+fz2->tabn+"000"))
                     buf1->(DBAP())
                     buf1->tabn:=fz2->tabn
                     buf1->kopu:="000"
                  ENDIF
                     buf1->otdn+=fz2->otdn
                     buf1->oths+=fz2->oths
            ENDIF
            SKIP 1 ALIAS fz2
         ENDDO
      select fz1
      SKIP 1 ALIAS fz1
  ENDDO
  CLOSE FZ1
  CLOSE FZ2
  CLOSE FZ3
RETURN .t.
function buhmonth(d)
if day(d)>25
 if month(d)=12
  return 1
 else
  return month(d)+1
 endif
endif
return month(d)
