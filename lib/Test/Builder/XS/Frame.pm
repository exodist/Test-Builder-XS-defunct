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

__END__

=pod

=head1 name

Test::Builder::XS::Frame - XS subclass of Test::Builder::Trace::Frame

=head1 DESCRIPTION

Some parts of Test::Builder are very slow in pure perl code. Recent updates to
Test::Builder have almost doubled the time it takes for the perl test suite to
complete. This module is an attempt to maintain performance without sacrificing
capabilities.

=head1 SEE ALSO

L<Test::Builder::Trace::Frame> - This subclass does not implement any methods
that are not already documented in the base class.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2014 Chad Granum

Test-Builder-XS is free software; Standard perl license (GPL and Artistic).

Test-Builder-XS is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

=cut
