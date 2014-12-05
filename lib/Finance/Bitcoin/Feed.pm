package Finance::Bitcoin::Feed;

use strict;
use Mojo::Base 'Mojo::EventEmitter';
use AnyEvent;
use Finance::Bitcoin::Feed::Site::BitStamp;
use Finance::Bitcoin::Feed::Site::Hitbtc;
use Finance::Bitcoin::Feed::Site::BtcChina;
use Finance::Bitcoin::Feed::Site::CoinSetter;

our $VERSION = '0.01';

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

=head1 SYNOPSIS

    use Finance::Bitcoin::Feed;

    #default output is to print to the stdout
    Finance::Bitcoin::Feed->new->run();

    #or custom your stdout
    my $feed = Finance::Bitcoin::Feed->new;
    open  my $fh, ">out.txt";
    $feed->on('output', sub{shift; print $fh @_,"\n"});


=head1 DESCRIPTION

L<Finance::Bitcoin::Feed> is a bitcoin realtime data source which collect real time data source from other sites:

=over 4

=item * ws://api.hitbtc.com:80

=item * wss://websocket.btcchina.com

=item * ws://ws.pusherapp.com

=item * https://plug.coinsetter.com:3000

=back

=head1 METHODS

This class inherits all methods from L<Mojo::EventEmitter>

=head1 EVENTS

This class inherits all events from L<Mojo::EventEmitter> and add the following new ones:

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

=head1 SEE ALSO

L<Mojo::EventEmitter>

=head1 AUTHOR

Chylli  C<< <chylli@binary.com> >>

=head1 COPYRIGHT

Copyright 2014- Binary.com

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
