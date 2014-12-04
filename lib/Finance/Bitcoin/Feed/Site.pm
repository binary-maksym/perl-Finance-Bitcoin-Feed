package Finance::Bitcoin::Feed::Site;
use strict;

use Mojo::Base 'Mojo::EventEmitter';
use AnyEvent;

has 'cv' => sub {AnyEvent->condvar;};
has last_activity_at => 0;
has last_activity_period => 60;
has 'timer';
has started => 0;

sub new{
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	$self->on('timeout', \&on_timeout);
	$self->on('data_out', \&on_data_out);

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

sub on_data_out{
	my $self = shift;
	$self->last_activity_at(time());
	$self->emit('output', @_);
}

sub timer_call_back{
	my $self = shift;
	return unless $self->started;
	if($self->is_timeout){
		$self->emit('timeout');
	}
	
}
sub set_timeout{
	my $self = shift;
	$self->last_activity_at(time - $self->last_activity_period - 100);
}
sub is_timeout{
	my $self = shift;
	return time() - $self->last_activity_at > $self->last_activity_period;
}

sub on_timeout{
	my $self = shift;
	$self->go;
}


sub go {
	my $self = shift;
	$self->started(1);
	$self->last_activity_at(time());
}

sub debug{
	my $self = shift;
	if($ENV{DEBUG}){
		say STDERR "-------------------------";
		say STDERR @_;
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

