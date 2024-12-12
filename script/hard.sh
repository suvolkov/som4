#!/bin/sh

# DTS->DTB: dtc -I dts -O dtb -o output.dtb input.dts
# DTB->DTS: dtc -I dtb -O dts -o output.dts input.dtb

cd ../
quartus_cpf -c output_files/tse_devboard.sof output_files/dev_5cs.rbf
dtc -I dts -O dtb -o output_files/socfpga_mitysom5csx_devkit.dtb output_files/socfpga_mitysom5csx_devkit.dts

if [ $? -eq 0 ]
then
echo "Sending .rbf and .dtb files to the target 192.168.137.5:/mnt/sdcard/..."
scp -r output_files/dev_5cs.rbf root@192.168.137.5:/mnt/sdcard/
scp -r output_files/socfpga_mitysom5csx_devkit.dtb root@192.168.137.5:/mnt/sdcard/

##sopc2dts --input ARM_system.sopcinfo --output socfpga.dts --bridge-removal all --clocks
##sopc2dts --input ARM_system.sopcinfo --output socfpga.dtb --type dtb --bridge-removal all --clocks
fi
