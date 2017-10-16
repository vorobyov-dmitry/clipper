SET INCLUDE=C:\CLIPPER5\INCLUDE
SET LIB=C:\CLIPPER5\LIB
SET OBJ=C:\CLIPPER5\LIB
SET PLL=C:\CLIPPER5\PLL
SET CLIPPERCMD=/TD:\buhgal\temp
SET CLIPPER=F170; D:0; SWAPK:4000; SWAPPATH:'D:\BUHGAL\TEMP'; TEMPPATH:'D:\BUHGAL\TEMP'
SET PATH=%PATH%;C:\Clipper5\BIN
        ECHO COMPILE SPRAV
        clipper @sprav   /m/w /n %1 /oc:\compil\obj3\sprav  /q
        copy c:\compil\obj3\sprav.obj c:\clipper5\lib\sprav.obj
