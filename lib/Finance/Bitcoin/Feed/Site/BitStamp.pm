package Finance::Bitcoin::Feed::Site::BitStamp;
use strict;
use Mojo::Base 'Finance::Bitcoin::Feed::Site';

has 'socket';

sub new{
	my $class = shift;
	my $self = $class->SUPER::new();

  $self->socket(Finance::Bitcoin::Feed::BitStamp::Socket->new($self));
	
}	

sub go{
	shift->socket->go;
}


package Finance::Bitcoin::Feed::BitStamp::Socket;

use strict;
use warnings;
use parent qw(Finance::Bitcoin::Feed::Pusher);

sub new{
	my $self = shift->SUPER::new(channels => [qw/live_trades/] );
	$self->{owner} = shift;
	return $self;
}

sub trade {
    my $self = shift;
    my $data = shift;
		$self->{owner}->emit('output', "BITSTAMP BTCUSD ", $data->{price});
}

sub go {
    my $self = shift;
    $self->setup;
    $self->handle;
}




1;
