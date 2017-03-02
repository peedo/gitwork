#!/bin/bash
#sed "s/^[ \t]*//" header.txt | awk '/typedef enum/{flag=1;next}/}Error;/{flag=0}flag' | grep -v ^# | sed 's/,//g' > out.txt

INPUTFILE="header.txt"
iDECIMAL=10
cDECIMAL=48
uDECIMAL=1024

IDENTITY=($(sed "s/^[ \t]*//" header.txt | grep -E "^Identity[^[:space:]]+" | sed 's/,//g' | awk '{print $1}'))
CONNECT=($(sed "s/^[ \t]*//" header.txt | grep -E "^Connect[^[:space:]]+" | sed 's/,//g' | awk '{print $1}'))
UPDATE=($(sed "s/^[ \t]*//" header.txt | grep -E "^Update[^[:space:]]+" | sed 's/,//g' | awk '{print $1}'))

for i in "${IDENTITY[@]}"
do
   echo "${i} ${iDECIMAL}"
   ((iDECIMAL++))
done

for c in "${CONNECT[@]}"
do
   echo "${c} ${cDECIMAL}"
   ((cDECIMAL++))
done

for u in "${UPDATE[@]}"
do
   echo "${u} ${uDECIMAL}"
   ((uDECIMAL++))
done

#echo ${IDENTITY[*]}
#echo ${CONNECT[*]}
#echo ${UPDATE[*]}

#grep -iE "\[[Ee][Rr][Rr][Oo][Rr]\] code \((4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])\)" example.txt 
ERRCODE=($(grep -iE "\[[Ee][Rr][Rr][Oo][Rr]\] code \((4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])\) | code \((4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])\) | code (4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])" example.txt))

echo "#---#"
echo $ERRCODE
echo "#---#"


#Regex
#10-47
#([1-3][0-9]|4[0-7])
#48-137 4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])
#(4[89]|[5-9][0-9]|1[0-2][0-9]|13[0-7])
#1024- 
#1024- \[[Ee][Rr][Rr][Oo][Rr]\] code \(0*([1-9]|[1-8][0-9]|9[0-9]|[1-8][0-9]{2}|9[0-8][0-9]|99[0-9]|1[01][0-9]{2}|12[0-6][0-9]|127[0-9])\)
