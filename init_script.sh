#!/bin/bash

echo "Installing Java 17..."
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-17-amazon-corretto-devel

echo
echo "Installing Minecraft..."
mkdir /home/ec2-user/minecraft
cd /home/ec2-user/minecraft
wget https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar
sudo java -Xmx1024M -Xms1024M -jar server.jar nogui
echo "eula=true" > eula.txt

echo
echo "Creating a systemd service..."
sudo echo "[Unit]
Description=Start the Minecraft server
After=network.target

[Service]
Type=simple
WorkingDirectory=/home/ec2-user/minecraft
ReadWriteDirectory=/home/ec2-user/minecraft
ExecStart=/usr/bin/java -Xmx1024M -Xms1024M -jar server.jar nogui
KillMode=process

[Install]
WantedBy=default.target" > /etc/systemd/system/server-start.service
sudo chmod 640 /etc/systemd/system/server-start.service
sudo systemctl daemon-reload
sudo systemctl enable server-start

echo
echo "Starting Minecraft server..."
sudo systemctl start server-start
