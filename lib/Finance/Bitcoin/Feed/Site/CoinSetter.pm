package Finance::Bitcoin::Feed::Site::CoinSetter;
use strict;
use Mojo::Base 'Finance::Bitcoin::Feed::Site';
use Mojo::UserAgent;

# Module implementation here
has ws_url => 'https://plug.coinsetter.com:3000/socket.io/1';
has 'ua';
has 'site' => 'CoinSetter';

sub go {
    my $self = shift;
    $self->SUPER::go;
    $self->ua( Mojo::UserAgent->new() );
    $self->debug('get handshake information');
    my $tx = $self->ua->get( $self->ws_url );
    unless ( $tx->success ) {
        my $err = $tx->error;
        $self->error("Connection error of Site CoinSetter: $err->{message}");
        $self->set_timeout;
        return;
    }

    # f_P7lQkhkg4JD5Xq0LCl:60:60:websocket,htmlfile,xhr-polling,jsonp-polling
    my ( $sid, $hb_timeout, $con_timeout, $transports ) = split /:/,
      $tx->res->text;

    my $url = $self->ws_url . "/websocket/$sid";
    $url =~ s/https/wss/;

		$self->debug( 'connecting...', $url );
		
    my $socket = $self->ua->websocket(
        $url => sub {
            my ( $ua, $tx ) = @_;
            $self->debug('connected!');
            unless ( $tx->is_websocket ) {
                $self->error("Site BtcChina WebSocket handshake failed!");

                # set timeout;
                $self->set_timeout;
                return;
            }
            bless $tx, 'Mojo::Transaction::WebSocket::ForCoinSetterSite';
            $tx->configure($self);
        }
    );
}

package Mojo::Transaction::WebSocket::ForCoinSetterSite;
use JSON;
use Scalar::Util qw(weaken);

use Mojo::Base 'Mojo::Transaction::WebSocket';

has 'owner';

sub configure {
    my $self  = shift;
    my $owner = shift;
    $self->owner($owner);
    weaken( $self->{owner} );

    # call parse when receive text event
    $self->on(
        text => sub {
            my ( $self, $message ) = @_;
            $self->parse($message);
        }
    );

    ################################################
    # setup events
    $self->on(
        subscribe => sub {
            my ( $self, $channel ) = @_;
            $self->on(
                'setup',
                sub {
                    $self->send(
                        { text => qq(5:::{"name":"$channel","args":[""]}) } );
                }
            );
        }
    );
    $self->emit( 'subscribe', 'last room' );
    $self->on(
        last => sub {
            my ( $self, $data ) = @_;
            $self->owner->emit( 'data_out', 'COINSETTER', 'BTCUSD',
                $data->[0]{price} );
        }
    );
}

#socketio v0.9.6
sub parse {

    my ( $tx, $data ) = @_;

    my @packets = (
        'disconnect', 'connect', 'heartbeat', 'message',
        'json',       'event',   'ack',       'error',
        'noop'
    );

    my $regexp = qr/([^:]+):([0-9]+)?(\+)?:([^:]+)?:?([\s\S]*)?/;

    my @pieces = $data =~ $regexp;
    return {} unless @pieces;
    my $id = $pieces[1] || '';
    $data = $pieces[4] || '';
    my $packet = {
        type     => $packets[ $pieces[0] ],
        endpoint => $pieces[3] || '',
    };

    # whether we need to acknowledge the packet
    if ($id) {
        $packet->{id} = $id;
        if ( $pieces[3] ) {
            $packet->{ack} = 'data';
        }
        else {
            $packet->{ack} = 'true';
        }

    }

    # handle different packet types
    if ( $packet->{type} eq 'error' ) {

        # need do nothing now.
    }
    elsif ( $packet->{type} eq 'message' ) {
        $packet->{data} = $data || '';
    }

#"5:::{"name":"last","args":[{"price":367,"size":0.03,"exchangeId":"COINSETTER","timeStamp":1417382915802,"tickId":14667678802537,"volume":14.86,"volume24":102.43}]}"
    elsif ( $packet->{type} eq 'event' ) {
        eval {
            my $opts = decode_json($data);
            $packet->{name} = $opts->{name};
            $packet->{args} = $opts->{args};
        };
        $packet->{args} ||= [];

        $tx->emit( $packet->{name}, $packet->{args} );
    }
    elsif ( $packet->{type} eq 'json' ) {
        evel {
            $packet->{data} = decode_json($data);
        }
    }
    elsif ( $packet->{type} eq 'connect' ) {
        $packet->{qs} = $data || '';
        $tx->emit('setup');
    }
    elsif ( $packet->{type} eq 'ack' ) {

        # nothing to do now
        # because this site seems don't emit this packet.
    }
    elsif ( $packet->{type} eq 'heartbeat' ) {

        #send back the heartbeat
        $tx->send( { text => qq(2:::) } );
    }
    elsif ( $packet->{type} eq 'disconnect' ) {
        $tx->owner->set_timeout();
    }
}

1;
