#!/usr/bin/env bash

# Update to match generated certificate name. See ../certs
export ASPNETCORE_Kestrel__Certificates__Default__Path=localhost.pfx

# Update to match generated certificate password. See ../certs
export ASPNETCORE_Kestrel__Certificates__Default__Password=YourSecurePassword

# Start the application
dotnet ThinkCode.Ocelot.dll
