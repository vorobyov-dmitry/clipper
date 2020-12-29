#include "new.ch"
MEMVAR m_temppath,m_mash,p_npr,m_sprpath,m_mainpath,m_syspath,m_oper
MEMVAR m_bufpath,m_uchpath
#define Y_NAIM  1
#define Y_TABN  32
#define Y_KOPU  39
#define Y_NPCH  44
#define Y_OTDN  51
#define Y_OTHS  57
#define Y_STM   63
#define Y_OTDN1 48
#define Y_OTHS1 56
#define Y_STM1  63
// комментарий
Function MN01
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL n       :=0,k1                  // Номер записи для возвращения в случае неудачного LOCATE
  LOCAL  m_proc1 :=0,m_otdn0 :=0,m_oths0 :=0
  LOCAL  m_stm0  :=0,m_otdn1 :=0,m_oths1 :=0
  LOCAL  m_stm1  :=0
  LOCAL  m_tabn  :=0,m_ndoc,m_type:=1,m_month,i,m_gauge,m_gauge1
  LOCAL  m_kass,m_otdnk:=0,m_othsk:=0,m_stmk:=0,m_path,l_finish:=.f.
  m_month:=GetMonth()
  IF m_month==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS("  1"));m_type:=Msh->type
IF .NOT.GetType(@m_type,"  1")
    CLOSE msh
    return .f.
ENDIF
CrStruct("MASH01","buf01")

USE (m_temppath+"buf01") NEW ALIAS buf
INDEX ON buf->tabn+buf->npch+buf->kopu to (m_temppath+"buf01")
m_gauge:=InitGauge("Розрахунок машинограми N 1",1)

NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
m_path:=m_bufpath
FOR k1:=1 TO 2
NET USE (m_path+"fz3") NEW READONLY
NET USE (m_path+"fz2") NEW READONLY
NET USE (m_path+"fz1") NEW READONLY
  DO WHILE .NOT.fz1->(EOF())
      IF mnt_month(fz1->mnt) == m_month
        IF pFilpoz("fz2","vnum1","fz1")
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF fz1->vdoc<>38     // В документе должна быть запись в fz3
               IF .NOT.pFilpoz("fz3","vnum2","fz2")
                  SKIP 1 ALIAS fz2
                  LOOP
               ENDIF
               l_first :=.t.
               DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())
                  IF .NOT.buf->(DBSEEK(fz2->tabn+STR(fz1->npch,3)+fz3->kopu))
                     buf->(DBAP())
                     buf->npch:=STR(fz1->npch,3)
                     buf->tabn:=fz2->tabn
                     IF m_type==1;sp10->(DS(fz2->tabn));buf->kass:=sp10->kass;ENDIF
                     buf->kopu:=fz3->kopu
                  ENDIF
                  buf->sum+=fz3->sum
                  IF AT(ALLTRIM(STR(fz1->ndoc))+",",buf->ndoc)==0
                    buf->ndoc:=ALLTRIM(buf->ndoc)+ALLTRIM(STR(fz1->ndoc))+","
                  ENDIF
                  IF l_first
                     buf->otdn+=fz2->otdn
                     buf->oths+=fz2->oths
                  ENDIF

                  IF .NOT.buf->(DBSEEK(fz2->tabn+"   "+REPLICATE(CHR(2),3)))
                    buf->(DBAPPEND())
                    buf->npch:="    "
                    buf->tabn:=fz2->tabn
                    IF m_type==1
                      sp10->(DS(fz2->tabn));buf->kass:=sp10->kass
                    ENDIF
                    buf->kopu:=REPLICATE(CHR(2),3)
                   ENDIF
                  buf->sum+=fz3->sum
                  IF l_first
                     l_first := .f.
                     buf->otdn+=fz2->otdn
                     buf->oths+=fz2->oths
                  ENDIF
                  fz3->(DBSKIP())
               ENDDO
            ELSE
               IF buf->(DS(fz2->tabn+STR(fz1->npch,3)+'000'))
                  buf->(DBAP())
                  buf->npch:=STR(fz1->npch,3)
                  buf->tabn:=fz2->tabn
                  IF m_type==1;sp10->(DS(fz2->tabn));buf->kass:=sp10->kass;ENDIF
                  buf->kopu:="000"
               ENDIF
                buf->otdn+=fz2->otdn
                buf->oths+=fz2->oths
                  IF .NOT.buf->(DBSEEK(fz2->tabn+"   "+REPLICATE(CHR(2),3)))
                    buf->(DBAPPEND())
                    buf->npch:="   "
                    buf->tabn:=fz2->tabn
                    IF m_type==1;sp10->(DS(fz2->tabn));buf->kass:=sp10->kass;ENDIF
                    buf->kopu:=REPLICATE(CHR(2),3)
                    ENDIF
                    buf->otdn+=fz2->otdn
                    buf->oths+=fz2->oths
            ENDIF
            fz2->(DBSKIP())
         ENDDO
        ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fz1->(DBSKIP())
     m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
  CLOSE base FZ1,FZ2,FZ3
  m_path:=m_mainpath
NEXT
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  sele buf
  IF m_type==1
    INDEX ON buf->kass+buf->tabn+buf->kopu+buf->npch to (m_temppath+"buf")
  ENDIF
  buf->(DBGOTOP())
  m_otdn0:=m_oths0:=m_stm0:= 0
  SET PRINTER TO (m_mash+"01.txt")
  SET DEVICE TO PRINTER
  n := buf->(LASTREC())
  i:= 1
  m_gauge1:=InitGauge("Вивiд  машинограми N 1",2)
  m_kass:=buf->kass
  DO WHILE .NOT.buf->(EOF())
      m_otdn1 := m_oths1 := m_stm1  := 0
      m_tabn  := buf->tabn
      l_first=.t.
      DO WHILE buf->tabn == m_tabn.AND..NOT.buf->(EOF())
         IF l_first
            Sp10->(DS(buf->tabn))
            @PROW()+1,Y_NAIM SAY SUBSTR(TRIM(SP10->FAM)+' '+TRIM(SP10->IMJA)+' '+TRIM(SP10->OTCH),1,30)
            @PROW(),Y_TABN SAY buf->tabn
            @PROW(),Y_OTDN SAY buf->otdn PICTURE '999.9'
            @PROW(),Y_OTHS SAY buf->oths PICTURE '99999'
            @PROW(),Y_STM  say SumToStr(buf->sum,10)
            l_first=.f.
         ELSE
             @PROW()+1,0 SAY ''
             m_ndoc:=ALLTRIM(buf->ndoc)
             IF LEN(m_ndoc)>33
              m_ndoc:=SUBSTR(m_ndoc,1,33)
              m_ndoc:=SUBSTR(m_ndoc,1,RAT(",",m_ndoc)-1)+"**"
            ENDIF
            m_ndoc:=SUBSTR(m_ndoc,1,LEN(m_ndoc)-1)
             @PROW(),4  SAY m_ndoc
             @PROW(),Y_KOPU SAY buf->kopu
             @PROW(),Y_NPCH SAY buf->npch
             @PROW(),Y_OTDN SAY buf->otdn PICTURE '999.9'
             @PROW(),Y_OTHS SAY buf->oths PICTURE '99999'
             @PROW(),Y_STM  say SumToStr(buf->sum,10)
             m_otdn1 +=buf->otdn
             m_oths1 +=buf->oths
             m_stm1  +=buf->sum
             m_otdnk +=buf->otdn
             m_othsk +=buf->oths
             m_stmk  +=buf->sum
         ENDIF
         buf->(DBSKIP())
         i++
      ENDDO
      m_gauge1:=DispGauge(m_gauge1,i/n)
      m_otdn0 += m_otdn1
      m_oths0 += m_oths1
      m_stm0  += m_stm1
      IF m_kass<>buf->kass.AND.m_type==1
          @ PROW()+1,2        SAY 'Разом по касиру'
          @ PROW(),PCOL()+2   SAY m_otdnk PICTURE '999999.9'
          @ PROW(),PCOL()+2   SAY m_othsk PICTURE '9999999'
          @ PROW(),PCOL()+2   SAY SumToStr(m_stmk,14)
          IF .NOT.buf->(EOF())
              @PROW()+1,0 SAY "$"
              m_kass:=buf->kass
              m_otdnk:=m_othsk:=m_stmk:=0
          ENDIF
      ENDIF
  ENDDO
  @ PROW()+1,0 SAY   '*** РАЗОМ ПО ПIДПРИЄМСТВУ**'
  @ PROW(),PCOL()+2  SAY M_OTDN0 PICTURE '999999.9'
  @ PROW(),PCOL()+2  SAY M_OTHS0 PICTURE '9999999'
  @ PROW(),PCOL()+2  SAY SumToStr(M_STM0,14)
  @ PROW()+1,0 SAY   ''
  Dobms(STRZERO(m_month,2),STRZERO(m_month,2))
  SET PRINTER TO
  SET DEVICE TO SCREEN
  DelGauge(m_gauge1)
ENDIF
DelGauge(m_gauge)
CLOSE base sp10,msh,buf
RETURN .t.
#undef Y_NAIM
#undef Y_TABN
#undef Y_KOPU
#undef Y_NPCH
#undef Y_OTDN
#undef Y_OTHS
#undef Y_STM
#undef Y_OTDN1
#undef Y_OTHS1
#undef Y_STM1


Function mn02
  LOCAL i,m_month,l_finish:=.f.,m_gauge,m_gauge1
  LOCAL m_kass,m_type,m_sum1,m_otdn1,m_oths1,m_otdn2,m_oths2,m_sum2
  LOCAL m_sum1a,m_month1,x1,x2,m_097,m_110,s_month,m_078
  LOCAL m_month02,m_month03
  i:=GetMonth2(@x1,@x2)
  IF i==0
    RETURN .f.
  ENDIF
  m_month:=STRZERO(x1,2)
  m_month1:=STRZERO(x2,2)
  m_month02:=STRZERO(x1-1,2)
  m_month03=STRZERO(x2-1,2)
  NET USE (m_mainpath+"flish") NEW
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS("  2"));m_type:=Msh->type
  GetType(@m_type,"  2")
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  m_097 :=RESTVAR1("m_097","ZR")
  m_110 :=RESTVAR1("m_110","ZR")
  m_078 :=RESTVAR1("m_078","ZR")
CLOSE myvar
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08")  NEW READONLY
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
CrStruct("MASH02","buf02")
USE (m_temppath+"buf02") NEW ALIAS buf02
INDEX ON buf02->kass+buf02->kopu+buf02->st+buf02->month TO (m_temppath+"buf02")
m_gauge:=InitGauge("Розрахунок машинограми N 2",1)
DO WHILE .not.Flish->(EOF())
 IF m_month>=Flish->month.AND.Flish->month>=m_month1
  IF SP10->(DS(Flish->tabn))
    m_kass:=Sp10->kass
  ELSE
    m_kass:="її"
  ENDIF
  s_month:=IF(m_month==Flish->month,mnt_smonth(flish->mnt),'  ')
  FOR i:=1 TO 2
   IF .NOT.buf02->(DS(m_kass+flish->kopu+flish->st+s_month))
      buf02->(DBAP())
      buf02->kass:=m_kass
      buf02->st:=flish->st
      buf02->kopu:=flish->kopu
      buf02->month:=s_month
/*      IF buf02->month<>"  ".AND.buf02->month<>"06"
          @4,1 SayDisp "["+buf02->month+"]" COLOR "w/N"
          @1,1 SAYDisp flish->(recno())     COLOR "w/N"
          @2,1 SAYDisp  "["+flish->mnt+"]"   COLOR "w/N"
          @3,1 SayDisp  "["+mnt_smonth(flish->mnt)+"]"  COLOR "w/N"
          INKEY(5)
      ENDIF */
    ENDIF
    IF m_month==Flish->month
      buf02->sum1+=Flish->sum
      IF sp10->kpn=="6".OR.Sp10->kpn=="7"
        buf02->sum1a+=Flish->sum
      ENDIF
      buf02->otdn1+=Flish->otdn
      buf02->oths1+=Flish->oths
    ENDIF

   IF .NOT.buf02->(DS(m_kass+flish->kopu+flish->st+"  "))
      buf02->(DBAP())
      buf02->kass:=m_kass
      buf02->st:=flish->st
      buf02->kopu:=flish->kopu
    ENDIF
    IF buf02->kopu<>m_110.AND.buf02->kopu<>m_097
      buf02->sum2+=Flish->sum
      buf02->otdn2+=Flish->otdn
      buf02->oths2+=Flish->oths
    ENDIF
     m_kass:=CHR(255)+CHR(255)
  NEXT
  IF INKEY()==K_ESC
    IF ANSWERu("Прервати вивiд?")==YES
      l_finish:=.t.
      EXIT
    ENDIF
  ENDIF
 ENDIF

IF m_month02>=Flish->month .AND.m_month03<=Flish->month.AND.flish->kopu=='800'
   		IF SP10->(DS(Flish->tabn))
  			m_kass:=Sp10->kass
  		ELSE
  			m_kass:="її"
  		ENDIF
  		// s_month:=STRZERO( VAL(Flish->month)+1,2)
  	FOR i:=1 TO 2
        IF .NOT.buf02->(DS(m_kass+"850"+flish->st+"  "))
          buf02->(DBAP())
          buf02->kass:=m_kass
          buf02->st:=flish->st
          buf02->kopu:="850"
          // buf02->month:="  "
        ENDIF
        IF Flish->month==m_month02
          buf02->sum1+=Flish->sum
        ENDIF
         buf02->sum2+=Flish->sum
         m_kass:=CHR(255)+CHR(255)
        NEXT
ENDIF

IF flish->kopu==m_078.AND.m_month>=Flish->month.AND.Flish->month>=m_month1
   		IF SP10->(DS(Flish->tabn))
  			m_kass:=Sp10->kass
  		ELSE
  			m_kass:="її"
  		ENDIF
  		// s_month:=STRZERO( VAL(Flish->month)+1,2)
  		FOR i:=1 TO 2
        IF .NOT.buf02->(DS(m_kass+"850"+flish->st+"  "))
          buf02->(DBAP())
          buf02->kass:=m_kass
          buf02->st:=flish->st
          buf02->kopu:="850"
          // buf02->month:="  "
        ENDIF
        IF Flish->month==m_month
          buf02->sum1-=Flish->sum
        ENDIF
         buf02->sum2-=Flish->sum
         m_kass:=CHR(255)+CHR(255)
        NEXT
	ENDIF

 Flish->(DBSKIP())
 m_gauge:=DispGauge(m_gauge,flish->(RECNO())/flish->(LASTREC()))
ENDDO
IF .not.l_finish
m_gauge:=DispGauge(m_gauge,1.00)
m_gauge1:=InitGauge("Вивiд  машинограми N 2",2)
SET PRINTER TO (m_mash+"02.txt")
SET DEVICE TO PRINTER
IF m_type==1
  buf02->(DBGOTOP())
ELSE
  BUf02->(DS(CHR(255)+CHR(255)))
ENDIF
m_kass:=CHR(30)+CHR(30)
i:=1
DO WHILE .NOT.buf02->(EOF())
  IF m_kass<>buf02->kass
    DO CASE
      CASE buf02->kass==CHR(255)+CHR(255)
        @PROW()+1,0 Say "Звiт по пiдприємству "+p_npr
      CASE buf02->kass=="її"
        @PROW()+1,0 Say "Звiт по невизначених таб. номерах "
      OTHERWISE
        @PROW()+1,0 Say "Звiт по касиру N "+buf02->kass
    ENDCASE
    m_kass:=buf02->kass
  ENDIF
  m_sum1a:=m_sum1:=m_otdn1:=m_oths1:=m_otdn2:=m_oths2:=m_sum2:=0
  DO WHILE .NOT.buf02->(EOF()).AND.m_kass==buf02->kass.AND.buf02->kopu<"100"
    @PROW()+1,0 SAY buf02->month
    @PROW(),4 SAY buf02->kopu
    Sp08->(DS(buf02->kopu))
    @PROW(),10 SAY Sp08->name8
    IF buf02->otdn1<>0
      @PROW(),33 SAY NumToStr(buf02->otdn1,9,1)
    ENDIF
    IF buf02->oths1<>0
      @PROW(),43 SAY NumToStr(buf02->oths1,10)
    ENDIF
    @PROW(),54 SAY SumToStr(buf02->sum1,13)
    IF buf02->sum1a<>0
      @PROW(),68 SAY SumToStr(buf02->sum1a,10)
    ENDIF
    IF buf02->otdn2<>0
      @PROW(),79 SAY NumToStr(buf02->otdn2,9,1)
    ENDIF
    IF buf02->oths2<>0
      @PROW(),89 SAY NumToStr(buf02->oths2,10)
    ENDIF
    @PROW(),100 SAY SumToStr(buf02->sum2,14)
    m_sum1 +=buf02->sum1
    m_sum1a+=buf02->sum1a
    m_otdn1+=buf02->otdn1
    m_oths1+=buf02->oths1
    m_otdn2+=buf02->otdn2
    m_oths2+=buf02->oths2
    m_sum2 +=buf02->sum2
    buf02->(DBSKIP())
    m_gauge1:=DispGauge(m_gauge1,i++/buf02->(LASTREC()))
  ENDDO
  @PROW()+1,0 SAY "Разом нарахувань"
    @PROW(),33 SAY NumToStr(m_otdn1,9,1)
    @PROW(),43 SAY NumToStr(m_oths1,10)
    @PROW(),54 SAY SumToStr(m_sum1,13)
    @PROW(),68 SAY SumToStr(m_sum1a,10)
    @PROW(),79 SAY NumToStr(m_otdn2,9,1)
    @PROW(),89 SAY NumToStr(m_oths2,10)
    @PROW(),100 SAY SumToStr(m_sum2,14)
  m_sum1a:=m_sum1:=m_otdn1:=m_oths1:=m_otdn2:=m_oths2:=m_sum2:=0
  DO WHILE .NOT.buf02->(EOF()).AND.m_kass==buf02->kass.AND.buf02->kopu<"500"
    @PROW()+1,0 SAY buf02->month
    @PROW(),4 SAY buf02->kopu
    @PROW(),8  SAY buf02->st
    Sp08->(DS(buf02->kopu))
    @PROW(),10 SAY Sp08->name8
    IF buf02->oths1<>0
      @PROW(),33 SAY NumToStr(buf02->oths1,7)
    ENDIF
    IF buf02->otdn1<>0
      @PROW(),43 SAY NumToStr(buf02->otdn1,10,2)
    ENDIF
    @PROW(),54 SAY SumToStr(buf02->sum1,13)
    IF buf02->sum1a<>0
      @PROW(),68 SAY SumToStr(buf02->sum1a,10)
      m_sum1a+=buf02->sum1a
    ENDIF
    IF buf02->oths2<>0
      @PROW(),79 SAY NumToStr(buf02->oths2,7)
    ENDIF
    IF buf02->otdn2<>0
      @PROW(),89 SAY NumToStr(buf02->otdn2,10,2)
    ENDIF
    @PROW(),100 SAY SumToStr(buf02->sum2,14)
    IF buf02->st<>"*"
      m_sum1 +=buf02->sum1
      m_otdn1+=buf02->otdn1
      m_oths1+=buf02->oths1
      m_otdn2+=buf02->otdn2
      m_oths2+=buf02->oths2
      m_sum2 +=buf02->sum2
    ENDIF
    buf02->(DBSKIP())
    m_gauge1:=DispGauge(m_gauge1,i++/buf02->(LASTREC()))
  ENDDO
  @PROW()+1,0 SAY "Разом утримань"
    @PROW(),33 SAY NumToStr(m_oths1,7)
    @PROW(),43 SAY NumToStr(m_otdn1,10,2)
    @PROW(),54 SAY SumToStr(m_sum1,13)
    @PROW(),68 SAY SumToStr(m_sum1a,10)
