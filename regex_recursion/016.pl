    #use v5.12;
    use Modern::Perl;

    #use File::Slurp qw(read_file write_file);
    use Data::Dumper qw(Dumper);
    my $filename = 'short_example.dsx';
    my $ref_source_data = import_sql_and_data();
    my $data           = $ref_source_data->{$filename};#'short_example.dsx';# read_file($filename);

    #say Dumper $data;
    my $header_and_job = split_by_header_and_job($data);
    #say Dumper $header_and_job;
    my $header_fields  = split_fields_by_new_line( $header_and_job->{header} );
    #my $header_fields  = split_fields_by_new_line( $header_and_job->{job} );
    say Dumper $header_fields;

    sub split_by_header_and_job {
        my $data = shift;
        local $/ = '';    # Paragraph mode
        my %header_and_job = ();
        my @fields         = ();
        $data =~ /
    (?<header>
    BEGIN[ ]HEADER
    .*?
    END[ ]HEADER
    )
    .*?
    (?<job>
    BEGIN[ ]DSJOB
    .*?
    END[ ]DSJOB )
    /xsg
          ;
        %header_and_job = %+;
        return \%header_and_job;
    }

    sub split_fields_by_new_line {
        my ($curr_record)     = @_;
        #my %fields_and_values = ();
        my @fields            = ();
        local $/ = '';    # Paragraph mode
        while (
            $curr_record =~ m/
       (?(DEFINE)
                (?<short_quote> ["] )
    	        (?<long_quote> \Q=+=+=+=\E )
    	        (?<not_back_slash> (?<!\\) )
    	        (?<quote> (?&short_quote)|(?&long_quote) )
    	        (?<val> (?<value>.*?) )
    	    )
            (?<name>\w+)[ ]
            (?&quote)
            (?<value>.*?)
            (?&not_back_slash)
            (?&quote)
            /xsg	
          )
        {
            my %hash_value = %+;
            push @fields, \%hash_value;
        }
        return \@fields;
    }

    sub import_sql_and_data {
        print {*STDERR} "Reading sql query...\n";
        my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };
        for ( values %contents_of ) {
            s/^!=([a-z])/=$1/gxms;
        }
        print {*STDERR} "done\n";
        return \%contents_of;
    }


    __DATA__

    _____[ short_example.dsx ]________________________________________________
    BEGIN HEADER
       CharacterSet "CP1251"
       ExportingTool "IBM Websphere DataStage Export"
       ServerName "YAPC"
       ToolInstanceID "Russia"
    END HEADER
    BEGIN DSJOB
       Identifier "Parse_DSX"
       DateModified "2024-09-08"
       TimeModified "13.03.02"
       BEGIN DSRECORD
          Identifier "ROOT"
          OLEType "CJobDefn"
          Readonly "0"
          Name "Parse_DSX"
          ControlAfterSubr "0"
          Parameters "CParameters"
          MetaBag "CMetaProperty"
          BEGIN DSSUBRECORD
             Owner "APT"
             Name "AdvancedRuntimeOptions"
             Value "#DSProjectARTOptions#"
          END DSSUBRECORD
          BEGIN DSSUBRECORD
             Owner "APT"
             Name "ClientCodePage"
             Value "1251"
          END DSSUBRECORD
          NULLIndicatorPosition "0"
          OrchestrateCode =+=+=+=
    #################################################################
    #### STAGE: T201
    ## Operator
    transform
    ## Operator options
    -flag run
    -name 'Russia_YAPC_Ryasan_2015'

    ## General options
    [ident('T201'); jobmon_ident('T201')]
    ## Inputs
    0< [] 'Ryazan_client:L201.v'
    ## Outputs
    0> [] 'T201:L01.v'
    1> [] 'T201:L202.v'
    ;


    =+=+=+=
          IsTemplate "0"
          NLSLocale ",,,,"
          JobType "3"
          ValidationStatus "0"
          RecordPerformanceResults "0"
       END DSRECORD
    END DSJOB
