use EDW
drop table #table 
drop table #lab 
drop table #lab_pk 

select *  
into #table
from  nmh_cerner_dm.lab_result lab  
where (event_dsc like '%sedimentation%rate%' 
	--	or lab.event_cd = 39896 )    -- c-reactive protein code 
	--	or lab.event_cd = 2307403 ) -- c-reactive protein hisens
	 or lab.event_cd = 7460) -- sedimentation rate 
		and  lab.result_status_cd in ( 9,17)  -- authenticated
		and lab.order_status_cd = 682 -- order complete
		and mrd_pt_id is not NULL 
		and result_val_num is not NULL 
		and valid_until_dt_tm > GETDATE()
		and date??????????
--select top 10 result_units_dsc from   nmh_cerner_dm.lab_result lab 
--select count(*) from   #table

--select top 10 * from nmh_cerner_dm.lab_result where clinical_event_id = '1923529861'
select * from #table where mrd_pt_id = '5285640'


select  mrd_pt_id, event_cd, event_dsc, result_val_num, event_start_dt_tm, result_units_dsc, ROW_NUMBER() over (partition by mrd_pt_id order by result_val_num desc) as rk 
into #lab
from #table
where (result_val_num is not null)  and (result_units_dsc is not null) 

select  mrd_pt_id, event_cd, event_dsc, result_val_num, event_start_dt_tm,result_units_dsc --, ROW_NUMBER() over (partition by mrd_pt_id order by result_val_num desc) as rk 
into #lab_pk
from #lab  
where rk = 1 


