# Azure Container Registry (ACR) Docker Cleanup

See [SO: How to delete image from Azure Container Registry](https://stackoverflow.com/questions/41446962/how-to-delete-image-from-azure-container-registry)

First, login

```powershell
az login
```

Show usage

```console
az acr show-usage -name helloaksacr --output table
NAME      LIMIT        CURRENT VALUE    UNIT
--------  -----------  ---------------  ------
Size      10737418240  9143988388       Bytes
Webhooks  2                             Count
```

Get all tags of `repo/image` as json:

```powershell
az acr repository show-tags -n helloaksacr --repository repo/image > image_tags.json
```

Delete all tags except `latest` using [acr_docker_cleanup.ps1](acr_docker_cleanup.ps1)

```powershell
.\acr_docker_cleanup.ps1
```

Cleanup other repositories, e.g. `<foo>`

```powershell
.\acr_docker_cleanup.ps1 -repository repo/<foo>
```

## References

- [Best practices for Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-best-practices)
- [Set a retention policy for untagged manifests](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-retention-policy)
