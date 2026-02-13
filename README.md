# GreenDevCorp Startup Infrastructure - Setmana 1

Aquest repositori conté la infraestructura base del servidor Debian per a la startup **GreenDevCorp**. L'objectiu d'aquesta setmana ha estat establir un entorn d'administració remot, segur i automatitzat[cite: 33, 120, 121].

##Estructura Administrativa
Seguint el requeriment de crear una estructura de directoris compartida, hem centralitzat l'activitat a `/opt/admin`:

* **`scripts/`**: Automatització de tasques (instal·lació, directoris, verificació i backup).
* **`configs/`**: Fitxers de configuració del sistema i plantilles.
* **`logs/`**: Registre d'activitat per a l'observabilitat del sistema.
* **`backups/`**: Còpies de seguretat locals (directori exclòs de Git per seguretat).

## Scripts d'Automatització (Setmana 1)
Tots els scripts han estat dissenyats per ser **idempotents** (poden executar-se múltiples vegades sense errors):

1.  **`setup_packages.sh`**: Instal·la les eines bàsiques (`sudo`, `openssh-server`, `git`, `htop`) i configura el servei SSH.
2.  **`setup_admin_dirs.sh`**: Crea l'estructura de carpetes a `/opt/admin` i configura els permisos de col·laboració.
3.  **`verify_setup.sh`**: Script de diagnòstic que assegura que el setup s'ha aplicat correctament.
4.  **`backup_admin.sh`**: Empaqueta les dades administratives mantenint els atributs de fitxer (permisos) mitjançant `tar` amb encriptació.

## Decisions de Disseny i Seguretat
D'acord amb les preguntes de reflexió del manual:

* **Accés Remot (SSH)**: Hem optat per claus SSH en lloc de contrasenyes per evitar atacs de força bruta i millorar la seguretat de l'accés.
* **Privilegis**: S'aplica el **principi de mínim privilegi**. L'usuari `gsx` escala a `sudo` només quan és necessari, evitant l'ús directe de `root`.
* **Gestió de Git**: Utilitzem un fitxer `.gitignore` per evitar la pujada de dades sensibles, claus privades o fitxers de backup pesats.

## Col·laboració de l'Equip
Per garantir un entorn de treball col·laboratiu:
* Hem assignat la propietat de `/opt/admin` al grup `sudo`, permetent que ambdós administradors treballin sense compartir comptes.
* Cada membre utilitza la seva pròpia identitat SSH per mantenir la traçabilitat dels canvis al repositori.

## Guia d'Instal·lació
Per replicar aquest entorn en un servidor nou:
1. Clonar el repositori: `git clone git@github.com:Adriii9/GSX-Practica1.git /opt/admin`.
2. Executar els scripts d'inici:

   `sudo /opt/admin/scripts/setup_packages.sh`
   `sudo /opt/admin/scripts/setup_admin_dirs.sh`

3. Comprovar que s'ha instal·lat tot correctament amb: 
   `sudo /opt/admin/scripts/verify_setup.sh`
