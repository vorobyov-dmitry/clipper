#include "new.ch"
STATIC c_disk:=" "
STATIC n_file:=1,n_dir:=1,n_disk:=0
MEMVAR m_temppath
// #define TEST
#ifdef TEST
Function Test
  WaitMESSAge("����["+GetFname()+"]")
RETURN .t.
#endif
FUNCTION  copyfl(a_file,s_name)
   LOCAL m_str,i:=1,NumDisk:=1,m_file
   LOCAL m_proc,l_return:=.t.,k,j,s_lastdisk:=""
   LOCAL m_msg:=IF(s_name==NIL,"",s_name)+END_LINE+"���i� ����� "+DMY()+TIME()+END_LINE
IF .NOT.GetFloppy()
  RETURN .f.
ENDIF
m_proc := InitGauge("���i���  �� ��᪥��",2)
SSETVERIFY(.t.)
IF NextDisk(numDisk)
  MEMOWRIT(c_disk+":\disk.dsk",m_msg+"�i᪥� N "+STRZERO(numDisk++,3))
ELSE
  l_return:=.f.
ENDIF
WriteList(a_file,m_msg)
DO WHILE i<=LEN(a_file).AND.L_return
   DispGauge(m_proc, (i-1)/LEN(a_file))
   m_file:=c_disk+":\"+TOKEN(a_file[i],":\")
   FILECOPY(a_file[i],m_file,.t.)
   k:=1
   DO WHILE FILECOPEN().AND.L_return
     IF NextDisk(numDisk)
      MEMOWRIT(c_disk+":\disk.dsk",m_msg+"�i᪥� N "+STRZERO(numDisk++,3))
     ELSE
      FILECCLOSE()
      l_return:=.f.
      EXIT
     ENDIF
     FILECCONT(TOKEN(m_file,".",1)+"."+STRZERO(k,3));k++
   ENDDO
   IF l_return
    SETFATTR(a_file[i],CLEARBIT(FILEATTR(a_file[i]),6))
  ENDIF
   i++
ENDDO
IF l_return
   m_file:=FOPEN(c_disk+":\disk.dsk",2)
   FSEEK(m_file,LEN(m_msg)+3)
   FWRITE(m_file,"�",1)
   FCLOSE(m_file)
ENDIF
DelGauge(m_proc)
SSETVERIFY(.f.)
RETURN l_return

FUNCTION  restfl()
   LOCAL m_str,i:=1,NumDisk:=2,m_file,a_file:={},m_name,l_last
   LOCAL m_proc,l_return:=.t.,k,j,s_lastdisk:="",m_msg
IF .NOT.GetFloppy()
  RETURN .f.
ENDIF
  l_return:=.f.
IF InsDisk(1,,@l_last)
  IF ReadList(@a_file,@m_name,@m_msg)
    IF ANSWER("�� �i᪥�i ����ᠭ� "+m_name+";��� "+SUBSTR(m_msg,14,LEN(m_msg)-21)+";�६� "+SUBSTR(m_msg,LEN(m_msg)-7)+";����⠭�������� ?")==YES
      l_return:=.t.
    ENDIF
  ENDIF
ENDIF
IF .NOT.l_return
  RETURN .f.
