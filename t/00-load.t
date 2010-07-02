#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Steam::CSV' );
}

diag( "Testing Steam::CSV $Steam::CSV::VERSION, Perl $], $^X" );
