#include "new.ch"
STATIC c_disk:=" "
STATIC n_file:=1,n_dir:=1,n_disk:=0
MEMVAR m_workpath
FUNCTION  copyfl(m1)
   LOCAL m_str,i:=1,NumDisk:=1,m_file
   LOCAL m_proc,l_return:=.t.,k,j,s_lastdisk:=""
IF .NOT.GetFloppy()
  RETURN .f.
ENDIF
IF WaitDisk()
SSETVERIFY(.t.)
IF ANSWERu("����� �i᪥��?")==YES
  DelFiles(c_disk+":\")
ENDIF
i:=FILECOPY(m_workpath+"fl2.dbf",c_disk+":\"+m1)
WaitMessage("���i��� �����襭�",,.t.)
BeepErr()
SSETVERIFY(.f.)
ENDIF
RETURN l_return

*************************************************
#DEFINE   HIGHER 10
#DEFINE   M_ROWFIRST INT((MAXROW()-m_high)/2)+i
#DEFINE   M_COLFIRST INT((MAXCOL()-m_width)/2)+i
STATIC Function My_Menu(m_name,a_choice,m_count,l_clear)
  LOCAL m_WIDTH:=0,m_high,m_screen,m_key,i:=IF(m_count==NIL,0,m_count),;
  l_restore:=IF(l_clear==NIL,.t.,l_clear)
  AADD(a_choice,NIL)
  AINS(a_choice,1)
  a_choice[1]:="���i�"
  AEVAL(a_choice,{|p|IF(LEN(p)>m_width,m_width:=LEN(p),NIL)})
  IF(LEN(m_name)>m_width,m_width:=LEN(m_name),NIL)
  IF(LEN(a_choice)>HIGHER,m_high:=HIGHER,m_high:=LEN(a_choice))
  m_screen:=SAVESCREEN(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1+1,M_COLFIRST+m_width+1+2)
  @M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1,M_COLFIRST+m_width+1 ;
  BOX B_DOUBLE_SINGLE+SPACE(1) COLOR ("w+/b,gr+/n,,,w+/b")
  @M_ROWFIRST-1,M_COLFIRST SayDisp m_name COLOR ("r+/b")
  SHADOW(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1,M_COLFIRST+m_width+1)
  SETCOLOR("w+/b,n/w")
  m_key:=ACHOICE(M_ROWFIRST,M_COLFIRST,M_ROWFIRST+m_high,M_COLFIRST+m_width,a_choice)
  ADEL(a_choice,1)
  ASIZE(a_choice,LEN(a_choice)-1)
  IF(l_restore,RESTSCREEN(M_ROWFIRST-1,M_COLFIRST-1,M_ROWFIRST+m_high+1+1,M_COLFIRST+m_width+1+2,m_screen),NIL)
  RETURN( IF(m_key==1.OR.m_key==0,0,m_key-1))

/*   �롮� 䫮���  - ��᪠      */

FUNCTION GetFloppy()
  LOCAL a_choice:={},i
  FOR i:=1 TO NUMDISKF()
    AADD(a_choice,"��᪮��� "+CHR(ASC("A")-1+i))
  NEXT
  i:=my_menu("���i� ��᪮����",a_choice)
  IF i==0
    c_disk:=" "
    RETURN .f.
  ENDIF
c_disk:=CHR(ASC("A")-1+i)
RETURN .t.
FUNCTION WaitDisk()
LOCAL m_str
DO WHILE .t.
    m_str:=DispMessage("��⠢� �i᪥�� � ��᪮��� "+c_disk+";� ���᭨�� ��� ����i��",,.T.)
    IF INKEY(0)==K_ESC
      DelMessage(m_str)
      RETURN .f.
    ENDIF
    IF DISKREADY(c_disk)
      DelMessage(m_str)
      RETURN .t.
    ENDIF
ENDDO
RETURN .T.
Function GetDisk()
RETURN c_disk

Function DelFiles(m_path)
  LOCAL a_dir:=DIRECTORY(m_path+"*.*","D")
  LOCAL i,j
  FOR i:=LEN(a_dir) TO 1 STEP -1
    IF LEFT(a_dir[i][1],1)="."
      ADEL(a_dir,i);ASIZE(a_dir,LEN(a_dir)-1)
    ENDIF
  NEXT
  FOR i:=1 TO LEN(a_dir)
    IF a_dir[i,5]=="D"
      DelFiles(m_path+ALLTRIM(a_dir[i][1])+"\")
      j:=DirRemove(m_path+a_dir[i][1])
    ELSE
      FERASE(m_path+a_dir[i,1])
    ENDIF
  NEXT
RETURN .t.
Static Function SkipBr(x,i,n)
LOCAL j
IF x>0
    j:=IF(i+x<=n,x,n-i)
ELSE
    j:=IF(i+x>=1,x,1-i)
ENDIF
i+=j
RETURN j
EXTERNAL calcul

