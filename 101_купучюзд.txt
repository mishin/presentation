
use MIME::QuotedPrint qw(encode_qp);
use Encode qw(encode);
 
$encoded = encode_qp(encode("UTF-8", "\x{FFFF}\n"));
print $encoded;