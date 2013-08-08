#!/bin/bash

echo "current $$"
function kill_process_by_name()
{
    local name sum process_id kill_id
    name="$1"
    sum=`ps -ef | grep $name | grep -v "grep" | wc -l`
    sleep 1
    if [ $sum -gt 1 ];then
        process_id=`ps -ef | grep $name | grep -v "grep" | awk '{print $2}'`
        for kill_id in $process_id;do
                if [ $$ -eq $kill_id ];then
                        echo '????'$name'??????'
                else
                        ps aux | awk '{print $2 }' | grep -q $kill_id 2> /dev/null

                        if [ $? -eq 0 ];then
                                kill $kill_id
                        fi
                fi
        done
   fi
}

kill_process_by_name "$0"
kill_process_by_name "inotifywait"
sleep 1

#f1
sync[0]='/w/apsqwezpre/www/a/,f1.appshare.cn,apsaudio'
sync[1]='/w/apsqwezpre/www/b/,f1.appshare.cn,apsaudioimg'
sync[2]='/w/apsqwezpre/www/data/attachment/story/,f1.appshare.cn,apsstory'
sync[3]='/w/apsqwezpre/www/static/,f1.appshare.cn,apsstatic'
sync[4]='/w/apsqwezpre/www/uc_server/data/avatar/,f1.appshare.cn,apsavatar'

#f2
sync[5]='/w/apsqwezpre/www/a/,f2.appshare.cn,apsaudio'
sync[6]='/w/apsqwezpre/www/b/,f2.appshare.cn,apsaudioimg'
sync[7]='/w/apsqwezpre/www/data/attachment/story/,f2.appshare.cn,apsstory'
sync[8]='/w/apsqwezpre/www/static/,f2.appshare.cn,apsstatic'
sync[9]='/w/apsqwezpre/www/uc_server/data/avatar/,f2.appshare.cn,apsavatar'

#f4
sync[10]='/w/apsqwezpre/www/a/,f4.appshare.cn,apsaudio'
sync[11]='/w/apsqwezpre/www/b/,f4.appshare.cn,apsaudioimg'
sync[12]='/w/apsqwezpre/www/data/attachment/story/,f4.appshare.cn,apsstory'
sync[13]='/w/apsqwezpre/www/static/,f4.appshare.cn,apsstatic'
sync[14]='/w/apsqwezpre/www/uc_server/data/avatar/,f4.appshare.cn,apsavatar'

#f5
sync[15]='/w/apsqwezpre/www/a/,f5.appshare.cn,apsaudio'
sync[16]='/w/apsqwezpre/www/b/,f5.appshare.cn,apsaudioimg'
sync[17]='/w/apsqwezpre/www/data/attachment/story/,f5.appshare.cn,apsstory'
sync[18]='/w/apsqwezpre/www/static/,f5.appshare.cn,apsstatic'
sync[19]='/w/apsqwezpre/www/uc_server/data/avatar/,f5.appshare.cn,apsavatar'

for item in ${sync[@]}; do

dir=`echo $item | awk -F"," '{print $1}'`
host=`echo $item | awk -F"," '{print $2}'`
module=`echo $item | awk -F"," '{print $3}'`

logfile=/var/log/rsync/sync_`date '+%Y%m%d'`.log
exclude_file=/w/bin/exclude_list

inotifywait -mrq --exclude='.*\.swp' --timefmt '%d/%m/%y %H:%M' --format  '%T %w%f %e' \
 --event CLOSE_WRITE,create,move,delete  $dir | while read  date time file event
        do
                action="[$time]$host : $event-$file "
                cmd=""
                case $event in
                        MODIFY|CREATE|MOVE|MODIFY,ISDIR|CREATE,ISDIR|MODIFY,ISDIR)
                                if [ "${file: -4}" != '4913' ]  && [ "${file: -1}" != '~' ]; then
                                        cmd="rsync -az --exclude='*' --exclude-from=$exclude_file --include=$file $dir apsbackup@$host::$module --password-file=/etc/rsync/syncdata_client.pas"
                                fi
                                ;;

                        MOVED_FROM|MOVED_FROM,ISDIR|DELETE|DELETE,ISDIR)
                                if [ "${file: -4}" != '4913' ]  && [ "${file: -1}" != '~' ]; then
                                        cmd="rsync -az --exclude='*' --exclude-from=$exclude_file --delete --include=$file $dir apsbackup@$host::$module --password-file=/etc/rsync/syncdata_client.pas"
                                fi
                                ;;

                esac

                if [ -n "$cmd" ];then
                        res=`$cmd 2>&1`
                        if [ $? -ne 0 ];then
                                echo "$action$res" >> $logfile
                        fi
                fi
        done &
done