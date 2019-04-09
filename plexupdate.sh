#!/bin/bash
echo "###########################" >> /home/plex/scripts/update/plex_downloader.log
echo "#" >> /home/plex/scripts/update/plex_downloader.log
echo "# $(date)" >> /home/plex/scripts/update/plex_downloader.log
echo "#" >> /home/plex/scripts/update/plex_downloader.log
echo "# Checking if any movies are being watched" >> /home/plex/scripts/update/plex_downloader.log
sessions=$(curl http://127.0.0.1:32400/status/sessions?X-Plex-Token=TOKEN | grep "MediaContainer size" | awk -F'[\"]' '{print $2}')
if (($sessions < 1))
then
echo "#" >> /home/plex/scripts/update/plex_downloader.log
echo "# No movies are currently being streamed" >> /home/plex/scripts/update/plex_downloader.log
echo "#" >> /home/plex/scripts/update/plex_downloader.log
echo "# downloading plex.deb" >> /home/plex/scripts/update/plex_downloader.log
wget -O /home/plex/scripts/update/plex.deb "https://plex.tv/downloads/latest/1?channel=16&build=linux-ubuntu-x86_64&distro=ubuntu&X-Plex-Token=TOKEN" >> /home/plex/scripts/update/plex_downloader.log
echo "#" >> /home/plex/scripts/update/plex_downloader.log
echo "# comparing versions" >> /home/plex/scripts/update/plex_downloader.log
newplex="$(dpkg -I /home/plex/scripts/update/plex.deb | grep Version | awk '{print $2}' | awk -F'[ -]' '{print $1}')"
currentplex="$(dpkg -l | grep plexmediaserver | awk '{print $3}' | awk -F'[ -]' '{print $1}')"
echo "# currently installed version is $currentplex" >> /home/plex/scripts/update/plex_downloader.log
echo "# downloaded version is $newplex" >> /home/plex/scripts/update/plex_downloader.log
/usr/bin/dpkg --compare-versions $newplex gt $currentplex
if (($? < 1))
then
        echo "#" >> /home/plex/scripts/update/plex_downloader.log
        echo "# $newplex is greater than $currentplex" >> /home/plex/scripts/update/plex_downloader.log
        echo "# installing downloaded plex" >> /home/plex/scripts/update/plex_downloader.log
        echo "#" >> /home/plex/scripts/update/plex_downloader.log
        /usr/bin/dpkg -i /home/plex/scripts/update/plex.deb >> /home/plex/scripts/update/plex_downloader.log
        echo "#" >> /home/plex/scripts/update/plex_downloader.log
        echo "# renaming downloaded package to plex.$newplex.deb" >> /home/plex/scripts/update/plex_downloader.log
        mv /home/plex/scripts/update/plex.deb /home/plex/scripts/update/plex.$newplex.deb
        echo "#" >> /home/plex/scripts/update/plex_downloader.log
else
        echo "#" >> /home/plex/scripts/update/plex_downloader.log
        echo "# $newplex is not greater than $currentplex" >> /home/plex/scripts/update/plex_downloader.log
        echo "# deleting downloaded package" >> /home/plex/scripts/update/plex_downloader.log
        rm plex.deb
fi
else
echo "#" >> /home/plex/scripts/update/plex_downloader.log
echo "# A movie is currently being streamed, will not check on upgrade" >> /home/plex/scripts/update/plex_downloader.log
fi
echo "#" >> /home/plex/scripts/update/plex_downloader.log
echo "###########################" >> /home/plex/scripts/update/plex_downloader.log
