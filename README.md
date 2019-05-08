# Ocelot API Gateway

![Ocelot](https://camo.githubusercontent.com/c2118a418c5805c899903bc34fcdf471c9edf0d5/687474703a2f2f74687265656d616d6d616c732e636f6d2f696d616765732f6f63656c6f745f6c6f676f2e706e67)

Ocelot is a .NET API Gateway. For more information on the product, you should head over to their repository on [Github](https://github.com/ThreeMammals/Ocelot) or check out the product's [documentation](https://ocelot.readthedocs.io/en/latest/introduction/gettingstarted.html).

This docker image is provided for development purposes; it is built on .NET Core 2.1 and uses [Consul](https://www.consul.io/) for Service Discovery and Configuration by default.

## Usage

It is assumed that you have a consul instance or docker container running on your localhost, accessible on port 8500. If you don't, check out ```tools/support-consul.sh``` in this repository to start a local docker container on your machine or see the section on *Installing Consul*. 

**To start the container using defaults:**

```
docker run --rm -d -p 10443:443/tcp -p 10080:80/tcp thinkco/ocelot
```

You can check Consul on ```http://localhost:8500/ui/dc1/kv``` to see and edit the Ocelot configuration. The gateway is running on http port 10080 (```http://localhost:10080/```) and on https port 10443 (```https://localhost:10443/```). You can customize the ports bindings for your local environment as needed.

**To start the container using a specific Consul:**

You can use environment variables ```CONSUL_HOST``` and ```CONSUL_PORT``` to have Ocelot use a Consul instance that is not running on localhost.

```
docker run --rm -d -p 10443:443/tcp -p 10080:80/tcp -e CONSUL_HOST="192.168.1.103" -e CONSUL_PORT="8500" thinkco/ocelot
```
You can customize the host and port for your local environment as needed. This has been tested in a local docker instance and in kubernetes, connecting to a Consul singleton and Consul HA cluster.


### Chrome & Self-Signed Certificates
If Chrome is giving you a hard time using the self-signed certificate when using the gateway on https, then enable [allow-insecure-localhost](chrome://flags/#allow-insecure-localhost) on your browser for development - open ```chrome://flags/#allow-insecure-localhost``` as a URI on Chrome itself and enable ```Allow invalid certificates for resources loaded from localhost```. Or simply use Firefox. 😄

After development, you should really have NGINX, HAProxy, Apache, Envoy, or whatever, in front of this component dealing with https using proper certificates. 

## Installing Consul

### Using Docker
```
docker create -p 8500:8500 --name=consul-dev -h consul-dev consul agent -dev -ui -client=0.0.0.0 -bind='{{ GetPrivateIP }}'
```

### Using Brew (MacOS)
```
brew install consul
```

You can then use ```brew services start consul``` and ```brew services stop consul``` to manage it as a background service. See on [Brew](https://brew.sh/) site.

### Using Chocolatey (Windows)
```
choco install consul
```
See on [Chocolatey](https://chocolatey.org/packages/consul) site.

### Using Other Environments
All Environments - Refer to Consul [installation](https://learn.hashicorp.com/consul/getting-started/install) and [downloads](https://www.consul.io/downloads.html) page.

# Development

You'll need to have .NET Core 2.2 installed. All commands listed are relative to the repository root directory.

## Docker Build

```
docker build --rm -f "Dockerfile" -t thinkco/ocelot:latest .
```
This will yield a docker container that you can start as described above.

## Dotnet Build & Run
To build:

```
docker build
```

To run using defaults:

```
docker run
```

To publish using defaults:

```
dotnet publish -c Release -r $target -o publish/$target
```

Where target can be any of ```win-x64 win-x86 win-arm win-arm64 linux-x64 linux-musl-x64 linux-arm osx-x64``` and any platform with a dotnet [Runtime Identifier](https://docs.microsoft.com/en-us/dotnet/core/rid-catalog). 
A convenience bash script can be found in the root directory of the repository called ```publish.sh``` to publish for all known identifiers.

You can change the configuration to meet your needs by editing either root or published YAML files:

* ```ocelot.yaml``` Runtime Ocelot configuration for Consul host and port settings.
* ```ocelot.Development.yaml``` Development Ocelot configuration for Consul host and port settings.
* ```appsettings.yaml``` Runtime configuration for Kestrel URLs.
* ```appsettings.Development.yaml``` Development configuration for Kestrel URLs.

Enjoy!

---
Brought to you by Thinkco.de!

![ThinkCode](https://avatars2.githubusercontent.com/u/31565447?s=200) 