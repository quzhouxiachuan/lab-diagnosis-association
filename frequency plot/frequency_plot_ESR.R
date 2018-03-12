---
title: "ESRhistogram_bycutoff_visualization"
output:
  html_document: default
  pdf_document: default
---
```{r, echo = F}
library(kableExtra)
dict = read.csv('/Volumes/fsmhome/projects/new_dataset_peakval_only/ESR/data/icd_ESR-peak_0216-after.csv',sep = '|',header= 0,fileEncoding="UTF-8-BOM")
dict = dict[!duplicated(dict$V1),]
dict = dict[dict$V2!='',]
colnames(dict)[ncol(dict)]='icd9_dsc'

setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/ESR/data/')
x=read.csv('./diangosis-esr-peak.csv')
x=x[,-c(1,ncol(x))]
colnames(x) = c('mrd_pt_id','event_dsc','result_val_num','vocabulary_val','event_start_dt_tm','diagnosis_dt')
x$val_disc = as.numeric(cut(x$result_val_num, c(-1,30,50,90,100,120, 130,145,180,200,max(x$result_val_num))))
xx = merge(x,dict, by.x='vocabulary_val', by.y='V1',all.x=T)
xx$icd9_dsc = strtrim(xx$icd9_dsc,45)

x1= xx[xx$val_disc==1,]
x2= xx[xx$val_disc==2,]
x3= xx[xx$val_disc== 3,]
x4= xx[xx$val_disc==4,]
x5= xx[xx$val_disc==5,]
x6= xx[xx$val_disc== 6,] #| xx$val_disc==7 | xx$val_disc==8 | xx$val_disc==9 | xx$val_disc==10 ,]


x7= xx[xx$val_disc==7,]
x8= xx[xx$val_disc==8,]
x9= xx[xx$val_disc==9,]
x10= xx[xx$val_disc==10,]
#x = x[x$vocabulary_val %in% unique(dd_plot$dx_str), ]
```


## show table 
```{r}
#ESR 0-30
freq1 = as.data.frame(table(x1$icd9_dsc))
freq1 = with(freq1, freq1[order(Freq,decreasing=T),])
freq1[1:20,]
#ESR 30-50
freq2 = as.data.frame(table(x2$icd9_dsc))
freq2 =with(freq2, freq2[order(Freq,decreasing=T),])
freq2[1:20,]
#ESR 50-90
freq3 = as.data.frame(table(x3$icd9_dsc))
freq3 = with(freq3, freq3[order(Freq,decreasing=T),])
freq3[1:20,]
#ESR 90-100
freq4 = as.data.frame(table(x4$icd9_dsc))
freq4 = with(freq4, freq4[order(Freq,decreasing=T),])
freq4[1:20,]
#ESR 100-120
freq5 = as.data.frame(table(x5$icd9_dsc))
freq5 = with(freq5, freq5[order(Freq,decreasing=T),])
freq5[1:20,]
#ESR 120-130
freq6 = as.data.frame(table(x6$icd9_dsc))
freq6 = with(freq6, freq6[order(Freq,decreasing=T),])
freq6[1:20,]
#ESR 130-145
freq7 = as.data.frame(table(x7$icd9_dsc))
freq7 = with(freq7, freq7[order(Freq,decreasing=T),])
freq7[1:20,]
#ESR 145-180
freq8 = as.data.frame(table(x8$icd9_dsc))
freq8 = with(freq8, freq8[order(Freq,decreasing=T),])
freq8[1:20,]
#ESR 180-200
freq9 = as.data.frame(table(x9$icd9_dsc))
freq9 = with(freq9, freq9[order(Freq,decreasing=T),])
freq9[1:20,]
#ESR 200- 
freq10 = as.data.frame(table(x10$icd9_dsc))
freq10 = with(freq10, freq10[order(Freq,decreasing=T),])
freq10[1:20,]
```