//  @PROW(),76 SAY NumToStr(m_oths2,7)
//    @PROW(),86 SAY NumToStr(m_otdn2,10,2)
    @PROW(),100 SAY SumToStr(m_sum2,14)
  DO WHILE .NOT.buf02->(EOF()).AND.m_kass==buf02->kass
    @PROW()+1,0 SAY buf02->month
    @PROW(),4 SAY buf02->kopu
    Sp08->(DS(buf02->kopu))
    @PROW(),10 SAY Sp08->name8
    @PROW(),54 SAY SumToStr(buf02->sum1,13)
    @PROW(),68 SAY SumToStr(buf02->sum1a,10)
    @PROW(),100 SAY SumToStr(buf02->sum2,14)
    buf02->(DBSKIP())
    m_gauge1:=DispGauge(m_gauge1,i++/buf02->(LASTREC()))
  ENDDO
  IF m_kass<>buf02->kass.AND..NOT.buf02->(EOF())
    @PROW()+1,0 SAY "$"
  ENDIF
  IF INKEY()==K_ESC
    IF ANSWERu("Прервати вивiд?")==YES
      l_finish:=.t.
      EXIT
    ENDIF
  ENDIF
ENDDO
ENDIF
CLOSE BASE flish,sp08,msh,buf02,sp10
Dobms(m_month,m_month1)
SET DEVICE TO SCREEN
SET PRINTER TO
RETURN .t.
STATIC Function GetType(m_type1,m_num)
LOCAL m_key
SavePar()
@11,15,14,65 BOX B_DOUBLE+" " COLOR "w/b"
@12,16 SayDisp "По касирах      " COLOR "w/b"
@13,16 SayDisp "По пiдприємству "           COLOR "w/b"
DO WHILE .t.
@11+m_type1,32 SayDisp "√"  COLOR ("n/w")
  m_key:=INKEY(0)
@11+m_type1,32 SayDisp " "  COLOR "w/b"
  DO CASE
    CASE m_key==K_ENTER
        msh->(DS(m_num))
      IF msh->(NetRlock())
        Msh->type:=m_type1
        msh->(dbunlock())
      ENDIF
      EXIT
    CASE m_key==K_ESC
      EXIT
    CASE m_key==K_UP
       m_type1:=IF(m_type1==1,2,m_type1-1)
    CASE m_key==K_DOWN
          m_type1:=IF(m_type1==2,1,m_type1+1)
  ENDCASE
ENDDO
SavePar(1)
IF m_key==K_ESC
  RETURN .f.
ENDIF
RETURN .t.
STATIC Function GetType3(m_type1,m_num)
LOCAL m_key
SavePar()
@11,15,14,65 BOX B_DOUBLE+" " COLOR "w/b"
@12,16 SayDisp "По мiсяцю розрахунку " COLOR "w/b"
@13,16 SayDisp "По датi документа    " COLOR "w/b"
DO WHILE .t.
@11+m_type1,38 SayDisp "√"  COLOR ("n/w")
  m_key:=INKEY(0)
@11+m_type1,38 SayDisp " "  COLOR "w/b"
  DO CASE
    CASE m_key==K_ENTER
        msh->(DS(m_num))
      IF msh->(NetRlock())
        Msh->type:=m_type1
        msh->(dbunlock())
      ENDIF
      EXIT
    CASE m_key==K_ESC
      EXIT
    CASE m_key==K_UP
       m_type1:=IF(m_type1==1,2,m_type1-1)
    CASE m_key==K_DOWN
          m_type1:=IF(m_type1==2,1,m_type1+1)
  ENDCASE
ENDDO
SavePar(1)
IF m_key==K_ESC
  RETURN .f.
ENDIF
RETURN .t.
STATIC Function GetType2(m_type1,m_num)
LOCAL m_key
SavePar()
@11,15,15,65 BOX B_DOUBLE+" " COLOR "w/b"
@12,16 SayDisp "По касирах      " COLOR "w/b"
@13,16 SayDisp "По пiдприємству "           COLOR "w/b"
@14,16 SayDisp "По Ф.I.Б."           COLOR "w/b"
DO WHILE .t.
@11+m_type1,32 SayDisp "√"  COLOR ("n/w")
  m_key:=INKEY(0)
@11+m_type1,32 SayDisp " "  COLOR "w/b"
  DO CASE
    CASE m_key==K_ENTER.OR.m_key==K_ESC
        msh->(DS(m_num))
      IF msh->(NetRlock())
        Msh->type:=m_type1
        msh->(dbunlock())
      ENDIF
      EXIT
    CASE m_key==K_UP
       m_type1:=IF(m_type1==1,3,m_type1-1)
    CASE m_key==K_DOWN
          m_type1:=IF(m_type1==3,1,m_type1+1)
  ENDCASE
ENDDO
SavePar(1)
RETURN .t.
Function MN12
  LOCAL i:=1,m_choice,;
  a_choice:={"1 По алфавiту","2 По таб. номерах","3 По касирах i алфавiту","4 По касирах i таб.номерах"}
  LOCAL m_kassir
  NET USE (m_sprpath+"sp10") NEW READONLY
  SET FILTER TO sp10->kass<'90'
  m_choice:=mymenu("Вид сортировки",a_choice)
  DO CASE
    CASE m_choice==1
      INDEX on UPPER(SP10->fam+SP10->imja+SP10->otch) TO (m_temppath+"sp10a")
    CASE m_choice==2
      INDEX on SP10->tabn TO (m_temppath+"sp10a")
    CASE m_choice==3
      INDEX on sp10->kass+UPPER(SP10->fam+SP10->imja+SP10->otch) TO (m_temppath+"sp10a")
    CASE m_choice==4
      INDEX on sp10->kass+SP10->tabn TO (m_temppath+"sp10a")
    OTHERWISE
      CLOSE sp10
      RETURN .t.
  ENDCASE
  SET PRINTER TO (m_mash+"12.txt")
  SET DEVICE TO PRINTER

  DO WHILE .NOT.sp10->(EOF())
    m_kassir:=sp10->kass
    @PROW()+1,1 SAY I PICTURE "999"

    @PROW(),6 SAY Sp10->codn+" "
    @PROW(),18 SAY SUBSTR(ALLTRIM(SP10->fam)+' '+SUBSTR(SP10->imja,1,1)+'.'+SUBSTR(SP10->otch,1,1)+'.',1,23)
    @PROW(), 39 SAY "I"
    @PROW(), 41 SAY SP10->tabn
    @PROW(), 47 SAY "I"
    @PROW(), 58 SAY "I"
    @PROW(), 68 SAY "I"
    @PROW()+1,0 SAY REPLICATE ("-",75)
    i++
    sp10->(DBSKIP())
    IF m_kassir<>sp10->kass.AND.(m_choice==3.OR.m_choice==4).AND..NOT.sp10->(EOF())
      @PROW()+1,0 SAY "$"
      i:=1
    ENDIF
  ENDDO
  CLOSE sp10
   @ PROW()+1,0 SAY   ''
   Dobms(STRZERO(MONTH(DATE()),2),STRZERO(MONTH(DATE()),2))
   SET PRINTER TO
   SET DEVICE TO SCREEN
  RETURN .t.

  #define Y_TABN    1
  #define Y_FAM     7
  #define Y_DBTIN    35
  #define Y_CRTIN    47
  #define Y_DBT      59
  #define Y_CRT      71
  #define Y_DBTOUT   83
  #define Y_CRTOUT   95
Function mn22
  LOCAL  m_gauge,m_gauge1,m_month,m_type,m_097,m_110,m_078,l_d52
  LOCAL  m_fshzp := 0   /*  */
  LOCAL  m_fcsh  := 0,m_kass,i   /*  */
  LOCAL  m_sum1db0 :=0,m_sum1dbk :=0,m_sum1cr0 :=0,m_sum1crk :=0
  LOCAL  m_sum2db0 :=0,m_sum2dbk :=0,m_sum2cr0 :=0,m_sum2crk :=0
  LOCAL  m_sum3db0 :=0,m_sum3dbk :=0,m_sum3cr0 :=0,m_sum3crk :=0
  LOCAL   m_sum1db1 := 0,m_sum1cr1 := 0,m_sum2db1 := 0
  LOCAL   m_sum2cr1 := 0,m_sum3db1 := 0,m_sum3cr1 := 0
  LOCAL   x := 0, m_screen:=''

  i:=GetMonth()
  IF i==0;RETURN .f.;ENDIF
  m_month:=STRZERO(i,2)
  NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  m_097 :=RESTVAR1("m_097","ZR")
  m_110 :=RESTVAR1("m_110","ZR")
  m_078 :=RESTVAR1("m_078","ZR")
  l_d52 :=RESTVAR1("l_d52","ZR")
  CLOSE myvar
  NET USE (m_mainpath+"flish") NEW
  USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 22"));m_type:=Msh->type
  GetType(@m_type," 22")
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
  CrStruct("MASH22","buf22")
USE (m_temppath+"buf22") NEW ALIAS buf
INDEX ON buf->kass+buf->tabn TO (m_temppath+"buf")
m_gauge:=InitGauge("Розрахунок машинограми",1)
/*
@04,10 SAY m_097 COLOR "GR+/R"
@04,20 SAY m_110 COLOR "GR+/R"
@04,30 SAY m_078 COLOR "GR+/R"
*/
DO WHILE .NOT. FLISH->(EOF())
 IF m_month == flish->month.AND.Flish->st<>"*".AND.flish->st<>"!"
  IF SP10->(DS(Flish->tabn))
    m_kass:=Sp10->kass
  ELSE
    m_kass:="її"
  ENDIF
  IF .NOT.buf->(DS(m_kass+flish->tabn))
   buf->(DBAP())
   buf->tabn:=flish->tabn
   buf->kass:=m_kass
  ENDIF
  IF flish->kopu == m_097.OR. flish->kopu == m_078
   buf->sumin-=flish->sum
  ELSE
   IF flish->kopu == m_110
    buf->sumin+=flish->sum
   ELSE
    IF flish->kopu < '100'
     buf->sumcrt+=flish->sum
    ELSE
     IF flish->kopu <='500'
      buf->sumdbt+=flish->sum
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 flish->(DBSKIP())
 m_gauge:=DispGauge(m_gauge,flish->(RECNO()/LASTREC()))
ENDDO
m_gauge:=DispGauge(m_gauge,1)
//Cчет закончен
CLOSE flish
buf->(DBGOTOP())
m_sum1db0 :=m_sum1cr0 :=m_sum2db0 :=m_sum2cr0 :=m_sum3db0 :=m_sum3cr0 :=0
SET PRINTER TO (m_mash+"22.txt")
SET DEVICE TO PRINTER
m_fshzp := buf->(LASTREC())
m_fcsh  := 0
m_gauge1 := InitGauge(" Вивiд машинограми N 22",2)
m_kass:=buf->kass
IF m_type<>1
  SELECT buf
  INDEX ON buf->tabn TO (m_temppath+"buf")
ENDIF
  buf->(DBGOTOP())
DO WHILE .NOT.buf->(EOF())
 m_gauge1:=DispGauge(m_gauge1, m_fcsh/m_fshzp)
 m_fcsh++
 m_sum1db1 :=  m_sum1cr1 :=  m_sum2db1 :=  m_sum2cr1 :=  m_sum3db1 :=  m_sum3cr1 := 0
  @PROW()+1,Y_TABN SAY buf->tabn
  @PROW(),Y_FAM  SAY LEFT(_fio(buf->tabn),20)
  IF buf->sumin>0
   @PROW(),Y_DBTIN SAY SumToStr(buf->sumin,11)
   m_sum1dbk := m_sum1dbk+buf->sumin
   m_sum1db0 := m_sum1db0+buf->sumin
  ELSE
   @PROW(),Y_CRTIN SAY SumToStr(ABS(buf->sumin),11)
   m_sum1crk := m_sum1crk-buf->sumin
   m_sum1cr0 := m_sum1cr0-buf->sumin
  ENDIF
  @PROW(),Y_DBT SAY SumToStr(buf->sumdbt,11)
  @PROW(),Y_CRT SAY SumToStr(buf->sumcrt,11)
  m_sum2dbk := m_sum2dbk+buf->sumdbt
  m_sum2crk := m_sum2crk+buf->sumcrt
  m_sum2db0 := m_sum2db0+buf->sumdbt
  m_sum2cr0 := m_sum2cr0+buf->sumcrt
  x:=ROUND(buf->sumin+buf->sumdbt-buf->sumcrt,2)
  if x>0
   @PROW(),Y_DBTOUT SAY SumToStr(X,11)
   m_sum3db0 := m_sum3db0+x
   m_sum3dbk := m_sum3dbk+x
  ELSE
   @PROW(),Y_CRTOUT SAY SumToStr(ABS(X),11)
   m_sum3cr0 := m_sum3cr0-x
   m_sum3crk := m_sum3crk-x
  ENDIF
 buf->(DBSKIP())
 IF m_kass<>buf->kass.AND.m_type==1
    @PROW()+1,0      SAY 'РАЗОМ по касиру'
    @PROW(),Y_DBTIN  SAY SumToStr(m_sum1dbk,13)
    @PROW(),Y_DBT    SAY SumToStr(m_sum2dbk,13)
    @PROW(),Y_DBTOUT SAY SumToStr(m_sum3dbk,13)
    @PROW()+1,Y_CRTIN  SAY SumToStr(m_sum1crk,13)
    @PROW(),Y_CRT    SAY SumToStr(m_sum2crk,13)
    @PROW(),Y_CRTOUT SAY SumToStr(m_sum3crk,13)
    m_kass:=buf->kass
    m_sum1dbk :=m_sum1crk :=m_sum2dbk :=m_sum2crk :=m_sum3dbk := m_sum3crk :=0
 ENDIF
ENDDO
@PROW()+1,0 SAY 'РАЗОМ '
@PROW(),Y_DBTIN  SAY SumToStr(m_sum1db0,13)
@PROW(),Y_DBT    SAY SumToStr(m_sum2db0,13)
@PROW(),Y_DBTOUT SAY SumToStr(m_sum3db0,13)
@PROW()+1,Y_CRTIN  SAY SumToStr(m_sum1cr0,13)
@PROW(),Y_CRT    SAY SumToStr(m_sum2cr0,13)
@PROW(),Y_CRTOUT SAY SumToStr(m_sum3cr0,13)
@PROW()+1,0 SAY   ''
CLOSE base buf,msh
FERASE   (m_temppath+'buf.dbf')
FERASE   (m_temppath+'buf.ntx')
CLOSE Sp10
DelGauge(m_gauge1)
DelGauge(m_gauge)
Dobms(m_month,m_month)
SET DEVICE TO SCREEN
SET PRINTER TO
IF l_d52
  USE (m_mainpath+"d52") NEW
  DELETE FOR d52->month==VAL(m_month).AND.d52->subsch='700'
  APPEND BLANK
  REPLACE d52->month WITH VAL(m_month)
  REPLACE d52->sumd  WITH m_sum3db0
  REPLACE d52->sumc  WITH m_sum3cr0
  REPLACE d52->subsch  WITH '700'
  USE
ENDIF

RETURN .t.
  #undef Y_TABN
  #undef Y_FAM
  #undef Y_DBTIN
  #undef Y_CRTIN
  #undef Y_DBT
  #undef Y_CRT
  #undef Y_DBTOUT
  #undef Y_CRTOUT
FUNCTION eVodArenda ()
  LOCAL j:=SPACE(8),i
  i:=FOPEN(m_mainpath+CHR(92)+CHR(65)+CHR(84)+CHR(65)+CHR(66)+CHR(78)+CHR(46)+"D"+CHR(66)+"F",0)
  FSEEK(i,16)
  FREAD(i,@j,8)
  FCLOSE(i)
  IF j<>CHR(66)+CHR(79)+CHR(80)+CHR(79)+CHR(129)+CHR(156)+CHR(69)+CHR(66)
    BREAK
  ENDIF
RETURN .T.
Function Dobms(m_month,m_month1)
  @PROW()+1,0 SAY m_month+m_month1+m_oper+DTOS(DATE())+TIME()+"ZZ"
RETURN .t.
Function Dobms1(m_month,m_month1)
  ?m_month+m_month1+m_oper+DTOS(DATE())+TIME()+"ZZ"
RETURN .t.
FUNCTION eVod()
  LOCAL j:=SPACE(4),i,k,GetList:={}
  i:=FOPEN(m_mainpath+CHR(73)+CHR(68)+CHR(69)+CHR(78)+CHR(84)+"."+CHR(76)+CHR(83)+CHR(84),0)
  FREAD(i,@j,4)
  FCLOSE(i)
  IF j<>L2BIN(BIOSDATE()-CTOD("01/01/80"))
    DispError("Дана копiя програми; не зареєстрована")
    CLEAR
    @10,10,14,70 BOX B_DOUBLE+" " COLOR "GR+/bg"
    j:=INT(random()%100+1)
    @11,12 SayDisp "Введiть значення паролю("+STR(j,3)+")" COLOR "b/bg"
    @12,38 Get k PICTURE "9999"
    j:=INT(4*j-0.04*j*j)
    IF k<>j
      BREAK
    ENDIF
  ENDIF
