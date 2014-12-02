use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed::Site::BitStamp' );
}

my $obj = Finance::Bitcoin::Feed::Site::BitStamp->new();
isa_ok($obj->socket, 'Finance::Bitcoin::Feed::BitStamp::Socket','class of socket is correct');
is($obj->socket->{owner}, $obj, "object's socket's owner is object");
my $str = '';
lives_ok(sub{$obj->on('output',sub {shift; $str = join " ", @_})}, 'set output event');

lives_ok(sub{$obj->socket->trade({price => 1})},'call trade');
is($str, 'BITSTAMP BTCUSD 1');

