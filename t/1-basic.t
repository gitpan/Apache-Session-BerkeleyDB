#!/usr/bin/perl -w
# $File: //member/autrijus/Apache-Session-BerkeleyDB/t/1-basic.t $ $Author: autrijus $
# $Revision: #1 $ $Change: 653 $ $DateTime: 2002/08/16 04:24:45 $

use strict;
use Test;

BEGIN { plan tests => 3 }

ok (eval { require Apache::Session::BerkeleyDB; 1 });
warn $@ if $@;
ok (eval { require Apache::Session::Lock::BerkeleyDB; 1 });
warn $@ if $@;
ok (eval { require Apache::Session::Store::BerkeleyDB; 1 });
warn $@ if $@;

__END__
