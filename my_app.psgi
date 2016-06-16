use CGI::PSGI;

my $app = sub {
    my $env = shift;
    my $q = CGI::PSGI->new($env);
    return [ 
        $q->psgi_header('text/plain'),
        [ "Hello ", $q->param('name') ],
    ];
};