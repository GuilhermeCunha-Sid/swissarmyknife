#!/bin/bash

read -p "Fazer coleta de dados s/n?" opc

if [[ $opc = "s" || $opc = "S" ]]
then
    read -p "Digite ip ou dominio:" host
    echo ""
    sudo whois $host | grep "inetnum:\|aut-num:\|ownerid:\|responsible:\|country:\|inetrev:\|nserver:\|person:\|e-mail:"

    echo "--------------------------------------------------------------------------"
    echo "Mapeando Regsitros do Dominio..."
    lista=['soa','a','aaaa','ns','cname','mx','ptr','hinfo','txt']
    echo "Executando DNS Scan com os registros: ${lista[*]}"
    echo ""

    hostmaster=$(host -t 'soa' $host | cut -d " " -f6)
    ip=$(host -t 'a' $host | cut -d " " -f4)
    ipv6=$(host -t 'aaaa' $host | cut -d " " -f5)
    ns=$(host -t 'ns' $host | cut -d " " -f4)
    cname=$(host -t 'cname' $host)
    mx=$(host -t 'mx' $host | cut -d " " -f7)
    ptr=$(host -t 'ptr' $host)
    hinfo=$(host -t 'hinfo' $host | grep "information")
    txt=$(host -t 'txt' $host | cut -d "\"" -f2)

    echo "HostMaser         : $hostmaster"
    echo "HostMaser         : $hostmaster" >> $host.log

    echo "Ip                : $ip"
    echo "Ip                : $ip" >> $host.log

    echo "IpV6              : $ipv6"
    echo "IpV6              : $ipv6" >> $host.log

    for name in $ns
    do
        echo "Name Server      : $name"
        echo "Name Server      : $name" >> $host.log
    done
    
    echo "CName             : $cname"
    echo "CName             : $cname" >> $host.log
    
    for mail in $mx
    do
        echo "Mail Exchange     : $mail"
        echo "Mail Exchange     : $mail" >> $host.log
    done

    echo "PTR               : $ptr"
    echo "PTR               : $ptr" >> $host.log

    echo "Host Information  : $hinfo"
    echo "Host Information  : $hinfo" >> $host.log

    for text in $txt
    do
        echo "Any text          : $text"
        echo "Any text          : $text" >> $host.log
    done


    read -p "Executar transferencia de zona s/n?" opc

    if [[ $opc = "s" || $opc = "S" ]]
    then
        for name in $ns
        do
            host -l -a $host $name 
            host -l -a $host $name >> $host.log
        done
    fi
fi
