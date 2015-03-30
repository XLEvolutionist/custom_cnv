#!/usr/bin/perl
use strict;
use warnings;

#usage script.pl <IN>

while (<>) {
	my @data = split /\s+/;
	$_ =~ m/Name=(\w+)_/;
	print "$data[0]:$data[1]-$data[2]\t$data[3]\t$1\n";
	#print join ( "\t" , @data[0..3] ) , "\t" , $1 , "\n";
}#while

exit;