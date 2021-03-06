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
    open  my $fh, ">out.txt";
    $fh->autoflush();
    my $feed = Finance::Bitcoin::Feed->new(output => sub{
       my ($self, $site, $currency, $price) = @_;
       print $fh "the price currency $currency on site $site is $price\n";
    });
    # let's go!
    $feed->run();

    #you can also custom which site you want to connect
    Finance::Bitcoin::Feed->new(sites => [qw(LakeBtc)])->go;

# DESCRIPTION

[Finance::Bitcoin::Feed](https://metacpan.org/pod/Finance::Bitcoin::Feed) is a bitcoin realtime data source which collect real time data source from these sites:

- [HitBtc](https://hitbtc.com/api#socketio)
- [BtcChina](http://btcchina.org/websocket-api-market-data-documentation-en)
- [CoinSetter](https://www.coinsetter.com/api/websockets/last)
- [<lakebtc api](https://www.lakebtc.com/s/api)

The default output format to the stdout by this format:

    site_name TIMESTAMP CURRENCY price

For example:

    COINSETTER 1418173081724 BTCUSD 123.00

The unit of timestamp is ms.

You can custom your output by listen on the event [output](https://metacpan.org/pod/output) and modify the data it received.

Note the followiing sites doesn't give the timestamp. So the timestamp in the result will be 0:

LakeBtc

# METHODS

This class inherits all methods from [Mojo::EventEmitter](https://metacpan.org/pod/Mojo::EventEmitter)

## new

This method have two arguments by which you can costumize the behavior of the feed:

### sites

which sites you want to connect. It is in fact the array reference of  module names of Finance::Bitcoin::Feed::Site::\*. Now there are the following sites:
Hitbtc
BtcChina
CoinSetter
LakeBtc
BitStamp

You can also put your own site module under this namespace and added here.

### output

customize the output format by giving this argument a sub reference. It will be bind to the event 'output'. Please rever to the event <output>.

    # you can customize the output by giving argument 'output' to the new methold
     open  my $fh, ">out.txt";
     $fh->autoflush();
     my $feed = Finance::Bitcoin::Feed->new(output => sub{
        my ($self, $site, $timestamp, $currency, $price) = @_;
        print $fh "the price currency $currency on site $site is $price\n";
     });
     # let's go!
     $feed->run();

# EVENTS

This class inherits all events from [Mojo::EventEmitter](https://metacpan.org/pod/Mojo::EventEmitter) and add the following new ones:

## output

This event has a default subscriber:

    #output to the stdout, the default action:
    $feed->on('output', sub { shift; say join " ", @_ } );

You can customize the output by giving argument 'output' to the new method

    open  my $fh, ">out.txt";
    $fh->autoflush();
    my $feed = Finance::Bitcoin::Feed->new(output => sub{
       my ($self, $site, $timestamp, $currency, $price) = @_;
       print $fh "the price currency $currency on site $site is $price\n";
    });
    # let's go!
    $feed->run();

Or you can bind output directly to the feed to get multi outout or you should unscribe this event first.

    $feed->on('output', sub {....})

The arguments of this event is:

$self: the site class object
timestamp: the timestamp of the data. If no timestamp is given by the site, then the value of it is 0.
sitename: the site class name
price: the price

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

[Finance::Bitcoin::Feed::Site::LakeBtc](https://metacpan.org/pod/Finance::Bitcoin::Feed::Site::LakeBtc)

[Finance::Bitcoin::Feed::Site::BitStamp](https://metacpan.org/pod/Finance::Bitcoin::Feed::Site::BitStamp)

# AUTHOR

Chylli  `<chylli@binary.com>`

# COPYRIGHT

Copyright 2014- Binary.com
