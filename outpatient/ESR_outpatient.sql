--CREACTIVEPRO	                   SEDIMENTATION RATE
--ESR	                             RBC SED RATE, NONAUTOMATED
--RETA	                           SEDIMENTATION RATE
--WSTB	                           SEDIMENTATION RATE
--CRPHS	                           ERYTHROCYTE SEDIMENTATION RATE
--TFT	                             SEDIMENTATION RATE
--ESR                             ERYTHROCYTE SEDIMENTATION RATE
--DNADS	                           SEDIMENTATION RATE
--ESR	                             SEDIMENTATION RATE
--RETIC                           	SEDIMENTATION RATE
--SGOT	                          SEDIMENTATION RATE



select -- distinct com.ABBREVIATION,com.EXTERNAL_NAME,BASE_NAME, DESCRIPTION, PROC_CODE    
pro.PAT_ID, pro.ORDER_PROC_ID,  PROC_ID,  DESCRIPTION, com.COMPONENT_ID, com.NAME, com.EXTERNAL_NAME, com.BASE_NAME, res.ORD_NUM_VALUE, res.REFERENCE_UNIT, res.RESULT_DATE , ORDERING_DATE 
into #ESR
from nmff_epic_ods.order_proc pro
join nmff_epic_ods.order_results res on  (pro.ORDER_PROC_ID = res.ORDER_PROC_ID and pro.PAT_ID = res.PAT_ID)
join nmff_epic_ods.clarity_component  com on com.COMPONENT_ID = res.COMPONENT_ID
where PROC_CODE in ('85651', '100413', 'LAB3030') -- code that matches '%sedimentation%'
and BASE_NAME = 'ESR'
and res.RESULT_STATUS_C != '5' -- incomplete 
and res.RESULT_STATUS_C is not null 
and pro.ORDER_STATUS_C not in (4, 7)
and pro.ORDER_STATUS_C is not null 
and pro.IS_PENDING_ORD_YN = 'N' 
and res.ORD_VALUE is not null 


-- select max(ORD_NUM_VALUE)   from #ESR
  



select *, ROW_NUMBER() over (partition by pat_id order by ORD_NUM_VALUE desc) as rk 
into #ESR_rk 
from #ESR
where (ORD_NUM_VALUE is not null)  and (REFERENCE_UNIT is not null) 

select  *
into #ESR_pk 
from #ESR_rk 
where rk = 1 

select * from #ESR_pk 


