use EDW 

select  pro.PAT_ENC_CSN_ID, PROC_CODE, DESCRIPTION, CPT_CODE, ORDER_TIME, res.COMPONENT_ID, ORD_NUM_VALUE, REFERENCE_UNIT, com.NAME, com.EXTERNAL_NAME, com.BASE_NAME
into #wbc 
from nmff_epic_ods.ORDER_PROC pro 
join nmff_epic_ods.order_results res on   pro.order_proc_id = res.order_proc_id
INNER JOIN nmff_epic_ods.clarity_component com
ON res.component_id = com.component_id
where DESCRIPTION like '%CBC%' and NAME like '%white%'

--drop table #wbc1
select * 
into #wbc1 
from #wbc wbc  
where wbc.ORD_NUM_VALUE > 30 and wbc.ORD_NUM_VALUE != 9999999 and REFERENCE_UNIT is not null and REFERENCE_UNIT is not null  


select * from edw.nmff_epic_ods.pat_enc_dx  enc 
join #wbc1 wbc on wbc.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID 
join nmff_epic_ods.clarity_edg edg on edg.DX_ID = enc.dx_id 


select PAT_ID , wbc.PAT_ENC_CSN_ID , enc.ICD9_CODE , PROC_CODE, DESCRIPTION, ORD_NUM_VALUE , REFERENCE_UNIT, DX_NAME 
into #final 
from edw.nmff_epic_ods.pat_enc_dx  enc 
join #wbc2 wbc on wbc.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID 
join nmff_epic_ods.clarity_edg edg on edg.DX_ID = enc.dx_id 


