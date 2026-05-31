provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "the-redemption"
      Environment = "prod"
      ManagedBy   = "terraform"
      Owner       = "cloud-engineer-assessment"
    }
  }
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_backup_region
}