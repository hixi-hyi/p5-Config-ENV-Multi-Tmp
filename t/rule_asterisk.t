package MyConfig;
use strict;
use warnings;
use Config::ENV::Multi [qw/ENV REGION/];

common {
    cnf => '/etc/my.cnf',
};

rule '{ENV}_{REGION}' => sub {
    config 'prod_*' => {
        db_host => 'jp.local',
    };
};

use Test::More;
use Test::Deep;

undef $ENV{ENV};
undef $ENV{REGION};

cmp_deeply +__PACKAGE__->current, {
    cnf => '/etc/my.cnf',
};

$ENV{ENV}='prod';
$ENV{REGION}='jp';

cmp_deeply +__PACKAGE__->current, {
    cnf => '/etc/my.cnf',
    db_host => 'jp.local',
};

done_testing;
