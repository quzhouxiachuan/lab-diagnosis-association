#after getting two column icd9 dict from EDW, the first column is the icd9 code, the sec is the description. Save them as txt file. 
replace all the , and other special symbols. Then re-save as csv file. 

cut -f 1 icd-hisenCRP.txt > file1
cut -f 2 icd-hisenCRP.txt > file2 
sed -i -e 's/\,//g' -e "s/'//g" -e 's/\#//g'  -e 's/\"//g' -e 's/\///g' -e 's/\\//g' file2 
