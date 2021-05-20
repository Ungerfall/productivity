# SQL Server (Linux) + Docker

This guideline is based on https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker

1. Download [Docker for Windows 10](https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe)
2. Install Docker (don't select to switch on Windows container)
3. Run "Docker Desktop.exe"
4. Open a command shell (cmd, bash etc.)
5. Pull the SQL Server 2017 Linux container image
``` shell
  docker pull mcr.microsoft.com/mssql/server:2017-latest
```
6. Run container image
``` shell
  docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=<Strong@Passw0rd>" \
  -p 1433:1433 --name mssql-server-2017 \
  -d mcr.microsoft.com/mssql/server:2017-latest
```
7. Open SQL IDE (SSMS, Azure data studio)
8. Connect to the created server
```
  Server:              127.0.0.1, 1433 (port is configured in docker run command)
  Authentication type: SQL Login
  User name:           sa
  Password:            from docker run command (SA_PASSWORD property)
```
9. Execute query from instnwnd.sql
10. Done.
