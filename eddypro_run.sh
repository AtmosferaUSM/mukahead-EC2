#!/bin/bash

cd /home/ubuntu/eddypro-engine/bin/linux/ # Navigate to EddyPro dir
./eddypro_rp -s linux /home/ubuntu/muka_head.eddypro # Run EddyPro
mv /home/ubuntu/data/mukahead/raw/*.ghg /home/ubuntu/data/mukahead/archive/ # Move processed raw data to archive
