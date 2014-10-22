# Copyright (c) 2012, cPanel, Inc.
# All rights reserved.
# http://cpanel.net/
#
# This is free software; you can redistribute it and/or modify it under the same
# terms as Perl itself.  See the LICENSE file for further details.

package Filesys::POSIX::Directory::Handle;

=head1 NAME

Filesys::POSIX::Directory::Handle - Basic placeholder for directory file handles

=head1 DESCRIPTION

This class provides a basic stub that allows for the return of a file handle
object based on a directory.  These are only meant to be used internally by
L<Filesys::POSIX::IO> and currently perform no functions of their own.

=cut

sub new {
    my ($class) = @_;

    return bless {}, $class;
}

sub open {
    my ($self) = @_;

    return $self;
}

sub close {
    return;
}

1;
