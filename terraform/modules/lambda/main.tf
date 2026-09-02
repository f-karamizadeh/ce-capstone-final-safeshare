data "archive_file" "all" {
  for_each    = toset(["upload_metrics", "upload_metadata", "upload_scanner", "download_audit", "download_delete"])
  type        = "zip"
  source_dir  = "${path.module}/src/${each.value}"
  output_path = "${path.module}/${each.value}.zip"
}