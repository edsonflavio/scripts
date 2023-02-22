Estes scripts são utilizados para gerenciar backup e rotação dos backups do PostgreSQL
no esquema diario, semanal, mensal em ambiente docker

Os scripts rodam no crontab, com a seguinte configuração

SHELL=/bin/bash
DATA_BACKUP=$(date +%Y%m%d)
DATA_BACKUP_SEM=$(LC_TIME=C date +%Y%b_%U)
DATA_BACKUP_MEN=$(date +%Y%m)
DIR_SCRIPTS="/var/lib/docker/volumes/NomedoContainer/_data"
DIR_DADOS="/var/lib/docker/volumes/NomedoContainer/_data"

#Remove os backup antigos
10 1  * * *  $DIR_SCRIPTS/remove_backup.sh $DIR_DADOS/backup_diario  backup_diario  > $DIR_SCRIPTS/remocao_diaria.log
10 1  * * 7    $DIR_SCRIPTS/remove_backup.sh $DIR_DADOS/backup_semanal backup_semanal > $DIR_SCRIPTS/remocao_diaria.log
10 1  1 * *    $DIR_SCRIPTS/remove_backup.sh $DIR_DADOS/backup_mensal  backup_mensal  > $DIR_SCRIPTS/remocao_diaria.log

#Executa os backups
10 0 * * 1-6 docker exec -i NomeContainer su - postgres -c "/pg_backups/backup_pg.sh /pg_backups/backup_diario  $DATA_BACKUP"     > $DIR_SCRIPTS/backup_diario.log
10 0 * * 7   docker exec -i NomeContainer su - postgres -c "/pg_backups/backup_pg.sh /pg_backups/backup_semanal $DATA_BACKUP_SEM" > $DIR_SCRIPTS/backup_semanal.log
10 0 1 * *   docker exec -i NomeContainer su - postgres -c "/pg_backups/backup_pg.sh /pg_backups/backup_mensal  $DATA_BACKUP_MEN" > $DIR_SCRIPTS/backup_mensal.log


Mantém os backups diarios por 8 dias
Mantém os backups semanais por 1 mês
Mantém os backups mensais por 1 ano

