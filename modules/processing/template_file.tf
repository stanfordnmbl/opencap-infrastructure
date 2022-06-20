data "template_file" "task_definition_template" {
    template = file("../modules/processing/task_definition.json.tpl")
    vars = {
        REGION = "${var.region}"
        OPENPOSE = "${var.openpose_ecr_repository}"
        OPENCAP = "${var.opencap_ecr_repository}"
    }
}