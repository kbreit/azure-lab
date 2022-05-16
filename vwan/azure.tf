terraform {
  cloud {
    organization = "kbreit"

    workspaces {
      name = "azure-vwan"
    }
  }
}
