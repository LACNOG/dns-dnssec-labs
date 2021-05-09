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

## Tarea 1: Configurar el recursivo para que acepte consultas recursivas desde de la red 100.100.1.0/24

Dentro del directorio del laboratorio, editar los archivos de configuración del recursivo que se encuentran en ```etc/grp1/recursivo``` para permitir la recursión desde la red 100.100.1.0/24.


