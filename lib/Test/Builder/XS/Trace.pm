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

__END__

=pod

=head1 name

Test::Builder::XS::Trace - XS subclass of Test::Builder::Trace

=head1 DESCRIPTION

Some parts of Test::Builder are very slow in pure perl code. Recent updates to
Test::Builder have almost doubled the time it takes for the perl test suite to
complete. This module is an attempt to maintain performance without sacrificing
capabilities.

=head1 SEE ALSO

L<Test::Builder::Trace> - This subclass does not implement any methods
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
