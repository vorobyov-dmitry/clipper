
#DEFINE ROW1 INT((MAXROW()- 10)/2)
#DEFINE COL1 INT((MAXCOL()- 60)/2)
//Сложный поиск       
m_screen:=SAVESCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64)
@ROW1,COL1,ROW1+ 11,COL1+ 62 BOX (B_SINGLE+' ') COLOR ("w/b")
SHADOW(ROW1,COL1,ROW1+ 11,COL1+ 62)
@ROW1,COL1+INT( 37/2) SayText "~3Сложный поиск накладной" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+1+ 10,COL1+INT( 60/2) SayText "~4" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  1,COL1+1 SayText "~2Найти накладную" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  2,COL1+1 SayText "~2с           по" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  3,COL1+1 SayText "~2Таб. номер" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  4,COL1+1 SayText "~2ОКПО" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  5,COL1+1 SayText "~2ШПЗ" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  6,COL1+1 SayText "~2Код материала" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
@ROW1+  7,COL1+1 SayText "~2Стоимость" COLOR ("w/b,w/b,r/w,n/w,gr+/n,n/w")
SET CURSOR ON
@ROW1+  2,COL1+  3 Get m_ddoc1 COLOR ("n/w,gr+/n")
@ROW1+  2,COL1+ 17 Get m_ddoc2 COLOR ("n/w,gr+/n")
@ROW1+  3,COL1+ 12 Get m_tabn COLOR ("n/w,gr+/n")
@ROW1+  4,COL1+ 12 Get m_okpo COLOR ("n/w,gr+/n")
@ROW1+  5,COL1+ 12 Get m_ksash COLOR ("n/w,gr+/n")
@ROW1+  6,COL1+ 12 Get m_kod COLOR ("n/w,gr+/n")
@ROW1+  7,COL1+ 12 Get m_sum1 COLOR ("n/w,gr+/n")
@ROW1+  7,COL1+ 27 Get m_sum2 COLOR ("n/w,gr+/n")
READ 
SET CURSOR OFF
RESTSCREEN(ROW1,COL1,ROW1+ 12,COL1+ 64,m_screen)
#UNDEF ROW1 
#UNDEF COL1 