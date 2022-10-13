use warnings; use strict;

package gene_list;

sub new
{
    my $class = shift;
    my @genes;

    my $self = bless {
        genes => \@genes,                                   # 0     # Reference to an array containing a list of genes
    }, $class;

    return $self;
}

# expects a file handle to a plaintext list of genes
sub process_gene_list
{
    my $self = shift;
    my $geneListHandle = shift;

    die "File handle expected but not received.\n" unless $geneListHandle;
    die "Valid file handle expected but not received.\n" unless fileno($geneListHandle) != -1;

    while (my $line = <$geneListHandle>)
    {    
        chomp($line);
        
        if ($line =~ m/^\S/) { $self->add_gene($line); }
    }
}

# getters

sub get_genes
{
    my $self = shift;
    return $self->{genes};
}

# setters

sub add_gene
{
    my $self = shift;
    my $gene = shift;
    push(@{$self->{genes}}, $gene);
}

# other

sub get_gene_count
{
    my $self = shift;
    return scalar(@{$self->get_genes()});
}

1;