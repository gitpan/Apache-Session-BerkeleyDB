# $File: //member/autrijus/Apache-Session-BerkeleyDB/lib/Apache/Session/Lock/BerkeleyDB.pm $ $Author: autrijus $
# $Revision: #2 $ $Change: 657 $ $DateTime: 2002/08/16 05:53:51 $

package Apache::Session::Lock::BerkeleyDB;

use strict;
use vars qw($VERSION);
use BerkeleyDB;

$VERSION = '1.00';

sub new {
    my $class = shift;
    return bless { read => 0, write => 0, id => 0 }, $class;
}

sub acquire_read_lock  {
    my $self    = shift;
    my $session = shift;
    
    return if $self->{read};

    my $store = $session->{object_store};
    $store->_tie($session);
    my $txn = $store->{env}->txn_begin;

    $store->{db}->Txn($txn); $store->{dbm}{__readlock} += 1;
    while ($store->{dbm}{__readlock} > 1) { sleep 1 }
    $store->{txn_write} = $txn;

    $self->{read} = 1;
}

sub acquire_write_lock {
    my $self    = shift;
    my $session = shift;

    my $store = $session->{object_store};
    $store->_tie($session);
    my $txn = $store->{env}->txn_begin;

    $store->{db}->Txn($txn); $store->{dbm}{__writelock} += 1;
    while ($store->{dbm}{__writelock} > 1) { sleep 1 }
    $store->{txn_read} = $txn;

    $self->{write} = 1;
}

sub release_read_lock  {
    my $self    = shift;
    my $session = shift;
    
    die unless $self->{read};

    my $store = $session->{object_store} or return;
    $store->_tie($session);
    $store->{dbm}{__readlock} -= 1;
    $store->{txn_read}->txn_commit;
    
    $self->{read} = 0;
}

sub release_write_lock {
    my $self    = shift;
    my $session = shift;
    
    die unless $self->{write};
    
    my $store = $session->{object_store};
    $store->_tie($session);
    $store->{dbm}{__writelock} -= 1;
    $store->{txn_write}->txn_commit;
    
    $self->{write} = 0;
}

sub release_all_locks  {
    my $self    = shift;
    my $session = shift;

    $self->release_write_lock($session) if $self->{write};
    $self->release_read_lock($session) if $self->{read};
    
    $self->{read}   = 0;
    $self->{write}  = 0;
}

sub DESTROY {
    my $self = shift;
    $self->release_all_locks;
}

sub clean {
}

1;

=pod

=head1 NAME

Apache::Session::Lock::BerkeleyDB - Provides mutual exclusion using transaction

=head1 SYNOPSIS

 use Apache::Session::Lock::BerkeleyDB;
 
 my $locker = new Apache::Session::Lock::BerkeleyDB;
 
 $locker->acquire_read_lock($ref);
 $locker->acquire_write_lock($ref);
 $locker->release_read_lock($ref);
 $locker->release_write_lock($ref);
 $locker->release_all_locks($ref);

=head1 DESCRIPTION

Apache::Session::Lock::BerkeleyDB fulfills the locking interface of 
Apache::Session.  Mutual exclusion is achieved through the use of temporary
keys and BerkeleyDB's transaction support.

=head1 CONFIGURATION

The module must work with L<Apache::Session::Store::BerkeleyDB>.

=head1 SEE ALSO

L<Apache::Session>, L<Apache::Session::Store::BerkeleyDB>, L<BerkeleyDB>

=head1 AUTHORS

Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>

=head1 COPYRIGHT

Copyright 2002 by Autrijus Tang E<lt>autrijus@autrijus.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