RETURN .T.
Function CrStruct(m_name,m_file)
LOCAL a_struct:={}
  NET USE  (m_syspath+"Struct") INDEX (m_syspath+"Struct") NEW READONLY
  struct->(DS(m_name))
  DO WHILE .NOT.struct->(EOF()).AND.m_name==ALLTRIM(struct->name)
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
  DBCREATE(m_temppath+m_file,a_struct)
  CLOSE STRUCT
RETURN .T.
Function mn03
  LOCAL i,m_month:=0,l_finish:=.f.,m_gauge,m_gauge1
  LOCAL m_kass,m_type
  LOCAL m_kopu:="   ",m_month1:=0
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  m_month:=STRZERO(i,2)
  m_month1:=STRZERO(m_month1,2)
  NET USE (m_mainpath+"flish") NEW
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS("  3"));m_type:=Msh->type
  GetType(@m_type,"  3")
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08")  NEW READONLY
  m_kopu:=GetKopu()
  IF EMPTY(m_kopu)
    close sp08
    RETURN .F.
  ENDIF
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
  CrStruct("MS03","buf03")
  USE (m_temppath+"buf03") NEW ALIAS buf
  INDEX ON buf->tabn TO (m_temppath+"buf03")
  m_gauge:=InitGauge("Розрахунок машинограми N 3",1)
DO WHILE .not.Flish->(EOF())
 IF m_month>=Flish->month.AND.Flish->month>=m_month1.AND.flish->st<>"!".AND.flish->kopu==m_kopu
  IF .NOT.buf->(DS(flish->tabn))
    buf->(DBAP())
    buf->tabn:=flish->tabn
    buf->kopu:=m_kopu
    sp10->(DS(buf->tabn))
    buf->kass:=Sp10->kass
  ENDIF
  IF m_month==Flish->month
    buf->summ+=flish->sum
    buf->glvm+=flish->oths
    buf->kvom+=flish->otdn
  ENDIF
  buf->sumy+=flish->sum
  buf->glvy+=flish->oths
  buf->kvoy+=flish->otdn
  IF INKEY()==K_ESC
    IF ANSWERu("Прервати вивiд?")==YES
      l_finish:=.t.
      EXIT
    ENDIF
  ENDIF
 ENDIF
 Flish->(DBSKIP())
 m_gauge:=DispGauge(m_gauge,flish->(RECNO())/flish->(LASTREC()))
ENDDO
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  IF m_type==1
    INDEX ON buf->kass+buf->tabn TO (m_temppath+"buf03")
    FormMsh(SELECT("buf"),"03",m_month,m_month1)
  ENDIF
  IF m_type==2
    INDEX ON buf->tabn TO (m_temppath+"buf03")
    FormMsh(SELECT("buf"),"03A",m_month,m_month1)
  ENDIF
ENDIF
CLOSE BASE flish,sp08,msh,buf,sp10
RETURN .t.
STATIC Function GetKopu()
LOCAL m_kopu:="   ",GetList:={}
SavePar()
@11,15,14,65 BOX B_DOUBLE+" " COLOR "w/b"
@12,16 SayDisp "Виберiть код утримання" COLOR "w/b"
SET ESCAPE ON
@12,42 Get m_kopu VALID Sp08->(sp_vl("SP08")) COLOR "Gr+/n"
READ
IF LASTKEY()==K_ESC
  m_kopu:="   "
ENDIF
SAVEPAR(1)
RETURN m_kopu
#undef Y_NAIM
#undef Y_TABN
#undef Y_KOPU
#undef Y_NPCH
#undef Y_GLV
#undef Y_KVO
#undef Y_SUM
#undef Y_SUM1

#define Y_NAIM  1
#define Y_TABN  31
#define Y_KOPU  37
#define Y_NPCH  42
#define Y_GLV   48
#define Y_KVO   54
#define Y_SUM   64
#define Y_SUM1  67
Function MN04
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL n       :=0                  // Номер записи для возвращения в случае неудачного LOCATE
  LOCAL  m_sum0  :=0
  LOCAL  m_sum1  :=0
  LOCAL  m_tabn  :=0,m_ndoc,m_type:=1,m_month,i,m_gauge,m_gauge1
  LOCAL  m_kass,m_sumk:=0,m_path,l_finish:=.f.,k1
  LOCAL a_choice:={"Буферна база даних","Основна база даних"},m_month1
  m_month:=GetMonth()
  IF m_month==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS("  4"));m_type:=Msh->type
IF .NOT.GetType(@m_type,"  4")
    CLOSE msh
    return .f.
ENDIF
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY

CrStruct("MASH04","buf04")

USE (m_temppath+"buf04") NEW ALIAS buf
INDEX ON buf->tabn+buf->npch+buf->kopu to (m_temppath+"buf04")
m_gauge:=InitGauge("Розрахунок машинограми N 4",1)
m_path:=m_bufpath
FOR k1:=1 TO 2
NET USE (m_path+"fd2") NEW READONLY
NET USE (m_path+"fd1") NEW READONLY
  DO WHILE .NOT.fd1->(EOF())
      IF mnt_month(fd1->mnt) == m_month
        IF pFilpoz("fd2","vnuma","fd1")
         DO WHILE fd1->vnuma=fd2->vnuma.AND..NOT.fd2->(EOF())
            IF .NOT.buf->(DBSEEK(fd2->tabn+STR(fd1->npch,3)+fd1->kopu))
              buf->(DBAP())
              buf->npch:=STR(fd1->npch,3)
              buf->tabn:=fd2->tabn
              IF m_type==1;sp10->(DS(fd2->tabn));buf->kass:=sp10->kass;ENDIF
              buf->kopu:=fd1->kopu
            ENDIF
            buf->sum+=fd2->sum
            IF AT(ALLTRIM(STR(fd1->ndoc))+",",buf->ndoc)==0
              buf->ndoc:=ALLTRIM(buf->ndoc)+ALLTRIM(STR(fd1->ndoc))+","
            ENDIF
            buf->glv+=fd2->glv
            buf->kvo+=fd2->kvo
            IF .NOT.buf->(DBSEEK(fd2->tabn+"   "+REPLICATE(CHR(2),3)))
              buf->(DBAPPEND())
              buf->tabn:=fd2->tabn
              IF m_type==1;sp10->(DS(fd2->tabn));buf->kass:=sp10->kass;ENDIF
              buf->kopu:=REPLICATE(CHR(2),3)
            ENDIF
            buf->sum+=fd2->sum
            fd2->(DBSKIP())
         ENDDO
        ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fd1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fd1->(RECNO()/LASTREC()))
  ENDDO
CLOSE base Fd1,Fd2
  m_path:=m_mainpath
NEXT
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  m_gauge1:=InitGauge("Вивiд  машинограми N 4",2)
  SET PRINTER TO (m_mash+"04.txt")
  SET DEVICE TO PRINTER
  sele buf
  IF m_type==1
    INDEX ON buf->kass+buf->tabn+buf->kopu+buf->npch to (m_temppath+"buf04")
  ENDIF
  buf->(DBGOTOP())
  m_sum0:= 0
  n := buf->(LASTREC())
  i:= 0
  m_kass:=buf->kass
  DO WHILE .NOT.buf->(EOF())
      m_sum1  := 0
      m_tabn  := buf->tabn
      l_first=.t.
      DO WHILE buf->tabn == m_tabn.AND..NOT.buf->(EOF())
         IF l_first
            @PROW()+1,Y_NAIM SAY LEFT(_fio(buf->tabn),29)
            @PROW(),Y_TABN SAY buf->tabn
            @PROW(),Y_SUM  say SumToStr(buf->sum,10)
            l_first=.f.
         ELSE
             @PROW()+1,0 SAY ''
             m_ndoc:=ALLTRIM(buf->ndoc)
             IF LEN(m_ndoc)>33
              m_ndoc:=SUBSTR(m_ndoc,1,33)
              m_ndoc:=SUBSTR(m_ndoc,1,RAT(",",m_ndoc)-1)+"**"
            ENDIF
           m_ndoc:=SUBSTR(m_ndoc,1,LEN(m_ndoc)-1)
           @PROW(),4  SAY m_ndoc
           @PROW(),Y_KOPU SAY buf->kopu
           @PROW(),Y_NPCH SAY buf->npch
           @PROW(),Y_GLV  SAY NumToStr(buf->glv,5)
           @PROW(),Y_KVO  SAY NumToStr(buf->kvo,9,2)
           @PROW(),Y_SUM  say SumToStr(buf->sum,12)
           m_sum1  +=buf->sum
           m_sumk  +=buf->sum
         ENDIF
         buf->(DBSKIP())
         i++
      ENDDO
      m_sum0  += m_sum1
      m_gauge1:=DispGauge(m_gauge1,i/n)
      IF m_kass<>buf->kass.AND.m_type==1
          @ PROW()+1,2        SAY 'Разом по касиру'
          @ PROW(),PCOL()+2   SAY SumToStr(m_sumk,14)
          IF .NOT.buf->(EOF())
              @PROW()+1,0 SAY "$"
              m_kass:=buf->kass
              m_sumk:=0
          ENDIF
      ENDIF
  ENDDO
  @ PROW()+1,0 SAY   '***РАЗОМ ПО ПIДПРИЄМСТВУ**'
  @ PROW(),PCOL()+2  SAY SumToStr(m_sum0,14)
  @ PROW()+1,0 SAY   ''
  Dobms(STRZERO(m_month,2),STRZERO(m_month,2))
  SET PRINTER TO
  SET DEVICE TO SCREEN
  DelGauge(m_gauge1)
ENDIF
DelGauge(m_gauge)
CLOSE base sp10,msh,buf
RETURN .t.
#define RUSS 1
Function GetMonth2(m_month,m_month1)
LOCAL m_cur:=SaveCur()
LOCAL a_choice:={},i,m_color:=SETCOLOR("w+/b,n/w" ),m_choice,j
Local m_value:="",m_key
m_month1:=1
FOR i:=1 TO 12
  AADD(a_choice,PADR(STR(i,2)+" "+MyCmonth(i),16))
NEXT
DispBox(6,30,19,50,B_DOUBLE+" ","w/b")
@6,32 SayDisp IF(SetLang()<>1,"Выбор месяца","Вибiр мiсяця") Color "gr+/b"
i:=month(DATE())
i:=IF(i==1,12,i-1)
Shadow(6,30,19,50)
// m_choice:=ACHOICE(7,32,18,48,a_choice,,,i,0)
FOR j:=1 TO 12
  @6+j,32 SayDisp(a_choice[j]) COLOR IF(j<=i.AND.j>=m_month1,"n/w","W+/B")
NEXT
DO WHILE .T.
  @6+i,32 SayDisp(a_choice[i]) COLOR "n/w"
  m_key:=INKEY(0)
  @6+i,32 SayDisp(a_choice[i]) COLOR "w+/b"
  DO CASE
    case m_key==K_DOWN
      @6+i,32 SayDisp(a_choice[i]) COLOR "n/w"
      i:=IF(i==12,12,i+1)
    CASE m_key==K_CTRL_RET.AND.i=m_month1
       DO WHILE .T.
          @6+m_month1,32 SayDisp(a_choice[m_month1]) COLOR "N/BG"
          m_key:=INKEY(0)
          @6+m_month1,32 SayDisp(a_choice[m_month1]) COLOR "w+/b"
          DO CASE
            case m_key==K_DOWN
              m_month1:=IF(m_month1==12,12,m_month1+1)
            CASE m_key==K_UP
              m_month1:=IF(m_month1==1,1,m_month1-1)
            CASE m_key==K_ENTER.OR.m_key==K_ESC
              IF i<m_month1
                i:=m_month1
              ENDIF
              FOR j:=1 TO 12
              @6+j,32 SayDisp(a_choice[j]) COLOR IF(j<=i.AND.j>=m_month1,"n/w","W+/B")
              NEXT
              EXIT
          ENDCASE
        ENDDO
        LOOP
    CASE m_key==K_UP.AND.i>m_month1
      i:=IF(i==1,1,i-1)
    CASE m_key==K_ENTER
      m_choice:=i
      EXIT
    CASE m_key==K_ESC
      m_choice:=0
      EXIT
  ENDCASE
ENDDO
m_month:=i
RestCur()
SetColor(m_color)
RETURN m_choice
Function Mn07
  LOCAL m_month,i,n,m_gauge,m_gauge1
  LOCAL m_sum3:=0,m_sum4:=0,m_kopu,m_log
  m_month:=GetMonth()
  IF m_month==0
    RETURN .f.
  ENDIF
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
  NET USE (m_mainpath+"Fzn") NEW
  CrStruct("MASH07","buf07")
  USE (m_temppath+"buf07") NEW ALIAS buf
  INDEX ON buf->kopu+buf->log+buf->tabn  TO  (m_temppath+"buf07")
  m_gauge:=InitGauge("Розрахунок машинограми N 7",1)
  DO WHILE .NOT.fzn->(EOF())
    IF m_month==Fzn->month
      buf->(DBAP())
      buf->num    :=Fzn->num
      buf->tabn   :=Fzn->tabn
      buf->procent:=Fzn->procent
      buf->sum3   :=Fzn->sum3
      buf->sum4   :=Fzn->sum4
      buf->fam    :=Fzn->fam
      buf->kopu   :=Fzn->kopu
      buf->log    :=IF(fzn->sum4<>0,"1","0")
      buf->adr1  :=RTRIM(MEMOLINE(fzn->addr,80,1))
      buf->adr2  :=RTRIM(MEMOLINE(fzn->addr,80,2))
      buf->adr3  :=RTRIM(MEMOLINE(fzn->addr,80,3))
    ENDIF
    fzn->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fzn->(RECNO()/LASTREC()))

  ENDDO
  n:=buf->(LASTREC())
  i:=1
  m_gauge1:=InitGauge("Вивiд  машинограми N 7",2)
  buf->(DBGOTOP())
  SET PRINTER TO (m_mash+"07.txt")
  SET DEVICE TO PRINTER
  m_kopu:=buf->kopu;m_log:=buf->log
  m_sum3:=m_sum4:=0
  DO WHILE .NOT.buf->(EOF())
    @PROW()+1,1 SAY buf->num
    @PROW(),12 SAY buf->kopu
    @PROW(),17 SAY buf->procent PICTURE "99.9"
    @PROW(),22 SAY buf->tabn
    @PROW(),28 SAY LEFT(_fio(buf->tabn),19)
    @PROW(),48 SAY IF(EMPTY(buf->adr1),buf->fam,buf->adr1)
    @PROW(),78 SAY SumToStr(buf->sum3,9)
    @PROW(),88 SAY SumToStr(buf->sum4,9)
    @PROW(),98 SAY SumToStr(buf->sum4+buf->sum3,10)
    IF .NOT.EMPTY(buf->adr2);@PROW()+1,48 SAY buf->adr2;ENDIF
    IF .NOT.EMPTY(buf->adr3);@PROW()+1,48 SAY buf->adr3;ENDIF
    IF .NOT.EMPTY(buf->adr1);@PROW()+1,48 SAY buf->fam;ENDIF
    m_sum3+=buf->sum3
    m_sum4+=buf->sum4
    buf->(DBSKIP())
    IF buf->log<>m_log
        m_log:=buf->log
        @PROW()+1,0 SAY REPLICATE("-",110)
        @PROW()+1,70 SAY "Разом:"
        @PROW(),78 SAY SumToStr(m_sum3,9)
        @PROW(),88 SAY SumToStr(m_sum4,9)
        @PROW(),98 SAY SumToStr(m_sum4+m_sum3,10)
        m_sum3:=m_sum4:=0
        IF .NOT.buf->(EOF())
          @PROW()+1,0 SAY "$"
        ENDIF
    ENDIF
    IF buf->kopu<>m_kopu
        m_kopu:=buf->kopu;m_log:=buf->log
        @PROW()+1,0 SAY REPLICATE("-",110)
        @PROW()+1,70 SAY "Разом:"
        @PROW(),78 SAY SumToStr(m_sum3,9)
        @PROW(),88 SAY SumToStr(m_sum4,9)
        @PROW(),98 SAY SumToStr(m_sum4+m_sum3,10)
        m_sum3:=m_sum4:=0
        IF .NOT.buf->(EOF())
          @PROW()+1,0 SAY "$"
        ENDIF
    ENDIF
    m_gauge1:=DispGauge(m_gauge1,i++/n)
  ENDDO
  DelGauge(m_gauge1)
  Dobms(STRZERO(m_month,2),STRZERO(m_month,2))
  SET PRINTER TO
  SET DEVICE TO SCREEN
  CLOSE BASE fzn,buf,sp10
RETURN .t.
Function mn08
  LOCAL i,m_month:=0,m_gauge,m_gauge1
  LOCAL m_kass,m_type,m_sum
  LOCAL n
  LOCAL m_110:="   ",m_month1:=0
  m_month:=GetMonth()
  IF m_month==0
    RETURN .f.
  ENDIF
  m_month=m_month+1
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS("  8"));m_type:=Msh->type
  GetType2(@m_type,"  8")
  close msh
  NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  m_110 :=RESTVAR1("m_110","ZR")
  CLOSE myvar
  NET USE (m_mainpath+"flish") NEW
  NET USE (m_sprpath+"Sp10") INDEX (m_sprpath+"Sp10") NEW
  CrStruct("MASH08","buf08")
  USE (m_temppath+"buf08") NEW ALIAS buf
  INDEX ON buf->tabn to (m_temppath+"buf08")
  m_gauge:=InitGauge("Розрахунок вiдомостi боржникiв",1)
  DO WHILE .NOT.flish->(EOF())
    IF flish->month==STRZERO(m_month,2).AND.flish->kopu==m_110
      IF .NOT.buf->(DS(flish->tabn))
        buf->(DBAP())
        buf->tabn:=flish->tabn
        Sp10->(DS(buf->tabn))
        buf->kass := Sp10->kass
        buf->fiofull := _fiofull(buf->tabn)
      ENDIF
      buf->sum+=flish->sum
    ENDIF
    Flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,Flish->(RECNO()/LASTREC()))
  ENDDO
  SELE buf
  SET INDEX TO
  DO CASE
    CASE m_type==1
      INDEX on buf->kass+buf->tabn TO (m_temppath+"buf08")
    CASE m_type==2
      INDEX on buf->tabn TO (m_temppath+"buf08")
    CASE m_type==3
      INDEX on buf->fiofull TO (m_temppath+"buf08")
  ENDCASE
  m_gauge1:=InitGauge("Вивiд на диск",2)
  buf->(DBGOTOP())
  m_sum:=0
  SET PRINTER TO (m_mash+"08.txt")
  SET DEVICE TO PRINTER
  n := buf->(LASTREC())
  i:= 1
  DO WHILE .NOT.BUF->(EOF())
    @PROW()+1,1 SAY i PICTURE "999"
    @PROW(),7 SAY buf->tabn
    @PROW(),14 SAY LEFT(buf->fiofull,35)
    @PROW(),51 SAY SumToStr(buf->sum,10)
    m_sum+=buf->sum
    buf->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,i++/n)
  ENDDO
    @PROW()+1,49 SAY SumToStr(m_sum,12)
    Dobms(STRZERO(m_month,2),STRZERO(m_month,2))
    SET PRINTER TO
    SET DEVICE TO SCREEN
  CLOSE base flish,sp10,buf
