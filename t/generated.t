use strict;
use warnings;

BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't';
        @INC = ('../lib', 'lib', 'TraceTests');
    }
    else {
        unshift @INC, 't/lib', 't/TraceTests';
    }
}

use TraceTest '-implementation' => 'XS';

my $path = $ENV{PERL_CORE} ? 'generated' : 't/generated';

ok(-d $path, "found generated test dir") || print STDERR "Do you need to run the generator script?";

opendir(my $D, $path) || die "Could not open generated test dir";

my $files = grep { m/\.t$/ } readdir($D);

ok($files > 0, "Found some generated test files") || print STDERR "Do you need to run the generator script?";

done_testing();
