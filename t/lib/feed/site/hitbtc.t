use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::MockObject;

BEGIN {
    use_ok('Finance::Bitcoin::Feed::Site::Hitbtc');
}

my $obj = Finance::Bitcoin::Feed::Site::Hitbtc->new();
ok( $obj->has_subscribers('json'), 'has json subscribe' );

my $str  = '';
my $hash = {
    MarketDataIncrementalRefresh => {
        symbol => 'USDBTC',
        trade  => [ { price => 1 } ]
    }
};
lives_ok(
    sub {
        $obj->on( 'output', sub { shift; $str = join " ", @_; } );
        $obj->emit( 'json', $hash );
    },
    'set on output  and emit json'
);

is( $str, 'HITBTC USDBTC 1', 'emit result ok' );

diag('testing connect fail...');

# mock objects to simulate connection fail
my $websocket_mock = Test::MockObject->new();
$websocket_mock->set_false('is_websocket');
$websocket_mock->mock(
    'on',
    sub {
        my ( $self, $name, $cb ) = @_;
        $cb->( $self, $hash );
    }
);
my $ua_mock = Test::MockObject->new();
$ua_mock->fake_new('Mojo::UserAgent');
$ua_mock->mock(
    'websocket',
    sub {
        shift;
        shift;
        my $cb = shift;
        $cb->( $ua_mock, $websocket_mock );
    }
);
lives_ok( sub { $obj->go; }, 'run go' );
is( $obj->started, 1, 'started after go' );
ok( $obj->is_timeout, 'set timeout' );

diag('testing connect success');

#simulate connection succeed
$str = '';
$obj->started(0);
$websocket_mock->set_true('is_websocket');
lives_ok( sub { $obj->go; }, 'run go again' );
ok( !$obj->is_timeout, 'not timeout' );
is( $str, 'HITBTC USDBTC 1', 'emit result ok' );

done_testing();
