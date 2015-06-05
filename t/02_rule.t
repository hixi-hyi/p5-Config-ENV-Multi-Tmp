$ENV{ENV}='prod';
$ENV{REGION}='jp';
use Config::ENV::Multi [qw/ENV REGION/],
    role => '{ENV}_{REGION}';

common {
    cnf => '/etc/my.cnf',
};

config prod_jp => {
    db_host => 'jp.local',
};

debug;
