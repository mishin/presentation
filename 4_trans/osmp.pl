my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");
my $req = HTTP::Request->new(POST => 'http://xml1.osmp.ru/term2/xml.jsp');
$req->content_type('application/octet-stream');
$req->content('<?xml version="1.0"
encoding="utf-8"?>                                                                                                                                 

<request>                                                                                                                                                              

  <auth
signAlg="MD5"                                                                                                                                                  


sign="9244cc4142b289371cf4f64f5c249ec2"                                                                                                                        


login="erik0">                                                                                                                                           

    <client software="BankSkidok
0.1"                                                                                                                                  

terminal="Александр"                                                                                                                                                   


serial="9276915">                                                                                                                                          


<system>                                                                                                                                                      

        <getResultCodes
/>                                                                                                                                             


</system>                                                                                                                                                     


</client>                                                                                                                                                          


</auth>                                                                                                                                                              

</request>                                                                                                                                                             

');

# Pass request to the user agent and get a response
back                                                                                                               

my $res = $ua->request($req);

# Check the outcome of the
response                                                                                                                                    

if ($res->is_success) {
  print $res->content;
}
else {
  print $res->status_line, "\n";
}

Все просто. Ответ тоже простой

<?xml version="1.0" encoding="windows-1251"?>
<response> <result-code fatal="true">202</result-code> </response>