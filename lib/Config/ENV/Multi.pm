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

        push @{"$package\::ISA"}, __PACKAGE__;

        for my $method (qw/common config env debug/) {
            *{"$package\::$method"} = \&{__PACKAGE__ . "::" . $method}
        }

        no warnings 'once';
        ${"$package\::data"} = +{
            common      => {},
            specific    => {},
            envs        => $envs,
            current_env => undef,
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
    my $package = shift || caller(1);
    no strict 'refs';
    no warnings 'once';
    ${"$package\::data"};
}

sub _flatten {
    my $v = shift;
    $v = [$v] unless ref $v;
    join '%%', grep { $_ if ($_) } @{$v};
}
sub _parse {
    my $f = shift;
    [split '%%', $f];
}

sub env ($&) {
    my ($env, $code) = @_;
    my $f_env = _flatten($env);
    _data->{current_env} = $f_env;
    $code->();
    _data->{current_env} = undef;
}

sub common ($) {
    my ($hash) = @_;
    _data->{common} = $hash;
}

sub config ($$) {
    my ($names, $hash) = @_;
    my $name = _flatten($names);
    my $current_env = _data->{current_env};
    _data->{specific}->{$current_env}{$name} = $hash;
}

sub current {
    my ($package) = @_;
    my $data = _data($package);

    my $vals = +{
        %{ $data->{common} },
        %{ _env_value($package) || {} },
    };
}

sub _env_value {
    my ($package) = @_;
    my $data = _data($package)->{specific};
    my %targets;
    for my $env (keys %{$data})  {
        my $compiled = _flatten([map { $ENV{$_} } @{ _parse($env) }]);
        $targets{$env} = $data->{$env}{$compiled};
    }

    my %merged;
    for my $target (values %targets) {
        next unless $target;
        %merged = ( %merged , %$target );
    }
    return \%merged;
}

sub debug {
    my $package = shift;
    use Data::Dumper::Names; printf("[%s]\n%s \n",(caller 0)[3],Dumper(_env_value($package)));
}

1;
__END__

=encoding utf-8

=head1 NAME

Config::ENV::Multi - It's new $module

=head1 SYNOPSIS

    use Config::ENV::Multi;

=head1 DESCRIPTION

Config::ENV::Multi is ...

=head1 LICENSE

Copyright (C) Hiroyoshi Houchi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Hiroyoshi Houchi E<lt>git@hixi-hyi.comE<gt>

=cut

