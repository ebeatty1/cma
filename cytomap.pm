use warnings; use strict;
use chromosome;

package cytomap;

sub new
{
    my $class = shift;

    my $chr1 = chromosome->new('chr1');
    my $chr2 = chromosome->new('chr2');
    my $chr3 = chromosome->new('chr3');
    my $chr4 = chromosome->new('chr4');
    my $chr5 = chromosome->new('chr5');
    my $chr6 = chromosome->new('chr6');
    my $chr7 = chromosome->new('chr7');
    my $chr8 = chromosome->new('chr8');
    my $chr9 = chromosome->new('chr9');
    my $chr10 = chromosome->new('chr10');
    my $chr11 = chromosome->new('chr11');
    my $chr12 = chromosome->new('chr12');
    my $chr13 = chromosome->new('chr13');
    my $chr14 = chromosome->new('chr14');
    my $chr15 = chromosome->new('chr15');
    my $chr16 = chromosome->new('chr16');
    my $chr17 = chromosome->new('chr17');
    my $chr18 = chromosome->new('chr18');
    my $chr19 = chromosome->new('chr19');
    my $chr20 = chromosome->new('chr20');
    my $chr21 = chromosome->new('chr21');
    my $chr22 = chromosome->new('chr22');
    my $chrX = chromosome->new('chrX');
    my $chrY = chromosome->new('chrY');

    my $self = bless {
        chr1 => $chr1,                                      # 0     # Chromosome 1 cytoband map reference
        chr2 => $chr2,                                      # 1     # Chromosome 2 cytoband map reference
        chr3 => $chr3,                                      # 2     # Chromosome 3 cytoband map reference
        chr4 => $chr4,                                      # 3     # Chromosome 4 cytoband map reference
        chr5 => $chr5,                                      # 4     # Chromosome 5 cytoband map reference
        chr6 => $chr6,                                      # 5     # Chromosome 6 cytoband map reference
        chr7 => $chr7,                                      # 6     # Chromosome 7 cytoband map reference
        chr8 => $chr8,                                      # 7     # Chromosome 8 cytoband map reference
        chr9 => $chr9,                                      # 8     # Chromosome 9 cytoband map reference
        chr10 => $chr10,                                    # 9     # Chromosome 10 cytoband map reference
        chr11 => $chr11,                                    # 10    # Chromosome 11 cytoband map reference
        chr12 => $chr12,                                    # 11    # Chromosome 12 cytoband map reference
        chr13 => $chr13,                                    # 12    # Chromosome 13 cytoband map reference
        chr14 => $chr14,                                    # 13    # Chromosome 14 cytoband map reference
        chr15 => $chr15,                                    # 14    # Chromosome 15 cytoband map reference
        chr16 => $chr16,                                    # 15    # Chromosome 16 cytoband map reference
        chr17 => $chr17,                                    # 16    # Chromosome 17 cytoband map reference
        chr18 => $chr18,                                    # 17    # Chromosome 18 cytoband map reference
        chr19 => $chr19,                                    # 18    # Chromosome 19 cytoband map reference
        chr20 => $chr20,                                    # 19    # Chromosome 20 cytoband map reference
        chr21 => $chr21,                                    # 20    # Chromosome 21 cytoband map reference
        chr22 => $chr22,                                    # 21    # Chromosome 22 cytoband map reference
        chrX => $chrX,                                      # 22    # Chromosome X cytoband map reference
        chrY => $chrY                                       # 23    # Chromosome Y cytoband map reference
    }, $class;

    return $self;
}

# expects a file handle to a cytoband table file
# https://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/
#   cytoBand.txt.gz
sub process_cytoband_table
{
    my $self = shift;
    my $tableHandle = shift;

    die "File handle expected but not received.\n" unless $tableHandle;
    die "Valid file handle expected but not received.\n" unless fileno($tableHandle) != -1;

    while (my $line = <$tableHandle>)
    {    
        chomp($line);

        if ($line =~ m/^\s/) { next; }
        elsif (!($line =~ m/^chr/)) { die "Unrecognized cytoband table format detected.\n"; }
        else
        {
            my @cytoband = split(/\t/, $line, -1);
            die "Invalid cytoband entry found in table.\n" unless scalar(@cytoband) == 5;
            $self->{$cytoband[0]}->add_cytoband(\@cytoband);
        }
    }
}

# getters

sub get_chr1
{
	my $self = shift;
	return $self->{chr1};
}

sub get_chr2
{
	my $self = shift;
	return $self->{chr2};
}

sub get_chr3
{
	my $self = shift;
	return $self->{chr3};
}

sub get_chr4
{
	my $self = shift;
	return $self->{chr4};
}

sub get_chr5
{
	my $self = shift;
	return $self->{chr5};
}

sub get_chr6
{
	my $self = shift;
	return $self->{chr6};
}