ENDIF
SSETVERIFY(.t.)
m_proc := InitGauge("�i���������: "+m_name ,2)
i:=1;m_file:=c_disk+":\"+TOKEN(a_file[1],":\");k:=1
DO WHILE i<=LEN(a_file).AND.L_return
   DispGauge(m_proc, (i-1)/LEN(a_file))
   IF .NOT.FILE(m_file)
    IF k<>1
      i++;m_file:=c_disk+":\"+TOKEN(a_file[i],":\");k:=1
    ENDIF
    DispError("�� ��᪥�i �i����i� 䠩� "+m_file)
    l_return:=.f.;EXIT
  ENDIF
  IF k==1
    FILECOPY(m_file,m_temppath+TOKEN(a_file[i],":\"))
  ELSE
    FILEAPPEND(m_file,m_temppath+TOKEN(a_file[i],":\"))
  ENDIF
  IF i<LEN(a_file).AND.FILE(c_disk+":\"+TOKEN(a_file[i+1],":\"))
    i++;m_file:=c_disk+":\"+TOKEN(a_file[i],":\");k:=1
    LOOP
  ENDIF
  IF l_last
    IF i==LEN(a_file)
      l_return:=.t.;EXIT
    ELSE
      DispError("�� ��⠭�i� �i᪥�i �i����i� 䠩��;"+c_disk+":\"+TOKEN(a_file[i+1],":\"))
      l_return:=.f.;EXIT
    ENDIF
  ENDIF
  IF .NOT.InsDisk(NumDisk++,m_msg,@l_last)
    l_return:=.f.;EXIT
  ENDIF
  m_file:=TOKEN(m_file,".",1)+"."+STRZERO(k,3)
  k++
ENDDO
DelGauge(m_proc)
SSETVERIFY(.f.)
IF l_return
  // ����⠭����� ��室�� 䠩�
  k:=LEN(a_file)
  FOR i:=1 TO k
    FERASE(a_file[i])
    FILEMOVE(m_temppath+TOKEN(a_file[i],":\"),a_file[i])
  NEXT
ENDIF

RETURN l_return

FUNCTION  restfl1()
   LOCAL m_str,i:=1,NumDisk:=2,m_file,a_file:={},m_name,l_last
   LOCAL m_proc,l_return:=.t.,k,j,s_lastdisk:="",m_msg
IF .NOT.GetFloppy()
  RETURN .f.
ENDIF
  l_return:=.f.
IF InsDisk(1,,@l_last)
  IF ReadList(@a_file,@m_name,@m_msg)
    IF ANSWER("�� �i᪥�i ����ᠭ� "+m_name+";��� "+SUBSTR(m_msg,14,LEN(m_msg)-21)+";���   "+SUBSTR(m_msg,LEN(m_msg)-7)+";������� ?")==YES
      l_return:=.t.
    ENDIF
  ENDIF
ENDIF
IF .NOT.l_return
  RETURN .f.
ENDIF
SSETVERIFY(.t.)
m_proc := InitGauge("�����: "+m_name ,2)
i:=1;m_file:=c_disk+":\"+TOKEN(a_file[1],":\");k:=1
DO WHILE i<=LEN(a_file).AND.L_return
   DispGauge(m_proc, (i-1)/LEN(a_file))
   IF .NOT.FILE(m_file)
    IF k<>1
      i++;m_file:=c_disk+":\"+TOKEN(a_file[i],":\");k:=1
    ENDIF
    DispError("�� �i᪥�i �i����i� 䠩� "+m_file)
    l_return:=.f.;EXIT
  ENDIF
  IF k==1
    FILECOPY(m_file,m_temppath+TOKEN(a_file[i],":\"))
  ELSE
    FILEAPPEND(m_file,m_temppath+TOKEN(a_file[i],":\"))
  ENDIF
  IF i<LEN(a_file).AND.FILE(c_disk+":\"+TOKEN(a_file[i+1],":\"))
    i++;m_file:=c_disk+":\"+TOKEN(a_file[i],":\");k:=1
    LOOP
  ENDIF
  IF l_last
    IF i==LEN(a_file)
      l_return:=.t.;EXIT
    ELSE
      DispError("�� ��⠭�i� �i᪥�i �i����i� 䠩�;"+c_disk+":\"+TOKEN(a_file[i+1],":\"))
      l_return:=.f.;EXIT
    ENDIF
  ENDIF
  IF .NOT.InsDisk(NumDisk++,m_msg,@l_last)
    l_return:=.f.;EXIT
  ENDIF
  m_file:=TOKEN(m_file,".",1)+"."+STRZERO(k,3)
  k++
ENDDO
DelGauge(m_proc)
SSETVERIFY(.f.)
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
    AADD(a_choice,"�i᪮��� "+CHR(ASC("A")-1+i))
  NEXT
  i:=my_menu("���i� �i᪮����",a_choice)
  IF i==0
    c_disk:=" "
    RETURN .f.
  ENDIF
c_disk:=CHR(ASC("A")-1+i)
RETURN .t.
/*                                                       */

FUNCTION NextDisk(var)
  LOCAL m_str,a_dir:={}
  DO WHILE .T.
    WaitMessage("��⠢� "+IF(var==NIL,"����㯭� �i᪥�� ","�i᪥�� N"+STR(var,2))+" � �i᪮��� "+c_disk+";� ���᭨�� ��� ����i��",,.T.)
    DO WHILE .NOT.DISKREADY(c_disk)
      IF INKEY()==K_ESC
        IF ANSWERu("��ࢠ� ���i஢����;�� �������i ?")==YES
          DelMessage(m_str)
          RETURN .F.
        ENDIF
      ENDIF
    ENDDO
    IF .NOT.DISKREADYW(c_disk)
      DispError("�I����� ���饭� �i� ������;���i�i�� �i᪥��")
      KEYBOARD " "
      LOOP
    ENDIF
    DIRCHANGE(c_disk+":\.")
    a_dir:=DIRECTORY(c_disk+":\*.*")
    IF .NOT.EMPTY(a_dir)
      IF ANSWER("�i᪥� �� ����;����� �i᪥��?")==YES
        DelFiles(c_disk+":\")
      ENDIF
    ENDIF
    IF DISKFREE(c_disk)<100000
      DispError("�� �i᪥�i �i�쭮�� �i��� ���� 100 �i������;���i஢���� ���������")
      KEYBOARD " "
      LOOP
    ENDIF
    EXIT
  ENDDO
RETURN .T.
/*                                     */

FUNCTION InsDisk(var,m_msg,l_last)
  LOCAL m_str
//  LOCAL i,j
DO WHILE .t.
    WaitMessage("��⠢� "+IF(var==NIL,"����㯭� �i᪥�� ","�i᪥�� N"+STR(var,2))+" � �i᪮��� "+c_disk+";� ���᭨�� ��� ����i��",,.T.)
      IF INKEY(0.01)==K_ESC
        IF ANSWERu("��ࢠ� ���i஢����;�� �������i ?")==YES
          RETURN .F.
        ENDIF
      ENDIF
    DO WHILE .NOT.DISKREADY(c_disk)
      IF INKEY()==K_ESC
        IF ANSWERu("��ࢠ� ���i஢����;�� �������i ?")==YES
          RETURN .F.
        ENDIF
      ENDIF
    ENDDO
  m_str:=MEMOREAD(c_disk+":\disk.dsk")
  IF VAL(RIGHT(ALLTRIM(MEMOLINE(m_str,250,3)),3))<>var
     DispError("���i୨� ����� �i᪥�;����i��� �i᪥�  N "+STRZERO(var,2))
     LOOP
  ENDIF
  l_last:=IF(SUBSTR(ALLTRIM(MEMOLINE(m_str,250,3)),4,1)=="�",.t.,.f.)
  IF var<>1
    IF ALLTRIM(MEMOLINE(m_str,250,2))<>m_msg
      DispError("�i᪥� �� � ������� ������ ������")
      LOOP
    ENDIF
  ENDIF
  EXIT
ENDDO
RETURN .T.
FUNCTION WaitDisk(m_disk)
LOCAL m_str
DO WHILE .t.
    m_str:=DispMessage("��⠢� �i᪥�� � �i᪮��� "+m_disk+";� ���᭨�� ��� ����i��",,.T.)
    IF INKEY(0)==K_ESC
      DelMessage(m_str)
      RETURN .f.
    ENDIF
    IF DISKREADY(m_disk)
      DelMessage(m_str)
      RETURN .t.
    ENDIF
ENDDO
RETURN .T.
FUNCTION TestFl
   LOCAL m_str
   IF GetFloppy()
   m_str:=DispMessage("��ॢiઠ �i᪥�")
    IF DISKCHECK(c_disk)<0
      DelMessage(m_str)
      DispError("� �i᪮���� �i�ᮢ��� �i᪥�;���i�i��")
      RETURN .F.
    ENDIF
    DelMessage(m_str)
    WaitMessage("�i᪥� � �i᪮���i "+c_disk+" ��ॢi७�;"+;
    "��� i��ଠ�i� ���०���")
    ENDIF
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

STATIC FUNCTION WriteList(a_file,m_name)
LOCAL m_str:=m_name
AEVAL(A_file,{|x|m_str+=x+END_LINE})
MEMOWRIT(c_disk+":\list.txt",m_str)
RETURN .t.

STATIC FUNCTION ReadList(a_file,m_name,m_msg)
LOCAL m_str:=MEMOREAD(c_disk+":\list.txt")
LOCAL n:=MLCOUNT(m_str,254),i
IF .NOT.FILE(c_disk+":\list.txt")
  DispError("��� 䠩�� list ")
  RETURN .f.
ENDIF

m_name:=ALLTRIM(MEMOLINE(m_str,250,1))
m_msg:=ALLTRIM(MEMOLINE(m_str,250,2))
FOR i:=3 TO n
  AADD(a_file,ALLTRIM(MEMOLINE(m_str,250,i)))
NEXT

RETURN .t.

#define COLOR_NORM  1
#define COLOR_HIGH  2
#define COLOR_TITEL 3
#define COLOR_TABL  4

#define MONO1  "W/N"
#define MONO2  "+W/N"
#define MONO3  "N/W"
#define MONO4  "+W/N"
#define COLOR1 "+W/BG"
#define COLOR2 "+G/BG"
#define COLOR3 "+RG/BG"
#define COLOR4 "+W/W"

FUNCTION MyFormat(var)
  LOCAL x,a_choice:={},c_dsk
  IF var==NIL.OR.EMPTY(var)
    IF .NOT.GetFloppy()
      RETURN .F.
    ENDIF
  ENDIF
  c_dsk:=GetDisk()
  DO Case
    CASE FLOPPYTYPE(c_dsk)==1
      x:=DF(c_disk,360,.F.)
    CASE FLOPPYTYPE(c_dsk)==2
      a_choice:={"360","720","1200"}
      x:=My_menu("�i��i��� �i᪮����",a_choice)
      IF x==0
        RETURN .F.
      ENDIF
      x:=VAL(a_choice[x])
      x:=DF(c_disk,x,.F.)
    CASE FLOPPYTYPE(c_dsk)==3
      x:=DF(c_disk,360,.F.)
    CASE FLOPPYTYPE(c_dsk)==4
      a_choice:={"720","1440"}
      x:=My_menu("�i��i��� �i᪮����",a_choice)
      IF x==0
        RETURN .F.
      ENDIF
      x:=VAL(a_choice[x])
      x:=DF(c_disk,x,.F.)
    OTHERWISE
      RETURN .F.
  EndCASE
  IF x==0
    RETURN .T.
  ENDIF
  RETURN .F.
FUNCTION DF(cDrive, nFormat, FmtOption)
  LOCAL cDosScreen  := SAVESCREEN(7, 15, 16, 60)
  LOCAL cDosColor   := SETCOLOR()
  LOCAL cDosCursor  := ROW()*256 + COL()
  LOCAL aDefFormats := { 360, 1200, 720, 1440 }
  LOCAL lVol        := .F.
  LOCAL lDriveLegal := .F.
  LOCAL lErrCode, vName
//                                   {MONO1,MONO2,MONO3,MONO4})

*** �஢�ઠ ����易⥫��� ��ࠬ��஢ � �ਭ�⨥ ���祭�� �� 㬮�砭��
*
//  cls
  IF VALTYPE(cDrive) <> "C"
   cDrive := "A:"                   // ��᪮��� �� 㬮�砭��
  ELSE
   cDrive := UPPER(SUBSTR(cDrive, 1, 1)) + ":"
  ENDIF

  IF VALTYPE(nFormat) <> "N"
   nFormat := 0
  ENDIF

  IF VALTYPE(FmtOption) = "C"      // �஢�ઠ ��ࠬ��஢
   lVol := "V" $ UPPER(FmtOption)
  ENDIF

  lDriveLegal := cDrive $ "A:B:"

  IF lDriveLegal
   IF nFormat = 0                   // ��ଠ� �� 㬮�砭��
    nFormat := aDefFormats[FLOPPYTYPE(cDrive)]
   ELSEIF nFormat = 4
    nFormat := aDefFormats[1]
   ENDIF
  ENDIF

  IF lDriveLegal .AND.;
     "|" + NTOC(nFormat, 10, 4) $;
     "| 160| 180| 320| 360| 720|1200|1440"

//   lTrk80 := nFormat > 360

   SETCOLOR(COLOR1)
    @ 7,15 TO 16,60 DOUBLE
    @ 8,16 CLEAR TO 15,59

   SETCOLOR(COLOR3)
    @ 7,25 SAY " ��ଠ�஢���� �i᪥� "
   SETCOLOR(COLOR1)

   @ 09,17 SAY "0"
   @ 10,17 SAY "1"

   DO WHILE LASTKEY() <> K_ESC
     SETCOLOR(COLOR4)
      @ 9,19,10,58 BOX REPLICATE(" ", 9)
     SETCOLOR(COLOR1)

       @ 8,19 SAY "0....1....2....3....4....5....6....7...."

     @ 12,16 CLEAR TO 14,59
     @ 12,18 SAY "��⠢�� ��᪥�� � ��᪮��� " + cDrive + "  (" +;
                 IIF(nFormat < 1000, STR(nFormat, 3) + "kB",;
                                     STR(nFormat /1000, 3, 1) + "MB") + ")"
     @ 13,18 SAY "������ ���� ������� ��� �த�������"
     @ 15,18 SAY "[ESC]-��室    "

     lErrCode = IF(INKEY(0) == K_ESC, -3, 0)

     IF lErrCode = 0
       @ 12,16 CLEAR TO 14,59
       @ 12,17 SAY "��ଠ�஢���� ��᪥��   _  (___xx)"
       @ 13,17 SAY "������� __ ��஦�� __"

      SETCOLOR(COLOR2)
       @ 12,42 SAY cDrive
       @ 12,46 SAY IIF(nFormat < 1000,;
                   STR(nFormat, 3) + "kB", STR(nFormat/1000, 3, 1) + "��")

       lErrCode := DISKFORMAT(cDrive, nFormat, "CONTROL", "No system.....", 5)

       IF lErrCode = 0
         SETCOLOR(COLOR1)
         IF lVol
           vName := "DATA       "
           vName := CHARREM(" .", vName)
           IF .NOT. EMPTY(vName)
             VOLUME(cDrive + vName)
           ENDIF
         ENDIF

         IF ALERT( "��ଠ�஢��� �� ��᪥��?", {"��","���"}) != 1
           EXIT
         ELSE
           SETLASTKEY(0)
         ENDIF
       ELSEIF lErrCode = -2
         IF ALERT( "�������⨬� �ଠ� ��� ��᪮���� " + cDrive +;
                ";�ଠ�஢��� ����� ��᪥��?", {"��","���"}) != 1
           EXIT
         ELSE
           SETLASTKEY(0)
         ENDIF
       ELSEIF lErrCode = -3
         IF ALERT( "��ଠ�஢���� ��᪥�� ��ࢠ��." +;
               ";��ଠ�஢��� ����� ��᪥��?", {"��","���"}) != 1
         // IF MSG("��ଠ�஢���� ��᪪��� ��ࢠ��." +;
         //        ";��ଠ�஢��� ����� ��᪥��? (�/�)", "��") = "�"
           EXIT
         ELSE
           SETLASTKEY(0)
         ENDIF
       ELSEIF lErrCode = -4
         IF ALERT( "�訡�� �� �ଠ�஢����." +;
               ";��ଠ�஢��� ����� ��᪥��?", {"��","���"}) != 1
         // IF MSG("�訡�� �� �ଠ�஢����." +;
         //        ";��ଠ�஢��� ����� ��᪥��? (�/�)", "��") = "�"
           EXIT
         ELSE
           SETLASTKEY(0)
         ENDIF
       ELSE
         EXIT
       ENDIF
     ENDIF
   ENDDO

   RESTSCREEN(7, 15, 16, 60, cDosScreen)
   SETCOLOR(cDosColor)
   @ cDosCursor/256, cDosCursor % 256 SAY ""
  ELSE
   lErrCode = -9
  ENDIF
RETURN(lErrCode)


***********************************************
* DISKFORMAT() �ࠢ����� �㭪�� ���짮��⥫�
*
FUNCTION CONTROL(nTrack, nHead)
LOCAL ret_val
  IF nTrack >= 0
    SETCOLOR(COLOR4)

//     IF lTrk80
      @ 9 +nHead, 19 +nTrack/2 SAY IIF(nTrack %2 > 0, "�", "�")
//     ELSE
//      @ 9 +nHead,19 +nTrack SAY "�"
//     ENDIF

    SETCOLOR(COLOR2)
     @ 13,25 SAY nHead PICTURE "99"
     @ 13,36 SAY nTrack PICTURE "99"

    ret_val := if(inkey() == K_ESC, 2, 0)
  ELSE
    MSG("���樠������ ��᪥��.........")
    ret_val := 0
  ENDIF
RETURN(ret_val)


*****************************************************
* �뢮� ᮮ�饭�� � ����� ���⢥ত����
*
STATIC FUNCTION MSG(msg, val_keys)
LOCAL ret_val, old_color := SETCOLOR(COLOR1)

 IF val_keys <> NIL
  SOUND(200, 2, .T.)
  val_keys := val_keys + chr(K_ESC)
 ENDIF

 @ 12,16 CLEAR TO 14,59

 IF ";" $ msg
  @ 12,18 SAY SUBSTR(msg, 1, at(";", msg) -1)
  @ 13,18 SAY SUBSTR(msg, at(";", msg) +1)
 ELSE
  @ 12,18 SAY msg
 ENDIF

 ret_val := " "
 IF val_keys <> NIL
  DO WHILE .T.
   ret_val := UPPER(CHR(INKEY(0)))
   IF VALTYPE(val_keys) == "C"
     IF ret_val $ val_keys
      EXIT
     ENDIF
   ELSE
     EXIT
   ENDIF
  ENDDO
 ENDIF

 SETCOLOR(old_color)
RETURN(ret_val)
Function GetFname()
  LOCAL a_disk:={},m_key,i,n,m_browse1,m_browse2,m_str,m_col,L_delete:=.t.
  LOCAL m_disk:=DiskNAME(),c_file:="",m_state:=3,j
  LOCAL c_dir:=DIRNAME(m_disk),m_screen:=SAVESCREEN(0,0,MAXROW(),MAXCOL())
  LOCAL a_dir,a_file
  LOCAL a_str:={"-------"}
  SAVEPAR()
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
 m_col:block:={||IF(LEN(a_dir)>0,PADR(a_dir[n_dir,1],12),"���-਩ ��� ")}
 m_col:ColorBlock:={||{1,2}}
 m_browse2:ColorSpec:="w/b,n/w"
 m_browse2:GoBottomBlock:={||n_dir:=LEN(a_dir)}
 m_browse2:GotopBlock:={||n_dir:=1}
 m_browse2:SkipBlock:={|x|SkipBr(x,@n_dir,LEN(a_dir))}
 m_browse2:AddColumn(m_col)

 @0,0,MAXROW(),60 Box  B_SINGLE+" " COLOR "w/b"
 @0,0 SayDisp PADC("���i� 䠩��",60) COLOR "B/W"
 @MAXROW(),1 SayText PADC("~1<"+CHR(26)+","+CHR(27)+">~2-���室,~1<Alt+F1>~2-�롮� ��᪠,~1<ENTER>~2-�롮� 䠩��",70) COLOR "R/W,n/w"
 @1,2 SayDisp "�i�:" COLOR "gr+/b"
 @1,8 SayDisp PADR(a_disk[n_disk],50) COLOR "w+/B"
 @3,4 SayDisp "�i४��i� " COLOR "gr+/b"
 @3,26 SayDisp "����� " COLOR "gr+/b"
  m_browse2:Autolite:=.f.
  m_browse2:Dehilite()
  m_browse2:refreshCurrent()
  STABILIZE BROWSE m_browse2
// DispDisk(a_disk,m_disk)
 @MAXROW()-1,2 SayDisp "���࠭��� 䠩�" COLOR "gr+/b"
 @2,2 SayDisp "���. �i४��i� " COLOR "gr+/b"
 @2,18 SayDisp UPPER(LEFT(a_disk[n_disk],1)+":"+IF(EMPTY(c_dir),"\",c_dir)) COLOR "w+/b"
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
        IF DRIVETYPE(a_disk[n_disk])==2
          IF .NOT.WaitDisk(a_disk[n_disk])
            lOOP
          ENDIF
        ENDIF
          c_dir:=DIRNAME(LEFT(a_disk[n_disk],1))
          IF c_dir=="\"
            c_dir:=""
          ENDIF
         @2,18 SayDisp PADR(UPPER(LEFT(a_disk[n_disk],1)+":"+IF(EMPTY(c_dir),"\",c_dir)),42) COLOR "w+/b"
          a_dir:=DIRECTORY(LEFT(a_disk[n_disk],1)+":"+c_dir+"\*.*","D")
          a_file:=DIRECTORY(LEFT(a_disk[n_disk],1)+":"+c_dir+"\*.*")
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
       @2,18 SayDisp PADR(UPPER(LEFT(a_disk[n_disk],1)+":"+IF(EMPTY(c_dir),"\",c_dir)),42) COLOR "w+/b"
        a_dir:=DIRECTORY(LEFT(a_disk[n_disk],1)+":"+c_dir+"\*.*","D")
        a_file:=DIRECTORY(LEFT(a_disk[n_disk],1)+":"+c_dir+"\*.*")
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
        c_file:=UPPER(LEFT(a_disk[n_disk],1)+":"+c_dir)+"\"+LOWER(ALLTRIM(a_file[n_file][1]))
        @MAXROW()-1,18 SayDisp c_file COLOR "GR+/N"
        IF inkey(0)==K_ENTER
          SAVEPAR(1)
          RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
          RETURN c_file
        ENDIF
        @MAXROW()-1,18 SayDisp BLANK(c_file,.t.) COLOR "w+/b"
        c_file:=""
      ENDCASE
  ENDCASE
ENDDO
SAVEPAR(1)
RESTSCREEN(0,0,MAXROW(),MAXCOL(),m_screen)
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
  RETURN PADC("������ ���",27)
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
EXTERNAL calcul

