This Terraform project sets up a Virtual Private Cloud (VPC) in AWS with the following components:

VPC: A rsschool-zayneshzangar-vpc VPC.
Subnets:
2 public subnets in different Availability Zones (AZs).
2 private subnets in different AZs.
Internet Gateway: To allow internet access for resources in public subnets.
Internet Gateway: To allow internet access for resources in public subnets.
Routing Configuration:
Instances in all subnets can communicate with each other.
Instances in public subnets can access the internet, and the internet can access them.
Organization of Terraform Code
Separation of Variables
All configurable variables are defined in the variables.tf file. This includes settings for:

VPC CIDR block
Subnet CIDR blocks
Availability Zones
Other customizable parameters
Separation of Resources
Resources are divided into separate .tf files for better organization. This allows each file to focus on a specific component, making it easier to navigate and maintain.

Here's the breakdown of resource files:

vpc.tf: Defines the VPC resource.
subnets.tf: Configures the public and private subnets.
igw.tf: Provisions the Internet Gateway for public subnets.
nat_gw.tf: Configures the NAT Gateway for private subnets.
route_table.tf: Sets up the route tables for public and private subnets.
route.tf: Defines the routes to allow communication between subnets and internet access for public subnets.
rt_association.tf: Associates subnets with their respective route tables.
eip.tf: Allocates Elastic IPs for the NAT Gateway.
nacl.tf: Defines Network ACLs to control inbound and outbound traffic for subnets in the VPC.
Example of how the resources are divided:
└── vpc
    ├── nat.tf                # NAT Gateway
    ├── internet_gateway.tf   # Internet Gateway configuration
    ├── security_group.tf     # Security group and NACL
    ├── backend.tf            # Terraform remote state
    ├── providers.tf          # AWS provider configuration
    ├── route.tf              # Routing rules for subnets and NAT
    ├── subnets.tf            # Public and private subnets
    ├── data.tf               # Daata for instance
    ├── bastion.tf            # Bastion host
    ├── variables.tf          # Variables to customize the VPC and subnets        
    ├── output.tf             # Outputs  
    └── vpc.tf                # VPC definition
Key Resources:
VPC: A virtual private network that hosts all subnets.
Public Subnets: Subnets with internet access via the Internet Gateway.
Private Subnets: Subnets that use a NAT Gateway to access the internet, without direct internet access from outside.
Internet Gateway (IGW): Allows public subnets to access the internet.
NAT Gateway: Enables instances in private subnets to initiate outbound traffic to the internet while remaining unreachable from the outside.
Prerequisites
AWS account
Terraform installed (Install Terraform)
IAM permissions to manage VPC, subnets, and other resources
Usage
Clone this repository:
git clone git@github.com:zayneshzangar/rsschool-devops-course-tasks.git
cd task_2/vpc
Initialize the Terraform workspace:
terraform init
Review the variables in variables.tf and adjust them according to your requirements.
Generate a plan:
terraform plan
Apply the configuration:
terraform apply -auto-approve
This will create the VPC, subnets, routing tables, and other resources defined in the files.

Verification
Terraform plan is executed successfully.

You can see the success of terraform plan in the plan-files folder

A resource map screenshot is provided
