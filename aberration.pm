use warnings; use strict;

package aberration;

sub new
{
    my $class = shift;
    my $type = shift;

    my $chromosome;
    my $start;
    my $stop;
    my $cytoband;
    my @genes;
    my $size;
    my $event;
    my $probe_count;
    my $classification;
    my $pval;
    my $gene_count;

    my $mean_log_ratio          = 'Not found - Agilent CytoGenomics exclusive';
    my $state                   = 'Not found - Agilent CytoGenomics exclusive';
    my $iscn                    = 'Not found - Agilent CytoGenomics exclusive';
    my $suppressed              = 'Not found - Agilent CytoGenomics exclusive';
    my $vus                     = 'Not found - Agilent CytoGenomics exclusive';
    my $copy_number             = 'Not found - Agilent CytoGenomics exclusive';
    my $deletion_loh            = 'Not found - Agilent CytoGenomics exclusive';

    my $cnv_overlap             = 'Not found - Nexus exclusive';
    my $probe_median            = 'Not found - Nexus exclusive';
    my $percent_heterozygous    = 'Not found - Nexus exclusive';
    my $min_size                = 'Not found - Nexus exclusive';
    my $max_size                = 'Not found - Nexus exclusive';
    my $min_region              = 'Not found - Nexus exclusive';
    my $max_region              = 'Not found - Nexus exclusive';
    my $mirna                   = 'Not found - Nexus exclusive';
    my $mirna_count             = 'Not found - Nexus exclusive';
    my $locus_ids               = 'Not found - Nexus exclusive';
    my $bp_genes                = 'Not found - Nexus exclusive';
    my $percent_normal          = 'Not found - Nexus exclusive';
    my $notes                   = 'Not found - Nexus exclusive';

    my $first_tier;
    my $second_tier;
    my $third_tier;
    my $fourth_tier;

    my $self = bless {
        type => $type,                                      # 0  
        chromosome => $chromosome,                          # 1
        start => $start,                                    # 2
        stop => $stop,                                      # 3
        cytoband => $cytoband,                              # 4
        genes => \@genes,                                   # 5
        gene_count => $gene_count,                          # 6
        size => $size,                                      # 7     # Shown in kb
        event => $event,                                    # 8
        probe_count => $probe_count,                        # 9
        classification => $classification,                  # 10
        pval => $pval,                                      # 11
        mean_log_ratio => $mean_log_ratio,                  # 12    # Agilent CytoGenomics exclusive metric
        state => $state,                                    # 13    # Agilent CytoGenomics exclusive metric
        iscn => $iscn,                                      # 14    # Agilent CytoGenomics exclusive metric
        suppressed => $suppressed,                          # 15    # Agilent CytoGenomics exclusive metric
        vus => $vus,                                        # 16    # Agilent CytoGenomics exclusive metric
        copy_number => $copy_number,                        # 17    # Agilent CytoGenomics exclusive metric
        deletion_loh => $deletion_loh,                      # 18    # Agilent CytoGenomics exclusive metric
        cnv_overlap => $cnv_overlap,                        # 19    # Nexus exclusive metric
        probe_median => $probe_median,                      # 20    # Nexus exclusive metric
        percent_heterozygous => $percent_heterozygous,      # 21    # Nexus exclusive metric
        min_size => $min_size,                              # 22    # Nexus exclusive metric
        max_size => $max_size,                              # 23    # Nexus exclusive metric
        min_region => $min_region,                          # 24    # Nexus exclusive metric
        max_region => $max_region,                          # 25    # Nexus exclusive metric
        mirna => $mirna,                                    # 26    # Nexus exclusive metric
        mirna_count => $mirna_count,                        # 27    # Nexus exclusive metric
        locus_ids => $locus_ids,                            # 28    # Nexus exclusive metric
        bp_genes => $bp_genes,                              # 29    # Nexus exclusive metric
        percent_normal => $percent_normal,                  # 30    # Nexus exclusive metric
        notes => $notes,                                    # 31    # Nexus exclusive metric
        first_tier => $first_tier,                          # 32    # Filter flag
        second_tier => $second_tier,                        # 33    # Filter flag
        third_tier => $third_tier,                          # 34    # Filter flag
        fourth_tier => $fourth_tier                         # 35    # Filter flag
    }, $class;

    return $self;
}

