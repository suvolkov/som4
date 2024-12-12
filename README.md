# tse_devboard
TSE on development board

Copy project to your local machine:
1. git clone git@github.com:xxkent/tse_devboard.git

-----------------How to build HW-----------------
For CycloneV use Standart Quartus version, not Pro!
Windows:
1. Open Quartus 18.1 (any version which support cyclone 5)
2. File -> Open Project -> tse_devboard.qpf
3. Tools -> Platform Designer, select tse_devboard_hps.qsys
4. Push 'Generate HDL' button -> Generate
5. Close, Finish
6. Processing -> Start compilation
7. Find generated binaries in 'tse_devboard/output_files' folder

-----------------How to build SW-----------------
Repositories¶
Type	                Repo	                                                        Branch
Kernel	                git://support.criticallink.com/home/git/linux-socfpga.git	    socfpga-4.9.78-ltsi
U-Boot	                git://support.criticallink.com/home/git/u-boot-socfpga.git	    socfpga_v2013.01.01
Yocto Layer	            git://git.criticallink.com/home/git/meta-cl-socfpga.git	        rocko
FPGA Reference Projects	git://support.criticallink.com/home/git/mitysom-5csx-ref.git	18.1-stable


Links:
https://support.criticallink.com/redmine/projects/mityarm-5cs/wiki
https://support.criticallink.com/redmine/boards/47/topics/6142

//--------------------------------------------------------------------------------------------------------------------
Building U-BOOT(Only Quartus 18.1 and earlier, Windows)(On Linux and Windows):
//--------------------------------------------------------------------------------------------------------------------
https://support.criticallink.com/redmine/projects/mityarm-5cs/wiki/Building_uboot_181

1. Run as Admin "SoC EDS 18.1 Command Shell"
2. bsp-editor &
3. File->New HPS BSP
4. Preloader settings dirrectory: ..\tse_devboard\hps_isw_handoff\tse_devboard_hps_hps, OK
5. In the BSP Editor, change the name of the PRELOADER_TGZ file for U-Boot to just uboot-socfpga.tar.gz (remove the path)
6. Clear WATCHDOG_ENABLE
7. Generate and then Exit
8. cd /cygdrive/...path/to/tse_devboard/software/spl_bsp
9. Modify <project>/software/spl_bsp/Makefile to use the MitySOM-5CSx board configuration instead of the stock Altera DevKit configuration:
    sed -i 's/socfpga_\$(DEVICE_FAMILY)/mitysom-5csx/' Makefile
    sed -i 's/altera\/socfpga/cl\/mitysom-5csx/' Makefile
