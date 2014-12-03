use strict;
use warnings;

package Finance::Bitcoin::Feed::Site::Hitbtc;

use Mojo::Base 'Finance::Bitcoin::Feed::Site';

use Mojo::UserAgent;
use EV;
use AnyEvent;

has ws_url => 'ws://api.hitbtc.com';
has 'ua';
has last_activity_at => sub{time()};
has last_activity_period => 60;
has 'timer';
has started => 0;
sub new{
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	$self->on('json',\&on_json);
	$self->on('timeout', \&on_timeout);

	my $timer = AnyEvent->timer (
      after => 0,    # first invoke ASAP
      interval => 1, # then invoke every second
      cb    => sub { # the callback to invoke
				$self->timer_call_back;
      },
															);
	$self->timer($timer);
	return $self;
}

sub timer_call_back{
	my $self = shift;
	return unless $self->started;
	if($self->is_timeout){
		$self->emit('timeout');
	}
	
}

sub is_timeout{
	my $self = shift;
	return time() - $self->last_activity_at > $self->last_activity_period;
}
sub on_timeout{
	my $self = shift;
	$self->go;
}


sub go{
	my $self = shift;
	$self->started(1);
	$self->ua(Mojo::UserAgent->new);
	$self->last_activity_at(time());
	$self->ua->websocket($self->ws_url => sub{
									 my ($ua, $tx) = @_;
									 unless($tx->is_websocket){
										 warn "WebSocket handshake failed!\n";
										 # set timeout;
										 $self->last_activity_at(time() - $self->last_activity_period - 100);
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

	$self->last_activity_at(time());
	if ($hash->{MarketDataIncrementalRefresh}
			&& scalar @{$hash->{MarketDataIncrementalRefresh}{trade}}) {
		for my $trade (@{$hash->{MarketDataIncrementalRefresh}{trade}}) {
			$self->emit('output', 'HITBTC', $hash->{MarketDataIncrementalRefresh}{symbol}, $trade->{price});
		}
	}
}

1;


