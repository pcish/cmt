#!/usr/bin/perl

# Usage: %prog <disk img path> <new vm name> <mac/ip suffix> <cpu affinity>

$image_dir = "/var/lib/xen/images/";
$mac_vendor_code = "00163EB310";
$dns_conf_file = '/var/lib/named/master/tcds.tcloud.com';
$ip_prefix = '10.201.196';
$ip_base = 140;
#$write_config = `if [ \`hostname\` = "b306" ]; then echo 1; fi`;
#$write_images = `if [ \`hostname\` != "b306" ]; then echo 1; fi`;
$write_config = $ARGV[4];
$write_images = $ARGV[5];

$origin_image = $ARGV[0];
$target_name = $ARGV[1];
$mac_overwrite = "".int($ARGV[2]/10)."".($ARGV[2]%10);
$random_mac = generate_random_mac($mac_vendor_code, $mac_overwrite);
$ipaddr = $ip_prefix.".".($ARGV[2] + $ip_base);
$random_uuid = generate_random_uuid();
$cpu = $ARGV[3];

$_ = `ifconfig | grep br0`;
($bridge, @discard) = split;
%profile = ( 
  name => '"'.$target_name.'"',
  uuid => '"'.$random_uuid.'"',
  memory => 1024,
  maxmem => 1024,
  vcpus => 1,
  cpus => "[\"$cpu\"]",
  on_poweroff => '"destroy"',
  on_reboot => '"restart"',
  on_crash => '"destroy"',
  disk => "[ \'file:/var/lib/xen/images/$target_name/disk0,xvda,w\', \'file:/var/lib/xen/images/$target_name/logdisk,xvdb,w\', \'file:/var/lib/xen/images/$target_name/osddisk,xvdc,w\' ]",
  vif => "[ \'bridge=$bridge, mac=$random_mac\' ]"
);
if (-e '/usr/lib/xen/boot/domUloader.py') {
  $profile{'bootloader'} = '"/usr/lib/xen/boot/domUloader.py"';
  $profile{'bootargs'} = '"--entry=xvda2:/boot/vmlinuz-xen,/boot/initrd-xen"';
} else {
  $profile{'bootloader'} = '"/usr/bin/pygrub"';
}

open(CONFFILE, ">", $target_name) or die "Cannot open conf file for writing: ".$!;
foreach $key (sort(keys(%profile))) {
  print CONFFILE $key."=".$profile{$key}."\n"
}
close CONFFILE;

if ($write_config) {
  append_to_dhcp($target_name, $random_mac, $ipaddr);
  append_to_dns($target_name, $ipaddr);
}

if ($write_images) {
  print `mkdir -p $image_dir$target_name`;
  if ($origin_image =~ /:/) {
    print `scp $origin_image $image_dir$target_name`;
  } else {
    print `cp $origin_image $image_dir$target_name`;
  }
  `dd if=/dev/zero of=$image_dir$target_name/logdisk bs=4M count=1000`;
  `dd if=/dev/zero of=$image_dir$target_name/osddisk bs=4M count=1000`;
}

sub append_to_dhcp {
  my $hostname = $_[0];
  my $mac = $_[1];
  my $ipaddr = $_[2];
  open(DHCP, '>>', '/etc/dhcpd.conf') or die "Cannot open /etc/dhcpd.conf for writing: ".$!;
  print DHCP "host $hostname {\n";
  print DHCP "  option host-name \"$hostname\";\n";
  print DHCP "  hardware ethernet $mac;\n";
  print DHCP "  fixed-address $ipaddr;\n";
  print DHCP "}\n";
  close DHCP;
}

sub append_to_dns {
  my $hostname = $_[0];
  my $ipaddr = $_[1];
  open(DNS, '>>', $dns_conf_file) or die "Cannot open $dns_conf_file for writing: ".$!;
  print DNS "$hostname\t\t\tA\t$ipaddr\n"; 
  close DNS;
}

sub generate_random_mac {
  my $addr = "";
  if (defined($_[0])) {
     $addr .= $_[0];
  } else {
     $addr = "00";
  }
  while (length($addr) < 12) {
    $addr .= sprintf "%X", int(rand(16));
  }
  if (defined($_[1])) {
    $addr =~ s/(..)(..)(..)(..)(..)(..)/$1:$2:$3:$4:$5:$_[1]/;
  } else {
    $addr =~ s/(..)(..)(..)(..)(..)(..)/$1:$2:$3:$4:$5:$6/;
  }
  return $addr;
}

sub generate_random_uuid {
  my $uuid = "";
  my $i = 0;
  while ($i++ < 32) {
    $uuid .= sprintf "%x", int(rand(16));
    if ($i == 8 || $i == 12 || $i == 16 || $i == 20) {
      $uuid .= "-";
    }
  }
  return $uuid;
}

