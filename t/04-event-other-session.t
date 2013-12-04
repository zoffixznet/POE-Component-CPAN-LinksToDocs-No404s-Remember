#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 3;

use POE qw(Component::CPAN::LinksToDocs::No404s::Remember);

POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn(
    obj_args => { tags => {foos => 'bars'}, timeout => 10 },
    debug => 1,
    alias => 'linker',
);

my $VAR1 = [
          'http://perldoc.perl.org/functions/map.html',
          'http://perldoc.perl.org/functions/grep.html',
          'http://search.cpan.org/perldoc?perlrequick',
          'http://search.cpan.org/perldoc?perlretut',
          'http://search.cpan.org/perldoc?perlre',
          'http://search.cpan.org/perldoc?perlreref',
          'http://search.cpan.org/perldoc?perlboot',
          'http://search.cpan.org/perldoc?perltoot',
          'http://search.cpan.org/perldoc?perltooc',
          'http://search.cpan.org/perldoc?perlbot',
          'bars',
        ];

POE::Session->create(
    inline_states => {
        _start => sub {
            $poe_kernel->post( linker => link_for => {
                tags=>'map,grep,RE,OOP,foos',
                event=>'results',
                _user=>'foos',
                session => 'other'});
        },
    },
);

POE::Session->create(
    package_states => [
        main => [ qw(_start results) ],
    ],
);

$poe_kernel->run;
sub _start {
    $_[KERNEL]->alias_set('other');
}
sub results {
    my $in = $_[ARG0];
    is_deeply(
        $in->{response},
        $VAR1,
        'checks for links'
    );
    is($in->{tags},'map,grep,RE,OOP,foos', '{tags}');
    is($in->{_user}, 'foos', 'user defined args');
    $poe_kernel->post( linker => 'shutdown' );
}