apt-get install -y debian-keyring  # debian only
apt-get install -y debian-archive-keyring  # debian only
apt-get install -y apt-transport-https

# For Debian Stretch, Ubuntu 16.04 and later
keyring_location=/usr/share/keyrings/nxadm-pkgs-rakudo-pkg-archive-keyring.gpg

# For Debian Jessie, Ubuntu 15.10 and earlier
# keyring_location=/etc/apt/trusted.gpg.d/nxadm-pkgs-rakudo-pkg.gpg

curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/gpg.0DD4CA7EB1C6CC6B.key' |  gpg --dearmor >> ${keyring_location}
curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/config.deb.txt?distro=ubuntu&codename=xenial' > /etc/apt/sources.list.d/nxadm-pkgs-rakudo-pkg.list
apt-get update

