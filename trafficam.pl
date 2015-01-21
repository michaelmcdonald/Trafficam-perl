#!/usr/bin/perl 

use warnings;
use strict;

my $PINK="\e[38;5;210m";
my $NO="\e[0m";

my $top = 5;
my $i = 0;

my @log = </home/domlogs/*>;
my %IPseen = ();
my %DOMseen = ();
my %FILESseen = ();

foreach my $fh (@log) {
	next if $fh =~ /bytes/;
	open (my $FILE, '<', $fh) or die "unable to open $fh"; 
	while(my $line = <$FILE> ) {
		next unless $line =~ /POST/;
		if ($line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*"POST\s+([^"]*)\s/) {
                       	$FILESseen{$2}++;
			$DOMseen{$fh}++;
			$IPseen{$1}++;
		}
		
	}		
	close $FILE;
}

print "\n${PINK}IPs making the most POST requests:${NO}\n";

for my $key (sort {$IPseen{$b} <=> $IPseen{$a} }  keys %IPseen)  {
    printf ("%-4s$key\n",  "$IPseen{$key}");
	$i++;
	if ($i == $top){last;}
}

undef $i;

print "\n${PINK}Domains receiving the most POST requests:${NO}\n";

for my $key (sort {$DOMseen{$b} <=> $DOMseen{$a} }  keys %DOMseen)  {
    printf ("%-4s$key\n",  "$DOMseen{$key}");
	$i++;
	if ($i == $top){last;}
}

undef $i;

print "\n${PINK}Files receiving the most POST requests${NO}\n";

for my $key (sort {$FILESseen{$b} <=> $FILESseen{$a} }  keys %FILESseen)  {
	printf ("%-4s$key\n",  "$FILESseen{$key}");
		$i++;
		if ($i == $top){last;}
}

print "\n"
