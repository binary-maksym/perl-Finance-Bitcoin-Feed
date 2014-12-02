use Test::More tests => 2;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed' );
}

can_ok('Finance::Bitcoin::Feed', run);
