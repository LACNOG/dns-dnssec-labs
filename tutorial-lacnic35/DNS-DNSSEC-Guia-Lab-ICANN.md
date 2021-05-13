# Topologia de red de un grupo X [grpX]



![ICANN-LAB-NET-topo](DNS-DNSSEC-Guia-Lab-ICANN-pics/ICANN-LAB-NET-topo.png)



```
     EQUIPO          DIRECCION IPv4            DIRECCION IPv6
+--------------+-----------------------+-----------------------------+
| grpX-cli     | 100.100.X.2 (eth0)    | fd89:59e0:X::2 (eth0)       |
+--------------+-----------------------+-----------------------------+
| grpX-ns1     | 100.100.X.130 (eth0)  | fd89:59e0:X:128::130 (eth0) |
+--------------+-----------------------+-----------------------------+
| grpX-ns2     | 100.100.X.131 (eth0)  | fd89:59e0:X:128::131 (eth0) |
+--------------+-----------------------+-----------------------------+
| grpX-resolv1 | 100.100.X.67 (eth0)   | fd89:59e0:X:64::67 (eth0)   |
+--------------+-----------------------+-----------------------------+
| grpX-resolv2 | 100.100.X.68 (eth0)   | fd89:59e0:X:64::68 (eth0)   |
+--------------+-----------------------+-----------------------------+
| grpX-rtr     | 100.64.1.X (eth0)     | fd89:59e0:X::1 (eth1)       |
|              | 100.100.X.65 (eth2)   | fd89:59e0:X:64::1 (eth2)    |
|              | 100.100.X.193 (eth4)  | fd89:59e0:X:192::1 (eth4)   |
|              | 100.100.X.129 (eth3)  | fd89:59e0:X:128::1 (eth3)   |
|              | 100.100.X.1 (eth1)    | fd89:59e0:0:1::X (eth0)     |
+--------------+-----------------------+-----------------------------+
| grpX-soa     | 100.100.X.66 (eth0)   | fd89:59e0:X:64::66 (eth0)   |
+--------------+-----------------------+-----------------------------+
```

Donde en esta práctica **solamente** vamos a acceder a los siguientes equipos:

* **grpX-cli** : cliente
* **grpX-resolv1** y **grpX-resolv2** : servidores recursivos
* **grpX-soa** : servidor autoritativo oculto (primario)
* **grpX-ns1** y **grpX-ns2** : servidores autoritativos secundarios



---



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

	listen-on port 53 { localhost; 100.100.0.0/16; };									<--- Agregar
	listen-on-v6 port 53 { localhost; fd89:59e0::/32; };							<--- Agregar
	allow-query { localhost; 100.100.0.0/16; fd89:59e0::/32; };				<--- Agregar

	recursion yes;																										<--- Agregar
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
● named.service - BIND Domain Name Server
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

Utilizamos el contenedor "Resolv 2" (servidor recursivo) [**grpX-resolv2**]

Este contenedor ya tiene descargados e instalados los paquetes de Unbound.

Nos cambiamos al usuario root

```
$ sudo su -
```

Vamos al directorio /etc/bind

```
# cd /etc/unbound
```

En este momento debemos configurar algunas opciones de Unbound. Para ello editamos el archivo /etc/unbound/unbound.conf

```
# nano unbound.conf
```

Ahora añadimos las opciones para indicarle al resolver cuales son las interfaces en las que escuchará consultas, las direcciones IP que podrán enviarle consultas DNS, el puerto que utilizará (53), y algunos otros parámetros. El archivo deberá quedar de la siguiente forma:

```
# Unbound configuration file for Debian.
#
# See the unbound.conf(5) man page.
#
# See /usr/share/doc/unbound/examples/unbound.conf for a commented
# reference config file.
#
# The following line includes additional configuration files from the
# /etc/unbound/unbound.conf.d directory.

server:
        interface: 0.0.0.0
        interface: ::0

        access-control: 127.0.0.0/8 allow
        access-control: 100.100.0.0/16 allow
        access-control: fd89:59e0::/32 allow

        port: 53

        do-udp: yes
        do-tcp: yes
        do-ip4: yes
        do-ip6: yes

include: "/etc/unbound/unbound.conf.d/*.conf"
```

