#! /bin/sh

sudo launchctl unload /Library/LaunchDaemons/dubielel.Stats.SMC.Helper.plist
sudo rm /Library/LaunchDaemons/dubielel.Stats.SMC.Helper.plist
sudo rm /Library/PrivilegedHelperTools/dubielel.Stats.SMC.Helper
sudo rm $HOME/Library/Application Support/Stats
