#!/bin/bash

# Check if the user wants to quit
read -p "Press q to quit or any other key to continue: " choice
if [[ $choice == "q" ]]; then
    exit 0
fi

# Store the IP address in a variable
read -p "Enter the IP address: " ip
ip_address="$ip"

# Store the port number in a variable
read -p "Enter the port number: " port
port_number="$port"

##############################################
#        Download Nginx Source Code          #
##############################################

# Download Nginx 1.21.3
wget https://nginx.org/download/nginx-1.21.3.tar.gz

# Extract the Nginx 1.21.3 tar file
tar -xzvf nginx-1.21.3.tar.gz

#################################################
# Compile Nginx source code with the ajp module #
#################################################

# Clone the Nginx ajp module repo
git clone https://github.com/dvershinin/nginx_ajp_module.git

# Change the directory to the Nginx source code
cd nginx-1.21.3

# Install the build dependencies
sudo apt install libpcre3-dev

# Configure the Nginx source code with the ajp module
./configure --add-module=`pwd`/../nginx_ajp_module --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules

# Compile the Nginx source code with the ajp module
make

# Install the Nginx source code with the ajp module
sudo make install

# Point to the AJP Port in Nginx config
echo "Comment out the entire server block and append the following lines inside the http block in the /etc/nginx/conf/nginx.conf file then start Nginx:

upstream tomcats {
	server $ip_address:$port_number;
	keepalive 10;
	}
server {
	listen 80;
	location / {
		ajp_keep_conn on;
		ajp_pass tomcats;
	}
}"

echo "\nDon't forget to curl http://$ip_address:$port_number to test the connection\n"
