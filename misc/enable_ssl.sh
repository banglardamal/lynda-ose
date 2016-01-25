#!/bin/bash

echo "Upgrading Lynda..."
curl -sL https://raw.githubusercontent.com/banglardamal/lynda-ose/master/misc/upgrade.sh | bash

echo "Installing Stunnel..."
sudo apt-get -y -qq install stunnel4
sudo ln -s ~/lynda/misc/stunnel.conf /etc/stunnel/screenly.conf

echo "Enable Stunnel to start on boot.."
sudo sed -e 's/^ENABLED=0$/ENABLED=1/g' -i /etc/default/stunnel4

echo "Installing self-signed certificates..."
echo "NOTE: To improve security, you can use properly signed certificates. Just replace screenly.crt and screenly.key in /etc/ssl."
sudo cp ~/lynda/misc/screenly.crt /etc/ssl/
sudo cp ~/lynda/misc/screenly.key /etc/ssl/
sudo chown root:root /etc/ssl/screenly*
sudo chmod 600 /etc/ssl/screenly*

echo "Modify Lynda Server to only listen on localhost (and only allow SSL connections)..."
sed -e 's/^.*listen.*/listen = 127.0.0.1:8080/g' -i ~/.lynda/screenly.conf

echo "Restarting Lynda Server..."
sudo supervisorctl restart lynda

echo "Starting Stunnel..."
sudo /etc/init.d/stunnel4 restart

echo "You should be all set. You should be able to access Lynda's management interface at https://<your IP>"

echo "NOTE: If you have the firewall enabled, make sure to open it up for HTTPS (port 443)."
echo "Assuming you're running UFW, the command is:"
echo "sudo ufw allow 443/tcp"
