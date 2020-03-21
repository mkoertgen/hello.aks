# https://stackoverflow.com/questions/41446962/how-to-delete-image-from-azure-container-registry

param(
    [Parameter(Mandatory = $False)] [string] $registry = 'helloaksseabhelacr',
    [Parameter(Mandatory = $False)] [string] $image = 'helloaks/parrot',
    [Parameter(Mandatory = $False)] [string[]] $exceptTags = @('latest')
)

#az login

$repository = "$image"
$tagsFile = "acr_docker.$image.json"
if (!(Test-Path -Path $tagsFile)) {
    Write-Host "Getting all tags of $repository ..."
    az acr repository show-tags -n $registry --repository $repository > $tagsFile
}

$tags = Get-Content -Raw -Path $tagsFile | ConvertFrom-Json
$tagsToDelete = $tags | Where-Object { $_ -notin $exceptTags }
Write-Host "${repository}: Deleting $($tagsToDelete.Count) / $($tags.Count) tags..."

#$tagsToDelete[1..10] | ForEach-Object { Write-Host $_ }
$tagsToDelete | ForEach-Object {
    $imageTag = "${repository}:$_"
    Write-Host "Deleting $imageTag ..."
    az acr repository delete -n $registry --image $imageTag --yes
}
