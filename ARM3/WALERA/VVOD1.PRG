#include "wal.ch"
#define BELL() ?Chr(7)

// MEMVAR  arr1
// MEMVAR  vvod_clr
#DEFINE VVOD_CLR    'w/b,gr+/n,,,n/w'
MEMVAR  p_npr
MEMVAR  getlist
MEMVAR  m_vdoc
MEMVAR  m_oper
MEMVAR  m_dbspath,m_bufpath,m_temppath,m_syspath,m_sprpath
MEMVAR  p_help_code

  //
//╔══════════════════════════════════════════════════════════
//║ Процедура: s_vv001 (  )
//║ Автор: Шнайдеp В. О.
//║ Дата разработки: 19-07-91.
//║ Назначение: Ввод универсального реестра по зарплате
//║
//║ Используемые внешние переменные: m_vdoc,vvod_clr,p_npr
//║
//║ Используемые процедуры и функции: Wait_Mig,sz_use,f013_1,a71,svideo,
//║   sdoc,f_valid,_fio,replacerecord,sdelfilz
//║ Используемые файлы и внешние устройства: vvrees.wdf,fz1.dbf,fz2.dbf,
//║   fz3.dbf,sp01.dbf,sp01.ntx,sp08.dbf,sp08.ntx,sp06.dbf,sp06.ntx,
//║   SP44.dbf,SP44.ntx,sp10.dbf,sp10.ntx
//╚═══════
//
//
PROCEDURE s_vv001

LOCAL __a:="  │      │   │               │    │                  │     │     │   │        "
LOCAL clear_block := {||ii:=11,;
                   nl++,;
                   j:=1,;
                   AEVAL(ARRAY(11),{||SETPOS(10+j++,1),DISPOUT(__a)})}
LOCAL j,ii,nl:=1,i
LOCAL m_vnum1,m_vnum2,s_files:={},a_block
LOCAL    m_ddoc , m_brgd , m_vrab , m_ksash,;
         m_tabn , m_otdn , m_oths , m_kopu , m_sum
LOCAL a,GetList:={}
LOCAL arr1:=Warr1("01")
LOCAL  m_npch , m_ndoc
p_help_code := 120
// SETCURSOR(SC_NONE)
SET(_SET_DELETED,.T.) ; SET(_SET_ESCAPE,.F.) ; SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)   ; SET(_SET_SOFTSEEK,.T.)
Wait_Mig()
suse01(@s_files)
SETCOLOR(VVOD_CLR)
// SETCURSOR(SC_NORMAL)
f014_1(@arr1)
a_block:={{K_ALT_F9,{||a71(@arr1)}}}
m_ddoc:=arr1[6,2]
WHILE .T.
   SAYWDF("11")
   @1,39 SAY mnt_dtoc(fvnum->mnt) COLOR "GR+/b*"

   m_vnum1 := fvnum -> vnum1
   m_ndoc:=0
   m_npch:=arr1[1,2]
   IF !sdoc(3,42,5,46,@m_npch,@m_ndoc) ; EXIT ; END
   SETPOS(5,12) ; DISPOUT(PADR(p_npr,21,' '),"GR+/B")
   m_ddoc:=IF(!EMPTY(arr1[6,2]),arr1[6,2],m_ddoc)
   @ 5,2 GET m_ddoc VALID !EMPTY(m_ddoc) WHEN EMPTY(arr1[6,2])
   READMY(GetList,a_block);GetList:={}
   fz1->(DBAPPEND())
   fz1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,m_vdoc,DATE(),m_oper,m_vnum1}))
   fz1->mnt:=fvnum->mnt
   fvnum->vnum1 := m_vnum1+1


   ii:=11
   nl:=1
   WHILE .t.
      m_vnum2 := fvnum -> vnum2
      m_brgd  :=arr1[2,2]
      m_ksash :=arr1[3,2]
      m_vrab  :=arr1[4,2]
      m_otdn  :=m_oths  :=0
      m_tabn  :=SPACE(4)
      @ 3,65 SAY 'Лист N '+STRZERO(nl,2)
      SET(_SET_ESCAPE,!(nl=1 .and. ii=11))
      @ ii,1  GET m_brgd PICTURE 'XX' VALID  sp01->(sp_vl("SP01","2",23,11,"sp01->naim1","GR+/B",19))
      READMY(GetList,a_block);GetList:={}
      SET(_SET_ESCAPE,.F.)
      IF LASTKEY()==K_ESC .or. (!UPDATED().and. EMPTY(m_brgd).and. !(ii=11 .and. nl=1))
         EXIT
      END
      @ ii,4 GET m_ksash  PICTURE 'XXXXXXX' VALID  SP44->(sp_vl('SP44',,23,50,'SP44->naim7'))
      @ ii,11 GET m_vrab PICTURE '999' VALID  SP06->(sp_vl("SP06","2",ii,15,"sp06->naim6","GR+/B",15))
      @ ii,31 GET m_tabn PICTURE '9999' VALID  SP10->(sp_vl("SP10",,ii,36,"_fio()","GR+/B",18))
      @ ii,55 GET m_otdn PICTURE '999.9'
      @ ii,61 GET m_oths PICTURE '9999'
      READMY(GetList,a_block);GetList:={}
      fz2->(DBAPPEND())
      fz2->(ReplaceRecord({m_vnum1,m_ksash,m_vrab,m_brgd,m_tabn,m_otdn,m_oths,m_vnum2}))
      fvnum->vnum2 := m_vnum2+1
      i := .t.  // Пеpвый код оплат

      WHILE .t.
         SET(_SET_ESCAPE,!i)
         m_sum :=0
         m_kopu:=IF(i,arr1[5,2],SPACE(3))
         @ ii,67 GET m_kopu PICTURE '999' ;
              VALID SP08->(sp_vl("SP08",IF(i,"1","2")))
         @ ii,71 GET m_sum WHEN (.NOT.EMPTY(m_kopu)) PICTURE '99999.99'
         READMY(GetList,a_block);GetList:={}
         SET(_SET_ESCAPE,.F.)
         IF LASTKEY()==K_ESC .or. EMPTY(m_kopu)
            SETPOS(ii,67) ; DISPOUT(SPACE(3))
            SETPOS(ii--,71) ; DISPOUT(SPACE(8))
            EXIT
         END
         fz3->(DBAPPEND())
         fz3->(ReplaceRecord({m_vnum2,m_kopu,m_sum}))
         IF (ii++=21,EVAL(clear_block),)
         i := .f.
      END
      IF (ii++=21,EVAL(clear_block),)
   END
END
sDel01(s_files)
SET(_SET_SOFTSEEK,.F.)
RETURN


STATIC FUNCTION sDel01(s_files)

fz1->(DBCLOSEAREA())
fz2->(DBCLOSEAREA())
fz3->(DBCLOSEAREA())
fvnum->(DBCLOSEAREA())
ScloseFiles(s_files)
RETURN NIL


STATIC FUNCTION suse01(s_files)
DBUSEAREA(.t.,,m_dbspath+"fz1")
USE_INDEX("fz2")
USE_INDEX("fz3")

DBUSEAREA(.t.,,m_bufpath+"fvnum.dbr")
SopenFiles('001',@s_files)
SELECT sp08
SET FILTER TO sp08->kopu<"100"
RETURN NIL

/*--------------------------------------------------------------------------*/



