variable "tags" {
  type = map(string)
  default = {
    Project = "SafeShare"
    Owner   = "farama"
  }
}