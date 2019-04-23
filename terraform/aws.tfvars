aws_region = "eu-north-1"
# TODO: Parameter needed for later prod
aws_role = "arn:aws:iam::295267165045:role/EC2AccessFromTerraform"
aws_master_iam_profile = "K8SControlPlaneEC2Access"
aws_worker_iam_profile = "K8SWorkerNodeEC2Access"

# AWS Instance types
# ...
master_instance_type = "m5.xlarge"
worker_instance_type = "m5.xlarge"
