use Sys::Statistics::Linux::NetStats;

my $lxs = Sys::Statistics::Linux::NetStats->new;
$lxs->init;
my $stat;
my $br0_stat;
$| = 1;
while(1) {
    sleep 2;
    $stat = $lxs->get;
    $br0_stat = %$stat->{'br0'};
    #print "", $br0_stat->{'rxbyt'}, "\n";
    while (($k, $v) = each %$br0_stat) {
        if ($k eq "rxbyt" || $k eq "rxpcks" ||
            $k eq "txbyt" || $k eq "txpcks" ) {
            print $k.".".$v."\t";
        }
    }
    print "\n";
}
