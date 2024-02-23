# Build Security Groups
resource "aws_security_group" "pds" {
  name = "pds security group"
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ip]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "opened_to_alb" {
  type                     = "ingress"
  from_port                = 3002
  to_port                  = 3002
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_https.id
  security_group_id        = aws_security_group.pds.id
}

# The PDS instance in EC2
resource "aws_instance" "pds" {
  ami             = "ami-0fc5d935ebf8bc3bc"
  instance_type   = var.instance_size
  security_groups = [aws_security_group.pds.name]
  tags = {
    Name = "PDS"
  }
  user_data       = <<EOF
#!/bin/bash
echo "Copying SSH Keys to the server"
echo -e "${var.ssh_pub_key}" >> /home/ubuntu/.ssh/authorized_keys
echo "Installing requirements"
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
sudo apt-get install -y nodejs git jq
sudo npm install -g pnpm

echo "cloning the pds repo"
sudo git clone https://github.com/bluesky-social/pds /pds

cd /pds/service
sudo mkdir /pds/service/data

echo "building pds software"
sudo pnpm install --production --frozen-lockfile

echo "setting up the pds software"

echo "PDS_HOSTNAME=${var.domain_name}
PDS_JWT_SECRET=$(openssl rand --hex 16)
PDS_ADMIN_PASSWORD=%{if var.admin_password != ""}${var.admin_password}%{else}$(openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32)%{endif}
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$(openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32)
PDS_DATA_DIRECTORY=./data
PDS_BLOBSTORE_DISK_LOCATION=./data/blocks
PDS_DID_PLC_URL=https://plc.directory
PDS_BSKY_APP_VIEW_URL=https://api.bsky.app
PDS_BSKY_APP_VIEW_DID=did:web:api.bsky.app
PDS_REPORT_SERVICE_URL=https://mod.bsky.app
PDS_REPORT_SERVICE_DID=did:plc:ar7c4by46qjdydhdevvrndac
PDS_CRAWLERS=https://bsky.network
LOG_ENABLED=true
NODE_ENV=production
PDS_PORT=3002" | sudo tee /pds/pds.env

echo "[Unit]
Description=atproto personal data server

[Service]
WorkingDirectory=/pds/service
ExecStart=/usr/bin/node --enable-source-maps index.js
Restart=on-failure
EnvironmentFile=/pds/pds.env

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/pds.service

sudo systemctl daemon-reload

sudo systemctl start pds

EOF
}
