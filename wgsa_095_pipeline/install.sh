#!/bin/bash 

set -e

#sudo apt-get install perl-JSON
#sudo apt-get install perl-Archive-Zip
#sudo apt-get install perl-DBD-mysql
#sudo apt-get install make
#sudo apt-get install gcc
#sudo apt-get install zlib-devel
#sudo apt-get install libbz2-devel
#sudo apt-get install xz-devel

sudo yum install bzip2-devel
sudo yum install zlib-devel
sudo yum install perl-JSON
sudo yum install xz-devel
sudo yum perl-Archive-Zip
sudo yum perl-DBD-mysql

sudo apt-get install libbz2-dev
sudo apt-get install libclang-dev
sudo apt-get install liblzma-dev
sudo apt-get install libmysqlclient-dev
sudo apt-get install libapache-dbi-perl