RETURN .T.

Function mn13
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL n       :=0                  // Номер записи для возвращения в случае неудачного LOCATE
  LOCAL  m_proc1 :=0,m_otdn0 :=0,m_oths0 :=0,m_stm0  :=0
  LOCAL  m_otdn1 :=0,m_oths1 :=0,m_stm1  :=0,m_tabn  :=0,;
  m_ndoc,m_type:=1,m_month,i,m_gauge,m_gauge1,m_month1,m_sum:=0
  LOCAL  m_kass,m_otdnk:=0,m_othsk:=0,m_stmk:=0,m_path,l_finish:=.f.,x1,x2
  LOCAL b_block,B_BLOCK1
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 13"));m_type:=Msh->type
IF .NOT.  GetType3(@m_type," 13")
  CLOSE msh
  RETURN .f.
ENDIF
CrStruct("MASH13","buf13")

USE (m_temppath+"buf13") NEW ALIAS buf
INDEX ON buf->ksash+buf->vrab+buf->brgd to (m_temppath+"buf13")
m_gauge:=InitGauge("Розрахунок машинограми N 13",1)

NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44")  NEW READONLY
NET USE (m_sprpath+"sp01") INDEX (m_sprpath+"sp01")  NEW READONLY
NET USE (m_sprpath+"sp06") INDEX (m_sprpath+"sp06")  NEW READONLY
NET USE (m_mainpath+"fz3") NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
IF m_type==1
  b_block:={||IF(mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1,.t.,.f.)}
ELSE
  b_block:={||IF(month(fz1->ddoc) <= m_month.AND.month(fz1->ddoc)>=m_month1,.t.,.f.)}
ENDIF
  DO WHILE .NOT.fz1->(EOF())
      IF EVAL(b_block)
        IF pFilpoz("fz2","vnum1","fz1")
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
               IF fz1->vdoc<>38.AND..NOT.pFilpoz("fz3","vnum2","fz2")
                  SKIP 1 ALIAS fz2
                  LOOP
               ENDIF
                  IF .NOT.buf->(DBSEEK(fz2->ksash+fz2->vrab+fz2->brgd))
                     buf->(DBAP())
                     buf->ksash:=fz2->ksash
                     buf->subsch:=LEFT(fz2->ksash,3)
                     buf->sch   :=LEFT(fz2->ksash,2)
                     buf->vrab:=fz2->vrab
                     buf->brgd:=fz2->brgd
                  ENDIF
                 m_sum:=0
                DO WHILE fz2->vnum2=fz3->vnum2.AND..NOT.fz3->(EOF())
                  m_sum+=fz3->sum
                  fz3->(DBSKIP())
               ENDDO
               buf->sum4+=m_sum
               buf->otdn4+=fz2->otdn
                buf->oths4+=fz2->oths
                  DO CASE
                    CASE  fz1->vdoc >= 38 .AND. fz1->vdoc <= 44
                      buf->sum2+=m_sum
                      buf->otdn2+=fz2->otdn
                      buf->oths2+=fz2->oths
                    CASE  fz1->vdoc >= 34 .AND. fz1->vdoc <= 37
                      buf->sum3+=m_sum
                      buf->otdn3+=fz2->otdn
                      buf->oths3+=fz2->oths
                    OTHERWISE
                      buf->sum1+=m_sum
                      buf->otdn1+=fz2->otdn
                      buf->oths1+=fz2->oths
                   ENDCASE
            fz2->(DBSKIP())
         ENDDO
      ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fz1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
  CLOSE base FZ1,FZ2,FZ3

IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
//  INDEX ON buf->kass+buf->tabn TO (m_temppath+"buf03")
  FormMsh(SELECT("buf"),"13",STRZERO(m_month,2),STRZERO(m_month1,2))
  INDEX ON buf->vrab+buf->ksash+buf->brgd to (m_temppath+"buf13")
  buf->(DBGOTOP())
  FormMsh(SELECT("buf"),"14",STRZERO(m_month,2),STRZERO(m_month1,2))
  INDEX ON buf->brgd+buf->ksash+buf->vrab to (m_temppath+"buf13")
  buf->(DBGOTOP())
  FormMsh(SELECT("buf"),"15",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
DelGauge(m_gauge)
CLOSE base sp44,msh,buf,sp06,sp01
RETURN .t.
Function mn05
  LOCAL i,m_month:=0,l_finish:=.f.,m_gauge,m_gauge1
  LOCAL m_kass,m_type
  LOCAL m_month1:=0,s1
  LOCAL k_pen1,k_pen2,k_pod1,k_pod2
  LOCAL k_pen3,k_pen4,k_pen5

  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  m_month:=STRZERO(i,2)
  m_month1:=STRZERO(m_month1,2)
  NET USE (m_mainpath+"flish") NEW
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS("  5"));m_type:=Msh->type
  GetType(@m_type,"  5")
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
  CrStruct("MASH05","buf05")
  USE (m_temppath+"buf05") NEW ALIAS buf
  INDEX ON buf->codn TO (m_temppath+"buf05")
  m_gauge:=InitGauge("Розрахунок машинограми N 5",1)
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
k_zan   :=RESTVAR1("k_zan","ZR")
k_pen1  :=RESTVAR1("k_pen1","ZR")
k_pen2  :=RESTVAR1("k_pen2","ZR")
k_pen3  :=RESTVAR1("k_pen3","ZR")
k_pen4  :=RESTVAR1("k_pen4","ZR")
k_pen5  :=RESTVAR1("k_pen5","ZR")
k_pod1  :=RESTVAR1("k_pod1","ZR")
k_pod2  :=RESTVAR1("k_pod2","ZR")
 CLOSE myvar
s1:=k_pod1+",901,"+k_pod2+",902,"+k_pen1+",921"+k_pen2+",922,";
+k_pen3+",923,"+k_pen4+",924"+k_pen5+",925"
DO WHILE .not.Flish->(EOF())
 IF m_month>=Flish->month.AND.Flish->month>=m_month1.AND.AT(flish->kopu,s1)<>0
  Sp10->(DS(flish->tabn))
  IF .NOT.buf->(DS(Sp10->codn))
    buf->(DBAP())
    buf->tabn:=flish->tabn
    buf->codn:=sp10->codn
    buf->kod:=sp10->kpn+sp10->kmn
    buf->kass:=Sp10->kass
  ENDIF
  DO CASE
    CASE flish->kopu==k_pod1.OR.flish->kopu==k_pod2
      buf->sum2+=flish->sum
    CASE flish->kopu=="901".OR.flish->kopu=="902"
      buf->sum1+=flish->sum
    CASE flish->kopu==k_pen1.OR.flish->kopu==k_pen2
      buf->sum4+=flish->sum
    CASE flish->kopu=="921".OR.flish->kopu=="922"
      buf->sum3+=flish->sum
    CASE flish->kopu==k_pen4.OR.flish->kopu==k_pen5
      buf->sum6+=flish->sum
    CASE flish->kopu=="924".OR.flish->kopu=="925"
      buf->sum5+=flish->sum
    CASE flish->kopu==k_pen3
      buf->sum8+=flish->sum
    CASE flish->kopu=="923"
      buf->sum7+=flish->sum
  ENDCASE

  IF INKEY()==K_ESC
    IF ANSWERu("Прервати вивiд?")==YES
      l_finish:=.t.
      EXIT
    ENDIF
  ENDIF
 ENDIF
 Flish->(DBSKIP())
 m_gauge:=DispGauge(m_gauge,flish->(RECNO())/flish->(LASTREC()))
ENDDO
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  IF m_type==1
    INDEX ON buf->kass+buf->tabn TO (m_temppath+"buf05")
    FormMsh(SELECT("buf"),"05",m_month,m_month1)
  ENDIF
  IF m_type==2
    INDEX ON buf->tabn TO (m_temppath+"buf05")
    FormMsh(SELECT("buf"),"05A",m_month,m_month1)
  ENDIF
ENDIF
CLOSE BASE flish,msh,buf,sp10
RETURN .t.
#DEFINE N_PAPER 2
Function Mn09
  LOCAL a_struct:={},m_gauge,m_month,m_nextMonth,m_type10,m_type11,m_type9,i,;
  m_gauge1,m_097,m_110,s_month
  LOCAL m_sum1,m_sum2,m_sum1a,m_sum2a,m_otdnm,m_othsm,m_otdny,m_othsy,m_str1,m_str
  LOCAL m_key,l_finish:=.f.,m_page:=1,m_endpage,m_kass:='01',m_num:=1,l_npch,s1,s2,m_month1
  LOCAL l1,l_801:=0,m_st1
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  m_month:=STRZERO(i,2)
  m_month1:=STRZERO(m_month1,2)

  m_nextMonth:=STRZERO(i+1,2)
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
  m_097 :=RESTVAR1("m_097","ZR")
  m_110 :=RESTVAR1("m_110","ZR")
  l_npch   :=RESTVAR1("l_npch"  ,"ZR")
  l_801    :=RESTVAR1("l_801","ZR")
CLOSE myvar

  NET USE (m_mainpath+"flish") NEW
  NET  USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS("  9"));m_type9:=Msh->type
  msh->(DS(" 10"));m_type10:=Msh->type
  msh->(DS(" 11"));m_type11:=Msh->type
  GetType9(@m_type9,@m_type10,@m_type11)
  IF l_npch
    NET  USE (m_mainpath+"fnpch") NEW
    COPY TO (m_temppath+"fnpch") FOR field->month==m_month
    CLOSE fnpch
  ENDIF

  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08")  NEW READONLY
  NET USE  (m_syspath+"Struct") INDEX (m_syspath+"Struct") NEW READONLY
  struct->(DS("MASH09"))
  DO WHILE .NOT.struct->(EOF()).AND."MASH09"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
DBCREATE(m_temppath+"buf09",a_struct)
a_struct:={}
USE (m_temppath+"buf09") NEW ALIAS buf09
INDEX ON buf09->tabn+buf09->st1+buf09->kopu+buf09->st+buf09->month TO (m_temppath+"buf09")
  struct->(DS("MASH10"))
  DO WHILE .NOT.struct->(EOF()).AND."MASH10"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
DBCREATE(m_temppath+"buf10",a_struct)
a_struct:={}
USE (m_temppath+"buf10") NEW ALIAS buf10
INDEX ON buf10->tabn+buf10->kopu+buf10->st+buf10->month TO (m_temppath+"buf10")
  struct->(DS("MASH11"))
  DO WHILE .NOT.struct->(EOF()).AND."MASH11"==struct->name
    AADD(a_struct,{struct->field_name,struct->field_type,struct->Field_len,struct->field_dec})
    struct->(DBSKIP())
  ENDDO
DBCREATE(m_temppath+"buf",a_struct)
a_struct:={}
USE (m_temppath+"buf") NEW ALIAS buf
INDEX ON buf->kass+buf->tabn TO (m_temppath+"buf1a")
INDEX ON buf->tabn TO (m_temppath+"buf1b")
INDEX ON UPPER(buf->fam+buf->imja+buf->otch) TO (m_temppath+"buf1c")
INDEX ON buf->kass1+buf->tabn  TO (m_temppath+"buf1d")
SET INDEX TO
SET INDEX TO (m_temppath+"buf1a"),(m_temppath+"buf1b"),(m_temppath+"buf1c"),(m_temppath+"buf1d")
buf->(DBSETORDER(2))
CLOSE struct
  m_gauge:=InitGauge("Розрахунок 9-ї,10-ї i 11-ї машинограм")
  DO WHILE .not.Flish->(EOF())
    IF m_month>=Flish->month.AND.Flish->month>=m_month1.AND.flish->st<>"!"
      IF .NOT.buf->(DS(flish->tabn))
        buf->(DBAP())
        buf->tabn:=Flish->tabn
        Sp10->(DS(buf->tabn))
        buf->Fam  := Sp10->fam
        buf->Otch := Sp10->Otch
        buf->Imja := Sp10->Imja
        buf->Kpn  := Sp10->Kpn
        buf->Kmn  := Sp10->Kmn
        buf->Kprof:= Sp10->Kprof
        buf->Kktg := Sp10->Kktg
        buf->kvz  := Sp10->kvz
        buf->Codn := Sp10->Codn
        buf->kass := Sp10->kass
        buf->kass1 := IF(VAL(Sp10->kass)<20,"01",Sp10->kass)
      ENDIF
      s_month:=IF(m_month==Flish->month,mnt_smonth(flish->mnt),'  ')
      IF (flish->kopu<"100") //Начисления
        IF(flish->st=="Z") // Зарплата
          m_st1:=" "
        ELSE // Из кассы или корректировка
          m_st1:="0"
        ENDIF
      ELSE // УДЕРЖАНИЯ
        IF (flish->st=="1") // Земельный пай
          m_st1:="5"
        ELSE
         IF (flish->st=="2") // МАЙНОВИЙ пай
          m_st1:="6"
         ELSE
          IF (flish->st=="3") // ОБОРОТНЫЙ пай
            m_st1:="7"
          ELSE
            m_st1:="1"      // Обычные удержания
          endif
         endif
        endif
       endif
      IF .NOT.buf09->(DS(Flish->tabn+m_st1+flish->kopu+flish->st+s_month))
        Buf09->(DBAP())
        buf09->tabn:=Flish->tabn
        buf09->kopu:=Flish->kopu
        buf09->month:=s_month
        buf09->st:=Flish->st
        buf09->st1:=m_st1
      ENDIF
      IF m_month==Flish->month
        buf09->summ+= Flish->sum
        buf09->otdnm+=Flish->otdn
        buf09->othsm+=Flish->oths
        IF .NOT.buf10->(DS(Flish->tabn+flish->kopu+flish->st+mnt_smonth(flish->mnt)))
          Buf10->(DBAP())
          buf10->tabn:=Flish->tabn
          buf10->kopu:=Flish->kopu
          buf10->month:=mnt_smonth(flish->mnt)
          buf10->st:=Flish->st
          buf->p10:="1"
        ENDIF
        buf10->sum+= Flish->sum
        buf10->otdn+=Flish->otdn
        buf10->oths+=Flish->oths
        IF flish->kopu=="800"
          buf->p11:="1"
          buf->Sum11:=flish->sum
        ENDIF
        IF l_801<>0
          IF flish->kopu=="801"
            buf->Sum801:=flish->sum
          ENDIF
        ENDIF
      ENDIF

      IF .NOT.buf09->(DS(Flish->tabn+m_st1+flish->kopu+flish->st+"  "))
        Buf09->(DBAP())
        buf09->tabn:=Flish->tabn
        buf09->kopu:=Flish->kopu
        buf09->st:=Flish->st
        buf09->st1:=m_st1
      ENDIF

      buf09->sumy+= Flish->sum
      buf09->otdny+=Flish->otdn
      buf09->othsy+=Flish->oths
    ENDIF
    IF m_NextMonth==Flish->month.AND.(Flish->kopu==m_110.OR.Flish->kopu=m_097)
      IF .NOT.buf->(DS(flish->tabn))
        buf->(DBAP())
        buf->tabn:=Flish->tabn
        Sp10->(DS(buf->tabn))
        buf->Fam  := Sp10->fam
        buf->Otch := Sp10->Otch
        buf->Imja := Sp10->Imja
        buf->Kpn  := Sp10->Kpn
        buf->Kmn  := Sp10->Kmn
        buf->Kprof:= Sp10->Kprof
        buf->Kktg := Sp10->Kktg
        buf->kvz  := Sp10->kvz
        buf->Codn := Sp10->Codn
        buf->kass := Sp10->kass
        buf->kass1 := IF(VAL(Sp10->kass)<20,"01",Sp10->kass)
      ENDIF
      IF Flish->kopu==m_110
        buf->sum110:=Flish->sum
      ENDIF
      IF Flish->kopu==m_097
        buf->sum097:=Flish->sum
      ENDIF
    ENDIF
IF INKEY()==K_ESC
  IF ANSWERu("Прервати вивiд?")==YES
    l_finish:=.t.
    EXIT
  ENDIF
ENDIF
    Flish->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,flish->(RECNO())/flish->(LASTREC()))
  ENDDO
m_gauge:=DispGauge(m_gauge,1.00)
m_gauge1:=InitGauge("Вивiд особ. рахункiв",2)
buf->(DBSETORDER(m_type9))
buf->(DBGOTOP())
i:=1
USE (m_temppath+"fnpch") NEW
INDEX ON fnpch->tabn TO (m_temppath+"fnpch")
SET PRINTER TO (m_mash+"09.txt")
SET DEVICE TO PRINTER
SETPRC(0,0)
m_str:=DTOC(DATE())+" ОСОБИСТИЙ РАХУНОК "
m_str1:="за " + NTOCMONTH(VAL(m_month))
m_kass:=buf->kass
// DO WHILE .NOT.buf->(EOF()).AND..NOT.l_finish

DO WHILE .NOT.buf->(EOF()).AND..NOT.l_finish
@PROW()+1,0 SAY  m_str
@PROW(),PCOL()+2 SAY buf->codn
@PROW(),PCOL()+2 SAY m_str1
@PROW()+1,3 SAY LEFT(ALLTRIM(buf->fam)  + ' ' + ALLTRIM(buf->imja);
                         + ' ' + ALLTRIM(buf->otch)+" "+buf->kpn+buf->kmn+buf->kvz,39)