Una vez que finalizamos la edición del archivo de configuración ejecutamos un comando que nos permite crear rápidamente si la configuración está semánticamente correcta

```
# unbound-checkconf
```

Si la misma es correcta nos devolverá algo similar a lo siguiente

```
unbound-checkconf: no errors in /etc/unbound/unbound.conf
```

Finalmente reiniciamos el servidor para que tome los cambios de configuración:

```
# systemctl restart unbound
```

Y revisamos el estado del proceso bind9

```
# systemctl status unbound
```

Deberemos obtener una salida similar a la siguiente:

```
● unbound.service - Unbound DNS server
     Loaded: loaded (/lib/systemd/system/unbound.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/service.d
             └─lxc.conf
     Active: active (running) since Thu 2021-05-13 03:49:11 UTC; 13s ago
       Docs: man:unbound(8)
    Process: 571 ExecStartPre=/usr/lib/unbound/package-helper chroot_setup (code=exited, status=0/SUCCESS)
    Process: 574 ExecStartPre=/usr/lib/unbound/package-helper root_trust_anchor_update (code=exited, status=0/SUCCESS)
   Main PID: 578 (unbound)
      Tasks: 1 (limit: 152822)
     Memory: 7.8M
     CGroup: /system.slice/unbound.service
             └─578 /usr/sbin/unbound -d

May 13 03:49:10 resolv2.grp2.lacnic35.te-labs.training unbound[178]: [178:0] info: [25%]=0 median[50%]=0 [75%]=0
May 13 03:49:10 resolv2.grp2.lacnic35.te-labs.training unbound[178]: [178:0] info: lower(secs) upper(secs) recursions
May 13 03:49:10 resolv2.grp2.lacnic35.te-labs.training unbound[178]: [178:0] info:    0.000000    0.000001 1
May 13 03:49:11 resolv2.grp2.lacnic35.te-labs.training package-helper[577]: /var/lib/unbound/root.key has content
May 13 03:49:11 resolv2.grp2.lacnic35.te-labs.training package-helper[577]: success: the anchor is ok
May 13 03:49:11 resolv2.grp2.lacnic35.te-labs.training unbound[578]: [578:0] notice: init module 0: subnet
May 13 03:49:11 resolv2.grp2.lacnic35.te-labs.training unbound[578]: [578:0] notice: init module 1: validator
May 13 03:49:11 resolv2.grp2.lacnic35.te-labs.training unbound[578]: [578:0] notice: init module 2: iterator
May 13 03:49:11 resolv2.grp2.lacnic35.te-labs.training unbound[578]: [578:0] info: start of service (unbound 1.9.4).
May 13 03:49:11 resolv2.grp2.lacnic35.te-labs.training systemd[1]: Started Unbound DNS server.
```



---



# Firmando zonas con DNSSEC



## Intro

Vamos a crear la zona autoritativa grp2.lacnic35.te-labs.training y luego la firmaremos con DNSSEC. Trataremos también de formar una cadena de confianza completa.



## Que es lo que ya sabemos

Nuestro "padre" ya ha creado lo siguiente en su propia zona:

```shell
; grpX
grpX             NS           ns1.grpX.lacnic35.te-labs.training.
grpX             NS           ns2.grpX.lacnic35.te-labs.training.
; ---Placeholder for grp2 DS record (DO NOT MANUALLY EDIT THIS LINE)---
ns1.grpX         A           100.100.X.130
ns1.grpX         AAAA        fd89:59e0:X:128::130
ns2.grpX         A           100.100.X.131
ns2.grpX         AAAA        fd89:59e0:X:128::131

```

Nuestra zona debe ser compatible con esto.



## Configurando la zona autoritativa

Utilizamos el contenedor "SOA" (autoritativo primario oculto) [**grpX-soa**]

Vamos al directorio /etc/bind y clonamos el archivo db.empty

```cp db.empty db.grpX```

El contenido de la zona deberá ser al menos:

```
; grpX 

$TTL    30
@       IN      SOA     grpX.lacnic35.te-labs.training. root.example.com (                                            
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;

; grpX 
grpX             NS           ns1.grpX.lacnic35.te-labs.training.
grpX             NS           ns2.grpX.lacnic35.te-labs.training.

ns1.grpX         A           100.100.X.130
ns1.grpX         AAAA        fd89:59e0:X:128::130
ns2.grpX         A           100.100.X.131
ns2.grpX         AAAA        fd89:59e0:X:128::131

;; SE PUEDEN AGREGAR MAS REGISTROS A GUSTO
```



