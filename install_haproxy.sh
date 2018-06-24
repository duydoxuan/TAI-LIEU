#!/bin/bash

function install_default()
{
    check=$(haproxy -v | grep -i -o "ha-proxy version ") # check da co cai haproxy chua
if [ -z "$check" ]; then # neu chua , chuoi rong
    sudo add-apt-repository ppa:vbernat/haproxy > $PWD/version.txt # check latest version hien nay
	version=$(cat version.txt | sed -n '8 p' | grep -o "haproxy-1.[0-9]" |tr -d "', :") # lay ra chuoi latest version =1.8
	# cai latest version bang apt
    sudo add-apt-repository ppa:vbernat/$version -y
    sudo apt-get update -y
    sudo apt-get install haproxy -y
 #config port
    if [ -n "$2" ]; then # neu argument $2 co ton tai
    	sudo sed -ri '/504.http/a frontend public \nbind *:'"$2"'' /etc/haproxy/haproxy.cfg 

    else # neu ko ton tai argument $2 thi mac dinh port 80
        sudo sed -ri '/504.http/a frontend public \nbind *:80' /etc/haproxy/haproxy.cfg
    fi
else 
	    echo	"HAProxy is running. Backing up now..." && sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
        echo    "Stopping HAProxy"  && sudo service haproxy stop 
        echo    "* Stopping haproxy" 
        echo    "haproxy"
        sudo add-apt-repository ppa:vbernat/haproxy > $PWD/version.txt 
	    version=$(cat version.txt | sed -n '8 p' | grep -o "haproxy-1.[0-9]" |tr -d "', :")
	    shortversion=$(echo $version | grep -o ...$) # lay 3 phan tu cuoi cung trong chuoi "haproxy-1.8" = 1.8
	    mkdir -p download
	    cd download
    for value in {25..1} #download tag tu 25 giam xuong 1 , thoat vong lap khi reach tag ton` tai lon' nhat'
    do
    	wget -q https://www.haproxy.org/download/$shortversion/src/haproxy-$shortversion.$value.tar.gz
        if [ -f  haproxy-$shortversion.$value.tar.gz ]; then # check xem neu da~ download thi thoat loop
        	break
        	fi
    done

# compile source
    sudo tar xzf haproxy-$shortversion.$value.tar.gz
    cd haproxy-$shortversion.$value
    sudo apt-get install build-essential -y
    sudo apt-get install libssl-dev -y
    sudo apt-get install zlib1g-dev -y
    sudo apt-get install virt-what -y
    sudo apt-get install libpcre3-dev -y
    sudo make TARGET=linux2628 USE_PCRE=1 USE_PCRE_JIT=1 USE_OPENSSL=1 USE_ZLIB=1 USE_REGPARM=1
    sudo make install
    # check version
    checkversion=$(haproxy -v | grep -i -o "ha-proxy version $shortversion.$value " )
    if [ "$checkversion" = haproxy-$shortversion.$value ]; then
    	echo " haproxy-$shortversion.$value "
    else
        echo " failed to build haproxy-$shortversion.$value "
    fi
fi
}

function install_specify()
{
	if [ "$1"="-haproxy" ]; then
	    short=$( echo "$4" | grep -o ^... )
		echo	"HAProxy is running. Backing up now..." && sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
        echo    "Stopping HAProxy"  && sudo service haproxy stop 
        echo    "* Stopping haproxy" 
        echo    "haproxy"
		cd download
		sudo wget -q https://www.haproxy.org/download/$short/src/haproxy-$4.tar.gz
	    tar xzf haproxy-$4.tar.gz
		cd haproxy-"$4"
		sudo apt-get install build-essential -y
        sudo apt-get install libssl-dev -y
        sudo apt-get install zlib1g-dev -y
        sudo apt-get install virt-what -y
        sudo apt-get install libpcre3-dev -y
        sudo make TARGET=linux2628 USE_PCRE=1 USE_PCRE_JIT=1 USE_OPENSSL=1 USE_ZLIB=1 USE_REGPARM=1
        sudo make install
    elif [[ "$1"="-version" ]]; then
    	short=$(echo "$2" | grep -o ^...)
    	echo	"HAProxy is running. Backing up now..." && sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
        echo    "Stopping HAProxy"  && sudo service haproxy stop 
        echo    "* Stopping haproxy" 
        echo    "haproxy"
    	cd download
		sudo wget -q https://www.haproxy.org/download/$short/src/haproxy-$2.tar.gz
    	tar xzf haproxy-$2.tar.gz
		cd haproxy-$2
		sudo apt-get install build-essential -y
        sudo apt-get install libssl-dev -y
        sudo apt-get install zlib1g-dev -y
        sudo apt-get install virt-what -y
        sudo apt-get install libpcre3-dev -y
        sudo make TARGET=linux2628 USE_PCRE=1 USE_PCRE_JIT=1 USE_OPENSSL=1 USE_ZLIB=1 USE_REGPARM=1
        sudo make install
    fi
	
}



if [ -z "$1" -o "$1" = "-help" -o "$1" = "-h" ]; then #neu argument $1 = null or -h or -help thi show usage
	echo "Usage:"
    echo "./install_haproxy.sh [OPTIONS]"
    echo "OPTIONS:"
    echo "-help, -h, -?	Display usage"
    echo "-httpport		Specify your port on which your proxy is binded (between 80 and 9999), default is 80"
    echo "-version 		Set your installation version of HAProxy, default is latest version"
elif [ "$1" = "-httpport" -a -n "$2" -a "$3" = "-version" -a -n "$4" ]; then # neu $1 =-httpport va $2 co ton tai va $3 = -version va $4 co ton tai
  install_specify "$1" "$2" "$3" "$4"
elif [ "$1" = "-version" -a -n "$2" -a "$3" = "-httpport" -a -n "$4" ]; then
  echo "2" 
elif [ "$1" = "-httpport" ]; then #neu $1=-httpport thi goi funtion install latest version 
  install_default
elif [ "$1" = "-version" ]; then #
  echo "1"
fi