10. cp /cygdrive/c/intelFPGA/18.1/embedded/host_tools/altera/preloader/uboot-socfpga.patch/cygwin/* .
11. Fix a permission issue with the generated code.
    sed -i '/update-src:/a\\t@$(CHMOD) -R 755 $(PRELOADER_SRC_DIR)' Makefile
    sed -i '/@$(CP) -v $< $@/a\\t@$(CHMOD) -R 755 $(PRELOADER_SRC_DIR)' Makefile
12. git archive --format=tar.gz --prefix=uboot-socfpga/ --remote=git://support.criticallink.com/home/git/u-boot-socfpga.git socfpga_v2013.01.01 > uboot-socfpga.tar.gz
13. Build the preloader:    "make -j8"     Build the preloader. The image will be found at <project>/software/spl_bsp/preloader-mkpimage.bin
14. Build U-Boot:   "make -j8 uboot"    The image will be found at <project>/software/spl_bsp/uboot-socfpga/u-boot.img
15. After building U-Boot, the environment must be created. This environment will be stored on the SD card and is used to tell U-Boot where to load the kernel, FPGA image, device tree, and root filesystem from. Build the U-Boot environment image. uBootMMCEnv.txt is a human-readable file which has all the U-Boot environment variables required to boot Linux from the SD card. ubootenv.bin is a binary blob that U-Boot will read on startup to populate its environment variables. The image will be found at <project>/software/spl_bsp/ubootenv.bin.
    uboot-socfpga/tools/mkenvimage -s 4096 -o ubootenv.bin UBootMMCEnv.txt

//--------------------------------------------------------------------------------------------------------------------
Building Linux for MitySom(On Linux):
//--------------------------------------------------------------------------------------------------------------------
https://support.criticallink.com/redmine/projects/mityarm-5cs/wiki/Building_kernel_181
The current supported kernel version is 4.9.78-ltsi.
git clone git://support.criticallink.com/home/git/linux-socfpga.git
git checkout socfpga-4.9.78-ltsi

1. Dowmoload: https://support.criticallink.com/redmine/attachments/download/21782/poky-glibc-x86_64-mitysom-image-base-cortexa9hf-neon-toolchain-2.4.4.sh
2. Install the script to /opt/poky/2.4.4/ : ./poky-glibc-x86_64-mitysom-image-base-cortexa9hf-neon-toolchain-2.4.4.sh
3. source /opt/poky/2.4.4/environment-setup-cortexa9hf-neon-poky-linux-gnueabi
4. git clone https://support.criticallink.com/git/linux-socfpga.git -b socfpga-4.9.78-ltsi
5. cd linux-socfpga
6. make ARCH=arm CROSS_COMPILE=arm-poky-linux-gnueabi- -j8 mitysom5csx_devkit_defconfig
7. make ARCH=arm CROSS_COMPILE=arm-poky-linux-gnueabi- -j8 zImage
8. make ARCH=arm CROSS_COMPILE=arm-poky-linux-gnueabi- -j8 dtbs
Building modules:
9. make ARCH=arm CROSS_COMPILE=arm-poky-linux-gnueabi- -j8 modules
10. make ARCH=arm CROSS_COMPILE=arm-poky-linux-gnueabi- INSTALL_MOD_PATH=/tmp modules_install

Note:
Each time you wish to use the SDK in a new shell session, you need to source the environment setup script e.g.
 $ . /opt/poky/2.4.4/environment-setup-cortexa9hf-neon-poky-linux-gnueabi

//--------------------------------------------------------------------------------------------------------------------
SD Card:
https://support.criticallink.com/redmine/projects/mityarm-5cs/wiki/Building_sd_181
//--------------------------------------------------------------------------------------------------------------------
MitySOM configuration requirements:
The BSEL pins must be set to 0x5 (101b) since the device uses 3.3V. Note: 0x4 (100b) is for a 1.8V device, so don't use it.
The CSEL pins must be strapped to match your clock configuration.
The MSEL pins must be strapped to match your desired FPGA configuration.

The following files are required to be in the same directory:
1. dev_5cs.rbf
2. mitysom-image-base-mitysom-c5.tar.gz
3v. preloader-mkpimage.bin
4v. u-boot.img
5v. ubootenv.bin
6v. make_sd.sh (SD card image generation script)

The following packages must be installed before the script can be run. Note: You must reboot after adding the user to the kvm group.
sudo apt-get install --no-install-recommends -y libguestfs-tools qemu-utils linux-image-generic
sudo chmod o+r,g+r /boot/vmlinuz-*
sudo chmod 0666 /dev/kvm
sudo usermod -a -G kvm $USER

1. git archive --format=tar --remote=git://support.criticallink.com/home/git/meta-cl-socfpga.git rocko recipes-bsp/sd-card-scripts/files/make_sd.sh | tar -xO > make_sd.sh
2. sudo chmod +x make_sd.sh
cp /mnt/hgfs/F/unit-m/software/tse_devboard/software/spl_bsp/ubootenv.bin ~/src/unit-m/sdcard/
cp /mnt/hgfs/F/unit-m/software/tse_devboard/software/spl_bsp/preloader-mkpimage.bin ~/src/unit-m/sdcard/
cp /mnt/hgfs/F/unit-m/software/tse_devboard/software/spl_bsp/uboot-socfpga/u-boot.img ~/src/unit-m/sdcard/
Building the SD card image:
3.
sudo chmod o+r,g+r /boot/vmlinuz-*
./make_sd.sh -d CycloneV -p preloader-mkpimage.bin -u u-boot.img -e ubootenv.bin -f dev_5cs.rbf mitysom-image-base-mitysom-c5.tar.gz
Updating the full SD card:
4. sudo umount /dev/mmcblkX*   Replace the mmcblkX shown in the command below with your device: (i.e. mmcblk0 or sdd)
sudo dd if=sd_card.img of=/dev/mmcblkX bs=4M status=progress
sync

Updating parts of the SD card
Updating the U-Boot environment
The U-Boot environment is stored immediately after the MBR on the SD card and not on a partition. In order to write the U-Boot environment, you will need to write it raw to the partition using the dd command.
sudo umount /dev/mmcblkX*
sudo dd if=ubootenv.bin of=/dev/mmcblkX bs=512 seek=1
sync

Updating the FPGA image:
The Critical Link provided FPGA .rbf file is stored on the first partition of the SD card, which has the Windows FAT filesystem. This means that they can easily be updated from either a Windows machine or a Linux machine.
sudo mount /dev/mmcblkXp1 /mnt
sudo cp dev_5cs.rbf /mnt
sync
sudo umount /mnt


Updating the preloader:
The preloader is stored on the second partition of the SD card, which does not have a filesystem. In order to write the preloader, you will need to write it raw to the partition using the dd command.
sudo umount /dev/mmcblkXp2
sudo dd if=preloader-mkpimage.bin of=/dev/mmcblkXp2 bs=64k
sync


Updating U-Boot:
U-Boot is stored on the second partition of the SD card, which does not have a filesystem. In order to write the U-Boot image, you will need to write it raw to the partition using the dd command.
sudo umount /dev/mmcblkXp2
sudo dd if=u-boot.img of=/dev/mmcblkXp2 bs=64k seek=4
sync

Updating the kernel:
The Critical Link provided Linux root filesystem is stored on the third partition, which is formatted with the EXT3 filesystem. This partition can easily be updated from a Linux host.
sudo mount /mmcblkXp3 /mnt
sudo cp zImage /mnt/boot
sync
sudo umount /mnt

Updating the device tree:
The Critical Link provided Linux root filesystem is stored on the third partition, which is formatted with the EXT3 filesystem. This partition can easily be updated from a Linux host.
sudo mount /mmcblkXp3 /mnt
sudo cp mitysom_5csx_devkit.dtb /mnt/boot
sync
sudo umount /mnt


//--------------------------------------------------------------------------------------------------------------------
Building Root Filesystem 18.1
https://support.criticallink.com/redmine/projects/mityarm-5cs/wiki/Building_fs_181
//--------------------------------------------------------------------------------------------------------------------
sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat \
libsdl1.2-dev python curl libssl-dev bc python3 tig libncurses5-dev libncursesw5-dev


