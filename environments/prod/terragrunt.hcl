# Terraform configuration to use
terraform {
  source = "${get_parent_terragrunt_dir()}/terraform/"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# Specfic variables for this environment
inputs = {
  example_thing_1 = "foo2"
  example_thing_2 = "bar2"
}