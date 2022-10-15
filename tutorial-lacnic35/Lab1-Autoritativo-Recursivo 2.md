# Lab 1 - Configuración de un servidor DNS autoritativo y de un recursivo

Al finalizar esta guia tendremos un servidor con una zona autoritativa y otro que tiene una zona autoritativa pero también realiza recursión.

## Tarea 1: Configurar el recursivo para que acepte consultas recursivas desde de la red 100.100.1.0/24

Dentro del directorio del laboratorio, editar los archivos de configuración del recursivo que se encuentran en ```etc/grp1/recursivo``` para permitir la recursión desde la red 100.100.1.0/24.

Para ello editamos el archivo ```etc/grp1/recursivo/named.conf.options``` para que la sección allow-recursion se vea así:

```
    allow-recursion {
            127.0.0.1;
            100.100.1.0/24;
    };
```

Reiniciar el laboratorio con ```docker-compose down``` && ```docker-compose up -d```    

Verificar con el comando:

```
dig www.google.com @100.100.1.3
```

Si la respuesta es vacía y el status REFUSED es porque los cambios no surtieron efecto.

## Tarea 2: Configurar una zona autoritativa

Dentro del directorio del laboratorio, editar los archivos de configuración del autoritativo que se encuentran en ```etc/grp1/autoritativo``` para que el servidor responda por la zona "pande.mia" (o por cualquier nombre de su gusto).

1. Crear el archivo de zona "db.pande.mia" con el siguiente contenido:

```
$TTL	10
@	IN	SOA	pande.mia. root.pande.mia. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns1.pande.mia.
@	IN	NS	ns2.pande.mia.

ns1	IN	A	100.100.1.4
ns2	IN	A   100.100.1.5

nombres IN  TXT juan
nombres IN  TXT pedro
nombres IN  TXT jose

```

2. Agregar la configuración de la zona a la configuración del servidor de nombres:

Editar ```named.conf.local``` y agregar lo siguiente:

```
zone "pande.mia" {
        type master;
        file "/etc/bind/db.pande.mia";
};
```

Reiniciar el laboratorio y verificar:

```
dig soa pande.mia @100.100.1.4
```

## Tarea 3: configurar la zona "mia" en el servidor "raiz" y delegar la zona "pande.mia"

Dentro del directorio del laboratorio, editar los archivos de configuración del autoritativo que se encuentran en ```etc/grp1/raiz``` para que el servidor responda por la zona "pande.mia" (o por cualquier nombre de su gusto).

1. Crear el archivo de zona "db.mia" con el siguiente contenido:

```
$TTL	10
@	IN	SOA	mia. root.mia. (
			      2		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns1.mia.
@	IN	NS	ns2.mia.

ns1	IN	A	100.100.1.2
ns2	IN	A	100.100.1.2

pande.mia.	IN	NS	ns1.pande.mia.
pande.mia.	IN	NS	ns2.pande.mia.
ns1.pande.mia.	IN	A	100.100.1.4
ns2.pande.mia.	IN	A	100.100.1.5
```

2. Agregar la configuración de la zona a la configuración del servidor de nombres:

Editar ```named.conf.local``` y agregar lo siguiente:

```
zone "mia" {
        type master;
        file "/etc/bind/db.mia";
};
```

Reiniciar el laboratorio y verificar:

```
dig soa mia @100.100.1.2
#
dig ns pande.mia @100.100.1.2
```

## Tarea 4: Configuración de la raíz para que pueda hacer recursión en el arbol

Repetir los pasos de la Tarea 1 para que el recursivo (100.100.1.2) acepte consultas recursivas.

Verificar:

```
dig @100.100.1.2 txt nombres.pande.mia
```

Repetir esta consulta rápidamente y observar como el TTL disminuye. Esto nos indica que las respuestas que estamos viendo vienen de caché y no son autoritativas.