
i = 1 
dx= vector()
for (i in (1:length(dx_list$dx_list)))
{
  if(grepl(".+\\.", dx_list$dx_list[i], perl = T))
  {
    print(dx_list$dx_list[i])
    dx[i] = paste(strsplit(dx_list$dx_list[i],'[.]')[[1]][1], 
    strsplit(strsplit(dx_list$dx_list[i],'[.]')[[1]][2], "")[[1]][1],sep = '.')} 
  else 
  {dx[i] = dx_list$dx_list[i]}
  i = i + 1 
}

