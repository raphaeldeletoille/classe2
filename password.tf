resource "random_password" "password" {
  count            = 2
  length           = 26
  special          = true
  upper            = true
  min_upper        = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}