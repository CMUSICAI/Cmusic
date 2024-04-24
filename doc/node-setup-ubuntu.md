Setting Up a Cmusic Node on Ubuntu Server
====================

This guide will help you set up a Cmusic node on a VPS running Ubuntu 20.04. The Cmusic node allows you to run a full node on the Cmusic network, which helps secure the network and provides you with a wallet to send and receive Cmusic coins.

### Prerequisites

- A VPS running Ubuntu 20.04+
- SSH access to the server
- At least 2GB of RAM
- At least 50GB of disk space
- A static IP address
- A basic understanding of the Linux command line

### Step 1: Update the System and Install Dependencies

Connect to your server via SSH and update the system packages.

```bash
sudo apt update
sudo apt upgrade
```

Install the required dependencies for running the Cmusic node.

```bash
sudo apt-get install build-essential libssl-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev libboost-test-dev qtbase5-dev qttools5-dev libdb++-dev libminiupnpc-dev libqrencode-dev libevent-dev libprotobuf-dev protobuf-compiler libzmq3-dev libgmp-dev bison libexpat1-dev libdbus-1-dev libfontconfig-dev libfreetype6-dev libice-dev libsm-dev libx11-dev libxau-dev libxext-dev libxcb1-dev libxkbcommon-dev xcb-proto x11proto-xext-dev x11proto-dev xtrans-dev zlib1g-dev autoconf automake libtool
```

### Step 2: Create new directory

Create a new directory for the Cmusic node.

```bash
mkdir ~/cmusic
cd ~/cmusic
```

### Step 3: Download the Cmusic Core Software

Download the latest version of the Cmusic Core software from the official website.

```bash
wget https://github.com/CMUSICAI/Cmusic/releases/download/wallet/CmusicAI-x86_64-linux-gnu.tar.gz
```

### Step 4: Extract the Archive

Extract the downloaded archive to a directory of your choice.

```bash
tar -xvf CmusicAI-x86_64-linux-gnu.tar.gz
```

### Step 5: Remove the Archive

Remove the downloaded archive to save disk space.

```bash
rm CmusicAI-x86_64-linux-gnu.tar.gz
```

### Step 6: Configure the Cmusic Node

Create a configuration file for the Cmusic node.

```bash
mkdir ~/.cmusicai
touch ~/.cmusicai/cmusicai.conf
```

Edit the configuration file with your preferred text editor.

```bash
nano ~/.cmusicai/cmusicai.conf
```

Add the following lines to the configuration

```bash
listen=1
daemon=1
server=1
txindex=1
addressindex=1
assetindex=1
timestampindex=1
spentindex=1
rpcuser=username_here
rpcpassword=password_here
rpcport=9819
port=9328
uacomment=Seed_Node_title_and_its_number_here
maxconnections=861 
```

Replace `username_here` and `password_here` with your preferred RPC username and password.  

Replace `Seed_Node_title_and_its_number_here` with the title of your seed node and its number.  Example: `Seed_Node_1`.

Save and exit the text editor.

### Step 7: Start the Cmusic Node

Start the Cmusic node by running the following command.

```bash
./cmusicaid
```

### Step 8: Verify the Node

Check the status of the Cmusic node by running the following command.

```bash
./cmusicai-cli getinfo
```

You should see information about the node, such as the version, blocks, and connections.

### Step 9: Configure the Firewall

If you have a firewall enabled on your server, make sure to allow traffic on the Cmusic port (default is 9819).

```bash
sudo ufw allow 9819/tcp
```

### Step 10: Set Up Auto-Start (Optional)

To start the Cmusic node automatically on system boot, create a systemd service file.

```bash
sudo nano /etc/systemd/system/cmusicaid.service
```

Add the following lines to the service file.

```bash
[Unit]
Description=Cmusic Node
After=network.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/path/to/cmusicaid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Save and exit the text editor.

### Step 11: Enable and Start the Service

Enable the Cmusic service to start on boot.

```bash
sudo systemctl enable cmusicaid
```

Start the Cmusic service.

```bash
sudo systemctl start cmusicaid
```

### Step 12: Monitor the Node

Check the status of the Cmusic service.

```bash
sudo systemctl status cmusicaid
```

You should see that the service is active and running.

Congratulations! You have successfully set up a Cmusic node on your Ubuntu server.