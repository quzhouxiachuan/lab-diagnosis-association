setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/c-reactive protein/')
library(ggplot2)
#x=read.table('peak_lab.txt',sep = '\t',header = 0,fileEncoding="UTF-8-BOM" )

x=read.table('./crp-pk.txt',sep = '\t',header = 0 )
#do unit conversion when dealing with hisensitivity crp 
#  x[x$V6=='mg/dl','V4'] = x[x$V6=='mg/dl','V4'] * 10 
#delte mrd_pt_id 3267468 where the lab value is abnormal when dealing with ESR 
#x = x[x$V1!='3267468',]

title = 'Hisensitivity CRP Peak Histogram'
xlab= 'Hisensitivity CRP value (mg/L)'
ggplot(data=x , aes(V4)) + geom_histogram(binwidth = 3,fill='darkorange',col='black') + 
  labs(title=title, x=xlab)+ theme(axis.text = element_text(size = 15)
   ,axis.title = element_text(size=18), plot.title = element_text(size=20,hjust=0.5)) 

title = 'Hisensitivity CRP Peak Boxplot'
xlab= 'Hisensitivity CRP'
ylab = 'Hisensitivity CRP Value  (mg/L)'
ggplot(x, aes(x = '', y = V4)) +
  geom_boxplot(fill = 'darkorange', colour = 'black')  + 
  labs(title=title, x=xlab, y=ylab)+ theme(axis.text = element_text(size = 15)
  ,axis.title = element_text(size=18), plot.title = element_text(size=20,hjust=0.5))

freq= table(x$V4)
write.csv(freq, 'hisensitivity_CRP_pk_freqtable.csv')
summary(x$V4)
