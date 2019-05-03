FROM        microsoft/dotnet:2.2-sdk  AS build_container
WORKDIR     /app

# copy csproj and restore as distinct layers
COPY        *.csproj ./
RUN         dotnet restore

# copy everything else and build, also create self-certs for testing purposes
COPY        . ./
RUN         dotnet publish -c Release -o out

# build runtime image
FROM        microsoft/dotnet:2.2-runtime-bionic AS runtime_container
WORKDIR     /app
COPY        --from=build_container /app/out .


### Comment/Uncomment as needed - (1) for static configuration, (2) for on-the-fly generation using docker
# (1) Static - read from repo. See /certs and /docker directories.
#ADD         certs/localhost.pfx localhost.pfx
#ADD         docker/init.sh /init.sh
# (2) On-thefly
RUN         echo "[req]" >> /self-certificate.conf && \
            echo "default_bits                  = 2048" >> /self-certificate.conf && \
            echo "default_keyfile               = localhost.key" >> /self-certificate.conf && \
            echo "distinguished_name            = req_distinguished_name" >> /self-certificate.conf && \
            echo "req_extensions                = req_ext" >> /self-certificate.conf && \
            echo "x509_extensions               = v3_ca" >> /self-certificate.conf && \
            echo "prompt                        = no" >> /self-certificate.conf && \
            echo "[req_distinguished_name]      " >> /self-certificate.conf && \
            echo "countryName                   = "DE"" >> /self-certificate.conf && \
            echo "localityName                  = \"Frankfurt\"" >> /self-certificate.conf && \
            echo "stateOrProvinceName           = \"Hessen\"" >> /self-certificate.conf && \
            echo "organizationName              = \"ThinkCode\"" >> /self-certificate.conf && \
            echo "organizationalUnitName        = \"Ocelot Docker\"" >> /self-certificate.conf && \
            echo "commonName                    = \"localhost\"" >> /self-certificate.conf && \
            echo "[req_ext]                     " >> /self-certificate.conf && \
            echo "subjectAltName = @alt_names   " >> /self-certificate.conf && \
            echo "[v3_ca]                       " >> /self-certificate.conf && \
            echo "subjectAltName = @alt_names   " >> /self-certificate.conf && \
            echo "[alt_names]                   " >> /self-certificate.conf && \
            echo "DNS.1                         = localhost" >> /self-certificate.conf && \
            echo "DNS.2                         = 127.0.0.1" >> /self-certificate.conf

RUN         openssl req -x509 -nodes -days 2000 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config /self-certificate.conf -passin pass:YourSecurePassword && \
            openssl pkcs12 -export -out localhost.pfx -inkey localhost.key -in localhost.crt -passout pass:YourSecurePassword -passin pass:YourSecurePassword

RUN         echo "#!/usr/bin/env bash" >> /init.sh && \
            echo "export ASPNETCORE_Kestrel__Certificates__Default__Path=localhost.pfx" >> /init.sh && \
            echo "export ASPNETCORE_Kestrel__Certificates__Default__Password=YourSecurePassword" >> /init.sh && \
            echo "dotnet ThinkCode.Ocelot.dll" >> /init.sh && \
            chmod +x /init.sh

EXPOSE      80 443
CMD         [ "/init.sh" ]
