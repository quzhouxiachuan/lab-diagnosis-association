setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/ESR/')
library(ggplot2)
#x=read.csv('P:/projects/new_dataset/peak_lab.txt',sep = '\t',header = 0,fileEncoding="UTF-8-BOM" )
#x[x$V6=='653609','V4'] = x[x$V6=='653609','V4'] * 10 
x=read.table('./esr-pk.txt',sep = '\t',header = 0 )
#delte mrd_pt_id 3267468 where the lab value is abnormal when dealing with ESR 
x = x[x$V1!='3267468',]

title = 'ESR Peak Histogram'
xlab= 'ESR value (mm/Hour)'
ggplot(data=x , aes(V4)) + geom_histogram(binwidth = 3,fill='darkorange',col='black') + 
  labs(title=title, x=xlab)+ theme(axis.text = element_text(size = 15)
   ,axis.title = element_text(size=18), plot.title = element_text(size=20,hjust=0.5)) 

title = 'ESR Peak Boxplot'
xlab= 'ESR'
ylab = 'ESR Value  (mm/Hour)'
ggplot(x, aes(x = '', y = V4)) +
  geom_boxplot(fill = 'darkorange', colour = 'black')  + 
  labs(title=title, x=xlab, y=ylab)+ theme(axis.text = element_text(size = 15)
  ,axis.title = element_text(size=18), plot.title = element_text(size=20,hjust=0.5))

freq= table(x$V4)
write.csv(freq, 'ESR_pk_freqtable.csv')
summary(x$V4)
