package Finance::Bitcoin::Feed::Site::BtcChina;
use strict;
use Mojo::Base 'Finance::Bitcoin::Feed::Site';
use Mojo::UserAgent;

has ws_url => 'wss://websocket.btcchina.com/socket.io/?transport=websocket';
has 'ua';
has 'site' => 'BtcChina';

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

            bless $tx, 'Mojo::Transaction::WebSocket::ForBtcChina';
            $tx->configure($self);
        }
    );

}

package Mojo::Transaction::WebSocket::ForBtcChina;
use JSON;

use Mojo::Base 'Mojo::Transaction::WebSocket';
use Scalar::Util qw(weaken);
has 'owner';
has 'ping_interval';
has 'ping_timeout';
has 'last_ping_at';
has 'last_pong_at';
has 'timer';

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
                    $self->send( { text => qq(42["subscribe","$channel"]) } );
                }
            );
        }
    );
    $self->emit( 'subscribe', 'marketdata_cnybtc' );
    $self->emit( 'subscribe', 'marketdata_cnyltc' );
    $self->emit( 'subscribe', 'marketdata_btcltc' );

    $self->on(
        trade => sub {
            my ( $self, $data ) = @_;
            $self->owner->emit( 'data_out', 'BTCCHINA', uc( $data->{market} ),
                $data->{price} );

        }
    );

    $self->on(
        'ping',
        sub {
            $self->send( { text => '2' } );
        }
    );
    my $timer = AnyEvent->timer(
        after    => 10,
        interval => 1,
        cb       => sub {
            if ( time() - $self->last_ping_at > $self->ping_interval / 1000 ) {
                $self->emit('ping');
                $self->last_ping_at( time() );
            }
        }
    );
    $self->timer($timer);

}

#socket.io v2.
sub parse {
    my ( $self, $data ) = @_;
    use Data::Dumper;
    $self->owner->debug( Dumper($data) );
    $self->owner->last_activity_at( time() );
    return unless $data =~ /^\d+/;
    my ( $code, $body ) = $data =~ /^(\d+)(.*)$/;

    # connect, setup
    if ( $code == 0 ) {
        my $json_data = decode_json($body);

        #session_id useless ?

        $self->ping_interval( $json_data->{pingInterval} )
          if $json_data->{pingInterval};
        $self->ping_timeout( $json_data->{pingTimeout} )
          if $json_data->{pingTimeout};
        $self->last_pong_at( time() );
        $self->last_ping_at( time() );
        $self->emit('setup');
    }

    # pong
    elsif ( $code == 3 ) {
        $self->last_pong_at( time() );
    }

    #disconnect ? reconnect!
    elsif ( $code == 41 ) {

        #set timeout
        $self->owner->set_timeout();
    }
    elsif ( $code == 42 ) {
        my $json_data = decode_json($body);
        $self->emit( $json_data->[0], $json_data->[1] );
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

