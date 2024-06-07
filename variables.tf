variable "my_name" {
  type    = string
  default = "raphael"
}

variable "rg_map" {
  type = map(any)
  default = {
    "rg1" = {
      name     = "raphaelforeach1"
      location = "West Europe"
    },
    "rg2" = {
      name     = "raphaelforeach2"
      location = "West US"
    },
    "rg3" = {
      name     = "raphaelforeach3"
      location = "East US"
    },
    "rg4" = {
      name     = "raphaelforeach4"
      location = "East US"
    },
  }
}