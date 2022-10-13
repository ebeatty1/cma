use warnings; use strict;

package cn_variant;

sub new
{
    my $class = shift;
    my $variant_raw = shift;
    my @variant = split(/\t/, $variant_raw, -1);

    die "Encountered entry that doesn't match expected copy number variant format.\n" unless (scalar(@variant) >= 4);

    my $self = bless {
        chromosome => $variant[0],                          # 0     # Chromosome ID
        cytoband => $variant[1],                            # 1     # Cytoband ID
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

sub get_cytoband
{
	my $self = shift;
	return $self->{cytoband};
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