#!/bin/bash
#Script para rotacionar os backups no esquema GFS
#Autor: Edson Flavio de Souza
#Versao: 0.1

#Diretorio base para os backups do banco de dados
BASE_DIR=${1:-"/var/lib/docker/volumes/idelageamb-dbbackups/_data/backup_diario"}
#configura a variavel onde ser armazenado o backup
#esta varíavel é preenchida de acordo com o parâmentro nro 2 passado ao script no crontab
#valores esperados são
#backup_diario
#backup_semanal
#backup_mensal
BACKUP_TIPO=${2?"A variável BACKUP_TIPO é obrigatório no segundo parâmetro"}
LOG_DATA=$(date '+%Y%m%d')

gera_log () {
        echo "$(date '+%d/%m/%Y %T') ${1}" >> $ARQ_LOGS
        if [ $? != 0 ]; then
                echo "$(date '+%d/%m/%Y %T') Erro ao inserir log no arquivo $ARQ_LOGS - VERIFIQUE!!!"
                exit 1
        fi
}

checa_backup_tipo(){
        local tipo_backup=${1?"backup_diario"}
        local diario=1
        local semanal=1
        local mensal=1
        local retorno=1

        case $tipo_backup in
                backup_diario)
                        BACKUP_DIR=$(date -d '-8 day' '+%Y%m%d')
                        diario=0
                        return $diario
                        ;;
                backup_semanal)
                        BACKUP_DIR=$(date -d '-1 month' '+%Y%b_%U')
                        semanal=0
                        return $semanal
                        ;;
                backup_mensal)
                        BACKUP_DIR=$(date -d '-13 month' '+%Y%m')
                        mensal=0
                        return $mensal
                        ;;
                *)
                        echo "Tipo de Backup - $tipo_backup não definido!!!"
                        return $retorno
                        ;;
        esac
}
existe_dir()
{
        local existe=1
        if [ -d $BASE_DIR/$BACKUP_DIR ]; then
                existe=0
                ARQ_LOGS="$BASE_DIR/remove_backup.$LOG_DATA.log"
        else
                ARQ_LOGS="$BASE_DIR/remove_backup.$LOG_DATA.log"
                existe=1
        fi
        return $existe
}

remove_backup()
{
        local BASE=${1:-$BASE_DIR}
        local DIR=${2:-$BACKUP_DIR}
        local removido=1
        if existe_dir; then
                gera_log "Parametros recebido para variavel BASE  $BASE e variavel DIR $DIR "
                gera_log "Diretorio $DIR existe e iremos remove-lo!! "
                gera_log "De acordo com a politica sera mantido apenas um backup "
                gera_log "Iniciando o procedimento de remocao do diretorio $DIR "
                gera_log "Mudando para o diretorio $BASE "
                cd $BASE
                gera_log "Removendo o diretório $DIR no diretorio $BASE "
                rm -rf $DIR
                rm -f remove_backup.$DIR.log
                rm -f backup.$DIR.log
                if [ $? -eq 0 ];then
                        gera_log "Diretorio $DIR removido em $BASE !!!"
                        removido=0
                else
                        gera_log "Nao foi possivel remover o diretorio $DIR em $BASE"
                        removido=1
                fi
                cd -
        else
                gera_log "Diretorio $BASE/$DIR ainda não foi criado!!"
                removido=1
        fi
        return $removido
}

if checa_backup_tipo $BACKUP_TIPO; then
        remove_backup $BASE_DIR $BACKUP_DIR
        if [ $? -eq 0 ]; then
                gera_log "Backup removido com sucesso!!!"
        else
                gera_log "Diretorio $BASE_DIR/$BACKUP_DIR não existe, ou"
                gera_log "não foi possível remover o Backup em $BASE_DIR/$BACKUP_DIR"
        fi
else
        echo "Tipo de Backup não definido - Verifique!!"
fi