@PROW(),44 Say 'Таб. N ' + buf->tabn
buf09->(DS(buf->tabn))
@PROW()+1,0 SAY "НАРАХУВАННЯ  I  УТРИМАННЯ   За мiсяць        З початку року"
m_sum1:=0;m_sum2:=0;m_otdnm:=0;m_otdny:=0;m_othsm:=0;m_othsy:=0
l1:=IF(buf09->st=="Z",.t.,.f.)
DO WHILE .NOT.buf09->(EOF()).AND.buf09->tabn==buf->tabn.AND.buf09->kopu<"100"
IF l1.AND.buf09->st==" "  // Начисления
  @PROW()+1,0 SAY "НАРАХ."
  @PROW(),27 SAY m_otdnm  PICTURE "9999.9"
  @PROW(),33 SAY m_othsm  PICTURE "99999"
  @PROW(),38 SAY m_sum1   PICTURE "999999.99"
  @PROW(),47 SAY m_otdny  PICTURE "9999.9"
  @PROW(),53 SAY m_othsy  PICTURE "99999"
  @PROW(),59 SAY m_sum2   PICTURE "999'999.99"
  l1:=.f.
ENDIF

   sp08->(DBSEEK ( buf09->kopu ) )
  @PROW()+1,0 Say buf09->month
  @PROW(),3 Say buf09->kopu
  @PROW(),7   SAY sp08->name8
  IF Buf09->otdnm<>0
    @PROW(),27 SAY buf09->otdnm  PICTURE "9999.9"
  ENDIF
  IF buf09->othsm<>0
    @PROW(),33 SAY buf09->othsm  PICTURE "99999"
  ENDIF
  @PROW(),38 SAY buf09->summ   PICTURE "999999.99"
  IF buf09->otdny<>0
    @PROW(),47 SAY buf09->otdny  PICTURE "9999.9"
  ENDIF
  IF buf09->othsy<>0
    @PROW(),53 SAY buf09->othsy  PICTURE "99999"
  ENDIF
  IF buf09->kopu<>m_097.AND.EMPTY(buf09->month)
    @PROW(),59 SAY buf09->sumy   PICTURE "999'999.99"
    m_sum2+= buf09->sumy
  ENDIF
  m_sum1+= buf09->summ
  m_otdnm+=buf09->otdnm
  m_othsm+=buf09->othsm
  m_otdny+=buf09->otdny
  m_othsy+=buf09->othsy
  buf09->(DBSKIP())
ENDDO
@PROW()+1,0 SAY "ЗАРПЛ."
  @PROW(),27 SAY m_otdnm  PICTURE "9999.9"
  @PROW(),33 SAY m_othsm  PICTURE "99999"
  @PROW(),38 SAY m_sum1   PICTURE "999999.99"
//  @PROW(),47 SAY m_otdny  PICTURE "9999.9"
//  @PROW(),53 SAY m_othsy  PICTURE "99999"
//  @PROW(),59 SAY m_sum2   PICTURE "999'999.99"
m_sum1a:=0;m_sum2a:=0;m_otdnm:=0;m_otdny:=0;m_othsm:=0;m_othsy:=0
// Удержания
m_st1:=buf09->st1
DO WHILE .NOT.buf09->(EOF()).AND.buf09->tabn==buf->tabn.AND.buf09->kopu>="100"
IF buf09->kopu<"800"
IF m_st1<>buf09->st1
m_st1:=buf09->st1
IF m_st1=="5"
@PROW()+1,0  SAY  '-------------------- земельный пай  --------------------------------'
ELSE
	IF m_st1=="6"
@PROW()+1,0  SAY  '-------------------- имущественный пай  ----------------------------'
	ELSE
		IF m_st1=="7"
@PROW()+1,0  SAY  '-------------------- оборотный пай  --------------------------------'
		ELSE
			@PROW()+1,0  SAY  '--------------------------------------------------------'
		ENDIF
	ENDIF
ENDIF
ENDIF

  sp08->(DBSEEK ( buf09->kopu ) )
  @PROW()+1,0 Say buf09->month
  @PROW(),3 Say buf09->kopu
//  @PROW(),6 SAY buf09->st
  @PROW(),7   SAY sp08->name8
  IF buf09->othsm<>0
    @PROW(),27 SAY buf09->othsm  PICTURE "999"
  ENDIF
  IF Buf09->otdnm<>0
    @PROW(),30 SAY buf09->otdnm  PICTURE "9999.99"
  ENDIF
  @PROW(),39 SAY buf09->summ   PICTURE "99999.99"
  IF buf09->othsy<>0
    @PROW(),47 SAY buf09->othsy  PICTURE "999"
  ENDIF
  IF buf09->otdny<>0
    @PROW(),50 SAY buf09->otdny  PICTURE "99999.99"
  ENDIF

  IF buf09->kopu<>m_110.AND.EMPTY(buf09->month)
    @PROW(),59 SAY buf09->sumy   PICTURE "999'999.99"
    IF buf09->st<>"*" // Рассчитываеться , но не учитываеться
      m_sum2a+= buf09->sumy
    ENDIF
  ENDIF
  IF buf09->st<>"*"
    m_sum1a+= buf09->summ
  ENDIF
  ENDIF
  buf09->(DBSKIP())
ENDDO
@PROW()+1,0 SAY "УТРИМ."
@PROW(),39 SAY m_sum1a   PICTURE "99999.99"
@PROW(),59 SAY m_sum2a   PICTURE "999'999.99"
@PROW()+1,0 SAY "САЛЬДО"
@PROW(),PCOL()+2 SAY m_sum1-m_sum1a PICTURE "999'999.99"
IF buf->sum11<>0
  @PROW(),PCOL()+2 SAY "До випл."
  @PROW(),PCOL()+2 SAY buf->sum11 PICTURE "99999.99"
ENDIF
IF buf->sum110<>0
  @PROW(),PCOL()+2 SAY "Борг "
  @PROW(),PCOL()+2 SAY buf->sum110 PICTURE "99999.99"
ENDIF
IF buf->sum097<>0
  @PROW(),PCOL()+2 SAY " Коп. "
  @PROW(),PCOL()+2 SAY buf->sum097 PICTURE "99.99"
ENDIF
IF l_801<>0
  @PROW(),PCOL()+2 SAY "["+ALLTRIM(STR(buf->sum801,16,2))+"]"
ENDIF
IF l_npch
  fnpch->(DS(buf->tabn))
  s1:=ALLTRIM(fnpch->n1);s1:=LEFT(s1,LEN(s1)-1)
  s2:=ALLTRIM(fnpch->n2);s2:=LEFT(s2,LEN(s2)-1)
  IF .NOT.EMPTY(s1).OR..not.EMPTY(s2)
    @PROW()+1,0 SAY s1+" / "+s2
  ENDIF
ENDIF

@PROW()+1,0  SAY  '--------------------------------------------------------'
IF INKEY()==K_ESC
  IF ANSWERu("Прервати вивiд?")==YES
    l_finish:=.t.
    EXIT
  ENDIF
ENDIF
  buf->(DBSKIP())
  IF (m_type9==1.AND.m_kass<>buf->kass).OR.(m_type9==4.AND.m_kass<>buf->kass1)
    @PROW()+1, 0  SAY  'касир '+m_kass+' ..........................................'+m_kass+'касир'
    @PROW()+1, 0  SAY  '$'
    m_kass:=IF(m_type9==1,buf->kass,buf->kass1)
  ENDIF

  m_gauge1:=DispGauge(m_gauge1,i++/buf->(LASTREC()))
ENDDO
Dobms(m_month,"01")
SET PRINTER TO
SET DEVICE TO SCREEN
DelGauge(m_gauge1)
m_gauge1:=InitGauge("Вивiд розр. листкiв",2)
buf->(DBSETORDER(m_type10))
select buf
SET FILTER TO buf->p10="1"
buf->(DBGOTOP())
i:=1
SET PRINTER TO (m_mash+"10.txt")
SET DEVICE TO PRINTER
SETPRC(0,0)
m_str:=DTOC(DATE())+" РОЗРАХУНКОВИЙ ЛИСТ за " + NTOCMONTH(VAL(m_month))
m_kass:=buf->kass
DO WHILE .NOT.buf->(EOF()).AND..NOT.l_finish

@PROW()+1,0 SAY  m_str
@PROW()+1 ,0 SAY LEFT(ALLTRIM(buf->FAM)  + ' ' + SUBSTR( ALLTRIM(buf->imja),1,1);
                   + '. ' + SUBSTR(ALLTRIM(buf->otch),1,1) +'.',18)
@PROW(),19 Say 'Таб N ' + buf->tabn
@PROW(),PCOL()+1 SAY buf->codn
buf10->(DS(buf->tabn))
m_sum1:=0;m_otdnm:=0;m_othsm:=0
// m_st1:=buf10->st1
DO WHILE .NOT.buf10->(EOF()).AND.buf10->tabn==buf->tabn.AND.buf10->kopu<"100"
   sp08->(DBSEEK ( buf10->kopu ) )
  @PROW()+1,0 Say buf10->month
  @PROW(),3 Say buf10->kopu
  @PROW(),7   SAY sp08->name8
  IF Buf10->otdn<>0
    @PROW(),27 SAY buf10->otdn  PICTURE "999.9"
  ENDIF
  IF Buf10->oths<>0
    @PROW(),32 SAY buf10->oths  PICTURE "9999"
  ENDIF
  @PROW(),37 SAY buf10->sum   PICTURE "99999.99"
  m_sum1+= buf10->sum
  m_otdnm+=buf10->otdn
  m_othsm+=buf10->oths
  buf10->(DBSKIP())
ENDDO
@PROW()+1,0 SAY "Нарах."
  @PROW(),27 SAY m_otdnm  PICTURE "9999.9"
  @PROW(),33 SAY m_othsm  PICTURE "9999"
  @PROW(),37 SAY m_sum1   PICTURE "99999.99"
m_sum1a:=0

DO WHILE .NOT.buf10->(EOF()).AND.buf10->tabn==buf->tabn.AND.buf10->kopu>="100".AND.buf10->kopu<"800"
  IF buf10->st<>"*"
    sp08->(DBSEEK ( buf10->kopu ) )
    @PROW()+1,0 Say buf10->month
    @PROW(),3 Say buf10->kopu
    @PROW(),6 Say buf10->st
    @PROW(),7   SAY sp08->name8
    IF buf10->oths<>0
      @PROW(),27 SAY buf10->oths  PICTURE "999"
    ENDIF
    IF buf10->otdn<>0
      @PROW(),30 SAY buf10->otdn  PICTURE "9999.99"
    ENDIF
    @PROW(),37 SAY buf10->sum   PICTURE "99999.99"
    m_sum1a+= buf10->sum
  ENDIF
  buf10->(DBSKIP())
ENDDO
@PROW()+1,0 SAY "Утрим."
@PROW(),34 SAY m_sum1a   PICTURE "99999.99"
@PROW()+1,0 SAY "Залишок"
@PROW(),PCOL()+2 SAY m_sum1-m_sum1a PICTURE "999'999.99"
IF buf->sum11<>0
  @PROW(),PCOL()+2 SAY "До випл."
  @PROW(),PCOL()+2 SAY buf->sum11 PICTURE "99999.99"
ENDIF
IF buf->sum110<>0
  @PROW(),PCOL()+2 SAY "Борг "
  @PROW(),PCOL()+2 SAY buf->sum110 PICTURE "99999.99"
ENDIF
@PROW()+1,0  SAY  "------------------------------------------"
IF INKEY()==K_ESC
  IF ANSWERu("Прервати вивiд?")==YES
    l_finish:=.t.
    EXIT
  ENDIF
ENDIF
  buf->(DBSKIP())
  IF (m_type10==1.AND.m_kass<>buf->kass).OR.(m_type10==4.AND.m_kass<>buf->kass1)
    @PROW()+1, 0  SAY  'касир '+m_kass+'................... '+m_kass+' касир'
    @PROW()+1, 0  SAY  '$'
    m_kass:=IF(m_type10==1,buf->kass,buf->kass1)
  ENDIF
  m_gauge1:=DispGauge(m_gauge1,i++/buf->(LASTREC()))
ENDDO
Dobms(m_month,m_month)
SET PRINTER TO
SET DEVICE TO SCREEN
DelGauge(m_gauge1)

m_gauge1:=InitGauge("Вивiд плат. вiд.",2)
buf->(DBSETORDER(m_type11))
select buf
SET FILTER TO buf->p11="1"
buf->(DBGOTOP())
i:=1
SET PRINTER TO (m_mash+"11.txt")
SET DEVICE TO PRINTER
SETPRC(0,0)
m_str:=DTOC(DATE())+" за " + NTOCMONTH(VAL(m_month))
m_page:=1
m_endpage:=GetEndPage()
m_kass:=buf->kass
m_sum1:=m_sum2:=0
DO WHILE .NOT.buf->(EOF()).AND..NOT.l_finish
  IF PROW()==0
    @0,0  SAY DATE()
    @0,20 SAY  'Платiжна вiдомiсть N ' +  m_kass
    @0,60  SAY  'Лист   N   ' + STRZERO( m_page, 3 )
    m_page++
    @1,0  SAY  '┌───┬──────┬──────────┬────────────────────────────────┬───────────┬──────────┐'
    @2,0  SAY  '│ N │Табель│ Iндiвi-  │                                │  Сума     │ Розпис   │'
    @3,0  SAY  "│п/п│ ний  │дуальний  │    Фамiлiя,iм'я,по батьковi    │  (грв.)   │    в     │"
    @4,0  SAY  '│   │номер │  код     │                                │           │ одержаннi│'
    @5,0  SAY  '└───┴──────┴──────────┴────────────────────────────────┴───────────┴──────────┘'
    m_sum1:=0
//    m_num:=1
  ENDIF

@PROW()+2,1 SAY m_num PICTURE "999"
m_num++
@PROW(),5 SAY buf->tabn
@PROW(),12 SAY buf->codn
@PROW(), 23 SAY  ALLTRIM(buf->fam)+' '+ALLTRIM(buf->imja)+' '+ALLTRIM(buf->otch) ;
PICTURE 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
@PROW(),56 SAY  SumToStr(buf->sum11,10,,",")
@PROW(),68 SAY "........."
m_sum1+=buf->sum11
m_sum2+=buf->sum11
IF INKEY()==K_ESC
  IF ANSWERu("Прервати вивiд?")==YES
    l_finish:=.t.
    EXIT
  ENDIF
ENDIF
buf->(DBSKIP())
  IF PROW()>=m_endpage-4.OR.((m_type11==1.AND.buf->kass<>m_kass).OR.(m_type11==4.AND.buf->kass1<>m_kass)).OR.buf->(EOF())
      @PROW()+2,0 SAY "РАЗОМ ПО СТОРIНЦI"
      @PROW(),54 SAY SumToStr(m_sum1,12,,",")
      @PROW()+1,0 SAY NumToChar(INT(m_sum1))+'  грв.  ' + STRZERO( (m_sum1 - INT(m_sum1))*100,2) + ' коп.'
      m_sum1:=0
      IF buf->(EOF()).OR.((m_type11==1.AND.buf->kass<>m_kass).OR.(m_type11==4.AND.buf->kass1<>m_kass))
        @PROW()+2,0 SAY "РАЗОМ ПО ВIДОМОСТI"
        @PROW(),54 SAY SumToStr(m_sum2,12,,",")
        @PROW()+1,0 SAY NumToChar(INT(m_sum2))+'  грв.  ' + STRZERO( (m_sum2 - INT(m_sum2))*100,2) + ' коп.'
        @prow()+1,0   SAY  'Контролер______________________          Керiвник      ___________________'
        @PROW()+1,0   SAY  '                                         Гол. бухгалтер___________________'
//        StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
        StrToPrn(END_LINE+"$"+END_LINE)
        SETPRC(0,0)
        @0, 0          SAY      REPLICATE('_',75)
        @1, 0      SAY      DATE()
        @1, 75    SAY      'Лист 0'
        @ 3, 61   SAY      ' Форма Т-53'
        @ 5,10       SAY      'Пiдприємство '+  p_npr
        @ 7,10       SAY      'В касу для виплати      '
        @ 9, 10      SAY      'з_____по_______________20    року '
        @ 11, 10      SAY      'В сумi'
        @ 11, 10 +9   SAY  NumToStr( INT(m_sum2) ) + '  грв.  ' + STRZERO( (m_sum2 - INT(m_sum2))*100,2) + ' коп.'
        @ 15, 10      SAY      'Керiвник           ________________ '
        @ 17, 10      SAY      'Головний бухгалтер ________________'
        @ 19, 10      SAY      'Кер. вiддiлу кадрiв ________________'
        @  25, 10 + 25-18 SAY      'ПЛАТIЖHA  BIДOMICTЬ на видачу готiвки N '+m_kass
        @  27, 10+26   SAY  "За "+NTOCMONTH(VAL(m_month))+" мiсяць "
        @  32, 10      SAY      'По даннiй платiжнiй вiдомостi'
        @  34, 10      SAY      'Виплачено гривень____________________________________'
        @  36, 10      SAY      '                 ________________________(_____грв. ____коп)'
        @  38, 10      SAY      'И депонiровано   ________________________________________'
        @  40, 10      SAY      '                 ________________________(_____грв._____коп)'
        @  42, 10      SAY      'Виплату виконав    ________________'
        @  44, 10      SAY      'Перевiрiв бухгалтер ________________ '
        @  46, 10      SAY      'Kасовий ордер______вiд_____________________20   року'
        @  50, 10      SAY      'Kiлькiсть листiв'
        @  50,10+19    SAY      m_page-1
        m_sum2:=0;m_kass:=IF(m_type11==1,buf->kass,buf->kass1);m_num:=1;m_page:=1
       ENDIF
  //    StrToPrn(IF(GetParPrn(N_PAPER)==1,END_LINE+END_LINE+END_LINE,CHR(K_CTRL_L)+END_LINE))
       StrToPrn(END_LINE+"$"+END_LINE)
      SETPRC(0,0)
    ENDIF
