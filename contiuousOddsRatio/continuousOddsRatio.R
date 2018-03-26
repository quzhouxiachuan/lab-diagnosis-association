library(gtools)
library(ggplot2)
library(knitr)
library(reshape2)
library(gridExtra)
setwd('P://projects/new_dataset_peakval_only/ESR/data')
x=read.csv('pkESR_diagnosis_validation_03082018.csv', sep = '\t', header = 0)

x = x[,c(1,3,5)]
colnames(x) = c('mrd_pt_id','result_val_num','vocabulary_val')

icd = read.csv('P://projects/new_dataset_peakval_only/icd9-longform-shortform.txt',header = 0)
x = merge(x, icd, by.x='vocabulary_val' , by.y= 'V1',all.x=T)
x=na.omit(x)
x= x[x$result_val_num!=3139995,]

x$V4 = as.character(x$V4)
#0-22 is normal for man, 0-29 is normal range for women. 
x$val_disc = as.numeric(cut(x$result_val_num, seq(-1,max(x$result_val_num)+10, by = 10)))

freq = as.data.frame(table(x$V3))
#freq=freq[freq$Var1!='*****',]
dx = freq[freq$Freq>=30,]  #change threshold as you want 
dx_list = as.character(dx$Var1)
#delete those starting with V 
dx_list = dx_list[-grep("V", dx_list, perl=TRUE)]
##running time: 9:16 - 9:27
result =  data.frame()

i = 1

for (voca in dx_list)
{
  #voca = '250.00'
  df_case = x[x$V3==voca,]  #select rows with dx voca 
  case_id = unique(df_case$mrd_pt_id) #find all the cases id 
  label = as.data.frame(cbind(case_id, rep('case',length(case_id))))
  colnames(label) = c('case_id', 'label')
  #control_id =  setdiff(unique(x$mrd_pt_id), unique(df_case$mrd_pt_id)) #find all the control id 
  #df_control = x[x$mrd_pt_id %in% control_id, ] # create control dataset 
  df_lab = merge(x,label, by.x='mrd_pt_id',by.y='case_id',all.x=TRUE)
  df_lab$label = as.character(df_lab$label)
  df_lab$label[is.na(df_lab$label)] <- 'ctrl'
  tb = table(df_lab$label, df_lab$val_disc) 
  
  for (k in 2:(length(unique(x$val_disc))) )
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

