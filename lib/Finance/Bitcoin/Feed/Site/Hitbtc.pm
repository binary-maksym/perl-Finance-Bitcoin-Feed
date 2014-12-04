use strict;
use warnings;

package Finance::Bitcoin::Feed::Site::Hitbtc;

use Mojo::Base 'Finance::Bitcoin::Feed::Site';

use Mojo::UserAgent;
use EV;
use AnyEvent;

has ws_url => 'ws://api.hitbtc.com';
has 'ua';
sub new{
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	$self->on('json',\&on_json);


	return $self
}




sub go{
	my $self = shift;
	$self->SUPER::go(@_);
	$self->ua(Mojo::UserAgent->new);
	$self->ua->websocket($self->ws_url => sub{
									 my ($ua, $tx) = @_;
									 unless($tx->is_websocket){
										 warn "WebSocket handshake failed!\n";
										 # set timeout;
										 $self->set_timeout;
										 return;
									 }

									 $tx->on(json => sub {
														 my ($tx, $hash) = @_;
														 $self->emit('json',$hash);
													 });
								 })
}

sub on_json{
	my ($self, $hash) = @_;

	if ($hash->{MarketDataIncrementalRefresh}
			&& scalar @{$hash->{MarketDataIncrementalRefresh}{trade}}) {
		for my $trade (@{$hash->{MarketDataIncrementalRefresh}{trade}}) {
			$self->emit('data_out', 'HITBTC', $hash->{MarketDataIncrementalRefresh}{symbol}, $trade->{price});
		}
	}
}

1;


