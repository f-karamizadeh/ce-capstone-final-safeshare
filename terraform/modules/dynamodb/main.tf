resource "aws_dynamodb_table" "tokens" {
  name         = "safeshare-tokens"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "token"
  attribute {
    name = "token"
    type = "S"
  }
}