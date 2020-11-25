sudo useradd --shell /bin/false --home-dir /opt/minecraft minecraft

sudo yum -y install wget java screen
sudo wget -qO /opt/minecraft/server.jar https://launcher.mojang.com/v1/objects/f02f4473dbf152c23d7d484952121db0b36698cb/server.jar # 1.16.3

sudo chown -R minecraft.minecraft /opt/minecraft
