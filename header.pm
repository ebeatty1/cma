use warnings; use strict;

package header;

sub new
{
    my $class = shift;
    my $type = shift;

    my $genome_build = 'No genome build found';
    my $title = 'No title found';
    my $scan_date = 'No scan date found';
    my @column_headers;
    my @extra_info;
    my @complete_header;

    my $self = bless {  
        type => $type,                                      # 0     # Agilent or Nexus
        genome_build => $genome_build,                      # 1     # Genome build number or identifier
        title => $title,                                    # 2     # Scan title
        scan_date => $scan_date,                            # 3     # Scan date
        column_headers => \@column_headers,                 # 4     # Reference to an array containing column headers
        extra_info => \@extra_info,                         # 5     # Reference to an array containing miscellaneous header data
        complete_header => \@complete_header                # 6     # Reference to an array containing the entire header
    }, $class;

    return $self;
}

# expects a reference to an array containing the header, split by line
sub process_header
{
    my $self = shift;
    my $header = shift;
    my $header_length = scalar(@$header);
    my $header_pos = 0;

    $self->set_complete_header($header);

    foreach my $line (@$header)
    {
        if ($self->get_type() eq 'Agilent')
        {
            if ($line =~ m/^Genome\t(.*)$/)
            {
                $self->set_genome_build($1);
            }

            elsif ($line =~ m/^Record Name\t(.*)$/)
            {
                $self->set_title($1);
            }

            elsif ($line =~ m/^Creation Date\t(.*)$/)
            {
                $self->set_scan_date($1);
            }
            
            elsif ($header_pos = ($header_length - 1))
            {
                $self->set_column_headers($line);
            }

            else
            {
                $self->add_extra_info($line);
            }
        }

        elsif ($self->get_type() eq 'Nexus')
        {
            if ($line =~ m/^\#Build\s\=\s(.*)$/)
            {
                $self->set_genome_build($1);
            }

            elsif ($line =~ m/^\#Sample\s\=\s(.*)$/)
            {
                $self->set_title($1);
            }

            elsif ($header_pos = ($header_length - 1))
            {
                $self->set_column_headers($line);
            }
            
            else
            {
                $self->add_extra_info($line);
            }
        }    

        else { die "Header type not set properly.\n"; };  

        $header_pos++;  
    }
}

# getters

sub get_type
{
    my $self = shift;
    return $self->{type};
}

sub get_genome_build
{
    my $self = shift;
    return $self->{genome_build};
}

sub get_title
{
    my $self = shift;
    return $self->{title};
}

sub get_scan_date
{
    my $self = shift;
    return $self->{scan_date};
}

sub get_column_headers
{
    my $self = shift;
    return $self->{column_headers};
}

sub get_extra_info
{
    my $self = shift;
    return $self->{extra_info};
}

sub get_complete_header
{
    my $self = shift;
    return $self->{complete_header};
}

# setters

sub set_type
{
    my $self = shift;
    my $type = shift;
    $self->{type} = $type;
}

sub set_genome_build
{
    my $self = shift;
    my $genome_build = shift;
    $self->{genome_build} = $genome_build;
}

sub set_title
{
    my $self = shift;
    my $title = shift;
    $self->{title} = $title;
}

sub set_scan_date
{
    my $self = shift;
    my $scan_date = shift;
    $self->{scan_date} = $scan_date;
}

sub set_column_headers
{
    my $self = shift;
    my $column_header = shift;
    my @column_headers = split(/\t/, $column_header, -1);
    $self->{column_headers} = \@column_headers;
}

sub add_extra_info
{
    my $self = shift;
    my $extra_info = shift;
    push(@{$self->{extra_info}}, $extra_info);
}

sub set_complete_header
{
    my $self = shift;
    my $complete_header = shift;
    $self->{complete_header} = $complete_header;
}

# other

sub print_column_headers
{
    my $self = shift;
    foreach my $column_header (@{$self->get_column_headers()})
    {
        print "$column_header\t";
    }
    print "\n";
}

sub print_extra_info
{
    my $self = shift;
    foreach my $extra_info (@{$self->get_extra_info()})
    {
        print "$extra_info\n";
    }
}

sub print_complete_header
{
    my $self = shift;
    foreach my $line (@{$self->get_complete_header()})
    {
        print "$line\n";
    }
}

1;