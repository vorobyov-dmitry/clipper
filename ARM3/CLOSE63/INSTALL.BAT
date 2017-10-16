ECHO OFF
VERIFY ON
cls
ECHO -------------------------------------------------------
ECHO I                                                     I
ECHO I  “‘’€Ž‚Š€ Žƒ€Œˆ Ž Ž‡€•“Š“ ”ŽŒˆ N 1- „”     I
ECHO I                                                     I
ECHO -------------------------------------------------------
D:
MD D:\BUHGAL\1DF
CD D:\BUHGAL\1DF
COPY %DISK%FORMA3.EXE D:FORMA3.EXE >NUL
COPY %DISK%dop.EXE D:dop.EXE >NUL
COPY %DISK%menupod.dbf D:menupod.dbf >NUL
COPY %DISK%menupod.ntx D:menupod.ntx >NUL
COPY %DISK%forma3.dbf D:forma3.dbf >NUL
VERIFY OFF

