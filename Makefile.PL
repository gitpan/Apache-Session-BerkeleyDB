#!/usr/bin/perl
# $File: //member/autrijus/Apache-Session-BerkeleyDB/Makefile.PL $ $Author: autrijus $
# $Revision: #2 $ $Change: 670 $ $DateTime: 2002/08/16 18:42:29 $

require 5.005;

use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR		=> 'Autrijus Tang (autrijus@autrijus.org)',
    ABSTRACT		=> 'Session from already interpolated strings',
    NAME		=> 'Apache::Session::BerkeleyDB',
    VERSION_FROM	=> 'lib/Apache/Session/Store/BerkeleyDB.pm', 
    DISTNAME		=> 'Apache-Session-BerkeleyDB',
    BINARY_LOCATION	=> 'x86/Apache-Session-BerkeleyDB.tar.gz',

    PREREQ_PM		=> {
	'Apache::Session'	=> '1.00',
	'BerkeleyDB'		=> '0',
    },

    dist		=> {
        COMPRESS	=> 'gzip -9',
        SUFFIX		=> '.gz',
    },
);

