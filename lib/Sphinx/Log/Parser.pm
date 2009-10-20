package Sphinx::Log::Parser;

use strict;
use warnings;

# ABSTRACT: parse Sphinx searchd log

use Carp;
use IO::File;
use IO::Handle;

sub new {
    my ($class, $file) = @_;

    my %data;
    if (UNIVERSAL::isa($file, 'IO::Handle')) {
        $data{file} = $file;
    } elsif (UNIVERSAL::isa($file, 'File::Tail')) {
        $data{file} = $file;
        $data{filetail}=1;
    } elsif (! ref $file) {
        if($file eq '-') {
            my $io = new IO::Handle;
            $data{file} = $io->fdopen(fileno(STDIN),"r");
        } else {
            $data{file} = new IO::File($file, "<");
            defined $data{file} or croak "can't open $file: $!";
        }
    } else {
        croak "argument must be either a file-name or an IO::Handle/File::Tail object.";
    }

    return bless \%data, $class;
}

sub _next_line {
    my $self = shift;
    my $f = $self->{file};
    if (defined $self->{filetail}) {
        return $f->read;
    } else {
        return $f->getline;
    }
}

sub next {
    my ($self) = @_;
    
    while(defined (my $str = $self->_next_line)) {
        # 0.9.8.1
        # [Tue Oct 20 02:42:29.950 2009] 0.528 sec [ext/5/attr- 25863 (0,800)] [*] @sexual_preference Male -Female
        # [query-date] query-time [match-mode/filters-count/sort-mode total-matches (offset,limit) @groupby-attr] [index-name] query

        my @parts = split('\]', $str, 4);
        # [
        #  '[Tue Oct 20 02:42:29.979 2009',
        #  ' 0.005 sec [ext/3/ext 163 (0,100)',
        #  ' [*',
        #  ' @city_id "3889"'
        #];

        #  '[Tue Oct 20 02:42:29.979 2009',
        my $query_date = $parts[0]; $query_date =~ s/^\[//;
        #  ' 0.005 sec [ext/3/ext 163 (0,100)',
        $parts[1] =~ /^\s*([\d\.]+)\s+sec\s+\[(\w+)\/(\d+)\/([\w\-\+]+)\s(\d+)\s\((\d+)\,(\d+)\)\s*\@?(\S+)?$/;
        my $query_time = $1;
        my $match_mode = $2;
        my $filter_count = $3;
        my $sort_mode  = $4;
        my $total_matches = $5;
        my $offset = $6;
        my $limit  = $7;
        my $groupby_attr = $8;
        #  ' [*',
        my $index_name = $parts[2]; $index_name =~ s/^\s*\[//;
        #  ' @city_id "3889"'
        my $query = $parts[3]; $query =~ s/(^\s+|\s+$)//g;

        return {
            query_date => $query_date,
            query_time => $query_time,
            match_mode => $match_mode,
            filter_count => $filter_count,
            sort_mode  => $sort_mode,
            total_matches => $total_matches,
            offset => $offset,
            limit  => $limit,
            groupby_attr => $groupby_attr,
            index_name => $index_name,
            query  => $query
        };
    }
    return;
}

1;

=head1 SYNOPSIS

    use Sphinx::Log::Parser;
    
    my $parser = Sphinx::Log::Parser->new( '/var/log/searchd/query.log' );
    while (my $sl = $parser->next) {
        print $sl->{total_matches}, $sl->{query_date}, "\n"; # more
    }

=head1 DESCRIPTION

Sphinx::Log::Parser parse sphinx searchd query.log based on L<http://sphinxsearch.com/docs/current.html#query-log-format>

=head2 Constructing a Parser

B<new> requires as first argument a source from where to get the syslog lines. It can
be:

=over 4

=item *

a filename for the searchd query log to be parsed. check B<query_log> in conf file

=item *

an IO::Handle object.

=item *

a File::Tail object as first argument, in which
case the I<read> method will be called to get lines to process.

=item *

The log string, you need use L<IO::Scalar>

    use IO::Scalar;
    my $logstr = '[Fri Jun 29 21:20:34 2007] 0.024 sec [all/0/rel 19886 (0,20) @channel_id] [lj] test';
    my $io = new IO::Scalar \$logstr;
    my $parser = Sphinx::Log::Parser->new( $io );

=back

=head2 Parsing the file

The file is parse one line at a time by calling the B<next> method, which returns
a hash-reference containing the following keys:

    {
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
    }

The log format is

    [query-date] query-time [match-mode/filters-count/sort-mode
        total-matches (offset,limit) @groupby-attr] [index-name] query
