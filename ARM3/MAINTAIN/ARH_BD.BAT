FOR /F "tokens=2,3,4  delims=/ " %%I IN ('DATE /T') DO 7z a  -t7z d:\BARS\arhiv\bd_mn_%%K_%%I_%%J.7z @listbd1.txt -mx7
FOR /F "tokens=2,3,4  delims=/ " %%I IN ('DATE /T') DO 7z a  -t7z d:\BARS\arhiv\bd_bf_%%K_%%I_%%J.7z @listbd2.txt -mx7
FOR /F "tokens=2,3,4  delims=/ " %%I IN ('DATE /T') DO 7z a  -t7z d:\BARS\arhiv\bd_plat_%%K_%%I_%%J.7z @listbd3.txt -mx7
FOR /F "tokens=2,3,4  delims=/ " %%I IN ('DATE /T') DO 7z a  -t7z d:\BARS\arhiv\bd_kassa_%%K_%%I_%%J.7z @listbd4.txt -mx7
