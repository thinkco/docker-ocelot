# Ocelot

![Ocelot](https://camo.githubusercontent.com/c2118a418c5805c899903bc34fcdf471c9edf0d5/687474703a2f2f74687265656d616d6d616c732e636f6d2f696d616765732f6f63656c6f745f6c6f676f2e706e67)

dotnet dev-certs https --trust
dotnet dev-certs https --help

ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://localhost:7000
ASPNETCORE_URLS="http://localhost:6666;https://localhost:6667" dotnet run
dotnet run --no-launch-profile

{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  },
  "AllowedHosts": "localhost",
  "Kestrel": {
    "EndPoints": {
        "Http": {
            "Url": "http://localhost:6000"
        },
        "Https": {
            "Url": "https://localhost:6001"
        }
    }
  }
}

## Overriding Listening Address
docker run --rm -it -p 80:80/tcp -e ASPNETCORE_URLS="https://0.0.0.0:10443;http://0.0.0.0:10080"  docker-ocelot:latest
docker run --rm -it -p 10080:10080/tcp -p 10443:10443/tcp -e ASPNETCORE_URLS="https://0.0.0.0:10443;http://0.0.0.0:10080"
docker run --rm -it -p 10080:10080/tcp -p 10443:10443/tcp -e ASPNETCORE_URLS="https://*:10443;http://*:10080" -e ASPNETCORE_HTTPS_PORT=10443 docker-ocelot:latest
docker run --rm -it -p 10080:10080/tcp -p 10443:10443/tcp -e ASPNETCORE_URLS="https://0.0.0.0:10443;http://0.0.0.0:10080" -e CONSUL_HOST="192.168.1.103" -e CONSUL_PORT="8500" docker-ocelot:latest
docker run --rm -it --name ocelot --hostname ocelot -p 10080:10080/tcp -p 10443:10443/tcp -e ASPNETCORE_URLS="https://0.0.0.0:10443;http://0.0.0.0:10080" -e CONSUL_HOST="192.168.1.103" -e CONSUL_PORT="8500" docker-ocelot:latest

## Using a Development Certificate
dotnet dev-certs https -ep ${HOME}/.aspnet/https/aspnetapp.pfx -p crypticpassword
dotnet dev-certs https --trust
chrome://flags/#allow-insecure-localhost
---
Brought to you by Thinkco.de!

![ThinkCode](https://avatars2.githubusercontent.com/u/31565447?s=200) 