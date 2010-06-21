#!/bin/sh

first=$1
last=$2
offset=$3
while [ $first -le $last ]
do
    echo "mvlsd $first `expr $first + $offset`"
    first=`expr $first + 1`
done
