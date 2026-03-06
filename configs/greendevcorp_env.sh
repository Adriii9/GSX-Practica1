# /etc/profile.d/greendevcorp_env.sh
# Configuració d'entorn per a l'equip GreenDevCorp (Week 4)

if id -Gn | grep -q "\bgreendevcorp\b"; then
    # 1. Personalització del PATH
    export PATH="$PATH:/home/greendevcorp/bin"

    # 2. Àlies comuns per a l'equip
    alias ll='ls -lah'
    alias work='cd /home/greendevcorp/shared'
    alias logs='tail -f /opt/admin/logs/backup.log'

    # 3. Missatge de benvinguda (Síncron i segur)
    if [[ $- == *i* ]]; then
        echo -e "\n\033[1;32m*****************************************************\033[0m"
        echo -e "\033[1;32m  BENVINGUT, $(whoami)! Ets a l'entorn GreenDevCorp.\033[0m"
        echo -e "\033[1;32m  Usa 'work' per anar al directori compartit.        \033[0m"
        echo -e "\033[1;32m*****************************************************\033[0m\n"
    fi
fi
