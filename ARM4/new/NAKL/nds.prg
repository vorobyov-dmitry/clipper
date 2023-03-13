#command NET USE <(db)> [ALIAS <a>] [<new: NEW>] [<ro: READONLY>] [INDEX <(index1)> [, <(indexn)>]]  ;
      => NetUse(<.new.>,, <(db)>, <(a)>, <.ro.>)                 ;
      [; dbSetIndex( <(index1)> )]                               ;
      [; dbSetIndex( <(indexn)> )]

MEMVAR m_platpath
STATIC k_nds1,k_nds2,k_nds3,k_ndsDbt
STATIC a_nds1:={},a_nds2:={}
STATIC k_ndsKopr,m_nds,s_nds1,s_nds2,m_nds1
Function InitNds
  NET USE (m_platpath+"NDS") READONLY NEW
  m_nds:=nds->nds/100  // процент ндс
  m_nds1:=nds->nds1/100  // процент ндс
  

  k_nds1:=nds->ksash  // Растениеводство
  // Преобразуем в массив
  a_nds1:=conv05(nds->Scht)
  k_nds2:=nds->ksash2 // Животноводство
  a_nds2:=conv05(nds->Scht2)
  k_nds3:=nds->ksash3 // Прочее
  k_ndsDbt:=nds->ksash4 // Дебет покупных НДС
  k_ndsKopr:=nds->kopr  //код операции по НДС

  s_nds1:=ALLTRIM(nds->Scht)  //Счета НДС по растениеводству

  s_nds2:=ALLTRIM(nds->Scht2) //Счета НДС по животноводству

  CLOSE Nds
RETURN .t.
Function GetNdsKsash(m_dbt)
LOCAL i:=ASCAN(a_nds1,{|x|(x==LEFT(m_dbt,LEN(x)))})

IF i<>0
    RETURN k_nds1
ENDIF
  IF ASCAN(a_nds2,{|x|(x==LEFT(m_dbt,LEN(x)))})<>0
    RETURN k_nds2
  ENDIF
RETURN k_nds3
Function GetNdsDbt()
  RETURN k_ndsDbt

Function GetNdsKopr()
RETURN k_ndsKopr

Function GetNds()
IF CountNds()
    RETURN m_nds
ENDIF
RETURN 0

Function GetNds1()
IF CountNds()
    RETURN m_nds1
ENDIF
RETURN 0


Function ReadNds()
RETURN m_nds

Function CountNds(var)
STATIC m_count:=.t.
IF var<>NIL
  spr01->(DBSEEK(var))
   m_count:=IF(spr01->nds=="1",.t.,.f.)
ENDIF
RETURN m_count
STATIC FUNCTION conv05(m_str)
LOCAL n:=NUMTOKEN(m_str),i,a_scht:={}

FOR i:=1 TO n
  AADD(a_scht,TOKEN(m_str,i))
NEXT
RETURN a_scht
Function EditNds()
  LOCAL s_files:={}
    SopenFiles("100",@s_files)
    NET USE (m_platpath+"NDS") NEW
    EdForm("NDS")
    CLOSE nds
    ScloseFile(s_files)
RETURN .T.
