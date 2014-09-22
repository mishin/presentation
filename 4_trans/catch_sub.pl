use Modern::Perl;
use Parse::RecDescent;

my $perl_code1  = q{my >test1$ string3 = $object->oldSub(6,7);};
my $perl_code2  = q{test1$ string3 = $object->oldSub(6,7);};
my $perl_code3  = q{my test1$ string3 = $object->oldSub(6,7);};
my @perl_lines  = ( $perl_code1, $perl_code2, $perl_code3 );
my $var         = 'test1';
my $sub_grammar = q{
    
    get_sub: 
           NOWORD TEST NOWORD
               {print $item[2]}      
           |TEST NOWORD
              {print $item[1]}     
      
    get_sub2: 
           WORD TEST NOWORD
               {print $item[2]}      
           |TEST NOWORD
              {print $item[1]}     
 
    WORD: 
        /\w+/    
    NOWORD: 
        /\W+/            
    TEST: 
        /} . $var . q{/
    };
my $sub_parse = new Parse::RecDescent($sub_grammar);
say 'example1:';

for my $string1 (@perl_lines) {
    say " Valid sub:$string1\n" if $sub_parse->get_sub($string1);
}

say 'example2:';
for my $string2 (@perl_lines) {
    say " Valid sub:$string2\n" if $sub_parse->get_sub2($string2);
}
