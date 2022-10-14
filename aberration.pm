use warnings; use strict;
use cytomap;

package aberration;

sub new
{
    my $class = shift;
    my $type = shift;

    my $chromosome;
    my $start;
    my $stop;
    my @cytobands;
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

    my $first_tier = '';
    my $second_tier = '';
    my $third_tier = '';
    my $fourth_tier = '';
    my $polymorphic = '';

    my $self = bless {
        type => $type,                                      # 0  
        chromosome => $chromosome,                          # 1
        start => $start,                                    # 2
        stop => $stop,                                      # 3
        cytobands => \@cytobands,                           # 4
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
        fourth_tier => $fourth_tier,                        # 35    # Filter flag
        polymorphic => $polymorphic                         # 36    # Polymorphic region flag
    }, $class;

    return $self;
}

sub process_aberration
{
    my $self = shift;
    my $raw = shift;
    my $header = shift;
	my $cytomap = shift;

    my @aberration = split("\t", $raw, -1);
    my @column_headers = @{$header->get_column_headers()};

    die "Array aberration sizes don't match\n" unless (scalar(@column_headers) == scalar(@aberration));

    my $pos = 0;

    foreach my $header (@column_headers)
    {
        if ($self->get_type() eq 'Agilent')
        {
            # generic
            if ($header eq 'Chromosome') { $self->set_chromosome($aberration[$pos]); } 
            elsif ($header eq 'Start') { $self->set_start($aberration[$pos]); }
            elsif ($header eq 'Stop') { $self->set_stop($aberration[$pos]);   }
            elsif ($header eq 'Cytoband') 
			{ 
				if (defined($self->get_chromosome()))
				{
					my $cytobands = $cytomap->get_cytoband_range($self->get_chromosome(), $aberration[$pos]);
					$self->set_cytobands($cytobands); 
				}
				else { die "Chromosome column must be ordered before the cytoband column\n"; }
			}
            elsif ($header eq 'Gene Name')
            {
                my @genes = split(/\,/, $aberration[$pos], -1);
                $self->set_genes(\@genes);
            }
            elsif ($header eq 'Size(kb)') { $self->set_size($aberration[$pos]); }
            elsif ($header eq 'Type') { $self->set_event($aberration[$pos]); }
            elsif ($header eq '#Probes') { $self->set_probe_count($aberration[$pos]); } 
            elsif ($header eq 'Classification') { $self->set_classification($aberration[$pos]); }
            elsif ($header eq 'pval') { $self->set_pval($aberration[$pos]); }

            # Agilent-exclusive
            elsif ($header eq 'Mean Log Ratio/LOH Score') { $self->set_mean_log_ratio($aberration[$pos]); }
            elsif ($header eq 'State') { $self->set_state($aberration[$pos]); }
            elsif ($header eq 'ISCN') { $self->set_iscn($aberration[$pos]); }
            elsif ($header eq 'Suppress') { $self->set_suppressed($aberration[$pos]); }
            elsif ($header eq 'VUS') { $self->set_vus($aberration[$pos]); }
            elsif ($header eq 'Copy Number') { $self->set_copy_number($aberration[$pos]); }
            elsif ($header eq 'Deletion LOH') { $self->set_deletion_loh($aberration[$pos]); }
            else { print "Found extra data in aberration call:\t$header\t-\t$aberration[$pos]\n"; }
        }

        elsif ($self->get_type() eq 'Nexus')
        {
            # generic
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

				$self->set_chromosome($chromosome);
				$self->set_start($start);
				$self->set_stop($stop);
            }
            elsif ($header eq 'Cytoband') 
			{ 
				if (defined($self->get_chromosome()))
				{
					my $cytobands = $cytomap->get_cytoband_range($self->get_chromosome(), $aberration[$pos]);
					$self->set_cytobands($cytobands); 
				}
				else { die "Chromosome column must be ordered before the cytoband column\n"; }
			}
            elsif ($header eq 'Gene Symbols')
            {
                my @genes = split(/\,\ /, $aberration[$pos], -1);
				$self->set_genes(\@genes);
            }
            elsif ($header eq 'Length') { $self->set_size($aberration[$pos] / 1000); }
            elsif ($header eq 'Event') { $self->set_event($aberration[$pos]); }
            elsif ($header eq 'Probes') { $self->set_probe_count($aberration[$pos]); }
            elsif ($header eq 'Classification') { $self->set_classification($aberration[$pos]); }
            elsif ($header eq 'Call PValue') { $self->set_pval($aberration[$pos]); }
            
            # Nexus-exclusive
            elsif ($header eq '% of CNV Overlap') { $self->set_cnv_overlap($aberration[$pos]); }
            elsif ($header eq 'Probe Median') { $self->set_probe_median($aberration[$pos]); }
            elsif ($header eq 'Count of Gene Symbols') { $self->set_gene_count($aberration[$pos]); }
            elsif ($header eq '% Heterozygous') { $self->set_percent_heterozygous($aberration[$pos]); }
            elsif ($header eq 'Min Size') { $self->set_min_size($aberration[$pos]); }
            elsif ($header eq 'Max Size') { $self->set_max_size($aberration[$pos]); }
            elsif ($header eq 'Min Region') { $self->set_min_region($aberration[$pos]); }
            elsif ($header eq 'Max Region') { $self->set_max_region($aberration[$pos]); }
            elsif ($header eq 'miRNAs') { $self->set_mirna($aberration[$pos]); }
            elsif ($header eq 'Count of miRNAs') { $self->set_mirna_count($aberration[$pos]); }
            elsif ($header eq 'Locus IDs') { $self->set_locus_ids($aberration[$pos]); }
            elsif ($header eq 'B/P Genes') { $self->set_bp_genes($aberration[$pos]); }
            elsif ($header eq '% Normal') { $self->set_percent_normal($aberration[$pos]); }
            elsif ($header eq 'Notes') { $self->set_notes($aberration[$pos]); }
            else { print "Found extra data in aberration call:\t$header\t-\t$aberration[$pos]\n"; }
        }

        else { die "Type not recognized during aberration processing\n." }

        $pos++;
    }
}

