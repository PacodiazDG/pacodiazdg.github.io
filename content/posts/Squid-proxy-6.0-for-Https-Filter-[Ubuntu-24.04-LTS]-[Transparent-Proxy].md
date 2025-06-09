---
title: "Squid proxy 6.0 for Https Filter [Ubuntu 24.04 LTS] [Transparent Proxy]  "
date: 2025-06-07T10:30:00-06:00
draft: false
tags: ["Squid-Proxy","SNI","TLS","Web-Filter","SSL-Inspection"]
---

Squid Proxy is a great tool that allows us to do multiple things; one of them is to function as a forward proxy, and with the use of ACLs, we can filter sites using the SNI.


-----------

## installation
Squid proxy is installed via apt-get. The squid-openssl version is of interest to us since it contains ssl-bump. If our distribution does not include squid-openssl, it must be installed manually.

```bash
sudo apt-get install squid-openssl
```

![Name](/images/9034cefa695d9cf73265449df6f2ba05025a2268660c542a44fb1107d1ef4b2610cde1591a62ded00bde3f9d8d2aa3d307087828e21ae3a8b9cfe05567708983.png)

We generate the SSL certificates, remember they must be in /etc/squid/ssl; otherwise, Squid will not trust the certificate.

```bash
cd /etc/ssl/
sudo openssl ecparam -name prime256v1 -genkey -noout -out sslsquid.key
sudo  openssl req -x509 -days 365 -nodes -key sslsquid.key -out sslsquid.crt
```

For Squid Proxy 6.0, it gives the following error if it’s not installed in /etc/ssl/.
```bash 
× squid.service - Squid Web Proxy Server
     Loaded: loaded (/usr/lib/systemd/system/squid.service; enabled; preset: enabled)
     Active: failed (Result: exit-code) since Fri 2024-06-07 05:48:16 CST; 4s ago
   Duration: 25min 6.288s
       Docs: man:squid(8)
    Process: 4522 ExecStartPre=/usr/sbin/squid --foreground -z (code=exited, status=1/FAILURE)
        CPU: 54ms

Jun 07 05:48:16 toor-VMware-Virtual-Platform squid[4522]: 2024/06/07 05:48:16|   Finished.  Wrote 0 entries.
Jun 07 05:48:16 toor-VMware-Virtual-Platform squid[4522]: 2024/06/07 05:48:16|   Took 0.00 seconds (  0.00 entries/sec).
Jun 07 05:48:16 toor-VMware-Virtual-Platform squid[4522]: 2024/06/07 05:48:16| FATAL: No valid signing certificate configured for HTTPS_port [::]:3135
Jun 07 05:48:16 toor-VMware-Virtual-Platform squid[4522]: 2024/06/07 05:48:16| Squid Cache (Version 6.6): Terminated abnormally.
Jun 07 05:48:16 toor-VMware-Virtual-Platform squid[4522]: CPU Usage: 0.060 seconds = 0.047 user + 0.013 sys
Jun 07 05:48:16 toor-VMware-Virtual-Platform squid[4522]: Maximum Resident Size: 74752 KB
Jun 07 05:48:16 toor-VMware-Virtual-Platform squid[4522]: Page faults with physical i/o: 0
Jun 07 05:48:16 toor-VMware-Virtual-Platform systemd[1]: squid.service: Control process exited, code=exited, status=1/FAILURE
Jun 07 05:48:16 toor-VMware-Virtual-Platform systemd[1]: squid.service: Failed with result 'exit-code'.
Jun 07 05:48:16 toor-VMware-Virtual-Platform systemd[1]: Failed to start squid.service - Squid Web Proxy Server.
```


To configure Squid, we do the following:
```bash
 cd /etc/squid/
 sudo nano squid.conf
```

To configure Squid, we do the following:
```bash
http_port 3131 intercept
https_port 3135 intercept ssl-bump tls-cert=/etc/ssl/sslsquid.crt tls-key=/etc/ssl/sslsquid.key generate-host-certificates=on dynamic_cert_mem_cache_size=16MB
http_access allow localnet
```

![Name](/images/3929c81e35a5719f6884afb94c6b337e6e0ef3f7aeed5fb0221f7343a9518fd80bb5963bf063c1dc565766d63f487d5f496373386e72b2022804c916385328bf.png)

Uncomment the following line.
```bash
#Default:
 sslcrtd_program /usr/lib/squid/security_file_certgen -s /var/spool/squid/ssl_db -M 4MB
```

![Name](/images/b69d71a0d29f37d5f070dcb09c0093615969d27c1aa02be7abe62e7ff5cb774efb1ff8e50975ffd64ef13f2d8bf8acf9c0f2ff34e40416805def1bcc3e39573f.png)

We have to configure iptables so that the traffic goes through squid proxy

```bash
sudo iptables -t nat -I PREROUTING  -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 3135
sudo iptables -t nat -I PREROUTING  -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 3131 
sudo iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
sudo sysctl -w net.ipv4.ip_forward=1
```

## Access Controls 

We create a file where the domains to be blocked will be
```bash
 sudo mkdir /blockwebsites
cd /blockwebsites
sudo nano list1
```

We add example.com as an example.

`example.com`

## Block web site via SNI (Server Name Indication)


```bash
sudo nano /etc/squid/squid.conf
```

We add the following at the end of the configuration.

```
acl monitoredSites ssl::server_name "/blockwebsites/list1"
ssl_bump terminate monitoredSites
ssl_bump peek all
ssl_bump splice all
```

In this case we do not want to interfere with the original certificate we use
ssl_bump peek all
ssl_bump splice all

[https://wiki.squid-cache.org/Features/SslPeekAndSplice](https://wiki.squid-cache.org/Features/SslPeekAndSplice)


![Name](/images/8eae27349b3b1381cd930ef923d1d0cea41e9adfd9d4338ace34a7621045d44926cadff03f5a9dfe7edc0143a14f362eb646ba7c50183987d09e8110ab6770ae.png)

![Name](/images/d7f81f61121521e249fb31d971fe372b7f84421cdb298263324d49d21ab00a9d32e14769101222af4cca06a21b134474a1c9155df279f85da6aab82a2b498b91.png)

The website is working without installing any certificate on the client



![Name](/images/edf1786ab6b3bb51266cf81f277a1e68f584652482d2f83d745e3735ce984744343a21f0516d1081e80c263bac1d44fcb491452a3dd89a1e392607a741022d31.png)



-----------

# Block QUIC using the firewall policy.

Squid Proxy does not support QUIC, so we have to disable it.

```
sudo iptables -I FORWARD -p udp --dport 443 -j REJECT --reject-with icmp-port-unreachable
```

