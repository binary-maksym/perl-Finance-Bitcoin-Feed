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
__END__

=head1 NAME

Finance::Bitcoin::Feed::Site - Base class of Finance::Bitcoin::Feed modules


=head1 VERSION

This document describes BitCoinFeed version 0.0.1


=head1 SYNOPSIS

    use Mojo::Base 'Finance::Bitcoin::Feed::Site';

    sub go{
       my $self = shift;
       .....
    }

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
=head1 DESCRIPTION

   It is a base class

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
BitCoinFeed requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-bitcoinfeed@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Chylli  C<< <chylli@binary.com> >>

