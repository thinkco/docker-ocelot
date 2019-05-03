#!/usr/bin/env bash

# Update to match generated certificate name. See ../certs
export ASPNETCORE_Kestrel__Certificates__Default__Path=localhost.pfx

# Update to match generated certificate password. See ../certs
export ASPNETCORE_Kestrel__Certificates__Default__Password=YourSecurePassword

# Keep Original
cp /app/ocelot.yaml /app/ocelot.yaml.orig

if [ -z "$CONSUL_HOST" ];then
    CONSUL_HOST=localhost
fi

if [ -z "$CONSUL_PORT" ];then
    CONSUL_PORT=8500
fi

echo "Using Consul @ ${CONSUL_HOST}:${CONSUL_PORT}"

if [ -f /app/ocelot.yaml.orig ];then
   cp /app/ocelot.yaml.orig /app/ocelot.yaml
   sed -i 's/Host:/Host: '$CONSUL_HOST' #/g' /app/ocelot.yaml
   sed -i 's/Port:/Port: '$CONSUL_PORT' #/g' /app/ocelot.yaml
fi

# Start the application
dotnet ThinkCode.Ocelot.dll
