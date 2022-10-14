use warnings; use strict;

package cytoband;

sub new
{
    my $class = shift;
    my $cytoband_ref = shift;
    my @cytoband = @$cytoband_ref;
    my @classifications;

    my $self = bless {
        chr_id => $cytoband[0],                             # 0     # Chromosome ID
        cytoband_id => $cytoband[3],                        # 1     # Cytoband ID
        start => $cytoband[1],                              # 2     # Start position
        stop => $cytoband[2],                               # 3     # End position
        length => (($cytoband[2] - $cytoband[1]) / 1000000),# 4     # Cytoband length in MB
        gie_stain => $cytoband[4],                          # 5     # Giemsa stain result
        classifications => \@classifications                # 6     # Classification array
    }, $class;

    return $self;
}

# getters

sub get_chr_id
{
	my $self = shift;
	return $self->{chr_id};
}

sub get_cytoband_id
{
	my $self = shift;
	return $self->{cytoband_id};
}

sub get_start
{
	my $self = shift;
	return $self->{start};
}

sub get_stop
{
	my $self = shift;
	return $self->{stop};
}

sub get_length
{
	my $self = shift;
	return $self->{length};
}

sub get_gie_stain
{
	my $self = shift;
	return $self->{gie_stain};
}

sub get_classifications
{
	my $self = shift;
	return $self->{classifications};
}

# setters

sub add_classification
{
    my $self = shift;
    my $classification = shift;

    # add classification to the classification array if not already present
    if ( !( grep( /^$classification$/, @{$self->get_classifications()} ) ) ) { push(@{$self->get_classifications()}, $classification); }
}

# other

sub print_classifications
{
    my $self = shift;

    my $pos = 0;
    my $end = $self->get_classifications_count() - 1;
    foreach my $classification (@{$self->get_classifications()}) 
    { 
        print "$classification"; 
        if ($pos < $end) { print "\, "; }

        $pos++; 
    }
}

sub get_classifications_count
{
    my $self = shift;
    return scalar(@{$self->get_classifications()});
}

1;