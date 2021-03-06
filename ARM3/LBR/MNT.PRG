#include "New.ch"
Function Aseek(a_data,x)
  LOCAL n:=LEN(a_data),i:=1
  LOCAL j:=0
  DO WHILE .t.
    j:=INT((i+n)/2)
    IF x==a_data[j][1]
      RETURN j
    ENDIF
    IF i==n-1
      EXIT
    ENDIF
    IF x>a_data[j][1]
      i:=j
    ELSE
      n:=j
    ENDIF
  ENDDO
RETURN 0


Function mnt_data(var)
  IF .NOT.EMPTY(var)
    RETURN (RIGHT(var,2)+"."+LEFT(var,2))
  ENDIF
RETURN SPACE(5)


Function mnt_dec(var)
  LOCAL i:=mnt_month(var),j:=mnt_year(var)
  IF i>1
    RETURN (LEFT(var,2)+STRZERO(i-1,2))
  ENDIF
  IF j==1
    RETURN ("9902")
  ENDIF
RETURN (STRZERO(j-1,2)+"12")

FUNCTION mnt_dtoc(var)
  IF EMPTY(var)
    RETURN ""
  ENDIF
RETURN (NTOCMONTH(mnt_month(var))+' '+mnt_syear(var))

Function mnt_dtod(var)
  LOCAL i:=DTOS(var)
  RETURN (SUBSTR(i,3,2)+SUBSTR(i,5,2))

Function Mnt_Field(x)
  IF EMPTY(x)
    RETURN SPACE(4)
  ENDIF
RETURN (RIGHT(x,2)+LEFT(x,2))


Function mnt_inc(var)
  LOCAL i:=mnt_month(var),j:=mnt_year(var)
  IF i<12
    RETURN(LEFT(var,2)+STRZERO(i+1,2))
  ENDIF
  IF j==99
    RETURN ("0001")
  ENDIF
  RETURN (STRZERO(j+1,2)+"01")


Function mnt_month(var)
  RETURN (VAL(RIGHT(var,2)))


FUNCTION mnt_smonth(var)
  IF ISDIGIT(SUBSTR(var,4,1)).AND.ISDIGIT(SUBSTR(var,3,1))
    RETURN(RIGHT(var,2))
  ENDIF
RETURN("  ")

Function mnt_syear(var)
  IF ISDIGIT(SUBSTR(var,1,1)).AND.ISDIGIT(SUBSTR(var,2,1))
//    IF LEFT(var,1)=="0"
      RETURN("20"+LEFT(var,2))
//    ELSE
//      RETURN("19"+LEFT(var,2))
//    ENDIF
  ENDIF
RETURN("    ")

Function mnt_val(var)
  RETURN((mnt_year(var)-96)*12+mnt_month(var)-1)


Function mnt_year(var)
RETURN (VAL(LEFT(var,2)))



