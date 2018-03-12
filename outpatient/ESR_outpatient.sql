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

--select * from #ESR_pk 
--------------------------------------- ESR Peak value table above --------------------------------------------
---------------------------------------ESR peak value table above ---------------------------------------------
--------------------------------------ESR peak value table above ---------------------------------------------

--------------get diagnosis table ready -------------------------------------
-------------get diagnosis table ready --------------------------------------
select mrd_pt_id, d.diagnosis, d.vocabulary_value, d.diagnosis_dts 
into #diagnoses 
from edw_ids.edw_ids_cr_dm.diagnoses d
inner join [EDW_IDS].[edw_ids_ir_dm].[patients] p on d.patient_ir_id = p.patient_ir_id
where mrd_pt_id  is not NULL   -- for some patients, with patient_ir_id, they dont have mrd_pt_id? 
and d.src_vocabulary = 'ICD9'  -- for some dignosis, snomed code is used 
and vocabulary_value is not null 

------- link to mrd_pt_id by using  nmff_epic_ods.patient table ---------------------
---------------------get ESR pk table ready -----------------------------------------
select pt.mrd_pt_id, esr.* 
into #ESR_final
from #ESR_pk esr
join nmff_epic_ods.patient pt
on esr.PAT_ID = pt.PAT_ID
where mrd_pt_id is not NULL  

--select top 10 * from #ESR_final

select * 
into #full_tb 
from
(
	select esr.*, diagnosis, vocabulary_value,abs(DATEDIFF(month, esr.RESULT_DATE, diagnosis_dts)) as date_diff ,
	diagnosis_dts 
	from #ESR_final esr
	inner join #diagnoses d on esr.mrd_pt_id = d.mrd_pt_id 
)labd
where date_diff < = 1 

--select top 10 * from #full_tb
select *, (DATEDIFF(day, RESULT_DATE, diagnosis_dts)) as day_diff --ROW_NUMBER() over (partition by mrd_pt_id, event_dsc, result_val_num, vocabulary_value order by date_diff asc) as rk 
into #filter_tb 
from #full_tb 
where mrd_pt_id is not null and vocabulary_value is not null

--select top 100 * from #filter_tb
-- drop table #final 
-- drop table #filter_tb 
-- delete duplicated rows 
select *  
into #final
from  
(
	select *, ROW_NUMBER() over (partition by mrd_pt_id, description, component_id, ord_num_value, reference_unit, vocabulary_value order by diagnosis_dts asc) as rk2   
	from #filter_tb
)tb 
where  day_diff < 30 and day_diff > -30 and rk2 = 1 

select * from #final 

--select * from #final 
--where ORD_NUM_VALUE > 100
--and (diagnosis like '%vasculitis%' or vocabulary_value = '447.6')

--446.0 446.4 
drop table #filter_tb
drop table #ESR
drop table #ESR_final
drop table #diagnoses
drop table #ESR_pk
drop table #ESR_rk
drop table #full_tb 

