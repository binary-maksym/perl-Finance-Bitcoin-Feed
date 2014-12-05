requires 'Mojolicious';
requires 'AnyEvent';
requires 'Protocol::WebSocket';
requires 'JSON';
requires 'Scalar::Util';

on test => sub {
    requires 'Test::More', '0.96';
};
