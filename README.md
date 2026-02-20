
# GreenDevCorp Startup Infrastructure (PAU DOMINGO TORRIJOS I ADRIÀ CABRÉ ACER)            

#***************************************************************************************************************************************#
#                                                                                                                                       #
#			                   -- Guia d'Instal·lació i Recuperació --                                                      #
#                                                                                                                                       #
#---------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                       #
#		Per a un desplegament nou:                                                                                              #
#		                                                                                                                        #
#			**Clonar repositori (via SSH):**                                                                                #
#                                                                                                                                       #
#				git clone git@github.com:Adriii9/GSX-Practica1.git /opt/admin                                           #
#                                                                                                                                       #
#			**Configurar programari i serveis:**                                                                            #
#                                                                                                                                       #
#				sudo /opt/admin/scripts/setup_packages.sh                                                               #
#                                                                                                                                       #
#			**Configurar estructura i permisos:**                                                                           #
#                                                                                                                                       #
#				sudo /opt/admin/scripts/setup_admin_dirs.sh                                                             #
#                                                                                                                                       #
#			**Verificar instal·lació:**                                                                                     #
#                                                                                                                                       #
#				sudo /opt/admin/scripts/verify_setup.sh                                                                 #
#                                                                                                                                       #
#                                                                                                                                       #
#                                                                                                                                       #
#		En cas de fallada crítica o corrupció:                                                                                  #
#                                                                                                                                       #
#			Si el directori /opt/admin no funciona o li falten scripts, executa el protocol de recuperació:                 # 
#				                                                                                                        #
#				sudo bash /ruta/al/script/recovery_setup.sh                                                             #
#                                                                                                                                       #
# 			Això deixarà el sistema net, clonarà el repositori de nou i forçarà el retorn al commit de seguretat b36fbb4.   #
#                                                                                                                                       #
#                                                                                                                                       #
#****************************************************************************************************************************************






#=====================================================================================#
#                       S   E   T   M   A   N   A   -      1                          #
#=====================================================================================#

Aquest repositori conté la infraestructura base del servidor Debian per a la startup **GreenDevCorp**. 
L'objectiu d'aquesta setmana ha estat establir un entorn d'administració remot, segur i automatitzat.

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
5.  **`recovery_setup.sh`**Dissenyat per restaurar la infraestructura en cas d'esborrat o corrupció (Ampliació i decisió de disseny):

			- Neteja: Esborra el directori si existeix però no és un repositori vàlid per permetre un clone net.
			
			- Restauració: Força l'estat dels scripts al commit segur .

			- Reparació de Permisos: Reaplica la propietat de grup per garantir que l'equip pugui tornar a treballar immediatament.

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


#=====================================================================================#
#                       S   E   T   M   A   N   A   -       2	           	      #
#=====================================================================================#

Implementació de la resiliència del sistema i automatització de tasques crítiques

## 1. Gestió de Serveis i Alta Disponibilitat
Hem implementat la gestió de serveis mitjançant systemd per garantir que les aplicacions crítiques estiguin sempre actives:

 * **Nginx (Web Server)**: Instal·lat i configurat per arrencar en l'inici del sistema.

 * **Resiliència Automàtica**: Mitjançant un fitxer d'override, hem configurat Nginx perquè es reiniciï automàticament cada 5 segons si el procés falla (Restart=on-failure).

## 2. Automatització de Backups amb Timers
Substituïm les tasques manuals per un sistema de systemd timers, molt més robust que el cron tradicional:

 * **Frequències múltiples**: Tenim configurats tres serveis de backup (24h, 72h, 7D) que llegeixen la ruta a copiar des de fitxers de configuració a /opt/admin/configs/.

 * **Garantia d'execució (Persistència)**: Tots els timers tenen activada l'opció Persistent=true. Això garanteix que, si el servidor estava apagat a l'hora del backup,
 la tasca s'executarà immediatament en engegar-se.

## 3. Observabilitat i Gestió de Logs
Per evitar que el sistema es quedi sense espai i per facilitar el diagnòstic, hem configurat:

 * **Límits de Journald**: Hem restringit l'ús de disc dels logs a 100MB i una retenció màxima de 3 mesos mitjançant journald-limits.conf.

 * **Script de Diagnòstic (check_logs.sh):** Una eina ràpida per auditar l'estat de Nginx, verificar l'èxit dels últims backups i monitoritzar l'espai que ocupen els logs en temps real.







