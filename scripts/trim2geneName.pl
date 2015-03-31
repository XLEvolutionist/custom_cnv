#!/usr/bin/perl
use strict;
use warnings;

# Simon Renny-Byfield

# usage script.pl <in>

while ( <> ) {
	chomp;
	my $name;
	my @data = split /\s+/;
	if ( m/miRNA/ ) {
		$name=$data[4];
	}#if
	elsif ( $_=~ m/(GRM\w+)[_;]/ ) {
		$_=~ m/(GRM\w+)[_;]/;
		$name =$1;
		$name =~ s/_.*//ig;
	}#elsif
	else {
		$_ =~ m/ID=gene:(AC\w+\.\w+)/;
		$name =$1;		
	}#else
	
	#print $name , "\n";
	
	print "$data[0]\t$data[1]\t$data[2]\t$data[3]\t$name\n";
}#while