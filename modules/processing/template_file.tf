data "template_file" "task_definition_template" {
    template = file("../modules/processing/task_definition.json.tpl")
    vars = {
        REGION = "${var.region}"
        ENV = "${var.env}"
        APP_NAME = "${var.app_name}"
        OPENPOSE = "${var.openpose_ecr_repository}"
        MMPOSE = "${var.mmpose_ecr_repository}"
        OPENCAP = "${var.opencap_ecr_repository}"
        API_TOKEN = var.env == "-dev" ? "arn:aws:secretsmanager:us-west-2:660440363484:secret:OpenCapProcessingCredentials-oXYoTR:api_token_dev::" : "arn:aws:secretsmanager:us-west-2:660440363484:secret:OpenCapProcessingCredentials-oXYoTR:api_token::"
        API_URL = var.env == "-dev" ? "arn:aws:secretsmanager:us-west-2:660440363484:secret:OpenCapProcessingCredentials-oXYoTR:api_url_dev::" : "arn:aws:secretsmanager:us-west-2:660440363484:secret:OpenCapProcessingCredentials-oXYoTR:api_url::"
    }
}