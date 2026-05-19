output "zone_ids" {
  description = "Cloudflare zone IDs by domain. Copy into the cloudflare_zone_id map in global-variables.tf after apply."
  value       = { for k, z in cloudflare_zone.openmrs : k => z.id }
}

output "name_servers" {
  description = "Cloudflare-assigned name servers per zone. Lodge these at the registrar at cutover."
  value       = { for k, z in cloudflare_zone.openmrs : k => z.name_servers }
}
