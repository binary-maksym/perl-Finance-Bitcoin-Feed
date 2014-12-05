package Finance::Bitcoin::Feed::Site::BitStamp;
use strict;
use Mojo::Base 'Finance::Bitcoin::Feed::Site';

has 'socket';
has 'site' => 'bitstamp';

sub go {
    my $self = shift;
    $self->SUPER::go;
    $self->debug('connecting...');
    $self->socket(Finance::Bitcoin::Feed::BitStamp::Socket->new($self));
    $self->socket->go;
}

package Finance::Bitcoin::Feed::BitStamp::Socket;

use strict;
use warnings;
use parent qw(Finance::Bitcoin::Feed::Pusher);
use Scalar::Util qw(weaken);

sub new {
    my $self = shift->SUPER::new(channels => [qw/live_trades/]);
    $self->{owner} = shift;

    #weaken it to prevent from crossing reference
    weaken($self->{owner});
    return $self;
}

sub trade {
    my $self = shift;
    my $data = shift;
    $self->{owner}->emit('data_out', "BITSTAMP", "BTCUSD", $data->{price});
}

sub go {
    my $self = shift;
    $self->setup;
    $self->handle;
}

1;

__END__

=head1 NAME

Finance::Bitcoin::Feed::Site::BitStamp -- the class that connect and process the data from site bitstamp


=head1 SYNOPSIS

    use 'Finance::Bitcoin::Feed::Site::BitStamp';

    my $obj = Finance::Bitcoin::Feed::Site::BitStamp->new();
    $obj->go();

    # dont forget this 
    AnyEvent->condvar->recv;

=head1 DESCRIPTION

Connect to site BitStamp by protocol Pusher.

=head1 SEE ALSO

L<Finance::Bitcoin::Feed::Site>, L<Finance::BitStamp::Socket>, L<https://www.bitstamp.net/websocket/>

=head1 AUTHOR

Chylli  C<< <chylli@binary.com> >>

