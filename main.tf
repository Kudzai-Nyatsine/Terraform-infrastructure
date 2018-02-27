provider "aws" {
    region="eu-west-1"
}

data "template_file" "app_init" {
	template = "${file("./scripts/app_user_data.sh")}"
	vars {
		private_ip = "${module.db-tier.db_ip}"
	}
}


resource "aws_vpc" "vpc-kudz" {
  cidr_block = "10.3.0.0/16"
  tags {
    Name = "kudzai-app"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc-kudz.id}"
  tags {
        Name = "gw"
    }
}
 
resource "aws_route_table" "public-kudz" {
	vpc_id  = "${aws_vpc.vpc-kudz.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.gw.id}"
	}

	tags {
		Name = "public-kudz"
	}
}
# load balancer

resource "aws_elb" "app-kudz" {
  name               	= "kudzai-terraform-elb"
  subnets 						= ["${module.app-tier.sub_n}"]
  security_groups 		= ["${module.app-tier.sec_group}"]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  instances                   = ["${module.app-tier.app_id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "kudzai-terraform-elb"
  }
}



	module "db-tier" {
	name = "db-kudz"
	source = "./modules/tier"
	vpc_id = "${aws_vpc.vpc-kudz.id}"
	cidr_block = "10.3.1.0/24"
	route_table_id = "${aws_route_table.public-kudz.id}"
	user_data = ""
	machine_count = 1
	ami_id =  "ami-6a84ef13"

	ingress = [{
		from_port  = 27017
		to_port    = 27017
		protocol   = "tcp"
		cidr_blocks = "${module.app-tier.subnet_cidr_block}"
	}]

	}

module "app-tier" {
	name = "app-kudz"
	source = "./modules/tier"
	vpc_id = "${aws_vpc.vpc-kudz.id}"
	machine_count = 2
	cidr_block = "10.3.0.0/24"
	route_table_id = "${aws_route_table.public-kudz.id}"
	user_data = "${data.template_file.app_init.rendered}"
	ami_id =  "ami-0cbfd475"
	map_public_ip_on_launch = true

	ingress = [{
		from_port  = 80
		to_port    = 80
		protocol   = "tcp"
		cidr_blocks = "0.0.0.0/0"
	}]

	}


