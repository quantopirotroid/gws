#!/bin/bash
#
#vars&functions
#
WRONG_INPUT='yourrrmama.txt'


#все салоны
salonAll(){
LIST=$(mysql -h 10.0.0.1 -Bse "SELECT int_ip FROM complete WHERE s_num REGEXP '^[0-9.]'" -D rbt)
echo "Список адресов:
${LIST}"
}


#интервал
salonRegexp(){
echo "
Введите интервал.
с:"
read from_num
echo "по:"
read to_num
LIST=$(mysql -h 10.0.0.1 -Bse "SELECT int_ip FROM complete WHERE s_num >= ${from_num} AND s_num <= ${to_num}" -D rbt)
echo "Список адресов:
${LIST}"
}


#список
salonList(){
echo "
Введите список салонов:"
read list
list=$(echo "${list}" | sed 's/ /,/g')
LIST=$(mysql -h 10.0.0.1 -Bse "SELECT int_ip FROM complete WHERE s_num IN(${list})" -D rbt)
echo "Список адресов:
${LIST}"
}


#SQL
SQList(){
echo 'Введите SQL запрос, например: SELECT int_ip FROM complete WHERE s_num REGEXP "^[0-9.]"'
read query
LIST=$(mysql -h 10.0.0.1 -Bse "${query}" -D rbt)
echo "Список адресов:
${LIST}"
}


#
#interact
#
echo "Выберите салоны для работы:
1 - все салоны
2 - интервал номеров салонов
3 - некторые салоны по списку
4 - прямой ввод SQL запроса
0 - выход"
read -sn1 input
interactList() {
case ${input} in
1	) salonAll;;
2	) salonRegexp;;
3	) salonList;;
4	) SQList;;
0	) exit 0;;
*	) cat ${WRONG_INPUT}; exit 1;;
esac
}


#
#working
#
interactList
echo "Введите команду для выполнения на удалённых машинах."\
     "Если хотите использовать шаблоны, то введите '--tl'"\
     "для вывода списка шаблонов"
read action
if [[ '--tl' != $action ]];then
    echo "Будут ли файлы для копирования? y/n"
    read -sn1 choice
    case ${choice} in
    n      ) for host in ${LIST}
             do
                echo "Начинаю работы с ${host}"
                ssh ${host} "${action}"
             done;;
    y      ) echo "Укажите файл для копирования."
             read source_file
             echo "А теперь укажите директорию на удалённой машине, в которую копировать файл."
             read dst_folder
             for host in ${LIST}
             do
                echo "Начинаю работы с ${host}"
                scp ${source_file} ${host}:${dst_folder}
                ssh ${host} "${action}"
             done;;
    *      ) cat ${WRONG_INPUT} && exit 1;;
    esac
elif [[ '--tl' == $action ]];then
    work_directory=$(dirname "${0}")
    nil=1
    for template in $(ls $work_directory/templates);do
        echo "$nil) $template"
        nil=$(($nil+1))
    done
    echo "0) выход"
    read template_number
    echo\
    "case $template_number in
    $(nil=1
    for template in $(ls $work_directory/templates);do
        echo "$nil ) source $work_directory/templates/$template;;"
        nil=$(($nil+1))
    done)
    0 ) exit 0;;
    * ) cat ${WRONG_INPUT} && exit 1;;
    esac" > $work_directory/tmp/dinamic_menu
    source $work_directory/tmp/dinamic_menu
    rm $work_directory/tmp/dinamic_menu
fi

