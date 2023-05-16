#!/bin/bash -eux

case "$PACKER_BUILDER_TYPE" in

   azure-arm)
      # When this is a RHEL8 variant
      if [ -e /etc/redhat-release ]; then
         major=$(tr -dc '0-9.' <  /etc/redhat-release | cut -d \. -f1)
         if ((major == 8))
         then
            sudo dnf makecache
            # Install python 3.6 
            sudo dnf install -y git-core ansible-core
          fi
      fi
      ;;
   *)
      echo "No RPMs to install"
      ;;
esac   
sudo pip3.9 install jmespath