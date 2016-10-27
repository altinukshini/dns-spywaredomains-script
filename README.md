# DNS spywaredomains zones script

Very simple bash script to automate the process of updating spywaredomain zones in bind server and then reload the server. 

I'm using http://www.malwaredomains.com for the list of domains, more specifically the following zip file http://dns-bh.sagadc.org/spywaredomains.zones.zip


**Script has been tested only with bind v9.9.4 on RHEL 7**

## Requirements

Install **unzip** and **wget**

```$ yum install -y unzip wget```

## Configuration

1) Add ```include "/etc/named/spywaredomains.zones";``` in the ```/etc/named.conf``` file.

2) Runs script (see Use section below), or add it in a cron job to run weekly

## Use

**Master dns**

```
$ ./update-zones.sh master
```

**Slave dns**

```
$ ./update-zones.sh slave 8.8.8.8
```
