package Finance::Bitcoin::Feed;
use strict;

use Mojo::Base 'Mojo::EventEmitter';
use AnyEvent;
use Finance::Bitcoin::Feed::Site::BitStamp;
use Finance::Bitcoin::Feed::Site::Hitbtc;
use Finance::Bitcoin::Feed::Site::BtcChina;
use Finance::Bitcoin::Feed::Site::CoinSetter;

our $|++;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    $self->on( 'output', sub { shift; say join " ", @_ } );
    return $self;
}

sub run {
    my $self = shift;
		my @sites;
		
		for my $site_class (qw(Finance::Bitcoin::Feed::Site::BitStamp Finance::Bitcoin::Feed::Site::Hitbtc Finance::Bitcoin::Feed::Site::BtcChina Finance::Bitcoin::Feed::Site::CoinSetter)){
			my $site = $site_class->new();
			$site->on('output',sub {shift, $self->emit('output',@_)});
			$site->go;
			push @sites, $site;
		}

    AnyEvent->condvar->recv;
}

1;

__END__

=head1 NAME

Finance::Bitcoin::Feed - Collect bitcoin real-time price from many sites' streaming data source


=head1 VERSION

This document describes BitCoinFeed version 0.0.1


=head1 SYNOPSIS

    use Finance::Bitcoin::Feed;

    #default output is to print to the stdout
    Finance::Bitcoin::Feed->new->run();

    #or custom your stdout
    my $feed = Finance::Bitcoin::Feed->new;
    open  my $fh, ">out.txt";
    $feed->on('output', sub{shift; print $fh @_,"\n"});


=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
=head1 DESCRIPTION

L<Finance::Bitcoin::Feed> is a bitcoin realtime data source which collect real time data source from other sites:
  ws://api.hitbtc.com:80
  wss://websocket.btcchina.com
  ws://ws.pusherapp.com
  https://plug.coinsetter.com:3000

=head1 METHODS

This class  inherits all methods from L<Mojo::EventEmitter>

=head1 EVENTS

This class  inherits all events from L<Mojo::EventEmitter> and add the following new ones:

=head2 output

   #output to the stdout, the default action:
   $feed->on('output', sub { shift; say join " ", @_ } );

   #or you can clear this default action and add yours:
   $feed->unsubscribe('output');
   open  my $fh, ">out.txt";
   $feed->on('output', sub{shift; print $fh @_,"\n"});


=head1 DEBUGGING

You can set the DEBUG environment variable to get some advanced diagnostics information printed to STDERR.
And these modules use L<Mojo::UserAgent>, you can also open the MOJO_USERAGENT_DEBUG environment variable:

   DEBUG=1
   MOJO_USERAGENT_DEBUG=1


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Chylli  C<< <chylli@binary.com> >>

