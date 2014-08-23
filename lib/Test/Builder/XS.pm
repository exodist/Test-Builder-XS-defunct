package Test::Builder::XS;
use strict;
use warnings;
use 5.008;

our $VERSION = '0.001';

use Test::Builder::XS::Trace;
use Test::Builder::XS::Frame;

use XSLoader;
use Exporter 5.57 'import';
our @EXPORT = qw/tb_trace/;

XSLoader::load(__PACKAGE__, $VERSION);

1;

__END__

=pod

=head1 name

Test::Builder::XS - XS Enhancement library for L<Test::Builder>

=head1 DESCRIPTION

Some parts of Test::Builder are very slow in pure perl code. Recent updates to
Test::Builder have almost doubled the time it takes for the perl test suite to
complete. This module is an attempt to maintain performance without sacrificing
capabilities.

=head1 EXPORTS

=over 4

=item $trace = tb_trace()

Returns an L<Test::Builder::Trace> object comprised of
L<Test::Builder::Trace::Frame> objects. XS is used to build the entire stack
trace to ensure performance.

=item more to come

There are plans to add other XS code as necessary

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2014 Chad Granum

Test-Builder-XS is free software; Standard perl license (GPL and Artistic).

Test-Builder-XS is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

=cut
