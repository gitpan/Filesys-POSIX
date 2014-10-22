# Copyright (c) 2012, cPanel, Inc.
# All rights reserved.
# http://cpanel.net/
#
# This is free software; you can redistribute it and/or modify it under the same
# terms as Perl itself.  See the LICENSE file for further details.

use strict;
use warnings;

use Filesys::POSIX             ();
use Filesys::POSIX::Mem        ();
use Filesys::POSIX::Mem::Inode ();
use Filesys::POSIX::Bits;

use File::Temp ();

use Test::More ( 'tests' => 11 );
use Test::Exception;
use Test::NoWarnings;

my $tmpdir = File::Temp::tempdir( 'CLEANUP' => 1 );
my ( $tmpfile_fh, $tmpfile ) = File::Temp::tempfile( 'DIR' => $tmpdir );

my $fs = Filesys::POSIX->new( Filesys::POSIX::Mem->new );
$fs->import_module('Filesys::POSIX::Extensions');

$fs->mkpath('/mnt/mem');
$fs->mount(
    Filesys::POSIX::Mem->new, '/mnt/mem',
    'noatime' => 1
);

$fs->mkdir('/bin');

$fs->map( $tmpfile, '/bin/sh' );
my $inode = $fs->stat('/bin/sh');

#
# Testing Filesys::POSIX->map()
#
{
    ok( ref($inode) eq 'Filesys::POSIX::Real::Inode', "Filesys::POSIX->map() succeeded" );

    throws_ok {
        $fs->touch('/bin/false');
        $fs->map( '/bin/false', '/bin/false' );
    }
    qr/^File exists/, "Filesys::POSIX->map() fails when destination exists";
}

#
# Testing Filesys::POSIX->attach()
#
{
    $fs->attach( $inode, '/bin/bash' );
    ok( $fs->stat('/bin/bash') eq $inode, "Filesys::POSIX->attach() operates expectedly" );

    throws_ok {
        $fs->touch('/bin/ksh');
        $fs->attach( $inode, '/bin/ksh' );
    }
    qr/^File exists/, "Filesys::POSIX->attach() will complain when destination exists";
}

#
# Testing Filesys::POSIX->alias()
#
{
    $fs->mkdir('/mnt/mem/bin');
    $fs->alias( '/bin/bash', '/mnt/mem/bin/bash' );
    ok( $fs->stat('/mnt/mem/bin/bash') eq $inode, "Filesys::POSIX->alias() operates expectedly" );

    throws_ok {
        $fs->alias( '/bin/sh', '/mnt/mem/bin/bash' );
    }
    qr/^File exists/, "Filesys::POSIX->alias() will complain when destination exists";
}

#
# Testing Filesys::POSIX->detach()
#
{
    throws_ok {
        $fs->detach('/mnt/mem/bin/bash');
        $fs->stat('/mnt/mem/bin/bash');
    }
    qr/^No such file or directory/, "Filesys::POSIX->detach() operates expectedly";

    throws_ok {
        $fs->detach('/mnt/mem/bin/bash');
    }
    qr/^No such file or directory/, "Filesys::POSIX->detach() will complain when specified inode does not exist";
}

#
# Testing Filesys::POSIX->replace()
#
{
    $fs->touch('/bin/true');
    $fs->replace( '/bin/true', $inode );
    ok( $fs->stat('/bin/true') eq $inode, "Filesys::POSIX->replace() operates expectedly" );

    throws_ok {
        $fs->replace( '/bin/csh', $inode );
    }
    qr/^No such file or directory/, "Filesys::POSIX->replace() will complain when specified path does not exist";
}
