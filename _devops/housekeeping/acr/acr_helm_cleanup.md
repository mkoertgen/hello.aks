# Azure Container Registry (ACR) Helm Cleanup

See Microsoft Docs on [az acr helm](https://docs.microsoft.com/en-us/cli/azure/acr/helm?view=azure-cli-latest)

First, login

```powershell
az login
```

Show usage

```console
az acr show-usage -name helloaksseabhelacr --output table
NAME      LIMIT        CURRENT VALUE    UNIT
--------  -----------  ---------------  ------
Size      10737418240  9143988388       Bytes
Webhooks  2                             Count
```

List all helm charts:

```powershell
az acr helm list -n helloaksseabhelacr > charts.json
```

Delete all versions of chart <foo> except `latest` using [acr_helm_cleanup.ps1](acr_helm_cleanup.ps1)

```powershell
.\acr_helm_cleanup.ps1 -registry helloaksseabhelacr -chart <foo> -exceptTags latest
```
