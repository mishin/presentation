sub split_by_header_and_job {
	    my $data = shift;
	        local $/ = '';    # Paragraph mode
		    my %header_and_job = ();
		        my @fields         = ();

			    #@fields = (
			    #    $data =~ /
			    #    (?<header>
			    #    BEGIN[ ]HEADER
			    #    .*?
			    #    END[ ]HEADER
			    #    )
			    #    .*?
			    #    (?<job>
			    #    BEGIN[ ]DSJOB
			    #    .*?
			    #    END[ ]DSJOB )
			    #    /xsg
			    #          ;
			    #              %header_and_job = %+;
			    #                  return \%header_and_job;
			    #                  }
