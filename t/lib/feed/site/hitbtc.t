use strict;
use warnings;

use Test::More tests => 5;
use Test::Exception;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed::Site::Hitbtc' );
}

my $obj = Finance::Bitcoin::Feed::Site::Hitbtc->new();
can_ok($obj, 'go');
isa_ok($obj->ua, 'Mojo::UserAgent');

my $str = '';
lives_ok(sub{
					 $obj->on('output', sub{shift; $str = join " ", @_;});
					 $obj->on_json({
													MarketDataIncrementalRefresh => {
																													 symbol => 'USDBTC',
																													 trade => [{price => 1}]
																													}
													
												 });
					 },'set output emit and call on_json');

is($str, 'HITBTC USDBTC 1','emit result ok');
