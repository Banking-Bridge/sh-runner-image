az acr build `
    --registry "bridgeprodgithubrunnersacr" `
    --image "github-actions-runner-v2:1.0" `
    --file "Dockerfilev2.github" `
    --auth-mode Default `
    "https://github.com/Banking-Bridge/sh-runner-image.git"