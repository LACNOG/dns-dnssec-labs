# TUTORIAL DNS en LACNIC 35

## Instructores

- Nicolas Antoniello (ICANN, LACNOG)
- Carlos Martínez-Cagnazzo (LACNIC, LACNOG)

## Inicializar el ambiente y el laboratorio

El ambiente del lab necesita de una VM con Linux Ubuntu 20.04. Esta VM debe tener algunos paquetes básicos instalados, a saber:

- ansible
- git
- curl
- bind9-tools

Se recomiendan ademas los siguientes paquetes:

- net-tools
- vim-tiny
- rsync

### Inicialización usando Vagrant

El ambiente puede ser instanciado en la laptop de cada estudiante utilizando las herramientas Vagrant y VirtualBox.

Primero debemos instalar en nuestra laptop o PC dos herramientas:

- Vagrant: https://vagranup.com 
- VirtualBox: https://www.virtualbox.org

Una vez instaladas estas herramientas, podemos utilizar git para clonar el repositorio del tutorial o bajarlo como zip.

- Para clonarlo: ```git clone https://github.com/LACNOG/dns-dnssec-labs.git```
- Para bajarlo como zip:
   - visitar la web en : https://github.com/LACNOG/dns-dnssec-labs 
   - clickear en "Code" y seleccionar "Download as zip"

Si tenemos instalado Vagrant y VirtualBox, alcanza con ejecutar el comando:

```
vagrant up
```

Este comando descarga una plantilla de VM y ejecuta los comandos para crear el ambiente del laboratorio. Una vez que este ambiente está listo, podemos accederlo mediante:

```
vagrant ssh
cd dns-dnssec-labs/tutorial-lacnic35
```

## Descripción del ambiente

Hay tres contenedores, todos ellos conectados a la red 100.100.1.0/24.

- raiz (100.100.1.2)
- recursivo (100.100.1.3)
- autoritativo (100.100.1.4)

El host no tiene instalado un servidor DNS pero tiene instaladas las herramientas host y dig.

## Gestión del laboratorio

Para poder resetear el estado del laboratorio en caso de que cometamos errores es conveniente primero crear un "branch" local en git.

```
git branch local
git checkout local
```

Para refrescar las configuraciones o reiniciar los contenedores usamos los comandos:

```
docker-compose down 
docker-comose up
```

Utilizando la sintaxis usual del shell de Unix esto se puede abreviar en una linea única:

```
docker-compose down && docker-comose up
```

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