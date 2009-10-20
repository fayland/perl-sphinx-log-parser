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
    if(UNIVERSAL::isa($file, 'IO::Handle')) {
        $data{file} = $file;
    }
    elsif(UNIVERSAL::isa($file, 'File::Tail')) {
        $data{file} = $file;
        $data{filetail}=1;
    }
    elsif(! ref $file) {
        if($file eq '-') {
            my $io = new IO::Handle;
            $data{file} = $io->fdopen(fileno(STDIN),"r");
        }
        else {
            $data{file} = new IO::File($file, "<");
            defined $data{file} or croak "can't open $file: $!";
        }
    }
    else {
        croak "argument must be either a file-name or an IO::Handle object.";
    }

    return bless \%data, $class;
}

1;

=head1 SYNOPSIS

    use Sphinx::Log::Parser;

=head1 DESCRIPTION

bla bla