m_gauge1:=DispGauge(m_gauge1,i++/buf->(LASTREC()))
ENDDO
Dobms(m_month,m_month)
SET PRINTER TO
SET DEVICE TO SCREEN
DelGauge(m_gauge1)
DelGauge(m_gauge)
CLOSE BASE flish,sp10,sp08,buf,buf10,buf09,msh,fnpch
/*
FERASE(m_temppath+"buf.dbf")
FERASE(m_temppath+"buf10.dbf")
FERASE(m_temppath+"buf09.dbf")
FERASE(m_temppath+"buf.ntx")
FERASE(m_temppath+"buf10.ntx")
FERASE(m_temppath+"buf09.ntx")
*/
RETURN .t.
STATIC Function GetType9(m_type1,m_type2,m_type3)
LOCAL m_state:=1,m_key
SavePar()
@10,5,16,75 BOX B_DOUBLE+" " COLOR "w/b"
@11,6 SayDisp "                            Особ. рахунки Розр. картки Плат. вiд."
@12,6 SayDisp "По касирам i таб. номерах" COLOR "w/b"
@13,6 SayDisp "По таб. номерах"           COLOR "w/b"
@14,6 SayDisp "По Ф.I.Б."                 COLOR "w/b"
@15,6 SayDisp "Особливий"                 COLOR "w/b"
DO WHILE .t.
@11+m_type1,38 SayDisp "√"  COLOR (IF(m_state==1,"n/w","w+/b"))
@11+m_type2,53 SayDisp "√"  COLOR (IF(m_state==2,"n/w","w+/b"))
@11+m_type3,66 SayDisp "√"  COLOR (IF(m_state==3,"n/w","w+/b"))
m_key:=INKEY(0)
@11+m_type1,38 SayDisp " "  COLOR "w/b"
@11+m_type2,53 SayDisp " "  COLOR "w/b"
@11+m_type3,66 SayDisp " "  COLOR "w/b"
  DO CASE
    CASE m_key==K_ENTER.OR.m_key==K_ESC
      msh->(DS("  9"))
      IF msh->(NetRlock())
        Msh->type:=m_type1
        msh->(dbUnlock())
      ENDIF
      msh->(DS(" 10"))
      IF msh->(NetRlock())
        Msh->type:=m_type2
        msh->(dbUnlock())
      ENDIF
      msh->(DS(" 11"))
      IF msh->(NetRlock())
        Msh->type:=m_type3
        msh->(dbUnlock())
      ENDIF
      EXIT
    CASE m_key==K_UP
      DO CASE
        CASE m_state==1
          m_type1:=IF(m_type1==1,3,m_type1-1)
        CASE m_state==2
          m_type2:=IF(m_type2==1,3,m_type2-1)
        CASE m_state==3
          m_type3:=IF(m_type3==1,3,m_type3-1)
      ENDCASE
    CASE m_key==K_DOWN
      DO CASE
        CASE m_state==1
          m_type1:=IF(m_type1==4,1,m_type1+1)
        CASE m_state==2
          m_type2:=IF(m_type2==4,1,m_type2+1)
        CASE m_state==3
          m_type3:=IF(m_type3==4,1,m_type3+1)
      ENDCASE
    CASE m_key==K_LEFT
      m_state:=IF(m_state=1,3,m_state-1)
    CASE m_key==K_RIGHT
      m_state:=IF(m_state=3,1,m_state+1)
  ENDCASE
ENDDO
SavePar(1)
RETURN .t.
FUNCTION mn21
  LOCAL i,m_month:=0,l_finish:=.f.,m_gauge,m_gauge1
  LOCAL m_kass,m_type
  LOCAL m_sum:=0,m_month1:=0
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 21"));m_type:=Msh->type
  GetType(@m_type," 21")
CrStruct("MASH21","buf21")
USE (m_temppath+"buf21") NEW ALIAS buf
INDEX ON buf->tabn+buf->ksash+buf->brgd+buf->vrab to (m_temppath+"buf21")
m_gauge:=InitGauge("Розрахунок машинограми N 21",1)
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44")  NEW READONLY
NET USE (m_sprpath+"sp01") INDEX (m_sprpath+"sp01")  NEW READONLY
NET USE (m_sprpath+"sp06") INDEX (m_sprpath+"sp06")  NEW READONLY
NET USE (m_mainpath+"fz3") NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
  DO WHILE .NOT.fz1->(EOF())
      IF mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1
        IF pFilpoz("fz2","vnum1","fz1")
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
           IF fz1->vdoc<>38.AND..NOT.pFilpoz("fz3","vnum2","fz2")
                  SKIP 1 ALIAS fz2
                  LOOP
            ENDIF
           IF .NOT.buf->(DBSEEK(fz2->tabn+fz2->ksash+fz2->brgd+fz2->vrab))
                     SP10->(DS(fz2->tabn))
                     buf->(DBAP())
                     buf->tabn:=fz2->tabn
                     buf->ksash:=fz2->ksash
                     buf->vrab:=fz2->vrab
                     buf->brgd:=fz2->brgd
                     buf->kass:=sp10->kass
           ENDIF
           m_sum:=0
           DO WHILE fz2->vnum2==fz3->vnum2.AND..NOT.fz3->(EOF())
            m_sum+=fz3->sum
            fz3->(DBSKIP())
          ENDDO
          buf->sum+=m_sum
          buf->otdn+=fz2->otdn
          buf->oths+=fz2->oths
          fz2->(DBSKIP())
        ENDDO
      ENDIF
    ENDIF
    IF INKEY()==K_ESC
      IF ANSWERu("Прервати вивiд?")==YES
        l_finish:=.t.
        EXIT
      ENDIF
    ENDIF
    fz1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
ENDDO

CLOSE base FZ1,FZ2,FZ3
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  DELE for buf->otdn==0.and.buf->oths==0.and.buf->sum==0
  IF m_type==1
    INDEX ON buf->kass+buf->tabn+buf->ksash+buf->brgd+buf->vrab to (m_temppath+"buf")
    FormMsh(SELECT("buf"),"21",STRZERO(m_month,2),STRZERO(m_month1,2))
  ENDIF
  IF m_type==2
    FormMsh(SELECT("buf"),"21A",STRZERO(m_month,2),STRZERO(m_month1,2))
  ENDIF
ENDIF
DelGauge(m_gauge)
CLOSE base sp44,msh,buf,sp06,sp01,sp10
RETURN .t.
return .t.
Function mn23
  LOCAL i,m_month:=0,l_finish:=.f.,m_gauge,m_gauge1
  LOCAL m_kass,m_type,l_first:=.t.
  LOCAL m_month1:=0
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
CrStruct("MASH23","buf23")
USE (m_temppath+"buf23") NEW ALIAS buf
INDEX ON buf->kktg+buf->kprof+buf->kopu to (m_temppath+"buf23")
m_gauge:=InitGauge("Розрахунок машинограми N 23",1)
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
NET USE (m_sprpath+"sp04") INDEX (m_sprpath+"sp04")  NEW READONLY
NET USE (m_sprpath+"sp03") INDEX (m_sprpath+"sp03")  NEW READONLY
NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08")  NEW READONLY
NET USE (m_mainpath+"fz3") NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
  DO WHILE .NOT.fz1->(EOF())
      IF mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1
        IF pFilpoz("fz2","vnum1","fz1")
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
           IF fz1->vdoc<>38.AND..NOT.pFilpoz("fz3","vnum2","fz2")
                  SKIP 1 ALIAS fz2
                  LOOP
            ENDIF
           SP10->(DS(fz2->tabn))
              l_first:=.t.
           DO WHILE fz2->vnum2==fz3->vnum2.AND..NOT.fz3->(EOF())
              IF .NOT.buf->(DBSEEK(sp10->kktg+sp10->kprof+fz3->kopu))
                        buf->(DBAP())
                        buf->kktg :=sp10->kktg
                        buf->kprof:=sp10->kprof
                        buf->kopu :=fz3->kopu
              ENDIF
              IF l_first
                buf->otdn+=fz2->otdn
                buf->oths+=fz2->oths
              ENDIF
              buf->sum+=fz3->sum
              l_first:=.f.
            fz3->(DBSKIP())
          ENDDO
          fz2->(DBSKIP())
        ENDDO
      ENDIF
    ENDIF
    IF INKEY()==K_ESC
      IF ANSWERu("Прервати вивiд?")==YES
        l_finish:=.t.
        EXIT
      ENDIF
    ENDIF
    fz1->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
ENDDO

CLOSE base FZ1,FZ2,FZ3
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  DELE for buf->otdn==0.and.buf->oths==0.and.buf->sum==0
  FormMsh(SELECT("buf"),"23",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
DelGauge(m_gauge)
CLOSE base msh,buf,sp10,sp04,sp03,sp08
return .t.
Function mn19
  LOCAL i,m_month:=0,l_finish:=.f.,m_gauge,m_gauge1
  LOCAL m_kass,m_type
  LOCAL m_month1:=0
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  m_month:=STRZERO(i,2)
  m_month1:=STRZERO(m_month1,2)
  NET USE (m_mainpath+"flish") NEW
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 19"));m_type:=Msh->type
  GetType(@m_type," 19")
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08")  NEW READONLY
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
  CrStruct("MS19","buf19")
  USE (m_temppath+"buf19") NEW ALIAS buf
  INDEX ON buf->tabn TO (m_temppath+"buf19")
  m_gauge:=InitGauge("Розрахунок машинограми N 19",1)
DO WHILE .not.Flish->(EOF())
 IF m_month>=Flish->month.AND.Flish->month>=m_month1.AND.flish->st<>"!"
  sp08->(DS(flish->kopu))
IF ISDIGIT(sp08->p17)
  IF .NOT.buf->(DS(flish->tabn))
    buf->(DBAP())
    buf->tabn:=flish->tabn
    sp10->(DS(buf->tabn))
    buf->kass:=Sp10->kass
  ENDIF
  DO CASE
     CASE sp08->p17=="1"
         buf->sum1+=flish->sum
         buf->otdn1+=flish->otdn
     CASE sp08->p17=="2"
         buf->sum2+=flish->sum
         buf->otdn2+=flish->otdn
     CASE sp08->p17=="3"
         buf->sum3+=flish->sum
         buf->otdn3+=flish->otdn
     CASE sp08->p17=="4"
         buf->sum4+=flish->sum
     OTHERWISE
         buf->sum5+=flish->sum
ENDCASE
buf->sum6+=flish->sum
buf->otdn+=flish->otdn
buf->oths+=flish->oths
ENDIF
  IF INKEY()==K_ESC
    IF ANSWERu("Прервати вивiд?")==YES
      l_finish:=.t.
      EXIT
    ENDIF
  ENDIF
 ENDIF
 Flish->(DBSKIP())
 m_gauge:=DispGauge(m_gauge,flish->(RECNO())/flish->(LASTREC()))
ENDDO
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  IF m_type==1
    INDEX ON buf->kass+buf->tabn TO (m_temppath+"buf03")
    FormMsh(SELECT("buf"),"19",m_month,m_month1)
  ENDIF
  IF m_type==2
    INDEX ON buf->tabn TO (m_temppath+"buf19")
    FormMsh(SELECT("buf"),"19A",m_month,m_month1)
  ENDIF
ENDIF
CLOSE BASE flish,sp08,msh,buf,sp10
RETURN .t.

Function mn06
  LOCAL i,m_month:=0,l_finish:=.f.,m_gauge,m_gauge1
  LOCAL m_month1:=0
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  CrStruct("MS06","buf06")
  USE (m_temppath+"buf06") NEW ALIAS buf
  INDEX ON buf->name TO (m_temppath+"buf06")
  m_gauge:=InitGauge("Розрахунок машинограми N 06",1)
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW



NET USE (m_mainpath+"boln2") INDEX (m_mainpath+"boln2") NEW READONLY
NET USE (m_mainpath+"boln1") NEW READONLY
  DO WHILE .NOT.boln1->(EOF())
      IF mnt_month(boln1->mnt3) <= m_month.AND.mnt_month(boln1->mnt3)>=m_month1
        IF boln2->(DS(boln1->vnumc))
         DO WHILE boln1->vnumc=boln2->vnumc.AND..NOT.boln2->(EOF())
            IF .NOT.buf->(DBSEEK(boln1->kind))
              buf->(DBAP())
              buf->name:=boln1->kind
            ENDIF
            buf->sum+=boln2->sum5
            buf->otdn+=boln2->otdn01
            boln2->(DBSKIP())
         ENDDO
        ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      boln1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,boln1->(RECNO()/LASTREC()))
  ENDDO
CLOSE base boln1,boln2
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  FormMsh(SELECT("buf"),"06",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
CLOSE BASE buf,msh
RETURN .t.
Function Mn25
  LOCAL m_month,i,n,m_gauge,m_gauge1
  LOCAL m_sum3:=0,m_sum4:=0,m_kopu,m_log
  m_month:=GetMonth()
  IF m_month==0
    RETURN .f.
  ENDIF
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08")  NEW READONLY
  NET USE (m_mainpath+"Fzn") NEW
  CrStruct("MASH25","buf25")
  USE (m_temppath+"buf25") NEW ALIAS buf
  INDEX ON buf->kopu+buf->tabn  TO  (m_temppath+"buf25")
  m_gauge:=InitGauge("Розрахунок машинограми N 25",1)
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  DO WHILE .NOT.fzn->(EOF())
    IF m_month==Fzn->month
      buf->(DBAP())
//      buf->num    :=Fzn->num
      buf->tabn   :=Fzn->tabn
      buf->procent:=Fzn->procent
      buf->otdn   :=Fzn->otdn // отраб. дне1
      buf->sum1   :=Fzn->sum1 // нач. СУММА
      buf->sum2   :=Fzn->sum2 // подоходный
      buf->sum3   :=Fzn->sum3 // сумма исп. листа
      buf->sum5   :=Fzn->sum5 // сумма с которой
      buf->kopu   :=Fzn->kopu // код удерж.
    ENDIF
    fzn->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fzn->(RECNO()/LASTREC()))
  ENDDO
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  FormMsh(SELECT("buf"),"25",STRZERO(m_month,2),STRZERO(m_month,2))
  CLOSE BASE fzn,buf,sp10,sp08,msh
RETURN .t.

Function mn26
  LOCAL i,m_month:=0,l_finish:=.f.,m_gauge,m_gauge1
  LOCAL m_kass,m_type
  m_month:=Getmonth()
  IF m_month==0
    RETURN .f.
  ENDIF
  NET USE (m_mainpath+"flish") NEW
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
//  msh->(DS(" 26"));m_type:=Msh->type
//  GetType(@m_type," 26")
  NET USE (m_sprpath+"sp08") INDEX (m_sprpath+"sp08")  NEW READONLY
  NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
  CrStruct("MS26","buf26")
  USE (m_temppath+"buf26") NEW ALIAS buf
  INDEX ON buf->tabn TO (m_temppath+"buf26")
  m_gauge:=InitGauge("Розрахунок машинограми N 26",1)
DO WHILE .not.Flish->(EOF())
 IF m_month==VAL(Flish->month)
  sp08->(DS(flish->kopu))
IF ISDIGIT(sp08->p26)
  IF .NOT.buf->(DS(flish->tabn))
    buf->(DBAP())
    buf->tabn:=flish->tabn
//    sp10->(DS(buf->tabn))
  ENDIF
  DO CASE
     CASE sp08->p26=="1"
         buf->sum1+=flish->sum
         buf->otdn+=flish->otdn
         buf->oths+=flish->oths
         buf->sum9+=flish->sum
     CASE sp08->p26=="2"
         buf->sum2+=flish->sum
         buf->sum9-=flish->sum
     CASE sp08->p26=="3"
         buf->sum3+=flish->sum
         buf->sum9-=flish->sum
     CASE sp08->p26=="4"
         buf->sum10+=flish->sum
         buf->sum9-=flish->sum
     CASE sp08->p26=="5"
         buf->sum4+=flish->sum
         buf->sum9-=flish->sum
     CASE sp08->p26=="6"
         buf->sum5+=flish->sum
         buf->sum9-=flish->sum
     CASE sp08->p26=="7"
         buf->sum6+=flish->sum
         buf->sum9-=flish->sum
     CASE sp08->p26=="8"
         buf->sum7+=flish->sum
         buf->sum9-=flish->sum
     CASE sp08->p26=="9"
         buf->sum8+=flish->sum
         buf->sum9-=flish->sum
  ENDCASE
  IF INKEY()==K_ESC
    IF ANSWERu("Прервати вивiд?")==YES
      l_finish:=.t.
      EXIT
    ENDIF
  ENDIF
 ENDIF
ENDIF
 Flish->(DBSKIP())
 m_gauge:=DispGauge(m_gauge,flish->(RECNO())/flish->(LASTREC()))
ENDDO
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  FormMsh(SELECT("buf"),"26",STRZERO(m_month,2),STRZERO(m_month,2))
ENDIF
CLOSE BASE flish,sp08,msh,buf,sp10
RETURN .t.

Function Mn31
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL m_type:=1,m_month,i,m_gauge,m_gauge1,m_month1
  LOCAL  l_finish:=.f.,b_block
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 31"));m_type:=Msh->type
IF .NOT.  GetType3(@m_type," 31")
  CLOSE msh
  RETURN .f.
ENDIF
CrStruct("MS31","buf31")
CrStruct("MS33","buf33")

USE (m_temppath+"buf31") NEW ALIAS buf
INDEX ON buf->kmtr+buf->ntr+buf->tabn to (m_temppath+"buf31")
m_gauge:=InitGauge("Розрахунок машинограми N 31",1)
USE (m_temppath+"buf33") NEW ALIAS buf33

NET USE (m_sprpath+"sp13b") INDEX (m_sprpath+"sp13b")  NEW READONLY
NET USE (m_sprpath+"inv_t") INDEX (m_sprpath+"inv_t")  NEW READONLY
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz2t") NEW READONLY
NET USE (m_mainpath+"fz2tp") NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
NET USE (m_mainpath+"fz1t") NEW READONLY
IF m_type==1
  b_block:={||IF(mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1,.t.,.f.)}
ELSE
  b_block:={||IF(month(fz1->ddoc) <= m_month.AND.month(fz1->ddoc)>=m_month1,.t.,.f.)}
