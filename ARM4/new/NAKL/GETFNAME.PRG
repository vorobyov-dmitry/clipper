#include "new.ch"
STATIC n_file:=1,n_dir:=1,n_disk:=0
Function Test
 WaitMessage("Файл ["+GetFname()+"]")
RETURN .t.

Function GetFname()
  LOCAL a_disk:={},m_key,i,n,m_browse1,m_browse2,m_str,m_col,L_delete:=.t.
  LOCAL m_disk:=DiskNAME(),c_file:="",m_state:=3,j
  LOCAL c_dir:=DIRNAME(m_disk)
  LOCAL a_dir,a_file
  LOCAL a_str:={"-------"}
  IF c_dir=="\"
    c_dir:=""
  ENDIF
  a_dir:=DIRECTORY(m_disk+":"+c_dir+"\*.*","D")
  a_file:=DIRECTORY(m_disk+":"+c_dir+"\*.*")
  n_file:=1;n_dir:=1;n_disk:=0
  n:=LEN(a_dir)
  FOR i:=n TO 1 STEP -1
    IF a_dir[i,5]<>"D".OR.ALLTRIM(a_dir[i,1])=="."
      ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
    ENDIF
  NEXT
  a_dir:=MySort1(a_dir,1)
  a_file:=MySort2(a_file)
  n:=NumDiskF()
 FOR i:=1 TO n
  m_str:=CHR(ASC("A")+i-1)+":"
  AADD(a_disk,m_str)
 NEXT
  n:=NumDiskL()
 FOR i:=1 TO n
  m_str:=CHR(ASC("C")+i-1)+":"
  IF DRIVETYPE(m_str)==3.OR.(DRIVETYPE(m_str)==0.AND.(DISKTYPE(m_str)==248.OR.DISKTYPE(m_str)==254))
    AADD(a_disk,m_str)
  ENDIF
 NEXT
  FOR i:=1 TO LEN(a_disk)
    IF LEFT(a_disk[i],1)==m_disk
//      @1,7 SayDisp a_disk[i] COLOR "w+/b"
      n_disk:=i
    ENDIF
  NEXT
 m_browse1:=TbrowseNew(4,16,MAXROW()-2,58)
 m_col:=TBColumnNew()
 m_col:block:={||MyBlock1(a_file,n_file)}
 m_col:ColorBlock:={||{1,2}}
 m_browse1:ColorSpec:="bg+/b,n/w"
 m_browse1:GoBottomBlock:={||n_file:=LEN(a_file)}
 m_browse1:GotopBlock:={||n_file:=1}
 m_browse1:SkipBlock:={|x|SkipBr(x,@n_file,LEN(a_file))}
 m_browse1:AddColumn(m_col)
 m_browse1:AutoLite:=.f.
 m_browse2:=TbrowseNew(4,1,MAXROW()-2,15)
 m_col:=TBColumnNew()
 m_col:block:={||IF(LEN(a_dir)>0,PADR(a_dir[n_dir,1],12),"Дир-рий нет ")}
 m_col:ColorBlock:={||{1,2}}
 m_browse2:ColorSpec:="w/b,n/w"
 m_browse2:GoBottomBlock:={||n_dir:=LEN(a_dir)}
 m_browse2:GotopBlock:={||n_dir:=1}
 m_browse2:SkipBlock:={|x|SkipBr(x,@n_dir,LEN(a_dir))}
 m_browse2:AddColumn(m_col)

 @0,0,MAXROW(),60 Box  B_SINGLE+" " COLOR "w/b"
 @0,0 SayDisp PADC("Выбор файла",60) COLOR "B/W"
 @MAXROW(),1 SayText PADC("~1<"+CHR(26)+","+CHR(27)+">~2-переход,~1<Alt+F1>~2-выбор диска,~1<ENTER>~2-Выбор файла",70) COLOR "R/W,n/w"
 @1,2 SayDisp "Диск:" COLOR "gr+/b"
 @1,8 SayDisp PADR(a_disk[n_disk],50) COLOR "w+/B"
 @3,4 SayDisp "Директория " COLOR "gr+/b"
 @3,26 SayDisp "Файлы " COLOR "gr+/b"
  m_browse2:Autolite:=.f.
  m_browse2:Dehilite()
  m_browse2:refreshCurrent()
  STABILIZE BROWSE m_browse2
