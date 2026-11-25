$ErrorActionPreference = 'Stop'

# Compose resolves its files and .env relative to the project folder.
Push-Location $PSScriptRoot
try {
    # Do not silently start with missing or automatically created certificate files.
    foreach ($file in @('certs\localhost.crt', 'certs\localhost.key')) {
        if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
            throw "Missing $file. Follow the certificate setup in README.md."
        }
    }

    # Validate Compose settings before building or changing containers.
    docker compose config --quiet
    if ($LASTEXITCODE -ne 0) {
        throw 'Compose configuration is invalid.'
    }

    # Build the custom nginx image before deploying the services.
    & (Join-Path $PSScriptRoot 'build-image.ps1')

    # Start or update services and wait for their running/health status.
    # Named data volumes are not deleted or replaced.
    docker compose up -d --wait --wait-timeout 180
    if ($LASTEXITCODE -ne 0) {
        throw 'Deployment failed or services did not become ready.'
    }

    docker compose ps
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not display service status.'
    }
}
finally {
    Pop-Location
}
