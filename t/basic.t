#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1;
use Sphinx::Log::Parser;

ok(1);

# 0.9.8.1
my $log = <<LOG;
[Tue Oct 20 02:42:29.950 2009] 0.528 sec [ext/5/attr- 25863 (0,800)] [*] @sexual_preference Male -Female
[Tue Oct 20 02:42:29.979 2009] 0.005 sec [ext/3/ext 163 (0,100)] [*] @city_id "3889"
[Tue Oct 20 02:42:30.052 2009] 0.048 sec [scan/4/attr- 106 (64,16)] [*]
[Tue Oct 20 02:42:30.086 2009] 0.001 sec [ext/0/attr- 0 (0,700)] [*] @username ("francine | cassiday")
[Tue Oct 20 02:42:30.090 2009] 0.001 sec [ext/0/attr- 0 (0,700)] [*] @first_name ("francine | cassiday")
LOG


1;