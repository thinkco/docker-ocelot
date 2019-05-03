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
ADD certs/self-certificate.conf /self-certificate.conf
RUN apt update && apt install -y libnss3-tools
RUN openssl req -x509 -nodes -days 2000 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config /self-certificate.conf -passin pass:YourSecurePassword
RUN openssl pkcs12 -export -out localhost.pfx -inkey localhost.key -in localhost.crt -passout pass:YourSecurePassword -passin pass:YourSecurePassword

# create the start command inline using the generated certs
RUN echo "#!/usr/bin/env bash" >> /init.sh && \
    echo "export ASPNETCORE_Kestrel__Certificates__Default__Path=localhost.pfx" >> /init.sh && \
    echo "export ASPNETCORE_Kestrel__Certificates__Default__Password=YourSecurePassword" >> /init.sh && \
    echo "dotnet ThinkCode.Ocelot.dll" >> /init.sh && \
    chmod +x /init.sh

EXPOSE 80 443
CMD [ "/init.sh" ]
