#include "new.ch"
Function Ssuda()
  LOCAL m_gauge,m_kopu:="117",m_gauge1,l_first:=.t.
  LOCAL m_kopr:="104",m_ksash:="732999",m_ddoc1:=CTOD(""),m_ddoc2:=CTOD(""),m_screen
  LOCAL m_bufpath:="d:\buhgal\bf\",m_syspath:="d:\buhgal\js\",m_kassapath:="d:\buh\kassa\"
  LOCAL GetList:={}
          VGAPALETTE()
          SetCursor ( 0 )
          setblink(.f.)
          VGAPALETTE(6,30,30,30)
          VGAPALETTE(7,50,50,50)
          VGAPALETTE(10,17,56,17)
          VGAPALETTE(2,14,36,14)
          VGAPALETTE(5,42,16,42)
          VGAPALETTE(13,28,16,43)
   Set ( _SET_ESCAPE     , .t. )
   Set ( _SET_SCOREBOARD , .f. )
   Set ( _SET_BELL       , .f. )
   Set ( _SET_DECIMALS   ,  5  )
   Set ( _SET_DELETED    , .t. )
   Set ( _SET_CONFIRM    , .t. )
   SET CENTURY       OFF
   SET DATE          BRITISH

  IF ANSWERu("Заносити даннi про ссуди в рахунок зар. плати ?")<>YES
    RETURN .f.
  ENDIF
  m_SCREEN :=savescreen(9,15,16,74)
  DispBox(9,15,15,70,B_SINGLE+" ","w+/bg")
  Shadow(9,15,15,70)
  @ 10,17 sayDisp 'Занести данi по ссудам    в рахунок зар. платнi' COLOR "n/Bg"
  @ 11,17 sayDisp '           по КО з           по                 '  COLOR "n/Bg"
  @ 12,17 sayDisp '       Код ссуди'  COLOR "n/Bg"
  @ 13,17 sayDisp '   Код утримання'  COLOR "n/Bg"
  m_ddoc1:=BOM(DATE()-10)
  @ 11,36 get m_ddoc1 COLOR "w/b,gr+/N" VALID (SetDdoc2(@m_ddoc1,@m_ddoc2))
  @ 11,50 get m_ddoc2 COLOR "w/b,gr+/N"  VALID m_ddoc2>=m_ddoc1
  @ 12,36 get m_kopr  COLOR "w/b,gr+/N"
  @ 13,36 get m_kopu  COLOR "w/b,gr+/N"
  SET ESCAPE ON
  read
  restscreen(9,15,16,74,m_screen)
  IF LASTKEY()==K_ESC
      set escape off
      set cursor off
      RETURN .F.
  ENDIF
  USE (m_bufpath+"fd1") NEW
  USE (m_bufpath+"fd2") NEW
  USE (m_syspath+"fvnum") NEW
  USE (m_kassapath+"fks08") NEW



  DO WHILE .NOT. fd1->(EOF())
    IF fd1->oper=="KS".AND.fd1->ddoc>=m_ddoc1.AND.fd1->ddoc<=m_ddoc2
      IF l_first
        IF ANSWERu("База вже мiстить утримання за ссуду;Удаляти цi документи?")<>YES
           EXIT
        ENDIF
        l_first:=.f.
      ENDIF
      IF pFilPoz1('fd1', {||(fd1->vnuma==fd2->vnuma)} , 'fd2')
        DO WHILE .NOT. fd2->(EOF()).AND.fd1->vnuma==fd2->vnuma
          fd2->(DBDELETE())
          fd2->(DBSKIP())
        ENDDO
      ENDIF
      fd1->(DBDELETE())
    ENDIF
    fd1->(DBSKIP())
  ENDDO
  Fks08->(DBGOTOP())
  m_gauge1:=InitGauge("Занесення утримань за ссуду",2)
  DO WHILE .NOT. Fks08->(EOF())
    IF Fks08->kpr==m_kopr.AND.fks08->ddoc>=m_ddoc1.And.Fks08->ddoc<=m_ddoc2
         fd1->(DBAPPEND())
         fd1->npch:=801
         fd1->ndoc:=Fks08->ndoc
         fd1->vdoc:=1
         fd1->oper:="KS"
         fd1->kopu:=m_kopu
         fd1->ddoc:=IF(DAY(fks08->ddoc)>25,CTOD(STUFF(DTOC(fks08->ddoc),1,2,"25")),fks08->ddoc)
         fd1->vnuma:=fvnum->vnuma++
         fd1->oper:="KS"
         fd2->(DBAPPEND())
         fd2->tabn:=Fks08->tabn
         fd2->sum:=Fks08->sum
         fd2->vnuma:=fd1->vnuma
    ENDIF
    Fks08->(DBSKIP())
    m_gauge1:=DispGauge(m_gauge1,fks08->(RECNO())/Fks08->(LASTREC()))
  ENDDO
  CLOSE BASE Fd1,Fd2,Fvnum,fks08
RETURN .t.
Function SetDdoc2(m_ddoc1,m_ddoc2)
  IF .NOT.EMPTY(m_ddoc1)
    m_ddoc2:=EOM(m_ddoc1)
  ENDIF
RETURN .t.
FUNCTION Pfilpoz1(file1,b_block,file2)
  LOCAL m_recno:=(file2)->(RECNO())
  DO WHILE .NOT.(file2)->(EOF())
    IF EVAL(b_block)
      RETURN .t.
    ENDIF
    (file2)->(DBSKIP())
  ENDDO
  (file2)->(DBGOTO(m_recno))
RETURN .f.