FUNCTION s_vv032
// Примечание: Бpигадный наpяд

LOCAL m_ddoc,j,ii,a
LOCAL m_sum,m_sumklasn
LOCAL m_kopu,GetList:={}
LOCAL kopu1:={},sum1:={}
LOCAL __a:=SPACE(13)+'│'+SPACE(5)+'│'+SPACE(5)+'│'+SPACE(4)+;
           REPLICATE('│'+SPACE(3)+'│'+SPACE(7),4)
LOCAL clear_block := {||ii:=14,;
                   nl++,;
                   j:=1,;
                   AEVAL(ARRAY(8),{||SETPOS(13+j++,1),DISPOUT(__a)})}
LOCAL m_brgd,m_ksash,m_vrab,m_tabn,m_vnum1,m_vnum2,s_files:={},m_oths,m_otdn,nl:=1
LOCAL  m_npch , m_ndoc,a_block,m_str1a:=""
LOCAL  arr1:=Warr1("01")
p_help_code := 121
// SETCURSOR(SC_NONE)
Wait_Mig()
SETCOLOR(VVOD_CLR)
SET(_SET_DELETED,.T.)
SET(_SET_ESCAPE,.F.)
SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)
SET(_SET_SOFTSEEK,.T.)
SET(_SET_SCOREBOARD,.F.)

suse01(@s_files)
Sp08->(DBEVAL({||IF(sp08->p06=="1",m_str1a:=m_str1a+sp08->kopu+",","")}))

NET USE (m_sprpath+"sp09") NEW READONLY
COPY TO (m_temppath+"sp09") FOR AT(sp09->kopu,M_KLASSGV)#0
USE  (m_temppath+"sp09")  READONLY
INDEX ON sp09->tabn TO (m_temppath+"sp09")

SETCOLOR(VVOD_CLR)
// SETCURSOR(SC_NORMAL)
f014_1(@arr1)
a_block:={{K_ALT_F9,{||a71(@arr1)}}}
m_ddoc:=arr1[6,2]

WHILE .T.
   SAYWDF("12")
   @1,36 SAY mnt_dtoc(fvnum->mnt) COLOR "GR+/b*"
   m_vnum1 := fvnum -> vnum1
   m_ndoc:=0
   m_npch:=arr1[1,2]
   ii=14
   IF !sdoc(3,44,5,56,@m_npch,@m_ndoc) ; EXIT ; END
   SETPOS(5,12) ; DISPOUT(PADR(p_npr,21,' '),"GR+/B")
   m_ddoc:=IF(!EMPTY(arr1[6,2]),arr1[6,2],m_ddoc)
   @ 5,2 GET m_ddoc VALID !EMPTY(m_ddoc) WHEN EMPTY(arr1[6,2])
   ReadMy(GetList,a_block);GetList:={}
   fz1->(DBAPPEND())
   fz1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,m_vdoc,DATE(),m_oper,m_vnum1}))
   fz1->mnt:=fvnum->mnt
   fvnum->vnum1 := m_vnum1+1

   m_brgd=arr1[2,2]
   m_ksash=arr1[3,2]
   m_vrab= arr1[4,2]
   @ 7,14 GET m_brgd   VALID  sp01->(sp_vl("SP01","2",7,18,"sp01->naim1","GR+/B",19))
   @ 8,16 GET m_ksash  VALID  SP44->(sp_vl('SP44',,8,23,'SP44->naim7',"GR+/B"))
   @ 8,53 GET m_vrab   VALID  sp06->(sp_vl("SP06","2",8,57,"sp06->naim6","GR+/B"))
   ReadMy(GetList,a_block);GetList:={}

   nl:=1

      WHILE .t.
         m_tabn= SPACE(4)
         m_vnum2 = fvnum -> vnum2
         m_oths:=m_otdn:= 0
         @ 1,40 SAY 'Лист N '+STRZERO(nl,2)
         SET(_SET_ESCAPE,!(ii=14.and.nl=1))
         @ ii,15 GET m_tabn VALID  sp10->(sp_vl("SP10",IF(nl=1.and.ii=14,"1","2"),ii,1,"_fio()",13))
         ReadMy(GetList,a_block);GetList:={}
         SET(_SET_ESCAPE,.F.)
         IF LASTKEY()==K_ESC.or.EMPTY(m_tabn)
                EXIT
         END
         @ ii,21 GET m_oths PICTURE '9999'
         @ ii,26 GET m_otdn PICTURE '999.9'
         ReadMy(GetList,a_block);GetList:={}
         fz2->(DBAPPEND())
         fz2->(ReplaceRecord({m_vnum1,m_ksash,m_vrab,m_brgd,m_tabn,m_otdn,m_oths,m_vnum2}))
         fvnum->vnum2 := m_vnum2+1
             kopu1:={}
             sum1:={}
             FOR j=1 to 3
                SET(_SET_ESCAPE,j#1)
                m_sum := 0
                m_kopu:=IF(j==1,arr1[5,2],SPACE(3))
                @ ii,12*j+20 GET m_kopu VALID sp08->(sp_vl("SP08",IF(j==1,"1","2")))
                @ ii,12*j+24 GET m_sum  WHEN (.NOT.EMPTY(m_kopu)) PICTURE '9999.99'
                ReadMy(GetList,a_block);GetList:={}
                SET(_SET_ESCAPE,.F.)
                IF LASTKEY() == K_ESC  .or. EMPTY(m_kopu)
                   @ ii,12*j+20 SAY '   '
                   @ ii,12*j+24 SAY SPACE(7)
                   EXIT
                END
                IF AT(m_kopu,m_str1a)#0
                   AADD(kopu1,m_kopu) ; AADD(sum1 ,m_sum )
                END
                fz3->(DBAPPEND())
                fz3->(ReplaceRecord({m_vnum2,m_kopu,m_sum}))
             NEXT
             // Расчет классности
             m_sumklasn:=0
             IF sp09->(DBSEEK(m_tabn)) .and. MONTH(m_ddoc) <= VAL(sp09->month) .and. SUBSTR(m_ksash,1,3)=="202"
                FOR j = 1 TO LEN(kopu1)
                    m_sumklasn=m_sumklasn+sum1[j]*sp09->procent/100
                NEXT
                IF  m_sumklasn#0
                    @ ii,68 SAY sp09->kopu
                    @ ii,72 SAY m_sumklasn PICTURE '9999.99'
                    fz3->(DBAPPEND())
                    fz3->(ReplaceRecord({m_vnum2,sp09->kopu,m_sumklasn}))
                END
             END
         ii++
         IF (ii=22,EVAL(clear_block),)
      END
END
sdel01(s_files)
close sp09
FERASE(m_temppath+"sp09")
SET(_SET_SOFTSEEK,.F.)
RETURN .t.


/*--------------------------------------------------------------------------*/
// Ввод индивидуального наряда помощника тракториста
PROCEDURE s_vv029
   s_vv031()
RETURN


PROCEDURE s_vv031
// Примечание: Индивидуальный наpяд
LOCAL m_ddoc,j,a,ii
LOCAL m_sum,m_sumklasn
LOCAL m_kopu,a_block
LOCAL kopu1:={},sum1:={}
LOCAL __a:=SPACE(2)+'│'+SPACE(6)+'│'+SPACE(3)+'│'+SPACE(5)+'│'+SPACE(6)+;
      REPLICATE('│'+SPACE(3)+'│'+SPACE(8),4)
LOCAL clear_block := {||ii:=14,;
                   nl++,;
                   j:=1,;
                   AEVAL(ARRAY(8),{||SETPOS(13+j++,1),DISPOUT(__a)})}
LOCAL m_brgd,m_ksash,m_vrab,m_tabn,m_vnum1,m_vnum2,s_files:={},m_oths,m_otdn,nl:=1,m_otdn1
LOCAL  m_npch , m_ndoc,m_str1a:=""
LOCAL  arr1:=Warr1("01")
p_help_code := 122
// SETCURSOR(SC_NONE)
Wait_Mig()
SETCOLOR(VVOD_CLR)
SET(_SET_DELETED,.T.)
SET(_SET_ESCAPE,.F.)
SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)
SET(_SET_SOFTSEEK,.T.)
SET(_SET_SCOREBOARD,.F.)