// DispDisk(a_disk,m_disk)
 @MAXROW()-1,2 SayDisp "Выбранный файл" COLOR "gr+/b"
 @2,2 SayDisp "Тек. директория " COLOR "gr+/b"
 @2,18 SayDisp UPPER(m_disk+":"+c_dir) COLOR "w+/b"
 m_str:=""
 DO WHILE .t.
  DO CASE
    CASE m_state==1
      j:=n_disk
      DO WHILE .t.
      FOR i:=1 TO LEN(a_disk)
        IF i==n_disk
          @1,5+3*i SayDisp a_disk[i] COLOR "n/w"
        ELSE
          @1,5+3*i SayDisp a_disk[i] COLOR "w/b"
        ENDIF
      NEXT
      m_key:=INKEY(0)
      DO CASE
        CASE m_key==K_ESC
          n_disk:=j
          EXIT
        CASE m_key==K_ENTER
          EXIT
        CASE m_key==K_RIGHT
          n_disk:=IF(n_disk==LEN(a_disk),1,n_disk+1)
        CASE m_key==K_LEFT
          n_disk:=IF(n_disk==1,n_disk:=LEN(a_disk),n_disk-1)
      ENDCASE
      ENDDO
      @1,8 SayDisp PADR(a_disk[n_disk],50) COLOR "w+/B"
      IF m_key==K_ENTER
        m_disk:=LEFT(a_disk[n_disk],1)
        c_dir:=DIRNAME(m_disk)
        IF c_dir=="\"
          c_dir:=""
        ENDIF
       ENDIF
       @2,18 SayDisp PADR(UPPER(m_disk+":"+c_dir),42) COLOR "w+/b"
        a_dir:=DIRECTORY(m_disk+":"+c_dir+"\*.*","D")
        a_file:=DIRECTORY(m_disk+":"+c_dir+"\*.*")
        n_file:=1;n_dir:=1
        n:=LEN(a_dir)
        FOR i:=n TO 1 STEP -1
          IF a_dir[i,5]<>"D".OR.ALLTRIM(a_dir[i,1])=="."
            ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
          ENDIF
        NEXT
        a_dir:=MySort1(a_dir,1)
        a_file:=MySort2(a_file)
        m_browse1:RowPos:=1;m_browse1:configure()
        m_browse1:Autolite:=.f.;m_browse1:Dehilite()
        Stabilize Browse m_browse1
        m_browse2:RowPos:=1;m_browse2:configure()
        Stabilize Browse m_browse2
        IF .NOT.EMPTY(a_file)
        m_state:=3
      ELSE
        m_state:=2
      ENDIF


    CASE m_state==2
      Display Browse m_browse2
      m_browse2:hilite()
      m_key:=INKEY(0)
      DO CASE
      CASE m_key==K_TAB.OR.m_key==K_RIGHT.AND..NOT.EMPTY(a_file)
       m_state:=3
       m_browse2:Autolite:=.f.
       m_browse2:Dehilite()
       m_browse2:refreshCurrent()
       STABILIZE BROWSE m_browse2
      DEAL BROWSE m_browse2 KEY m_key
      CASE m_key==K_ALT_F1
       m_state:=1
       m_browse2:Autolite:=.f.
       m_browse2:Dehilite()
       m_browse2:refreshCurrent()
       STABILIZE BROWSE m_browse2
      CASE m_key==K_ENTER
        IF a_dir[n_dir,1]==".."
          i:=RAT("\",c_dir)
          c_dir:=SUBSTR(c_dir,1,i-1)
        ELSE
          c_dir:=c_dir+"\"+UPPER(ALLTRIM(a_dir[n_dir,1]))
          // PutStr(@a_str,UPPER(ALLTRIM(a_dir[n_dir,1]))
          AADD(a_str,UPPER(ALLTRIM(a_dir[n_dir,1])))
        ENDIF
       @2,18 SayDisp PADR(UPPER(m_disk+":"+c_dir),42) COLOR "w+/b"
        a_dir:=DIRECTORY(m_disk+":"+c_dir+"\*.*","D")
        a_file:=DIRECTORY(m_disk+":"+c_dir+"\*.*")
        n_file:=1;n_dir:=1
        n:=LEN(a_dir)
        FOR i:=n TO 1 STEP -1
          IF a_dir[i,5]<>"D".OR.ALLTRIM(a_dir[i,1])=="."
            ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
          ENDIF
        NEXT
        a_dir:=MySort1(a_dir,1)
        a_file:=MySort2(a_file)
        m_browse1:RowPos:=1;m_browse1:configure()
        m_browse1:Autolite:=.f.;m_browse1:Dehilite()
        Stabilize Browse m_browse1
        m_browse2:RowPos:=1
        IF (j:=ASCAN(a_dir,{|x|UPPER(x[1])==a_str[LEN(a_str)]}))<>0
            IF LEN(a_str)>2
              ADEL(a_str,LEN(a_str))
              ASIZE(a_str,LEN(a_str)-1)
            ENDIF

          n_dir:=j
          m_browse2:RowPos:=IF(j<=m_browse2:RowCount,j,m_browse2:RowCount)
        ENDIF
        m_browse2:configure()
      ENDCASE
    CASE m_state==3
      Display Browse m_browse1
      m_browse1:hilite()
      m_key:=INKEY(0)
      DO CASE
      CASE m_key==K_TAB.OR.m_key==K_LEFT
       m_state:=2
       m_browse1:Autolite:=.f.
       m_browse1:Dehilite()
       m_browse1:refreshCurrent()
       STABILIZE BROWSE m_browse1
      DEAL BROWSE m_browse1 KEY m_key
      CASE m_key==K_ALT_F1
       m_state:=1
       m_browse1:Autolite:=.f.
       m_browse1:Dehilite()
       m_browse1:refreshCurrent()
       STABILIZE BROWSE m_browse1
      CASE m_key==K_ENTER
        c_file:=UPPER(m_disk+":"+c_dir)+"\"+LOWER(ALLTRIM(a_file[n_file][1]))
        @MAXROW()-1,18 SayDisp c_file COLOR "GR+/N"
        IF inkey(0)==K_ENTER
          RETURN c_file
        ENDIF
        @MAXROW()-1,18 SayDisp BLANK(c_file,.t.) COLOR "w+/b"
        c_file:=""
      ENDCASE
  ENDCASE
ENDDO
RETURN ""
STATIC function MySort1(a_dir,j)
ASORT(a_dir,,,{|x,y|x[j]<y[j]})
RETURN a_dir
STATIC function MySort2(a_dir)
ASORT(a_dir,,,{|x,y|comp1(x[1],y[1])})
RETURN a_dir
STATIC fUnction comp1(x,y)
LOCAL m_str1,m_str2,i
IF (i:=AT(".",x))<>0
  m_str1:=PADR(SUBSTR(x,i+1),3)+PADR(SUBSTR(x,1,i-1),8)
ELSE
  m_str1:="   "+PADR(x,8)
ENDIF
IF (i:=AT(".",y))<>0
  m_str2:=PADR(SUBSTR(y,i+1),3)+PADR(SUBSTR(y,1,i-1),8)
ELSE
  m_str2:="   "+PADR(y,8)
ENDIF
IF m_str1<m_str2
  RETURN .t.
ENDIF
RETURN .f.
Static Function MyBlock1(a_file,n)
LOCAL m_str,i
IF EMPTY(a_file)
  RETURN PADC("Файлов нет",27)
ENDIF

m_str:=LOWER(a_file[n][1])
IF (i:=AT(".",m_str))<>0
  m_str:=PADR(SUBSTR(m_str,1,i-1),8)+"."+PADR(SUBSTR(m_str,i+1),3)
ELSE
  m_str:=PADR(m_str,12)
ENDIF
m_str+=" "+DTOC(a_file[n][3])+" "+STR(a_file[n][2],10)
RETURN m_str
Static Function SkipBr(x,i,n)
LOCAL j
IF x>0
  IF i+x<=n
    j:=x
  ELSE
    j:=n-i
  ENDIF
ELSE
  IF i+x>=1
    j:=x
  ELSE
    j:=1-i
  ENDIF
ENDIF
i+=j
RETURN j
EXTERNAL calc
