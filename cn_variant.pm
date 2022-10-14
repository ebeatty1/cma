use warnings; use strict;
use cytomap;

package cn_variant;

sub new
{
    my $class = shift;
    my $variant_raw = shift;
     my $cytomap = shift;
     
    my @variant = split(/\t/, $variant_raw, -1);
    my $cytobands = $cytomap->get_cytoband_range($variant[0], $variant[1]);

    die "Encountered entry that doesn't match expected copy number variant format.\n" unless (scalar(@variant) >= 4);

    my $self = bless {
        chromosome => $variant[0],                          # 0     # Chromosome ID
        cytobands => $cytobands,                            # 1     # Cytoband ID array reference
        event => $variant[2],                               # 2     # Copy number variant type
        syndrome_name => $variant[3]                        # 3     # Name of associated disease, if any
    }, $class;

    return $self;
}

# getters

sub get_chromosome
{
	my $self = shift;
	return $self->{chromosome};
}

sub get_cytobands
{
	my $self = shift;
	return $self->{cytobands};
}

sub get_event
{
	my $self = shift;
	return $self->{event};
}

sub get_syndrome_name
{
	my $self = shift;
	return $self->{syndrome_name};
}

1;