En el archivo de configuracion /etc/bind/named.conf.local colocamos el enunciado "zone":

```
zone "grpX.lacnic35.te-labs.training" {                                                                               
        type master;                                                                                                  
        file "/etc/bind/db.grpX";                                                                                     
        allow-transfer { any; };                                                                                      
}; 
```

Reiniciamos el servidor y verificamos:

```
rndc reload


root@soa:/etc/bind# dig @localhost soa grpX.lacnic35.te-labs.training.                                                

; <<>> DiG 9.16.1-Ubuntu <<>> @localhost soa grpX.lacnic35.te-labs.training.
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 64339
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 270e2c46ed443c1c01000000609c59f04ba85015ff71998d (good)
;; QUESTION SECTION:
;grpX.lacnic35.te-labs.training.        IN      SOA

;; ANSWER SECTION:
grpX.lacnic35.te-labs.training. 30 IN   SOA     grpX.lacnic35.te-labs.training. root.example.com.grpX.lacnic35.te-labs
.training. 1 604800 86400 2419200 86400

;; Query time: 0 msec
;; SERVER: ::1#53(::1)
;; WHEN: Wed May 12 22:42:56 UTC 2021
;; MSG SIZE  rcvd: 170

```



## Configuramos los autoritativos secundarios

Estos servidores son los que exponen nuestra zona públicamente

#### Configuramos primero el servidor ns1 [**grpX-ns1**]

**El servidor ns1 es un BIND** (ISC)

Para ello en el archivo /etc/bind/named.conf.local configuramos los siguientes parámetros:

```
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";

zone "grpX.lacnic35.te-labs.training" {
        type slave;
        masters { 100.100.X.66; };
};
```

Verificamos la configuración y si no hay errores reincidamos el servidor

```
# named-checkconf
# systemctl restart bind9
```

Verificamos que reinicio correctamente

```
\# systemctl status bind9
```

```
● named.service - BIND Domain Name Server
     Loaded: loaded (/lib/systemd/system/named.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/service.d
             └─lxc.conf
     Active: active (running) since Thu 2021-05-13 04:25:43 UTC; 9s ago
       Docs: man:named(8)
   Main PID: 739 (named)
      Tasks: 50 (limit: 152822)
     Memory: 103.9M
     CGroup: /system.slice/named.service
             └─739 /usr/sbin/named -f -u bind

May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: all zones loaded
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: running
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: zone grp2.lacnic35.te-labs.training/IN: Transfer started.
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: transfer of 'grp2.lacnic35.te-labs.training/IN' from 100.100.2.66#53: connec>
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: zone grp2.lacnic35.te-labs.training/IN: transferred serial 1
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: transfer of 'grp2.lacnic35.te-labs.training/IN' from 100.100.2.66#53: Transf>
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: transfer of 'grp2.lacnic35.te-labs.training/IN' from 100.100.2.66#53: Transf>
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: zone grp2.lacnic35.te-labs.training/IN: sending notifies (serial 1)
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: managed-keys-zone: Key 20326 for zone . is now trusted (acceptance timer com>
May 13 04:25:43 ns1.grp2.lacnic35.te-labs.training named[739]: resolver priming query complete
```



#### Configuramos ahora el servidor ns2 [**grpX-ns2**]

**El servidor ns1 es un NSD** (NLnet Labs)

Para ello en el archivo /etc/nsd/nsd.conf configuramos los siguientes parámetros:

```
# NSD configuration file for Debian.
#
# See the nsd.conf(5) man page.
#
# See /usr/share/doc/nsd/examples/nsd.conf for a commented
# reference config file.
#
# The following line includes additional configuration files from the
# /etc/nsd/nsd.conf.d directory.

include: "/etc/nsd/nsd.conf.d/*.conf"

server:
	zonesdir: "/etc/nsd"

pattern:
	name: "fromprimary"
	allow-notify: 100.100.X.66 NOKEY
	request-xfr: AXFR 100.100.X.66 NOKEY

zone:
	name: "grpX.lacnic35.te-labs.training"
	zonefile: "grpX.lacnic35.te-labs.training.forward"
	include-pattern: "fromprimary"
```