suse01(@s_files)
Sp08->(DBEVAL({||IF(sp08->p06=="1",m_str1a:=m_str1a+sp08->kopu+",","")}))

NET USE (m_sprpath+"sp09") NEW
COPY TO (m_temppath+"sp09") FOR AT(sp09->kopu,M_KLASSGV)#0
USE  (m_temppath+"sp09")
INDEX ON sp09->tabn TO (m_temppath+"sp09")

SETCOLOR(VVOD_CLR)
// SETCURSOR(SC_NORMAL)
f014_1(@arr1)
a_block:={{K_ALT_F9,{||a71(@arr1)}}}
m_ddoc:=arr1[6,2]

WHILE .T.
   SAYWDF("13")
   @1,39 SAY mnt_dtoc(fvnum->mnt) COLOR "GR+/b*"
   m_vnum1 := fvnum -> vnum1
   m_ndoc:=0
   m_npch:=arr1[1,2]
   ii=14
   IF !sdoc(3,44,5,56,@m_npch,@m_ndoc) ; EXIT ; END
   SETPOS(5,12) ; DISPOUT(PADR(p_npr,21,' '),"GR+/B")
   m_ddoc:=IF(!EMPTY(arr1[6,2]),arr1[6,2],m_ddoc)
   @ 5,2 GET m_ddoc VALID !EMPTY(m_ddoc) WHEN EMPTY(arr1[6,2])
   READMY(GetList,a_block);GetList:={}
   fz1->(DBAPPEND())
   fz1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,m_vdoc,DATE(),m_oper,m_vnum1}))
   fz1->mnt:=fvnum->mnt
   fvnum->vnum1 := m_vnum1+1


   m_tabn= SPACE(4)
   m_otdn1:= 0
   SET(_SET_ESCAPE,.F.)
   @ 8,5 GET m_tabn  VALID  SP10->(SP_vl("SP10",,8,20,"_fio()","GR+/B"))
   @ 8,62 GET m_otdn1 PICTURE '999.9'
   READMY(GetList,a_block);GetList:={}
   nl:=1
      WHILE .t.
         m_vnum2 = fvnum -> vnum2
         m_ksash=arr1[3,2]
         m_brgd= arr1[2,2]
         m_vrab= arr1[4,2]
         m_oths:=m_otdn:= 0
         @ 1,40 SAY 'Лист N '+STRZERO(nl,2)
         SET(_SET_ESCAPE,!(ii=14.and.nl=1))
         @ ii,1  GET m_brgd VALID  sp01->(sp_vl("SP01","2",23,7,"sp01->naim1","gr+/b",19))
         READMY(GetList,a_block);GetList:={}
         SET(_SET_ESCAPE,.F.)
         IF LASTKEY()==K_ESC .or.(!UPDATED().and. EMPTY(m_brgd).and. !(ii=14.and.nl=1))
                @ ii,1  SAY '  '
                EXIT
         END
         @ ii,4 GET m_ksash  VALID  SP44->(sp_vl('SP44',,23,32,'SP44->naim7',"GR+/B"))
         @ ii,11 GET m_vrab  VALID  sp06->(sp_vl("SP06","2",23,59,"sp06->naim6","GR+/B"))
         IF m_otdn1=0
            @ ii,15 GET m_otdn PICTURE '999.9'
         ELSE
            m_otdn=m_otdn1
         END
         @ ii,22 GET m_oths PICTURE '9999'
         READMY(GetList,a_block);GetList:={}
         fz2->(DBAPPEND())
         fz2->(ReplaceRecord({m_vnum1,m_ksash,m_vrab,m_brgd,m_tabn,m_otdn,m_oths,m_vnum2}))
         fvnum->vnum2 := m_vnum2+1

         kopu1:={}
         sum1:={}
         FOR j=1 to 3
                SET(_SET_ESCAPE,j#1)
                m_sum := 0
                m_kopu:=IF(j==1,arr1[5,2],SPACE(3))
                @ ii,13*j+15 GET m_kopu VALID SP08->(sp_vl("SP08",IF(j==1,"1","2")))
                @ ii,13*j+19 GET m_sum  WHEN (.NOT.EMPTY(m_kopu))   PICTURE '99999.99'
                READMY(GetList,a_block);GetList:={}
                SET(_SET_ESCAPE,.F.)
                IF LASTKEY() == K_ESC  .or. EMPTY(m_kopu)
                   @ ii,13*j+15 SAY '   '
                   @ ii,13*j+19  SAY SPACE(8)
                   EXIT
                END
                IF AT(m_kopu,m_str1a)#0
                   AADD(kopu1,m_kopu) ; AADD(sum1 ,m_sum )
                END
                fz3->(DBAPPEND())
                fz3->(ReplaceRecord({m_vnum2,m_kopu,m_sum}))
             NEXT
             // Расчет классности
             m_sumklasn:=0
             IF sp09->(DBSEEK(m_tabn)) .and. MONTH(m_ddoc) <= VAL(sp09->month) .and. SUBSTR(m_ksash,1,3)=="202"
                FOR j = 1 TO LEN(kopu1)
                    m_sumklasn:=m_sumklasn+sum1[j]*sp09->procent/100
                NEXT
                IF  m_sumklasn#0
                    @ ii,67 SAY sp09->kopu
                    @ ii,71 SAY m_sumklasn PICTURE '99999.99'
                    fz3->(DBAPPEND())
                    fz3->(ReplaceRecord({m_vnum2,sp09->kopu,m_sumklasn}))
                END
             END
         ii++
         IF (ii=22,EVAL(clear_block),)
         IF m_otdn1 # 0.00
            EXIT
         END
      END
END
sdel01(s_files)
close sp09
FERASE (m_temppath+"sp09")

SET(_SET_SOFTSEEK,.F.)
RETURN

/*--------------------------------------------------------------------------*/
// Табель
PROCEDURE s_vv030
LOCAL   __a:=SPACE(25)+'│     │      │   │     │     │   │       │   │       '
LOCAL clear_block := {||ii:=11,;
                   nl++,;
                   j:=1,;
                   AEVAL(ARRAY(11),{||SETPOS(10+j++,1),DISPOUT(__a)}),;
                   Scroll(23,28,23,47),;
                   Scroll(23,59,23,78)}
LOCAL   m_ddoc,j,a,ii
LOCAL   nl:=1
LOCAL   m_brgd
LOCAL   m_vnum1,m_vnum2,s_files:={}               // Внутренний номер документа
LOCAL   m_vrab
LOCAL   m_ksash
LOCAL   m_tabn
LOCAL   m_otdn
LOCAL   m_oths
LOCAL   m_kopu:= "003"
LOCAL   m_sum
LOCAL  m_npch , m_ndoc,a_block
LOCAL  arr1 :=Warr1("02")

p_help_code := 123



// SETCURSOR(SC_NONE)
Wait_Mig()
SETCOLOR(VVOD_CLR)
SET(_SET_DELETED,.T.)
SET(_SET_ESCAPE,.F.)
SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)
SET(_SET_SOFTSEEK,.T.)
SET(_SET_SCOREBOARD,.F.)

