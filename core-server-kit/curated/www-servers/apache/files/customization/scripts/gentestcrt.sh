#!/bin/sh
##
##  gentestcrt -- Create self-signed test certificate
##  (C) 2001 Jean-Michel Dault <jmdault@mandrakesoft.com> and Mandrakesoft
##  Based on cca.sh script by Ralf S. Engelschall
##

#   external tools
openssl="/usr/bin/openssl"

#   some optional terminal sequences
case $TERM in
    xterm|xterm*|vt220|vt220*)
        T_MD=`echo dummy | awk '{ printf("%c%c%c%c", 27, 91, 49, 109); }'`
        T_ME=`echo dummy | awk '{ printf("%c%c%c", 27, 91, 109); }'`
        ;;
    vt100|vt100*)
        T_MD=`echo dummy | awk '{ printf("%c%c%c%c%c%c", 27, 91, 49, 109, 0, 0); }'`
        T_ME=`echo dummy | awk '{ printf("%c%c%c%c%c", 27, 91, 109, 0, 0); }'`
        ;;
    default)
        T_MD=''
        T_ME=''
        ;;
esac

#   find some random files
#   (do not use /dev/random here, because this device 
#   doesn't work as expected on all platforms)
randfiles=''
for file in /var/log/messages /var/adm/messages \
            /kernel /vmunix /vmlinuz \
            /etc/hosts /etc/resolv.conf; do
    if [ -f $file ]; then
        if [ ".$randfiles" = . ]; then
            randfiles="$file"
        else
            randfiles="${randfiles}:$file"
        fi
    fi
done


echo "${T_MD}maketestcrt -- Create self-signed test certificate${T_ME}"
echo "(C) 2001 Jean-Michel Dault <jmdault@mandrakesoft.com> and Mandrakesoft"
echo "Based on cca.sh script by Ralf S. Engelschall"
echo ""

grep -q -s DUMMY server.crt && mv server.crt server.crt.dummy
grep -q -s DUMMY server.key && mv server.key server.key.dummy

echo ""
echo ""

if [ ! -e ./server.crt -a ! -e ./server.key ];then 
	echo "Will create server.key and server.crt in `pwd`"
else
	echo "server.key and server.crt already exist, dying"
	exit
fi

echo ""


mkdir -p /tmp/tmpssl-$$
pushd /tmp/tmpssl-$$ > /dev/null


    echo "${T_MD}INITIALIZATION${T_ME}"

    echo ""
    echo "${T_MD}Generating custom Certificate Authority (CA)${T_ME}"
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 1: Generating RSA private key for CA (1024 bit)${T_ME}"
    cp /dev/null ca.rnd
    echo '01' >ca.ser
    if [ ".$randfiles" != . ]; then
        $openssl genrsa -rand $randfiles -out ca.key 1024
    else
        $openssl genrsa -out ca.key 1024
    fi
    if [ $? -ne 0 ]; then
        echo "cca:Error: Failed to generate RSA private key" 1>&2
        exit 1
    fi
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 2: Generating X.509 certificate signing request for CA${T_ME}"
    cat >.cfg <<EOT
[ req ]
default_bits                    = 1024
distinguished_name              = req_DN
RANDFILE                        = ca.rnd
[ req_DN ]
countryName                     = "1. Country Name             (2 letter code)"
#countryName_default             = CA
#countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = "2. State or Province Name   (full name)    "
#stateOrProvinceName_default     = "Quebec"
localityName                    = "3. Locality Name            (eg, city)     "
#localityName_default            = "Montreal"
0.organizationName              = "4. Organization Name        (eg, company)  "
0.organizationName_default      = "Apache HTTP Server"
organizationalUnitName          = "5. Organizational Unit Name (eg, section)  "
organizationalUnitName_default  = "For testing purposes only"
commonName                      = "6. Common Name              (eg, CA name)  "
commonName_max                  = 64
commonName_default              = "localhost"
emailAddress                    = "7. Email Address            (eg, name@FQDN)"
emailAddress_max                = 40
#emailAddress_default            = "root@localhost"
EOT
    $openssl req -config .cfg -new -key ca.key -out ca.csr
    if [ $? -ne 0 ]; then
        echo "cca:Error: Failed to generate certificate signing request" 1>&2
        exit 1
    fi
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 3: Generating X.509 certificate for CA signed by itself${T_ME}"
    cat >.cfg <<EOT
