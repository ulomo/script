#!/bin/zsh


#clear screen and give a choice to choose,yes to catch a new file 
clear

#go to the script dir and scratch all of information to a tmp file
realdir=`whereis sslink | awk -F ":" '{print $2}' | xargs ls -l | awk -F ">" '{print $2}' | xargs dirname`
cd $realdir

#product the command line to a list
if [[ -e ss.html ]];then
    echo -e	 "\033[32m <<<<<<<<<< the file exist, do you wanna to get a new one?(default no) >>>>>>>>>>  \033[0m"
    echo -e -n	 "\033[32m >>>>>>>>>>  \033[0m"
    read answer
    if [[ $answer == 'yes' ]];then
        cat ./ss.html | grep  '<td align=' | grep -v 'class' | grep -E '^<' | awk -F'>|<' '{print $3}' > ss.hl
    fi
elif [[ ! -e ss.html ]];then
    echo -e	 "\033[32m <<<<<<<<<< the file doesn't exist,you need to get it >>>>>>>>>>   \033[0m"
    echo -e -n	 "\033[32m >>>>>>>>>>  \033[0m"
    exit
fi

echo -e	 "\033[32m <<<<<<<<<< do you wanna to retest and get the faster one?(default no) >>>>>>>>>>  \033[0m"
echo -e -n	 "\033[32m >>>>>>>>>>  \033[0m"
read choose
if [[ $choose == "yes" ]];then
    :>ss.tmp && :>ss.final
    i=1 && j=`cat ss.hl | wc -l`
    while [[ $j -gt 0 ]]
    do
        s=`sed -n ''"$i"'p' ss.hl ` && ((i++))
        p=`sed -n ''"$i"'p' ss.hl ` && ((i++))
        k=`sed -n ''"$i"'p' ss.hl ` && ((i++))
        m=`sed -n ''"$i"'p' ss.hl ` && ((i++))
        ss="sslocal -s $s -p $p -k $k -m $m -l 1080"

        eval $ss 2>/dev/null 2>&1 &
        sleep 2
        tm=`timeout 4 proxychains -q curl -s -w "%{time_total}\n" -o /dev/null www.google.com`

        if [[ $tm -gt 0 && $tm -lt 4 ]];then
            ss="$tm sslocal -s $s -p $p -k $k -m $m -l 1080"
            echo $ss >> ss.tmp
        fi 
        j=$((j-4))
        killall sslocal 2>/dev/null
        killall proxychains 2>/dev/null
    done
    sort -g ss.tmp | awk '{$1="";print $0}' > ss.final
else
    cat ss.final
    total=`cat ss.final | wc -l`
    while :
    do
        echo -e	 "\033[32m <<<<<<<<<< choose the one you wanna to connect or the app to be proxyed >>>>>>>>>> \033[0m"
        echo -e -n	 "\033[32m >>>>>>>>>>  \033[0m"
        read info
        if [[ $info -gt 0 && $info -le $total ]];then
            command=`sed -n ''$info'p' ss.final`
            killall sslocal 2>/dev/null
            eval $command >/dev/null 2>&1 &
        elif [[ $info == 'exit' ]];then
            exit
        elif [[ $info == 'clear' ]];then
            clear
        elif [[ $info == 'menu' ]];then
            cat ss.final
        elif [[ $info -gt $total ]];then
            echo "total:$total,can not greater than $total"
        else
            which $info >/dev/null 2>&1
            if [[ $? == 0 ]];then
                proxychains -q $info > /dev/null 2>&1 &
            fi
        fi
    done
fi 