NET USE (m_sprpath+"sp20") INDEX (m_sprpath+"sp20") NEW READONLY

suse01(@s_files)

SETCOLOR(VVOD_CLR)
// SETCURSOR(SC_NORMAL)
f014_1(@arr1)
a_block:={{K_ALT_F9,{||a71(@arr1)}}}
m_ddoc:=arr1[6,2]

WHILE .T.                /* по документам */
   SAYWDF("14")
   @1,39 SAY mnt_dtoc(fvnum->mnt) COLOR "GR+/b*"
   m_vnum1 = fvnum -> vnum1
   ii=11
   m_ndoc=0
   m_npch:=arr1[1,2]
   IF !sdoc(3,68,5,72,@m_npch,@m_ndoc)
      EXIT
   END
   SETPOS(5,12) ; DISPOUT(PADR(p_npr,21,' '),"GR+/B")
   m_ddoc:=IF(!EMPTY(arr1[6,2]),arr1[6,2],m_ddoc)
   @ 5,2 GET m_ddoc VALID !EMPTY(m_ddoc) WHEN EMPTY(arr1[6,2])
   READMY(GetList,a_block);GetList:={}
   fz1->(DBAPPEND())
   fz1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,m_vdoc,DATE(),m_oper,m_vnum1}))
   fz1->mnt:=fvnum->mnt
   fvnum->vnum1 := m_vnum1+1

   m_brgd=arr1[2,2]
   @ 5,35  GET m_brgd VALID  Sp01->(sp_vl("SP01","2",5,38,"sp01->naim1","GR+/B"))
   READMY(GetList,a_block);GetList:={}
              WHILE .t.
                  m_vnum2 = fvnum -> vnum2
                  m_ksash=arr1[3,2]
                  m_vrab= arr1[4,2]
                  m_otdn= 0
                  m_oths= 0
                  m_tabn= SPACE(4)
                  @ 1,40 SAY 'Лист N '+STRZERO(nl,2)
                  SET(_SET_ESCAPE,!(nl=1 .and. ii=11))
                  @ ii,27 GET m_tabn VALID  Sp10->(sp_vl("SP10",IF(nl=1 .and. ii=11,"1","2"),ii,1,"_fio()","GR+/B"))
                  READMY(GetList,a_block);GetList:={}
                  SET(_SET_ESCAPE,.F.)
                  IF LASTKEY()==K_ESC .or. EMPTY(m_tabn)
                     EXIT
                  END
                 m_ksash:=arr1[3,2];m_vrab:=arr1[4,2];m_kopu:=IF(EMPTY(arr1[5,2]),"003",arr1[5,2])
                 @ ii,33 GET m_ksash WHEN(EMPTY(arr1[3,2])) VALID  SP44->(sp_vl('SP44',,23,28,'SP44->naim7',"GR+/B"))
                 @ ii,40 GET m_vrab  WHEN(EMPTY(arr1[4,2]))   VALID  Sp06->(sp_vl('SP06',"2",23,59,'sp06->naim6',"GR+/B"))
                 @ ii,44 GET m_otdn PICTURE '999.9'
                 @ ii,50 GET m_oths PICTURE '9999'
                 READMY(GetList,a_block);GetList:={}
                 // sp20->(DBSEEK(STRZERO(MONTH(fz1->ddoc),2)))
                 Sp10->(DBSEEK(m_tabn))
                 sp20->(DBSEEK(StrZero ( YEAR (m_ddoc ) , 2 )+Sp10->grafik))

                 @ ii,56 SAY m_kopu COLOR "GR+/B"
                 @ ii,60 SAY (m_sum:=sp10->stavka*m_oths/(sp20->(FIELDGET(FIELDNUM("OTHS"+STRZERO(MONTH(m_ddoc),2)))))) ;
                         PICTURE '9999.99'
                 fz2->(DBAPPEND())
                 fz2->(ReplaceRecord({m_vnum1,m_ksash,m_vrab,m_brgd,m_tabn,m_otdn,m_oths,m_vnum2}))
                 fvnum->vnum2 := m_vnum2+1
                 fz3->(DBAPPEND())
                 fz3->(ReplaceRecord({m_vnum2,m_kopu,m_sum}))
                 ii++
                 IF (ii=22,EVAL(clear_block),)
              END
   END
// ()
sdel01(s_files)
SET(_SET_SOFTSEEK,.F.)
CLOSE sp20
RETURN

/*--------------------------------------------------------------------------*/
// Отпускные, больничные

PROCEDURE s_vv020_021(r)
LOCAL     m_vnum1,m_vnum2,s_files:={},a_block
LOCAL     m_ddoc
LOCAL     m_brgd
LOCAL     m_vrab
LOCAL     m_ksash :=IF(r=='отп','890001','691104')
LOCAL     m_tabn
LOCAL     m_otdn
LOCAL     m_oths
LOCAL     m_kopu
LOCAL     m_sum
LOCAL     nl:=1
LOCAL clear_block := {||ii:=9,;
                   nl++,;
                   j:=1,;
                   AEVAL(ARRAY(13),{||SETPOS(8+j++,1),DISPOUT(__a)})}
LOCAL  __a := "│      │    │       │"+SPACE(25)+"│       │       │     │        │"
LOCAL ii,j
LOCAL  m_npch , m_ndoc
LOCAL   arr1:=Warr1("03")
p_help_code := IF(r=='отп',124,125)
// SETCURSOR(SC_NONE)
Wait_Mig()
SETCOLOR(VVOD_CLR)
SET(_SET_DELETED,.T.)
SET(_SET_ESCAPE,.F.)
SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)
SET(_SET_SOFTSEEK,.T.)
SET(_SET_SCOREBOARD,.F.)

suse01(@s_files)

SETCOLOR(VVOD_CLR)
// SETCURSOR(SC_NORMAL)
f014_1(@arr1)
a_block:={{K_ALT_F9,{||a71(@arr1)}}}
m_ddoc:=arr1[2,2]

