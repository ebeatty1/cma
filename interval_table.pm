use warnings; use strict;
use header; use aberration;

package interval_table;

sub new
{
    my $class = shift;

    my $type;
    my $header;
    my @raw_aberrations;
    my @aberrations;
    my @first_tier;
    my @second_tier;
    my @third_tier;
    my @fourth_tier;
    my @unflagged;

    my $self = bless {
        type => $type,                                      # 0     # Interval table type  
        header => $header,                                  # 1     # Reference to a header object
        raw_aberrations => \@raw_aberrations,               # 2     # Reference to an array containing unprocessed aberrations
        aberrations => \@aberrations,                       # 3     # Reference to an array containing references to processed aberration objects
        first_tier => \@first_tier,                         # 4     # Reference to an array containing references to aberrations flagged as being tier 1
        second_tier => \@second_tier,                       # 5     # Reference to an array containing references to aberrations flagged as being tier 2
        third_tier => \@third_tier,                         # 6     # Reference to an array containing references to aberrations flagged as being tier 3
        fourth_tier => \@fourth_tier,                       # 7     # Reference to an array containing references to aberrations flagged as being tier 4
        unflagged => \@unflagged                            # 8     # Reference to an array containing references to aberrations that weren't flagged
    }, $class;

    return $self;
}

