# $File: //member/autrijus/Apache-Session-BerkeleyDB/lib/Apache/Session/Store/BerkeleyDB.pm $ $Author: autrijus $
# $Revision: #2 $ $Change: 657 $ $DateTime: 2002/08/16 05:53:51 $

package Apache::Session::Store::BerkeleyDB;

use strict;
use vars qw($VERSION);
use BerkeleyDB;
use File::Basename;

$VERSION = '1.01';

sub new {
    my $class = shift;
    return bless {dbm => {}}, $class;
}

sub _tie {
    my ($self, $session) = @_;
    return if tied %{$self->{dbm}};

    my $home = $session->{args}{Directory}
	    || dirname($session->{args}{FileName}) . '/db_env';

    mkdir $home, 0777 unless -e $home;

    my $env = BerkeleyDB::Env->new(
	-Home   => $home,
	-Flags  => DB_CREATE|DB_INIT_TXN|DB_INIT_MPOOL,
    ) or die $!;

    my $txn = $env->txn_begin;
    my $rv = tie %{$self->{dbm}}, 'BerkeleyDB::Hash', (
	-Filename  => $session->{args}{FileName},
	-Flags     => DB_CREATE,
	-Env       => $env,
	-Txn       => $txn,
    ) or die "Could not open BerkeleyDB file: $!";

    $self->{env} = $env;
    $self->{db} = $rv;

    return 1;
}

sub insert {
    my $self    = shift;
    my $session = shift;
    
    $self->_tie($session);
    
    if (exists $self->{dbm}->{$session->{data}->{_session_id}}) {
        die "Object already exists in the data store";
    }
    
    $self->{dbm}->{$session->{data}->{_session_id}} = $session->{serialized};
}

sub update {
    my $self = shift;
    my $session = shift;
    
    $self->_tie($session);
    
    $self->{dbm}->{$session->{data}->{_session_id}} = $session->{serialized};
}

sub materialize {
    my $self = shift;
    my $session = shift;
    
    $self->_tie($session);
    
    $session->{serialized} = $self->{dbm}->{$session->{data}->{_session_id}};

    if (!defined $session->{serialized}) {
        die "Object does not exist in data store";
    }
}

sub remove {
    my $self = shift;
    my $session = shift;
    
    $self->_tie($session);
    
    delete $self->{dbm}->{$session->{data}->{_session_id}};
}

1;

=pod

=head1 NAME

Apache::Session::Store::BerkeleyDB - Use BerkeleyDB to store persistent objects

=head1 SYNOPSIS

 use Apache::Session::Store::BerkeleyDB;
 
 my $store = new Apache::Session::Store::BerkeleyDB;
 
 $store->insert($ref);
 $store->update($ref);
 $store->materialize($ref);
 $store->remove($ref);

=head1 DESCRIPTION

This module fulfills the storage interface of Apache::Session.  The serialized
objects are stored in a Berkeley DB file using the BerkeleyDB Perl module.  If
BerkeleyDB works on your platform, this module should also work.

=head1 OPTIONS

This module requires one argument in the usual Apache::Session style.  The
name of the option is FileName, and the value is the full path of the database
file to be used as the backing store.  If the database file does not exist,
it will be created.  Example:

 tie %s, 'Apache::Session::BerkeleyDB', undef,
    {FileName => '/tmp/sessions'};

Additionally, you may specify a C<Directory> option, which is taken to be
the place to put BerkeleyDB's transaction data files.  If omitted, it defaults
to the C<db_env> subdirectory under the directory of C<FileName>.

=head1 SEE ALSO

L<Apache::Session>, L<Apache::Session::Lock::BerkeleyDB>, L<BerkeleyDB>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2002 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
