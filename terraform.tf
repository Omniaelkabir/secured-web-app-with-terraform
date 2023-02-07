module "module" {
  source             = "./module"
  vpc_cidr           = var.vpc_cidr
  vpc_name           = var.vpc_name
  subnets_cidr       = var.subnet_cidr
  az1                = var.zone1
  az2                = var.zone2
  cidr_from_anywhere = var.cidr_from_anywhere
  publicvmid1  = module.ec2.publicec-id1
  publicvmid2  = module.ec2.publicec-id2
  privatevmid1 = module.ec2.privateec-id1
  privatevmid2 = module.ec2.privateec-id2


}
module "ec2" {
  source          = "./ec2"
  ami_id          = var.ami_id
  vm_type         = var.vm_type
  securitygroupid = module.module.secgroup-id
  publics1-id     = module.module.public_subnet_id1
  publics2-id      = module.module.public_subnet_id2
  privates1-id     = module.module.private_subnet_id1
  privates2-id    = module.module.private_subnet_id2



  provisionerdata =             ["sudo apt update -y",
      "sudo apt install -y nginx",
      "echo 'server { \n listen 80 default_server; \n  listen [::]:80 default_server; \n  server_name _; \n  location / { \n  proxy_pass http://${module.module.pivatedns}; \n  } \n}' > default",
      "sudo mv default /etc/nginx/sites-enabled/default",
      "sudo systemctl stop nginx",
      "sudo systemctl start nginx"]
    
}