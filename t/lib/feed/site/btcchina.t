use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::MockObject::Extends;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed::Site::BtcChina' );
}

my $obj = Finance::Bitcoin::Feed::Site::BtcChina->new();



done_testing();