#extensions = x509v3
#[ x509v3 ]
#subjectAltName   = email:copy
#basicConstraints = CA:true,pathlen:0
#nsComment        = "CCA generated custom CA certificate"
#nsCertType       = sslCA
EOT
    $openssl x509 -extfile .cfg -req -days 365 -signkey ca.key -in ca.csr -out ca.crt
    if [ $? -ne 0 ]; then
        echo "cca:Error: Failed to generate self-signed CA certificate" 1>&2
        exit 1
    fi
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}RESULT:${T_ME}"
    $openssl verify ca.crt
    if [ $? -ne 0 ]; then
        echo "cca:Error: Failed to verify resulting X.509 certificate" 1>&2
        exit 1
    fi
    $openssl x509 -text -in ca.crt
    $openssl rsa -text -in ca.key

    echo "${T_MD}CERTIFICATE GENERATION${T_ME}"
    user="server"

    echo ""
    echo "${T_MD}Generating custom USER${T_ME} [$user]"
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 5: Generating RSA private key for USER (1024 bit)${T_ME}"
    if [ ".$randfiles" != . ]; then
        $openssl genrsa -rand $randfiles -out $user.key 1024
    else
        $openssl genrsa -out $user.key 1024
    fi
    if [ $? -ne 0 ]; then
        echo "cca:Error: Failed to generate RSA private key" 1>&2
        exit 1
    fi
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 6: Generating X.509 certificate signing request for USER${T_ME}"
    cat >.cfg <<EOT
[ req ]
default_bits                    = 1024
distinguished_name              = req_DN
RANDFILE                        = ca.rnd
[ req_DN ]
countryName                     = "1. Country Name             (2 letter code)"
#countryName_default             = XY
#countryName_min                 = 2
countryName_max                 = 2
stateOrProvinceName             = "2. State or Province Name   (full name)    "
#stateOrProvinceName_default     = "Unknown"
localityName                    = "3. Locality Name            (eg, city)     "
#localityName_default            = "Server Room"
0.organizationName              = "4. Organization Name        (eg, company)  "
0.organizationName_default      = "Apache HTTP Server"
organizationalUnitName          = "5. Organizational Unit Name (eg, section)  "
organizationalUnitName_default  = "Test Certificate"
commonName                      = "6. Common Name              (eg, DOMAIN NAME)  "
commonName_max                  = 64
commonName_default              = "localhost"
emailAddress                    = "7. Email Address            (eg, name@fqdn)"
emailAddress_max                = 40
#emailAddress_default            = "root@localhost"
EOT
    $openssl req -config .cfg -new -key $user.key -out $user.csr
    if [ $? -ne 0 ]; then
        echo "cca:Error: Failed to generate certificate signing request" 1>&2
        exit 1
    fi
    rm -f .cfg
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}STEP 7: Generating X.509 certificate signed by own CA${T_ME}"
    cat >.cfg <<EOT
#extensions = x509v3
#[ x509v3 ]
#subjectAltName   = email:copy
#basicConstraints = CA:false,pathlen:0
#nsComment        = "CCA generated client certificate"
#nsCertType       = client
EOT
    $openssl x509 -extfile .cfg -days 365 -CAserial ca.ser -CA ca.crt -CAkey ca.key -in $user.csr -req -out $user.crt
    if [ $? -ne 0 ]; then
        echo "cca:Error: Failed to generate X.509 certificate" 1>&2
        exit 1
    fi
    caname="`$openssl x509 -noout -text -in ca.crt |\
             grep Subject: | sed -e 's;.*CN=;;' -e 's;/Em.*;;'`"
    username="`$openssl x509 -noout -text -in $user.crt |\
               grep Subject: | sed -e 's;.*CN=;;' -e 's;/Em.*;;'`"
#    echo "Assembling PKCS#12 package"
#    $openssl pkcs12 -export -in $user.crt -inkey $user.key -certfile ca.crt -name "$username" -caname "$caname" -out $user.p12
    echo "______________________________________________________________________"
    echo ""
    echo "${T_MD}RESULT:${T_ME}"
    $openssl verify -CAfile ca.crt $user.crt
    if [ $? -ne 0 ]; then
        echo "cca:Error: Failed to verify resulting X.509 certificate" 1>&2
        exit 1
    fi
    $openssl x509 -text -in $user.crt
    $openssl rsa -text -in $user.key


popd >/dev/null


rm -f /tmp/tmpssl-$$/*.csr
rm -f /tmp/tmpssl-$$/ca.*
chmod 400 /tmp/tmpssl-$$/*

echo "Certificate creation done!"
cp /tmp/tmpssl-$$/server.* .

rm -rf /tmp/tmpssl-$$
