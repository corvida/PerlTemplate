#!/usr/bin/perl

=head1 NAME

test.pl

=head1 SYNOPSIS

test.pl [--help] [--debug] [--verbose]

=head1 DESCRIPTION

test script for PerlTemplate.pm

=head1 AUTHOR

Bradford Leak <bleak@salesforce.com>

=cut

use strict;
use warnings;
use diagnostics;
use Data::Dumper;
use Getopt::Long;
Getopt::Long::Configure('bundling');
use Pod::Usage;
use Carp;
use FindBin;
use Sys::Syslog;
use POSIX;

BEGIN {
    push @INC, "$FindBin::Bin/../lib";
    push @INC, "$FindBin::Bin/../lib/perl5";
    push @INC, "$FindBin::Bin/../lib/perl5/x86_64-linux-thread-multi";
}

# use Log::Log4Perl;
use bleak::PerlTemplate;
############################################################
# Setup command line options:
############################################################
my $h;

GetOptions (
    'H|help'            => \$h->{'config'}->{'help'},
    'V|version'         => \$h->{'config'}->{'version'},
    'D|debug=n'         => \$h->{'config'}->{'debug'},
    'e|debugexit'       => \$h->{'config'}->{'debugexit'},
    'v|verbose=n'       => \$h->{'config'}->{'verbose'},
    'q|quiet'           => \$h->{'config'}->{'quiet'},
) or die pod2usage(1);
pod2usage(2) if $h->{'config'}->{'help'};

if (defined($h->{'config'}->{'version'})) {
    print "Author: Brad Leak\n";
    print "Version: ", $h->{'meta'}->{'version'}, "\n";
    exit 0;
}


##############################
# Set defaults
$h->{'config'}->{'debug'} = 0 unless(defined($h->{'config'}->{'debug'}));
$h->{'config'}->{'verbose'} = 0 unless(defined($h->{'config'}->{'verbose'}));
$h->{'config'}->{'loglevel'} = 0 unless(defined($h->{'config'}->{'loglevel'}));

##############################
# Print Debug Info:

if ($h->{'config'}->{'debug'} > 1 || defined($h->{'config'}->{'debugexit'}) ) {
    print "DEBUG: configfile=\$h->{'config'}->config\n";
    print Dumper($h);
    exit if defined($h->{'config'}->{'debugexit'});
}

##############################
# Sanity Checks:


############################################################
# Functions
############################################################




############################################################
# Main
############################################################
sub main {
	my $vars = {
	    debug => $h->{'config'}->{'debug'},
	    verbose => $h->{'config'}->{'verbose'}
	};
	
	my $t = new PerlTemplate($vars);
	$t->dm();
	print Dumper($t);
}

eval {
	main();
};
croak "Error running main($@)" if ($@);


