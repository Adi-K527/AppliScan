# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

ARG Jwt__Secret
ARG Db__Connection

ENV Jwt__Secret=$Jwt__Secret
ENV Db__Connection=$Db__Connection

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o out

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/out .

ENTRYPOINT ["dotnet", "ApplicationsService.dll"]
