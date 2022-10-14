use warnings; use strict;
use cytoband;

package chromosome;

sub new
{
    my $class = shift;
    my $chr_id = shift;

    my %cytobands = ();
    my @cytobands_sorted;

    my $self = bless {
        chr_id => $chr_id,                                  # 0     # Chromosome ID
        cytobands => \%cytobands,                           # 1     # Hash linking cytoband objects to cytoband id's (key)
        cytobands_sorted => \@cytobands_sorted              # 2     # Array of cytoband ID's, in order from distal p to distal q
    }, $class;

    return $self;
}

# getters

sub get_chr_id
{
    my $self = shift;
    return $self->{chr_id};
}

sub get_cytobands
{
    my $self = shift;
    return $self->{cytobands};
}

sub get_cytobands_sorted
{
    my $self = shift;
    return $self->{cytobands_sorted};
}

# setters

sub add_cytoband
{
    my $self = shift;
    my $cytoband_raw = shift;

    my $cytoband = cytoband->new($cytoband_raw);
    
    ${$self->get_cytobands()}{$cytoband->get_cytoband_id()} = $cytoband;
    push (@{$self->get_cytobands_sorted()}, $cytoband->get_cytoband_id());
}

# other

sub get_cytoband_by_id
{
    my $self = shift;
    my $cytoband_id = shift;

    if (exists( ${$self->get_cytobands()}{$cytoband_id} )) { return ${$self->get_cytobands}{$cytoband_id}; }
    else { return -1; }
}

sub get_cytoband_list_from_range
{
    my $self = shift;
    my $first = shift;
    my $last = shift;

    my @cytobands;

    my ($first_index) = grep { ${$self->get_cytobands_sorted()}[$_] eq $first } (0 .. @{$self->get_cytobands_sorted()} - 1);
    my ($last_index) = grep { ${$self->get_cytobands_sorted()}[$_] eq $last } (0 .. @{$self->get_cytobands_sorted()} - 1);

    if (defined($first_index) && defined($last_index))
    {
        for (my $i = $first_index; $i <= $last_index; $i++)
        {
            push (@cytobands, ${$self->get_cytobands_sorted()}[$i]);
        }
    }

    return \@cytobands;
}

sub get_cytoband_count
{
    my $self = shift;

    return scalar( keys %{$self->get_cytobands()} );
}

sub print_cytobands
{
    my $self = shift;

    foreach my $cytoband (keys %{$self->get_cytobands()})
    {
        print ${$self->get_cytobands()}{$cytoband}->get_chr_id()."\t";
        print ${$self->get_cytobands()}{$cytoband}->get_cytoband_id()."\t";
        print ${$self->get_cytobands()}{$cytoband}->get_start()."\t";
        print ${$self->get_cytobands()}{$cytoband}->get_stop()."\t";
        print ${$self->get_cytobands()}{$cytoband}->print_classifications();
        print "\n";
    }
}

1;