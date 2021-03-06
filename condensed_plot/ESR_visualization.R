library(gtools)
library(ggplot2)
library(knitr)
library(reshape2)
library(gridExtra)
setwd('P:/projects/new_dataset_peakval_only/ESR/data/')
x=read.csv('./diangosis-esr-peak.csv')
x=x[,-ncol(x)]
colnames(x) = c('mrd_pt_id','event_dsc','result_val_num','vocabulary_val','event_start_dt_tm','diagnosis_dt')
x$vocabulary_val = as.character(x$vocabulary_val)
x$val_disc = as.numeric(cut(x$result_val_num, c(-1,30,50,90,130,max(x$result_val_num))))
# get summary for the frequency of each category 
table(x$val_disc)

freq = as.data.frame(table(x$vocabulary_val))
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
  df_case = x[x$vocabulary_val==voca,]  #select rows with dx voca 
  case_id = unique(df_case$mrd_pt_id) #find all the cases id 
  label = as.data.frame(cbind(case_id, rep('case',length(case_id))))
  colnames(label) = c('case_id', 'label')
  #control_id =  setdiff(unique(x$mrd_pt_id), unique(df_case$mrd_pt_id)) #find all the control id 
  #df_control = x[x$mrd_pt_id %in% control_id, ] # create control dataset 
  df_lab = merge(x,label, by.x='mrd_pt_id',by.y='case_id',all.x=TRUE)
  df_lab$label = as.character(df_lab$label)
  df_lab$label[is.na(df_lab$label)] <- 'ctrl'
  tb = table(df_lab$label, df_lab$val_disc) 
  
  for (k in 5:(length(unique(x$val_disc))) )
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
setwd('P:/projects/new_dataset_peakval_only/ESR/data/')
result = read.csv('../result/ESR_chisquare_result_updated.csv')
result = result[,-1]
dict = read.csv('P:/projects/new_dataset_peakval_only/ESR/data/icd_ESR-peak_0216-after.csv',sep = '|',header= 0,fileEncoding="UTF-8-BOM")
dict = dict[!duplicated(dict$V1),]
dict = dict[dict$V2!='',]
colnames(dict)[ncol(dict)]='icd9_dsc'
final = merge(result, dict, by.x= 'diagnosis', by.y='V1',all.x=T)
data = final 
data$dx_str = paste(data$diagnosis,data$icd9_dsc,sep=':')
data$dx_str= strtrim(data$dx_str,rep(26,length(data$dx_str)))


df_p = data[,c('dx_str','pval_12','pval_13','pval_14','pval_15')]
df1 = melt(df_p, value.name='p_val')
## OR_12: ratio1/ratio2, (1case/1control)/(2case/2control)
df_or = data[,c('dx_str','OR_12','OR_13','OR_14','OR_15')]
df2= melt(df_or, value.name='OddsRatio')

dd = cbind(df1,df2)
dd= dd[,c('dx_str','variable','p_val',"OddsRatio")]
dd_plot = dd[dd$p_val< 0.05, ]
#set cut-off to only show odds ratio that is high 
dd_plot = dd_plot[abs(log(dd_plot$OddsRatio))>2.2,]
## get diagnosis-hisCRP matrix plot 

dd_plot$OddsRatio = as.character(dd_plot$OddsRatio)
dd_plot$OddsRatio = as.numeric(dd_plot$OddsRatio )
dd_plot$indictor =as.numeric(dd_plot$OddsRatio < 1)
dd_plot[dd_plot$indictor==0,'indictor']='decrease_risk'
dd_plot[dd_plot$indictor==1,'indictor']='increase_risk'

###dd_plot1 dropped icd with Inf value which means 0 cell counts in that category 
dd_plot1 = dd_plot
dd_plot1 = dd_plot1[dd_plot1$OddsRatio!='Inf',]

###dd_plot include inf value and mark it with a different indictor which will have a different color mark 
dd_plot[dd_plot$OddsRatio=='Inf','indictor'] = 'zero cell count'
dd_plot= dd_plot[order(dd_plot$dx_str),]
dd_plot$dx_str <- factor(dd_plot$dx_str, levels=unique(dd_plot$dx_str))

dd_plot1= dd_plot1[order(dd_plot1$dx_str),]
dd_plot1$dx_str <- factor(dd_plot1$dx_str, levels=unique(dd_plot1$dx_str))


##create p1, p2, which include and exclude 'Inf' value and add color 
p1=ggplot(dd_plot[1:150,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(1, 4.2))
p2=ggplot(dd_plot1[1:150,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(1, 4.2))
#grid.arrange(p1, p2, nrow = 1)
p1


















p3=ggplot(dd_plot[300:600,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(1, 4.2))
p4=ggplot(dd_plot1[300:600,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(1, 4.2))
#grid.arrange(p1, p2, nrow = 1)


p1=ggplot(dd_plot[1:300,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(1, 4.2))
p2=ggplot(dd_plot1[1:300,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(1, 4.2))
#grid.arrange(p1, p2, nrow = 1)





