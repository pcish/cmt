#!/bin/sh

first=$1
last=$2
offset=$3
while [ $first -le $last ]
do
    sh mvlsd $first `expr $first + $offset`
    first=`expr $first + 1`
done
