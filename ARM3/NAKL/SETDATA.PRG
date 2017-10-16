#include "new.ch"
LOCAL m_date:=DATE(),m_time
SET ESCAPE OFF
SET DATE BRITISH
  @02,14,06,66 BOX B_DOUBLE+" " color "W/B"
  shadow(02,14,06,66)
  @03,26 SayDisp "Сьогоднi "+DMY(m_date)+" "+NtoCdow(DOW(m_date)) COLOR "w+/b"
  @05,30 SayDisp "Дата>" COLOR "W+/B"
  @04,30 SayDisp "Час> " COLOR "W+/B"
  m_time:=TIME()
  @04,37 GET m_time COLOR "GR+/B,GR+/N" PICTURE "99:99:99"
  @05,37 GET m_date COLOR "GR+/B,GR+/N"
  READ
  SETTIME(m_time)
  SETDATE(m_date)
RETURN .t.
