---
title: "Cómo instalar un servidor OpenVPN y evadir los firewalls (DPI)"
date: 2025-06-07T10:30:00-06:00
draft: false
tags: ["hugo", "images", "markdown"]
---

Se mostrará como instalar OpenVPN y como evadir los Firewall que suelen usar Deep Packet Inspection para identificar el tipo de protocolo que son los paquetes, muchos de estos suelen bloquear las conexiones VPN, el funcionamiento se basa en identificar el handshake de OpenVPN entonces si logramos ofuscar el handshake podemos saltarnos esa restricción, por suerte se implemento tls-crypt-v2 lo que reduce significativamente la dificultad.

## Instalacion
Lo primero es instalar openvpn y easy-rsa
```
sudo apt install openvpn easy-rsa

```

Lo primero configuramos easyrsa 

```
cp -r /usr/share/easy-rsa /etc/
cd /etc/easy-rsa/
./easyrsa init-pki

```


Generamos el certificado y la clave de la autoridad de certificación 

```
cd /etc/easy-rsa/

./easyrsa build-ca nopass

./easyrsa gen-dh

./easyrsa build-server-full server nopass

openvpn --genkey secret /etc/easy-rsa/pki/ta.key

./easyrsa gen-crl

cp -rp /etc/easy-rsa/pki/{ca.crt,dh.pem,ta.key,crl.pem,issued,private} 

/etc/openvpn/server/

```

## Creacion del handshake encryption  [tls-crypt-v2]
```
Entonces nos ubicamos en
cd /etc/openvpn/server
Para generar el cifrado o el cifrado de handsacke  para el lado del server es 
openvpn --genkey tls-crypt-v2-server handshake_encryption_server.key

Para el lado del cliente es 
openvpn --tls-crypt-v2 handshake_encryption_server.key --genkey tls-crypt-v2-client handshake_encryption_client.key
```

## Creacion de los cientes para openvpn

para este caso nos debemos ubicar en la carpeta que copiamos de easyrsa

```
cd /etc/easy-rsa
./easyrsa build-client-full User1 nopass
./easyrsa build-client-full User2 nopass
```

Ahora vamos a copiar a los usuarios a la carpeta de openvpn, cada uno en su respectiva carpeta

```
mkdir /etc/openvpn/client/{User1,User2}

cp -rp /etc/easy-rsa/pki/{ca.crt,issued/User1.crt,private/User1.key} /etc/openvpn/client/User1

cp -rp /etc/easy-rsa/pki/{ca.crt,issued/User2.crt,private/User2.key} /etc/openvpn/client/User2


```


## Editar la configuracion 


En este caso es mas facil usar la plantilla de configuracion de OpenVPN

```
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server/
cd /etc/openvpn/server/
```

Ubicamos los siguientes parámetros y los modificamos un ejemplo:

```
ca ca.crt
cert issued/server.crt
key private/server.key  # This file should be kept secret
dh dh.pem
tls-crypt-v2 handshake_encryption_server.key
push "dhcp-option DNS 1.1.1.1"
tls-auth ta.key 0

log-append  /var/log/openvpn/openvpn.log
server-ipv6 fd93:b56d:6365::/64
push "dhcp-option DNS6 2606:4700:4700::1111"
push "dhcp-option DNS6 2606:4700:4700::1001"
push "redirect-gateway ipv6 def1 bypass-dhcp"
push "route-ipv6 fd93:b56d:6365::/64"
```




Ejecutamos este comando para hablilitar el server y verificamos que este funcionando
```
sudo systemctl start openvpn-server@server.service

root@i:/etc/openvpn/server# sudo service openvpn-server@server status
● openvpn-server@server.service - OpenVPN service for server
     Loaded: loaded (/usr/lib/systemd/system/openvpn-server@.service; disabled; preset: enabled)
     Active: active (running) since Wed 2024-10-23 00:55:49 UTC; 4min 39s ago
       Docs: man:openvpn(8)
             https://openvpn.net/community-resources/reference-manual-for-openvpn-2-6/
             https://community.openvpn.net/openvpn/wiki/HOWTO
   Main PID: 20333 (openvpn)
     Status: "Initialization Sequence Completed"
      Tasks: 1 (limit: 482)
     Memory: 1.4M (peak: 1.7M)
        CPU: 32ms
     CGroup: /system.slice/system-openvpn\x2dserver.slice/openvpn-server@server.service
             └─20333 /usr/sbin/openvpn --status /run/openvpn-server/status-server.log --status-version 2 --suppress-timestamps --config server.conf

Oct 23 00:55:48 Server systemd[1]: Starting openvpn-server@server.service - OpenVPN service for server...
Oct 23 00:55:49 Server systemd[1]: Started openvpn-server@server.service - OpenVPN service for server.


```



## Crear el ovpn

Los archivospara crear el  .ovpn estan en /etc/openvpn/client/User1

```
root@Server:/etc/openvpn/client/User1# ls
User1.crt  User1.key  ca.crt
```

lo mismo con tls-crypt-v2 es el archivo que creamos como handshake_encryption_client.key

