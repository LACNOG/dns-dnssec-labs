# Firmando zonas autoritativas en 15 minutos

## Inicialización 

- Lab basado en Vagrant
  - *Automazitar, amigos y amigas, ¡A automatizar!*
- Provisionado con Ansible
  - *No es la única herramienta, pero es suficientemente bueno*

Levantar con:

```
vagrant up
```

## Cargar el servidor y verificar la operacion

Zona: pande.mia

```shell
dig @localhost soa +multi pande.mia
```

Cada vez que se hace un cambio, hay que reiniciar el bind, haciendo, desde el usuario "vagrant":

```
sudo /etc/init.d/bind9 restart
```



## Firmar con DNSSEC

*Toda la actividad ocurre en el directorio /home/bind9/var/zones, por ello empezar cambiando a ese directorio*

```shell
sudo -i -u bind9
cd $HOME/var/zones
```



1. Generar un par de claves ZSK

```
dnssec-keygen -K . -a RSASHA256 -b 2048 -n ZONE pande.mia
```

2. Firmar la zona 

```
dnssec-signzone -S -P -K . -o pande.mia db.pande.mia
```

3. Chequear el archivo de zona firmado, chequearlo

```
named-checkzone pande.mia db.pande.mia
named-checkzone pande.mia db.pande.mia.signed
```

4. ¡ Corregir el warning !
   1. *modificando el valor del registro MX*
5. Refirmar, recargar el bind



## Verificar que se está sirviendo la zona firmada



```shell
dig @localhost soa pande.mia +dnssec
```