# getters

sub get_type
{
	my $self = shift;
	return $self->{type};
}

sub get_chromosome
{
	my $self = shift;
	return $self->{chromosome};
}

sub get_start
{
	my $self = shift;
	return $self->{start};
}

sub get_stop
{
	my $self = shift;
	return $self->{stop};
}

sub get_cytobands
{
	my $self = shift;
	return $self->{cytobands};
}

sub get_genes
{
	my $self = shift;
	return $self->{genes};
}

sub get_gene_count
{
	my $self = shift;
	return $self->{gene_count};
}

sub get_size
{
	my $self = shift;
	return $self->{size};
}

sub get_event
{
	my $self = shift;
	return $self->{event};
}

sub get_probe_count
{
	my $self = shift;
	return $self->{probe_count};
}

sub get_classification
{
	my $self = shift;
	return $self->{classification};
}

sub get_pval
{
	my $self = shift;
	return $self->{pval};
}

sub get_mean_log_ratio
{
	my $self = shift;
	return $self->{mean_log_ratio};
}

sub get_state
{
	my $self = shift;
	return $self->{state};
}

sub get_iscn
{
	my $self = shift;
	return $self->{iscn};
}

sub get_suppressed
{
	my $self = shift;
	return $self->{suppressed};
}

sub get_vus
{
	my $self = shift;
	return $self->{vus};
}

sub get_copy_number
{
	my $self = shift;
	return $self->{copy_number};
}

sub get_deletion_loh
{
	my $self = shift;
	return $self->{deletion_loh};
}

sub get_cnv_overlap
{
	my $self = shift;
	return $self->{cnv_overlap};
}

sub get_probe_median
{
	my $self = shift;
	return $self->{probe_median};
}

sub get_percent_heterozygous
{
	my $self = shift;
	return $self->{percent_heterozygous};
}

sub get_min_size
{
	my $self = shift;
	return $self->{min_size};
}

sub get_max_size
{
	my $self = shift;
	return $self->{max_size};
}

sub get_min_region
{
	my $self = shift;
	return $self->{min_region};
}

sub get_max_region
{
	my $self = shift;
	return $self->{max_region};
}

sub get_mirna
{
	my $self = shift;
	return $self->{mirna};
}

sub get_mirna_count
{
	my $self = shift;
	return $self->{mirna_count};
}

sub get_locus_ids
{
	my $self = shift;
	return $self->{locus_ids};
}

sub get_bp_genes
{
	my $self = shift;
	return $self->{bp_genes};
}

sub get_percent_normal
{
	my $self = shift;
	return $self->{percent_normal};
}