```
 cat handshake_encryption_client.key
-----BEGIN OpenVPN tls-crypt-v2 client key-----
pKYdZklpqoO/XhsJnzn/RX7zTPsqLxgL+0PG3tuzqwyX27IscNXeViVwCwWAYwHU
IdvcrL6AgxgA22QQ.............
-----END OpenVPN tls-crypt-v2 client key-----
```
#### Creación del .ovpn
para crear el archivo de ovpn se debe usar el siguiente formato y solo modificar los campos de las claves, certificados y remote.
 
```
client
dev tun
proto udp
remote address port
resolv-retry infinite
nobind
persist-key
persist-tun
verb 4
data-ciphers-fallback AES-128-CBC
data-ciphers AES-256-CBC:AES-256-CFB:AES-256-CFB1:AES-256-CFB8:AES-256-OFB:AES-256-GCM
tls-cipher "DEFAULT:@SECLEVEL=0"
auth SHA256
key-direction 1
<ca>
-----BEGIN CERTIFICATE-----
MIIDSzCCAjOgAwIBAgIUAbBDafoK+M02UQCliU5DLxMZ2hQwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAwwLRWFzeS1SU0EgQ0EwHhcNMjQxMDIzMDAxODI1WhcNMz....
-----END CERTIFICATE-----
</ca>
<cert>
Certificate:
    Data:......
-----BEGIN CERTIFICATE-----
MIIDUzCCAjugAwIBAgIQKEeHa0xsNPRzkQFHiHubCTANBgkqhkiG9w0BAQsFADAW.........
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDe8LAxZblRxaDj
8NEaq0Mq4.......
-----END PRIVATE KEY-----
</key>
<tls-crypt-v2>
-----BEGIN OpenVPN tls-crypt-v2 client key-----
pKYdZklpqoO/XhsJnzn/RX7zTPsqLxgL+0PG3tuzqwyX27IscNXeViVwCwWAYwHU.
Idvc.................
-----END OpenVPN tls-crypt-v2 client key-----
</tls-crypt-v2>

```




```
sysctl net.ipv4.ip_forward=1
iptables -t nat -I POSTROUTING  -o ens5 -j MASQUERADE
```
## Deteccion por Deep Packet Inspection  (DPI)

Los firewall usan Deep Packet Inspection para reconocer ciertos protocolos 


![Name](/images/e3938bc2bb3eae0744a63c2b4563ee8362cdda7453ab06b4adb34b890796d6fdcbb31ad740c4acde96dc746179c5eeb695acb3b459c4e633d3d24ac5e6444d90.png)

Desde ver el SNI en el Hello Client, identificar P2P, SSH, QUIC, etc. 


En este caso se detectó la conexión de openvpn y esto se debe a que el handshake tiene patrones muy reconocibles.

![Name](/images/8e739d64413c7701beb26d276162ace7bb861ea1bc39eb7f22699e8d8b8270631c537c27f1d86e04b70fedbb7af084254a0a3a9c30a09f0da59d550c0e453b79.png)



---

Lo primero que tenemos que hacer es cambiar el puerto porque el puerto default es de openvpn.

![Name](/images/cf7fb424a3f3c78234f4af9bb1db37233d9da8724da4209b1e880faf1eae8285b3040d524144153e0e86cf99238cc24deb956a03c4a5a06a84dbbc756308dfc0.png)


en la configuración usamos tls-crypt-v2 que nos permite ofuscar el handshake de openvpn. 

podemos ver la documentacion de  tls-crypt-v2

[https://github.com/OpenVPN/openvpn/blob/master/doc/tls-crypt-v2.txt](https://github.com/OpenVPN/openvpn/blob/master/doc/tls-crypt-v2.txt
)


---

*ls-crypt-v2 uses an encrypted cookie mechanism to introduce client-specific tls-crypt keys without introducing a lot of server-side state. The client-specific key is encrypted using a server key.  The server key is the same for all servers in a group.  When a client connects, it first sends the encrypted key to the server, such that the server can decrypt the key and all messages can thereafter be encrypted using the client-specific key.*

*A wrapped (encrypted and authenticated) client-specific key can also contain metadata.  The metadata is wrapped together with the key, and can be used to allow servers to identify clients and/or key validity.  This allows the server to abort the connection immediately after receiving the first packet, rather than performing an entire TLS handshake.  Aborting the connection this early greatly improves the DoS resilience and reduces attack surface against malicious clients that have the tls-crypt or tls-auth key.  This is particularly relevant for large deployments (think lost key or disgruntled employee) and VPN providers (clients are not trusted).*



---


Una vez que usamos  tls-crypt-v2 ya no es detecatdo por el Deep Packet Inspection 
![Name](/images/6a447095ab96f0e0c7ba6014a0f72ccdc12871632c5f09e0ad9d6c2fadf647f5f7f56183a3f0ce5fcf96085e6177f072f9d73787e24e1219882383df5d4f4838.png)


![Name](/images/cd742e78ab8f75f43e5cc75f28c473ae00eaeb5c5659b83de68f1f6b7ac9573068f5681d2863ef67c0ddc4657703b1635d3aba24b7c6937bd9ce2e7434d2c61c.png)



![Name](/images/7cd41183b6f6c952ad63be22d0d948c53fdf0a4daa4b5857c1822f669cbbe3a3f129fd03b000a3fc5e0efd203c53b19da3d9a0a9162aad00846fa0f7340cb5f4.png)




