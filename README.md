## Watson: Auto deploy a node with k3s+rancher on a sle-micro 5.3 image


WARNING: this is all for testing. Not giving support. Use at your own risk.

 - Set your target disk for install on `framework/files/system/oem/98_elemental_install_from_iso.yaml` (default /dev/vda)
 - Set your k3s version on `framework/files/system/oem/99_watson_deploy_k3s+rancher.yaml` (default v1.24.7+k3s1)
 - Drop any extra [yip](https://github.com/mudler/yip) config files for your system under `framework/files/system/oem`
 - Build iso `make build_all` (requires docker)
 - Pop the iso into your machine/QEMU
 - Wait for it to auto install to the given disk set on the first step and the machine will auto reboot
 - Reach to your node IP with the help of sslip.io (i.e. ip is 10.0.1.15, go to https://10.0.1.15.sslip.io/dashboard)
 - Use the password `admin` as the bootstrap password for Rancher to generate a new one
 - ??????
 - PROFIT!!!!11!!!!