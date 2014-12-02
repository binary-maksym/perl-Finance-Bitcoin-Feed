package Finance::Bitcoin::Feed;
use strict;

use Mojo::Base 'Mojo::EventEmitter';
use Finance::Bitcoin::Feed::Base;

sub new{
	my $class = shift;
	my $self = $class->SUPER::new();
	$self->on('output',sub{shift; say @_});
}
sub run{
	my $self = shift;
	#my $bitstamp = Finance::Bitcoin::Feed::BitStamp;
	#$bitstamp->on('output',sub {shift, $self->emit('output',@_)});
	#$bitstamp->go;
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

