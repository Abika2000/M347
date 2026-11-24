# Vaultwarden: source and description

## What is Vaultwarden?

Vaultwarden is an open-source, self-hosted password manager server written in
Rust. It provides an alternative implementation of the Bitwarden server API,
compatible with Bitwarden clients, and includes a web vault. It is an
unofficial community project, not a product of Bitwarden.

## Where did we get it?

The application source code and project documentation are on GitHub:

- [Vaultwarden GitHub repository](https://github.com/dani-garcia/vaultwarden)
- [Vaultwarden documentation](https://github.com/dani-garcia/vaultwarden/wiki)

Our [Compose file](./compose.yaml) uses the `vaultwarden/server:1.36.0` image
from [Docker Hub](https://hub.docker.com/r/vaultwarden/server). Docker Compose
downloads this image when starting the service if it is not already available
locally.

## Configuration references

- [Using PostgreSQL with Vaultwarden](https://github.com/dani-garcia/vaultwarden/wiki/Using-the-PostgreSQL-Backend)
- [Reverse proxy examples](https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples)
- [Enabling HTTPS](https://github.com/dani-garcia/vaultwarden/wiki/Enabling-HTTPS)

The local project uses PostgreSQL for the database and nginx as the HTTPS
reverse proxy. Its self-signed certificate is intended for local testing.
