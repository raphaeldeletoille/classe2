variable "my_name" {
  type = string
  default = "toto"
}

variable "rg_map" {
    type = map 
    default = {
      "rg1" = {
        name = "raphforeach1"
        location = "West Europe"
      },
      "rg2" = {
        name = "raphforeach2"
        location = "West US"
      },
      "rg3" = {
        name = "raphforeach3"
        location = "East US"
      },
      "rg4" = {
        name = "raphforeach4"
        location = "East US"
      }
    }
}