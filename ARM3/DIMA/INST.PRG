#INCLUDE "NEW.CH"
Function t1(var)
  LOCAL j:=SPACE(8),i,k:=0,GetList:={},;
  m_file,m_mainpath:=IF(var==NIL,"d:\buhgal\mn\",var)
  set key K_F10 TO calc
  set key K_ALT_F10 TO calcul
  set confirm on
  keyboard ""
  CLEAR
  @10,10,14,70 BOX B_DOUBLE+" " COLOR "GR+/bg"
  j:=INT(random()%100+1)
  @11,12 Say "Введiть значення паролю("+STR(j,3)+")" COLOR "b/bg"
  SET CURSOR ON
  @12,38 Get k PICTURE "9999"
  READ
  i:=INT(4*j-0.04*j*j)
  IF k<>i
      DispError("Пароль невiрен")
      RETURN .F.
  ENDIF
  m_file:=FCREATE(m_mainpath+CHR(73)+CHR(68)+CHR(69)+CHR(78)+CHR(84)+"."+CHR(76)+CHR(83)+CHR(84))
  j:=L2BIN(BIOSDATE()-CTOD("01/01/80"))
  FWRITE(m_file,j,4)
  FCLOSE(m_file)
  SETFATTR(m_mainpath+CHR(73)+CHR(68)+CHR(69)+CHR(78)+CHR(84)+"."+CHR(76)+CHR(83)+CHR(84),1)
RETURN .T.
external calc
EXTERNAL calcul

