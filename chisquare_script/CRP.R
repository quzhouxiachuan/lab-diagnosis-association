library(gtools)
library(ggplot2)
library(knitr)
library(reshape2)
library(gridExtra)
setwd('P:/projects/new_dataset_peakval_only/c-reactive protein/data/')
x=read.csv('./diagnosis-crp-unique_0220.csv')
x=x[,-c(1,ncol(x))]

colnames(x) = c('mrd_pt_id','event_dsc','result_val_num','vocabulary_val','event_start_dt_tm','diagnosis_dt')
x$vocabulary_val = as.character(x$vocabulary_val)
#0-22 is normal for man, 0-29 is normal range for women. 
x$val_disc = as.numeric(cut(x$result_val_num, c(c(0,3,5,10,20,30,50,100))))

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
  
  for (k in 2:(length(unique(x$val_disc))-1) )
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

## add diagnosis descrition and frequency for each diagnosis 
dict = read.csv('/Volumes/fsmhome/projects/new_dataset_peakval_only/ESR/data/',sep = '|',header= 0)
dict = dict[!duplicated(dict$V1),]
dict = dict[dict$V2!='',]
final = merge(result, dict, by.x= 'diagnosis', by.y='V1',all.x=T)
#final = final[,c('diagnosis','V2','OR_1vs2','pval_1vs2','conf.int_1v2','OR_1vs3','pval_1vs3','conf.int_1v3')]
colnames(final)[ncol(final)]='icd9_dsc'
final1 = merge(final,freq, by.x= 'diagnosis', by.y= 'Var1',all.x=T)
data = final1 
data$dx_str = data$diagnosis
data$diagnosis = as.character(data$diagnosis)
#data$dx_str = paste(data$diagnosis,data$icd9_dsc,sep=':')
## get esr matrix 
## get list of diagnosis-pval12/3/4/5/6/7 pairs that has significant p value for plot 
df_p = data[,c('dx_str','pval_12','pval_13','pval_14','pval_15')]
df1 = melt(df_p, value.name='p_val')
## OR_12: ratio1/ratio2, (1case/1control)/(2case/2control)
df_or = data[,c('dx_str','OR_12','OR_13','OR_14','OR_15')]
df2= melt(df_or, value.name='OddsRatio')

dd = cbind(df1,df2)
dd= dd[,c('dx_str','variable','p_val',"OddsRatio")]
dd_plot = dd[dd$p_val< 0.05, ]
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
dd_plot[dd_plot$OddsRatio=='Inf','indictor'] = 'zero cell ct'
dd_plot= dd_plot[order(dd_plot$dx_str),]
dd_plot$dx_str <- factor(dd_plot$dx_str, levels=unique(dd_plot$dx_str))

dd_plot1= dd_plot1[order(dd_plot1$dx_str),]
dd_plot1$dx_str <- factor(dd_plot1$dx_str, levels=unique(dd_plot1$dx_str))

##create p1, p2, which include and exclude 'Inf' value and add color 
p1=ggplot(dd_plot[1:300,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(0.5, 3))
p2=ggplot(dd_plot1[1:300,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(0.5, 3))
#grid.arrange(p1, p2, nrow = 1)

###repeat to see different rows in the dataframe 
p3=ggplot(dd_plot[300:600,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(0.5, 3))
p4=ggplot(dd_plot1[300:600,], aes(x = variable, y = as.factor(dx_str),color=as.factor(indictor))) + geom_point(aes(size = (as.numeric(1/OddsRatio)))) + scale_size_continuous(range = c(0.5, 3))

##arrange p1 and p2 and p3 and p4 
grid.arrange(p1, p2, p3, p4, nrow = 2)








plot1 = ggplot(dd_plot[1:300,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot2 = ggplot(dd_plot[300:600,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot3 = ggplot(dd_plot[600:900,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot4 = ggplot(dd_plot[900:1200,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot5 = ggplot(dd_plot[1200:1500,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot6 = ggplot(dd_plot[1500:1800,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot7 = ggplot(dd_plot[1800:2100,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot8 = ggplot(dd_plot[2100:2400,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot9 = ggplot(dd_plot[2400:2700,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot10 = ggplot(dd_plot[2700:3000,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot11= ggplot(dd_plot[3000:3300,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot12 = ggplot(dd_plot[3300:3600,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot13 = ggplot(dd_plot[3600:3900,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot14 = ggplot(dd_plot[3900:4200,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot15 = ggplot(dd_plot[4200:4500,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot16 = ggplot(dd_plot[4500:4800,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot17 = ggplot(dd_plot[4800:5100,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot18 = ggplot(dd_plot[5100:5400,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot19= ggplot(dd_plot[5400:5700,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot20 = ggplot(dd_plot[5700:6000,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))
plot21 = ggplot(dd_plot[6000:6300,], aes(x = variable, y = as.factor(dx_str))) + geom_point(aes(size = as.numeric(OddsRatio))) + scale_size_continuous(range = c(0.5, 2.5))








