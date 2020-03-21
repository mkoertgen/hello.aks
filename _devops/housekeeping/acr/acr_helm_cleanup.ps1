# https://stackoverflow.com/questions/41446962/how-to-delete-image-from-azure-container-registry

param(
    [Parameter(Mandatory = $False)] [string] $registry = 'helloaksseabhelacr',
    [Parameter(Mandatory = $False)] [string] $chart = 'parrot',
    [Parameter(Mandatory = $False)] [string[]] $exceptTags = @('latest')
)

#az login

$tagsFile = "acr_helm.$chart.json"
if (!(Test-Path -Path $tagsFile)) {
    Write-Host "${registry}: Getting all versions of $chart ..."
    #az acr helm list -n $registry > $tagsFile
    az acr helm show -n ${registry} ${chart} > $tagsFile
}

$tags = Get-Content -Raw -Path $tagsFile | ConvertFrom-Json
$tagsToDelete = $tags.version | Where-Object { $_ -notin $exceptTags }
Write-Host "${chart}: Deleting $($tagsToDelete.Count) / $($tags.Count) tags..."

#$tagsToDelete[1..10] | ForEach-Object { Write-Host $_ }
$tagsToDelete | ForEach-Object {
    $version = "$_"
    Write-Host "${registry}: Deleting ${chart}:${version} ..."
    az acr helm delete --yes -n $registry $chart --version $version
}
