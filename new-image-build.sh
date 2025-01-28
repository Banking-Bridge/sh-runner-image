az acr build `
    --registry "bridgedevdevgithubrunnersacr" `
    --image "github-actions-runner:1.2" `
    --file "Dockerfile.github" `
    --auth-mode Default `
    "https://github.com/Banking-Bridge/sh-runner-image.git"