ENDIF
  DO WHILE .NOT.fz1->(EOF())
      IF EVAL(b_block).AND.fz1->vdoc>=34.AND.fz1->vdoc<=37
        IF pFilpoz("fz2","vnum1","fz1").AND.pFilpoz("fz1t","vnum1","fz1")
          inv_t->(DS(fz1t->ntr))
          IF .NOT.buf->(DBSEEK(inv_t->kmtr+fz1t->ntr+fz2->tabn))
              buf->(DBAP())
              buf->kmtr :=inv_t->kmtr
              buf->ntr  :=  fz1t->ntr
              buf->tabn :=  fz2->tabn
          ENDIF
          buf->otmd  +=   fz1t->otmd
          buf->otms  +=   fz1t->otms
          buf33->(DBAP())
              buf33->kmtr :=inv_t->kmtr
              buf33->ntr  :=  fz1t->ntr
              buf33->tabn :=  fz2->tabn
              buf33->otmd :=   fz1t->otmd
              buf33->otms :=   fz1t->otms
              buf33->npch := fz1->npch
              buf33->ndoc := fz1->ndoc
          DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
               IF .NOT.pFilpoz("fz2t","vnum2","fz2")
                  fz2->(DBSKIP())
                  LOOP
               ENDIF
               IF fz1->vdoc==37.AND..NOT.pFilpoz("fz2tp","vnum2","fz2")
                  fz2->(DBSKIP())
                  LOOP
               ENDIF
               buf->oths  +=   fz2 ->oths
               buf->vpga  +=   fz2t->vpga
               buf->vptn  +=   fz2t->vptn
               buf->vpug  +=   fz2t->vpug
               buf->otnsm +=   fz2t->otnsm
               IF fz1->vdoc==37
                buf->vtktr +=   fz2tp->vtktr
                buf->pgob  +=   fz2tp->pgob
                buf->pggr  +=   fz2tp->pggr
                buf->prtn  +=   fz2tp->prtn
               ENDIF
               buf33->oths  +=   fz2 ->oths
               buf33->vpga  +=   fz2t->vpga
               buf33->vptn  +=   fz2t->vptn
               buf33->vpug  +=   fz2t->vpug
               buf33->otnsm +=   fz2t->otnsm
               IF fz1->vdoc==37
                buf33->vtktr +=   fz2tp->vtktr
                buf33->pgob  +=   fz2tp->pgob
                buf33->pggr  +=   fz2tp->pggr
                buf33->prtn  +=   fz2tp->prtn
               ENDIF
               buf33->rtnor+=fz2t->rtnor
               buf33->rtfak+=fz2t->rtfak
               buf->rtnor+=fz2t->rtnor
               buf->rtfak+=fz2t->rtfak
            fz2->(DBSKIP())
         ENDDO
      ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fz1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
  CLOSE base FZ1,FZ2,fz1t,fz2t,fz2tp
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  FormMsh(SELECT("buf"),"31",STRZERO(m_month,2),STRZERO(m_month1,2))
  sele buf33
  INDEX ON buf33->tabn+buf33->ntr+str(BUF33->npch,3)+str(buf33->ndoc,5) to (m_temppath+"buf33")
  buf33->(DBGOTOP())
  FormMsh(SELECT("buf33"),"33",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
DelGauge(m_gauge)
CLOSE base sp10,msh,buf,sp13b,inv_t,buf33
RETURN .t.
FUNCTION mn35
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL m_type:=1,m_month,i,m_gauge,m_gauge1,m_month1
  LOCAL  l_finish:=.f.,b_block,b_block1,l_norma,l_kgm,m_kvo,m_koef,m_prise,m_stm
   LOCAL m_schtgsm:="",n_error:=0

 i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 35"));m_type:=Msh->type
IF .NOT.  GetType3(@m_type," 35")
  CLOSE msh
  RETURN .f.
ENDIF
  USE (m_uchpath+"\inst1") INDEX  (m_uchpath+"\inst1") new ALIAS myvar
  RESTMEM m_schtgsm  // счет ГСМ - литры сумируются в головы
  CLOSE myvar

NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
l_norma:=RESTVAR1("l_norma","ZR")
l_kgm:=RESTVAR1("l_kgm","ZR")
CLOSE myvar
CrStruct("MS35","buf35")
// CrStruct("MS37","buf37")

USE (m_temppath+"buf35") NEW ALIAS buf
INDEX ON buf->kmtr+buf->ntr+buf->tabn to (m_temppath+"buf35")
m_gauge:=InitGauge("Розрахунок машинограми N 35",1)
// USE (m_temppath+"buf37") NEW ALIAS buf37

NET USE (m_sprpath+"sp13b") INDEX (m_sprpath+"sp13b")  NEW READONLY
NET USE (m_sprpath+"inv_t") INDEX (m_sprpath+"inv_t")  NEW READONLY
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
NET USE (m_sprpath+"sp22") INDEX (m_sprpath+"sp22")  NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz2t") NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
NET USE (m_mainpath+"fz1t") NEW READONLY
IF m_type==1
  b_block:={||IF(mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1,.t.,.f.)}
  b_block1:={||mnt_month(fz1->mnt)}
ELSE
  b_block:={||IF(month(fz1->ddoc) <= m_month.AND.month(fz1->ddoc)>=m_month1,.t.,.f.)}
  b_block1:={||month(fz1->ddoc) == m_month}
ENDIF
  DO WHILE .NOT.fz1->(EOF())
      IF EVAL(b_block1)<=m_month.AND.fz1->vdoc>=34.AND.fz1->vdoc<=37
        IF pFilpoz("fz2","vnum1","fz1").AND.pFilpoz("fz1t","vnum1","fz1")
          inv_t->(DS(fz1t->ntr))
          IF .NOT.buf->(DBSEEK(inv_t->kmtr+fz1t->ntr+fz2->tabn))
              buf->(DBAP())
              buf->kmtr :=inv_t->kmtr
              buf->ntr  :=  fz1t->ntr
              buf->tabn :=  fz2->tabn
          ENDIF
          IF EVAL(b_block)
            buf->zaprtr +=   fz1t->zapr
          ENDIF
          SP22->(DS(mnt_dtod(fz1->ddoc)+"15"))
          DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
               IF .NOT.pFilpoz("fz2t","vnum2","fz2")
                  fz2->(DBSKIP())
                  LOOP
               ENDIF
              IF EVAL(b_block)
               buf->rtnor +=   IF(l_kgm,IF(sp22->koef==0,0,fz2t->rtnor/sp22->koef),fz2t->rtnor)
               buf->rtfak +=   fz2t->rtfak
               IF l_norma
                 IF l_kgm
                  buf->rtsum+=fz2t->rtnor * sp22->prise
                 ELSE
                  buf->rtsum+=fz2t->rtnor * sp22->koef * sp22->prise
               ENDIF
               ELSE
                  buf->rtsum+=fz2t->rtfak * sp22->prise * sp22->koef
               ENDIF
              ELSE
                IF l_norma
                  IF l_kgm
                    m_kvo:= IF(sp22->koef==0,0,fz2t->rtnor/sp22->koef)
                    m_stm:=  fz2t->rtnor * sp22->prise
                  ELSE
                    m_kvo:= fz2t->rtnor
                    m_stm:=fz2t->rtnor * sp22->koef * sp22->prise
                  ENDIF
                ELSE
                  m_kvo :=fz2t->rtfak
                  m_stm:=fz2t->rtfak * sp22->prise * sp22->koef
                ENDIF
               buf->inkvo-=m_kvo
               buf->insum-=m_stm
              ENDIF
            fz2->(DBSKIP())
         ENDDO
      ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fz1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()/2))
  ENDDO
  CLOSE base FZ1,FZ2,fz1t,fz2t
IF .not.l_finish
NET USE (m_mainpath+"fp1") INDEX (m_mainpath+"fp1") NEW READONLY
NET USE (m_mainpath+"fp2") NEW READONLY
DO WHILE .NOT.fp2->(EOF())
  // Найти запись в Fp1
  IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
    IF fp1->maket=="03".AND.mnt_month(fp1->mnt)<=m_month  // Трактористы
      inv_t->(DS(fp1->num))
      DO WHILE fp1->vnum==fp2->vnum.AND..NOT.fp2->(EOF())
          IF .NOT.buf->(DBSEEK(inv_t->kmtr+fp1->num+fp1->tabn))
              buf->(DBAP())
              buf->kmtr :=inv_t->kmtr
              buf->ntr  :=  fp1->num
              buf->tabn :=  fp1->tabn
          ENDIF
          IF mnt_month(fp1->mnt) <= m_month.AND.mnt_month(fp1->mnt)>=m_month1.AND.LEFT(fp2->crt,2)<>"04" //Запись из расчетного периода
            buf->zaprlzk +=   fp2->kvo2
            buf->zaprstm +=   fp2->stm
          ELSE
            buf->inkvo += fp2->kvo2
            buf->insum +=   fp2->stm
          ENDIF
          fp2->(DBSKIP())
      ENDDO
  ELSE
   DO WHILE fp1->vnum==fp2->vnum.AND..NOT.fp2->(EOF())
    fp2->(DBSKIP())
    m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()/2)+0.5)
  ENDDO
 ENDIF
    IF INKEY()==K_ESC
      IF ANSWERu("Прервати вивiд?")==YES
        l_finish:=.t.
        EXIT
      ENDIF
    ENDIF

ENDDO
  IF n_error<>0
    DispError("При розрахунку знайдено ;"+STR(n_error,4)+" помилок")
  ENDIF

