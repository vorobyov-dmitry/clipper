#INCLUDE "NEW.CH"
memvar m_mainpath,m_bufpath,m_sprpath,m_temppath,m_syspath,m_exepath,m_workpath
MEMVAR m_uchpath
FUNCTION Perehod(m_var)

   SetCancel ( .f. )
   SetCursor (0)
   SETBLINK(.f.)
   Set ( _SET_ESCAPE     , .f. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH
   SET EPOCH TO 1960
   CSETSAFETY(.F.)
// ����䨪��� ����
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // ��⠫�� � ���୮� ��
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // ��⠫�� ��� .EXE ����� �����
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // ��⠫�� � �᭮���� ��
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // ��⠫�� � �ࠢ�筨����
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // ��⠫�� � ���୮� ��
   PUBLIC   m_workpath  :=m_var
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
   PUBLIC   m_syspath   := 'd:\buhgal\js\'  // ��⠫�� �  ��⥬��� ���ଠ樥�

// ����䨪��� ����

T1(m_workpath+"\bf\",m_bufpath,"fdbcr.dbf")
T1(m_workpath+"\bf\",m_bufpath,"fz1.dbf")
T1(m_workpath+"\bf\",m_bufpath,"fd1.dbf")
FILECOPY(m_workpath+"\bf\boln1.dbf",m_bufpath+"boln1.dbf")
FILECOPY(m_workpath+"\bf\boln2.dbf",m_bufpath+"boln2.dbf")
FILECOPY(m_workpath+"\bf\fvnum.dbr",m_bufpath+"fvnum.dbr")
T2(m_bufpath+"fz1")
T2(m_bufpath+"fd1")


// ����䨪��� �᭮���� ����

T1(m_workpath+"\mn\",m_mainpath,"fdbcr.dbf")
T1(m_workpath+"\mn\",m_mainpath,"fz1.dbf")
T1(m_workpath+"\mn\",m_mainpath,"fd1.dbf")
T1(m_workpath+"\mn\",m_mainpath,"flish.dbf")

FILECOPY(m_workpath+"\mn\boln1.dbf",m_mainpath+"boln1.dbf")
FILECOPY(m_workpath+"\mn\boln2.dbf",m_mainpath+"boln2.dbf")
FILECOPY(m_workpath+"\mn\fvnum.dbr",m_mainpath+"fvnum.dbr")
FILECOPY(m_workpath+"\mn\fl00.dbf",m_mainpath+"fl00.dbf")
FILECOPY(m_workpath+"\mn\fl01.dbf",m_mainpath+"fl01.dbf")
FILECOPY(m_workpath+"\mn\fl02.dbf",m_mainpath+"fl02.dbf")
FILECOPY(m_workpath+"\mn\fnpch.dbf",m_mainpath+"fnpch.dbf")
FILECOPY(m_workpath+"\mn\fzn.dbf",m_mainpath+"fzn.dbf")
FILECOPY(m_workpath+"\mn\fzn.dbt",m_mainpath+"fzn.dbt")
T2(m_mainpath+"fz1")
T2(m_mainpath+"fd1")

// ����䨪��� init

T1(m_workpath+"\bh\",m_exepath,"init.dbf")

// ����䨪��� 1_2

FILECOPY(m_workpath+"\1_2\buf13a.dbf",m_uchpath+"buf13a.dbf")
USE (m_uchpath+'inst1') INDEX (m_uchpath+'inst1')
APPEND FROM (m_workpath+"\1_2\_inst1.dbf")
USE

// ����䨪��� JS

USE (m_syspath+'inst1') INDEX (m_syspath+'inst1')
APPEND FROM (m_workpath+"\JS\_inst1.dbf")
USE

// ����䨪��� sp
T1(m_workpath+"\sp\",m_sprpath,"inv_a.dbf")
T1(m_workpath+"\sp\",m_sprpath,"inv_t.dbf")
T1(m_workpath+"\sp\",m_sprpath,"sp08.dbf")
T1(m_workpath+"\sp\",m_sprpath,"sp10.dbf")
T1(m_workpath+"\sp\",m_sprpath,"sp22.dbf")
USE (m_sprpath+"SP22")
REPL field->mnt WITH "99"+field->month ALL
USE
USE (m_sprpath+"SP08")
APPE FROM (m_workpath+"\sp\sp08")
USE
Cflish()
RETURN .T.

STATIC FUNCTION T1(m_path1,m_path2,m_file1)
IF FILE(m_temppath+m_file1)
  FERASE(m_temppath+m_file1)
ENDIF
FILECOPY(m_path1+m_file1,m_temppath+m_file1)
USE (m_temppath+m_file1)
ZAP
APPEND FROM (m_path2+m_file1)
USE
FERASE(m_path2+m_file1)
FILECOPY(m_temppath+m_file1,m_path2+m_file1)
RETURN .t.
STATIC FUNCTION T2(m_file)
USE (m_file)
DO WHILE .NOT.EOF()
  field->mnt:="99"+STRZERO(MONTH(field->ddoc),2)
  DBSKIP()
ENDDO
USE
RETURN .T.
Function CFlish()
  LOCAL m_gauge:=InitGauge("�����㭮� �ᮡ��⮣� ��㭪�",1)
  USE (m_mainpath+"fz1") NEW READONLY
  USE (m_mainpath+"fz2") NEW READONLY
  USE (m_mainpath+"fz3") NEW READONLY
  USE (m_mainpath+"flish") NEW
  pack
  INDEX ON flish->month+flish->tabn+flish->kopu TO (m_temppath+"flish")
  DO WHILE .NOT.fz1->(EOF())
        IF pFilpoz("fz2","vnum1","fz1")
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF fz1->vdoc<>38     // � ���㬥�� ������ ���� ������ � fz3
               IF .NOT.pFilpoz("fz3","vnum2","fz2")
                  SKIP 1 ALIAS fz2
                  LOOP
               ENDIF
                  IF .NOT.flish->(DBSEEK(STRZERO(MONTH(fz1->ddoc),2)+fz2->tabn+fz3->kopu))
                     flish->(DBAP())
                     flish->month:=STRZERO(MONTH(fz1->ddoc),2)
                     flish->tabn :=fz2->tabn
                     flish->kopu:=fz3->kopu
                  ENDIF
                  flish->otdn+=fz2->otdn
                  flish->oths+=fz2->oths
                  flish->st:="Z"
            ELSE
               IF buf->(DS(STRZERO(MONTH(fz1->ddoc),2)+fz2->tabn+'000'))
                  flish->month:=STRZERO(MONTH(fz1->ddoc),2)
                  flish->tabn :=fz2->tabn
                  flish->kopu:="000"
               ENDIF
                  flish->otdn+=fz2->otdn
                  flish->oths+=fz2->oths
                  flish->st:="Z"
            ENDIF
            fz2->(DBSKIP())
         ENDDO
        ENDIF
      fz1->(DBSKIP())
     m_gauge:=DispGauge(m_gauge,fz1->(RECNO()/LASTREC()))
  ENDDO
CLOSE base FZ1,FZ2,FZ3,flish
RETURN .T.




