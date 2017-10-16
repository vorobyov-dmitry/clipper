#include "new.ch"
Function Dop1(var)
  LOCAL a_st,m_path:=IF(var==NIL,"",var),i,j,k,n,m_gauge,N1,N2,N3,m_vnum
  LOCAL a_file:={"NAKL1","NAKL2","NAKL3","NALOG1","NALOG2","SCHT1","SCHT2"}
  SET DELE OFF
  setblink(.F.)
  USE (m_path+"NAKL1") new
  a_st:=DBSTRUCT();n1:=LEN(a_st)
  j:=ASCAN(a_st,{|x|(ALLTRIM(UPPER(x[1]))=="VNUM")})
  a_st[j,3]:=6
  DBCREATE(m_path+"file1.dbf",a_st)
  USE (m_path+"file1") NEW
  USE (m_path+"NAKL2") new
  a_st:=DBSTRUCT();n2:=LEN(a_st)
  j:=ASCAN(a_st,{|x|(ALLTRIM(UPPER(x[1]))=="VNUM")})
  a_st[j,3]:=6
  DBCREATE(m_path+"file2.dbf",a_st)
  USE (m_path+"file2") NEW
  USE (m_path+"NAKL3") new
  a_st:=DBSTRUCT();n3:=LEN(a_st)
  j:=ASCAN(a_st,{|x|(ALLTRIM(UPPER(x[1]))=="VNUM")})
  a_st[j,3]:=6
  DBCREATE(m_path+"file3.dbf",a_st)
  USE (m_path+"file3") NEW
  m_gauge:=InitGauge("Змiнюю структуру файла NAKL1 ")
  m_vnum:=0
  DO WHILE .NOT.NAKL1->(EOF())
    file1->(DBAP())
    FOR k:=1 TO n1
      file1->(FIELDPUT(k,nakl1->(FIELDGET(k))))
    NEXT
    file1->vnum:=STR(m_vnum,6)
    m_vnum++
    IF nakl1->(DELETE())
      file1->(DBDELETE())
    ENDIF
    NAKL1->(DBSKIP())
    DispGauge(m_gauge,NAKL1->(RECNO())/NAKL1->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  Nakl1->(DBCREATEIND(m_path+"N1","Nakl1->vnum",{||Nakl1->vnum}))
  m_gauge:=InitGauge("Змiнюю структуру файла NAKL2")
  m_vnum:=0
  DO WHILE .NOT.NAKL2->(EOF())
    file2->(DBAP())
    FOR k:=1 TO n2
      file2->(FIELDPUT(k,nakl2->(FIELDGET(k))))
    NEXT
    Nakl1->(DS(nakl2->vnum))
    File1->(DBGOTO(Nakl1->(RECNO())))
    file2->vnum:=file1->vnum
    IF nakl2->(DELETE())
      file2->(DBDELETE())
    ENDIF
    NAKL2->(DBSKIP())
    DispGauge(m_gauge,NAKL2->(RECNO())/NAKL2->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  m_gauge:=InitGauge("Змiнюю структуру файла NAKL3")
  m_vnum:=0
  DO WHILE .NOT.NAKL3->(EOF())
    file3->(DBAP())
    FOR k:=1 TO n2
      file3->(FIELDPUT(k,nakl3->(FIELDGET(k))))
    NEXT
    Nakl1->(DS(nakl3->vnum))
    File1->(DBGOTO(Nakl1->(RECNO())))
    file3->vnum:=file1->vnum
    IF nakl3->(DELETE())
      file3->(DBDELETE())
    ENDIF
    NAKL3->(DBSKIP())
    DispGauge(m_gauge,NAKL3->(RECNO())/NAKL3->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE BASE NAKL1,NAKL2,NAKL3,FILE1,FILE2,FILE3
  FRENAME(m_path+"NAKL1.DBF",m_path+"NAKL1.BAK");FRENAME(m_path+"FILE1.DBF",m_path+"NAKL1.DBF")
  FRENAME(m_path+"NAKL2.DBF",m_path+"NAKL2.BAK");FRENAME(m_path+"FILE2.DBF",m_path+"NAKL2.DBF")
  FRENAME(m_path+"NAKL3.DBF",m_path+"NAKL3.BAK");FRENAME(m_path+"FILE3.DBF",m_path+"NAKL3.DBF")
  ferase(m_path+"N1.ntx")
  USE (m_path+"nalog1") new
  a_st:=DBSTRUCT();n1:=LEN(a_st)
  j:=ASCAN(a_st,{|x|(ALLTRIM(UPPER(x[1]))=="VNUM")})
  a_st[j,3]:=6
  DBCREATE(m_path+"file1.dbf",a_st)
  USE (m_path+"file1") NEW
  USE (m_path+"nalog2") new
  a_st:=DBSTRUCT();n2:=LEN(a_st)
  j:=ASCAN(a_st,{|x|(ALLTRIM(UPPER(x[1]))=="VNUM")})
  a_st[j,3]:=6
  DBCREATE(m_path+"file2.dbf",a_st)
  USE (m_path+"file2") NEW
  m_gauge:=InitGauge("Змiнюю структуру файла nalog1 ")
  m_vnum:=0
  DO WHILE .NOT.nalog1->(EOF())
    file1->(DBAP())
    FOR k:=1 TO n1
      file1->(FIELDPUT(k,nalog1->(FIELDGET(k))))
    NEXT
    file1->vnum:=STR(m_vnum,6)
    m_vnum++
    IF nalog1->(DELETE())
      file1->(DBDELETE())
    ENDIF
    nalog1->(DBSKIP())
    DispGauge(m_gauge,nalog1->(RECNO())/nalog1->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  nalog1->(DBCREATEIND(m_path+"N1","nalog1->vnum",{||nalog1->vnum}))
  m_gauge:=InitGauge("Змiнюю структуру файла nalog2")
  m_vnum:=0
  DO WHILE .NOT.nalog2->(EOF())
    file2->(DBAP())
    FOR k:=1 TO n2
      file2->(FIELDPUT(k,nalog2->(FIELDGET(k))))
    NEXT
    nalog1->(DS(nalog2->vnum))
    File1->(DBGOTO(nalog1->(RECNO())))
    file2->vnum:=file1->vnum
    IF nalog2->(DELETE())
      file2->(DBDELETE())
    ENDIF
    nalog2->(DBSKIP())
    DispGauge(m_gauge,nalog2->(RECNO())/nalog2->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE BASE nalog1,nalog2,FILE1,FILE2
  FRENAME(m_path+"nalog1.DBF",m_path+"nalog1.BAK");FRENAME(m_path+"FILE1.DBF",m_path+"nalog1.DBF")
  FRENAME(m_path+"nalog2.DBF",m_path+"nalog2.BAK");FRENAME(m_path+"FILE2.DBF",m_path+"nalog2.DBF")
  ferase(m_path+"N1.ntx")
  USE (m_path+"scht1") new
  a_st:=DBSTRUCT();n1:=LEN(a_st)
  j:=ASCAN(a_st,{|x|(ALLTRIM(UPPER(x[1]))=="VNUM")})
  a_st[j,3]:=6
  DBCREATE(m_path+"file1.dbf",a_st)
  USE (m_path+"file1") NEW
  USE (m_path+"scht2") new
  a_st:=DBSTRUCT();n2:=LEN(a_st)
  j:=ASCAN(a_st,{|x|(ALLTRIM(UPPER(x[1]))=="VNUM")})
  a_st[j,3]:=6
  DBCREATE(m_path+"file2.dbf",a_st)
  USE (m_path+"file2") NEW
  m_gauge:=InitGauge("Змiнюю структуру файла scht1 ")
  m_vnum:=0
  DO WHILE .NOT.scht1->(EOF())
    file1->(DBAP())
    FOR k:=1 TO n1
      file1->(FIELDPUT(k,scht1->(FIELDGET(k))))
    NEXT
    file1->vnum:=STR(m_vnum,6)
    m_vnum++
    IF scht1->(DELETE())
      file1->(DBDELETE())
    ENDIF
    scht1->(DBSKIP())
    DispGauge(m_gauge,scht1->(RECNO())/scht1->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  scht1->(DBCREATEIND(m_path+"N1","scht1->vnum",{||scht1->vnum}))
  m_gauge:=InitGauge("Змiнюю структуру файла scht2")
  m_vnum:=0
  DO WHILE .NOT.scht2->(EOF())
    file2->(DBAP())
    FOR k:=1 TO n2
      file2->(FIELDPUT(k,scht2->(FIELDGET(k))))
    NEXT
    scht1->(DS(scht2->vnum))
    File1->(DBGOTO(scht1->(RECNO())))
    file2->vnum:=file1->vnum
    IF scht2->(DELETE())
      file2->(DBDELETE())
    ENDIF
    scht2->(DBSKIP())
    DispGauge(m_gauge,scht2->(RECNO())/scht2->(LASTREC()))
  ENDDO
  DelGauge(m_gauge)
  CLOSE BASE scht1,scht2,FILE1,FILE2
  FRENAME(m_path+"scht1.DBF",m_path+"scht1.BAK");FRENAME(m_path+"FILE1.DBF",m_path+"scht1.DBF")
  FRENAME(m_path+"scht2.DBF",m_path+"scht2.BAK");FRENAME(m_path+"FILE2.DBF",m_path+"scht2.DBF")
  ferase(m_path+"N1.ntx")
RETURN .t.
