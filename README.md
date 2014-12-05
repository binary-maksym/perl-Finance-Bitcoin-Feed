[![Build Status](https://travis-ci.org/binary-com/perl-Finance-Bitcoin-Feed.svg?branch=master)](https://travis-ci.org/binary-com/perl-Finance-Bitcoin-Feed)
[![Coverage Status](https://coveralls.io/repos/binary-com/perl-Finance-Bitcoin-Feed/badge.png?branch=master)](https://coveralls.io/r/binary-com/perl-Finance-Bitcoin-Feed?branch=master)

# NAME

Finance::Bitcoin::Feed - Collect bitcoin real-time price from many sites' streaming data source

# SYNOPSIS

    use Finance::Bitcoin::Feed;

    #default output is to print to the stdout
    Finance::Bitcoin::Feed->new->run();

    #or custom your stdout
    my $feed = Finance::Bitcoin::Feed->new;
    open  my $fh, ">out.txt";
    $feed->on('output', sub{shift; print $fh @_,"\n"});

# DESCRIPTION

[Finance::Bitcoin::Feed](https://metacpan.org/pod/Finance::Bitcoin::Feed) is a bitcoin realtime data source which collect real time data source from other sites:

- ws://api.hitbtc.com:80
- wss://websocket.btcchina.com
- ws://ws.pusherapp.com
- https://plug.coinsetter.com:3000

# METHODS

This class inherits all methods from [Mojo::EventEmitter](https://metacpan.org/pod/Mojo::EventEmitter)

# EVENTS

This class inherits all events from [Mojo::EventEmitter](https://metacpan.org/pod/Mojo::EventEmitter) and add the following new ones:

## output

    #output to the stdout, the default action:
    $feed->on('output', sub { shift; say join " ", @_ } );

    #or you can clear this default action and add yours:
    $feed->unsubscribe('output');
    open  my $fh, ">out.txt";
    $feed->on('output', sub{shift; print $fh @_,"\n"});

# DEBUGGING

You can set the DEBUG environment variable to get some advanced diagnostics information printed to STDERR.
And these modules use [Mojo::UserAgent](https://metacpan.org/pod/Mojo::UserAgent), you can also open the MOJO\_USERAGENT\_DEBUG environment variable:

    DEBUG=1
    MOJO_USERAGENT_DEBUG=1

# SEE ALSO

[Mojo::EventEmitter](https://metacpan.org/pod/Mojo::EventEmitter)

# AUTHOR

Chylli  `<chylli@binary.com>`

# COPYRIGHT

Copyright 2014- Binary.com

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
