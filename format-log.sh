if [ `parted /dev/xvdb print | grep primary | awk '{print /ext3/}'` -eq 0 ]
then
    mkfs.ext3 /dev/xvdb1
fi
