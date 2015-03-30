#!/usr/bin/perl
use strict;
use warnings;
use Bio::Tools::GFF;

# Simon Renny-Byfield, UC Davis, March 26th 2015

# usage script.pl <GFF> > <output>

# A quick BioPerl script extract the largest transcript per gene, and all the associated
# exons, UTRs, introns and CDS etc etc.

#####################
# Loading in the GFF
#####################

# first generate the GFF DB

my $gffio = Bio::Tools::GFF->new(-file => $ARGV[0], -gff_version => 3);

##############################      
# define some useful variables 
##############################
        
# for features and genes                                  
my $feature;
my $geneID;

# for transcripts
my $transLength;
my $transName;
my $transStart;
my $transStop;

# for exons
my $exonLength;
my $exonName;
my $exonStart;
my $exonStop;

# for CDS
my $cdsLength;
my $cdsName;
my $cdsStart;
my $cdsStop;

my %gffDB;
# structure
#	Gene->transcript->cds
#					'->exon
my @gffSlice;

#####################
# Loop over the GFF
#####################
    # loop over the input stream
    while( $feature = $gffio->next_feature() ) {
    	my $tag = $feature->primary_tag();
    	my $string =$gffio->gff_string($feature);
    	# skip lines that we don't want
    	next if $string =~ m/repeat/;
    	next if $string =~ m/Mt/;
    	next if $string =~ m/Pt/;
    	
    	###############
    	# deal with the GFF by gene
    	###############
    	
    	if ( $tag eq "gene" ) {
    			if ( $#gffSlice > 0 ) {
    				# send to the subroutine
    				my @geneModel = makeMiniDB ( $geneID , @gffSlice );
    				@gffSlice=();
    			}#if
    			$gffio->gff_string($feature) =~ m/ID=gene:(\w*)/;
    			$geneID = $1;
    			push( @gffSlice , $string );
        }#if
        else {
        	push( @gffSlice , $string );
        }#else
    }#while


#######
# Subroutines
#######

sub makeMiniDB {
		my ( $geneID , @geneObj ) = @_;
		# cycle through the gff lines
		foreach ( @geneObj ) {
			#split the line into data sections;
			my @data =split /[\t,;]+/, $_;
			# if it's a transcript;
			if ( $ data[8] =~ m/ID=transcript:(\w+_\w+)/ ) {
				$gffDB{$geneID}{$1}{'start'} = $data[3];#transcript start site
				$gffDB{$geneID}{$1}{'stop'} = $data[4];#transcript stop site
				$transLength = ($data[4] - $data[3]) ; # stop - start
				$gffDB{$geneID}{$1}{'length'} = $transLength; # the length
				$gffDB{$geneID}{'chr'} = $data[0]; #add the chromosome
				#print $gffDB{$geneID}{'chr'}, "\t" , $geneID , "\ttranscript" , "\t" , 
				#				$gffDB{$geneID}{$1}{'start'} , "\t" , $gffDB{$geneID}{$1}{'stop'}, "\n";
			}#if 
			
				# if it's a exon
				if ( $_ =~ /exon/ and m/Parent=transcript:(\w+_\w+)/ ) {
					$transName = $1;
					$_ =~ m/rank=(\d+)/;
					my $rank = $1;
					$gffDB{$geneID}{$transName}{'exon'}{$rank}{'start'} = $data[3];#transcript start site
					$gffDB{$geneID}{$transName}{'exon'}{$rank}{'stop'} = $data[4];#transcript stop site
					$transLength = ($data[4] - $data[3]) ; # stop - start
					$gffDB{$geneID}{$transName}{'exon'}{$rank}{'length'} = $transLength;
					#print $gffDB{$geneID}{'chr'}, "\t" , $geneID ,"\texon", "\t", 
					#			$gffDB{$geneID}{$transName}{'exon'}{$rank}{'start'} , "\t" , $gffDB{$geneID}{$transName}{'exon'}{$rank}{'stop'}, "\n";
				}#if
				# if it' a CDS
				if ( $_ =~ m/CDS/ and m/Parent=transcript:(\w+_\w+)/ ) {
					$_ =~ m/rank=(\d+)/;
					my $rank=$1;
					$gffDB{$geneID}{$1}{'CDS'}{$rank}{'start'} = $data[3];#transcript start site
					$gffDB{$geneID}{$1}{'CDS'}{$rank}{'stop'} = $data[4];#transcript stop site
					$transLength = ($data[4] - $data[3]) ; # stop - start
					$gffDB{$geneID}{$1}{'CDS'}{$rank}{'length'} = $transLength;
					#print $gffDB{$geneID}{'chr'}, "\t" , $geneID,  "\tCDS", "\t" , 
					#			$gffDB{$geneID}{$1}{'CDS'}{$rank}{'start'} , "\t" , $gffDB{$geneID}{$1}{'CDS'}{$rank}{'stop'} ,"\n";
				}#if
				# 
				# for each gene, should only be one.. 
				my @gene = keys ( %gffDB ); 
				
				foreach my $g ( @gene ) {
					print $g , "\t"; 
					# for each transcript
					my @trans = keys ( $gffDB{$g} );
					foreach my $t ( @trans ) {
						next if $t =~ m/chr/;
						next unless $t =~ m/T01/;
						print $t , "\ttranscript\t";
						print $gffDB{$g}{$t}{'start'} , "\t";
						print $gffDB{$g}{$t}{'stop'} , "\n";
						#foreach CDS
						my @cds = keys ( \%{$gffDB{$g}{$t}} );
						#print join ("\t" , @cds ) , "\n";
						foreach my $c ( @cds ) {
							
						}
					}#foreach
				}#foreach
					
		}#foreach
		%gffDB=();
		#print $geneID , "\n";
		#print join( "\n" , @geneObj );
		#print "\n\n\n\n";
}#makeMiniDB

exit;

#$feat->get_all_tags()