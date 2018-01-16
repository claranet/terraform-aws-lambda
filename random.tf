# Append a consistent random string to names to support multi region deployments

resource "random_id" "name" {
  byte_length = 4
}
