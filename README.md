> 一如既往的，打开这个命令，结果发现里面的命令都乱了。想着一定是网页数据发现了变化，有点懒，今天才去修改脚本。确实是网页结构调整导致的。所以修改之后的脚本如下，显得更加简洁了。

- 这一切可行的基础还是要感想提供数据的沐风了，[获取数据的网址](https://www.youneed.win/free-ss)

- 当然了这个脚本叫`sslink`，最好是取这个名字，因为别的名字那还要改脚本

- 配置过程：

  - 将代码复制下来，然后随便取个命令比如叫`shadowsocks`，然后将代码复制进去

  - 给脚本执行权限

    ```shell
    chmod u+x ./shadowsocks
    ```

  - 为了可以使用命令启动这个脚本，在`~/.local/bin`下建一个软链接

    ```shell
    ln -s 脚本位置 sslink
    ```

  - 然后就可以使用`sslink`启动这个脚本了。如果你没有zsh的话，将脚本第一行替换为

    ```shell
    #!/bin/bash
    ```

---

脚本如下：

```shell
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
```


