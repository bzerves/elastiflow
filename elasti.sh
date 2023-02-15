#!/bin/bash

# Atualiza o sistema e instala as dependências necessárias
echo "Atualizando o sistema e instalando as dependências necessárias..."
apt-get update
apt-get install apt-transport-https default-jre -y

# Tuning do Kernel
echo "Configurando o Kernel..."
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

# Instalação do Elasticsearch
echo "Instalando o Elasticsearch..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update
apt-get install elasticsearch-oss -y

# Configuração do Elasticsearch
echo "Configurando o Elasticsearch..."
sed -i 's/#cluster\.name: my-application/cluster.name: elasticsearch/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#network\.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/-Xms1g/-Xms512m/' /etc/elasticsearch/jvm.options
sed -i 's/-Xmx1g/-Xmx512m/' /etc/elasticsearch/jvm.options
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

# Instalação do Kibana
echo "Instalando o Kibana..."
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update
apt-get install kibana-oss -y

# Configuração do Kibana
echo "Configurando o Kibana..."
sed -i 's/#server\.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
sed -i 's/#elasticsearch\.hosts/elasticsearch.hosts/' /etc/kibana/kibana.yml
sed -i 's/localhost:9200/0.0.0.0:9200/' /etc/kibana/kibana.yml
systemctl enable kibana.service
systemctl start kibana.service

# Instalação do ElastiFlow
echo "Instalando o ElastiFlow..."
apt-get install python3 python3-pip python3-dev python3-setuptools -y
pip3 install -U pip
pip3 install elastiflow

# Download da base MaxMind
echo "Baixando a base de dados MaxMind..."
mkdir -p /etc/elastiflow/maxmind
wget https://git.io/GeoLite2-ASN.mmdb -O /etc/elastiflow/maxmind/GeoLite2-ASN.mmdb
wget https://git.io/GeoLite2-City.mmdb -O /etc/elastiflow/maxmind/GeoLite2-City.mmdb
wget https://git.io/GeoLite2-Country.mmdb -O /etc/elastiflow/maxmind/GeoLite2-Country.mmdb
