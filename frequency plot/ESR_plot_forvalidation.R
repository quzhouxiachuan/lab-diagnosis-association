setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/ESR/data/') 
x = read.csv('./pkESR_diagnosis_validation_03082018.csv', sep = '\t',header = 0)
x = x[x$result_val_num!='3139995',]
#x$val_disc = as.numeric(cut(x$result_val_num, c(-1,50,90,100,120, 130,145,
                  #                              180,200,max(x$result_val_num))))
colnames(x) = c('mrd_pt_id','event_cd','result_val_num','unit','vocabulary_val','event_start_dt_tm','diagnosis_dt','icd9_dsc')
dict = x[,c('vocabulary_val','icd9_dsc')]
dict = dict[!duplicated(dict$vocabulary_val),]
xx= x 
xx = merge(xx, dict, by= 'vocabulary_val',all.x = T)
xx = xx[,-9] # original description 
xx = xx[,-8]
colnames(xx)[8] = 'icd9_dsc'
xx$icd9_dsc = strtrim(xx$icd9_dsc,55)
xx$val_disc = as.numeric(cut(xx$result_val_num, c(-1,50,90,100,120, 130,145,180,200,max(x$result_val_num))))
xx = xx[xx$icd9_dsc!='NULL',]


x1= xx[xx$val_disc==1,]
x2= xx[xx$val_disc==2,]
x3= xx[xx$val_disc== 3,]
x4= xx[xx$val_disc==4,]
x5= xx[xx$val_disc==5,]
x6= xx[xx$val_disc== 6,] #| xx$val_disc==7 | xx$val_disc==8 | xx$val_disc==9 | xx$val_disc==10 ,]
x7= xx[xx$val_disc==7,]
x8= xx[xx$val_disc==8,]
x9= xx[xx$val_disc==9,]

freq1 = as.data.frame(table(x1$icd9_dsc))
freq1 = with(freq1, freq1[order(Freq,decreasing=T),])
freq1[1:20,]

freq2 = as.data.frame(table(x2$icd9_dsc))
freq2 =with(freq2, freq2[order(Freq,decreasing=T),])
freq2[1:20,]

freq3 = as.data.frame(table(x3$icd9_dsc))
freq3 = with(freq3, freq3[order(Freq,decreasing=T),])
freq3[1:20,]

freq4 = as.data.frame(table(x4$icd9_dsc))
freq4 = with(freq4, freq4[order(Freq,decreasing=T),])
freq4[1:20,]

freq5 = as.data.frame(table(x5$icd9_dsc))
freq5 = with(freq5, freq5[order(Freq,decreasing=T),])
freq5[1:20,]

freq6 = as.data.frame(table(x6$icd9_dsc))
freq6 = with(freq6, freq6[order(Freq,decreasing=T),])
freq6[1:20,]

freq7 = as.data.frame(table(x7$icd9_dsc))
freq7 = with(freq7, freq7[order(Freq,decreasing=T),])
freq7[1:20,]

freq8 = as.data.frame(table(x8$icd9_dsc))
freq8 = with(freq8, freq8[order(Freq,decreasing=T),])
freq8[1:20,]

freq9 = as.data.frame(table(x9$icd9_dsc))
freq9 = with(freq9, freq9[order(Freq,decreasing=T),])
freq9[1:20,]
