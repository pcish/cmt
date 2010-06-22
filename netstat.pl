use Sys::Statistics::Linux::NetStats;

if (!defined($ARGV[0])) {
    print "Must supply interface argument.\n";
    exit;
}
if ($ARGV[0] eq '-l') {
    my $lxs = Sys::Statistics::Linux::NetStats->new;
    $lxs->init;
    $stat = $lxs->get;
    $iface_stat = %$stat->{'eth0'};
    foreach $k (keys(%$iface_stat)) {
        print $k."\n";
    }
    exit;
}
my $iface = $ARGV[0];
my $lxs = Sys::Statistics::Linux::NetStats->new;
$lxs->init;
my $stat;
my $br0_stat;
$| = 1;
while(1) {
    sleep 2;
    $stat = $lxs->get;
    $iface_stat = %$stat->{$iface};
    while (($k, $v) = each %$iface_stat) {
        if ($k eq "rxbyt" || $k eq "rxpcks" ||
            $k eq "txdrop" || $k eq "rxdrop" ||
            $k eq "txbyt" || $k eq "txpcks" ) {
            print $k."=".$v."\t";
        }
    }
    print "\n";
}
