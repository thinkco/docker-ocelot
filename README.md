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

---
Brought to you by Thinkco.de!

![ThinkCode](https://avatars2.githubusercontent.com/u/31565447?s=200) 