    use Kelp::Base;

    attr source => 'dbi:mysql:users';
    attr user   => 'test';
    attr pass   => 'secret';
    attr opts   => { PrintError => 1, RaiseError => 1 };
