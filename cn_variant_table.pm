use warnings; use strict;
use cn_variant; 
use cytomap; 

package cn_variant_table;

sub new
{
    my $class = shift;

    my @known_variants;

    my $self = bless {
        known_variants => \@known_variants                  # 0     # Array of references to known CHD-related copy number variant objects
    }, $class;

    return $self;
}

# expects a file handle to a tsv containing info on known csv's
# example format:
#   chr22	q11.23	Loss	DiGeorge syndrome
#   chr21	p13-q22.3	Gain	Down syndrome
sub process_cn_variant_table
{
    my $self = shift;
    my $tableHandle = shift;
    my $cytomap = shift;

    die "File handle expected but not received.\n" unless $tableHandle;
    die "Valid file handle expected but not received.\n" unless fileno($tableHandle) != -1;

    while (my $line = <$tableHandle>)
    {    
        chomp($line);

        if ($line =~ m/^\s/) { next; }
        elsif (!($line =~ m/^chr/)) { die "Unrecognized copy number variant table format detected.\n"; }
        else 
        {   
            my $variant = cn_variant->new($line, $cytomap);
            $self->add_known_variant($variant);
        }
    }

    # add our known copy number variant information into the cytomap
    foreach my $variant (@{$self->get_known_variants()})
    {
        my $chromosome = $cytomap->{$variant->get_chromosome()};

        foreach my $cytoband_id (@{$variant->get_cytobands()})
        {
            my $cytoband = $chromosome->get_cytoband_by_id($cytoband_id);

            if ($cytoband != -1)
            {
                $cytoband->add_classification($variant->get_event()." : ".$variant->get_syndrome_name());
            }
        }
    }
}

# getters

sub get_known_variants
{
    my $self = shift;
    return $self->{known_variants};
}

# setters

sub add_known_variant
{
    my $self = shift;
    my $variant = shift;
    push(@{$self->{known_variants}}, $variant);
}

1;