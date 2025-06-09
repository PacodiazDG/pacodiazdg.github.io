---
title: "contador ascendente y descendente  con Display de 7 Segmentos para PIC18F4550 en Ensamblador"
date: 2025-06-07T10:30:00-06:00
draft: false
tags: ["assembly","PIC18F4550"]
---


En este proyecto se va a desarrollar un contador ascendente y descendente utilizando el microcontrolador PIC18F4550 en ensamblador. usando un Display de 7 Segmentos para mostrar los valores del contador en orden ascendente y descendente.

algunos de los pasos se expican en el contador automatico que se encuentra en 

[https://devnotescode.com/Pages?id=677437501f54d06c6ecb8012](https://devnotescode.com/Pages?id=677437501f54d06c6ecb8012)

```nasm


LIST    P = 18F4550
INCLUDE <P18F4550.INC>
;contador de cambio automatico 
;************************************************************
CONFIG  FOSC = HS   
CONFIG  PWRT = ON
CONFIG  BOR = OFF
CONFIG  WDT = OFF
CONFIG  MCLRE = ON
CONFIG  PBADEN = OFF
CONFIG  LVP = OFF
CONFIG  DEBUG = OFF
CONFIG  XINST = OFF
; CODE ******************************************************
    
  
ORG 0x00    ;Iniciar el programa en el registro 0x00
    movlw   0xFF                ; 
    movwf  TRISC
    movlw   0x00        ; 
    movwf  TRISB
; variables
    Counter1  equ 0x20 
    Counter2  equ 0x21 ; 
    
    sa  equ 0x22        
    movlw   0x00        
    movwf   sa          
main:
    ;--------------------------------------------------------------------
    call revisarintoverflow
    call revisiondecondicion
    ;--------------------------------------------------------------------

    ;incf    sa, f   aumenta
    ;decf    sa, f   decrementa 
    call controldebotones
    call DelayLoop2 ;
    goto main
    return
uno:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 1     
    bcf     LATB, 2     
    return

dos:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 1     
    bcf     LATB, 6     
    bcf     LATB, 4     
    bcf     LATB, 3     
    return
    
    
tres:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 1     
    bcf     LATB, 6     
    bcf     LATB, 2     
    bcf     LATB, 3     
    return

cuatro:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 5    
    bcf     LATB, 6     
    bcf     LATB, 1     
    bcf     LATB, 2     
    return
cinco:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 5     
    bcf     LATB, 6     
    bcf     LATB, 2     
    bcf     LATB, 7     
    bcf     LATB, 3     
    return
seis:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 5     
    bcf     LATB, 6     
    bcf     LATB, 2     
    bcf     LATB, 7     
    bcf     LATB, 4     
    bcf     LATB, 3     
    return
siete:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 1     
    bcf     LATB, 2     
    return
ocho:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 1     
    bcf     LATB, 2     
    bcf     LATB, 3     
    bcf     LATB, 4     
    bcf     LATB, 5     
    bcf     LATB, 6     
    return
nueve:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 1     
    bcf     LATB, 5     
    bcf     LATB, 6     
    bcf     LATB, 2     
    return
cero:
    movlw   0xFF        ; Establece todos los pines del puerto B en alto
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 1     
    bcf     LATB, 2     
    bcf     LATB, 3     
    bcf     LATB, 4     
    bcf     LATB, 5     
    return
a:
    movlw   0xFF        
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 1     
    bcf     LATB, 2     
    bcf     LATB, 3     
    bcf     LATB, 4     
    bcf     LATB, 6     
    return
b:
    movlw   0xFF        
    movwf  LATB
    bcf     LATB, 2     
    bcf     LATB, 3     
    bcf     LATB, 4     
    bcf     LATB, 5     
    bcf     LATB, 6     
    return
c:
    movlw   0xFF        
    movwf  LATB
    bcf     LATB, 3     
    bcf     LATB, 4     
    bcf     LATB, 6     
    return
d:
    movlw   0xFF        
    movwf  LATB
    bcf     LATB, 1     
    bcf     LATB, 2     
    bcf     LATB, 3     
    bcf     LATB, 4     
    bcf     LATB, 6     
    return
e:
    movlw   0xFF        
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 3     
    bcf     LATB, 4     
    bcf     LATB, 5     
    bcf     LATB, 6     
    return
f:
    movlw   0xFF        
    movwf  LATB
    bcf     LATB, 0    
    bcf     LATB, 5     
    bcf     LATB, 6     
    bcf     LATB, 4     
    return
 ;--------------------------------- Genera un sleep aprox 2 segundos
 Delay2s:
    movlw   D'50'       
    movwf   Counter1    
DelayLoop1:
    movlw   D'200'      
    movwf   Counter2    
DelayLoop2:
    nop                
    nop                            
    decfsz  Counter2, f 
    goto    DelayLoop2  
    decfsz  Counter1, f 
    goto    DelayLoop1  
    return              
;-----------------------------------------------------------
revisiondecondicion:
    call esun1
    call esun2
    call esun3
    call esun4
    call esun5
    call esun6
    call esun7
    call esun8
    call esun9
    call esun0
    call esunA
    call esunB
    call esunC
    call esunE
    call esunF
    return
    
esun1:
    nop
    MOVLW 1
    SUBWF sa, W
    BTFSS STATUS, Z
    return ;// esto es !=
    CALL uno
    return
esun2:
    nop
    MOVLW 2
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL dos
    return
esun3:
    nop
    MOVLW 3
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL tres
    return
esun4:
    nop
    MOVLW 4
    SUBWF sa, W
    BTFSS STATUS, Z
    return 
    CALL cuatro
    return
esun5:
    nop
    MOVLW 5
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL cinco
    return
esun6:
    nop
    MOVLW 6
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL seis
    return
esun7:
    nop
    MOVLW 7
    SUBWF sa, W
    BTFSS STATUS, Z
    return 
    CALL siete
    return
esun8:
    nop
    MOVLW 8
    SUBWF sa, W
    BTFSS STATUS, Z
   return 
    CALL ocho
    return
esun9:
    nop
    MOVLW 9
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL nueve
    return
esun0:
    nop
    MOVLW 0
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL cero
    return
; terminan las numeros  ---------------------------------------------------
esunA:
    nop
    MOVLW 10
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL a
    return

esunB:
    nop
    MOVLW 11
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL b
    return
esunC:
    nop
    MOVLW 12
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL  c
    return
esunD:
    nop
    MOVLW 13
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL d
    return
esunE:
    nop
    MOVLW 14
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL e
    return
esunF:
    nop
    MOVLW 15
    SUBWF sa, W
    BTFSS STATUS, Z
    return
    CALL f
    return
;********************************************************************************************************
revisarintoverflow:
    nop
    call esmin0 ; no permite que llege a 0
    call esmax15 ; no permite que llege a 15
    return
esmax15:
    nop
    MOVLW 16
    SUBWF sa, W
    BTFSS STATUS, Z
    return ;// esto es igual a !=
    movlw   0x00       ; Cargar el nuevo valor (0x01) en el registro W
    movwf   sa         ; Transferir el valor de W a 'sa'
    return
esmin0:
    movlw   0xFF       
    subwf   sa, W      ; 
    btfss   STATUS, Z  ; esto es igual a != 
    return            ; 
    movlw   15       
    movwf   sa         
    return             
;********************************************************************************************************
    ;incf    sa, f   aumenta
    ;decf    sa, f   decrementa
    acsListener:
    BTFSS PORTC, 0  ; Comprobar si el botón en RC0 está presionado 
    incf    sa, f
    return
    descListener:
    BTFSS PORTC, 1  ; Comprobar si el botón en RC1 está presionado
    decf    sa, f    
    return
    controldebotones:
	call acsListener
	call descListener
	return
;********************************************************************************************************
noop:
    nop
    nop
    nop
    nop
    nop
    return
    END             

```
