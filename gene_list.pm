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

# expects a file handle to an Agilent or Nexus interval table file
sub process_gene_list
{
    my $self = shift;
    my $geneListHandle = shift;

    die "File handle expected but not received.\n" unless $geneListHandle;
    die "Valid file handle expected but not received.\n" unless fileno($geneListHandle) != -1;

    while (my $line = <$geneListHandle>)
    {    
        chomp($line);
        
        if ($line =~ m/^\S/)
        {
            push(@{$self->{genes}}, $line);
        }
    }

    print "First-tier gene list has ".$self->get_gene_count()." genes.\n";
}

sub get_gene_count
{
    my $self = shift;
    return scalar(@{$self->{genes}});
}

1;