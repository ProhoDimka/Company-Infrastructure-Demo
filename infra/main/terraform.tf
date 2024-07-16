terraform {
  backend "s3" {
    bucket         = "terraform-states-main-example-domain-com"
    key            = "main-example-domain-com/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "state-locking"
  }
}

/* Create bucket and dynamodb table

aws s3api create-bucket \
  --region ap-south-1 \
  --bucket terraform-states-main-example-domain-com \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws dynamodb create-table \
  --region ap-south-1 \
  --table-name state-locking \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

# Example how to delete lock if s...t happened
# DELETE FROM "state-locking" WHERE "LockID" = 'terraform-states-main-example-domain-com/main-example-domain-com/terraform.tfstate'
*/