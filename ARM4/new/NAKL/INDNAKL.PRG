Function IndNakl
  LOCAL m_workpath:="D:\BUH\PLAT\"
  USE (m_workpath+"nakl1")
  INDEX ON ndoc TO (m_workpath+"nakl1")
  INDEX ON vnum TO (m_workpath+"nakl1a")
  USE (m_workpath+"nakl2")
  INDEX ON vnum TO (m_workpath+"nakl2")
  USE (m_workpath+"kaptka1")
  INDEX ON kod TO (m_workpath+"kaptka1")
  INDEX ON vnum TO (m_workpath+"kaptka1a")
  USE (m_workpath+"kaptka2")
  INDEX ON vnum TO (m_workpath+"kaptka2")
  USE (m_workpath+"spr01")
  INDEX ON kopr TO (m_workpath+"spr01")
  USE (m_workpath+"firm01")
  INDEX ON UPPER(short) TO (m_workpath+"firm01")
  INDEX ON okpo TO (m_workpath+"firm01a")
RETURN .t.
