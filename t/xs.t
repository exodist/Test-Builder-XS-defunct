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

TraceTest->run_tests();
