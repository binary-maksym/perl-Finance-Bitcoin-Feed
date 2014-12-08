[![Build Status](https://travis-ci.org/binary-com/perl-Finance-Bitcoin-Feed.svg?branch=master)](https://travis-ci.org/binary-com/perl-Finance-Bitcoin-Feed)
[![Coverage Status](https://coveralls.io/repos/binary-com/perl-Finance-Bitcoin-Feed/badge.png?branch=master)](https://coveralls.io/r/binary-com/perl-Finance-Bitcoin-Feed?branch=master)

# NAME

Finance::Bitcoin::Feed - Collect bitcoin real-time price from many sites' streaming data source

# SYNOPSIS

    use Finance::Bitcoin::Feed;

    #default output is to print to the stdout
    Finance::Bitcoin::Feed->new->run();
    # will print output to the stdout:
    # BITSTAMP BTCUSD 123.00
    

    #or custom your stdout
    my $feed = Finance::Bitcoin::Feed->new;
    #first unsubscribe the event 'output'
    $feed->unsubscribe('output');
    #then listen on 'output' by your callback
    open  my $fh, ">out.txt";
    $fh->autoflush();
    $feed->on('output', sub{
       my ($self, $site, $currency, $price) = @_;
       print $fh "the price currency $currency on site $site is $price\n";
    });
    # let's go!
    $feed->run();

# DESCRIPTION

[Finance::Bitcoin::Feed](https://metacpan.org/pod/Finance::Bitcoin::Feed) is a bitcoin realtime data source which collect real time data source from other sites:

- ws://api.hitbtc.com:80
- wss://websocket.btcchina.com
- ws://ws.pusherapp.com
- https://plug.coinsetter.com:3000

The default output format to the stdout by this format:

    site_name CURRENCY price

For example:

    BITSTAMP BTCUSD 123.00

You can custom your output by listen on the event [output](https://metacpan.org/pod/output) and modify the data it received.

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
    $feed->on('output', sub{
       my ($self, $site, $currency, $price) = @_;
       say $fh "the price of $site of currency $currency is $price"
    });

# DEBUGGING

You can set the FINANCE\_BITCOIN\_FEED\_DEBUG environment variable to get some advanced diagnostics information printed to STDERR.
And these modules use [Mojo::UserAgent](https://metacpan.org/pod/Mojo::UserAgent), you can also open the MOJO\_USERAGENT\_DEBUG environment variable:

    FINANCE_BITCOIN_FEED_DEBUG=1
    MOJO_USERAGENT_DEBUG=1

# SEE ALSO

[Mojo::EventEmitter](https://metacpan.org/pod/Mojo::EventEmitter)

[Finance::Bitcoin::Feed::Site::BitStamp](https://metacpan.org/pod/Finance::Bitcoin::Feed::Site::BitStamp)

[Finance::Bitcoin::Feed::Site::Hitbtc](https://metacpan.org/pod/Finance::Bitcoin::Feed::Site::Hitbtc)

[Finance::Bitcoin::Feed::Site::BtcChina](https://metacpan.org/pod/Finance::Bitcoin::Feed::Site::BtcChina)

[Finance::Bitcoin::Feed::Site::CoinSetter](https://metacpan.org/pod/Finance::Bitcoin::Feed::Site::CoinSetter)

# AUTHOR

Chylli  `<chylli@binary.com>`

# COPYRIGHT

Copyright 2014- Binary.com
