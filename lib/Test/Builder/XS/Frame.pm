package Test::Builder::XS::Frame;
use strict;
use warnings;

our @ISA = ('Test::Builder::Trace::Frame');

use constant PACKAGE => 0;
use constant FILE    => 1;
use constant LINE    => 2;
use constant SUBNAME => 3;
use constant _DEPTH  => 4; # Private only
use constant DETAILS => 5;

sub context { @{$_[0]}[PACKAGE .. SUBNAME] }

sub package { $_[0]->[PACKAGE] }
sub file    { $_[0]->[FILE   ] }
sub line    { $_[0]->[LINE   ] }
sub subname { $_[0]->[SUBNAME] }
sub details { $_[0]->[DETAILS] }

sub anointed   { $_[0]->[DETAILS]->{anointed}   }
sub encoding   { $_[0]->[DETAILS]->{encoding}   }
sub instance   { $_[0]->[DETAILS]->{instance}   }
sub has_todo   { $_[0]->[DETAILS]->{has_todo}   }
sub todo       { $_[0]->[DETAILS]->{todo}       }
sub provider   { $_[0]->[DETAILS]->{provider}   }
sub transition { $_[0]->[DETAILS]->{transition} }
sub level      { $_[0]->[DETAILS]->{level}      }
sub report     { $_[0]->[DETAILS]->{report}     }
sub builder    { $_[0]->[DETAILS]->{builder}    }

1;
