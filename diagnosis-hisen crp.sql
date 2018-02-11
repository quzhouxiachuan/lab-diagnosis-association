use EDW
drop table #table 
drop table #lab 
drop table #lab_pk 
drop table #diagnoses 
drop table #full_tb 
drop table #final 
drop table #final_tb 
drop table #filter_tb 

select *  
into #table
from  nmh_cerner_dm.lab_result lab  
where (event_dsc like '%creative%protein' 
	or lab.event_cd = 39896 )    -- c-reactive protein code 
	--	or lab.event_cd = 2307403 ) -- c-reactive protein hisens
	-- or lab.event_cd = 7460) -- sedimentation rate 
		and  lab.result_status_cd in ( 9,17)  -- authenticated
		and lab.order_status_cd = 682 -- order complete
		and mrd_pt_id is not NULL 
		and result_val_num is not NULL 
		and valid_until_dt_tm > GETDATE()
--select top 10 result_units_dsc from   nmh_cerner_dm.lab_result lab 




select  mrd_pt_id, event_cd, event_dsc, result_val_num, event_start_dt_tm, result_units_dsc, ROW_NUMBER() over (partition by mrd_pt_id order by result_val_num desc) as rk 
into #lab
from #table
where (result_val_num is not null)  and (result_units_dsc is not null) 

select  mrd_pt_id, event_cd, event_dsc, result_val_num, event_start_dt_tm,result_units_dsc --, ROW_NUMBER() over (partition by mrd_pt_id order by result_val_num desc) as rk 
into #lab_pk
from #lab  
where rk = 1 


-- select top 10 * from #lab 
------get diagnosis test ---------
-------get diagnosis and date -------
------get diagnosis and date ---------

select mrd_pt_id, d.diagnosis, d.vocabulary_value, d.diagnosis_dts 
into #diagnoses 
from edw_ids.edw_ids_cr_dm.diagnoses d
inner join [EDW_IDS].[edw_ids_ir_dm].[patients] p on d.patient_ir_id = p.patient_ir_id
where mrd_pt_id  is not NULL   -- for some patients, with patient_ir_id, they dont have mrd_pt_id? 
and d.src_vocabulary = 'ICD9'  -- for some dignosis, snomed code is used 
and vocabulary_value is not null 
--drop table #diagnoses


------combine diagnosis table and lab table -----
-------combine diagnosis table and lab table ------
select * 
into #full_tb 
from
(
	select lab.mrd_pt_id, event_dsc, event_cd, result_val_num, result_units_dsc, diagnosis, vocabulary_value,abs(DATEDIFF(month, lab.event_start_dt_tm, diagnosis_dts)) as date_diff ,
	event_start_dt_tm, diagnosis_dts 
	from #lab lab
	inner join #diagnoses d on lab.mrd_pt_id = d.mrd_pt_id 
)labd
where date_diff < = 1 

--drop table #filter_tb 
-- for each diagnosis, only select the first lab value associated with the first diagnosis 
select *, (DATEDIFF(day, event_start_dt_tm, diagnosis_dts)) as day_diff --ROW_NUMBER() over (partition by mrd_pt_id, event_dsc, result_val_num, vocabulary_value order by date_diff asc) as rk 
into #filter_tb 
from #full_tb 
where result_val_num is not null and mrd_pt_id is not null and vocabulary_value is not null

-- drop table #final 
-- drop table #filter_tb 
-- delete duplicated rows 
select *  
into #final
from  
(
	select *, ROW_NUMBER() over (partition by mrd_pt_id, event_dsc, result_val_num, result_units_dsc, vocabulary_value, event_start_dt_tm, diagnosis_dts order by day_diff asc) as rk   
	from #filter_tb
)tb 
where  day_diff < 30 and day_diff > -30

-- drop table #final_tb 
--select top 10 * from #final
select mrd_pt_id, event_cd, result_val_num, result_units_dsc, vocabulary_value, diagnosis, event_start_dt_tm, diagnosis_dts
into #final_tb 
from #final where rk = 1 

select * from #final_tb 
