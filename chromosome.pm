use warnings; use strict;
use cytoband;

package chromosome;

sub new
{
    my $class = shift;
    my $chr_id = shift;

    my %cytobands = ();

    my $self = bless {
        chr_id => $chr_id,                                  # 0     # Chromosome ID
        cytobands => \%cytobands                            # 1     # Hash linking cytoband objects to cytoband id's (key)
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

# setters

sub add_cytoband
{
    my $self = shift;
    my $cytoband_raw = shift;

    my $cytoband = cytoband->new($cytoband_raw);
    
    ${$self->get_cytobands()}{$cytoband->get_cytoband_id()} = $cytoband;
}

# other

sub get_cytoband_by_id
{
    my $self = shift;
    my $cytoband_id = shift;

    if (exists( ${$self->get_cytobands()}{$cytoband_id} )) { return ${$self->get_cytobands}{$cytoband_id}; }
    else { return -1; }
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