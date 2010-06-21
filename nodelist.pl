#!/usr/bin/perl
# Usage: %prog <max id> <start id>

if (defined($ARGV[1])) {
    $start = $ARGV[1];
} else {
    $start = 0;
}

open(OUTFILE, '>', 'nodelist');
print OUTFILE "nodelist_lsd_osd=(";
for ($i = $start; $i < $ARGV[0]; $i++) {
  print OUTFILE "lsd-$i ";
}
print OUTFILE ")\n";
close OUTFILE;
