#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 5;
use Sphinx::Log::Parser;
use FindBin qw/$Bin/;

my $parser = Sphinx::Log::Parser->new( "$Bin/0.9.8.log" );
my @sls;
while (my $sl = $parser->next) {
    push @sls, $sl;
}

is scalar @sls, 4;
# [Fri Jun 29 21:17:58 2007] 0.004 sec [all/0/rel 35254 (0,20)] [lj] test
is_deeply $sls[0], {
  'total_matches' => '35254',
  'match_mode' => 'all',
  'query' => 'test',
  'query_date' => 'Fri Jun 29 21:17:58 2007',
  'filter_count' => '0',
  'index_name' => 'lj',
  'limit' => '20',
  'query_time' => '0.004',
  'sort_mode' => 'rel',
  'groupby_attr' => undef,
  'offset' => '0'
};
# [Fri Jun 29 21:20:34 2007] 0.024 sec [all/0/rel 19886 (0,20) @channel_id] [lj] test
is_deeply $sls[1], {
  'total_matches' => '19886',
  'match_mode' => 'all',
  'query' => 'test',
  'query_date' => 'Fri Jun 29 21:20:34 2007',
  'filter_count' => '0',
  'index_name' => 'lj',
  'limit' => '20',
  'query_time' => '0.024',
  'sort_mode' => 'rel',
  'groupby_attr' => 'channel_id',
  'offset' => '0'
};
# [Tue Oct 20 02:42:29.979 2009] 0.005 sec [ext/3/ext 163 (0,100)] [*] @city_id "3889"
is_deeply $sls[2], {
  'total_matches' => '163',
  'match_mode' => 'ext',
  'query' => '@city_id "3889"',
  'query_date' => 'Tue Oct 20 02:42:29.979 2009',
  'filter_count' => '3',
  'index_name' => '*',
  'limit' => '100',
  'query_time' => '0.005',
  'sort_mode' => 'ext',
  'groupby_attr' => undef,
  'offset' => '0'
};
# [Tue Oct 20 02:42:30.052 2009] 0.048 sec [scan/4/attr- 106 (64,16)] [*]
is_deeply $sls[3], {
  'total_matches' => '106',
  'match_mode' => 'scan',
  'query' => '',
  'query_date' => 'Tue Oct 20 02:42:30.052 2009',
  'filter_count' => '4',
  'index_name' => '*',
  'limit' => '16',
  'query_time' => '0.048',
  'sort_mode' => 'attr-',
  'groupby_attr' => undef,
  'offset' => '64'
};

1;