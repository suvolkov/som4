#!/bin/sh

# scp -l SSS, SSS -> Kbit/s


echo "Sending abcd to 192.168.137.5:/root/tmpfs/..."
#scp -r -4 -C -l 20000 abcd.mp3 root@192.168.137.5:/root/tmpfs/
#scp -r -4 -C abcd.mp3 root@192.168.137.5:/root/tmpfs/
scp -r abcd.mp3 root@192.168.137.5:/root/tmpfs/