WHILE .T.
   SAYWDF(IF(r=='отп',"15","16"))
   @1,39 SAY mnt_dtoc(fvnum->mnt) COLOR "GR+/b*"

   m_vnum1 := fvnum -> vnum1
   ii=9
   nl := 1
   m_ndoc:=0
   m_npch:=arr1[1,2]
   m_kopu :=IF(r=='отп','040','044')
   IF !sdoc(4,58,4,73,@m_npch,@m_ndoc) ; EXIT ; END
   @ 4,28 SAY p_npr COLOR "GR+/B"
   m_ddoc:=IF(!EMPTY(arr1[2,2]),arr1[2,2],m_ddoc)
   @ 4,7 GET m_ddoc VALID !EMPTY(m_ddoc) WHEN EMPTY(arr1[2,2])
   READMY(GetList,a_block);GetList:={}
   fz1->(DBAPPEND())
   fz1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,m_vdoc,DATE(),m_oper,m_vnum1}))
   fz1->mnt:=fvnum->mnt
   fvnum->vnum1 := m_vnum1+1
   WHILE .t.
      m_vnum2 := fvnum -> vnum2
      m_brgd  :=SPACE(2)
      m_vrab  :=SPACE(3)
      m_otdn  :=0
      m_oths  :=0
      m_tabn  :=SPACE(4)
      @ 2,40 SAY 'Лист N '+STRZERO(nl,2)
      SET(_SET_ESCAPE,!(nl=1 .and. ii=9))
      m_ksash:=IF(EMPTY(arr1[3,2]),m_ksash,arr1[3,2])
      @ ii,2 GET m_ksash VALID SP44->(sp_vl("SP44"))
      READMY(GetList,a_block);GetList:={}
      SET(_SET_ESCAPE,.F.)
      IF LASTKEY()==K_ESC
            EXIT
      END
      m_sum =0;m_kopu:=IF(EMPTY(arr1[4,2]),m_kopu,arr1[4,2])
      @ ii,10 GET m_brgd  VALID SP01->(SP_VL("SP01","2"))
      @ ii,15 GET m_tabn  VALID  sp10->(sp_vl("SP10","1",ii,22,"_fio()","GR+/B"))
      @ ii,49 GET m_otdn  PICTURE '999.9' ;
              VALID EVAL({||m_oths:=m_otdn*7,IF(r=='отп',m_otdn<=31 .and. m_otdn>0,m_otdn>0)})
      @ ii,57 GET m_oths PICTURE '9999'
      @ ii,70 GET m_sum PICTURE '99999.99'
      @ ii,65 SAY m_kopu
      READMY(GetList,a_block);GetList:={}
      fz2->(DBAPPEND())
      fz2->(ReplaceRecord({m_vnum1,m_ksash,m_vrab,m_brgd,m_tabn,m_otdn,m_oths,m_vnum2}))
      fvnum->vnum2 := m_vnum2+1
      fz3->(DBAPPEND())
      fz3->(ReplaceRecord({m_vnum2,m_kopu,m_sum}))
      ii++
      IF (ii=22,EVAL(clear_block),)
   END
END
sDel01(s_files)
RETURN


/*-----------------------------------------------------------------------*/

//║ Процедура: S_VV036
//║ Автор: Шнайдер В. О.
//║ Hазначение:  Ввод учетного листа тракториста-машиниста

PROCEDURE s_vv036

LOCAL i,j,k,a
LOCAL     m_vnum1,m_vnum2,s_files:={},a_block
LOCAL     m_ddoc
LOCAL     m_tabn
LOCAL     m_ntr
LOCAL     m_brgd
LOCAL     m_ksash
LOCAL     m_vrab
LOCAL    m_vpga,m_vptn
LOCAL    m_otnsm
LOCAL    m_rtnor,m_rtfak,m_rtfaks,m_ostnm
LOCAL     m_kopu,m_sumklasn
LOCAL    m_vpug
LOCAL    m_zapr
LOCAL    m_otmd
LOCAL    m_otms,l_first:=.t.
LOCAL    m_oths,m_othss
LOCAL    m_sum,sum1,kopu1
LOCAL     m_otdn:=0
LOCAL  m_npch , m_ndoc,m_str1a:=""
LOCAL arr1:=Warr1("01")
#ifdef _L_BRGD
   LOCAL  m_brgdzak:='  '
#endif

p_help_code := 126



// SETCURSOR(SC_NONE)
Wait_Mig()
SETCOLOR(VVOD_CLR)
SET(_SET_DELETED,.T.)
SET(_SET_ESCAPE,.F.)
SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)
SET(_SET_SOFTSEEK,.T.)
SET(_SET_SCOREBOARD,.F.)
suse02(@s_files)
SETCOLOR(VVOD_CLR)
// SETCURSOR(SC_NORMAL)
f014_1(@arr1)
a_block:={{K_ALT_F9,{||a71(@arr1)}}}
m_ddoc:=arr1[6,2]
Sp08->(DBEVAL({||IF(sp08->p07=="1",m_str1a:=m_str1a+sp08->kopu+",","")}))