sub get_chr7
{
	my $self = shift;
	return $self->{chr7};
}

sub get_chr8
{
	my $self = shift;
	return $self->{chr8};
}

sub get_chr9
{
	my $self = shift;
	return $self->{chr9};
}

sub get_chr10
{
	my $self = shift;
	return $self->{chr10};
}

sub get_chr11
{
	my $self = shift;
	return $self->{chr11};
}

sub get_chr12
{
	my $self = shift;
	return $self->{chr12};
}

sub get_chr13
{
	my $self = shift;
	return $self->{chr13};
}

sub get_chr14
{
	my $self = shift;
	return $self->{chr14};
}

sub get_chr15
{
	my $self = shift;
	return $self->{chr15};
}

sub get_chr16
{
	my $self = shift;
	return $self->{chr16};
}

sub get_chr17
{
	my $self = shift;
	return $self->{chr17};
}

sub get_chr18
{
	my $self = shift;
	return $self->{chr18};
}

sub get_chr19
{
	my $self = shift;
	return $self->{chr19};
}

sub get_chr20
{
	my $self = shift;
	return $self->{chr20};
}

sub get_chr21
{
	my $self = shift;
	return $self->{chr21};
}

sub get_chr22
{
	my $self = shift;
	return $self->{chr22};
}

sub get_chrX
{
	my $self = shift;
	return $self->{chrX};
}

sub get_chrY
{
	my $self = shift;
	return $self->{chrY};
}

# other 

sub print_cytobands
{
    my $self = shift;
    
    $self->get_chr1()->print_cytobands();
    $self->get_chr2()->print_cytobands();
    $self->get_chr3()->print_cytobands();
    $self->get_chr4()->print_cytobands();
    $self->get_chr5()->print_cytobands();
    $self->get_chr6()->print_cytobands();
    $self->get_chr7()->print_cytobands();
    $self->get_chr8()->print_cytobands();
    $self->get_chr9()->print_cytobands();
    $self->get_chr10()->print_cytobands();
    $self->get_chr11()->print_cytobands();
    $self->get_chr12()->print_cytobands();
    $self->get_chr13()->print_cytobands();
    $self->get_chr14()->print_cytobands();
    $self->get_chr15()->print_cytobands();
    $self->get_chr16()->print_cytobands();
    $self->get_chr17()->print_cytobands();
    $self->get_chr18()->print_cytobands();
    $self->get_chr19()->print_cytobands();
    $self->get_chr20()->print_cytobands();
    $self->get_chr21()->print_cytobands();
    $self->get_chr22()->print_cytobands();
    $self->get_chrX()->print_cytobands();
    $self->get_chrY()->print_cytobands();
}

sub get_cytoband_count
{
    my $self = shift;

    my $count = 0;
    $count += $self->get_chr1()->get_cytoband_count();
    $count += $self->get_chr2()->get_cytoband_count();
    $count += $self->get_chr3()->get_cytoband_count();
    $count += $self->get_chr4()->get_cytoband_count();
    $count += $self->get_chr5()->get_cytoband_count();
    $count += $self->get_chr6()->get_cytoband_count();
    $count += $self->get_chr7()->get_cytoband_count();
    $count += $self->get_chr8()->get_cytoband_count();
    $count += $self->get_chr9()->get_cytoband_count();
    $count += $self->get_chr10()->get_cytoband_count();
    $count += $self->get_chr11()->get_cytoband_count();
    $count += $self->get_chr12()->get_cytoband_count();
    $count += $self->get_chr13()->get_cytoband_count();
    $count += $self->get_chr14()->get_cytoband_count();
    $count += $self->get_chr15()->get_cytoband_count();
    $count += $self->get_chr16()->get_cytoband_count();
    $count += $self->get_chr17()->get_cytoband_count();
    $count += $self->get_chr18()->get_cytoband_count();
    $count += $self->get_chr19()->get_cytoband_count();
    $count += $self->get_chr20()->get_cytoband_count();
    $count += $self->get_chr21()->get_cytoband_count();
    $count += $self->get_chr22()->get_cytoband_count();
    $count += $self->get_chrX()->get_cytoband_count();
    $count += $self->get_chrY()->get_cytoband_count();

    return $count;
}

sub get_cytoband_range
{
    my $self = shift;
    my $chr = shift;
    my $range_raw = shift;

    my $first;
    my $last;

    my @cytobands = ();
    
    if ($range_raw =~ m/^([pq].+?)\s{0,1}-\s{0,1}([pq].+?)$/) 
    {
        $first = $1;
        $last = $2;

        @cytobands = @{$self->{$chr}->get_cytoband_list_from_range($first, $last)};
    }

    else 
    { 
        push (@cytobands, $range_raw);
    }

    return \@cytobands; 
}

1;