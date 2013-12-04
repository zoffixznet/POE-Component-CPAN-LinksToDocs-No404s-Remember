#!/usr/bin/env perl

use strict;
use warnings;

use lib '../lib';
use POE qw(Component::CPAN::LinksToDocs::No404s::Remember);

die "Usage: perl link.pl <tags_or_module_names_to_lookup>\n"
    unless @ARGV;

my $Tags = shift;

my $poco = POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn;

POE::Session->create(
    package_states => [ main => [qw(_start response )] ],
);

$poe_kernel->run;

sub _start {
    $poco->link_for( {
            tags => $Tags,
            event => 'response',
        }
    );
}

sub response {
    print "$_\n" for @{ $_[ARG0]->{response} };

    $poco->shutdown;
}
