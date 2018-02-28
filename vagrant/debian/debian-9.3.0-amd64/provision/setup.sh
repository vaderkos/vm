echo "Configuring sources.list"
cp -f /vagrant/provision/etc/apt/sources.list /etc/apt/sources.list
echo

echo "Executing 'apt update'"
apt update
echo

echo "Installing 'curl'"
apt install curl
echo

echo "Installing 'nodejs'"
curl -sL https://deb.nodesource.com/setup_8.x | bash -
sudo apt-get install -y nodejs
echo

