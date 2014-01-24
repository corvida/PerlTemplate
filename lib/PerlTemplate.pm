package PerlTemplate;

=head1 NAME

PerlTemplate

=head1 SYNOPSIS

 my $t = new PerlTemplate;
 $t->debug=0;

=head1 DESCRIPTION

This Perl module does something interesting, I'm sure.

PUBLIC METHODS

PRIVATE METHODS

TODO

=head1 AUTHOR

Bradford Leak <bleak@salesforce.com>

=cut

use strict;
use warnings;
use diagnostics;
require Exporter;
use Carp;
use Data::Dumper;
use FindBin;
use Scalar::Util qw(looks_like_number);

BEGIN {
# use term::ReadKey;
    push @INC, "$FindBin::Bin/../lib";
}

use systools;
use Log::Log4perl qw(get_logger);

our $VERSION = "0.0.0";

my @ISA = qw(Exporter);
my @EXPORT = qw(new);

sub new {
    my ($_class, $options) = @_;
    my $self = {};
    bless($self, $_class);
	our $logger = get_logger("PerlTemplate");



    if (defined($options->{'debug'})) {
        $self->debug($options->{'debug'});
    } else {
        $self->debug(0);
    }

    if (defined($options->{'verbose'})) {
        $self->verbose($options->{'verbose'});
    } else {
        $self->verbose(0);
    }

    return $self;
}

sub debug {
    my $self = shift;
    if (@_) {
        $self->{'debug'} = shift;
        if (! looks_like_number($self->{'debug'})) {
            croak "invalid input: $self->{'debug'}";
        }
    }
    return $self->{'debug'};
}


sub verbose {
    my $self = shift;
    if (@_) {
        $self->{'verbose'} = shift;
        if (! looks_like_number($self->{'verbose'})) {
            croak "invalid input: $self->{'verbose'}";
        }
    }
    return $self->{'verbose'};
}

sub dm {
	my $self = shift;
	#print debugstr(), " **\n";
	$self->debugstr("**");
	#print "DEBUG1 ", __PACKAGE__, "()>> **\n";
	#my ($pkg, $filename, $line) = caller;
	#my $whoami = (caller(0))[3];
	#my $whowasi = (caller(1))[0];
	#print "DEBUG ", $pkg , " ", $filename, "()>> **\n";
	#print "DEBUG ", $filename, ">>", $whowasi, ">>", $whoami, "()>> **\n";
	#print "DEBUG2 ", whowasi(), ">>", whoami(), ">> **\n";
	#print debugstr(), " --\n";
	$self->debugstr("--");
	return;
}


sub doer {
	our $logger;
	$logger->debug("**");

	my $self = shift;
	my $options = shift;




	$logger->debug("--");
} #End of doer()



sub debugstr {	
	my $self = shift;
	my $str = shift;
	if ($self->{'debug'} > 0) {
		my $msg = "DEBUG " . (caller(2))[0] . ">>" . (caller(1))[3] . ">> " . $str ;
		print $str, "\n";
	}
	return;
}
sub whoami {(caller(1))[3]}
sub whowasi {(caller(2))[0]}



1;
