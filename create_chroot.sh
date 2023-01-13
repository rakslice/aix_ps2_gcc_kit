#!/bin/bash
set -e -x

[ $(id -u) -eq 0 ]

username=$(stat . -c '%U')

[ "$username" != "root" ]
[ -d "/home/$username" ]

# Build a Red Hat Linux 5.0.5 x86 chroot and run go_in_rpm_chroot.sh in it.

# Mount the cdrom somewhere and put its path here

cdrom=/mnt/cdrom

# cdrom_chroot is a space for our chroot with the mount of the cdrom,
# rh5_chroot is the actual chroot we're creating with build tools installed in it.

rh5_chroot=/tmp/rh5_chroot

mkdir -p $rh5_chroot
mkdir -p cdrom_chroot

chroot=cdrom_chroot

# cdrom sanity check
[ -f $cdrom/RedHat/RPMS/rpm-2.4.12-1glibc.i386.rpm ]

for f in etc lib var bin sbin usr; do 
	mkdir -p $chroot/$f
	mount --bind $cdrom/live/$f $chroot/$f
done

for f in proc dev home mnt mnt/target mnt/cdrom root root/src/aix_toolchain_new; do
	mkdir -p $chroot/$f
done

# we're not mounting dev in the cdrom chroot, but something seems to need a bit bucket
if [ ! -e $chroot/dev/null ]; then
	mknod $chroot/dev/null c 1 3
fi

if [ ! -e $rh5_chroot/dev/null ]; then
	mkdir -p $rh5_chroot/dev
	mknod $rh5_chroot/dev/null c 1 3
fi

mount --bind /proc $chroot/proc

mount --bind $rh5_chroot $chroot/mnt/target

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

# rubber band to avoid failng unmount probably because some other make thread
# hasn't quite finished exiting yet
sleep 2

for f in $(mount | fgrep $chroot | cut -d' ' -f3 | sort -r); do sudo umount $f; done

if [ $result -ne 0 ]; then
	exit 1
fi

chroot=$rh5_chroot

for f in proc dev home mnt mnt/target root; do
	mkdir -p $chroot/$f
done


mount --bind /proc $chroot/proc
mount --bind /dev $chroot/dev

mkdir -p $chroot/home/$username
chown -R 1000:1000 $chroot/home/$username

mkdir -p $chroot/home/$username/src

if ! grep "^$username:" $chroot/etc/passwd > /dev/null; then
echo "$username:x:$(id -u "$username"):$(id -g "$username")::/home/$username:/bin/sh" >> $chroot/etc/passwd
fi
if ! grep "^user:" $chroot/etc/group > /dev/null; then
echo "$username:!:$(id -g "$username"):" >> $chroot/etc/group
fi

#mkdir -p $chroot/home/$username/src/aix_toolchain_new
#pwd
#mount --bind $(pwd) $chroot/home/$username/src/aix_toolchain_new

mkdir -p $chroot/home/$username/src/
pwd
cp -a $(pwd) $chroot/home/$username/src/

#chroot $chroot '/bin/bash -c "cd /root/src/aix_toolchain_new; ls -l; ./go" ' || true

if [ "$1" == "-d" ]; then
  echo "DIAGNOSTIC SHELL INSIDE BUILD CHROOT -- exit to continue the build"
  chroot $chroot /bin/bash -c "cd /home/$username/src/aix_toolchain_new; bash" || true
fi
#chroot $chroot /bin/su $username -c "/bin/bash /home/$username/src/aix_toolchain_new/go_in_rpm_chroot.sh" || true

result=0
chroot $chroot /bin/bash /home/$username/src/aix_toolchain_new/go_in_rpm_chroot.sh "$GCC_VER" "$username" || result=1
#if [ $result -ne 0 ]; then
#	echo "ERRORED, opening chroot shell to investigate"
#	chroot $chroot /bin/bash || true
#fi

# rubber band to avoid failng unmount probably because some other make thread
# hasn't quite finished exiting yet
sleep 2

for f in $(mount | fgrep $chroot | cut -d' ' -f3 | sort -r); do sudo umount $f; done

[ $result -eq 0 ]
