#include "new.ch"
Function Dop1(var)
  LOCAL a_st,m_path:=IF(var==NIL,"",var),i,j,k,n,m_gauge,GetList:={}
  CLEAR
  SET PRINTER TO "N1.txt"
  SET PRINTER ON
  SET DELE ON
  setblink(.F.)
  USE (m_path+"NAKL1.BAK") new ALIAS NAKL1
  USE (m_path+"NAKL1") NEW ALIAS file1
  USE (m_path+"NAKL2.BAK") new ALIAS NAKL2
  USE (m_path+"nakl2") NEW ALIAS file2
  USE (m_path+"NAKL3.BAK") new ALIAS NAKL3
  USE (m_path+"nakl3") NEW ALIAS file3
  Nakl1->(DBCREATEIND(m_path+"N1","Nakl1->vnum",{||Nakl1->vnum}))
  ?"============NAKL2==============="
  m_gauge:=InitGauge("Перевiряю файл NAKL2")
  DO WHILE .NOT.NAKL2->(EOF())
    file2->(DBGOTO(nakl2->(RECNO())))
    Nakl1->(DS(nakl2->vnum))
    File1->(DBGOTO(Nakl1->(RECNO())))
    IF file2->vnum<>file1->vnum
      ?"Помилка в ",file1->ndoc,file1->ddoc
       file2->vnum:=file1->vnum
    ENDIF
    NAKL2->(DBSKIP())
    DispGauge(m_gauge,NAKL2->(RECNO())/NAKL2->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  ?"============NAKL3==============="
  m_gauge:=InitGauge("Перевiряю структуру файла NAKL3")
  DO WHILE .NOT.NAKL3->(EOF())
    file3->(DBGOTO(nakl3->(RECNO())))
    Nakl1->(DS(nakl3->vnum))
    File1->(DBGOTO(Nakl1->(RECNO())))
    IF file3->vnum<>file1->vnum
      ?"Помилка в ",file1->ndoc,file1->ddoc
 //     ?"Помилка в ",file1->(RECNO()),file3->(RECNO())
      file3->vnum:=file1->vnum
    ENDIF
    NAKL3->(DBSKIP())
    DispGauge(m_gauge,NAKL3->(RECNO())/NAKL3->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE BASE NAKL1,NAKL2,NAKL3,FILE1,FILE2,FILE3
  ferase(m_path+"N1.ntx")
  ?"============NALog2==============="
  USE (m_path+"nalog1.bak") new ALIAS nalog1
  USE (m_path+"nalog1") NEW    ALIAS file1
  USE (m_path+"nalog2.bak") new  ALIAS nalog2
  USE (m_path+"nalog2") NEW  ALIAS file2
  nalog1->(DBCREATEIND(m_path+"N1","nalog1->vnum",{||nalog1->vnum}))
  m_gauge:=InitGauge("Первiряю структуру файла nalog2")
  DO WHILE .NOT.nalog2->(EOF())
    file2->(DBGOTO(nalog2->(RECNO())))
    nalog1->(DS(nalog2->vnum))
    File1->(DBGOTO(nalog1->(RECNO())))
    IF file2->vnum<>file1->vnum
      ?"Помилка в ",file1->ndoc,file1->ddoc
//      ?"Помилка в ",file1->(RECNO()),file2->(RECNO())
      file2->vnum:=file1->vnum
    ENDIF
    nalog2->(DBSKIP())
    DispGauge(m_gauge,nalog2->(RECNO())/nalog2->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE BASE nalog1,nalog2,FILE1,FILE2
  ferase(m_path+"N1.ntx")
  USE (m_path+"scht1.bak") new ALIAS scht1
  USE (m_path+"scht1") NEW ALIAS file1
  USE (m_path+"scht2.bak") new ALIAS scht2
  USE (m_path+"scht2") NEW ALIAS file2
  scht1->(DBCREATEIND(m_path+"N1","scht1->vnum",{||scht1->vnum}))
  m_gauge:=InitGauge("Перевiряю структуру файла scht2")
  ?"============scht2==============="
  DO WHILE .NOT.scht2->(EOF())
    file2->(DBGOTO(scht2->(RECNO())))
    scht1->(DS(scht2->vnum))
    File1->(DBGOTO(scht1->(RECNO())))
    IF file2->vnum<>file1->vnum
      ?"Помилка в ",file1->ndoc,file1->ddoc
//      ?"Помилка в ",file1->(RECNO()),file2->(RECNO())
      file2->vnum:=file1->vnum
    ENDIF
    scht2->(DBSKIP())
    DispGauge(m_gauge,scht2->(RECNO())/scht2->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE BASE scht1,scht2,FILE1,FILE2
  ferase(m_path+"N1.ntx")
RETURN .t.
