package Config::ENV::Multi;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

sub import {
    my $class   = shift;
    my $package = caller(0);

    no strict 'refs';
    if (__PACKAGE__ eq $class) {
        my $envs = shift;
        my %opts    = @_;

        my $env;
        if (ref $envs) {
            $env = $envs;
            $envs = $envs;
        } else {
            $env = $envs;
            $envs = [$envs];
        }

        push @{"$package\::ISA"}, __PACKAGE__;

        for my $method (qw/common config env rule/) {
            *{"$package\::$method"} = \&{__PACKAGE__ . "::" . $method}
        }

        my $cache_rule = join '%%', map { "{$_}" } @{$envs};

        no warnings 'once';
        ${"$package\::data"} = +{
            common       => {},
            specific     => { env => {}, rule => {} },
            envs         => $envs,
            cache        => {},
            cache_rules  => $cache_rule,
            current_env  => undef,
            current_rule => undef,
            rule         => $opts{rule},
            env          => $cache_rule,
        };
    } else {
        my %opts    = @_;
        my $data = _data($class);
        if (my $export = $opts{export} || $data->{export}) {
           *{"$package\::$export"} = sub () { $class };
        }
    }
}

sub _data {
    my $package = shift;
    no strict 'refs';
    no warnings 'once';
    ${"$package\::data"};
}

sub _flatten_env {
    my $v = shift;
    $v = [$v] unless ref $v;
    join '%%', grep { $_ if ($_) } @{$v};
}

sub _parse_env {
    my $f = shift;
    [split '%%', $f];
}

sub _dataset {
    my $caption = shift;
    my $env = _defined($caption);
    my %envs = map { $_ => $ENV{$_} } @$env;
    return \%envs;
}

sub _defined {
    my ($caption) = @_;
    return [
        grep { defined && length }
        map {
            /^\{(.+?)\}$/ ? $1 : undef
        }
        grep { defined && length }
        split /(\{.+?\})/, $caption
    ];
}

sub _embeded {
    my ($caption, $dataset) = @_;
    return
        join '',
        map {
            /^\{(.+?)\}$/
                ? defined $dataset->{$1}
                    ? $dataset->{$1}
                    : ''
                : $_
        }
        grep { defined && length }
        split /(\{.+?\})/, $caption;
}

sub rule {
    my $package = caller(0);
    my ($rule, $code) = @_;
    _data($package)->{current_rule} = $rule;
    $code->();
    _data($package)->{current_rule} = undef;
}

sub env ($&) {
    my $package = caller(0);
    my ($env, $code) = @_;

    my $f_env = _flatten_env($env);
    _data($package)->{current_env} = $f_env;
    $code->();
    _data($package)->{current_env} = undef;
}


sub common ($) {
    my $package = caller(0);
    my ($hash) = @_;
    _data($package)->{common} = $hash;
}

sub _config_env {
    my ($package, $names, $hash) = @_;
    my $name = _flatten_env($names);
    my $current_env = _data($package)->{env} || _data($package)->{current_env};
    $current_env = "undef" unless $current_env;
    _data($package)->{specific}{env}{$current_env}{$name} = $hash;
}

sub _config_rule {
    my ($package, $names, $hash) = @_;
    my $name = _flatten_env($names);
    my $current_rule = _data($package)->{rule} || _data($package)->{current_rule};
    _data($package)->{specific}{rule}{$current_rule}{$name} = $hash;
}

sub config ($$) {
    my $package = caller(0);
    if (_data($package)->{rule} || _data($package)->{current_rule}) {
        return _config_rule($package, @_);
    } else {
        return _config_env($package, @_);
    }
}


sub current {
    my ($package) = @_;
    my $data = _data($package);

    my $cache_val = _embeded($data->{cache_rules}, _dataset($data->{cache_rules}));
    use Data::Dumper::Names; printf("[%s]\n%s \n",(caller 0)[3],Dumper(_env_value($package)));

    my $vals = $data->{cache}->{$cache_val} ||= +{
        %{ $data->{common} },
        %{ _env_value($package) || {} },
        %{ _env_value_asterisk($package) || {} },
        %{ _rule_value($package) || {} },
        %{ _rule_value_asterisk($package) || {} },
    };
}

sub _env_value {
    my ($package) = @_;
    my $data = _data($package)->{specific}{env};
    my %targets;
    for my $env (keys %{$data})  {
        my $t = [ map { $ENV{$_} } @{ _parse_env($env) } ];
        use Data::Dumper::Names; printf("[%s]\n%s \n",(caller 0)[3],Dumper($t));
        my $compiled = _flatten_env([map { $ENV{$_} } @{ _parse_env($env) }]);
        use Data::Dumper::Names; printf("[%s]\n%s \n",(caller 0)[3],Dumper($compiled));
        $targets{$env} = $data->{$env}{$compiled};
    }

    my %merged;
    for my $target (values %targets) {
        next unless $target;
        %merged = ( %merged , %$target );
    }
    return \%merged;
}

sub _env_value_asterisk {
    my ($package) = @_;
    my $data = _data($package)->{specific}{env};
    my %targets;
    for my $env (keys %{$data})  {
        my $compiled = _flatten_env([map { $ENV{$_} } @{ _parse_env($env) }]);
        $targets{$env} = $data->{$env}{$compiled};
    }

    my %merged;
    for my $target (values %targets) {
        next unless $target;
        %merged = ( %merged , %$target );
    }
    return \%merged;
}

sub _rule_value {
    my ($package) = @_;
    my $data = _data($package)->{specific}{rule};
    my %targets;
    for my $env (keys %{$data})  {
        my $compiled = _embeded($env, _dataset($env));
        $targets{$env} = $data->{$env}{$compiled};
    }

    my %merged;
    for my $target (values %targets) {
        next unless $target;
        %merged = ( %merged , %$target );
    }
    return \%merged;
}

sub _asterisk_dataset {
    my $caption = shift;
    my $asterisks = [];
    my $envs = _defined($caption);
    my @allenvs = ();
    push @allenvs , { map { $_ => '*' } @$envs };
    for my $target (@$envs) {
        my $ast = { map { $_ => '*' } @$envs };
        push @allenvs, { %$ast, $target => $ENV{$target} };
    }

    return \@allenvs;
}


sub _rule_value_asterisk {
    my ($package) = @_;
    my $data = _data($package)->{specific}{rule};
    my @targets;
    for my $env (keys %{$data})  {
        for my $dataset (@{_asterisk_dataset($env)}) {
            my $compiled = _embeded($env, $dataset);
            push @targets, $data->{$env}{$compiled};
        }
    }

    my %merged;
    for my $target (@targets) {
        next unless $target;
        %merged = ( %merged , %$target );
    }
    return \%merged;
}

1;
__END__

=encoding utf-8

=head1 NAME

Config::ENV::Multi - is ....

=head1 SYNOPSIS

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


=head1 DESCRIPTION

Config::ENV::Multi is the same of Config::ENV.
but supported Multi ENVIRONMENT VARIABLES.

=head1 LICENSE

Copyright (C) Hiroyoshi Houchi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Hiroyoshi Houchi E<lt>git@hixi-hyi.comE<gt>

=cut

