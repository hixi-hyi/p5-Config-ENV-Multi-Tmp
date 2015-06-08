package MyConfig;
use strict;
use warnings;
use Config::ENV::Multi [qw/ENV REGION/],
    rule => '{ENV}_{REGION}';

config 'prod_*' => {
    db_host => 'jp.local',
};

use Test::More;
use Test::Deep;

undef $ENV{ENV};
undef $ENV{REGION};

cmp_deeply +__PACKAGE__->current, {};

$ENV{ENV}='prod';
undef $ENV{REGION};

cmp_deeply +__PACKAGE__->current, {
    db_host => 'jp.local',
};

$ENV{ENV}='prod';
$ENV{REGION}='jp';


cmp_deeply +__PACKAGE__->current, {
    db_host => 'jp.local',
};

done_testing;
