package XML::Parser::Style::MyStream;

use strict;
use warnings;
use Carp;
use utf8;

sub Init {
  no strict 'refs';
  my $expat = shift;
  $expat->{Text} = '';
  eval {
    foreach my $o (@{$expat->{ParseObjs}}) {
      $o->StartDocument($expat) if ($o->can("StartDocument"));
    }

    #
    # xml:space="preserve"の実装について。
    # この流れだと<a>a </a><b> b</b>
    # という形が "a  b" となってしまう。
    # "a b"にしなければいけないのか不明でもあるため
    # とりあえずこのままとする
    #
    $expat->{XmlWhiteSpaceHandling} = [0]; # default: 0, preserve: 1
  };
  if ($@) {
    croak "error at line (", $expat->current_line, ")\n$@";
  }
}

sub is_empty_tag {
  my $str = shift;
  return ($str =~ /\/\s*>/);
}

sub Start {
  no strict 'refs';
  my $expat = shift;
  eval {
    doText($expat);
    pushXmlSpace($expat, @_[1..$#_]);
    my $is_emptag = is_empty_tag($expat->original_string);
    # DocStateのStartTagは常に呼ばれる
    if (defined $expat->{DocState}) {
      $expat->{DocState}->StartTag($is_emptag, $expat, @_);
    }
    # empty tag (ex: <br/>) はStartTag呼ばれなくする
    # 見分け方は、もっといい方法あるかも
    unless ($is_emptag) {
      foreach my $o (@{$expat->{ParseObjs}}) {
	$o->StartTag($expat, @_) if ($o->can("StartTag"));
      }
    }
  };
  if ($@) {
    croak "error at line (", $expat->current_line, ")\n$@";
  }
}

sub End {
  no strict 'refs';
  my $expat = shift;
  my $type = shift;
  eval {
    $expat->{DocState}->EndTagPre($expat, @_) if (defined $expat->{DocState});
    # Set right context for Text handler
    push(@{$expat->{Context}}, $type);
    doText($expat);
    popXmlSpace($expat);
    pop(@{$expat->{Context}});
    foreach my $o (@{$expat->{ParseObjs}}) {
      $o->EndTag($expat, $type, @_) if ($o->can("EndTag"));
    }
    $expat->{DocState}->EndTag($expat, @_) if (defined $expat->{DocState});
  };
  if ($@) {
    croak "error at line (", $expat->current_line, ")\n$@";
  }
}

sub Char {
  my $expat = shift;
  $expat->{Text} .= shift;
}

sub Proc {
  no strict 'refs';
  my $expat = shift;
  my $target = shift;
  my $text = shift;
  eval {
    doText($expat);
    foreach my $o (@{$expat->{ParseObjs}}) {
      $o->Proc($expat, $target, $text) if ($o->can("Proc"));
    }
  };
  if ($@) {
    croak "error at line (", $expat->current_line, ")\n$@";
  }
}

sub Final {
  no strict 'refs';
  my $expat = shift;
  eval {
    foreach my $o (@{$expat->{ParseObjs}}) {
      $o->EndDocument($expat) if ($o->can("EndDocument"));
    }
  };
  if ($@) {
    croak "error at line (", $expat->current_line, ")\n$@";
  }
}

sub doText {
  no strict 'refs';
  my $expat = shift;
  if ($expat->{XmlWhiteSpaceHandling}->[-1] == 1) {
    $expat->{Text} = rem_ws_p($expat->{Text});
  }
  else {
    $expat->{Text} = rem_ws($expat->{Text});
  }
  if (length($expat->{Text})) {
    $expat->{DocState}->Text($expat, @_) if (defined $expat->{DocState});
    foreach my $o (@{$expat->{ParseObjs}}) {
      $o->Text($expat) if ($o->can("Text"));
    }
    $expat->{Text} = '';
  }
}

sub pushXmlSpace {
  my $expat = shift;
  my $wh = $expat->{XmlWhiteSpaceHandling}->[-1];
  while (@_) {
    my ($an, $av) = (shift, shift);
    if ($an eq 'xml:space') {
      if ($av eq 'preserve') {
	$wh = 1;
      }
      elsif ($av eq 'default') {
	$wh = 0;
      }
    }
  }
  push(@{$expat->{XmlWhiteSpaceHandling}}, $wh);
}


sub popXmlSpace {
  my $expat = shift;
  pop(@{$expat->{XmlWhiteSpaceHandling}});
}

sub rem_ws_p {
  my $str = shift;
  $str =~ s/[\n\t]/ /g;
  $str =~ s/  +/ /g;
  return $str;
}

sub rem_ws {
  my $str = shift;
  $str =~ s/\n//g;
  $str =~ s/\t/ /g;
  $str =~ s/^ +//;
  $str =~ s/ +$//;
  $str =~ s/  +/ /g;
  return $str;
}

sub Default {
  no strict 'refs';
  my ($expat, $data) = @_;
  # とりあえずentityはそのまま追加する
  if ($data =~ /&.*\;/) {
    $expat->{Text} .= $data;
  }
}

1;

