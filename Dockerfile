FROM        microsoft/dotnet:2.2-sdk  AS build_container

MAINTAINER  Carlos Lozano Diez <thinkcode@adaptive.me>

WORKDIR     /app

# copy csproj and restore as distinct layers
COPY        *.csproj ./
RUN         dotnet restore

# copy everything else and build, also create self-certs for testing purposes
COPY        . ./
RUN         dotnet publish -c Release -o out

ENV         ASPNETCORE_URLS="https://0.0.0.0:443;http://0.0.0.0:80"
ENV         CONSUL_HOST=192.168.1.103
ENV         CONSUL_PORT=8500

# build runtime image
FROM        microsoft/dotnet:2.2-runtime-bionic AS runtime_container
WORKDIR     /app
COPY        --from=build_container /app/out .


### Comment/Uncomment as needed - (1) for static configuration, (2) for on-the-fly generation using docker
# (1) Static - read from repo. See /certs and /docker directories.
ADD         certs/localhost.pfx localhost.pfx
ADD         docker/init.sh /init.sh
# (2) On-thefly
# ADD         certs/self-certificate.conf /self-certificate.conf
# ADD         docker/init.sh /init.sh
# RUN         openssl req -x509 -nodes -days 2000 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config /self-certificate.conf -passin pass:YourSecurePassword && \
#             openssl pkcs12 -export -out localhost.pfx -inkey localhost.key -in localhost.crt -passout pass:YourSecurePassword -passin pass:YourSecurePassword

EXPOSE      80 443
CMD         [ "/init.sh" ]
