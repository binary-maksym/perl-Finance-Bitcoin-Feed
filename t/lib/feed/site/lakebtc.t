use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::MockObject::Extends;
use Scalar::Util qw(isweak);

BEGIN {
    use_ok('Finance::Bitcoin::Feed::Site::LakeBtc');
}

my $obj = Finance::Bitcoin::Feed::Site::LakeBtc->new();

#testing connect fail...

my $socket = Mojo::Transaction::WebSocket::ForLakeBtc->new();
$socket = Test::MockObject::Extends->new($socket);
$socket->set_false('is_websocket');
my $ua_mock = Test::MockObject->new();
$ua_mock->fake_new('Mojo::UserAgent');
$ua_mock->mock(
    'websocket',
    sub {
        shift;
        shift;
        my $cb = shift;
        $cb->( $ua_mock, $socket );
    }
);

lives_ok( sub { $obj->go; }, 'run go' );
ok( $obj->started,    'super::go is called, the program is running' );
ok( $obj->is_timeout, 'set timeout' );

#testing connect success
$obj->started(0);
$socket->set_true('is_websocket');
lives_ok( sub { $obj->go; }, 'run go again' );
is( $socket->owner, $obj, 'set owner of socket' );
ok( isweak( $socket->{owner} ), 'owner is weak' );



done_testing();
