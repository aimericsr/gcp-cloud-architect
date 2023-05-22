sudo mkdir -p /home/minecraft

format the disk : 
sudo mkfs.ext4 -F -E lazy_itable_init=0,\
lazy_journal_init=0,discard \
/dev/disk/by-id/google-minecraft-disk

mount the disk : 
sudo mount -o discard,defaults /dev/disk/by-id/google-minecraft-disk /home/minecraft

install dependencies : 
sudo apt-get update
sudo apt-get install -y default-jre-headless
cd /home/minecraft
sudo apt-get install wget
sudo wget https://launcher.mojang.com/v1/objects/d0d0fe2b1dc6ab4c65554cb734270872b72dadd6/server.jar

initialize server : 
sudo java -Xmx1024M -Xms1024M -jar server.jar nogui
sudo ls -l
sudo nano eula.txt

lunch as background : 
sudo apt-get install -y screen
sudo screen -S mcs java -Xmx1024M -Xms1024M -jar server.jar nogui
sudo screen -r mcs

backup vm on cloud storage : 
export YOUR_BUCKET_NAME=aaaaaaaaa
echo $YOUR_BUCKET_NAME
gsutil mb gs://$YOUR_BUCKET_NAME-minecraft-backup

create backup script : 
cd /home/minecraft
sudo nano /home/minecraft/backup.sh

#!/bin/bash
screen -r mcs -X stuff '/save-all\n/save-off\n'
/usr/bin/gsutil cp -R ${BASH_SOURCE%/*}/world gs://${YOUR_BUCKET_NAME}-minecraft-backup/$(date "+%Y%m%d-%H%M%S")-world
screen -r mcs -X stuff '/save-on\n'

sudo chmod 755 /home/minecraft/backup.sh

test the script file and schedule a cron job : 
. /home/minecraft/backup.sh
sudo crontab -e

copy this line to the end of the file : 
0 */4 * * * /home/minecraft/backup.sh

server maintenance : 
sudo screen -r -X stuff '/stop\n'

add metadata : 
startup-script-url	https://storage.googleapis.com/cloud-training/archinfra/mcserver/startup.sh
shutdown-script-url	https://storage.googleapis.com/cloud-training/archinfra/mcserver/shutdown.sh