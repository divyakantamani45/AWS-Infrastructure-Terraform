resource "aws_efs_file_system" "this" {
  creation_token = "${var.region}-efs-${random_id.id.hex}"
  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
  }
}

resource "random_id" "id" { byte_length = 4 }
locals {
  subnet_map = { for idx, id in var.subnet_ids : idx => id }
}
resource "aws_efs_mount_target" "this" {
  for_each = local.subnet_map
  file_system_id = aws_efs_file_system.this.id
  subnet_id = each.value
  security_groups = [var.vpc_sg_id]
}

# Optional: Access Point for per-app mount
resource "aws_efs_access_point" "app_ap" {
  file_system_id = aws_efs_file_system.this.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/app"
    creation_info {
      owner_gid = 1000
      owner_uid = 1000
      permissions = "0755"
    }
  }
}
