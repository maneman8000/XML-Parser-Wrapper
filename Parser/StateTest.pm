package Check_D;
use strict;
use warnings;
use utf8;

sub new {
  my ($class) = @_;
  my $self = {};
  $self->{DATA} = [];
  bless $self, $class;
  return $self;
}

sub StartTag {
  my ($self, $p, $el) = @_;
}

sub EndTag {
  my ($self, $p, $el) = @_;
  push(@{$self->{DATA}}, "$el:" . $p->{DocState}->get_data_top);
}

package Check_A;
use strict;
use warnings;
use utf8;

sub new {
  my ($class) = @_;
  my $self = {};
  $self->{DATA} = [];
  bless $self, $class;
  return $self;
}

sub StartTag {
  my ($self, $p, $el) = @_;
}

sub EndTag {
  my ($self, $p, $el) = @_;
  my $at = $p->{DocState}->get_attribs_top;
  my $str = "$el:" . join(",", map { "$_=\"" . $at->{$_}. '"'; } (sort keys %{$at}));
  push(@{$self->{DATA}}, $str);
}

package Check_T;
use strict;
use warnings;
use utf8;

sub new {
  my ($class, $tag) = @_;
  my $self = {};
  $self->{CHECK_TAG} = $tag;
  $self->{DATA} = [];
  bless $self, $class;
  return $self;
}

sub StartTag {
  my ($self, $p, $el) = @_;
}

sub EndTag {
  my ($self, $p, $el) = @_;
  if ($self->{CHECK_TAG} eq $el) {
    $self->{DATA} = $p->{DocState}->get_parent_tags;
  }
}

package Check_check;
use strict;
use warnings;
use utf8;

sub new {
  my ($class) = @_;
  my $self = {};
  shift;
  $self->{CHECK_TAGS} = {};
  foreach (@_) {
    $self->{CHECK_TAGS}->{$_} = 1;
  }
  bless $self, $class;
  return $self;
}

sub StartTag {
  my ($self, $p, $el) = @_;
}

sub EndTag {
  my ($self, $p, $el) = @_;
  foreach my $t (keys %{$self->{CHECK_TAGS}}) {
    $p->{DocState}->check_tag($t);
  }
}

package Check_T2;
use strict;
use warnings;
use utf8;

#
# StartTagとEndTagでタグトップ名を
# DATA配列にpushする
#

sub new {
  my ($class) = @_;
  my $self = {};
  $self->{DATA} = [];
  bless $self, $class;
  return $self;
}

sub StartTag {
  my ($self, $p, $el) = @_;
  push(@{$self->{DATA}}, $p->{DocState}->get_tag_top);
}

sub EndTag {
  my ($self, $p, $el) = @_;
  push(@{$self->{DATA}}, $p->{DocState}->get_tag_top);
}

package Check_T3;
use strict;
use warnings;
use utf8;

#
# 全データつなげ  <test>タグ終端でバッファに保持
#

sub new {
  my ($class) = @_;
  my $self = {};
  $self->{DATA} = '';
  bless $self, $class;
  return $self;
}

sub EndTag {
  my ($self, $p, $el) = @_;
  if ($el eq 'test') {
    $self->{DATA} = $p->{DocState}->get_data_top;
  }
  else {
    $p->{DocState}->add_data_to_parent("/". $p->{DocState}->get_data_top);
    # 2度目は追加されない
    $p->{DocState}->add_data_to_parent("/". $p->{DocState}->get_data_top);
  }
}

package XML::Parser::StateTest;
use strict;
use utf8;
use Test::Base -base;

use XML::Parser::State;

package XML::Parser::StateTestFilter;
use Test::Base::Filter -base;
use strict;
use utf8;
use Encode;
use XML::Parser;

sub test_endtag_data {
  my ($filename) = @_;
  my $test = new Check_D;
  my $parser = new XML::Parser(ErrorContext => 2,
			       Style => 'MyStream',
			       DocState => new XML::Parser::State,
			       ParseObjs => [
					     $test,
					    ],
			      );
  $parser->parsefile($filename);
  $_ = join(" ", @{$test->{DATA}});
}

sub test_endtag_attribs {
  my ($filename) = @_;
  my $test = new Check_A;
  my $parser = new XML::Parser(ErrorContext => 2,
			       Style => 'MyStream',
			       DocState => new XML::Parser::State,
			       ParseObjs => [
					     $test,
					    ],
			      );
  $parser->parsefile($filename);
  $_ = join(" ", @{$test->{DATA}});
}

sub test_parent_tags {
  my ($filename, $tag) = @_;
  my $test = new Check_T($tag);
  my $parser = new XML::Parser(ErrorContext => 2,
			       Style => 'MyStream',
			       DocState => new XML::Parser::State,
			       ParseObjs => [
					     $test,
					    ],
			      );
  $parser->parsefile($filename);
  $_ = join(" ", @{$test->{DATA}});
}

sub test_check {
  my $filename = shift;
  my $test = new Check_check(@_);
  my $state = new XML::Parser::State;
  $state->enable_check(1);
  my $parser = new XML::Parser(ErrorContext => 2,
			       Style => 'MyStream',
			       DocState => $state,
			       ParseObjs => [
					     $test,
					    ],
			      );
  eval {
    $parser->parsefile($filename);
  };
  if ($@) {
    my $temp = $@;
    $temp =~ s/\n//g;
    $temp =~ s/([a-zA-Z]+ is not checked\!)//;
    $_ = $1;
  }
  else {
    $_ = '';
  }
}

sub test_tag_top {
  my ($filename) = @_;
  my $test = new Check_T2;
  my $parser = new XML::Parser(ErrorContext => 2,
			       Style => 'MyStream',
			       DocState => new XML::Parser::State,
			       ParseObjs => [
					     $test,
					    ],
			      );
  $parser->parsefile($filename);
  $_ = join(" ", @{$test->{DATA}});
}

sub test_add_data {
  my ($filename) = @_;
  my $test = new Check_T3;
  my $parser = new XML::Parser(ErrorContext => 2,
			       Style => 'MyStream',
			       DocState => new XML::Parser::State,
			       ParseObjs => [
					     $test,
					    ],
			      );
  $parser->parsefile($filename);
  $_ = $test->{DATA};
}

1;

