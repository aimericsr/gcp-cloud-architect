output "demo-vpn-ip-0" {
  value = google_compute_ha_vpn_gateway.vpc-demo-vpn-gw1.vpn_interfaces[0].ip_address
}
output "demo-vpn-ip-1" {
  value = google_compute_ha_vpn_gateway.vpc-demo-vpn-gw1.vpn_interfaces[1].ip_address
}
output "on-prem-vpn-ip-0" {
  value = google_compute_ha_vpn_gateway.on-prem-vpn-gw1.vpn_interfaces[0].ip_address
}
output "on-prem-vpn-ip-1" {
  value = google_compute_ha_vpn_gateway.on-prem-vpn-gw1.vpn_interfaces[1].ip_address
}