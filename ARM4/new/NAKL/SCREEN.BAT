clipper screen01  /n %1 
IF ERRORLEVEL 1 GOTO error
rtlink fi screen01,ct2us50,e:\compil\obj\sprav lib new,ct250 
goto end
:error 
echo ERROR COMPILATION
PAUSE
:end
