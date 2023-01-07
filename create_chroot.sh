#!/bin/bash
set -e -x

[ $(id -u) -eq 0 ]

mkdir -p rh5_chroot
mkdir -p cdrom_chroot

chroot=cdrom_chroot
cdrom=/mnt/cdrom

for f in etc lib var bin sbin usr; do 
	mkdir -p $chroot/$f
	mount --bind /mnt/cdrom/live/$f $chroot/$f
done

for f in proc dev home mnt mnt/target mnt/cdrom root root/src/aix_toolchain_new; do
	mkdir -p $chroot/$f
done

mount --bind /proc $chroot/proc

mount --bind rh5_chroot $chroot/mnt/target

mount --bind $cdrom $chroot/mnt/cdrom

mount --bind . $chroot/root/src/aix_toolchain_new

if [ "$1" == "-c" ]; then 
  result=1
  chroot $chroot /bin/bash || true

elif [ "$1" == "-f" ]; then

  result=1
  chroot $chroot /bin/bash /root/src/aix_toolchain_new/find_on_cdrom.sh "$2" || true

else

  result=0
  chroot $chroot /bin/bash /root/src/aix_toolchain_new/rpm_chroot_init || result=1
  if [ $result -ne 0 ]; then
	echo "ERRORED: dropping into shell to investigate"
	chroot $chroot /bin/bash || true
  fi
fi

for f in $(mount | fgrep $chroot | cut -d' ' -f3 | sort -r); do sudo umount $f; done

if [ $result -ne 0 ]; then
	exit 1
fi

chroot=rh5_chroot

for f in proc dev home mnt mnt/target mnt/cdrom root; do
	mkdir -p $chroot/$f
done


mount --bind /proc $chroot/proc
mount --bind /dev $chroot/dev

mkdir -p $chroot/mnt/cdrom
mount --bind $cdrom $chroot/mnt/cdrom

mkdir -p $chroot/home/user
chown -R 1000:1000 $chroot/home/user

mkdir -p $chroot/home/user/src

echo "user:x:1000:1000::/home/user:/bin/sh" >> $chroot/etc/passwd

mkdir -p $chroot/home/user/src/aix_toolchain_new
pwd
mount --bind $(pwd) $chroot/home/user/src/aix_toolchain_new

#chroot $chroot '/bin/bash -c "cd /root/src/aix_toolchain_new; ls -l; ./go" ' || true
#chroot $chroot /bin/bash || true
#chroot $chroot /bin/su user -c "/bin/bash /home/user/src/aix_toolchain_new/go_in_rpm_chroot.sh" || true

result=0
chroot $chroot /bin/bash /home/user/src/aix_toolchain_new/go_in_rpm_chroot.sh || result=1
#if [ $result -ne 0 ]; then
#	echo "ERRORED, opening chroot shell to investigate"
#	chroot $chroot /bin/bash || true
#fi

for f in $(mount | fgrep $chroot | cut -d' ' -f3 | sort -r); do sudo umount $f; done

