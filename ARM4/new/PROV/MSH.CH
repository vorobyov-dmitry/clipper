,a_scht:={}

IF .NOT.MsRdMnt(m_num_mash,@a_scht,@m_kod,@m_mnt1,@m_mnt2,a_files)
  return .f.
ENDIF

IF IsScht(Fp2->dbt,a_scht).or.IsScht(Fp2->crt,a_scht) // Fp2 подходит
