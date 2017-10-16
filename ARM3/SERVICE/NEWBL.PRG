FUNCTION newbl(var1,var2)
LOCAL m_var1:=IF(var1==NIL,"d:\buhgal\",alltrim(var1)),;
      m_var2:=IF(var2==NIL,"d:\etalon\",alltrim(var2)),i,j,;
a_file:={"screen.dbf","screen.dbt","screen.ntx","dbrowse.dbf","dbrowse.ntx",;
"tbget.dbf","tbget.ntx"}

// копирование новых структур
for i:=1 to len(a_file)
frename(m_var1+"system\"+a_file[i],m_var1+"system\_"+a_file[i])
filecopy(m_var2+a_file[i],m_var1+"system\"+a_file[i])
next
ferase(m_var1+"bh\RASCHET.EXE")
filecopy(m_var2+"RASCHET.EXE",m_var1+"\bh\RASCHET.EXE")
frename(m_var1+"bf\boln1.dbf",m_var1+"bf\_boln1.dbf")
filecopy(m_var2+"boln1.dbf",m_var1+"bf\boln1.dbf")
USE (m_var1+"bf\boln1.dbf")
APPEND FROM (m_var1+"bf\_boln1.dbf")
frename(m_var1+"mn\boln1.dbf",m_var1+"mn\_boln1.dbf")
filecopy(m_var2+"boln1.dbf",m_var1+"mn\boln1.dbf")
USE (m_var1+"mn\boln1.dbf")
APPEND FROM (m_var1+"mn\_boln1.dbf")
use
return .t.
