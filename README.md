
# GreenDevCorp PRÀCTICA - 1    (PAU DOMINGO TORRIJOS I ADRIÀ CABRÉ ACER)            

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



#=====================================================================================#
#                       S   E   T   M   A   N   A   -       3                         #
#=====================================================================================#

**Gestió de Processos, Senyals i Control de Recursos**

A mesura que la infraestructura de GreenDevCorp creix, diversos serveis i usuaris competeixen pels mateixos recursos de maquinari (CPU, Memòria, I/O). 
L'objectiu d'aquesta tercera setmana ha estat implementar eines d'observabilitat per diagnosticar colls d'ampolla i establir límits estrictes 
(tant a nivell de servei com d'usuari) per evitar que processos descontrolats comprometin l'estabilitat del servidor.

## 1. Observabilitat i Diagnòstic de Processos
Quan el servidor va lent, "reiniciar-lo" no és una solució acceptable. Per diagnosticar problemes de rendiment de forma sistemàtica, 
s'han desenvolupat dos scripts clau:

* **`diagnose_processes.sh`**: Proporciona una fotografia global de l'estat del sistema.
  * **Anàlisi de `/proc`**: Llegeix directament de `/proc/loadavg` i `/proc/meminfo` per obtenir mètriques de càrrega global del sistema 
 i memòria disponible sense la sobrecàrrega d'altres programes.
  * **Top Consumidors**: Utilitza `ps` ordenat dinàmicament per localitzar el "Top 5" de processos que més CPU i Memòria estan consumint en temps real.
  * **Jerarquia**: Genera un arbre de processos (`pstree`) per entendre les relacions pare-fill, essencial per saber quin servei ha llançat
 un procés problemàtic.

* **`diagnose_specific_process.sh`**: Eina de diagnòstic avançat per observar un procés concret (ex. `./diagnose_specific_process.sh nginx`).
  * A més de les mètriques bàsiques d'ús, extreu informació vital de `/proc/[PID]/status`, com ara el nombre de fils d'execució (*Threads*) 
   i els canvis de context voluntaris (*voluntary_ctxt_switches*). 
   Aquesta informació és crucial per detectar aplicacions que fan un ús ineficient de la multitasca.

## 2. Process Lifecycle i Gestió de Senyals (Signals)
Per comprendre com interactua el sistema operatiu amb els processos en execució, s'ha creat un entorn de proves segur:

* **`workload_simulator.sh`**: Aquest script simula una càrrega de treball pesada (llançant la comanda `yes` en segon pla) i es manté en un bucle d'espera.
* **Tractament de Senyals (`trap`)**: L'script està dissenyat per interceptar (o atrapar) senyals específics del sistema:
  * `SIGTERM (15)` i `SIGINT (2)`: S'han configurat per executar un tancament net (*graceful shutdown*), netejant els processos fills abans de sortir,
 evitant així deixar processos *zombie*.
  * `SIGHUP (1)`: Simula la recàrrega de configuració sense aturar el servei.
  * `SIGUSR1 / SIGUSR2`: Senyals personalitzats utilitzats per mostrar l'estat del procés.
* Gràcies a aquest simulador, podem practicar la suspensió de processos (`kill -SIGSTOP`), la represa (`kill -SIGCONT`) i la modificació de prioritats
 de planificació de la CPU utilitzant `nice` i `renice`.

## 3. Control de Recursos i Resiliència
Per garantir que la màquina no caigui per culpa d'un *script* maliciós, d'un error de programació  o d'un procés legítim molt pesat, hem implementat
 la següent arquitectura de defensa en profunditat:

### A) Límits a nivell de Servei (cgroups v2)
El nucli (Kernel) de Linux permet agrupar processos i limitar-ne l'ús de recursos mitjançant els *Control Groups*. Hem aplicat aquestes restriccions 
des de `systemd`:
* **Servei Simulat (`workload-simulator.service`)**: Limitat a un ús màxim del 25% d'un nucli de CPU (`CPUQuota=25%`) i un límit de memòria 
RAM de 100 MB (`MemoryMax=100M`). Això demostra que podem tenir aplicacions pesades contingudes de forma segura.
* **Serveis de Còpia de Seguretat**: S'han modificat els serveis creats a la Week 2 (`backup-gsx-24h`, `72h` i `7D`) per limitar-ne el consum (30% CPU, 200MB RAM). *Justificació de disseny:* Un procés de *backup* intensiu (comprimir fitxers amb `tar -cz`) no hauria d'acaparar mai la CPU del servidor web de producció (Nginx).

### B) Límits a nivell d'Usuari (PAM)
S'ha configurat el mòdul d'autenticació PAM mitjançant el fitxer `/etc/security/limits.d/gsx-limits.conf` per protegir el sistema a nivell de sessió per a
 l'usuari `gsx`:
* **`nproc` (Processos concurrents)**: Límit *soft* de 300 i *hard* de 400 processos. Aquesta és la defensa principal contra atacs de denegació de servei
 local com les *fork-bombs*.
* **`nofile` (Fitxers oberts simultàniament)**: Límit *soft* de 1024 i *hard* de 4096. Evita que una aplicació mal programada exhaureixi els descriptors
 de fitxers de tot el servidor.















