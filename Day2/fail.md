# Problems during implementation

This file records the problems observed while building and testing the
password manager and the earlier nginx example.

## 1. nginx returned 403 Forbidden

- **Where:** The earlier `helloword` website at `http://localhost:8080`.
- **Cause:** Its Compose file mounted an empty `data` folder over nginx's
  website directory. This hid the `index.html` copied from `www` into the
  image. nginx had no index file to serve and directory listing was disabled.
- **Fix suggested:** Mount `www` at `/usr/share/nginx/html` and, if needed,
  mount `data` at a separate path. Static nginx alone does not save user data.

## 2. Account creation failed over HTTP

- **Where:** The first Vaultwarden configuration at `http://localhost:8081`.
- **Cause:** The initial setup served only HTTP. The web page opened, but
  the current web vault required HTTPS to complete account creation. The
  initial implementation and instructions incorrectly assumed HTTP on
  localhost was sufficient.
- **Fix:** Configure nginx with TLS, change the Vaultwarden `DOMAIN` to
  `https://localhost:8081`, and recreate the affected containers.

## 3. HTTPS initially could not load

- **Where:** `https://localhost:8081` before the TLS change.
- **Cause:** Changing `http` to `https` in the browser was not enough: nginx
  was listening for HTTP, not HTTPS.
- **Fix:** Generate a localhost certificate, configure nginx to listen with
  TLS, and map host port 8081 to container port 443.

## 4. Browser warns about the certificate

- **Where:** The current local HTTPS setup.
- **Cause:** The certificate is self-signed, so browsers do not automatically
  trust it. Automated browsing also reported `ERR_CERT_AUTHORITY_INVALID`.
- **Workaround for local testing:** Continue through the browser's warning
  for `localhost` as described in [README.md](./README.md). This is not a
  trusted production certificate. Do not use real passwords in this test
  setup.

## 5. Initial web page test failed despite HTTP 200

- **Where:** The first automated Compose validation.
- **Cause:** The test expected the word `Bitwarden` in the HTML response.
  The response returned HTTP 200, but did not satisfy that check. This was
  a faulty test assumption, not evidence that nginx had failed.
- **Fix:** Check the HTML response and Vaultwarden's `/api/config` endpoint
  instead. The database and two nginx scaling replicas were also checked.

## 6. Browser automation problems

- **Isolated browser context:** The integrated browser rejected creation of
  a separate browser context because of its session storage restrictions.
  A separate headless browser was used for the signup test instead.
- **Language-dependent test:** The first headless test expected an English
  button label, but the form appeared in German. The test was changed to
  use form and input selectors instead.
- **Result:** A test account was created successfully in an isolated
  temporary deployment. Its containers and test volumes were removed
  afterwards; the user's existing database was not deleted.

## 7. Diagnostic command errors

- A `docker inspect` formatting command failed because its arguments were
  parsed incorrectly. The nginx logs and Compose configuration still
  identified the 403 cause.
- Checking globally installed npm packages returned `ENOENT` because the
  global npm directory did not exist. This was a tooling check, not an
  application error; the signup test used the installed browser instead.
