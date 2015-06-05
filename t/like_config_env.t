package MyConfig;
use strict;
use warnings;
use Config::ENV::Multi 'REGION';

common {
    type => 's3',
};
config jp => {
    az => 'tokyo',
};
config us => {
    az => 'south',
};


use Test::More;
use Test::Deep;

undef $ENV{REGION};

cmp_deeply +__PACKAGE__->current, {
    type => 's3',
};

$ENV{REGION}='us';
cmp_deeply +__PACKAGE__->current, {
    type => 's3',
    az   => 'south',
};

$ENV{REGION}='jp';
cmp_deeply +__PACKAGE__->current, {
    type => 's3',
    az   => 'tokyo',
};

done_testing;
