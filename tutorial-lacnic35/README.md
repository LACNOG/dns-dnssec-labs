# TUTORIAL DNS en LACNIC 35

## Instructores

- Nicolas Antoniello (ICANN, LACNOG)
- Carlos Martínez-Cagnazzo (LACNIC, LACNOG)

## Inicializar el ambiente

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

El ambiente puede ser instanciado en una máquina virtual local utilizando Vagrant fácilmente. Si tenemos instalado Vagrant y VirtualBox, alcanza con ejecutar el comando:

```
vagrant up
```

Este comando descarga una plantilla de VM y ejecuta los comandos para crear el ambiente del laboratorio. Una vez que este ambiente está listo, podemos accederlo mediante:

```
vagrant ssh
```

## Descripción del ambiente

Hay tres contenedores:

- raiz (.2)
- recursivo (.3)
- autoritativo (.4)

Todos ellos están conectados a la red 100.100.1.0/24.

El host no tiene instalado un servidor DNS pero tiene instaladas las herramientas host y dig.

## Laboratorio

Para poder reiniciar el estado del laboratorio en caso de que cometamos errores es conveniente primero crear un "branch" local en git.

```git branch local````


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

