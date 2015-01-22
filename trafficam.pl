#!/usr/bin/perl

#   TITLE: Traffic Cam
#  AUTHOR: michael mcdonald
# CONTACT: michael@liquidweb.com
# PURPOSE: Scans through all domlogs for the server and identifies the
#          IPs, domains, and files that have the most POST requests


# Special thanks to James Dooley for peer reviewing my work and offering
# numerous suggestions on how to improve / speed up my Perl programming
# within this script.
 
use warnings;
use strict;

my $version = "1.0.1";

# Clear the screen before doing anything
my $clear_string = `clear`;
print $clear_string;

################################################################################################
#                               BEGIN MAIN VARIABLE DECLARATIONS                               #
#----------------------------------------------------------------------------------------------#

# Color and color-reset variables for use in section titles 
my $PINK="\e[38;5;210m";
my $NO="\e[0m";
 
# Variables for counting number of iterations / data to display. Change $top to display more / fewer results
my $top = 5;
my $i = 0;

# Initializing the $path variable for the largest_value_mem function
my $path;
 
# Setting an array of all filesnames for the domlogs on the system
my @log = </usr/local/apache/domlogs/*>;
 
# Initializing the hashes that will track the data we display
my %IPseen = ();
my %DOMseen = ();
my %FILESseen = ();
my %HITTERseen = ();
 
# Date variable to acquire the current date
my $now=qx(date +"%d/%b/%Y");
chomp $now;

#----------------------------------------------------------------------------------------------#
#                                  END MAIN VARIABLE DECLARATIONS                              #
################################################################################################




################################################################################################
#                                        BEGIN MAIN LOOP                                       #
#----------------------------------------------------------------------------------------------#

# Main for loop to cycle through the log files
foreach my $fh (@log) {
        next if $fh =~ /bytes/;
        my @file = split(/\n/,qx(grep '$now.*POST' '$fh'));
 
        while(my $line = shift @file ) {
                next unless $line =~ m/$now/;
                if ($line =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*"POST\s+([^"]*)\s/) {
                        $FILESseen{$2}++;
                        $DOMseen{$fh}++;
                        $IPseen{$1}++;
                }
 
        }
}

#----------------------------------------------------------------------------------------------#
#                                         END MAIN LOOP                                        #
################################################################################################




################################################################################################
#                              BEGIN DATA ORGANIZATION AND PRINTING                            #
#----------------------------------------------------------------------------------------------#

# Print the top 5 IPs that have made POST requests to any domain
print "\n${PINK}IPs making the most POST requests:${NO}\n";
 
for my $key (sort {$IPseen{$b} <=> $IPseen{$a} }  keys %IPseen)  {
    printf ("%-8s$key\n",  "$IPseen{$key}");
        $i++;
        if ($i == $top){last;}
}
 
undef $i;

# Print the top 5 domains that have received POST requests
print "\n${PINK}Domains receiving the most POST requests:${NO}\n";
 
for my $key (sort {$DOMseen{$b} <=> $DOMseen{$a} }  keys %DOMseen)  {
    printf ("%-8s$key\n",  "$DOMseen{$key}");
        $i++;
        if ($i == $top){last;}
}

undef $i;

# Print the top 5 files that have received POST requests
print "\n${PINK}Files receiving the most POST requests${NO}\n";
 
for my $key (sort {$FILESseen{$b} <=> $FILESseen{$a} }  keys %FILESseen)  {
        printf ("%-8s$key\n",  "$FILESseen{$key}");
                $i++;
                if ($i == $top){last;}
}


# Determines which of the domains has the highest number of POST requests and stores the path to the
# log file for that domain as the variable $hitter
sub largest_value_mem (\%) {
    my $hash   = shift;
    my ($key, @keys) = keys   %DOMseen;
    my ($big, @vals) = values %DOMseen;

    for (0 .. $#keys) {
        if ($vals[$_] > $big) {
            $big = $vals[$_];
            $key = $keys[$_];
        }
    }
    $key
}

my $hitter=(largest_value_mem %DOMseen);

# Applies regex to the $hitter variable that contains the full path to the domlog for the domain with the
# most POSTS requests and strips out just the domain portion, storing it as the variable $path
($path) = $hitter =~ m/domlogs\/([^\/]+)/g;
if ($path) {
}

undef $i;

# Print the top 5 files receiving POST requests from the domain that received the most POST requests
print "\n${PINK}Files receiving the most POST requests on $path${NO}\n";


my $name;
open ($name, '<', $hitter) or die "Could not open file";

while (my $row = <$name>) {
	chomp $row;
	next unless $row =~ m/$now/;
	if ($row =~ /"POST\s+([^"]*)\s/) {
                        $HITTERseen{$1}++;
        }

}

for my $key (sort {$HITTERseen{$b} <=> $HITTERseen{$a} }  keys %HITTERseen)  {
        printf ("%-8s$key\n",  "$HITTERseen{$key}");
                $i++;
                if ($i == $top){last;}
}


#----------------------------------------------------------------------------------------------#
#                              END DATA ORGANIZATION AND PRINTING                              #
################################################################################################

print "\n"
