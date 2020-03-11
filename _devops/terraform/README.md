# TerraForm

> What is [Terraform](https://www.terraform.io/intro/index.html#what-is-terraform-)?
> Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can > manage existing and popular service providers as well as custom in-house solutions.

Read on at [terraform.io/docs](https://www.terraform.io/docs/index.html)

## Getting started

Install terraform (and optionally tfswitch), then get ready for cloud provider of choice (here `azure`)

```console
cd azure
terraform init
terraform plan --out current.tfplan
...
```

## Importing existing resources

Terraform is able to [import existing infrastructure](https://www.terraform.io/docs/import/index.html). This allows you take resources you've created by some other means and bring it under Terraform management.

This is a great way to slowly transition infrastructure to Terraform, or to be able to be confident that you can use Terraform in the future if it potentially doesn't support every feature you need today.

Example for Azure

```console
cd azure
terraform import azurerm_resource_group.rg /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myresourcegroup
```

## Links

- [How to manage terraform versions for each project](https://medium.com/@warrensbox/how-to-manage-different-terraform-versions-for-each-project-51cca80ccece)
