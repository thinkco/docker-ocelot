FROM microsoft/dotnet:2.2-sdk  AS build_container
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# copy everything else and build, also create self-certs for testing purposes
COPY . ./
RUN dotnet publish -c Release -o out && \
    dotnet dev-certs https -ep out/aspnetapp.pfx -p crypticpassword

# build runtime image
FROM microsoft/dotnet:2.2-runtime-bionic AS runtime_container
WORKDIR /app
COPY --from=build_container /app/out .

# create some self-signed certificates on the fly
ADD self-certificate.conf /self-certificate.conf
RUN openssl req -new -config /self-certificate.conf -keyout my_web_domain.key -out my_web_domain.csr
#RUN openssl req -newkey rsa:2048 -nodes -keyout my_web_domain.key -out my_web_domain.csr
RUN openssl x509 -signkey my_web_domain.key -in my_web_domain.csr -req -days 2000 -out my_web_domain.crt
RUN openssl pkcs12 -inkey my_web_domain.key -in my_web_domain.crt -export -out my_web_domain.pfx -passout pass:crypticpassword

# create the start command inline using the generated certs
RUN echo "#!/bin/sh" >> /init.sh && \
    echo "openssl req -new -config /self-certificate.conf -keyout my_web_domain.key -out my_web_domain.csr" >> /init.sh && \
    echo "openssl x509 -signkey my_web_domain.key -in my_web_domain.csr -req -days 2000 -out my_web_domain.crt" >> /init.sh && \
    echo "openssl pkcs12 -inkey my_web_domain.key -in my_web_domain.crt -export -out my_web_domain.pfx -passout pass:crypticpassword" >> /init.sh && \
    echo "export ASPNETCORE_Kestrel__Certificates__Default__Path=/app/my_web_domain.pfx" >> /init.sh && \
    echo "export ASPNETCORE_Kestrel__Certificates__Default__Password=crypticpassword" >> /init.sh && \
    echo "dotnet ThinkCode.Ocelot.dll" >> /init.sh && \
    chmod +x /init.sh

EXPOSE 80 443
CMD [ "/init.sh" ]
