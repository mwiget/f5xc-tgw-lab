resource "volterra_aws_tgw_site" "tgw" {
  name        = var.site_name
  namespace   = "system"

  vpc_attachments {
    vpc_list {
      vpc_id = var.spoke_vpc_id
    }
  }

  #  vn_config {
  #  global_network_list {
  #    global_network_connections {
  #      sli_to_global_dr {
  #        global_vn {
  #          name = format("%s-global-network", var.projectPrefix)
  #        }
  #      }
  #    }
  #  }
  #  # sm_connection_pvt_ip = true
  #  sm_connection_public_ip = true
  #}

  aws_parameters {
    aws_certified_hw = "aws-byol-multi-nic-voltmesh"
    aws_region       = var.aws_region
    ssh_key          = var.ssh_public_key
    
    new_tgw {
      system_generated = true
    }

    new_vpc {
      name_tag = var.site_name
      primary_ipv4 = var.service_vpc_cidr
    }

    no_worker_nodes = true

    dynamic "az_nodes" {
      for_each = var.subnets
      content {
        aws_az_name = format("%s%s", var.aws_region, var.subnets[az_nodes.key]["az"])
        inside_subnet {
          subnet_param {
            ipv4 = var.subnets[az_nodes.key]["inside"]
          }
        }
        workload_subnet {
          subnet_param {
            ipv4 = var.subnets[az_nodes.key]["outside"]
          }
        }
        outside_subnet {
          subnet_param {
            ipv4 = var.subnets[az_nodes.key]["workload"]
          }
        }      
      }
    }

    aws_cred {
      name = var.f5xc_aws_cred
      namespace = "system"      
    }
    assisted = false
    instance_type = "t3.xlarge"
  }
  logs_streaming_disabled = true

  lifecycle {
    ignore_changes = [labels]
  }
}

resource "volterra_cloud_site_labels" "labels" {
  name = volterra_aws_tgw_site.tgw.name
    site_type = "aws_tgw_site"
    labels = {
      # site-group = var.projectPrefix
      key1 = "value1"
      key2 = "value2"
    }
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "tgw" {
  site_name        = volterra_aws_tgw_site.tgw.name
  site_kind        = "aws_tgw_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = false

  depends_on = [volterra_aws_tgw_site.tgw]
}

output "tgw" {
  value = resource.volterra_aws_tgw_site.tgw
}
