package ReadAll;
use strict;
use warnings;
use utf8;
use Encode;

sub new {
  my ($class) = @_;
  my $self = {};
  $self->{DATA} = [];
  bless $self, $class;
  return $self;
}

sub StartTag {
  my ($self, $p, $el) = @_;
  push(@{$self->{DATA}}, "<$el>");
}

sub EndTag {
  my ($self, $p, $el) = @_;
  push(@{$self->{DATA}}, "<\/$el>");
}

sub Text {
  my ($self, $p) = @_;
  push(@{$self->{DATA}}, $p->{Text});
}

package WhiteSpace;
use strict;
use warnings;
use utf8;
use Encode;

sub new {
  my ($class) = @_;
  my $self = {};
  $self->{DATA} = '';
  bless $self, $class;
  return $self;
}

sub Text {
  my ($self, $p) = @_;
  $self->{DATA} .= $p->{Text};
}

package XML::Parser::Style::MyStreamTest;
use strict;
use utf8;
use Test::Base -base;

use XML::Parser::Style::MyStream;

package XML::Parser::Style::MyStreamTestFilter;
use Test::Base::Filter -base;
use strict;
use utf8;
use Encode;
use XML::Parser;

sub test_read_tags {
  my ($filename) = @_;
  my $test = new ReadAll;
  my $parser = new XML::Parser(ErrorContext => 2,
			       Style => 'MyStream',
			       ParseObjs => [
					     $test,
					    ],
			      );
  $parser->parsefile($filename);
  $_ = join(" ", @{$test->{DATA}});
}

sub test_whitespace {
  my ($filename) = @_;
  my $test = new WhiteSpace;
  my $parser = new XML::Parser(ErrorContext => 2,
			       Style => 'MyStream',
			       ParseObjs => [
					     $test,
					    ],
			      );
  $parser->parsefile($filename);
  $_ = $test->{DATA};
}

1;

