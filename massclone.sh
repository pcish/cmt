#!/bin/sh

maxcpu=8
host=`hostname | cut -c 4-`
host=`expr $host - 1`
id_m=`expr $host \* 20`
id_M=`expr $id_m + 20`

i=$id_m
i=0
id_M=100
writeconfig=`if [ \`hostname\` = "b306" ]; then echo 1; else echo 0; fi`
writeimages=`if [ \`hostname\` != "b306" ]; then echo 1; else echo 0; fi`
while [ $i -lt $id_M ]
do
    echo $i
    perl massclone.pl disk0 lsd-$i $i `expr $i % $maxcpu` $writeconfig $writeimages
    i=`expr $i + 1`
done


