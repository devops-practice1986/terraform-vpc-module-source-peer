variable "project_name" {
  type        = string
  }
variable "environment" {
  type        = string
  }

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
   default     = true
}

# this is optional
variable "common_tags" {
  default     = {} 
  
}

variable "vpc_tags" {
    default     = {}
         
    }
variable "igw_tags" {
    default     = {}
         
    }
# public subnet CIDRs list
    variable "public_subnet_cidrs" {
        type    = list
        validation {
          condition = length(var.public_subnet_cidrs) == 2
          error_message = "please provide 2 valid public subnet CIDRs."
        }
      }
    variable "public_subnet_tags" {
        default = {}
    }


# private subnet CIDRs list
    variable "private_subnet_cidrs" {
        type    = list
        validation {
          condition = length(var.private_subnet_cidrs) == 2
          error_message = "please provide 2 valid private subnet CIDRs."
        }
      }
    variable "private_subnet_tags" {
        default = {}
    }   
# database private subnet CIDRs list
    variable "database_private_subnet_cidrs" {
        type    = list
        validation {
          condition = length(var.database_private_subnet_cidrs) == 2
          error_message = "please provide 2 valid database private subnet CIDRs."
        }
      }
    variable "database_private_subnet_tags" {
        default = {}
    }

    variable "database_subnet_tags" {
        
        default = {}
    }

    variable "nat_gateway_tags" {   
        default = {}
    }
    variable "public_route_table_tags" {   
        default = {}
    }
    variable "private_route_table_tags" {   
        default = {}
    }
    variable "database_route_table_tags" {   
        default = {}
    }

    variable "is_peering_required" {
        type    = bool
        default = false
    }
    variable "peering_connection_tags" {
        default = {}
    }