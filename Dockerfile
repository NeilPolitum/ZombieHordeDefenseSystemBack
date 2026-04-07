FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ZSafeBack.sln ./
COPY ZSafeBack.API/ZSafeBack.API.csproj ZSafeBack.API/
COPY ZSafeBack.Application/ZSafeBack.Application.csproj ZSafeBack.Application/
COPY ZSafeBack.Domain/ZSafeBack.Domain.csproj ZSafeBack.Domain/
COPY ZSafeBack.Infrastructure/ZSafeBack.Infrastructure.csproj ZSafeBack.Infrastructure/

RUN dotnet restore ZSafeBack.sln

COPY . .
RUN dotnet publish ZSafeBack.API/ZSafeBack.API.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://0.0.0.0:10000
EXPOSE 10000

ENTRYPOINT ["dotnet", "ZSafeBack.API.dll"]
