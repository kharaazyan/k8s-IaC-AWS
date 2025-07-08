data "aws_key_pair" "secret-key" {
  key_name           = var.key_pair_name
  include_public_key = true
}