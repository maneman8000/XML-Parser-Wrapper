package XML::Parser::State;

use strict;
use warnings;
use Carp;
use utf8;

sub new {
  my ($class) = @_;
  my $self = {};
  # if ENABLE_CHECK equal 1 then raise error if a tag was not checked
  $self->{ENABLE_CHECK} = 0;
  # add_data_to_parent only adds first data if it is called 2 more
  $self->{ADD_PARENT_FLAG} = 0;
  bless $self, $class;
  return $self;
}

sub StartDocument {
  my ($self, $p) = @_;
  $self->{D_ST} = [];
  $self->{A_ST} = [];
  $self->{T_ST} = [];
  $self->{CHECK_TAG} = [];
  $self->{EMP_ST} = [];
}

sub StartTag {
  my ($self, $is_emptag, $p, $el) = (shift, shift, shift, shift);
  $self->{ADD_PARENT_FLAG} = 0;
  push(@{$self->{D_ST}}, '');
  push(@{$self->{A_ST}}, {@_});
  push(@{$self->{T_ST}}, $el);
  push(@{$self->{CHECK_TAG}}, 0);
  push(@{$self->{EMP_ST}}, $is_emptag);
}

sub EndTagPre {
  my ($self, $p, $el) = @_;
  $self->{ADD_PARENT_FLAG} = 0;
}

sub EndTag {
  my ($self, $p, $el) = @_;
  pop(@{$self->{D_ST}});
  pop(@{$self->{A_ST}});
  pop(@{$self->{EMP_ST}});
  my $t = pop(@{$self->{T_ST}});
  my $c = pop(@{$self->{CHECK_TAG}});
  if ($self->{ENABLE_CHECK} and !$c) {
    croak "$t is not checked! at ", $p->current_line;
  }
}

sub Text {
  my ($self, $p) = @_;
  $self->{D_ST}->[-1] .= $p->{Text} if (@{$self->{D_ST}});
}

sub EndDocument {
  my ($self, $p) = @_;
  if (@{$self->{D_ST}} > 0
      or @{$self->{A_ST}} > 0) {
    croak "EndDocument Stack is not zero!";
  }
}

sub get_data_top {
  my ($self) = @_;
  return (@{$self->{D_ST}}) ? $self->{D_ST}->[-1] : '';
}

sub add_data {
  my $self = shift;
  if (@{$self->{D_ST}}) {
    $self->{D_ST}->[-1] .= $_ foreach (@_);
  }
}

sub add_data_to_parent {
  my $self = shift;
  if (@{$self->{D_ST}} > 1 and $self->{ADD_PARENT_FLAG} == 0) {
    $self->{D_ST}->[-2] .= $_ foreach (@_);
    $self->{ADD_PARENT_FLAG} = 1;
  }
}

sub get_parent_data {
  my ($self) = @_;
  return (@{$self->{D_ST}} > 1) ? $self->{D_ST}->[-2] : '';
}

sub get_attribs_top {
  my ($self) = @_;
  return (@{$self->{A_ST}}) ? $self->{A_ST}->[-1] : '';
}

sub get_tag_top {
  my ($self) = @_;
  return (@{$self->{T_ST}}) ? $self->{T_ST}->[-1] : '';
}

sub get_parent_tags {
  my ($self) = @_;
  return [@{$self->{T_ST}}[0..($#{$self->{T_ST}} - 1)]];
}

sub enable_check {
  my ($self, $ec) = @_;
  $self->{ENABLE_CHECK} = $ec;
}

sub check_tag {
  my ($self, $exp) = @_;
  if ($self->{T_ST}->[-1] eq $exp) {
    $self->{CHECK_TAG}->[-1] = 1;
    return 1;
  }
  else {
    return 0;
  }
}

sub is_empty_tag {
  my ($self) = @_;
  return (@{$self->{EMP_ST}}) ? $self->{EMP_ST}->[-1] : 0;
}

#
# utility methos
#

sub have_attrib {
  my ($self, $at) = @_;
  return exists $self->get_attribs_top->{$at};
}

sub get_attrib_val {
  my ($self, $at) = @_;
  return '' unless $self->have_attrib($at);
  return $self->get_attribs_top->{$at};
}

1;

