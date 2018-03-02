library(cluster) 
library(reshape2)
 setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/ESR/data/')
 result = read.csv('../result/ESR_chisquare_result_updated.csv')
 result = result[,-1]
 dict = read.csv('/Volumes/fsmhome/projects/new_dataset_peakval_only/ESR/data/icd_ESR-peak_0216-after.csv',sep = '|',header= 0,fileEncoding="UTF-8-BOM")
 dict = dict[!duplicated(dict$V1),]
 dict = dict[dict$V2!='',]
 colnames(dict)[ncol(dict)]='icd9_dsc'
 final = merge(result, dict, by.x= 'diagnosis', by.y='V1',all.x=T)
 data = final 
 #data$dx_str = paste(data$diagnosis,data$icd9_dsc,sep=':')
 #data$dx_str= strtrim(data$dx_str,rep(26,length(data$dx_str)))
 data$dx_str = data$diagnosis
 df_p = data[,c('dx_str','pval_12','pval_13','pval_14','pval_15')]
 df1 = melt(df_p, value.name='p_val')
 ## OR_12: ratio1/ratio2, (1case/1control)/(2case/2control)
 df_or = data[,c('dx_str','OR_12','OR_13','OR_14','OR_15')]
 df2= melt(df_or, value.name='OddsRatio')
 dd = cbind(df1,df2)
 dd= dd[,c('dx_str','variable','p_val',"OddsRatio")]
 dd_plot = dd[dd$p_val< 0.05, ]

dd_plot = dd_plot[log(dd_plot$OddsRatio)< -3,]
dd_plot = dd_plot[dd_plot$variable=='pval_15',]
length(unique(dd_plot$dx_str))

setwd('/Volumes/fsmhome/projects/new_dataset_peakval_only/ESR/data/')
x=read.csv('./diangosis-esr-peak.csv')
x=x[,-c(1,ncol(x))]
colnames(x) = c('mrd_pt_id','event_dsc','result_val_num','vocabulary_val','event_start_dt_tm','diagnosis_dt')
x$val_disc = as.numeric(cut(x$result_val_num, c(-1,30,50,90,130,max(x$result_val_num))))
x= x[x$val_disc==5,]
x = x[x$vocabulary_val %in% unique(dd_plot$dx_str), ]
#dim(x)
#[1] 6452    7
x$label = rep(1,dim(x)[1])
xx= x[,c('mrd_pt_id','vocabulary_val','label')]
library(tidyr)
test = spread(xx, key = vocabulary_val, value = label)
test1 = merge(test, x, by= 'mrd_pt_id',all.x=T)
test1 = subset(test1, select = -c(event_dsc,event_start_dt_tm,vocabulary_val,diagnosis_dt,val_disc,label))
test1 = test1[!duplicated(test1$mrd_pt_id),]
test1[is.na(test1)] <- 0

######PAM clustering and visualizatoin ##########

gower_dist <- daisy(test1[, -1],
                    metric = "gower",
                    type = list(logratio = 62))

sil_width <- c(NA)

for(i in 2:10){
  
  pam_fit <- pam(gower_dist,
                 diss = TRUE,
                 k = i)
  
  sil_width[i] <- pam_fit$silinfo$avg.width
  
}

# Plot sihouette width (higher is better)

plot(1:10, sil_width,
     xlab = "Number of clusters",
     ylab = "Silhouette Width")
lines(1:10, sil_width)

pam_fit <- pam(gower_dist, diss = TRUE, k = 9)

dd <- cbind(test1, cluster = pam_fit$cluster)

pam_results <- test1 %>%
  dplyr::select(-mrd_pt_id) %>%
  mutate(cluster = pam_fit$clustering) %>%
  group_by(cluster) %>%
  do(the_summary = summary(.))



tsne_obj <- Rtsne(gower_dist, is_distance = TRUE)
tsne_data <- tsne_obj$Y %>%
  data.frame() %>%
  setNames(c("X", "Y")) %>%
  mutate(cluster = factor(pam_fit$clustering),
         name = test1$mrd_pt_id)

ggplot(aes(x = X, y = Y), data = tsne_data) +
  geom_point(aes(color = cluster))

test1_s = test1

gower_dist_s <- daisy(test1_s[, -1],
                    metric = "gower",
                    type = list(logratio =62 ))
hc.rows <- hclust(gower_dist)
plot(hc.rows)
# transpose the matrix and cluster columns
gower_dist_t <- daisy(t(test1[, -1]),
                    metric = "gower",
                    type = list(logratio = 571))
hc.cols <- hclust(gower_dist_t)

# draw heatmap for first cluster
heatmap(test1[cutree(hc.rows,k=2)==1,], Colv=as.dendrogram(hc.cols), scale='none')

# draw heatmap for second cluster
heatmap(mtscaled[cutree(hc.rows,k=2)==2,], Colv=as.dendrogram(hc.cols), scale='none')

##link to pam clustering: 

#https://www.r-bloggers.com/the-ultimate-guide-to-partitioning-clustering/
#https://www.r-bloggers.com/clustering-mixed-data-types-in-r/
#http://www.sthda.com/english/articles/27-partitioning-clustering-essentials/88-k-medoids-essentials/










