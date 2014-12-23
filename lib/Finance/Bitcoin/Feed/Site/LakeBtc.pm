package Finance::Bitcoin::Feed::Site::LakeBtc;

use strict;
use warnings;
use Mojo::Base 'Finance::Bitcoin::Feed::Site';
use Mojo::UserAgent;

our $VERSION = '0.01';

has ws_url => 'wss://www.LakeBTC.com/websocket';
has 'ua';
has site => 'LAKEBTC';

sub go {
    my $self = shift;
    $self->SUPER::go;

    $self->ua( Mojo::UserAgent->new() );
    $self->debug( 'connecting...', $self->ws_url );
    $self->ua->websocket(
        $self->ws_url => sub {
            my ( $ua, $tx ) = @_;
            $self->debug('connected!');
            unless ( $tx->is_websocket ) {
                $self->error("Site BtcChina WebSocket handshake failed!");

                # set timeout;
                $self->set_timeout;
                return;
            }

            bless $tx, 'Mojo::Transaction::WebSocket::ForLakeBtc';
            $tx->configure($self);
        }
    );

}

package Mojo::Transaction::WebSocket::ForLakeBtc;    # hidden from PAUSE

use JSON;
use Mojo::Base 'Mojo::Transaction::WebSocket';
use Scalar::Util qw(weaken);
has 'owner';

sub configure {
    my $self  = shift;
    my $owner = shift;
    $self->owner($owner);
    weaken( $self->{owner} );

    # call parse when receive text event
    $self->on(
        json => sub {
            my ( $self, $message ) = @_;

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
                    $self->send( { json => ['websocket_rails.subscribe', {data =>{channel => $channel }}]} );
                }
            );
        }
    );
    $self->emit( 'subscribe', 'ticker' );


		

}



1;
