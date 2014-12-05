use strict;
use warnings;

use Test::More tests => 1;
BEGIN { use_ok('Finance::Bitcoin::Feed::Pusher') }

#########################

diag q{
This module is based on Finance::BitStamp::Socket, and this test is also based on it.
Here is the origin content:

You should just test from the command line with:

 $ perl -e 'use lib qw(lib); use base qw(Finance::BitStamp::Socket); main->new->go'

You should see text socket broadcasts from BitStamp dump to the screen

};
