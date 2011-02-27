use strict;
use warnings;
use utf8;
use Encode;
use XML::Parser::StateTest;

binmode STDERR, ":encoding(cp932)";
binmode STDOUT, ":encoding(cp932)";

plan tests => 1 * blocks;

filters {
  input => [qw/lines chomp/],
    expected => [qw/chomp/],
};

run_is 'input' => 'expected';

__END__
=== test_endtag_data 1
--- input XML::Parser::StateTestFilter::test_endtag_data
test02.xml
--- expected
br: c:え b:う a:あい&cd; test:

=== test_endtag_attribs 1
--- input XML::Parser::StateTestFilter::test_endtag_attribs
test02.xml
--- expected
br: c:at1c="at1c" b:at1b="at1b",at2b="at2b" a:at1="at1",at2="at2" test:

=== test_parent_tags 1
--- input XML::Parser::StateTestFilter::test_parent_tags
test03.xml
c
--- expected
test a b

=== test_check 1
--- input XML::Parser::StateTestFilter::test_check
test03.xml
a
b
c
--- expected
br is not checked!

=== test_check 2
--- input XML::Parser::StateTestFilter::test_check
test03.xml
a
br
b
--- expected
c is not checked!

=== test_tag_top 1
--- input XML::Parser::StateTestFilter::test_tag_top
test01.xml
--- expected
test a a p a br a p test

=== test_add_data 1
--- input XML::Parser::StateTestFilter::test_add_data
test01.xml
--- expected
/あい&cd;/うえ/お/かきく
