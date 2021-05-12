# Firmando zonas con DNSSEC



## Intro

Vamos a crear la zona autoritativa grp2.lacnic35.te-labs.training y luego la firmaremos con DNSSEC. Trataremos también de formar una cadena de confianza completa.



## Que es lo que ya sabemos

Nuestro "padre" ya ha creado lo siguiente en su propia zona:

```shell
; grp2
grp2             NS           ns1.grp2.lacnic35.te-labs.training.
grp2             NS           ns2.grp2.lacnic35.te-labs.training.
; ---Placeholder for grp2 DS record (DO NOT MANUALLY EDIT THIS LINE)---
ns1.grp2         A           100.100.2.130
ns1.grp2         AAAA        fd89:59e0:2:128::130
ns2.grp2         A           100.100.2.131
ns2.grp2         AAAA        fd89:59e0:2:128::131

```

Nuestra zona debe ser compatible con esto.

## Configurando la zona autoritativa

utilizamos el contenedor "SOA" (autoritativo oculto)

vamos al directorio /etc/bind y clonamos el archivo db.empty

```cp db.empty db.grp2```

El contenido de la zona deberá ser al menos:

```
; grp2 

$TTL    30
@       IN      SOA     grp2.lacnic35.te-labs.training. root.example.com (                                            
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;

; grp2 
grp2             NS           ns1.grp2.lacnic35.te-labs.training.
grp2             NS           ns2.grp2.lacnic35.te-labs.training.

ns1.grp2         A           100.100.2.130
ns1.grp2         AAAA        fd89:59e0:2:128::130
ns2.grp2         A           100.100.2.131
ns2.grp2         AAAA        fd89:59e0:2:128::131

;; SE PUEDEN AGREGAR MAS REGISTROS A GUSTO
```



En el archivo de configuracion /etc/bind/named.conf.local colocamos el enunciado "zone":

```
zone "grp2.lacnic35.te-labs.training" {                                                                               
        type master;                                                                                                  
        file "/etc/bind/db.grp2";                                                                                     
        allow-transfer { any; };                                                                                      
}; 
```

Reiniciamos el servidor y verificamos:

```
rndc reload


root@soa:/etc/bind# dig @localhost soa grp2.lacnic35.te-labs.training.                                                

; <<>> DiG 9.16.1-Ubuntu <<>> @localhost soa grp2.lacnic35.te-labs.training.
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64339
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 270e2c46ed443c1c01000000609c59f04ba85015ff71998d (good)
;; QUESTION SECTION:
;grp2.lacnic35.te-labs.training.        IN      SOA

;; ANSWER SECTION:
grp2.lacnic35.te-labs.training. 30 IN   SOA     grp2.lacnic35.te-labs.training. root.example.com.grp2.lacnic35.te-labs
.training. 1 604800 86400 2419200 86400

;; Query time: 0 msec
;; SERVER: ::1#53(::1)
;; WHEN: Wed May 12 22:42:56 UTC 2021
;; MSG SIZE  rcvd: 170

```

## Configuramos los autoritativos esclavos

Estos servidores son los que exponen nuestra zona públicamente

Ellos son ns1 y ns2



## Firmamos la zona

Para firmar la zona primero precisamos dos pares de claves, una ZSK y una KSK. Se puede firmar con un único par de claves pero no es una configuración recomendada.


```
#Create directory to hold DNSSEC keys

mkdir -p /etc/bind/keys

cd /etc/bind/keys

# Generate ZSK

dnssec-keygen -a RSASHA256 -3 -b 1024 -n ZONE grp2.lacnic35.te-labs.training

# Generate KSK

dnssec-keygen -f KSK -a RSASHA256 -b 2048 -3 -n ZONE grp2.lacnic35.te-labs.training

chown -R bind:bind /etc/bind/keys
```

Luego firmamos la zona:

```
dnssec-signzone -S -P -K keys -o grp2.lacnic35.te-labs.training db.grp2 
```

Finalmente sustituimos en named.conf.local el archivo db.grp2 por el db.grp2.signed y reiniciamos el servidor con ```rndc reload```

Verificamos:

```
root@soa:/etc/bind# dig @localhost soa grp2.lacnic35.te-labs.training. +dnssec                                                            
                                                                                                                                          
; <<>> DiG 9.16.1-Ubuntu <<>> @localhost soa grp2.lacnic35.te-labs.training. +dnssec                                                      
; (2 servers found)                                                                                                                       
;; global options: +cmd                                                                                                                   
;; Got answer:                                                                                                                            
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 9591                                                                                  
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1                                                                   
                                                                                                                                          
;; OPT PSEUDOSECTION:                                                                                                                     
; EDNS: version: 0, flags: do; udp: 4096                                                                                                  
; COOKIE: 69a0c61239afd9a201000000609c5df711d4eb3a39f90d89 (good)                                                                         
;; QUESTION SECTION:                                                                                                                      
;grp2.lacnic35.te-labs.training.        IN      SOA                                                                                       
                                                                                                                                          
;; ANSWER SECTION:                                                                                                                        
grp2.lacnic35.te-labs.training. 30 IN   SOA     grp2.lacnic35.te-labs.training. root.example.com.grp2.lacnic35.te-labs.training. 1 604800 
86400 2419200 86400                                                                                                                       
grp2.lacnic35.te-labs.training. 30 IN   RRSIG   SOA 8 4 30 20210611215606 20210512215606 41110 grp2.lacnic35.te-labs.training. RmUbjShh4jX
fw384miz1G1703ObV9WrYQOOJVSbzDNchCsLayuW/UQRR w3X6eTXHOCSVOcG2Bamkbals48LYUA9Y/l2tmuaGxKkeQVT5xcy0wY/r beaN4NgUG+N13BFodOPQumsBERQ+NUDAw89
8IfkcwcZ3pZFgIAsXplA1 MY4= 
```

