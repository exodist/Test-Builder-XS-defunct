package Test::Builder::XS::Trace;
use strict;
use warnings;

# Do not use base or parent, no need to load the subclass
our @ISA = ('Test::Builder::Trace');

sub level        { $_[0]->{level}        }
sub report       { $_[0]->{report}       }
sub builder      { $_[0]->{builder}      }
sub encoding     { $_[0]->{encoding}     }
sub todo_message { $_[0]->{todo_message} }
sub todo_package { $_[0]->{todo_package} }
sub full         { $_[0]->{full}         }
sub anointed     { $_[0]->{anointed}     }
sub transitions  { $_[0]->{transitions}  }
sub tools        { $_[0]->{tools}        }

1;
