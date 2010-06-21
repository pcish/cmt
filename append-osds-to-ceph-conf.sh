#!/bin/sh

perl nodelist.pl $1 0
. /root/nodelist

counter=0
for node in ${nodelist_lsd_osd[*]}
do
    echo "[osd$counter]" >> /etc/ceph/ceph.conf
    echo "    host = $node" >> /etc/ceph/ceph.conf
    counter=`expr $counter + 1`
done
