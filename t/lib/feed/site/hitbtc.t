use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed::Site::Hitbtc' );
}

my $obj = Finance::Bitcoin::Feed::Site::Hitbtc->new();
can_ok($obj, 'go');
isa_ok($obj->ua, 'Mojo::UserAgent');
ok($obj->has_subscribers('json'),'has json subscribe');
my $str = '';
lives_ok(sub{
					 $obj->on('output', sub{shift; $str = join " ", @_;});
					 $obj->emit('json',{
													MarketDataIncrementalRefresh => {
																													 symbol => 'USDBTC',
																													 trade => [{price => 1}]
																													}
													
												 });
					 },'set on output  and emit json');

is($str, 'HITBTC USDBTC 1','emit result ok');
