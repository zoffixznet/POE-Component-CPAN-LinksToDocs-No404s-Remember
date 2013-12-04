package POE::Component::CPAN::LinksToDocs::No404s::Remember;

use warnings;
use strict;

our $VERSION = '0.003';

use CPAN::LinksToDocs::No404s::Remember;
use Carp;
use POE;
use base 'POE::Component::NonBlockingWrapper::Base';

sub _methods_define {
    return ( link_for => '_wheel_entry' );
}

sub link_for {
    $poe_kernel->post( shift->{session_id} => link_for => @_ );
}

sub _prepare_wheel {
    my $self = shift;
    $self->{_linker} = CPAN::LinksToDocs::No404s::Remember->new(
        %{ $self->{obj_args} || {} }
    );
}

sub _check_args {
    my ( $self, $args_ref ) = @_;
    defined $args_ref->{tags}
        or carp "Missing 'tags' argumen"
            and return;

    return 1;
}

sub _process_request {
    my ( $self, $in_ref ) = @_;
    $in_ref->{response} = $self->{_linker}->link_for( $in_ref->{tags} );
}

1;
__END__

=encoding utf8

=head1 NAME

POE::Component::CPAN::LinksToDocs::No404s::Remember - non-blocking wrapper around CPAN::LinksToDocs::No404s::Remember module

=head1 SYNOPSIS

    use strict;
    use warnings;

    use POE qw(Component::CPAN::LinksToDocs::No404s::Remember);

    my $poco = POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn;

    POE::Session->create(
        package_states => [ main => [qw(_start response )] ],
    );

    $poe_kernel->run;

    sub _start {
        $poco->link_for( {
                tags => 'map,RE,Acme::BabyEater,POE',
                event => 'response',
            }
        );
    }

    sub response {
        print "$_\n" for @{ $_[ARG0]->{response} };

        $poco->shutdown;
    }

Using event based interface is also possible of course.

=head2 DESCRIPTION

The module is a non-blocking wrapper around
L<CPAN::LinksToDocs::No404s::Remember> module which provides interface to
lookup documentation by eating either predefined tags or module names

=head1 CONSTRUCTOR

=head2 spawn

    my $poco = POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn;

    POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn(
        alias => 'linker',
        obj_args => {
            tags => { foos => 'bars' },
            db_file => 'some_file.db',
        },
        options => {
            debug => 1,
            trace => 1,
            # POE::Session arguments for the component
        },
        debug => 1, # output some debug info
    );

The C<spawn> method returns a
POE::Component::CPAN::LinksToDocs::No404s::Remember object. It takes a
few arguments,
I<all of which are optional>. The possible arguments are as follows:

=head3 alias

    POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn(
        alias => 'linker'
    );

B<Optional>. Specifies a POE Kernel alias for the component.

=head3 obj_args

    POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn(
        obj_args => {
            tags => { foos => 'bars', },
            db_file => 'some_file.db',
        },
    );

The C<obj_args> argument takes a hashref as a value which will be
dereferenced directly into L<CPAN::LinksToDocs::No404s::Remember>
constructor. See documentation for the constructor of
L<CPAN::LinksToDocs::No404s::Remember> module
for possible arguments this hashref can contain.

=head3 options

    my $poco = POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn(
        options => {
            trace => 1,
            default => 1,
        },
    );

B<Optional>.
A hashref of POE Session options to pass to the component's session.

=head3 debug

    my $poco = POE::Component::CPAN::LinksToDocs::No404s::Remember->spawn(
        debug => 1
    );

When set to a true value turns on output of debug messages. B<Defaults to:>
C<0>.

=head1 METHODS

=head2 link_for

    $poco->link_for( {
            event => 'event_for_output',
            tags  => 'map,RE,Acme::BabyEater,POE',
            _blah => 'pooh!',
            session => 'other',
        }
    );

Takes a hashref as an argument, does not return a sensible return value.
See C<link_for> event's description for more information.

