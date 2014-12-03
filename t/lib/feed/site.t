use strict;
use warnings;

use Test::More;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed::Site' );
}

my $obj = Finance::Bitcoin::Feed::Site->new();

isa_ok($obj,'Finance::Bitcoin::Feed::Site');
isa_ok($obj->cv, 'AnyEvent::CondVar');
can_ok($obj, 'go');
ok($obj->has_subscribers('timeout'),'has timeout subscribe');
is($obj->started, 0, 'test not started');
is($obj->last_activity_at, 0, 'no activity yet');
$obj->go;
is($obj->started, 1, 'test started');
ok($obj->last_activity_at != 0, 'has activity now');
ok(!$obj->is_timeout, 'not timeout yet');

done_testing();
