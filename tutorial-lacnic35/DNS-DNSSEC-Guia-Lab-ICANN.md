# Configurando servidor recursivo (BIND)

Utilizamos el contenedor "Resolv 1" (servidor recursivo) [**grpX-resolv1**]

Este contenedor ya tiene descargados e instalados los paquetes de BIND9.

Nos cambiamos al usuario root

```
$ sudo su -
```

Vamos al directorio /etc/bind

```
# cd /etc/bind
```

En este momento debemos configurar algunas opciones de BIND9. Para ello editamos el archivo /etc/bind/named.conf.options

```
# nano named.conf.options
```

Ahora añadimos las opciones para indicarle al resolver cuales son las direcciones IP que podrán enviarle consultas DNS y al mismo tiempo a que direcciones IP escuchará por el puerto 53 (en este caso ambos prefijos son idénticos). El archivo deberá quedar de la siguiente forma:

```
options {
	directory "/var/cache/bind";

	// If there is a firewall between you and nameservers you want
	// to talk to, you may need to fix the firewall to allow multiple
	// ports to talk. See http://www.kb.cert.org/vuls/id/800113

	// If your ISP provided one or more IP addresses for stable 
	// nameservers, you probably want to use them as forwarders.  
	// Uncomment the following block, and insert the addresses replacing 
	// the all-0's placeholder.

	// forwarders {
	// 	0.0.0.0;
	// };

	//========================================================================
	// If BIND logs error messages about the root key being expired,
	// you will need to update your keys. See https://www.isc.org/bind-keys
	//========================================================================
	dnssec-validation auto;

	listen-on-v6 { any; };

	listen-on port 53 { localhost; 100.100.0.0/16; };
	listen-on-v6 port 53 { localhost; fd89:59e0::/32; };
	allow-query { localhost; 100.100.0.0/16; fd89:59e0::/32; };

	recursion yes;
};
```

Una vez que finalizamos la edición del archivo de configuración ejecutamos un comando que nos permite crear rápidamente si la configuración está semánticamente correcta (si el comando no devuelve nada significa que efectivamente no encontró errores en los archivo de configuración:

```
# named-checkconf
```

Finalmente reiniciamos el servidor para que tome los cambios de configuración:

```
# systemctl restart bind9
```

Y revisamos el estado del proceso bind9

```
# systemctl status bind9
```

Deberemos obtener una salida similar a la siguiente:

```
●** named.service - BIND Domain Name Server
   Loaded: loaded (/lib/systemd/system/named.service; enabled; vendor preset: enabled)
  Drop-In: /etc/systemd/system/service.d
       └─lxc.conf
   Active: **active (running)** since Thu 2021-05-13 01:38:27 UTC; 4s ago
    Docs: man:named(8)
  Main PID: 849 (named)
   Tasks: 50 (limit: 152822)
   Memory: 103.2M
   CGroup: /system.slice/named.service
       └─849 /usr/sbin/named -f -u bind

May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: **command channel listening on ::1#953**
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: managed-keys-zone: loaded serial 6
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: zone 0.in-addr.arpa/IN: loaded serial 1
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: zone 127.in-addr.arpa/IN: loaded serial 1
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: zone localhost/IN: loaded serial 2
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: zone 255.in-addr.arpa/IN: loaded serial 1
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: **all zones loaded**
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: **running**
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: managed-keys-zone: Key 20326 for zone . is now trusted (acceptance timer>
May 13 01:38:27 resolv1.grp2.lacnic35.te-labs.training named[849]: resolver priming query complete
```



# Configurando servidor recursivo (Unbound)







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

Utilizamos el contenedor "SOA" (autoritativo oculto) [**grpX-soa**]

Vamos al directorio /etc/bind y clonamos el archivo db.empty

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

/**** FALTA ****/

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



## Generamos el registro DS a ingresar en la zona padre

**(en este caso en el autoritario de la zona lacnic35.te-labs.training)**

Para que la plataforma de laboratorio localice e ingrese el registro DS en la zona correspondiente, deberemos guardarlo en un archivo con el nombre *DS.record* en el directorio */var/dns/dnssec/keys*

Para ello creamos el directorio correspondiente (y todos los directorios necesarios)

```
# mkdir -p /var/dns/dnssec/keys
```

Y ejecutamos el siguiente comando para obtener el registro DS y guardarlo en el archivo requerido

```
# dig @localhost dnskey grpX.lacnic35.te-labs.training | dnssec-dsfromkey -f - grpX.lacnic35.te-labs.training > /var/dns/dnssec/keys/DS.record
```

Verificamos el contenido del archivo generado

```
# cat /var/dns/dnssec/keys/DS.record
```

Que deberá contener algo parecido a la siguiente línea:

```
grpX.lacnic35.te-labs.training. IN DS 23471 8 2 018A86C0139BA5500AC87A5BAD8FB5D8D4F9672C319B34DB5A7F3BC10A424D6E
```

*Luego de esto informamos al tutor del laboratorio que dejamos listo el archivo con el registro DS para que lo ingrese en la zona padre*.

