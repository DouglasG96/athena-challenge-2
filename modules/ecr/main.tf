resource "aws_ecr_repository" "this" {
  name                 = "${var.project_name}-ecr"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = local.policy
}