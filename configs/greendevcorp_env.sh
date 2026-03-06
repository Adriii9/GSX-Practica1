# /etc/profile.d/greendevcorp_env.sh
# Configuració d'entorn per a l'equip GreenDevCorp (Week 4)

# Verifiquem si l'usuari pertany al grup de l'equip
if groups | grep -q "\bgreendevcorp\b"; then
    # 1. Personalització del PATH
    # Afegim el directori de scripts compartits al PATH de l'usuari
    export PATH="$PATH:/home/greendevcorp/bin"

    # 2. Àlies comuns per a l'equip
    alias ll='ls -lah'
    alias work='cd /home/greendevcorp/shared'
    alias logs='tail -f /opt/admin/logs/backup.log' # Exemple útil

    # Missatge de benvinguda opcional
    echo "Benvingut a l'entorn de GreenDevCorp, $(whoami)!"
    echo "Ruta de treball: /home/greendevcorp/shared"
fi
