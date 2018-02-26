library(gtools)
library(ggplot2)
library(knitr)
library(reshape2)
library(gridExtra)
setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/c-reactive protein/data/')
x=read.csv('./diagnosis-crp-unique_0220.csv')
x=x[,-c(1,ncol(x))]

colnames(x) = c('mrd_pt_id','event_dsc','result_val_num','vocabulary_val','event_start_dt_tm','diagnosis_dt')
x$vocabulary_val = as.character(x$vocabulary_val)
#0-22 is normal for man, 0-29 is normal range for women. 
x$val_disc = as.numeric(cut(x$result_val_num, c(0,3,5,10,20,30,50,100,max(x$result_val_num))))
phewas = read.csv('/Volumes/fsmhome/projects/ICD-2-phewas.csv')
freq = as.data.frame(table(x$vocabulary_val))
#freq=freq[freq$Var1!='*****',]
dx = freq[freq$Freq>=30,]  #change threshold as you want 
dx_list = as.character(dx$Var1)
#delete those starting with V 
dx_list = dx_list[-grep("V", dx_list, perl=TRUE)]
dx_list = dx_list[-grep("E", dx_list, perl=TRUE)]
dx_list = as.data.frame(dx_list)

### clean dx_list, to only keep the first digit after decimal point.
trunc_icd = function(dx_list){ #dx_list is a vector, sample: dx_list$dx_list 
  dx_list = as.character(dx_list)
  i = 1 
  dx= vector()
  for (i in (1:length(dx_list)))
  {
    if(grepl(".+\\.", dx_list[i], perl = T))
    {
      print(dx_list[i])
      dx[i] = paste(strsplit(dx_list[i],'[.]')[[1]][1], 
                    strsplit(strsplit(dx_list[i],'[.]')[[1]][2], "")[[1]][1],sep = '.')} 
    else 
    {dx[i] = dx_list[i]}
    i = i + 1  

}
return (dx)
}

dx_list1 = cbind(dx_list$dx_list,dx)
colnames(dx_list1)[1] = 'original_dx'

#clean phewas mapping table 
dict = merge(dx_list1, phewas, by.x = 'dx', by.y = 'ICD9_CODE',all.x= T)
dict = dict[,c('original_dx','dx','JD_CODE','JD_STR')]
dict$JD_CODE = as.character(dict$JD_CODE)
dict[1,3] = '*****'
dict$JD_STR = as.character(dict$JD_STR)
dict[1,4] = 'fever'

#create new dataset by switch ICD vocabulary value to JD code 
x$vocabulary_val1 = trunc_icd(x$vocabulary_val)
mm = merge(x, dict, by.x= 'vocabulary_val1', by.y = 'dx' )
mm = mm[complete.cases(mm),]
dx_list2 = as.character(unique(mm$JD_CODE))



##running time: 9:16 - 9:27
result =  data.frame()
i = 1

for (voca in dx_list2)
{
  #voca = '250.00'
  df_case = mm[mm$JD_CODE==voca,]  #select rows with dx voca 
  case_id = unique(df_case$mrd_pt_id) #find all the cases id 
  label = as.data.frame(cbind(case_id, rep('case',length(case_id))))
  colnames(label) = c('case_id', 'label')
  #control_id =  setdiff(unique(x$mrd_pt_id), unique(df_case$mrd_pt_id)) #find all the control id 
  #df_control = x[x$mrd_pt_id %in% control_id, ] # create control dataset 
  df_lab = merge(mm,label, by.x='mrd_pt_id',by.y='case_id',all.x=TRUE)
  df_lab$label = as.character(df_lab$label)
  df_lab$label[is.na(df_lab$label)] <- 'ctrl'
  tb = table(df_lab$label, df_lab$val_disc) 
  
  for (k in 2:(length(unique(mm$val_disc))) )
  {
    tmp = paste('res1',k,sep='') 
    assign ( tmp, fisher.test(tb[,c(1,k)]))
    result[i,'diagnosis'] = voca
    result[i, paste('OR_1',k,sep='')] = get(tmp)$estimate
    result[i, paste('pval_1',k,sep='')] = get(tmp)[1]
    result[i, paste('conf.int_1',k,sep='')]=paste('[',format(round(get(tmp)$conf.int[1],2),nsmall=2),',',format(round(get(tmp)$conf.int[2],2),nsmall=2),']')
    k= k +1 
  }
  i = i + 1 
  print(i)
}

