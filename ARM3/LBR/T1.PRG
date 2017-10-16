FUNCTION t1
LOCAL GetList:={},x:="    ",y
SET COLOR TO "w/n"

CLEAR
DO WHILE .t.
  SET COLOR TO "w/b"
@10,10 GET X
GetList[1]:Block:={|z|IF(z==NIL,mnt_data(x),x:=mnt_field(z))}
GetList[1]:picture:="99.99"
READ
@11,30 SAY MNT_data(x)
y:=mnt_dec(x)
@12,10  SAY mnt_data(y)
@12,30  SAY y
y:=mnt_inc(x)
@13,10  SAY mnt_data(y)
@13,30  SAY y
y:=mnt_dtoc(x)
@14,10  SAY mnt_data(y)
@14,30  SAY y
y:=mnt_dtod(DATE())
@15,10  SAY mnt_data(y)
@15,30  SAY y
y:=mnt_month(x)
@16,30  SAY y
y:=mnt_smonth(x)
@17,30  SAY y
y:=mnt_syear(x)
@18,30  SAY y
y:=mnt_year(x)
@19,30  SAY y
y:=mnt_val(x)
@20,30  SAY y
ENDDO
RETURN .t.
