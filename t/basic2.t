package MyConfig;
use strict;
use warnings;
use Config::ENV::Multi [qw/ENV REGION/];

config [qw/* */] => {
    cnf => 'my.cnf',
};
config [qw/prod jp/] => {
    db_host => 'jp.local',
};
config [qw/dev jp/] => {
    db_host => 'localhost',
};
config [qw/prod us/] => {
    db_host => 'us.local',
};
config [qw/dev us/] => {
    db_host => 'localhost',
};

use Test::More;
use Test::Deep;

undef $ENV{ENV};
undef $ENV{REGION};

cmp_deeply +__PACKAGE__->current, {
    cnf => '/etc/my.cnf',
};

$ENV{ENV}='prod';
undef $ENV{REGION};

cmp_deeply +__PACKAGE__->current, {
    cnf     => '/etc/my.cnf',
    is_prod => 1,
};

$ENV{ENV}='prod';
$ENV{REGION}='jp';

cmp_deeply +__PACKAGE__->current, {
    cnf     => '/etc/my.cnf',
    is_prod => 1,
    az      => 'tokyo',
    db_host => 'jp.local',
};

done_testing;
