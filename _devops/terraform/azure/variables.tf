variable "prefix" {
  description = "A prefix used for all resources"
  # seabhel: https://www.fantasynamegenerators.com/marvel-celestial-names.php
  default = "hello-aks-seabhel"
}

variable "location" {
  description = "The Azure Region in which all resources should be provisioned"
  # For Azure locations, typically `eastus` or `northeurope` will be lowest price. List locations using
  # Check pricing with the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/?service=kubernetes-service).
  #az account list-locations
  default = "eastus"
}

variable "environment" {
  description = "Environment tag tos for the created resources (e.g. 'Production', 'Testing')"
  # seabhel: https://www.fantasynamegenerators.com/marvel-celestial-names.php
  default = "Testing" # Development, Testing, Production
}

variable "k8s_enable_devspaces" {
  description = "(optional) Enable Azure Dev spaces"
  default     = true
}

variable "k8s_client_id" {
  description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "k8s_client_secret" {
  description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
}

variable "k8s_principal_id" {
  description = "The Service Principal's object ID needed for assigning `AcrPull` role to the k8s cluster"
}

variable "k8s_version" {
  # az aks get-versions -l eastus ---> latest version: 1.17.0
  default = "1.17.0"
}