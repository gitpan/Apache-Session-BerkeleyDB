# $File: //member/autrijus/Apache-Session-BerkeleyDB/lib/Apache/Session/BerkeleyDB.pm $ $Author: autrijus $
# $Revision: #1 $ $Change: 653 $ $DateTime: 2002/08/16 04:24:45 $

package Apache::Session::BerkeleyDB;

use strict;
use vars qw(@ISA $VERSION);

$VERSION = '1.00';
@ISA = qw(Apache::Session);

use Apache::Session;
use Apache::Session::Lock::BerkeleyDB;
use Apache::Session::Store::BerkeleyDB;
use Apache::Session::Generate::MD5;
use Apache::Session::Serialize::Storable;

sub populate {
    my $self = shift;

    $self->{object_store} = new Apache::Session::Store::BerkeleyDB $self;
    $self->{lock_manager} = new Apache::Session::Lock::BerkeleyDB $self;
    $self->{generate}     = \&Apache::Session::Generate::MD5::generate;
    $self->{validate}     = \&Apache::Session::Generate::MD5::validate;
    $self->{serialize}    = \&Apache::Session::Serialize::Storable::serialize;
    $self->{unserialize}  = \&Apache::Session::Serialize::Storable::unserialize;

    return $self;
}

1;

=pod

=head1 NAME

Apache::Session::BerkeleyDB - An implementation of Apache::Session

=head1 SYNOPSIS

 use Apache::Session::BerkeleyDB;
 
 tie %hash, 'Apache::Session::BerkeleyDB', $id, {
	FileName  => 'sessions.db',
 };

=head1 DESCRIPTION

This module is an implementation of Apache::Session.  It uses the BerkeleyDB
backing store and the BerkeleyDB locking scheme.  You must specify the filename of
the database file and the directory for locking in arguments to the constructor.
See the example, and the documentation for Apache::Session::Store::BerkeleyDB and
Apache::Session::Lock::BerkeleyDB.

=head1 SEE ALSO

L<Apache::Session::DB_File>, L<Apache::Session::File>, L<Apache::Session::Flex>,
L<Apache::Session::MySQL>, L<Apache::Session::Postgres>, L<Apache::Session>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2002 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
