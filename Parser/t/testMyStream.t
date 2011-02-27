use strict;
use warnings;
use utf8;
use Encode;
use XML::Parser::Style::MyStreamTest;

binmode STDERR, ":encoding(cp932)";
binmode STDOUT, ":encoding(cp932)";

plan tests => 1 * blocks;

filters {
  input => [qw/lines chomp/],
    expected => [qw/chomp/],
};

run_is 'input' => 'expected';

__END__
=== test_read_tags 1
--- input XML::Parser::Style::MyStreamTestFilter::test_read_tags
test01.xml
--- expected
<test> <a> あい&cd; </a> <p> うえ <a> お </br> か </a> きく </p> </test>

=== test_whitespace 1
--- input XML::Parser::Style::MyStreamTestFilter::test_whitespace
test03.xml
--- expected
 あい う えa b  &cd;ab  
