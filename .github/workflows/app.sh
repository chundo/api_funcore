#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#1 Creo un usuario

adduser deploy --disabled-password --gecos "" &&
adduser deploy sudo &&

#2 Actualizar OS, instalar dependencias y ruby
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - &&
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - &&
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list &&
sudo add-apt-repository ppa:chris-lea/redis-server &&
sudo apt-get install -y nodejs yarn &&
sudo apt-get update &&
sudo apt-get install -y unzip &&
sudo apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev dirmngr gnupg apt-transport-https ca-certificates redis-server redis-tools nodejs yarn &&

#3 Instalar rbenv
rm -rf *.zip &&
rm -rf ~/.rbenv &&
rm -rf rbenv &&

# git clone https://github.com/rbenv/rbenv.git ~/.rbenv &&
wget https://github.com/rbenv/rbenv/archive/refs/heads/master.zip -O rbenv.zip &&
unzip -d rbenv -u -o rbenv.zip &&
mv rbenv/*/* rbenv/ &&
mkdir -p ~/.rbenv &&
mv -n rbenv/* ~/.rbenv &&
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc &&
echo 'eval "$(rbenv init -)"' >> ~/.bashrc &&

# git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build &&
rm *.zip &&
rm -rf ruby-build &&
wget https://github.com/rbenv/ruby-build/archive/refs/heads/master.zip -O ruby-build.zip &&
unzip -d ruby-build -u -o ruby-build.zip &&
mv ruby-build/*/* ruby-build/ &&
mkdir -p ~/.rbenv/plugins &&
mkdir -p ~/.rbenv/plugins/ruby-build &&
mv -n ruby-build/* ~/.rbenv/plugins/ruby-build &&
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc &&

# git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars &&
rm -rf *.zip &&
rm -rf rbenv-vars &&
wget https://github.com/rbenv/rbenv-vars/archive/refs/heads/master.zip -O rbenv-vars.zip &&
unzip -d rbenv-vars -u -o rbenv-vars.zip &&
mv rbenv-vars/*/* rbenv-vars/ &&
mkdir -p ~/.rbenv/plugins/rbenv-vars &&
mv -n rbenv-vars/* ~/.rbenv/plugins/rbenv-vars &&
#exec $SHELL &&
#source ~/.profile &&
sudo apt -y install ruby-full rbenv ruby &&
#sudo rbenv install 3.1.2 &&
#sudo rbenv global 3.1.2 &&
ruby -v &&

#4 Instalar Bundle  y Rails
gem install bundler &&
gem install bundler -v 1.17.3 &&
bundle -v &&


#4 Installing NGINX & Passenger
sudo apt-get install -y dirmngr gnupg &&
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 &&
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 &&
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list' &&
sudo apt-get update &&
sudo apt-get install -y nginx-extras libnginx-mod-http-passenger &&
if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then sudo ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi &&
sudo ls /etc/nginx/conf.d/mod-http-passenger.conf &&
sudo cp files/mod-http-passenger.conf /etc/nginx/conf.d/ &&
sudo service nginx start &&
sudo rm -rf /etc/nginx/sites-enabled/default &&
sudo cp files/myapp /etc/nginx/sites-enabled/ &&
sudo service nginx reload &&
sudo service nginx start
