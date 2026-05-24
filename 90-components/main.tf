module "component"{
    for_each = var.component
    source = "git::/https://github.com/vinod1618/terraform-roboshop-component.git?ref=main"
    component = each.key
    rule_priority = each.value.rule_priority
}