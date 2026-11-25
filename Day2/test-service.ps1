$ErrorActionPreference = 'Stop'

# Use the same Compose project and certificate files as the deployment.
Push-Location $PSScriptRoot
try {
    # Check that the Compose file and its environment variables are valid.
    docker compose config --quiet
    if ($LASTEXITCODE -ne 0) {
        throw 'Compose configuration is invalid.'
    }

    # Test the nginx configuration inside the running proxy container.
    docker compose exec -T nginx nginx -t
    if ($LASTEXITCODE -ne 0) {
        throw 'nginx configuration test failed.'
    }

    # Verify PostgreSQL is accepting connections inside its container.
    docker compose exec -T db pg_isready -U vaultwarden -d vaultwarden
    if ($LASTEXITCODE -ne 0) {
        throw 'PostgreSQL is not ready.'
    }

    # Find the configured local host port instead of assuming port 8081.
    $binding = docker compose port nginx 443
    if ($LASTEXITCODE -ne 0 -or $binding -notmatch '^127\.0\.0\.1:(\d+)$') {
        throw 'Could not find the local nginx HTTPS port.'
    }
    $port = $Matches[1]

    # Trust only the local test certificate, then check the Vaultwarden API.
    $url = "https://localhost:$port/api/config"
    $response = & curl.exe --fail --silent --show-error --max-time 10 `
        --cacert 'certs\localhost.crt' $url
    if ($LASTEXITCODE -ne 0) {
        throw 'Vaultwarden HTTPS request failed.'
    }
    $config = $response | ConvertFrom-Json
    if ($config.server.name -ne 'Vaultwarden') {
        throw 'The HTTPS endpoint did not return the expected Vaultwarden configuration.'
    }

    Write-Host "Service checks passed: $url"
}
finally {
    Pop-Location
}