WHILE .T.
   SAYWDF("17")
   @1,39 SAY mnt_dtoc(fvnum->mnt) COLOR "GR+/b*"

   m_vnum1 :=  fvnum->vnum1
   m_ndoc  :=  m_rtfaks := m_othss :=0
   m_npch  :=  arr1[1,2]
   m_ntr   :=  SPACE(5)
   m_tabn  :=  SPACE(4)
   IF !sdoc(3,41,6,39,@m_npch,@m_ndoc) ; EXIT ;  END
   SETPOS(4,15) ; DISPOUT(p_npr,"GR+/B")
   m_ddoc:=IF(!EMPTY(arr1[6,2]),arr1[6,2],m_ddoc)
   @ 4,4 GET m_ddoc VALID !EMPTY(m_ddoc) WHEN EMPTY(arr1[6,2])
   READMY(GetList,a_block);GetList:={}
   #ifdef _L_BRGD
      @ 6,9 GET m_brgdzak PICTURE 'XX' VALID sp01->(sp_vl("SP01","2",6,12,"sp01->naim1","GR+/B"))
   #endif
   @ 4,74 GET m_tabn  VALID  sp10->(sp_vl("SP10",,4,46,"_fio()","GR+/B"))
   @ 6,73 GET m_ntr VALID EVAL({||m_ntr:=PADL(ALLTRIM(m_ntr),5),;
                      inv_t->(sp_vl('INV_T',,6,46,'SP13B->naim13b',"GR+/b"))})
   READMY(GetList,a_block);GetList:={}
   fz1t->(DBAPPEND())
   fz1t->(ReplaceRecord({m_vnum1,m_ntr,,,,}))

   #ifdef _L_BRGD
      fz2b->(DBAPPEND())
      fz2b->(ReplaceRecord({m_vnum1,m_brgdzak}))
   #endif
   fz1->(DBAPPEND())
   fz1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,m_vdoc,DATE(),m_oper,m_vnum1}))
   fz1->mnt:=fvnum->mnt
   fvnum->vnum1 := m_vnum1+1
  i:=1;l_first:=.t.
  DO WHILE .t.
      m_brgd := arr1[2,2]
      m_ksash:= arr1[3,2]
      m_vrab := arr1[4,2]
      m_vnum2:= fvnum->vnum2
      SET(_SET_ESCAPE,i#1)
      @ 11+i,1  GET m_brgd ;
                VALID  sp01->(sp_vl("SP01","2"))
      READMY(GetList,a_block);GetList:={}
      SET(_SET_ESCAPE,.F.)
      IF LASTKEY()==K_ESC .or.(!UPDATED().and. EMPTY(m_brgd).and..NOT.l_first)
        @ 11+i,1  SAY '  '
        EXIT
      END
      l_first:=.f.
      m_vpga:=m_vptn:=m_otnsm:=m_ostnm:=0
      m_zapr:=m_oths:=m_rtfak:=m_rtnor:=m_vpug:=m_otmd:=m_otms:=0
      @ 11+i,4 GET     m_ksash  ;
              VALID  SP44->(sp_vl('SP44',,11+i,11,'SP44->naim7',"GR+/B",12))
      @ 11+i,24 GET m_vrab ;
                VALID  sp06->(sp_vl('SP06',"2",11+i,28,'sp06->naim6',"GR+/b",12))
      @ 11+i,41 GET m_vpga PICTURE '9999.9'
      @ 11+i,48 GET m_vptn PICTURE '9999.999'
      @ 11+i,57 GET m_otnsm PICTURE '99.9'
      @ 11+i,62 GET m_oths  PICTURE '999'
      @ 11+i,66 GET m_rtnor PICTURE '9999.9'
      @ 11+i,73 GET m_rtfak PICTURE '9999.9'
      READMY(GetList,a_block);GetList:={}
      fz2->(DBAPPEND())
      fz2->(ReplaceRecord({m_vnum1,m_ksash,m_vrab,m_brgd,m_tabn,0,m_oths,m_vnum2}))
      fvnum->vnum2 := m_vnum2+1

      m_othss:=m_othss+m_oths
      m_rtfaks=m_rtfaks+m_rtfak
      kopu1:={}
      sum1:={}
      FOR j=1 to 3
        SET(_SET_ESCAPE,j#1)
        m_sum := 0
        m_kopu:=IF(j==1,arr1[5,2],SPACE(3))
        @ 19+i,12*j-11 GET m_kopu PICTURE '999' ;
            VALID SP08->(sp_vl("SP08",if(j==1,"1","2")))
        @ 19+i,12*j-7 GET m_sum   WHEN (.NOT.EMPTY(m_kopu)) PICTURE '9999.99'
        READMY(GetList,a_block);GetList:={}
        SET(_SET_ESCAPE,.F.)
        IF LASTKEY() == K_ESC  .or. EMPTY(m_kopu)
            @ 19+i,12*j-11 SAY SPACE(3)
            @ 19+i,12*j-7  SAY SPACE(7)
            EXIT
        END
        IF AT(m_kopu,m_str1a)#0
            AADD(kopu1,m_kopu) ; AADD(sum1 ,m_sum )
        END
        fz3->(DBAPPEND())
        fz3->(ReplaceRecord({m_vnum2,m_kopu,m_sum}))
      NEXT
      // Расчет классности
      m_sumklasn:=0
      IF sp09->(DBSEEK(m_tabn)) .and. month(m_ddoc) <= VAL(sp09->month)
        FOR k = 1 TO LEN(kopu1)
            m_sumklasn=m_sumklasn+sum1[k]*sp09->procent/100
        NEXT
        IF  m_sumklasn#0
            @ 19+i,37 SAY sp09->kopu
            @ 19+i,41 SAY m_sumklasn PICTURE '9999.99'
            fz3->(DBAPPEND())
            fz3->(ReplaceRecord({m_vnum2,sp09->kopu,m_sumklasn}))
        END
      END
      @ 19+i,49 GET m_vpug PICTURE '9999.9'
      READMY(GetList,a_block);GetList:={}
      fz2t->(DBAPPEND())
      fz2t->(REPLACERECORD({m_vnum2,m_vpga,m_vptn,m_vpug,m_rtnor,m_rtfak,m_otnsm}))
      i:=i+1
      IF i==4
        FOR i:=1 TO 3
          @ 11+i,1  Say SPACE(2)
          @ 11+i,4  SAY SPACE(6)
          @ 11+i,11 SAY SPACE(12)
          @ 11+i,24 SAY SPACE(3)
          @ 11+i,28 SAY SPACE(12)
          @ 11+i,41 SAY SPACE(6)
          @ 11+i,48 SAY SPACE(8)
          @ 11+i,57 SAY SPACE(4)
          @ 11+i,62 SAY SPACE(3)
          @ 11+i,66 SAY SPACE(6)
          @ 11+i,73 SAY SPACE(6)
          @ 19+i,49 SAY SPACE(6)
          FOR j=1 to 3
            @ 19+i,12*j-11 SAY SPACE(3)
            @ 19+i,12*j-7  SAY SPACE(7)
          NEXT
          @ 19+i,37 SAY SPACE(3)
          @ 19+i,41 SAY SPACE(7)
        NEXT
        i:=1
      ENDIF
  ENDDO
         @ 18,62 GET m_ostnm  PICTURE '9999'
         @ 18,68 GET m_zapr   ;
                 PICTURE '9999' ;
                 VALID EVAL({||SETPOS(18,74),;
                               DISPOUT(TRANSFORM(m_ostnm+m_zapr-m_rtfaks,"99999")),;
                               .t.})
         @ 20,75 GET m_otmd PICTURE '99.9';
             VALID EVAL ( {||SETPOS(19+MIN(i-1,3),56),;
                 DISPOUT(TRANSFORM(m_otmd,"99.9" )),.t. } )
         @ 22,75 GET m_otms PICTURE '99.9'
         READMY(GetList,a_block);GetList:={}
         fz2->otdn:=m_otmd
         fz1t->(ReplaceRecord({,,m_zapr,m_ostnm,m_otmd,m_otms}))
   END
 // ()
 sClose02(@s_files)
RETURN


STATIC FUNCTION suse02(s_files)
DBUSEAREA(.t.,,m_dbspath+"fz1")

USE_INDEX("fz2")

USE_INDEX("fz3")

USE_INDEX("fz1t")

USE_INDEX("fz2t")

#ifdef _L_BRGD
   USE_INDEX("fz2b")
#endif

DBUSEAREA(.t.,,m_bufpath+"fvnum.dbr")

SopenFiles("001",@s_files)
SELE sp08
SET FILTER TO sp08->kopu<"100"
NET USE (m_sprpath+"sp09") NEW READONLY
COPY TO (m_temppath+"sp09k") FOR AT(sp09->kopu,M_KLASSTR)#0
CLOSE Sp09
USE  (m_temppath+"sp09k") ALIAS Sp09 NEW
INDEX ON sp09->tabn TO (m_temppath+"sp09")
SopenFiles("INV_T",@s_files)
SELE inv_t
SET RELATION TO inv_t->kmtr INTO sp13b
RETURN NIL



STATIC FUNCTION sclose02(s_files)
fz1   -> ( DBCLOSEAREA () )
fz2   -> ( DBCLOSEAREA () )
fz3   -> ( DBCLOSEAREA () )
fz1t  -> ( DBCLOSEAREA () )
fz2t  -> ( DBCLOSEAREA () )
fvnum ->(DBCLOSEAREA())
ScloseFiles(s_files)
#ifdef _L_BRGD
   fz2b->(DBCLOSEAREA())
#endif
IF SELECT("sp09")<>0
  CLOSE SP09
ENDIF
RETURN NIL


FUNCTION USE_INDEX(cFile)
DBUSEAREA(.t.,,m_dbspath+cFile);DBSETINDEX(m_dbspath+cFile);DBSETORDER(0)
RETURN NIL

//
//╔══════════════════════════════════════════════════════════
//║ Процедура: S_VV037
//║ Автор: Шнайдер В. О.
//║ Дата разработки: 05/14/91 09:54pm
//║ Параметры:
//║ Hазначение:  Ввод путевого листа трактора
//║ Используемые внешние переменные:  M_VDOC
//║ Используемые процедуры и функции:
//║ Используемые файлы и внешние устройства:
//║ Побочные эффекты:
//║ Примечания:
//╚═══════
//
PROCEDURE s_vv037

LOCAL i,j,k,a
LOCAL     m_vnum1,m_vnum2,s_files:={},a_block
LOCAL     m_ddoc
LOCAL     m_tabn
LOCAL     m_ntr
LOCAL     m_brgd
LOCAL     m_ksash
LOCAL     m_vrab
LOCAL    m_vpga,m_vptn
LOCAL    m_otnsm
LOCAL    m_rtnor,m_rtfak,m_rtfaks
LOCAL     m_kopu,m_sumklasn
LOCAL    m_vpug
LOCAL    m_zapr
LOCAL    m_otmd
LOCAL    m_otms
LOCAL    m_oths,m_othss
LOCAL    m_sum,sum1,kopu1,m_ostnm,m_ost
LOCAL     m_otdn:=0,m_kolez
LOCAL   m_prtn,m_vtktr,m_pgob,m_pggr
LOCAL  m_npch , m_ndoc,m_str1a:=""
LOCAL arr1:=Warr1("01")
#ifdef _L_BRGD
   LOCAL  m_brgdzak:='  '
#endif

p_help_code := 127



// SETCURSOR(SC_NONE)
Wait_Mig()
SETCOLOR(VVOD_CLR)
SET(_SET_DELETED,.T.)
SET(_SET_ESCAPE,.F.)
SET(_SET_CONFIRM,.T.)
SET(_SET_EXACT,.T.)
SET(_SET_SOFTSEEK,.T.)
SET(_SET_SCOREBOARD,.F.)
suse02(@s_files)
USE_INDEX("fz2tp")
SETCOLOR(VVOD_CLR)
// SETCURSOR(SC_NORMAL)
f014_1(@arr1)
a_block:={{K_ALT_F9,{||a71(@arr1)}}}
m_ddoc:=arr1[6,2]
Sp08->(DBEVAL({||IF(sp08->p07=="1",m_str1a:=m_str1a+sp08->kopu+",","")}))

WHILE .T.
   SAYWDF("18")
   @1,39 SAY mnt_dtoc(fvnum->mnt) COLOR "GR+/b*"

      m_vnum1 :=  fvnum->vnum1
      m_ndoc  :=  m_rtfaks := m_othss :=0
      m_npch  :=  arr1[1,2]
      m_ntr   :=  SPACE(5)
      m_tabn  :=  SPACE(4)
      IF !sdoc(3,37,5,36,@m_npch,@m_ndoc) ;  EXIT ; END
      SETPOS(5,10) ; DISPOUT(PADR(p_npr,18),"GR+/B")
      m_ddoc:=IF(!EMPTY(arr1[6,2]),arr1[6,2],m_ddoc)
      @ 5,1 GET m_ddoc VALID !EMPTY(m_ddoc) WHEN EMPTY(arr1[6,2])
      READMY(GetList,a_block);GetList:={}
   #ifdef _L_BRGD
      @ 5,63 GET m_brgdzak VALID sp01->(sp_vl("SP01","2",5,65,"sp01->naim1","GR+/B",14))
   #endif
      @ 7,9 GET m_tabn ;
          VALID  sp10->(sp_vl("SP10",,7,14,"_fio()","GR+/B"))
      @ 7,53 GET m_ntr ;
          VALID EVAL({||m_ntr:=PADL(ALLTRIM(m_ntr),5),;
                      inv_t->(sp_vl('INV_T',,7,59,'sp13b->naim13b',"GR+/B"))})
      READMY(GetList,a_block);GetList:={}

      FOR i=1 TO 3
             m_brgd := arr1[2,2]
             m_ksash:= arr1[3,2]
             m_vrab := arr1[4,2]
             m_vnum2:= fvnum->vnum2
             m_kopu := arr1[5,2]
             SET(_SET_ESCAPE,i#1)
             @ 11+i,1  GET m_brgd ;
                VALID  sp01->(sp_vl("SP01","2",23,5,"sp01->naim1","GR+/B"))
             READMY(GetList,a_block);GetList:={}
             SET(_SET_ESCAPE,.F.)
             IF LASTKEY()==K_ESC .or.(!UPDATED().and. EMPTY(m_brgd).and. i#1)
                @ 11+i,1  SAY SPACE(2)
                EXIT
             END
             @ 11+i,4 GET m_ksash  ;
                 VALID  SP44->(sp_vl('SP44',,23,31,'SP44->naim7',"GR+/B"))
             @ 11+i,11 GET m_vrab ;
              VALID  sp06->(sp_vl("SP06","2",23,61,"sp06->naim6",18))
             m_ost:=m_vpga:=m_vptn:=m_otnsm:=m_ostnm:=m_otdn:=0
             m_zapr:=m_oths:=m_rtfak:=m_rtnor:=m_vpug:=m_otmd:=m_otms:=0
             m_kolez :=0
             m_prtn:=m_vtktr:=m_pgob:=m_pggr:=0
             @ 11+i,15 GET m_oths  PICTURE '9999'
             @ 11+i,21 GET m_otnsm  PICTURE '99.9'
             @ 11+i,28 GET m_prtn  PICTURE '9999'
             @ 11+i,35 GET m_vtktr PICTURE '999999.9'

             kopu1:={}
             sum1:={}
             FOR j=1 to 2
                SET(_SET_ESCAPE,j#1)
                m_sum = 0
                m_kopu:=IF(j==1,arr1[5,2],SPACE(3))
                @ 11+i,12*j+32 GET m_kopu  ;
                  VALID SP08->(sp_vl("SP08",IF(j==1,"1","2")))
                @ 11+i,12*j+36 GET m_sum  WHEN (.NOT.EMPTY(m_kopu))  PICTURE '9999.99'
                READMY(GetList,a_block);GetList:={}
                SET(_SET_ESCAPE,.F.)
                IF LASTKEY() == K_ESC  .or. EMPTY(m_kopu)
                   @ 11+i,12*j+32 SAY '   '
                   @ 11+i,12*j+36 SAY SPACE(7)
                   EXIT
                END
                IF AT(m_kopu,m_str1a)#0
                   AADD(kopu1,m_kopu) ; AADD(sum1 ,m_sum )
                END
                fz3->(DBAPPEND())
                fz3->(ReplaceRecord({m_vnum2,m_kopu,m_sum}))
             NEXT



             // Расчет классности
             m_sumklasn:=0
             IF sp09->(DBSEEK(m_tabn)) .and. MONTH(m_ddoc) <= VAL(sp09->month)
                FOR k = 1 TO LEN(kopu1)
                    m_sumklasn=m_sumklasn+sum1[k]*sp09->procent/100
                NEXT
                IF  m_sumklasn#0
                    @ 11+i,68 SAY sp09->kopu
                    @ 11+i,72 SAY m_sumklasn PICTURE '9999.99'
                    fz3->(DBAPPEND())
                    fz3->(ReplaceRecord({m_vnum2,sp09->kopu,m_sumklasn}))
                END
             END
             @ 18+i,2 GET m_vpug PICTURE '999.9'
             @ 18+i,10 GET m_pgob PICTURE '99999'
             @ 18+i,17 GET m_pggr PICTURE '99999'
             @ 18+i,26 GET m_rtnor PICTURE '9999.9'
             @ 18+i,36 GET m_rtfak PICTURE '9999.9'
             @ 18+i,46 GET m_kolez PICTURE "99"
             READMY(GetList,a_block);GetList:={}
             m_othss:=m_othss+m_oths
             m_rtfaks=m_rtfaks+m_rtfak
             fz2->(DBAPPEND())
             fz2->(ReplaceRecord({m_vnum1,m_ksash,m_vrab,m_brgd,m_tabn,0,m_oths,m_vnum2}))
             fz2tp->(DBAPPEND())
             fz2tp->(ReplaceRecord({m_vnum2,m_prtn,m_vtktr,m_pgob,m_pggr,m_kolez}))
             fz2t->(DBAPPEND())
             fz2t->(ReplaceRecord({m_vnum2,m_vpga,m_vptn,m_vpug,m_rtnor,m_rtfak,m_otnsm}))
             fvnum->vnum2 := m_vnum2+1
         NEXT
         @ 5,43 GET m_ostnm  PICTURE '9999'
         @ 5,50 GET m_zapr   PICTURE '9999' VALID EVAL({||SETPOS(5,56),;
                               DISPOUT(TRANSFORM(m_ostnm+m_zapr-m_rtfaks,"99999")),;
                               .t.})
         @ 18,75 GET m_otmd PICTURE '99.9';
             VALID EVAL ( {||SETPOS(11+MIN(i-1,3),21),;
                 DISPOUT(TRANSFORM(m_otmd,"99.9" )),.t. } )
         @ 19,75 GET m_otms PICTURE '99.9'
         READMY(GetList,a_block);GetList:={}
         fz2->otdn:=m_otmd
         fz1t->(DBAPPEND())
         fz1t->(ReplaceRecord({m_vnum1,m_ntr,m_zapr,m_ostnm,m_otmd,m_otms}))
         fz1->(DBAPPEND())
         fz1->(ReplaceRecord({m_npch,m_ndoc,m_ddoc,m_vdoc,DATE(),m_oper,m_vnum1}))
         fz1->mnt:=fvnum->mnt
   #ifdef _L_BRGD
      fz2b->(DBAPPEND())
      fz2b->(ReplaceRecord({m_vnum1,m_brgdzak}))
   #endif
         fvnum->vnum1  := m_vnum1+1
   END
// ()
sClose02(@s_files)
fz2tp->(dbclosearea())
RETURN
FUNCTION a71(arr1)

#define HELPCODE  197

MEMVAR  _1,_2,_3
LOCAL  ss,re:=READEXIT(.t.),se:=SET(_SET_ESCAPE),bAction:=SETKEY(K_F9,NIL)
LOCAL arrtmax:=0 , arrlmax:=0,lenarr:=LEN(arr1),lenght,col,row,co:=SETCOLOR()
LOCAL i := 0
LOCAL getlist := {}
LOCAL oldHelpCode := p_help_code
PRIVATE _1,_2,_3
FOR i=1 to  lenarr
  arrtmax:=MAX(arrtmax,LEN(arr1[i,1]))
  arrlmax:=MAX(arrlmax,arr1[i,3])
NEXT
lenght := arrlmax + arrtmax + 3     // Длина наибольшей строки экрана
col    := INT((80-lenght)/2)-1
row    := INT((25-lenarr+1)/2)-1
ss     := SAVESCREEN(row,col,row+lenarr+2,col+lenght+5)

SETCOLOR('w+/bg,w+/n,,,w+/bg')
@row,col,row+lenarr+1,col+lenght+3 BOX B_DOUBLE+" " COLOR "gr+/BG"
FOR i=1 TO lenarr
    @ row+i,col+2 SAY PADR(arr1[i,1],arrtmax)+ ': '
    @ row+i,col+arrtmax+4 SAY arr1[i,2]  PICTURE  REPLICATE('9',arr1[i,3])
NEXT
SET(_SET_ESCAPE,.T.)
FOR i=1 TO lenarr

// _1:='arr1['+str(i)+',2]'
// _2:='arr1['+str(i)+',3]'
// _3:='arr1['+str(i)+',4]'

@ row+i,col+arrtmax+4 GET arr1[i][2] VALID EVAL(arr1[i][4])
READ
IF LASTKEY()==K_ESC.OR.LASTKEY()==K_F12
  EXIT
ENDIF
IF LASTKEY()==K_UP.AND.i<>1
  i--
  LOOP
ENDIF

NEXT

p_help_code := HELPCODE
p_help_code := oldhelpcode

RESTSCREEN(row,col,row+lenarr+2,col+lenght+5,ss)
SETCOLOR(co)
SET(_SET_ESCAPE,se)
READEXIT(re)
SETKEY(K_F9,bAction)

#undef HELPCODE

RETURN NIL
FUNCTION  Warr1(c)
   LOCAL a := {}
        AADD(a,;
        {"Hомер пачки",0,3,{||.T.}})
    DO CASE
      CASE c=="01".OR.c=="02"
        AADD(a,;
        {"Код структурного подразделения",SPACE(2),2,{||sp01->(sp_vl("SP01","2"))}})
        AADD(a,;
        {"Шифр затрат",SPACE(7),7,{||SP44->(sp_vl('SP44',"2"))}})
        AADD(a,;
        {"Вид работ",SPACE(3),3,{||sp06->(sp_vl('SP06',"2"))}})
        AADD(a,;
        {"Код оплат",SPACE(3),3,{||Sp08->(sp_vl('SP08',"2"))}})
        AADD(a,;
        {"Дата",CTOD(SPACE(8)),8,{||.T.}})
      CASE c=="03"
        AADD(a,;
        {"Дата",CTOD(SPACE(8)),8,{||.T.}})
        AADD(a,;
        {"Шифр затрат",SPACE(7),7,{||SP44->(sp_vl('SP44',"2"))}})
        AADD(a,;
        {"Код оплат",SPACE(3),3,{||Sp08->(sp_vl('SP08',"2"))}})
      CASE c=="11"
        AADD(a,;
        {"Код структурного подразделения",SPACE(2),2,{||sp01->(sp_vl("SP01","2"))}})
        AADD(a,;
        {"Код отпpавителя",SPACE(2),2,{||Sp02->(sp_vl("SP02","2"))}})
        AADD(a,;
        {"Код получателя",SPACE(2),2,{||Sp02->(sp_vl("SP02","2"))}})
        AADD(a,;
        {"Код опеpации",SPACE(2),2,{||Sp05->(sp_vl("SP05","2"))}})
        AADD(a,;
        {"Код учета (дебет) ",SPACE(7),7,{||SP44->(sp_vl('SP44',"2"))}})
        AADD(a,;
        {"Код учета (кpедит)",SPACE(7),7,{||SP44->(sp_vl('SP44',"2"))}})
        AADD(a,;
        {"Дата",CTOD(SPACE(8)),8,{||.T.}})
      CASE c=="12"
        AADD(a,;
        {"Код опеpации",SPACE(2),2,{||Sp05->(sp_vl("SP05","2"))}})
        AADD(a,;
        {"Код отпpавителя",SPACE(2),2,{||Sp02->(sp_vl("SP02","2"))}})
        AADD(a,;
        {"Код структурного подразделения",SPACE(2),2,{||sp01->(sp_vl("SP01","2"))}})
        AADD(a,;
        {"Дата",CTOD(SPACE(8)),8,{||.T.}})
ENDCASE
RETURN a
