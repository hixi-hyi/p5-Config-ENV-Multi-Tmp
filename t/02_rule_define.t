package MyConfig;
use strict;
use warnings;
use Config::ENV::Multi [qw/ENV REGION/],
    rule => '{ENV}_{REGION}';

common {
    cnf => '/etc/my.cnf',
};

config 'prod_jp' => {
    db_host => 'jp.local',
};

config 'prod_dev' => {
    db_host => 'localhost',
};

use Test::More;
use Test::Deep;

undef $ENV{ENV};
undef $ENV{REGION};

__PACKAGE__->debug;

cmp_deeply +__PACKAGE__->current, {
    cnf => '/etc/my.cnf',
};

$ENV{ENV}='prod';
$ENV{REGION}='jp';

__PACKAGE__->debug;

cmp_deeply +__PACKAGE__->current, {
    cnf => '/etc/my.cnf',
    db_host => 'jp.local',
};

done_testing;