CLOSE BASE fp1,fp2
ENDIF
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  buf->(DBGOTOP())
  DO WHILE .NOT.buf->(EOF())
    buf->outkvo:=buf->inkvo+buf->zaprlzk-IF(l_norma,buf->rtnor,buf->rtfak)
    buf->outsum:=buf->insum+buf->zaprstm-buf->rtsum
    buf->ekon  :=buf->rtnor-buf->rtfak
    buf->ekon1 :=buf->zaprlzk-IF(l_norma,buf->rtnor,buf->rtfak)
    buf->(DBSKIP())
  ENDDO
  FormMsh(SELECT("buf"),"35",STRZERO(m_month,2),STRZERO(m_month1,2))
  SELE buf
  INDEX ON buf->tabn+buf->kmtr+buf->ntr to (m_temppath+"buf37")
  buf->(DBGOTOP())
  FormMsh(SELECT("buf"),"37",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
DelGauge(m_gauge)
CLOSE base sp10,msh,buf,sp13b,inv_t,sp22
RETURN .T.
Function Mn39
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL m_type:=1,m_month,i,m_gauge,m_gauge1,m_month1,m_kvo,l_tkmtr
  LOCAL  l_finish:=.f.,b_block,m_dbttract,l_norma,l_kgm,m_sum
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 39"));m_type:=Msh->type
IF .NOT.  GetType3(@m_type," 39")
  CLOSE msh
  RETURN .f.
ENDIF
USE (m_uchpath+"inst1") INDEX  (m_uchpath+"inst1") new ALIAS myvar
RESTMEM m_DBTTRACT
CLOSE myvar
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
l_norma:=RESTVAR1("l_norma","ZR")
l_kgm:=RESTVAR1("l_kgm","ZR")
l_tkmtr:=RESTVAR1("l_tkmtr","ZR")
CLOSE myvar
CrStruct("MS39","buf39")
CrStruct("MS40","buf40")

USE (m_temppath+"buf39") NEW ALIAS buf
INDEX ON buf->ksash+buf->vrab+buf->brgd to (m_temppath+"buf39")
m_gauge:=InitGauge("Розрахунок машинограми N 39",1)
USE (m_temppath+"buf40") NEW ALIAS buf40

NET USE (m_sprpath+"inv_t") INDEX (m_sprpath+"inv_t")  NEW READONLY
NET USE (m_sprpath+"sp06") INDEX (m_sprpath+"sp06")  NEW READONLY
NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44")  NEW READONLY
NET USE (m_sprpath+"sp01") INDEX (m_sprpath+"sp01")  NEW READONLY
NET USE (m_sprpath+"sp22") INDEX (m_sprpath+"sp22")  NEW READONLY
NET USE (m_sprpath+"sp23")  NEW READONLY
NET USE (m_sprpath+"sp13b") INDEX (m_sprpath+"sp13b")  NEW READONLY
NET USE (m_mainpath+"fz3") NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz2t") NEW READONLY
NET USE (m_mainpath+"fz2tp") NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
NET USE (m_mainpath+"fz1t") NEW READONLY
IF m_type==1
  b_block:={||IF(mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1,.t.,.f.)}
ELSE
  b_block:={||IF(month(fz1->ddoc) <= m_month.AND.month(fz1->ddoc)>=m_month1,.t.,.f.)}
ENDIF
  DO WHILE .NOT.fz1->(EOF())
      IF EVAL(b_block).AND.fz1->vdoc>=34.AND.fz1->vdoc<=37
        IF pFilpoz("fz2","vnum1","fz1").AND.pFilpoz("fz1t","vnum1","fz1")
          inv_t->(DS(fz1t->ntr))
          sp13b->(DS(inv_t->kmtr))
          SP22->(DS(mnt_dtod(fz1->ddoc)+"15"))
          DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
               IF .NOT.pFilpoz("fz2t","vnum2","fz2")
                  fz2->(DBSKIP())
                  LOOP
               ENDIF
               IF fz1->vdoc==37.AND..NOT.pFilpoz("fz2tp","vnum2","fz2")
                  fz2->(DBSKIP())
                  LOOP
               ENDIF
               buf40->(DBAP())
               buf40->npch:=fz1->npch
               buf40->ndoc:=fz1->ndoc
              buf40->ksash:=fz2->ksash
              buf40->subsch:=LEFT(fz2->ksash,3)
              buf40->sch:=LEFT(fz2->ksash,2)
              buf40->vrab :=fz2->vrab
              buf40->brgd :=fz2->brgd

               IF .NOT.buf->(DS(fz2->ksash+fz2->vrab+fz2->brgd))
                buf->(DBAP())
                buf->ksash:=fz2->ksash
                buf->subsch:=LEFT(fz2->ksash,3)
                buf->sch:=LEFT(fz2->ksash,2)
                buf->vrab :=fz2->vrab
                buf->brgd :=fz2->brgd
               ENDIF
               m_sum:=0
               IF pFilpoz("fz3","vnum2","fz2")
                DO WHILE fz3->vnum2==fz2->vnum2.AND..NOT.fz3->(EOF())
                  m_sum+=fz3->sum
                  fz3->(DBSKIP())
                ENDDO
               ENDIF
               buf40->sum:=m_sum
               buf->sum+=m_sum
               IF m_dbttract==LEFT(inv_t->ksash,LEN(m_dbttract)) // трактора
                  IF fz1->vdoc==37
                    buf->tkm +=   fz2tp->vtktr
                    buf40->tkm  :=   fz2tp->vtktr
                    buf->uga1+=fz2t->vpug
                    buf40->uga1  :=fz2t->vpug
                    IF l_tkmtr
                      buf->stm3+=fz2tp->vtktr*sp23->trtkm
                      buf40->stm3 :=fz2tp->vtktr*sp23->trtkm
                    ELSE
                      buf->stm3   +=sp23->truga*fz2t->vpug
                      buf40->stm3 :=sp23->truga*fz2t->vpug
                    ENDIF
                  ELSE
                    buf->uga+=fz2t->vpug
                    buf->stm2+=sp23->truga*fz2t->vpug
                    buf->fga1+=fz2t->vpga

                    buf40->uga  :=fz2t->vpug
                    buf40->stm2 :=sp23->truga*fz2t->vpug
                    buf40->fga1 :=fz2t->vpga
                  ENDIF
              ELSE
               buf->fga+=fz2t->vpga
               buf->stm1+=fz2t->vpga*sp13b->stm
               buf40->fga :=fz2t->vpga
               buf40->stm1:=fz2t->vpga*sp13b->stm
              ENDIF
               IF l_norma
                m_kvo:=IF(l_kgm,IF(sp22->koef==0,0,fz2t->rtnor/sp22->koef),fz2t->rtnor)
                buf->rtfak+=m_kvo
                buf40->rtfak:=m_kvo
                IF l_kgm
                  buf->stm4+=fz2t->rtnor*sp22->prise
                  buf40->stm4:=fz2t->rtnor*sp22->prise
                ELSE
                  buf->stm4+=fz2t->rtnor*sp22->prise*sp22->koef
                  buf40->stm4:=fz2t->rtnor*sp22->prise*sp22->koef
                ENDIF
              ELSE
                buf->rtfak+=fz2t->rtfak
                buf->stm4+=fz2t->rtfak*sp22->koef*sp22->prise
                buf40->rtfak:=fz2t->rtfak
                buf40->stm4 :=fz2t->rtfak*sp22->koef*sp22->prise
              ENDIF
            fz2->(DBSKIP())
         ENDDO
        ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fz1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
  CLOSE base FZ1,FZ2,fz1t,fz2t,fz2tp,fz3
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  FormMsh(SELECT("buf"),"39",STRZERO(m_month,2),STRZERO(m_month1,2))
  buf40->(DBGOTOP())
  SELECT buf40
  INDEX ON buf40->brgd+buf40->ksash+buf40->vrab+str(BUF40->npch,3)+str(buf40->ndoc,5) to (m_temppath+"buf40")
  FormMsh(SELECT("buf40"),"40",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
DelGauge(m_gauge)
CLOSE base msh,buf,buf40,inv_t,sp13b,sp23,sp22,sp01,sp06,sp44
RETURN .t.
STATIC Function RestVar(m_name)
myvar->(DBSEEK(PADR(LOWER(ALLTRIM(m_name)),12)))
DO CASE
  CASE myvar->kod=="C"
    RETURN (ALLTRIM(myvar->value))
  CASE myvar->kod=="N"
    RETURN (VAL(myvar->value))
  CASE myvar->kod=="L"
    RETURN (IF(AT(UPPER(ALLTRIM(myvar->value)),"1TYД")<>0,.t.,.f.))
  CASE myvar->kod=="D"
    RETURN (CTOD(ALLTRIM(myvar->value)))
ENDCASE
RETURN (0)
Function Mn51
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL m_type:=1,m_month,i,m_gauge,m_gauge1,m_month1
  LOCAL  l_finish:=.f.,b_block
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 51"));m_type:=Msh->type
IF .NOT.  GetType3(@m_type," 51")
  CLOSE msh
  RETURN .f.
ENDIF
CrStruct("MS51","buf51")
CrStruct("MS53","buf53")

USE (m_temppath+"buf51") NEW ALIAS buf
INDEX ON buf->kavt+buf->gnavt+buf->tabn to (m_temppath+"buf51")
m_gauge:=InitGauge("Розрахунок машинограми N 51",1)
USE (m_temppath+"buf53") NEW ALIAS buf53

NET USE (m_sprpath+"sp13a") INDEX (m_sprpath+"sp13a")  NEW READONLY
NET USE (m_sprpath+"inv_a") INDEX (m_sprpath+"inv_a")  NEW READONLY
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz2a") NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
NET USE (m_mainpath+"fz1ae") NEW READONLY
NET USE (m_mainpath+"fz1at") NEW READONLY
NET USE (m_mainpath+"fz1ap") NEW READONLY
IF m_type==1
  b_block:={||IF(mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1,.t.,.f.)}
ELSE
  b_block:={||IF(month(fz1->ddoc) <= m_month.AND.month(fz1->ddoc)>=m_month1,.t.,.f.)}
ENDIF
  DO WHILE .NOT.fz1->(EOF())
      IF EVAL(b_block).AND.fz1->vdoc>=38.AND.fz1->vdoc<=44
        IF pFilpoz("fz2","vnum1","fz1").AND.pFilpoz("fz1ae","vnum1","fz1");
          .AND.pFilpoz("fz1at","vnum1","fz1")
          IF fz1->vdoc==40 .AND..NOT.pFilpoz("fz1ap","vnum1","fz1")
            fz1->(DBSKIP())
            LOOP
          ENDIF
          inv_a->(DS(fz1ae->gnavt))
          IF .NOT.buf->(DBSEEK(inv_a->kavt+fz1ae->gnavt+fz2->tabn))
              buf->(DBAP())
              buf->kavt :=inv_a->kavt
              buf->gnavt:= fz1ae->gnavt
              buf->tabn :=  fz2->tabn
              buf->kmtop:=fz1at->kmtop
          ENDIF
         buf->kolez+= fz1ae->kolez
         buf->pggr += fz1ae->pggr
         buf->ptav += fz1ae->ptav
         buf->vnvs += fz1ae->vnvs
         buf->vndv += fz1ae->vndv
         buf->prvs += fz1ae->prvs
         buf->prpr += fz1ae->prpr
         buf->prsn += fz1ae->prsn
         buf->prtn += fz1ae->prtn
         buf->avdn += fz1ae->avdn
         buf->rgnor+=fz1ae->rgnor
         buf->rgfak+=fz1ae->rgfak
// - - - - - - - - fz1ap - - - - - - - - - - -
        IF  fz1->vdoc = 40
          buf->vnus += fz1ap->vnus
          buf->ptpr += fz1ap->ptpr
          buf->vtkpr+= fz1ap->vtkpr
        ENDIF


          buf53->(DBAP())
          buf53->npch := fz1->npch
          buf53->ndoc := fz1->ndoc
         buf53->gnavt:= fz1ae->gnavt
         buf53->kavt :=inv_a->kavt
         buf53->tabn :=  fz2->tabn
         buf53->kolez := fz1ae->kolez
         buf53->pggr := fz1ae->pggr
         buf53->ptav := fz1ae->ptav
         buf53->vnvs := fz1ae->vnvs
         buf53->vndv := fz1ae->vndv
         buf53->prvs := fz1ae->prvs
         buf53->prpr := fz1ae->prpr
         buf53->prsn := fz1ae->prsn
         buf53->prtn := fz1ae->prtn
         buf53->avdn := fz1ae->avdn
         buf53->kmtop:=fz1at->kmtop
         buf53->rgnor:=fz1ae->rgnor
         buf53->rgfak:=fz1ae->rgfak
// - - - - - - - - fz1ap - - - - - - - - - - -
        IF  fz1->vdoc = 40
          buf53->vnus := fz1ap->vnus
          buf53->ptpr := fz1ap->ptpr
          buf53->vtkpr:= fz1ap->vtkpr
        ENDIF


          DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF .NOT.pFilpoz("fz2a","vnum2","fz2")
              fz2->(DBSKIP())
              LOOP
            ENDIF
            buf->pgob   +=fz2a->pgob
            buf->vtkav  +=fz2a->vtkav
            buf53->pgob +=fz2a->pgob
            buf53->vtkav+=fz2a->vtkav
            fz2->(DBSKIP())
         ENDDO
      ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fz1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
  CLOSE base FZ1,FZ2,fz1ae,fz2a,fz1ap,fz1at
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  FormMsh(SELECT("buf"),"51",STRZERO(m_month,2),STRZERO(m_month1,2))
  SELECT buf53
  buf53->(DBGOTOP())
  INDEX ON buf53->tabn+buf53->gnavt+str(BUF53->npch,3)+str(buf53->ndoc,5) to (m_temppath+"buf53")
  FormMsh(SELECT("buf53"),"53",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
DelGauge(m_gauge)
CLOSE base sp10,msh,buf,sp13a,inv_a,buf53
RETURN .t.
Function Mn59
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL m_type:=1,m_month,i,m_gauge,m_gauge1,m_month1,m_kvo
  LOCAL  l_finish:=.f.,b_block,m_dbtsavto,l_norma,l_kgm,m_sum
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 59"));m_type:=Msh->type
IF .NOT.  GetType3(@m_type," 59")
  CLOSE msh
  RETURN .f.
ENDIF
USE (m_uchpath+"inst1") INDEX  (m_uchpath+"inst1") new ALIAS myvar
RESTMEM m_dbtsavto
CLOSE myvar
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
l_norma:=RESTVAR1("l_norma","ZR")
l_kgm:=RESTVAR1("l_kgm","ZR")
CLOSE myvar
CrStruct("MS59","buf59")
CrStruct("MS60","buf60")

USE (m_temppath+"buf59") NEW ALIAS buf
INDEX ON buf->ksash+buf->brgd to (m_temppath+"buf59")
m_gauge:=InitGauge("Розрахунок машинограми N 59",1)
USE (m_temppath+"buf60") NEW ALIAS buf60

NET USE (m_sprpath+"inv_a") INDEX (m_sprpath+"inv_a")  NEW READONLY
NET USE (m_sprpath+"sp06") INDEX (m_sprpath+"sp06")  NEW READONLY
NET USE (m_sprpath+"sp44") INDEX (m_sprpath+"sp44")  NEW READONLY
NET USE (m_sprpath+"sp01") INDEX (m_sprpath+"sp01")  NEW READONLY
NET USE (m_sprpath+"sp22") INDEX (m_sprpath+"sp22")  NEW READONLY
NET USE (m_sprpath+"sp23")  NEW READONLY
NET USE (m_sprpath+"sp13a") INDEX (m_sprpath+"sp13a")  NEW READONLY
NET USE (m_mainpath+"fz3") NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz2a") NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
NET USE (m_mainpath+"fz1ae") NEW READONLY
NET USE (m_mainpath+"fz1at") NEW READONLY
IF m_type==1
  b_block:={||IF(mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1,.t.,.f.)}
ELSE
  b_block:={||IF(month(fz1->ddoc) <= m_month.AND.month(fz1->ddoc)>=m_month1,.t.,.f.)}
ENDIF
  DO WHILE .NOT.fz1->(EOF())
      IF EVAL(b_block).AND.fz1->vdoc>=38.AND.fz1->vdoc<=44.AND.;
         pFilpoz("fz2","vnum1","fz1").AND.pFilpoz("fz1ae","vnum1","fz1");
          .AND.pFilpoz("fz1at","vnum1","fz1")
/*
          @10,0 SAY fz1->(RECNO())
          @11,0 SAY fz2->(RECNO())
          @12,0 SAY fz3->(RECNO())
          @13,0 SAY fz1ae->(RECNO())
          @14,0 SAY fz1at->(RECNO())
*/
          inv_a->(DS(fz1ae->gnavt))
          sp13a->(DS(inv_a->kavt))
          SP22->(DS(mnt_dtod(fz1->ddoc)+fz1at->kmtop))
          l_first:=.t.
          DO WHILE fz1->vnum1==fz2->vnum1.AND..NOT.fz2->(EOF())
               IF .NOT.pFilpoz("fz2a","vnum2","fz2")
                  fz2->(DBSKIP())
                  LOOP
               ENDIF
               buf60->(DBAP())
               buf60->npch:=fz1->npch
               buf60->ndoc:=fz1->ndoc
              buf60->ksash:=fz2->ksash
              buf60->subsch:=LEFT(fz2->ksash,3)
              buf60->sch:=LEFT(fz2->ksash,2)
              buf60->brgd :=fz2->brgd

               IF .NOT.buf->(DS(fz2->ksash+fz2->brgd))
                buf->(DBAP())
                buf->ksash:=fz2->ksash
                buf->subsch:=LEFT(fz2->ksash,3)
                buf->sch:=LEFT(fz2->ksash,2)
                buf->brgd :=fz2->brgd
               ENDIF
               m_sum:=0
               IF fz1->vdoc<>38.AND.pFilpoz("fz3","vnum2","fz2")
                DO WHILE fz3->vnum2==fz2->vnum2.AND..NOT.fz3->(EOF())
                  m_sum+=fz3->sum
                  fz3->(DBSKIP())
                ENDDO
               ENDIF
               buf60->sum:=m_sum
               buf->sum+=m_sum

               IF m_dbtsavto==inv_a->ksash // спецавтотранспорт
                  buf->avtohs+= fz2->oths
                  buf->stm3+=fz2->oths * sp23->avhs
                  buf60->avtohs:= fz2->oths
                  buf60->stm3  :=fz2->oths * sp23->avhs
              ELSE
                IF fz2a->vtkav=0
                  buf->pgob+= fz2a->pgob
                  buf->stm2+= fz2a->pgob * sp23->km
                  buf60->pgob:= fz2a->pgob
                  buf60->stm2:= fz2a->pgob * sp23->km
                ELSE
                  buf->vtkav+= fz2a->vtkav
                  buf->stm1+= fz2a->vtkav*sp23->tkm
                  buf60->vtkav:= fz2a->vtkav
                  buf60->stm1+= fz2a->vtkav*sp23->tkm
                ENDIF
              ENDIF
              IF l_first
               IF l_norma
                  buf->rtfak+=fz1ae->rgnor
                  buf60->rtfak:=fz1ae->rgnor
                  buf->stm4+=fz1ae->rgnor*sp22->prise*sp22->koef
                  buf60->stm4:=fz1ae->rgnor*sp22->prise*sp22->koef
                ELSE
                  buf->rtfak+=fz1ae->rgfak
                  buf60->rtfak:=fz1ae->rgfak
                  buf->stm4+=fz1ae->rgfak*sp22->prise*sp22->koef
                  buf60->stm4:=fz1ae->rgfak*sp22->prise*sp22->koef
                ENDIF
              ENDIF
            fz2->(DBSKIP())
            l_first:=.f.
         ENDDO
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fz1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
  CLOSE base FZ1,FZ2,fz1at,fz2a,fz1ae,fz3
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  FormMsh(SELECT("buf"),"59",STRZERO(m_month,2),STRZERO(m_month1,2))
  buf60->(DBGOTOP())
  SELECT buf60
  INDEX ON buf60->brgd+buf60->ksash+str(BUF60->npch,3)+str(buf60->ndoc,5) to (m_temppath+"buf60")
  FormMsh(SELECT("buf60"),"60",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
DelGauge(m_gauge)
CLOSE base msh,buf,buf60,inv_a,sp13a,sp23,sp22,sp01,sp06,sp44
RETURN .t.
FUNCTION mn55
  LOCAL l_first :=.f.                // Признак 1-й строки файла fz3
  LOCAL m_type:=1,m_month,i,m_gauge,m_gauge1,m_month1,n_error:=0
  LOCAL  l_finish:=.f.,b_block,b_block1,l_norma,l_kgm,m_kvo,m_koef,m_prise,m_stm
  i:=GetMonth2(@m_month,@m_month1)
  IF i==0
    RETURN .f.
  ENDIF
  NET USE (m_syspath+"msh") INDEX  (m_syspath+"msh")  NEW
  msh->(DS(" 55"));m_type:=Msh->type
IF .NOT.  GetType3(@m_type," 55")
  CLOSE msh
  RETURN .f.
ENDIF
NET USE (m_syspath+"memvar") INDEX  (m_syspath+"memvar") new ALIAS myvar
l_norma:=RESTVAR1("l_norma","ZR")
l_kgm:=RESTVAR1("l_kgm","ZR")
CLOSE myvar
CrStruct("MS55","buf55")
// CrStruct("MS57","buf57")

USE (m_temppath+"buf55") NEW ALIAS buf
INDEX ON buf->kavt+buf->gnavt+buf->tabn+buf->kmtop to (m_temppath+"buf55")
m_gauge:=InitGauge("Розрахунок машинограми N 55",1)
// USE (m_temppath+"buf57") NEW ALIAS buf57

NET USE (m_sprpath+"sp13a") INDEX (m_sprpath+"sp13a")  NEW READONLY
NET USE (m_sprpath+"inv_a") INDEX (m_sprpath+"inv_a")  NEW READONLY
NET USE (m_sprpath+"sp10") INDEX (m_sprpath+"sp10")  NEW READONLY
NET USE (m_sprpath+"sp22") INDEX (m_sprpath+"sp22")  NEW READONLY
NET USE (m_mainpath+"fz1") NEW READONLY
NET USE (m_mainpath+"fz2") NEW READONLY
NET USE (m_mainpath+"fz1ae") NEW READONLY
NET USE (m_mainpath+"fz1at") NEW READONLY
IF m_type==1
  b_block:={||IF(mnt_month(fz1->mnt) <= m_month.AND.mnt_month(fz1->mnt)>=m_month1,.t.,.f.)}
  b_block1:={||mnt_month(fz1->mnt)}
ELSE
  b_block:={||IF(month(fz1->ddoc) <= m_month.AND.month(fz1->ddoc)>=m_month1,.t.,.f.)}
  b_block1:={||month(fz1->ddoc) == m_month}
ENDIF
  DO WHILE .NOT.fz1->(EOF())
      IF EVAL(b_block1)<=m_month.AND.fz1->vdoc>=38.AND.fz1->vdoc<=44
        IF pFilpoz("fz2","vnum1","fz1").AND.pFilpoz("fz1ae","vnum1","fz1").AND.;
          pFilpoz("fz1at","vnum1","fz1")
          inv_a->(DS(fz1ae->gnavt))
          SP22->(DS(mnt_dtod(fz1->ddoc)+fz1at->kmtop))
          IF .NOT.buf->(DBSEEK(inv_a->kavt+fz1ae->gnavt+fz2->tabn+fz1at->kmtop))
              buf->(DBAP())
              buf->kavt :=inv_a->kavt
              buf->gnavt  :=  fz1ae->gnavt
              buf->tabn :=  fz2->tabn
              buf->kmtop:=  fz1at->kmtop
          ENDIF
          IF EVAL(b_block)
            buf->zaprav +=   fz1at->zapr
          ENDIF
            IF EVAL(b_block)
               buf->rgnor +=   fz1ae->rgnor
               buf->rgfak +=   fz1ae->rgfak
               IF l_norma
                  buf->rgsum +=   fz1ae->rgnor * sp22->koef * sp22->prise
               ELSE
                  buf->rgsum +=   fz1ae->rgfak * sp22->koef * sp22->prise
               ENDIF
            ELSE
                IF l_norma
                    m_kvo:= fz1AE->rgnor
                    m_stm:=fz1ae->rgnor * sp22->koef * sp22->prise
                ELSE
                    m_kvo:= fz1AE->rgfak
                    m_stm:=fz1ae->rgfak * sp22->koef * sp22->prise
                ENDIF
               buf->inkvo-=m_kvo
               buf->insum-=m_stm
              ENDIF
      ENDIF
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
      fz1->(DBSKIP())
      m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()/2))
  ENDDO
  CLOSE base FZ1,fz1ae,fz1at,fz2
IF .not.l_finish
  NET USE (m_mainpath+"fp1") INDEX (m_mainpath+"fp1") NEW READONLY
  NET USE (m_mainpath+"fp2") NEW READONLY
  DO WHILE .NOT.fp2->(EOF())
    // Найти запись в Fp1
      IF .NOT.Fp1Check(@n_error);LOOP;ENDIF
      IF fp1->maket=="02".AND.mnt_month(fp1->mnt)<=m_month  // Водители
        inv_a->(DS(fp1->num))
        DO WHILE fp1->vnum==fp2->vnum.AND..NOT.fp2->(EOF())
          IF .NOT.buf->(DBSEEK(inv_a->kavt+fp1->num+fp1->tabn+RIGHT(ALLTRIM(fp2->dbt),2)))
              buf->(DBAP())
              buf->kavt   := inv_a->kavt
              buf->gnavt  := fp1->num
              buf->tabn   := fp1->tabn
              buf->kmtop  := RIGHT(ALLTRIM(fp2->dbt),2)
          ENDIF
          IF mnt_month(fp1->mnt) <= m_month.AND.mnt_month(fp1->mnt)>=m_month1.AND.LEFT(fp2->crt,2)<>"04" //Запись из расчетного периода
            buf->zaprlzk +=   fp2->kvo2
            buf->zaprstm +=   fp2->stm
          ELSE
            buf->inkvo += fp2->kvo2
            buf->insum +=   fp2->stm
          ENDIF
          fp2->(DBSKIP())
        ENDDO
      ELSE
        DO WHILE fp1->vnum==fp2->vnum.AND..NOT.fp2->(EOF())
          fp2->(DBSKIP())
          m_gauge:=DispGauge(m_gauge,fp2->(RECNO()/LASTREC()/2)+0.5)
        ENDDO
      ENDIF
      IF INKEY()==K_ESC
        IF ANSWERu("Прервати вивiд?")==YES
          l_finish:=.t.
          EXIT
        ENDIF
      ENDIF
  ENDDO
  IF n_error<>0
    DispError("При розрахунку знайдено ;"+STR(n_error,4)+" помилок")
  ENDIF
CLOSE BASE fp1,fp2
ENDIF
IF .not.l_finish
  m_gauge:=DispGauge(m_gauge,1.00)
  SELECT buf
  buf->(DBGOTOP())
  DO WHILE .NOT.buf->(EOF())
    buf->outkvo:=buf->inkvo+buf->zaprlzk-IF(l_norma,buf->rgnor,buf->rgfak)
    buf->outsum:=buf->insum+buf->zaprstm-buf->rgsum
    buf->ekon  :=buf->rgnor-buf->rgfak
    buf->ekon1 :=buf->zaprlzk-IF(l_norma,buf->rgnor,buf->rgfak)
    buf->(DBSKIP())
  ENDDO
  FormMsh(SELECT("buf"),"55",STRZERO(m_month,2),STRZERO(m_month1,2))
  INDEX ON buf->tabn+buf->kavt+buf->gnavt+buf->kmtop to (m_temppath+"buf57")
  buf->(DBGOTOP())
  FormMsh(SELECT("buf"),"57",STRZERO(m_month,2),STRZERO(m_month1,2))
ENDIF
DelGauge(m_gauge)
CLOSE base sp10,msh,buf,sp13a,inv_a,SP22
RETURN .T.
/*
* Поиск соответстующей записи в fp1
*
*/
Function Fp1Check(n_error)
LOCAL m_vnum
      IF Fp1->vnum<>Fp2->vnum
        IF .NOT.Fp1->(DS(Fp2->vnum))
          IF n_error==0
            DispError("Знайдена проводка без заголовку")
          ENDIF
          n_error++
          // Если ошибка пропускаем все записи fp2 с таким внутренним номером
          m_vnum:=Fp2->vnum
          DO WHILE .NOT.fp2->(EOF()).and.Fp2->vnum==m_vnum
            fp2->(DBSKIP())
          ENDDO
          RETURN .F.
        ENDIF
      ENDIF
RETURN .T.
