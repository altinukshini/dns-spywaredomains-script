# DNS spywaredomains zones script

Very simple shell script to automate the process of updating spywaredomain zones file from http://dns-bh.sagadc.org and reload named


**Scripts have been tested only on RHE 7**


## Requirements

Install **unzip** and **wget**


## Use

**Master dns**

```
$ ./update-zones.sh master
```

**Slave dns**

```
$ ./update-zones.sh slave 8.8.8.8
```
