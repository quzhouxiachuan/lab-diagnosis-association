cut -f 15 ESR_diagnoses_outpatient03112018.txt > file1
sed -i -e 's/\,//g' -e "s/'//g" -e 's/\#//g'  -e 's/\"//g' -e 's/\///g' -e 's/\\//g' -e 's/\|//g' file1
sed -e 's/[ \t]*//' file1 > file3



cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20 ESR_diagnoses_outpatient03112018.txt > file2 

paste -d"\t" file2 file3 > ESR_diagnoses_outpatient03112018_icd.txt
