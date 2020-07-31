#######
# WAF #
#######
locals {
  cf_waf_name = "WhitelistSpecifIps${var.env}"
}

resource "aws_waf_ipset" "ipset" {
  name = "tfIPSet"
  dynamic "ip_set_descriptors" {
    for_each = var.whitelisted_cdirs
    content {
      value = ip_set_descriptors.value.value
      type  = ip_set_descriptors.value.type
    }
  }
}

resource "aws_waf_rule" "wafrule" {
  depends_on = [aws_waf_ipset.ipset]

  name        = local.cf_waf_name
  metric_name = local.cf_waf_name

  predicates {
    data_id = aws_waf_ipset.ipset.id
    type    = "IPMatch"
    negated = false
  }
}

resource "aws_waf_web_acl" "waf_acl" {
  depends_on = [aws_waf_ipset.ipset, aws_waf_rule.wafrule]

  name        = local.cf_waf_name
  metric_name = local.cf_waf_name

  default_action {
    type = "BLOCK"
  }

  rules {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = aws_waf_rule.wafrule.id
    type     = "REGULAR"
  }
}
