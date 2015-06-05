# NAME

Config::ENV::Multi - is ....

# SYNOPSIS

    package Config;
    use Config::ENC::Multi [qw/ENV REGION/];

    env 'ENV' => sub {
        config dev => {
            debug => 1,
        };
    };

    env 'REGION' => sub {
        config jp => {
            timeout => 1,
        };
        config us => {
            timeout => 5,
        },
    };

    use Config;
    Config->current;
    # $ENV{ENV}=dev, $ENV{REGION}=jp
    # {
    #   debug     => 1,
    #   timeout   => 1,
    # }

# DESCRIPTION

Config::ENV::Multi is the same of Config::ENV.
but supported Multi ENVIRONMENT VARIABLES.

# LICENSE

Copyright (C) Hiroyoshi Houchi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Hiroyoshi Houchi <git@hixi-hyi.com>
