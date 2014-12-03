use strict;
use warnings;

package Finance::Bitcoin::Feed::Site::Hitbtc;

use Mojo::Base 'Finance::Bitcoin::Feed::Site';

use Mojo::UserAgent;
use EV;
use AnyEvent;

has ws_url => 'ws://api.hitbtc.com';
has ua => sub {Mojo::UserAgent->new};
sub go{
	my $self = shift;

	$self->ua->websocket($self->ws_url => sub{
									 my ($ua, $tx) = @_;
									 say 'WebSocket handshake failed!' and return unless $tx->is_websocket; 
									 $tx->on(json => sub {
														 my ($tx, $hash) = @_;

														 if ($hash->{MarketDataIncrementalRefresh}
																 && scalar @{$hash->{MarketDataIncrementalRefresh}{trade}}) {
															 for my $trade (@{$hash->{MarketDataIncrementalRefresh}{trade}}) {
																 $self->emit('output', 'HITBTC', $hash->{MarketDataIncrementalRefresh}{symbol}, $trade->{price});
															 }
														 }
														 
													 });
								 })
}


1;
__END__

