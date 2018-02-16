
library(gtools)
library(ggplot2)
library(knitr)

setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/hisensitivity c-reactive protein/data/')
#in windows: setwd('P:/projects/new_dataset_peakval_only/hisensitivity c-reactive protein/data')
x=read.csv('./diagnosis-hisencrp_pk.csv',header = 0 )
colnames(x) = c('mrd_pt_id','event_cd','vocabulary_value','result_val_num','result_units_dsc','event_start_dt_tm','diagnosis_dt')
#convert between units if it is high sensitivity reactive protein 
x[x$result_units_dsc=='mg/dL','result_val_num'] = x[x$result_units_dsc=='mg/dL','result_val_num']*10
x$vocabulary_value = as.character(x$vocabulary_value)

title = 'Hisensitivity CRP Peak Histogram'
xlab= 'Hisensitivity CRP value (mg/L)'
ggplot(data=x , aes(result_val_num)) + geom_histogram(binwidth = 3,fill='darkorange',col='black') +
  labs(title=title, x=xlab)+ theme(axis.text = element_text(size = 15)
   ,axis.title = element_text(size=18), plot.title = element_text(size=20,hjust=0.5)) 

title = ''
xlab= 'Hisensitivity CRP'
ylab = 'Hisensitivity CRP Value  (mg/L)'
ggplot(x, aes(x = '', y = result_val_num)) +
  geom_boxplot(fill = 'darkorange', colour = 'black')  + 
  labs(title=title, x=xlab, y=ylab)+ theme(axis.text = element_text(size = 15)
  ,axis.title = element_text(size=18), plot.title = element_text(size=20,hjust=0.5))
  

x$val_disc= as.factor(as.numeric(quantcut(x$result_val_num,3)))

#focus on diagnoses that have frequency higher than 10. 
freq = as.data.frame(table(x$vocabulary_val))
#freq=freq[freq$Var1!='*****',]
dx = freq[freq$Freq>=10,]  #change threshold as you want 
dx_list = as.character(dx$Var1)
#delete those starting with V 
dx_list = dx_list[-grep("V", dx_list, perl=TRUE)]
##running time: 9:16 - 9:27
result =  data.frame()
i = 1
for (voca in dx_list)
{ 
  # voca = '250.00'
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
  result[i,'diagnosis'] = voca
  result[i, 'OR_1vs2'] = res12$estimate
  result[i, 'pval_1vs2'] = res12[1]
  format(round(1.1234, 2), nsmall = 2)
  result[i, 'conf.int_1v2']=paste('[',format(round(res12$conf.int[1],2),nsmall=2),',',format(round(res12$conf.int[2],2),nsmall=2),']')
  result[i, 'OR_1vs3'] = res13$estimate
  result[i, 'pval_1vs3'] = res13[1]
  result[i, 'conf.int_1v3']=paste('[',format(round(res13$conf.int[1],2),nsmall=2),',',format(round(res13$conf.int[2],2),nsmall=2),']')
  i = i+ 1 
  print(i)
}

###plot chi-square result 
dict = read.csv('/Volumes/fsmhome/projects/new_dataset_peakval_only/hisensitivity c-reactive protein/data/icd-hisenCRP-after.txt',sep = '|',header= 0)
dict = dict[!duplicated(dict$V1),]
dict = dict[dict$V2!='',]
final = merge(result, dict, by.x= 'diagnosis', by.y='V1',all.x=T)
final = final[,c('diagnosis','V2','OR_1vs2','pval_1vs2','conf.int_1v2','OR_1vs3','pval_1vs3','conf.int_1v3')]
colnames(final)[2]='icd9_dsc'
final1 = merge(final,freq, by.x= 'diagnosis', by.y= 'Var1',all.x=T)
data = final1 
data$diagnosis = as.character(data$diagnosis)


#### get diagnosis that are significant between group1 and group 2 but not between group1 and group3. 

group2vs1= data[data$pval_1vs2<=0.05 & data$pval_1vs3>0.05, ]
dim(group2vs1)
write.csv(group2vs1,'chi-square_group12_significant_only.csv')
##plot
group2vs1$diagnosis = as.character(group2vs1$diagnosis)
group2vs1= group2vs1[order(group2vs1$Freq, decreasing = T),]
group2vs1$diagnosis <- factor(group2vs1$diagnosis, levels=unique(group2vs1$diagnosis))
ggplot(group2vs1[1:40,], aes(x=diagnosis, y=OR_1vs2)) + 
  geom_point(size=3) + 
  geom_segment(aes(x=diagnosis, 
                   xend=diagnosis, 
                   y=0, 
                   yend=OR_1vs2)) + 
  labs(title="Lollipop Chart", 
       subtitle="hisensitivity c-reactive protein: odds ratio group2 vs group1", 
       caption="order by the frequency of diagnosis") + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) 

#### get diagnosis that are significant between group1 and group 3 but not between group1 and group2. 
group3vs1= data[data$pval_1vs2>0.05 & data$pval_1vs3<=0.05, ]
dim(group3vs1)
write.csv(group3vs1,'chi-square_group13_significant_only.csv')

#plot
group3vs1$diagnosis = as.character(group3vs1$diagnosis)
group3vs1= group3vs1[order(group3vs1$Freq, decreasing = T),]
group3vs1$diagnosis <- factor(group3vs1$diagnosis, levels=unique(group3vs1$diagnosis))
ggplot(group3vs1[1:40,], aes(x=diagnosis, y=OR_1vs3)) + 
  geom_point(size=3) + 
  geom_segment(aes(x=diagnosis, 
                   xend=diagnosis, 
                   y=0, 
                   yend=OR_1vs3)) + 
  labs(title="Lollipop Chart", 
       subtitle="hisensitivity c-reactive protein: odds ratio group3 vs group1", 
       caption="order by the frequency of diagnosis") + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) 

####get diagnosis that are significant in both group12, group13. 
group23= data[data$pval_1vs2<=0.05 & data$pval_1vs3<=0.05, ]
dim(group23)
write.csv(group23,'chi-square_group23_significant_both.csv')
#plot
group23$diagnosis = as.character(group23$diagnosis)
group23= group23[order(group23$Freq, decreasing = T),]
group23$diagnosis <- factor(group23$diagnosis, levels=unique(group23$diagnosis))
ggplot(group23[1:50,], aes(x=diagnosis, y=OR_1vs3)) + 
  geom_point(size=3) + 
  geom_segment(aes(x=diagnosis, 
                   xend=diagnosis, 
                   y=0, 
                   yend=OR_)) + 
  labs(title="Lollipop Chart", 
       subtitle="hisensitivity c-reactive protein: odds ratio group23vs1", 
       caption="order by the frequency of diagnosis") + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) 
