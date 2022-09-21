#!/bin/bash

for i in {1..22}
do
   curl 'https://bravo.sph.umich.edu/freeze8/hg38/downloads/vcf/'$i -H 'Accept-Encoding: gzip, deflate, br' -H 'Cookie: _ga=GA1.2.225760447.1663191510;_gid=GA1.2.582892527.1663191510;remember_token=tmtrigga@gmail.com|eacec93a3712e983440977d3e390ecee6745c96c7aae16f81c9c259adcc66455bacb53bb4ec5e0e5852e40723c2bc372e84b69d00cd55b8282cbd54086ada178;session=.eJwdj7tOxTAQRP_FdXS1ftupkGhAQjwkCrpovbsJ0cUE7FxRIP6dQDvSnDPzraa5SX9V494uMqhpZTUqQMMgCGItA3FkZ8gReh_dzEfog0sh2QQw55yNKZRLSS5AtgJB5wyGc4pIyBpLMIJ_sIBWe0GOuugIHK3PnqOZyRTtZwfaWk3sD6caVJMqtUibutD2zl2NKTiAEwyq77jLsdK52_D0nA1tsbmHev4I5vPm65ra3f3L-fFgXPrR_z-0172ty4JXS8X17URbVT-_lX5KvA.YyJNLg.ab9YpF8OswXntGhf6zPkMi3nbhc;' --compressed > chr$i.vcf.gz
done

curl 'https://bravo.sph.umich.edu/freeze8/hg38/downloads/vcf/X' -H 'Accept-Encoding: gzip, deflate, br' -H 'Cookie: _ga=GA1.2.225760447.1663191510;_gid=GA1.2.582892527.1663191510;remember_token=tmtrigga@gmail.com|eacec93a3712e983440977d3e390ecee6745c96c7aae16f81c9c259adcc66455bacb53bb4ec5e0e5852e40723c2bc372e84b69d00cd55b8282cbd54086ada178;session=.eJwdj7tOxTAQRP_FdXS1ftupkGhAQjwkCrpovbsJ0cUE7FxRIP6dQDvSnDPzraa5SX9V494uMqhpZTUqQMMgCGItA3FkZ8gReh_dzEfog0sh2QQw55yNKZRLSS5AtgJB5wyGc4pIyBpLMIJ_sIBWe0GOuugIHK3PnqOZyRTtZwfaWk3sD6caVJMqtUibutD2zl2NKTiAEwyq77jLsdK52_D0nA1tsbmHev4I5vPm65ra3f3L-fFgXPrR_z-0172ty4JXS8X17URbVT-_lX5KvA.YyJNLg.ab9YpF8OswXntGhf6zPkMi3nbhc;' --compressed > chrX.vcf.gz
