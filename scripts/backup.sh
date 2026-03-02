#!/bin/bash
BACKUP_DIR="/ruta/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup de BD
docker exec proyecto_mysql mysqldump -u root tiendaplazachina | gzip > $BACKUP_DIR/tiendaplazachina_$DATE.sql.gz

# Mantener solo últimos 7 backups
find $BACKUP_DIR -name "tiendaplazachina_*.sql.gz" -mtime +7 -delete