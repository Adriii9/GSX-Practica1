#!/bin/bash

# COMPROVACIÓ INICIAL DE SEGURETAT
if [ "$EUID" -ne 0 ]; then
    echo "Si us plau, executa'm fent servir root (su -)."
    exit 1
fi

echo "--- Instal·lant paquets i eines bàsiques ---"

# (1). ACTUALITZACIÓ I INSTAL·LACIÓ
# Instal·lem les eines necessàries per a l'administració
apt update && apt install -y sudo openssh-server git htop

# (2). PRIVILEGIS (Escalada segura)
# Afegim l'usuari gsx al grup sudo per complir el principi de mínim privilegi
if groups gsx | grep -q "\bsudo\b"; then
    echo "L'usuari gsx ja té permisos de sudo."
else
    usermod -aG sudo gsx
    echo "Usuari gsx afegit al grup sudo."
fi

# (3). ACTIVACIÓ DEL SERVEI SSH
# Activem accés remot per a la col·laboració de l'equip
systemctl enable --now ssh

echo "--- Instal·lació completada. Recorda reiniciar per aplicar els grups. ---"
