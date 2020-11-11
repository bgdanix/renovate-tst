locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
      "-var-file=../../common.tfvars",
      "-var-file=../region.tfvars"
    ]
  }

  before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Running Terraform"]
  }

  source = "github.com/bgdanix/tfrepo//terraform/modules/moduleone?ref=0.0.9"

  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Finished running Terraform"]
    run_on_error = true
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name           = "mysql_${local.env}"
  instance_class = "db.t2.micro"

  allocated_storage = 20
  storage_type      = "standard"

  master_username = "admin"
  # TODO: To avoid storing your DB password in the code, set it as the environment variable TF_VAR_master_password
}
