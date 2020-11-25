sudo useradd --shell /bin/false --home-dir /opt/minecraft minecraft

sudo yum -y install wget java screen
sudo wget -qO /opt/minecraft/server.jar https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar # 1.16.4

sudo chown -R minecraft.minecraft /opt/minecraft
