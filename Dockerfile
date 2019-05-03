FROM microsoft/dotnet:2.2-sdk  AS build_container
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# copy everything else and build, also create self-certs for testing purposes
COPY . ./
RUN dotnet publish -c Release -o out

# build runtime image
FROM microsoft/dotnet:2.2-runtime-bionic AS runtime_container
WORKDIR /app
COPY --from=build_container /app/out .

# create some self-signed certificates on the fly
ADD self-certificate.conf /self-certificate.conf
RUN apt update && apt install -y libnss3-tools
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config /self-certificate.conf -passin pass:YourSecurePassword
RUN openssl pkcs12 -export -out localhost.pfx -inkey localhost.key -in localhost.crt -passout pass:YourSecurePassword -passin pass:YourSecurePassword

#RUN mkdir -p $HOME/.pki/nssdb && certutil -d sql:$HOME/.pki/nssdb -A -t "P,," -n "localhost" -i localhost.crt && certutil -L -d sql:${HOME}/.pki/nssdb
#RUN apt clean autoclean && apt autoremove --yes && rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN cp localhost.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates


# create the start command inline using the generated certs
RUN echo "#!/bin/sh" >> /init.sh && \
    #echo "openssl req -new -config /self-certificate.conf -keyout my_web_domain.key -out my_web_domain.csr" >> /init.sh && \
    #echo "openssl x509 -signkey my_web_domain.key -in my_web_domain.csr -req -days 2000 -out my_web_domain.crt" >> /init.sh && \
    #echo "openssl pkcs12 -inkey my_web_domain.key -in my_web_domain.crt -export -out my_web_domain.pfx -passout pass:crypticpassword" >> /init.sh && \
    echo "export ASPNETCORE_Kestrel__Certificates__Default__Path=localhost.pfx" >> /init.sh && \
    echo "export ASPNETCORE_Kestrel__Certificates__Default__Password=YourSecurePassword" >> /init.sh && \
    echo "dotnet ThinkCode.Ocelot.dll" >> /init.sh && \
    chmod +x /init.sh

EXPOSE 80 443
CMD [ "/init.sh" ]
