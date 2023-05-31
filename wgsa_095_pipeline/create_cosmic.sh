#!/bin/bash 


((!$#)) && echo No arguments supplied! && exit 1
wgsa_dir=$1
cosmic_dir=$wgsa_dir/resources/COSMIC

set -e
echo "Enter email and password address registered to COSMIC: "  
read email  
read -s -p psword

#token= echo 'email:psword' | base64

token= echo 'mushayah@usc.edu:6675Tm++' | base64

echo \n $token

curl -H "Authorization: Basic $token" \
  https://cancer.sanger.ac.uk/cosmic/file_download/GRCh38/cosmic/v96/VCF/CosmicCodingMuts.vcf.gz

curl -H "Authorization: Basic bXVzaGF5YWhAdXNjLmVkdTo2Njc1VG0rKwo=" https://cancer.sanger.ac.uk/cosmic/file_download/GRCh38/cosmic/v96/VCF/CosmicCodingMuts.vcf.gz

cd $cosmic_dir

echo "Enter download url "  
read url 

echo "curl -o CosmicCodingMuts.vcf.gz '$url'"

#cd hg19
#curl -o CosmicCodingMuts.vcf.gz '$url'
#sftp> get /cosmic/grch37/cosmic/v82/VCF/CosmicCodingMuts.vcf.gz
#
#cd ./../hg38
#sftp $email@sftp-cancer.sanger.ac.uk
#sftp> get /cosmic/grch38/cosmic/v82/VCF/CosmicCodingMuts.vcf.gz

