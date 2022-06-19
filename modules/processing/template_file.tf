data "template_file" "task_definition_template" {
    template = file("../modules/processing/task_definition.json.tpl")
    vars = {
        REGION = "${var.region}"
    }
}