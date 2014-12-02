use Test::More tests => 3;

BEGIN {
	use_ok( 'Finance::Bitcoin::Feed::Base' );
}

my $obj = Finance::Bitcoin::Feed::Base->new();

isa_ok($obj,Finance::Bitcoin::Feed::Base);
isa_ok($obj->cv, AnyEvent::CondVar);

