# 5. Comprovació dels Serveis de la Week 2 (NOU)
echo -e "\n${VERD}--- Verificant Serveis (Week 2) ---${NC}"

# Verificar Nginx
echo -n "Verificant estat de Nginx... "
if systemctl is-active --quiet nginx; then
    echo -e "${VERD}[ACTIU]${NC}"
else
    echo -e "${VERMELL}[INACTIU]${NC}"
fi

# Verificar Resiliència de Nginx (comprova si existeix l'override)
echo -n "Verificant resiliència de Nginx (Override)... "
if [ -f "/etc/systemd/system/nginx.service.d/override.conf" ]; then
    echo -e "${VERD}[CONFIGURAT]${NC}"
else
    echo -e "${VERMELL}[FALTA OVERRIDE]${NC}"
fi

# Verificar Timer del Backup
echo -n "Verificant automatització del Backup (Timer)... "
if systemctl is-active --quiet backup-gsx-24h.timer && systemctl is-active --quiet backup-gsx-72h.timer && systemctl is-active --quiet backup-gsx-7D.timer; then
    echo -e "${VERD}[PROGRAMAT]${NC}"
else
    echo -e "${VERMELL}[INACTIU]${NC}" 
fi
