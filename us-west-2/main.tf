module "bsclight" {
    region = "us-west-2"
    num_machines = 1
    
    source = "../modules/processing"
}
