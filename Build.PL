#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name   => 'Test::Builder::XS',
    license       => 'perl',
    dist_author   => 'Chad Granum <exodist7@gmail.com>',
    create_readme => 1,
    requires      => {
        XSLoader => 0,
        Exporter => '5.57',
    },
    configure_requires => {
        'Module::Build' => 0,
    },
    requires => {
        perl => '5.008',
    },
    add_to_cleanup     => ['Test-Builder-*'],
    create_makefile_pl => 'small',
    recursive_test_files => 1,
    meta_merge         => {
        resources => {
            repository => 'http://github.com/exodist/Test-Builder-XS',
            bugtracker => 'http://github.com/exodist/Test-Builder-XS/issues',
        },
    },
);

$build->create_build_script;
