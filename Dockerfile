FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build

RUN apt-get update && apt-get install -y libgdiplus nuget libc6-dev zip && apt-get clean all

COPY *.sh /source/

WORKDIR /source

CMD ["./build.sh", ""]