sub process_aberration
{
    my $self = shift;
    my $raw = shift;
    my $header = shift;
    my @aberration = split("\t", $raw, -1);
    my @column_headers = @{$header->{column_headers}};

    die "Array aberration sizes don't match\n" unless (scalar(@column_headers) == scalar(@aberration));

    my $pos = 0;

    foreach my $header (@column_headers)
    {
        if ($self->{type} eq 'Agilent')
        {
            if ($header eq 'Chromosome')
            {
                $self->{chromosome} = $aberration[$pos]
            }

            elsif ($header eq 'Start')
            {
                $self->{start} = $aberration[$pos]
            }

            elsif ($header eq 'Stop')
            {
                $self->{stop} = $aberration[$pos];                
            }

            elsif ($header eq 'Cytoband')
            {
                $self->{cytoband} = $aberration[$pos];
            }

            elsif ($header eq 'Gene Name')
            {
                my @genes = split(/\,/, $aberration[$pos], -1);
                $self->{genes} = \@genes;
            }

            elsif ($header eq 'Size(kb)')
            {
                $self->{size} = $aberration[$pos];
            }

            elsif ($header eq 'Type')
            {
                $self->{event} = $aberration[$pos];
            }

            elsif ($header eq '#Probes')
            {
                $self->{probe_count} = $aberration[$pos];
            }

            elsif ($header eq 'Classification')
            {
                $self->{classification} = $aberration[$pos];
            }

            elsif ($header eq 'pval')
            {
                $self->{pval} = $aberration[$pos];
            }

            # Agilent-exclusive

            elsif ($header eq 'Mean Log Ratio/LOH Score')
            {
                $self->{mean_log_ratio} = $aberration[$pos];
            }

            elsif ($header eq 'State')
            {
                $self->{state} = $aberration[$pos];
            }

            elsif ($header eq 'ISCN')
            {
                $self->{iscn} = $aberration[$pos];
            }

            elsif ($header eq 'Suppress')
            {
                $self->{suppressed} = $aberration[$pos];
            }

            elsif ($header eq 'VUS')
            {
                $self->{vus} = $aberration[$pos];
            }

            elsif ($header eq 'Copy Number')
            {
                $self->{copy_number} = $aberration[$pos];
            }

            elsif ($header eq 'Deletion LOH')
            {
                $self->{deletion_loh} = $aberration[$pos];
            }

            else
            {
                print "Found extra data in aberration call:\t$header\t-\t$aberration[$pos]\n";
            }
        }

        elsif ($self->{type} eq 'Nexus')
        {
            if ($header eq 'Chromosome Region')
            {
                # chr1:72,811,938-73,941,714
                my $region = $aberration[$pos];
                $region =~ m/(.+?)\:(.*?)\-(.*?)/;
                
                my $chromosome = $1;
                my $start = $2;
                my $stop = $3;

                $start =~ tr/,//;
                $stop =~ tr/,//;

                $self->{chromosome} = $chromosome;
                $self->{start} = $start;
                $self->{stop} = $stop;
            }

            elsif ($header eq 'Cytoband')
            {
                $self->{cytoband} = $aberration[$pos];
            }

            elsif ($header eq 'Gene Symbols')
            {
                my @genes = split(/\,\ /, $aberration[$pos], -1);
                $self->{genes} = \@genes;
            }

            elsif ($header eq 'Length')
            {
                $self->{size} = ($aberration[$pos] / 1000);
            }

            elsif ($header eq 'Event')
            {
                $self->{event} = $aberration[$pos];
            }

            elsif ($header eq 'Probes')
            {
                $self->{probe_count} = $aberration[$pos];
            }

            elsif ($header eq 'Classification')
            {
                $self->{classification} = $aberration[$pos];
            }

            elsif ($header eq 'Call PValue')
            {
                $self->{pval} = $aberration[$pos];
            }

            # Nexus-exclusive

            elsif ($header eq '% of CNV Overlap')
            {
                $self->{cnv_overlap} = $aberration[$pos];
            }

            elsif ($header eq 'Probe Median')
            {
                $self->{probe_median} = $aberration[$pos];
            }

            elsif ($header eq 'Count of Gene Symbols')
            {
                $self->{gene_count} = $aberration[$pos];
            }

            elsif ($header eq '% Heterozygous')
            {
                $self->{percent_heterozygous} = $aberration[$pos];
            }

            elsif ($header eq 'Min Size')
            {
                $self->{min_size} = $aberration[$pos];
            }

            elsif ($header eq 'Max Size')
            {
                $self->{max_size} = $aberration[$pos];
            }

            elsif ($header eq 'Min Region')
            {
                $self->{min_region} = $aberration[$pos];
            }

            elsif ($header eq 'Max Region')
            {
                $self->{max_region} = $aberration[$pos];
            }

            elsif ($header eq 'miRNAs')
            {
                $self->{mirna} = $aberration[$pos];
            }

            elsif ($header eq 'Count of miRNAs')
            {
                $self->{mirna_count} = $aberration[$pos];
            }

            elsif ($header eq 'Locus IDs')
            {
                $self->{locus_ids} = $aberration[$pos];
            }

            elsif ($header eq 'B/P Genes')
            {
                $self->{bp_genes} = $aberration[$pos];
            }

            elsif ($header eq '% Normal')
            {
                $self->{percent_normal} = $aberration[$pos];
            }

            elsif ($header eq 'Notes')
            {
                $self->{notes} = $aberration[$pos];
            }

            else
            {
                print "Found extra data in aberration call:\t$header\t-\t$aberration[$pos]\n";
            }
        }

        else
        {
            die "Type not recognized during aberration processing\n."
        }

        $pos++;
    }
}

sub set_first_tier
{
    my $self = shift;
    $self->{first_tier} = 1;
}

sub set_second_tier
{
    my $self = shift;
    $self->{second_tier} = 1;
}

sub set_third_tier
{
    my $self = shift;
    $self->{third_tier} = 1;
}

sub set_fourth_tier
{
    my $self = shift;
    $self->{fourth_tier} = 1;
}

1;