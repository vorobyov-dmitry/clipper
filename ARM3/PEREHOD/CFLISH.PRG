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
// Модификация буфера
   PUBLIC   m_bufpath   := 'd:\buhgal\bf\'  // каталог с буферной БД
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
   PUBLIC   m_exepath   := 'd:\buhgal\bh\'  // каталог для .EXE модуля пакета
   PUBLIC   m_mainpath  := 'd:\buhgal\mn\'  // каталог с основной БД
   PUBLIC   m_sprpath   := 'd:\buhgal\sp\'  // каталог со справочниками
   PUBLIC   m_temppath  := 'd:\buhgal\temp\' // каталог с буферной БД
   PUBLIC   m_workpath  :=m_var
   PUBLIC   m_uchpath   :='d:\buhgal\1_2\'
   PUBLIC   m_syspath   := 'd:\buhgal\js\'  // каталог с  системной информацией
Cflish()
RETURN .T.
Function CFlish()
  LOCAL m_gauge:=InitGauge("Розрахунок особистого рахунку",1)
  USE (m_mainpath+"fz1") NEW READONLY
  USE (m_mainpath+"fz2") NEW READONLY
  USE (m_mainpath+"fz3") NEW READONLY
  USE (m_mainpath+"flish") NEW
  pack
  INDEX ON flish->month+flish->tabn+flish->kopu TO (m_temppath+"flish")
  DO WHILE .NOT.fz1->(EOF())
        IF pFilpoz("fz2","vnum1","fz1")
         DO WHILE fz1->vnum1=fz2->vnum1.AND..NOT.fz2->(EOF())
            IF fz1->vdoc<>38     // В документе должна быть запись в fz3
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
/*
Function CFlish()
  LOCAL m_gauge:=InitGauge("Розрахунок особистого рахунку",1)
  USE (m_mainpath+"FD1") NEW READONLY
  USE (m_mainpath+"FD2") NEW READONLY
  USE (m_mainpath+"flish") NEW
  pack
  INDEX ON flish->month+flish->tabn+flish->kopu TO (m_temppath+"flish")
  DO WHILE .NOT.FD1->(EOF())
        IF pFilpoz("FD2","vnumA","FD1")
         DO WHILE FD1->vnumA==FD2->vnuma.AND..NOT.FD2->(EOF())
                  IF .NOT.flish->(DBSEEK(STRZERO(MONTH(FD1->ddoc),2)+FD2->tabn+FD1->kopu))
                     flish->(DBAP())
                     flish->month:=STRZERO(MONTH(FD1->ddoc),2)
                     flish->tabn :=FD2->tabn
                     flish->kopu:=FD1->kopu
                  ENDIF
                  flish->otdn+=FD2->KVO
                  flish->oths+=FD2->GLV
            FD2->(DBSKIP())
         ENDDO
        ENDIF
      FD1->(DBSKIP())
     m_gauge:=DispGauge(m_gauge,FD1->(RECNO()/LASTREC()))
  ENDDO
CLOSE base FD1,FD2,flish
RETURN .T.
*/
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION pFilPoz
PARAMETERS  m_nmfl_1, m_nmpl_1, m_nmfl_2

LOCAL  m_fict_zap
LOCAL  m_fict_al
PRIVATE m_1
m_fict_al := SELECT()
SELECT (m_nmfl_1)
m_fict_zap :=  RECNO()
m_1 := ALLTRIM(m_nmfl_2) + '->' + ALLTRIM(m_nmpl_1)
LOCATE  REST  FOR  &(m_nmpl_1) == &(m_1)
IF  FOUND()
     SELECT( m_fict_al )
     RETURN( .T. )
   ELSE
     GOTO m_fict_zap
     SELECT( m_fict_al )
     RETURN( .F. )
ENDIF