# expects a file handle to an Agilent CytoGenomics or Nexus Copy Number interval table file
sub process_table
{
    my $self = shift;
    my $tableHandle = shift;
    my $cytomap = shift;

    die "File handle expected but not received.\n" unless $tableHandle;
    die "Valid file handle expected but not received.\n" unless fileno($tableHandle) != -1;
    
    my @header;
    my $headerProcessed = 0;

    while (my $line = <$tableHandle>)
    {    
        chomp($line);

        # start by guessing the table type based on the first line of the export table
        # Agilent CytoGenomics starts with the word 'title': 
        #       title:	INTERVAL_TABLE
        # Nexus Copy Number starts with a pound sign:
        #       #Build = NCBI Build 37
        
        if (!$self->get_type())
        {
            if      ($line =~ m/^title\:.*/)    { $self->set_type('Agilent'); }
            elsif   ($line =~ m/^\#.*/)         { $self->set_type('Nexus'); }
            else                                { die "Unrecognized interval table format detected.\n"; }

            push(@header, $line);
        }

        # process the second line through the end of the header
        elsif (!$headerProcessed)
        {
            if ($self->get_type() eq 'Agilent') 
            {
                push(@header, $line);

                if ($line eq '') { $headerProcessed = 1; }
            }

            elsif ($self->get_type() eq 'Nexus') 
            {
                push(@header, $line);

                if ($line =~ m/^[^#].*/) { $headerProcessed = 2; }
            }

            else { die "Failure during interval table header processing. Investigate.\n"; }
        }

        # process the last line of the header for Agilent tables
        elsif ($self->get_type() eq 'Agilent' && $headerProcessed == 1)
        {
            push(@header, $line);
            $headerProcessed = 2;
        }

        # prepare the aberrations for later processing
        elsif ($headerProcessed == 2)
        {
            if ($line =~ m/^\S/)
            {
                $self->add_raw_aberration($line);
            }
            
            else { last; } 
        }

        else { die "Failure during interval table processing. Investigate.\n"; }
    }

    my $header = header->new($self->get_type());
    $header->process_header(\@header);
    $self->set_header($header);

    $self->process_aberrations($cytomap);
}

# getters

sub get_type
{
    my $self = shift;
    return $self->{type};
}

sub get_header
{
    my $self = shift;
    return $self->{header};
}

sub get_raw_aberrations
{
    my $self = shift;
    return $self->{raw_aberrations};
}

sub get_aberrations
{
    my $self = shift;
    return $self->{aberrations};
}

sub get_first_tier
{
    my $self = shift;
    return $self->{first_tier};
}

sub get_second_tier
{
    my $self = shift;
    return $self->{second_tier};
}

sub get_third_tier
{
    my $self = shift;
    return $self->{third_tier};
}

sub get_fourth_tier
{
    my $self = shift;
    return $self->{fourth_tier};
}

sub get_unflagged
{
    my $self = shift;
    return $self->{unflagged};
}

# setters

sub set_type
{
    my $self = shift;
    my $type = shift;
    $self->{type} = $type;
}

sub set_header
{
    my $self = shift;
    my $header = shift;
    $self->{header} = $header;
}

sub add_raw_aberration
{
    my $self = shift;
    my $raw_aberration = shift;
    push(@{$self->{raw_aberrations}}, $raw_aberration);
}

sub add_aberration
{
    my $self = shift;
    my $aberration = shift;
    push(@{$self->{aberrations}}, $aberration);
}

sub add_first_tier_aberration
{
    my $self = shift;
    my $aberration = shift;
    push(@{$self->{first_tier}}, $aberration);
}

sub add_second_tier_aberration
{
    my $self = shift;
    my $aberration = shift;
    push(@{$self->{second_tier}}, $aberration);
}

sub add_third_tier_aberration
{
    my $self = shift;
    my $aberration = shift;
    push(@{$self->{third_tier}}, $aberration);
}

sub add_fourth_tier_aberration
{
    my $self = shift;
    my $aberration = shift;
    push(@{$self->{fourth_tier}}, $aberration);
}

sub add_unflagged_aberration
{
    my $self = shift;
    my $aberration = shift;
    push(@{$self->{unflagged}}, $aberration);
}

# other

sub process_aberrations
{
    my $self = shift;
    my $cytomap = shift; 

    foreach my $raw_aberration (@{$self->get_raw_aberrations()})
    {
        my $aberration = aberration->new($self->get_type());
        $aberration->process_aberration($raw_aberration, $self->get_header(), $cytomap);
        $self->add_aberration($aberration);
    }
}

sub filter_aberrations
{
    my $self = shift;
    my $first_tier_genes = shift;
    my $second_tier_genes = shift;

    foreach my $aberration (@{$self->get_aberrations()})
    {
        foreach my $gene (@{$aberration->get_genes()})
        {
            # tier 1 flagging
            if ( grep( /^$gene$/, @{$first_tier_genes->get_genes()} ) ) 
            { 
                $aberration->set_first_tier(); 
                $aberration->add_primary_gene($gene);
            }

            # tier 2 flagging
            if ( grep( /^$gene$/, @{$second_tier_genes->get_genes()} ) ) 
            { 
                $aberration->set_second_tier(); 
                $aberration->add_secondary_gene($gene);
            }
        }

        # tier 3 flagging
        if ($aberration->get_size() >= 1000 && $aberration->get_event() ne 'LOH') { $aberration->set_third_tier(); }

        # tier 4 flagging
        if ($aberration->get_size() >= 5000 && $aberration->get_event() eq 'LOH') { $aberration->set_fourth_tier(); }

        # polymorphic region flagging - needs completion
        if (1 == 0) { $aberration->set_polymorphic(); }
    }

    foreach my $aberration (@{$self->get_aberrations()})
    {
        if ($aberration->get_first_tier()) { $self->add_first_tier_aberration($aberration); }

        elsif ($aberration->get_second_tier()) { $self->add_second_tier_aberration($aberration); }

        elsif ($aberration->get_third_tier()) { $self->add_third_tier_aberration($aberration); }

        elsif ($aberration->get_fourth_tier()) { $self->add_fourth_tier_aberration($aberration); }

        else { $self->add_unflagged_aberration($aberration) } 
    }
}

sub print_filtered
{
    my $self = shift;
    my $print_full = shift;

    $self->print_group("Aberration matches against primary gene list: CHD", "first_tier", $print_full);
    $self->print_group("Aberration matches against secondary gene list: CVD", "second_tier", $print_full);
    $self->print_group("Aberration size > 1 MB and not LOH", "third_tier", $print_full);
    $self->print_group("Aberration size > 5 MB and LOH", "fourth_tier", $print_full);
    $self->print_group("Unflagged aberrations", "unflagged", $print_full);

    print "\n";
}

sub print_group
{
    my $self = shift;
    my $title = shift;
    my $group = shift;
    my $print_full = shift;

    my $index = 0;

    print "\n";
    print $title."\n";
    print "-" x length($title)."\n";

    foreach my $aberration (@{$self->{$group}})
    {
        print $aberration->get_event()."\t";
        print $aberration->get_chromosome()."\t";
        
        if ($print_full)
        {
            foreach my $cytoband (@{$aberration->get_cytobands()}) 
            { 
                print $cytoband;
                if ($index >= scalar(@{$aberration->get_cytobands()}) - 1) { last; } 
                
                $index++;
                print ", "; 
            }
        }

        else 
        {
            print ${$aberration->get_cytobands()}[0];

            if (scalar(@{$aberration->get_cytobands()}) > 1)
            {
                print "-".${$aberration->get_cytobands()}[scalar(@{$aberration->get_cytobands()}) - 1];
            }
        }
        
        print "\t";
        print $aberration->get_size()."\t";
        
        $index = 0;
        foreach my $gene (@{$aberration->get_primary_genes()}) 
        { 
            print $gene;
            if ($index >= scalar(@{$aberration->get_primary_genes()}) - 1) { last; } 
            $index++;
            print ", "; 
        }

        print "\t";

        $index = 0;
        foreach my $gene (@{$aberration->get_secondary_genes()}) 
        { 
            print $gene;
            if ($index >= scalar(@{$aberration->get_secondary_genes()}) - 1) { last; } 
            $index++;
            print ", "; 
        }

        print "\t";

        print $aberration->get_third_tier()."\t";
        print $aberration->get_fourth_tier()."\t";
        # print $aberration->get_polymorphic()."\t";

        $index = 0;
        foreach my $classification (@{$aberration->get_region_classifications})
        {
            print $classification;
            if ($index >= scalar(@{$aberration->get_region_classifications()}) - 1) { last; } 
            $index++;
            print ", "; 
        }
        
        $index = 0;
        if ($print_full)
        {
            foreach my $gene (@{$aberration->get_genes()}) 
            { 
                print $gene;
                if ($index >= scalar(@{$aberration->get_genes()}) - 1) { last; } 
                $index++;
                print ", "; 
            }
        }

        print "\n";
    }
}

1;