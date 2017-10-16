FUNCTION cr1
  LOCAL m_str:="",m_recno
//  LOCAL m_syspath:="e:\arm1\js\"
  LOCAL m_syspath:="d:\buhgal\temp\"
NET USE (m_syspath+"DBROWSE") INDEX (m_syspath+"DBROWSE") ALIAS SPTABL  NEW READONLY
NET USE (m_syspath+"SCREEN") INDEX (m_syspath+"SCREEN") NEW
NET USE (m_syspath+"DBRTB") INDEX (m_syspath+"DBRTB")     ALIAS SPTABL1 NEW READONLY
NET USE (m_syspath+"TBGET") INDEX (m_syspath+"TBGET") NEW
DO WHILE .NOT.sptabl1->(EOF())
  IF LEFT(sptabl1->name,2)=="SP".OR.LEFT(sptabl1->name,3)=="INV"
    // Сформировать экран
    sptabl->(DS(sptabl->name))
    DO WHILE sptabl1->name==sptabl->name
      sptabl-(DBSKIP())
    ENDDO
    IF INKEY(20)<>K_ESC
      // Занести данные
      screen->(DBAP())
      screen->fl:=screen->p01:=sptabl1->name
      screen->row:=0
      screen->col:=0
      screen->high:=23
      screen->width:=79
      screen->vd:=m_str
      sptabl->(DBGOTO(m_recno))
      DO WHILE sptabl1->name==sptabl->name
        sptabl-(DBSKIP())
      ENDDO




  sptabl1-(DBSKIP())
ENDDO
