locals {
  system = jsondecode(file("assets/system.json"))
}

resource "tfe_workspace" "minetest_server" {
  name  = format("%s_%s", 
                local.system["env_stage"],
                local.system["workspace"]
                )
  organization = local.system["tfc_organization"]
  queue_all_runs = false
}

resource "tfe_variable" "mt_access_token" {
    key          = "access_token"
    value        = ""
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "Workspace that created the Minetest Server"
    sensitive    = true
}

resource "tfe_variable" "mt_env_name" {
    key          = "env_name"
    value        = format("%s_%s", 
                    lookup(local.system, "env_name"),
                    random_pet.name.id
                    )
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "Name of the Component"
}

resource "tfe_variable" "mt_env_stage" {
    key          = "env_stage"
    value        = lookup(local.system, "env_stage")
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "Stage of the Component"
}

resource "tfe_variable" "mt_location" {
    key          = "location"
    value        = lookup(local.system, "location")
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "Location of the Component"
}

resource "tfe_variable" "mt_system_function" {
    key          = "system_function"
    value        = lookup(local.system, "system_function")
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "System Function of the Component"
}

resource "tfe_variable" "mt_server_image" {
    key          = "server_image"
    value        = lookup(local.system, "server_image")
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "server_image of the Component"
}

resource "tfe_variable" "mt_server_type" {
    key          = "server_type"
    value        = lookup(local.system, "server_type")
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "server_type of the Component"
}

resource "tfe_variable" "mt_keyname" {
    key          = "keyname"
    value        = lookup(local.system, "keyname")
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "keyname of the Component"
}

resource "tfe_variable" "mt_network_zone" {
    key          = "network_zone"
    value        = lookup(local.system, "network_zone")
    category     = "terraform"
    workspace_id = tfe_workspace.minetest_server.id
    description  = "network_zone of the Component"
}
