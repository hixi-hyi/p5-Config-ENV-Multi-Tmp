$ENV{ENV}='prod';
$ENV{REGION}='jp';
use Config::ENV::Multi 'ENV';

common {
    cnf => '/etc/my.cnf',
};

config prod => {
    db_host => 'jp.local',
};

debug;
