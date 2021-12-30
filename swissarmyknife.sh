#!/bin/bash


progName="Swiss Army Knife"
progOwner="Guilherme Cunha"
progVersion="1.0.0"

echo "Tool         : $progName"
echo "Powered by   : $progOwner"
echo "Version      : $progVersion"
echo ""

read -p "Iniciar Information Gathering [s/N]?" opc

if [[ $opc = "s" || $opc = "S" ]]
then
    read -p "Digite ip ou dominio:" host

    echo "--------------------------------------------------------------------------"
    echo "Mapeando Regsitros do Dominio..."
    lista=['soa','a','aaaa','ns','cname','mx','ptr','hinfo','txt']
    echo "Executando DNS Scan com os registros: ${lista[*]}"
    echo ""

    hostmaster=$(host -t 'soa' $host | grep -o "[a-Z0-9.]*$host[.a-Z0-9]*")
    ip=$(host -t 'a' $host | grep -o "[a-Z0-9.]*$host[.a-Z0-9]*.\|[0-9].*")
    ipv6=$(host -t 'aaaa' $host)
    ns=$(host -t 'ns' $host | grep -o "[a-Z0-9.]*.$host")
    cname=$(host -t 'cname' $host)
    mx=$(host -t 'mx' $host | cut -d " " -f7 | cut -d "." -f1,2,3,4)
    ptr=$(host -t 'ptr' $host)
    hinfo=$(host -t 'hinfo' $host)
    vspf=$(host -t 'txt' $host | grep -o "[\"]v=spf[a-Z0-9] include:.*[a-Z0-9][\"]")
    
    let i=0
    for dns in $hostmaster
    do
        echo "\"hostmaster$[i=i+1]\":\"$dns\"," >> $host.log
    done

    domain=$(echo $ip | cut -d " " -f1)
    dnsaddr=$(echo $ip | cut -d " " -f2)

    echo "\"dns\":\"$domain\"," >> $host.log
    echo "\"ip\":\"$dnsaddr\"," >> $host.log

    if [[ "$ipv6" == "$host has no AAAA record" ]]
    then
        echo "\"ipv6\":\"NoIpv6\"," >> $host.log
    else
        ipv6=$(echo $ipv6 | cut -d " " -f5)
        echo "\"ipv6\":\"$ipv6\"," >> $host.log
    fi

    let i=0
    for name in $ns
    do
        echo "\"NameServer$[i=i+1]\":\"$name\"," >> $host.log
    done

    let i=0
    for mail in $mx
    do
        echo "\"MailExchange$[i=i+1]\":\"$mail\"," >> $host.log
    done


    if [[ "$ptr" != "$host has no PTR record" ]]
    then
        echo "\"Ptr\":\"$ptr\"," >> $host.log
    fi

    if [[ "$hinfo" != "$host has no HINFO record" ]]
    then
        hinfo=$(host -t 'hinfo' $host | sed 's/\"//g' | cut -d " " -f4-)
        echo "\"Hinfo\":\"$hinfo\"," >> $host.log
    fi


    echo "\"VSFP\":$vspf," >> $host.log
    host -t 'txt' $host | grep -o "[\"].*[\"]" | sed 's/^/"Text":/g' | sed 's/$/,/g' >> $host.log

    let i=0    
    for nameserver in $ns
    do
        dns=$(host -l -a $host $nameserver | grep -o  "[a-z0-9]*[.]businesscorp.com.br" | sort -u | sed 's/^/"/g' | sed 's/$/",/g')
        for address in $dns
        do
            echo "\"dns$[i=i+1]\":$address" >> $host.log
        done
    done


    
    jparser=$(cat $host.log | sed '1i{' | sed '$a}')
    echo $jparser > $host.log
fi
