Function formfl05
SET DELE ON
USE flish  NEW
USE fl05 new
ZAP
INDEX ON fl05->tabn + fl05->month to fl05
DO WHILE (.NOT.flish->(EOF()))
  IF (flish->kopu=="112")
    IF (.NOT. fl05->(DBSEEK(flish->tabn+flish->month)))
      fl05->(DBAPPEND())
      fl05->tabn:=flish->tabn
      fl05->month:=flish->month
    ENDIF
	fl05->sum01+=flish->sum
ENDIF

  IF (flish->kopu=="009")
    IF (.NOT. fl05->(DBSEEK(flish->tabn+flish->month)))
      fl05->(DBAPPEND())
      fl05->tabn:=flish->tabn
      fl05->month:=flish->month
    ENDIF
  fl05->sum03+=flish->sum
ENDIF


IF (flish->kopu=="237" .OR. flish->kopu=="238")
  IF (.NOT. fl05->(DBSEEK(flish->tabn+flish->month)))
		fl05->(DBAPPEND())
		fl05->tabn:=flish->tabn
		fl05->month:=flish->month
	ENDIF
	fl05->sum02+=flish->sum
ENDIF
flish->(DBSKIP())
ENDDO
close all
return .t.
