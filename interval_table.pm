use warnings; use strict;
use aberration; use header;

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

    my $self = bless {
        type => $type,                                      # 0     # Interval table type  
        header => $header,                                  # 1     # Reference to a header object
        raw_aberrations => \@raw_aberrations,               # 2     # Reference to an array containing unprocessed aberrations
        aberrations => \@aberrations,                       # 3     # Reference to an array containing references to aberration objects
        first_tier => \@first_tier,                         # 4     # Reference to an array containing references to aberrations flagged as being tier-1
        second_tier => \@second_tier,                       # 5     # Reference to an array containing references to aberrations flagged as being tier-2
        third_tier => \@third_tier                          # 6     # Reference to an array containing references to aberrations flagged as being tier-3
    }, $class;

    return $self;
}

# expects a file handle to an Agilent or Nexus interval table file
sub process_table
{
    my $self = shift;
    my $tableHandle = shift;

    die "File handle expected but not received.\n" unless $tableHandle;
    die "Valid file handle expected but not received.\n" unless fileno($tableHandle) != -1;
    
    my @header;
    my $headerProcessed = 0;

    while (my $line = <$tableHandle>)
    {    
        chomp($line);

        # start by guessing the type based on the first line of the export table
        # Agilent CytoGenomics starts with the word 'title': 
        #       title:	INTERVAL_TABLE
        # Nexus Copy Number starts with a pound sign:
        #       #Build = NCBI Build 37
        
        if (!$self->{type})
        {
            if      ($line =~ m/^title\:.*/)    { $self->{type} = 'Agilent'; }
            elsif   ($line =~ m/^\#.*/)         { $self->{type} = 'Nexus'; }
            else                                { $self->{type} = 'Unknown'; }

            die "Unrecognized interval table format detected.\n" unless $self->{type} ne 'Unknown';

            push(@header, $line);

            # debug
            print $self->{type}."\n";
        }

        # process the second line through the end of the header
        elsif (!$headerProcessed)
        {
            if ($self->{type} eq 'Agilent') 
            {
                push(@header, $line);

                if ($line eq '')
                {
                    $headerProcessed = 1;

                    # debug
                    print "Last line of Agilent header found!\n";
                }
            }

            elsif ($self->{type} eq 'Nexus') 
            {
                push(@header, $line);

                if ($line =~ m/^[^#].*/)
                {
                    $headerProcessed = 2;
                }
            }

            else { die "Unrecognized interval table format detected.\n"; }
        }

        # process the last line of the header for Agilent tables
        elsif ($self->{type} eq 'Agilent' && $headerProcessed == 1)
        {
            push(@header, $line);
            $headerProcessed = 2;

            # debug
            print "Header fully processed\n"
        }

        # prepare the aberrations for later processing
        elsif ($headerProcessed == 2)
        {
            if ($line =~ m/^\S/)
            {
                $self->add_raw_aberration($line);
            }
            
            else
            {
                last;
            }
        }

        else { die "Failure during interval table processing. Investigate.\n"; }
    }

    # debug
    print scalar(@header)." lines in processed header\n";

    my $header = header->new($self->{type});
    $header->process_header(\@header);
    $self->set_header($header);

    $self->process_aberrations();

    print "Input table has ".$self->get_aberration_count()." aberration calls.\n";
    # print "Input table header has ".scalar(@tableHeader)." lines.\n";
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

sub get_raw_aberration_count
{
    my $self = shift;
    return scalar(@{$self->{raw_aberrations}});
}

sub process_aberrations
{
    my $self = shift;
    foreach my $raw_aberration (@{$self->{raw_aberrations}})
    {
        my $aberration = aberration->new($self->{type});
        $aberration->process_aberration($raw_aberration, $self->{header});
        $self->add_aberration($aberration);
    }
}

sub add_aberration
{
    my $self = shift;
    my $aberration = shift;
    push(@{$self->{aberrations}}, $aberration);
}

sub get_aberration_count
{
    my $self = shift;
    return scalar(@{$self->{aberrations}});
}

# placeholder function that needs completion
sub filter_aberrations
{
    my $self = shift;
    my $first_tier_genes = shift;
    my $second_tier_genes = shift;

    # tier 1 and tier 2 flagging
    foreach my $aberration (@{$self->{aberrations}})
    {
        foreach my $gene (@{$aberration->{genes}})
        {
            # tier 1 flagging
            if ( grep( /^$gene$/, @{$first_tier_genes->{genes}} ) ) { $aberration->set_first_tier(); }

            # tier 2 flagging
            if ( grep( /^$gene$/, @{$second_tier_genes->{genes}} ) ) { $aberration->set_second_tier(); }
        }

        # tier 3 flagging
        if ($aberration->{size} >= 1000 && $aberration->{type} ne 'LOH') { $aberration->set_third_tier(); }

        # tier 4 flagging
        if ($aberration->{size} >= 5000 && $aberration->{type} eq 'LOH') { $aberration->set_fourth_tier(); }
    }

    foreach my $aberration (@{$self->{aberrations}})
    {
        if ($aberration->{first_tier}) { $self->add_first_tier_aberration($aberration); }

        elsif ($aberration->{second_tier}) { $self->add_second_tier_aberration($aberration); }

        elsif ($aberration->{third_tier}) { $self->add_third_tier_aberration($aberration); }

        elsif ($aberration->{fourth_tier}) { $self->add_fourth_tier_aberration($aberration); }
    }

    $self->print_filtered();

    print "Aberrations filtered!\n";
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

sub print_filtered
{
    my $self = shift;

    print "\nFirst-tier aberrations: CHD gene\n";
    print "----------------------------------\n";
    foreach my $aberration (@{$self->{first_tier}})
    {
        print $aberration->{event}."\t".$aberration->{chromosome}."\t".$aberration->{cytoband}."\t".$aberration->{size}."\t";
        # foreach my $gene (@{$aberration->{genes}}) { print $gene.","; }
        print "\n";
    }
    print "\n";

    print "Second-tier aberrations: CVD gene\n";
    print "---------------------------------\n";
    foreach my $aberration (@{$self->{second_tier}})
    {
        print $aberration->{event}."\t".$aberration->{chromosome}."\t".$aberration->{cytoband}."\t".$aberration->{size}."\t";
        # foreach my $gene (@{$aberration->{genes}}) { print $gene.","; }
        print "\n";
    }
    print "\n";

    print "Third-tier aberrations: Size > 1 MB and not LOH\n";
    print "-----------------------------------------------\n";
    foreach my $aberration (@{$self->{third_tier}})
    {
        print $aberration->{event}."\t".$aberration->{chromosome}."\t".$aberration->{cytoband}."\t".$aberration->{size}."\t";
        # foreach my $gene (@{$aberration->{genes}}) { print $gene.","; }
        print "\n";
    }
    print "\n";

    print "Fourth-tier aberrations: Size > 5 MB and LOH\n";
    print "--------------------------------------------\n";
    foreach my $aberration (@{$self->{fourth_tier}})
    {
        print $aberration->{event}."\t".$aberration->{chromosome}."\t".$aberration->{cytoband}."\t".$aberration->{size}."\t";
        # foreach my $gene (@{$aberration->{genes}}) { print $gene.","; }
        print "\n";
    }
    print "\n";
}

1;