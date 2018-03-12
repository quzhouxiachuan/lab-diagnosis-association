#first, save your EDW output as .txt file

#get the diagnosis list and delete all , and other special symbols 
cut -f 5 ESR_diangosis_outpatient03122018.txt > file1
sed -i -e 's/\,//g' -e "s/'//g" -e 's/\#//g'  -e 's/\"//g' -e 's/\///g' -e 's/\\//g' -e 's/\|//g' file1
sed -i -e 's/[ \t]*//' file1 

#get the columns other than diagnosis. 
cut -f 1,2,3,4,6,7 ESR_diangosis_outpatient03122018.txt > file2 
sed -i -e 's/\,//g' -e "s/'//g" -e 's/\#//g'  -e 's/\"//g' -e 's/\///g' -e 's/\\//g' -e 's/\|//g' file2
sed -i -e 's/\t/,/g' file2

paste -d"," file1 file2 > ESR_diangosis_outpatient03122018.csv
#delete ^M symbol 
tr -d '\b\r' < ESR_diangosis_outpatient03122018.csv > ESR_diangosis_outpatient03122018_icd.csv
