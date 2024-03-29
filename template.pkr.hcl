data "amazon-ami" "autogenerated_1" {
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "autogenerated_1" {
  ami_description         = "Base image for headless ghost CMS system"
  ami_groups              = ["all"]
  ami_name                = "daringway-ghost-${local.timestamp}"
  ami_regions             = ["us-east-1"]
  ami_virtualization_type = "hvm"
  force_delete_snapshot   = "true"
  force_deregister        = "true"
  instance_type           = "m5.large"
  region                  = "us-east-1"
  source_ami              = "${data.amazon-ami.autogenerated_1.id}"
  ssh_username            = "ubuntu"
  tags = {
    Application         = "ghost"
    Base_AMI_Name       = "{{ .SourceAMIName }}"
    DISTRIB_CODENAME    = "focal"
    DISTRIB_DESCRIPTION = "Ubuntu 20.04 LTS"
    DISTRIB_ID          = "Ubuntu"
    DISTRIB_RELEASE     = "20.04"
    OS_CODENAME         = "focal"
    OS_Name             = "Ubuntu"
    OS_Version          = "20.04"
    SSHUSER             = "ubuntu"
  }
}

build {
  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "file" {
    destination = "/tmp/"
    source      = "templates/"
  }

  provisioner "file" {
    destination = "/tmp/"
    source      = "ghost-serverless"
  }

  provisioner "shell" {
    script = "./provision.sh"
    execute_command = "sudo -u root /bin/bash -c '{{.Path}}'"
  }

}
