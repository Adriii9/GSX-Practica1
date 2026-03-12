# 🟢 GreenDevCorp - Manual d'Infraestructura i Administració

### Projecte: Foundational Server Administration (GSX)
**Administradors:** Pau Domingo Torrijos i Adrià Cabré Acer

---

##  Índex de Continguts
1. [Arquitectura i Configuració Inicial](#arquitectura)
2. [Accés Remot i Seguretat (Setmana 1)](#setmana1)
3. [Serveis, Timers i Observabilitat (Setmana 2)](#setmana2)
4. [Control de Recursos i Processos (Setmana 3)](#setmana3)
5. [Col·laboració, Permisos i PAM (Setmana 4)](#setmana4)
6. [Emmagatzematge i Backups (Setmana 5)](#setmana5)
7. [Guia de Troubleshooting (Resolució de Problemes)](#troubleshooting)
8. [Guia d'Onboarding per a Nous Membres](#onboarding)
9. [Protocol de Recuperació de Desastres](#recuperacio)

---

## <a name="arquitectura"></a>1. Arquitectura i Configuració Inicial
La infraestructura es basa en un servidor **Debian 13 (Trixie)** virtualitzat. Per garantir la col·laboració professional, hem centralitzat la gestió a `/opt/admin`.

* **Estructura de Directoris:**
    * `scripts/`: Lògica d'automatització i manteniment.
    * `configs/`: Fitxers de configuració, unitats de systemd i plantilles.
    * `logs/`: Registres de l'activitat dels scripts i serveis de backup.
    * `backups/`: Còpies locals (ignorat per Git via `.gitignore`).

---

## <a name="setmana1"></a> 2. Accés Remot i Seguretat (Setmana 1)
* **SSH Segur:** S'ha prohibit el login directe de `root`. Utilitzem **claus SSH** per eliminar la dependència de contrasenyes.
* **Privilegis Segurs:** L'administrador opera com a usuari `gsx` i escala privilegis via `sudo`.
* **Scripts Clau:**
    * `setup_packages.sh`: Instal·la el programari essencial.
    * `verify_setup.sh`: Script de diagnòstic per validar la instal·lació.

---

## <a name="setmana2"></a>3. Serveis, Timers i Observabilitat (Setmana 2)
* **Alta Disponibilitat (Nginx):** Configurat amb `Restart=on-failure` per reiniciar-se sol en 5 segons si falla.
* **Automatització amb Timers:** Utilitzem **systemd timers** (24h, 72h, 7D) amb `Persistent=true` per garantir que els backups s'executin encara que el servidor hagi estat apagat.
* **Observabilitat:** Límits de `journald` a 100MB per evitar saturar el disc.

---

## <a name="setmana3"></a> 4. Control de Recursos i Processos (Setmana 3)
* **Diagnòstic Avançat:** `diagnose_processes.sh` analitza dades de `/proc/loadavg` i `/proc/meminfo`.
* **Control amb cgroups v2:** Limitem els backups a un **30% de CPU** i **200MB de RAM** per no afectar Nginx.
* **Gestió de Senyals:** `workload_simulator.sh` demostra el tancament net (*graceful shutdown*) interceptant `SIGTERM` i `SIGINT`.

---

## <a name="setmana4"></a> 5. Col·laboració, Permisos i PAM (Setmana 4)
* **Usuaris i Grups:** Creació del grup `greendevcorp` per als usuaris `dev1` a `dev4`.
* **Permisos Granulars:**
    * `/home/greendevcorp/shared`: Ús de **SetGID** i **Sticky Bit**.
    * **POSIX ACLs:** `dev1` i `dev2` tenen permisos `rwx`, mentre `dev3` i `dev4` són `r-x`.
* **Límits PAM:** Protecció contra *fork-bombs* (`nproc`) i esgotament de descriptors de fitxer (`nofile`).

---

## <a name="setmana5"></a> 6. Emmagatzematge i Backups (Setmana 5)
* **Nou Disc:** Volum particionat i muntat de forma persistent via **UUID** a `/etc/fstab`.
* **Estratègia 3-2-1:** 3 còpies, 2 suports, 1 de remota per garantir la recuperació de dades.

---

## <a name="troubleshooting"></a>7. Guia de Troubleshooting (Resolució de Problemes)
Aquesta guia permet diagnosticar fallades seguint una metodologia sistemàtica.

| Problema | Símptoma | Acció de Resolució |
| :--- | :--- | :--- |
| **Servidor lent** | Càrrega alta a `/proc/loadavg`. | Executar `sudo ./scripts/diagnose_processes.sh` per trobar el procés consumidor. |
| **Nginx no respon** | Servei inactiu o falla el port 80. | Comprovar logs amb `journalctl -u nginx`. Reiniciar manualment amb `systemctl restart nginx`. |
| **Backup fallit** | Falta l'arxiu `.tar.gz` o log d'error. | Verificar el timer amb `systemctl status backup-gsx-24h.timer` i revisar `/opt/admin/logs/backup.log`. |
| **Accés denegat** | Usuari no pot escriure a `/shared`. | Verificar permisos amb `getfacl /home/greendevcorp/shared`. Comprovar si l'usuari és al grup `greendevcorp`. |
| **Procés zombi** | Processos bloquejats a `pstree`. | Identificar PID i enviar `SIGTERM (15)`. Si no respon, usar `SIGKILL (9)` com a últim recurs. |

---

## <a name="onboarding"></a> 8. Guia d'Onboarding per a Nous Membres
Passos per integrar un nou enginyer d'operacions o desenvolupador al sistema.

### A. Creació del Compte
1. **Crear usuari:** `sudo useradd -m -s /bin/bash devX`.
2. **Assignar grup:** `sudo usermod -aG greendevcorp devX`.
3. **Establir límits:** Verificar que els límits a `/etc/security/limits.d/greendevcorp-team.conf` s'apliquen correctament.

### B. Configuració de l'Entorn
L'entorn es configura automàticament gràcies a `/etc/profile.d/greendevcorp_env.sh`. El nou membre disposarà de:
* Accés directe al directori de treball via àlies `work`.
* Binaris compartits al `PATH` (`/home/greendevcorp/bin`).
* Comandes de diagnòstic ràpid com `ll`.

### C. Accés al Repositori
1. L'usuari ha de generar una clau SSH: `ssh-keygen -t ed25519`.
2. Afegir la clau pública al fitxer `authorized_keys` del servidor.
3. Clonar aquest repositori a la seva carpeta local per col·laborar en els scripts.

---

## <a name="recuperacio"></a> 9. Protocol de Recuperació de Desastres
En cas de fallada total del directori administratiu:
1. Executar el script de recuperació: `sudo bash /opt/admin/scripts/recovery_setup.sh`.
2. L'script netejarà el directori i forçarà el retorn al **commit de seguretat b36fbb4**.
3. Per a restaurar dades de l'usuari, seguir el runbook de restauració des de `/var/backups/backups_gsx`.
