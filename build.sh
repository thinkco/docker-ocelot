#!/usr/bin/env bash
dotnet build -c Release


Targets="win-x64 win-x86 win-arm win-arm64 linux-x64 linux-musl-x64 linux-arm osx-x64"

for target in $Targets; do
    dotnet publish -c Release -r $target
done