#!/usr/bin/env bash
set -e

client_id=$GITHUB_APP_CLIENT_ID

printf '%b\n' "$GITHUB_APP_KEY" > /tmp/key.pem

now=$(date +%s)
iat=$((${now} - 60)) # Issues 60 seconds in the past
exp=$((${now} + 600)) # Expires 10 minutes in the future

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

header_json='{
    "typ":"JWT",
    "alg":"RS256"
}'
# Header encode
header=$( echo -n "${header_json}" | b64enc )

payload_json="{
    \"iat\":${iat},
    \"exp\":${exp},
    \"iss\":\"${client_id}\"
}"
# Payload encode
payload=$( echo -n "${payload_json}" | b64enc )

# Signature
header_payload="${header}"."${payload}"
signature=$(
    openssl dgst -sha256 -sign /tmp/key.pem \
    <(echo -n "${header_payload}") | b64enc
)

# Create JWT
JWT="${header_payload}"."${signature}"
printf '%s\n' "JWT: $JWT"
printf '%s\n' "INSTALLATION_ID: $INSTALLATION_ID"

INSTALLATION_TOKEN="$(curl --request POST \
--url "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
--header "Accept: application/vnd.github+json" \
--header "Authorization: Bearer $JWT" \
--header "X-GitHub-Api-Version: 2022-11-28" \
  | jq -r '.token')"

printf '%s\n' "INSTALLATION TOKEN: $INSTALLATION_TOKEN"

# Retrieve a short lived runner registration token using the PAT
REGISTRATION_TOKEN="$(curl -X POST -fsSL \
  -H 'Accept: application/vnd.github+json' \
  -H "Authorization: Bearer $INSTALLATION_TOKEN" \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  "$REGISTRATION_TOKEN_API_URL" \
  | jq -r '.token')"

printf '%s\n' "REGISTRATION TOKEN: $REGISTRATION_TOKEN"

./config.sh --url $GH_URL --token $REGISTRATION_TOKEN --unattended --ephemeral && ./run.sh