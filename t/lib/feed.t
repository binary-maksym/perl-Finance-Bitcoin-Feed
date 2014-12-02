use Test::More tests => 5;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed' );
}

can_ok(Finance::Bitcoin::Feed, run);

my $feed = Finance::Bitcoin::Feed->new();
isa_ok($feed,Finance::Bitcoin::Feed);
isa_ok($feed, Mojo::EventEmitter);
ok($feed->has_subscribers('output'));

