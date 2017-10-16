j:=0
IF m_key==K_F8.OR.((j:=AT(MyUpper(MyCodeAlt(m_key)),s_letter))<>0)
IF j<>0;n_menu:=j;ENDIF
j:=1
DO WHILE j==1
@0,(n_menu-1)*menu_hor_width SayMenu a_hor_menu[n_menu] COLOR (SEL_H+","+SEL_H1)
i:=LEN(a_ver_menu[n_menu][1][1])+3
menu_col1:=MIN((n_menu-1)*menu_hor_width,MAXCOL()-i-4)
m_screen:=SAVESCREEN (1,menu_col1 ,LEN(a_ver_menu[n_menu][1])+3,menu_col1+i+4)
@1,menu_col1 ,LEN(a_ver_menu[n_menu][1])+2,menu_col1+i+2 BOX B_DOUBLE_SINGLE + SPACE(1) COLOR ( VER_CLR )
SHADOW( 1,menu_col1 ,LEN(a_ver_menu[n_menu][1])+2,menu_col1+i+2)
FOR i:=1 TO LEN(a_ver_menu[n_menu][1])
@1+i,menu_col1+1 SayDisp STR(i,1)+' '+a_ver_menu[n_menu][1][i] COLOR (IF(a_num_menu[n_menu]==i,SEL_V,VER_CLR))
NEXT
DO WHILE .t.
i:=INKEY(0)
DO CASE
CASE i==K_ESC
j:=0;m_key:=0;EXIT
CASE i==K_DOWN.AND.a_num_menu[n_menu]<LEN(a_ver_menu[n_menu][1])
@1+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][1][a_num_menu[n_menu]] COLOR VER_CLR
a_num_menu[n_menu]:=a_num_menu[n_menu]+1
@1+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][1][a_num_menu[n_menu]] COLOR SEL_V
CASE i==K_UP.AND.a_num_menu[n_menu]>1
@1+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][1][a_num_menu[n_menu]] COLOR VER_CLR
a_num_menu[n_menu]:=a_num_menu[n_menu]-1
@1+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][1][a_num_menu[n_menu]] COLOR SEL_V
CASE i==K_RIGHT
j:=1
i:=IF(n_menu==LEN(a_hor_menu),1,n_menu+1)
EXIT
CASE i==K_LEFT
j:=1
i:=IF(n_menu==1,LEN(a_hor_menu),n_menu-1)
EXIT
CASE CHR(i)>="1".AND.i<=ASC("0")+LEN(a_ver_menu[n_menu][2])
@1+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][1][a_num_menu[n_menu]] COLOR VER_CLR
a_num_menu[n_menu]:=i-ASC("0")
@1+a_num_menu[n_menu],menu_col1+1 SayDisp STR(a_num_menu[n_menu],1)+' '+a_ver_menu[n_menu][1][a_num_menu[n_menu]] COLOR SEL_V
CASE i==K_ENTER
j:=2;EXIT
CASE (j:=AT(MyUpper(CHR(i)),s_letter))<>0
i:=j;j:=1;EXIT
ENDCASE
ENDDO
RESTSCREEN (1,menu_col1 ,LEN(a_ver_menu[n_menu][2])+3,menu_col1+LEN(a_ver_menu[n_menu][1][1])+3+4,m_screen)
@0,(n_menu-1)*menu_hor_width SayMenu a_hor_menu[n_menu] COLOR (USL_CLR+","+SEL_CLR)
IF j==1
n_menu:=i
ENDIF
IF j==2
m_key:=a_ver_menu[n_menu][2][a_num_menu[n_menu]]
ENDIF
ENDDO
IF m_key==0;LOOP;ENDIF
ENDIF;;
