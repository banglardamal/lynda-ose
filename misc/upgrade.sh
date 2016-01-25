#!/bin/bash

LYNDA="/home/pi/lynda"

echo "Upgrading Lynda OSE..."

echo "Ensuring proper permission is set..."
sudo chown -R pi:pi $LYNDA
sudo chown -R pi:pi /home/pi/lynda_assets
sudo chown -R pi:pi /home/pi/.lynda

echo "Removing feh (no longer needed)..."
sudo apt-get -y -qq remove feh

echo "Installing libx11-dev (if missing)..."
sudo apt-get -y -qq install libx11-dev

echo "Removing OS-provided supervisor..."
sudo /etc/init.d/supervisor stop
sudo apt-get -qq purge supervisor

echo "Installing supervisor from pip packages"
sudo pip install supervisor==3.2.0 -q > /dev/null

#if log dir was removed on purge
sudo mkdir -p /var/log/supervisor

echo "Removing 'unclutter' and replacing it with a better hack."
sudo apt-get -y -qq remove unclutter
sudo killall unclutter
sudo sed -e 's/^#xserver-command=X$/xserver-command=X -nocursor/g' -i /etc/lightdm/lightdm.conf

echo "Fetching the latest update..."
cd $LYNDA
git pull

echo "Add new supervisor to autostart..."
sudo ln -s "$HOME/lynda/misc/supervisor" /etc/init.d/supervisor
sudo ln -s "$HOME/lynda/misc/supervisord.conf" /etc/supervisor/supervisord.conf
sudo ln -s "$HOME/lynda/misc/supervisord.conf" /etc/supervisord.conf
sudo update-rc.d supervisor defaults
sudo /etc/init.d/supervisor start

echo "Ensuring all Python modules are installed..."
sudo pip install -r $LYNDA/requirements.txt -q

echo "Running migration..."
python $LYNDA/misc/migrate.py

echo "Restarting app-server..."
sudo supervisorctl restart lynda

echo "Restarting X (viewer)..."
sudo pkill -f "xloader.sh"
sudo service lightdm restart

# Make sure we have proper framebuffer depth.
if grep -q framebuffer_depth /boot/config.txt; then
  sudo sed 's/^framebuffer_depth.*/framebuffer_depth=32/' -i /boot/config.txt
else
  echo 'framebuffer_depth=32' | sudo tee -a /boot/config.txt > /dev/null
fi

# Fix framebuffer bug
if grep -q framebuffer_ignore_alpha /boot/config.txt; then
  sudo sed 's/^framebuffer_ignore_alpha.*/framebuffer_ignore_alpha=1/' -i /boot/config.txt
else
  echo 'framebuffer_ignore_alpha=1' | sudo tee -a /boot/config.txt > /dev/null
fi


echo "Done! Please reboot."
