package MyConfig;
use strict;
use warnings;
use Config::ENV::Multi [qw/ENV REGION/];

config [qw/* */] => {
    cnf => 'my.cnf',
};
config ['prod', undef] => {
    env    => 'prod',
    region => undef,
};
config [qw/prod jp/] => {
    env    => 'prod',
    region => 'jp',
};
config [qw/dev jp/] => {
    env    => 'dev',
    region => 'jp',
};
config [qw/prod us/] => {
    env    => 'prod',
    region => 'us',
};
config [qw/dev us/] => {
    env    => 'prod',
    region => 'us',
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
    env    => 'prod',
    region => undef,
};

$ENV{ENV}='prod';
$ENV{REGION}='jp';

cmp_deeply +__PACKAGE__->current, {
    cnf     => '/etc/my.cnf',
    env    => 'prod',
    region => 'jp',
};

done_testing;
