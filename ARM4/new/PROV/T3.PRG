#include "new.ch"
Function test
  LOCAL m_mainpath:="d:\buhgal\mn\",m_temppath:="d:\buhgal\temp\",;
  m_computer:=1

  NET USE (m_mainpath+"Fp1") INDEX (m_mainpath+"Fp1a")  NEW // ALIAS File1
  IF .NOT.Fp1->(NetFlock())
    DispError("Неможливо заблокувати; файл основної бази даних; Fp1")
    RETURN .f.
  ENDIF
  NET USE (m_mainpath+"Fp2")  NEW // ALIAS File2
  IF .NOT.Fp2->(NetFlock())
    DispError("Неможливо заблокувати; файл основної бази даних; Fp2")
    RETURN .f.
  ENDIF
/*  USE (m_temppath+"fp1") INDEX (m_temppath+"fp1") NEW
  USE (m_temppath+"fp2") INDEX (m_temppath+"fp2") NEW
  NET USE (m_mainpath+"fvnum.dbs") NEW
    fvnum->(DBGOTO(1))
    IF fvnum->(NetRlock())
      fvnum->reg:=SETBIT(fvnum->reg,m_computer)
      fvnum->(DBCOMMIT())
    ELSE
      DispError("Вiдмовлено в доступi")
      Close Fvnum
      RETURN .f.
    ENDIF
  Fvnum->(DBUNLOCK())
  Fp1->(DBUNLOCK());Fp2->(DBUNLOCK())
  CLOSE BASE Fvnum,Fp1,Fp2 */
  Select fp1
  APPEND FROM (m_temppath+"Fp1")
//  file1->(__DBAPP(m_temppath+"Fp1",{}))
//    file2->(__DBAPP(m_temppath+"Fp2",{}))
RETURN .t.
