---
title: "Cómo configurar claves SSH en Ubuntu."
date: 2025-06-07T10:30:00-06:00
draft: false
tags: ["SSH", "Ubuntu", "Key"]
image: /images/88df4720bbf7e855c081b8d23fda37897fe1836efef71c1fd2b15b6b0820eb35119d74f3026d2a4df073b83cdcf272dc0291cc6c51bcdbfa1fb2a2dfe36c55ad.png
categories:
    - SSH
    - Ubuntu
    - Key
---

En este blog se va a configurar las claves ssh en ubuntu para tener acceso, para este tutorial se va a usar WLS pero se puede hacer desde la consola de windows.

Lo primero es generar la clave en el cliente 


```bash

ssh-keygen -t rsa -b 4096

```
![Name](/images/4453e150749562141c9ef23723bfb2bfa8d74b6cec46ebe3321a8c65f80897adc5a8a65f8f9dbaf20fa82cb189f0d28e22bb94b6b74863935f02303d8b4729dd.png)

una vez realizado nos va a dejar dos archivos 

![Name](/images/9047ace5e67eba2bb94d5868f11716c691e45154a412868904c14052224c79d0e3d06ddf7ee8d9802652f37eff869f5662d70ce0364f4c335b964511871644c8.png)

en este caso se va a realizar de manera manual al servidor 

para esto nos vamos a  la carpeta .ssh 

![Name](/images/736b449fbcaf98bb21935f0a2e4f3749ead672c868921dbf83ccea7561a8ed27f35c2efcd43d63af9b91e81299be4645a57b312eb76b6260c21e61d7d9ed63f1.png)

en el archivo authorized_keys agregamos ssh-rsa

`
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNz261zvu3Ig32cKrdloBMF96gYVHRqVeot4TBWx/lG61V....." >> ~/.ssh/authorized_keys
`

si nos solicita la contraseña al entrar se puede usar ssh agent 

`
 ssh-add
`

![Name](/images/88df4720bbf7e855c081b8d23fda37897fe1836efef71c1fd2b15b6b0820eb35119d74f3026d2a4df073b83cdcf272dc0291cc6c51bcdbfa1fb2a2dfe36c55ad.png)

Esto nos evitará insertar la contraseña al iniciar 