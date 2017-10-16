DEL new.lib
DEL new.obj
DEL lib1.obj
DEL calcul.obj
clipper new /n/w
pause
clipper lib1 /n/w
pause
clipper calcul /n/w
pause
Clipper mnt /n/w
pause
lib new lib1 calcul new mnt,new.lst
copy new.lib c:\clipper5\lib\new.lib
