        ECHO COMPILE NDS
        clipper nds   /m/w /n %1 /oe:\compil\obj\nds /te:\ /q
        copy e:\compil\obj\nds.obj c:\clipper5\lib\nds.obj