Verificamos la configuración y si no hay errores reincidamos el servidor

```
# nsd-checkconf /etc/nsd/nsd.conf
# systemctl restart nsd
```

Verificamos que reinicio correctamente

```
# systemctl status nsd
```

```
● nsd.service - Name Server Daemon
     Loaded: loaded (/lib/systemd/system/nsd.service; enabled; vendor preset: enabled)
    Drop-In: /etc/systemd/system/service.d
             └─lxc.conf
     Active: active (running) since Thu 2021-05-13 05:02:35 UTC; 1min 22s ago
       Docs: man:nsd(8)
   Main PID: 638 (nsd)
      Tasks: 3 (limit: 152822)
     Memory: 114.5M
     CGroup: /system.slice/nsd.service
             ├─638 /usr/sbin/nsd -d
             ├─639 /usr/sbin/nsd -d
             └─640 /usr/sbin/nsd -d

May 13 05:02:35 ns2.grp2.lacnic35.te-labs.training systemd[1]: Starting Name Server Daemon...
May 13 05:02:35 ns2.grp2.lacnic35.te-labs.training nsd[638]: nsd starting (NSD 4.1.26)
May 13 05:02:35 ns2.grp2.lacnic35.te-labs.training nsd[638]: [2021-05-13 05:02:35.865] nsd[638]: notice: nsd starting (NSD 4.1.26)
May 13 05:02:35 ns2.grp2.lacnic35.te-labs.training nsd[639]: nsd started (NSD 4.1.26), pid 638
May 13 05:02:35 ns2.grp2.lacnic35.te-labs.training nsd[639]: [2021-05-13 05:02:35.922] nsd[639]: notice: nsd started (NSD 4.1.26), pid 638
May 13 05:02:35 ns2.grp2.lacnic35.te-labs.training systemd[1]: Started Name Server Daemon.
```



---



## Firmamos la zona

Para firmar la zona primero precisamos dos pares de claves, una ZSK y una KSK. Se puede firmar con un único par de claves pero no es una configuración recomendada.


```
#Create directory to hold DNSSEC keys

mkdir -p /etc/bind/keys

cd /etc/bind/keys

# Generate ZSK

dnssec-keygen -a RSASHA256 -3 -b 1024 -n ZONE grpX.lacnic35.te-labs.training

# Generate KSK

dnssec-keygen -f KSK -a RSASHA256 -b 2048 -3 -n ZONE grpX.lacnic35.te-labs.training

chown -R bind:bind /etc/bind/keys
```

Luego firmamos la zona:

```
dnssec-signzone -S -P -K keys -o grpX.lacnic35.te-labs.training db.grpX 
```

Finalmente sustituimos en named.conf.local el archivo db.grpX por el db.grpX.signed y reiniciamos el servidor con ```rndc reload```

Verificamos:

```
root@soa:/etc/bind# dig @localhost soa grpX.lacnic35.te-labs.training. +dnssec                                                            
                                                                                                                                          
; <<>> DiG 9.16.1-Ubuntu <<>> @localhost soa grpX.lacnic35.te-labs.training. +dnssec                                                      
; (2 servers found)                                                                                                                       
;; global options: +cmd                                                                                                                   
;; Got answer:                                                                                                                            
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 9591                                                                                  
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1                                                                   
                                                                                                                                          
;; OPT PSEUDOSECTION:                                                                                                                     
; EDNS: version: 0, flags: do; udp: 4096                                                                                                  
; COOKIE: 69a0c61239afd9a201000000609c5df711d4eb3a39f90d89 (good)                                                                         
;; QUESTION SECTION:                                                                                                                      
;grpX.lacnic35.te-labs.training.        IN      SOA                                                                                       
                                                                                                                                          
;; ANSWER SECTION:                                                                                                                        
grpX.lacnic35.te-labs.training. 30 IN   SOA     grpX.lacnic35.te-labs.training. root.example.com.grpX.lacnic35.te-labs.training. 1 604800 
86400 2419200 86400                                                                                                                       
grpX.lacnic35.te-labs.training. 30 IN   RRSIG   SOA 8 4 30 20210611215606 20210512215606 41110 grpX.lacnic35.te-labs.training. RmUbjShh4jX
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

