variable "region" {
  type        = string
  default     = "us-east-2"
  description = "3 tier architecture"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "private subnet app"
}

variable "desired_capacity" {
  type        = number
  default     = "3"
  description = "desired capacity of ASG"
}

variable "max_size" {
  type        = number
  default     = "5"
  description = "max size for ASG"
}

variable "min_size" {
  type        = number
  default     = "1"
  description = "min size for ASG"
}

variable "cpu_target" {
  type        = number
  default     = 60
  description = "cpu_target"
}



variable "sg_name" {
  type        = string
  default     = "as-name"
  description = "default sg name"
}




variable "name_prefix" {
  type        = string
  default     = "my-launch"
  description = "description"
}

#VPC variable

variable "vpcname" {
  type        = string
  default     = "custom VPC"
  description = "description"
}

variable "db_username" {
  description = "Database administrator username"
  default     = "admin"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  default     = "Temppass11$$"
  type        = string
  sensitive   = true
}


#VPC cidr block

variable "vpc_cidr" {
  default     = "10.0.0.0/24"
  description = "VPC_cidr block"
  type        = string
}
##################################
## Presentation Tier CIDR Block 1 ##
##################################
variable "public-subnet1-cidr" {
  default     = "10.0.0.0/28"
  description = "public_web_subnet1"
  type        = string
}
################################
## Presentation Tier CIDR Block 2##
###############################
variable "public-subnet2-cidr" {
  default     = "10.0.0.16/28"
  description = "public_web_subnet2"
  type        = string
}
#########################
## App tier CIDR Block 1##
#########################
variable "private-subnet1-cidr" {
  default     = "10.0.0.128/28"
  description = "private_app_subnet1"
  type        = string
}
############################
## App tier CIDR Block 2 ##
###########################
variable "private-subnet2-cidr" {
  default     = "10.0.0.144/28"
  description = "private_app_subnet2"
  type        = string
}
####################
## DB CIDR Block 1 ##
####################
variable "private-subnet1db-cidr" {
  default     = "10.0.0.160/28"
  description = "private_db_subnet1"
  type        = string
}
####################
## DB CIDR Block 2 ##
####################
variable "private-subnet2db-cidr" {
  default     = "10.0.0.176/28"
  description = "private_db_subnet2"
  type        = string
}

############################
## App tier security group ##
############################
variable "ssh-locate" {
  default     = "yourip"
  description = "ip address"
  type        = string
}