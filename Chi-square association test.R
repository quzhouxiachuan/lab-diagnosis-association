library(gtools)
library(plyr)
setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/hisensitivity c-reactive protein/data/')
x=read.csv('./diagnosis-crp.txt',header= 0)
#convert continuous variable to discrete variable using quantile/quartile 

x$val_disc= as.factor(as.numeric(quantcut(x$result_val_num,3)))

#focus on diagnoses that have frequency higher than 10. 
freq = as.data.frame(table(x$vocabulary_val))
dx_list = freq[freq$Freq>=10,]  #change threshold as you want 
dx_list = as.character(dx_list$Var1)
result =  data.frame()
i = 1
for (voca in dx_list)
{ 
  # voca = '216.7'
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
  res12= fisher.test(tb[,1:2]) #chi-sqaure test for more than 2 categories 
  res13= fisher.test(tb[,c(1,3)])
  res23= fisher.test(tb[,2:3])
  result[i,'diagnosis'] = voca
  result[i, 'OR_1vs2'] = res12$estimate
  result[i, 'pval_1vs2'] = res12[1]
  result[i, 'OR_1vs3'] = res13$estimate
  result[i, 'pval_1vs3'] = res13[1]
  result[i, 'OR_2vs3'] = res23$estimate
  result[i, 'pval_2vs3'] =  res23[1]
  i = i+ 1 
  print(i)
  
}

#histograms of diagnosis among different groups 
#diagnosis  OR_1vs2 category1-2_pval category2-3_OR category2_3pval category1-3_OR  category1-3_pval
#get distribution for patinet in three different intervals
#reload data 
library(gtools)
setwd('/Volumes/fsmhome/projects/chi-square test/')
x=read.csv('./chi-square dataset.csv',sep = '\t')
x= x [,1:7]
x= x[,-c(2)]
#convert continuous variable to discrete variable using quantile/quartile 
x$val_disc= as.factor(as.numeric(quantcut(x$result_val_num,3)))
###find diagnosis distribution on the first group 
df1 = x[x$val_disc==1, ]
#hist(df1$val_disc, main= 'group1 diagnosis histogram', xlab = 'diagnoses',cex=2)
library(tidyverse)
tmp1 = df1 %>%
  group_by(vocabulary_val,diagnosis) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))
  
tmp1[1:50,] %>%
  ggplot(aes(x=reorder(diagnosis,count), y=count))+
  geom_bar(stat="identity",fill="indian red")+
  coord_flip() + labs(x='diagnosis') + ggtitle('group1 diagnosis distribution')

df2 = x[x$val_disc==2, ]
tmp2 = df2 %>%
  group_by(vocabulary_val,diagnosis) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))
  tmp2[1:50,] %>%
    ggplot(aes(x=reorder(diagnosis,count), y=count))+
    geom_bar(stat="identity",fill="indian red")+
    coord_flip() + labs(x='diagnosis') + ggtitle('group2 diagnosis distribution')

df3= x[x$val_disc==3, ]
tmp3 = df3 %>%
  group_by(vocabulary_val,diagnosis) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))
  
tmp3[1:50,] %>%
  ggplot(aes(x=reorder(diagnosis,count), y=count))+
  geom_bar(stat="identity",fill="indian red")+
  coord_flip() + labs(x='diagnosis') + ggtitle('group3 diagnosis distribution')

write.csv(tmp1, 'group1_disgnosis_distribution')
write.csv(tmp2, 'group2_disgnosis_distribution')
write.csv(tmp3, 'group3_disgnosis_distribution')

##diagnosis that has odds ratio change among different ESR groups 
#reload data 
data=read.csv('oddsratio-diagnosisfiletering_quartile.csv',row.names = 1 )
data$diagnosis = as.character(data$diagnosis)
const1= data[data$pval_1vs2>0.05&data$pval_1vs3>0.05&data$pval_2vs3>0.05, ]
const2= data[data$pval_1vs2<=0.05&data$pval_1vs3<=0.05&data$pval_2vs3<=0.05, ]
list = unique(c(const1$diagnosis,const2$diagnosis))
data_diff = data[!(data$diagnosis %in% list),]

##select top 5 diagnosis based on frequency, visualize those diagnosis that has different odds ratio between different groups
tmp = x %>%
  group_by(vocabulary_val) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))
#tmp = tmp[!duplicated(tmp$vocabulary_val),]
data_merge = merge(data_diff, tmp, by.y= 'vocabulary_val', by.x= 'diagnosis',all.x=T)

#401.1, V76.12, 477.9, 784, 724.2, 780.52, 268.9,782, V76.51, 

sample= x[x$vocabulary_val =='401.1',]
plot(density(sample$result_val_num))

sample= x[x$vocabulary_val =='V76.12',]
plot(density(sample$result_val_num))

sample= x[x$vocabulary_val =='477.9',]
plot(density(sample$result_val_num))

sample  = x[x$vocabulary_val =='784',] 
plot(density(sample$result_val_num))

sample  = x[x$vocabulary_val =='780.52',] 
plot(density(sample$result_val_num))

sample  = x[x$vocabulary_val =='268.9',] 
plot(density(sample$result_val_num))

sample  = x[x$vocabulary_val =='V76.51',] 
plot(density(sample$result_val_num))

sample  = x[x$vocabulary_val =='723.1',] 
plot(density(sample$result_val_num))

ggplot() + geom_density(data=sample, aes(x=result_val_num, fill='ICD782',alpha=0.5))

d=ggplot() + geom_density(data= sample, aes(x=result_val_num, fill='ICD782',alpha=0.5))+ xlab('hisen-CRP value')+ylab('density') + coord_cartesian(xlim=c(0, 50))
d+ geom_density(data= x, aes(x=result_val_num, fill='population', alpha = 0.5)) 







