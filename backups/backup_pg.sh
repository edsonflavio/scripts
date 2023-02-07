#!/bin/bash
#Script para backup do banco de dados PostgreSQL
#Autor: Edson Flavio de Souza
#Versao: 0.1


#Diretorio base para os backups do banco de dados
BASE_DIR=${1:-"/pg_backups/backup_diario"}
#configura a variavel onde ser armazenado o backup
BACKUP_DIR=${2:-$(date +%Y%m%d)}
#senha do banco de dados
#PASS=$(cat $BASE_DIR/.pg_password)

gera_log () {
        echo "$(date '+%d/%m/%Y %T') ${1}" >> $ARQ_LOGS
        if [ $? != 0 ]; then
                echo "$(date '+%d/%m/%Y %T') Erro ao inserir log no arquivo $ARQ_LOGS - VERIFIQUE!!!"
                exit 1
        fi
}

existe_dir()
{
        if [ -d $BASE_DIR/$BACKUP_DIR ]; then
                existe=0;
        else
                existe=1;
        fi
        return $existe;
}

verifica_estrutura()
{
        local BASE=${1:-$BASE_DIR};
        local DIR=${2:-$BACKUP_DIR)};
        dir_ok=1;
        if existe_dir; then
                gera_log "Diretorio $DIR existe, removendo-o!!"
                rm -rf $BASE/$DIR
                gera_log "Diretorio existente removido"
                gera_log "Criando diretorio $DIR para o backup de hoje"
                mkdir -p $BASE/$DIR
                gera_log "Diretorio $DIR criado"
                dir_ok=0
        else
                gera_log "Diretorio $DIR nao existe e sera criado"
                mkdir -p $BASE/$DIR
                gera_log "Diretorio $DIR criado"
                dir_ok=0
        fi
        return $dir_ok
}
executa_backup()
{
        local backup_ok=1
        pg_basebackup -D $BASE_DIR/$BACKUP_DIR  -P -Ft -z -Xs -h localhost -p 5432 -U postgres -w
        if [ $? -eq 0]; then
                backup_ok=0
        else
                backup_ok=1
        fi
        return $backup_ok
}

#Executando o backup
#Iniciamos o processo criando o diretorio para o backup
#Se o diretorio existir entao executamos o backup, senao sai fora.
ARQ_LOGS=$BASE_DIR/backup.$BACKUP_DIR.log
gera_log "Iniciando o backup do dia $BACKUP_DIR"
verifica_estrutura $BASE_DIR $BACKUP_DIR
if [ $? -eq  0 ]; then
        gera_log "Executando o backup base para o diretorio $BASE_DIR/$BACKUP_DIR"
        if executa_backup; then
		gera_log "Backup efetuado com sucesso para o diretorio $BASE_DIR/$BACKUP_DIR"
        else
		gera_log "Nao foi possivel efetuar o backup para o dia $BACKUP_DIR, verifique!!!"
	fi
else
        gera_log "Estrutura de diretorios para o backup nao esta preparada, verifique!!!"
        exit 1;
fi
