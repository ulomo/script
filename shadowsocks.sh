#!/bin/zsh

#define a function to print autoline
function line()
{
    unset i
    while [[ $i -le $COLUMNS ]]
    do
        echo -e -n "\e[32m.\e[0m"
        ((i++))
        sleep 0.01
    done
}

#clear screen and give a choice to choose,yes to catch a new file 
clear
echo -e -n	 "\033[32m do you wanna to scratch another new vpn file ? yes or no :  \033[0m"
read wanna

#go to the script dir and scratch all of information to a tmp file
realdir=`whereis sslink | awk -F ":" '{print $2}' | xargs ls -l | awk -F ">" '{print $2}' | xargs dirname`
cd $realdir
if [[ $wanna == "yes" ]];then
    curl https://www.youneed.win/free-ss | grep  '<td align=' | grep -v 'class' | grep -E '^<' | awk -F'>|<' '{print $3}' > account.txt
fi

#product the command line to a list
i=1
j=`cat  account.txt | wc -l`
while [[ $j -gt 0 ]]
do
    s=`sed -n ''"$i"'p' account.txt `
    ((i++))
    p=`sed -n ''"$i"'p' account.txt `
    ((i++))
    k=`sed -n ''"$i"'p' account.txt `
    ((i++))
    m=`sed -n ''"$i"'p' account.txt `
    ((i++))
    ss="sslocal -s $s -p $p -k $k -m $m -l 1080"
    sum[$i]=${ss}
    ((j--))
done

#print all of the commands for ur choice,the one u choose will work in bg
select m in ${sum[*]}
do
    for (( k=1;k<${#sum[@]};k++ ))
    do
        case $m in 
            ${sum[k]})
                id=`ps -ef | grep sslocal | grep -v grep | awk '{print $2}'`
                if [[ $id -gt 0 ]];then
                    killall sslocal 
                    echo -e "\033[32m the sslocal process has been killed successfully \033[0m"
                fi
                eval $m 2>/dev/null 1>&2 &
                line
                ;;
        esac
    done
done
