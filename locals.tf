locals {
    unique_stage = lookup(var.stage_mapping,lower(var.stage)).unique_stage
    environment = var.stage
}