=head2 session_id

    my $poco_id = $poco->session_id;

Takes no arguments. Returns component's session ID.

=head2 shutdown

    $poco->shutdown;

Takes no arguments. Shuts down the component.

=head1 ACCEPTED EVENTS

=head2 link_for

    $poe_kernel->post( linker => link_for => {
            event   => 'event_for_output',
            tags    => 'map,RE,Acme::BabyEater,POE',
            _blah   => 'pooh!',
            session => 'other',
        }
    );

Instructs the component to fetch some docs for the tags or module names
you specify. Takes a hashref as an
argument, the possible keys/value of that hashref are as follows:

=head3 event

    { event => 'results_event', }

B<Mandatory>. Specifies the name of the event to emit when results are
ready. See OUTPUT section for more information.

=head3 tags

    { tags => 'map,RE,Acme::BabyEater,POE' }

B<Mandatory>. Takes a scalar string containing comma separated predefined
tags or module names. For list of predefined tags see L<CPAN::LinksToDocs>.

=head3 session

    { session => 'other' }

    { session => $other_session_reference }

    { session => $other_session_ID }

B<Optional>. Takes either an alias, reference or an ID of an alternative
session to send output to.

=head3 user defined

    {
        _user    => 'random',
        _another => 'more',
    }

B<Optional>. Any keys starting with C<_> (underscore) will not affect the
component and will be passed back in the result intact.

=head2 shutdown

    $poe_kernel->post( linker => 'shutdown' );

Takes no arguments. Tells the component to shut itself down.

=head1 OUTPUT

    $VAR1 = {
        'response' => [
            'http://perldoc.perl.org/functions/map.html',
            'http://perldoc.perl.org/functions/grep.html',
            'http://search.cpan.org/perldoc?Acme::BabyEater',
            'Not found'
        ],
        'tags' => 'map,grep,Acme::BabyEater,Zoffer',
        '_user' => 'foos',
    };

The event handler set up to handle the event which you've specified in
the C<event> argument to C<link_for()> method/event will recieve input
in the C<$_[ARG0]> in a form of a hashref. The possible keys/value of
that hashref are as follows:

=head2 response

    {
        'response' => [
            'http://perldoc.perl.org/functions/map.html',
            'http://perldoc.perl.org/functions/grep.html',
            'http://search.cpan.org/perldoc?Acme::BabyEater',
            'Not found'
        ],
    }

The C<response> key will contain a (possibly empty) arrayref of links
to documentation. This is the same arrayref that you would get from
L<CPAN::LinksToDocs::No404s::Remember>'s C<link_for()> method. See
documentation
for L<CPAN::LinksToDocs::No404s::Remember> module for more information.

=head2 tags

    { 'tags' => 'map,grep,Acme::BabyEater,Zoffer', }

The C<tags> key will contain whatever you've passed in C<tags> argument to
C<link_for()> method/event.

=head2 user defined

    { '_blah' => 'foos' }

Any arguments beginning with C<_> (underscore) passed into the C<link_for()>
event/method will be present intact in the result.

=head1 SEE ALSO

L<POE>, L<CPAN::LinksToDocs::No404s::Remember>

=head1 AUTHOR

Zoffix Znet, C<< <zoffix at cpan.org> >>
(L<http://zoffix.com>, L<http://haslayout.net>

=head1 BUGS

Please report any bugs or feature requests to C<bug-poe-component-cpan-linkstodocs-no404s-remember at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=POE-Component-CPAN-LinksToDocs-No404s-Remember>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc POE::Component::CPAN::LinksToDocs::No404s::Remember

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=POE-Component-CPAN-LinksToDocs-No404s-Remember>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/POE-Component-CPAN-LinksToDocs-No404s-Remember>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/POE-Component-CPAN-LinksToDocs-No404s-Remember>

=item * Search CPAN

L<http://search.cpan.org/dist/POE-Component-CPAN-LinksToDocs-No404s-Remember>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008 Zoffix Znet, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
