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

