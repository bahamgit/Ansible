# Install des pacquets nécessaires
apt update && apt upgrade -y
apt install -y p7zip-full wget cloud-image-utils xorriso

# Récupérer un fichier de configuration par défaut d'un server Ubuntu
cp /var/log/installer/autoinstall-user-data ~/

# Rajoutez les packages que vous souhaitez installer après la section apt
sed -i '15i\  paqueges:\
\ \ -\ microcode.ctl\
\ \ -\ irqbalance\
\ \ -\ sudo\
\ \ -\ postfix\
\ \ -\ sysstat'  autoinstall-user-data
###############################
sed '/drivers:/i\
\
\  paqueges:\
\ \ -\ microcode.ctl\
\ \ -\ irqbalance\
\ \ -\ sudo\
\ \ -\ postfix\
\ \ -\ sysstat\
' autoinstall-user-data > autoinstall-user-data1
mv autoinstall-user-data1 autoinstall-user-data
###############################

# Indiquez à l’installer que vous souhaitez mettre à jour le cache des dépots et le système, juste après la section packages
sed '/drivers:/i\
\  paquege_update: true\
\  package_upgrade: true\
' autoinstall-user-data > autoinstall-user-data1
mv autoinstall-user-data1 autoinstall-user-data


mkdir -p ~/autoinstall-ubuntu/seedAuto/data
cd autoinstall-ubuntu/seedAuto/

cp ~/autoinstall-user-data ~/autoinstall-ubuntu/seedAuto/data/user-data

touch ~/autoinstall-ubuntu/seedAuto/data/meta-data

cloud-localds ~/seed.iso ~/autoinstall-ubuntu/seedAuto/data/user-data ~/autoinstall-ubuntu/seedAuto/data/meta-data


mkdir -p ~/autoinstall/source-files

wget https://cdimage.ubuntu.com/ubuntu-server/jammy/daily-live/current/jammy-live-server-amd64.iso
mv mv jammy-* ~/autoinstall

cd autoinstall
7z -y x jammy-live-server-amd64.iso -osource-files/
cd source-files
mv \[BOOT\]/ ../BOOT

vi boot/grub/grub.cfg

menuentry "Autoinstall Ubuntu Server" {
set gfxpayload=keep
linux /casper/vmlinuz autoinstall ---
initrd /casper/initrd
}

cd ..
xorriso -indev jammy-live-server-amd64.iso -report_el_torito as_mkisofs

cd source-files
xorriso -as mkisofs -r \
-V 'Ubuntu-Server 22.04.1 LTS amd64' \
-o ../ubuntuAutoinstall.iso \
--grub2-mbr ../BOOT/1-Boot-NoEmul.img \
-partition_offset 16 \
--mbr-force-bootable \
-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b ../BOOT/2-Boot-NoEmul.img \
-appended_part_as_gpt \
-iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
-c '/boot.catalog' \
-b '/boot/grub/i386-pc/eltorito.img' \
-no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
-eltorito-alt-boot \
-e '--interval:appended_partition_2:::' \
-no-emul-boot \
.

cd
scp seed.iso amad@37.187.132.7:/vmfs/volumes/STORAGE_Commun/iso
scp autoinstall/ubuntuAutoinstall.iso amad@37.187.132.7:/vmfs/volumes/STORAGE_Commun/iso

