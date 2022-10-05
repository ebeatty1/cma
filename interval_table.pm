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

    my $self = bless {
        type => $type,                                      # 0     # Interval table type  
        header => $header,                                  # 1     # Reference to a header object
        raw_aberrations => \@raw_aberrations,               # 2     # Reference to an array containing unprocessed aberrations
        aberrations => \@aberrations                        # 3     # Reference to an array containing references to aberration objects
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

    foreach my $aberration (@{$self->{aberrations}})
    {
        foreach my $gene (@{$aberration->{genes}})
        {
            if ( grep( /^$gene$/, @{$first_tier_genes->{genes}} ) ) 
            {
                print "First-tier gene $gene found in ".$aberration->{chromosome}." ".$aberration->{cytoband}." aberration!\n";
                $aberration->set_first_tier();
            }
        }
    }

    print "Aberrations filtered!\n";
}

1;