use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed::Site' );
}

my $obj = Finance::Bitcoin::Feed::Site->new();

isa_ok($obj,'Finance::Bitcoin::Feed::Site');
isa_ok($obj->cv, 'AnyEvent::CondVar');
can_ok($obj, 'go');

