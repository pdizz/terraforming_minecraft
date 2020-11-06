# sudo yum update
sudo yum install java -y

# create minecraft user with no login
sudo useradd --shell /bin/false --home-dir /opt/minecraft minecraft

sudo yum -y install wget
sudo wget -qO /opt/minecraft/server.jar https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar # 1.16.4

# create minecraft server daemon and enable it
sudo cat <<EOF > /usr/lib/systemd/system/minecraft.service
# /usr/lib/systemd/system/minecraftd.service
[Unit]
Description=The Minecraft Server
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/java -Xms2048M -Xmx2048M -XX:+UseG1GC -jar server.jar nogui
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo chown -R minecraft.minecraft /opt/minecraft
