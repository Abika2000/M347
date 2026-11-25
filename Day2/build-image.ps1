$ErrorActionPreference = 'Stop'

# Run from this script's folder so the Dockerfile and build context are found.
Push-Location $PSScriptRoot
try {
    # Build the nginx image used by both proxy services in compose.yaml.
    docker build --tag day2-nginx:1.0 .
    if ($LASTEXITCODE -ne 0) {
        throw 'Docker image build failed.'
    }

    Write-Host 'Image day2-nginx:1.0 built successfully.'
}
finally {
    # Restore the caller's original working directory, even after an error.
    Pop-Location
}