sub get_notes
{
	my $self = shift;
	return $self->{notes};
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

sub get_polymorphic
{
	my $self = shift;
	return $self->{polymorphic};
}

# setter

sub set_type
{
	my $self = shift;
	my $type = shift;
	$self->{type} = $type;
}

sub set_chromosome
{
	my $self = shift;
	my $chromosome = shift;
	$self->{chromosome} = $chromosome;
}

sub set_start
{
	my $self = shift;
	my $start = shift;
	$self->{start} = $start;
}

sub set_stop
{
	my $self = shift;
	my $stop = shift;
	$self->{stop} = $stop;
}

sub set_cytobands
{
	my $self = shift;
	my $cytobands = shift;
	$self->{cytobands} = $cytobands;
}

sub set_genes
{
	my $self = shift;
	my $genes = shift;
	$self->{genes} = $genes;
}

sub set_gene_count
{
	my $self = shift;
	my $gene_count = shift;
	$self->{gene_count} = $gene_count;
}

sub set_size
{
	my $self = shift;
	my $size = shift;
	$self->{size} = $size;
}

sub set_event
{
	my $self = shift;
	my $event = shift;
	$self->{event} = $event;
}

sub set_probe_count
{
	my $self = shift;
	my $probe_count = shift;
	$self->{probe_count} = $probe_count;
}

sub set_classification
{
	my $self = shift;
	my $classification = shift;
	$self->{classification} = $classification;
}

sub set_pval
{
	my $self = shift;
	my $pval = shift;
	$self->{pval} = $pval;
}

sub set_mean_log_ratio
{
	my $self = shift;
	my $mean_log_ratio = shift;
	$self->{mean_log_ratio} = $mean_log_ratio;
}

sub set_state
{
	my $self = shift;
	my $state = shift;
	$self->{state} = $state;
}

sub set_iscn
{
	my $self = shift;
	my $iscn = shift;
	$self->{iscn} = $iscn;
}

sub set_suppressed
{
	my $self = shift;
	my $suppressed = shift;
	$self->{suppressed} = $suppressed;
}

sub set_vus
{
	my $self = shift;
	my $vus = shift;
	$self->{vus} = $vus;
}

sub set_copy_number
{
	my $self = shift;
	my $copy_number = shift;
	$self->{copy_number} = $copy_number;
}

sub set_deletion_loh
{
	my $self = shift;
	my $deletion_loh = shift;
	$self->{deletion_loh} = $deletion_loh;
}

sub set_cnv_overlap
{
	my $self = shift;
	my $cnv_overlap = shift;
	$self->{cnv_overlap} = $cnv_overlap;
}

sub set_probe_median
{
	my $self = shift;
	my $probe_median = shift;
	$self->{probe_median} = $probe_median;
}

sub set_percent_heterozygous
{
	my $self = shift;
	my $percent_heterozygous = shift;
	$self->{percent_heterozygous} = $percent_heterozygous;
}

sub set_min_size
{
	my $self = shift;
	my $min_size = shift;
	$self->{min_size} = $min_size;
}

sub set_max_size
{
	my $self = shift;
	my $max_size = shift;
	$self->{max_size} = $max_size;
}

sub set_min_region
{
	my $self = shift;
	my $min_region = shift;
	$self->{min_region} = $min_region;
}

sub set_max_region
{
	my $self = shift;
	my $max_region = shift;
	$self->{max_region} = $max_region;
}

sub set_mirna
{
	my $self = shift;
	my $mirna = shift;
	$self->{mirna} = $mirna;
}

sub set_mirna_count
{
	my $self = shift;
	my $mirna_count = shift;
	$self->{mirna_count} = $mirna_count;
}

sub set_locus_ids
{
	my $self = shift;
	my $locus_ids = shift;
	$self->{locus_ids} = $locus_ids;
}

sub set_bp_genes
{
	my $self = shift;
	my $bp_genes = shift;
	$self->{bp_genes} = $bp_genes;
}

sub set_percent_normal
{
	my $self = shift;
	my $percent_normal = shift;
	$self->{percent_normal} = $percent_normal;
}

sub set_notes
{
	my $self = shift;
	my $notes = shift;
	$self->{notes} = $notes;
}

sub set_first_tier
{
    my $self = shift;
    $self->{first_tier} = "Filter 1";
}

sub set_second_tier
{
    my $self = shift;
    $self->{second_tier} = "Filter 2";
}

sub set_third_tier
{
    my $self = shift;
    $self->{third_tier} = "Filter 3";
}

sub set_fourth_tier
{
    my $self = shift;
    $self->{fourth_tier} = "Filter 4";
}

sub set_polymorphic
{
    my $self = shift;
    $self->{polymorphic} = 'Known polymorphic region';
}


1;