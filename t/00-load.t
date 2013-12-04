#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 5;

BEGIN {
    use_ok('Carp');
    use_ok('POE');
    use_ok('CPAN::LinksToDocs::No404s::Remember');
    use_ok('POE::Component::NonBlockingWrapper::Base');
	use_ok( 'POE::Component::CPAN::LinksToDocs::No404s::Remember' );
}

diag( "Testing POE::Component::CPAN::LinksToDocs::No404s::Remember $POE::Component::CPAN::LinksToDocs::No404s::Remember::VERSION, Perl $], $^X" );
