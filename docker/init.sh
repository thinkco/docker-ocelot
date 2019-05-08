#!/usr/bin/env bash

# Update to match generated certificate name. See ../certs
export ASPNETCORE_Kestrel__Certificates__Default__Path=localhost.pfx

# Update to match generated certificate password. See ../certs
export ASPNETCORE_Kestrel__Certificates__Default__Password=YourSecurePassword

# Keep Original
cp /app/ocelot.yaml /app/ocelot.yaml.orig

# Always listen on 80 & 443
#if [ -z "$ASPNETCORE_URLS" ];then
    export ASPNETCORE_URLS="https://0.0.0.0:443;http://0.0.0.0:80"
#fi 

if [ -z "$CONSUL_HOST" ];then
    export CONSUL_HOST=host.docker.internal
fi

if [ -z "$CONSUL_PORT" ];then
    export CONSUL_PORT=8500
fi

echo "Using Ocelot URLS ${ASPNETCORE_URLS}"
echo "Using Consul @ ${CONSUL_HOST}:${CONSUL_PORT}"

if [ -f /app/ocelot.yaml.orig ];then
   cp /app/ocelot.yaml.orig /app/ocelot.yaml
   sed -i 's/Host:/Host: '$CONSUL_HOST' #/g' /app/ocelot.yaml
   sed -i 's/Port:/Port: '$CONSUL_PORT' #/g' /app/ocelot.yaml
fi

# Start the application
dotnet ThinkCode.Ocelot.dll
