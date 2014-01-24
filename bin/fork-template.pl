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
	'L|loglevel=n'		=> \$h->{'config'}->{'loglevel'},
    'q|quiet'           => \$h->{'config'}->{'quiet'},
    'd|daemon'          => \$h->{'config'}->{'daemon'},
    'csvout=s'          => \$h->{'config'}->{'csvout'},
    'xmlout=s'          => \$h->{'config'}->{'xmlout'},
    'log=s'             => \$h->{'config'}->{'log'},
 	'n=s'				=> \@{$h->{'config'}->{'n'}}
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


##############################
# Output Functions

sub genCSVout {
}

sub genXMLout {
}

sub genHTMLout {
}

sub genSTDout {
}


############################################################
# Main
############################################################
use IO::Select;
use IO::Pipe;
use IO::Handle;

my @nodes = qw(one two three);
my $select_ch = IO::Select->new();
my @pids;
foreach my $_node (@nodes) {
	my $pid;
	my $pipe = IO::Pipe->new();
	#next if $pid = fork; #Parent goes to next server
	if ($pid = fork) {
		# in the parent
		print "Spawning PID: ", $pid, "... \n";
		my $fh = $pipe->reader();
		#$fh->blocking(10);
		$select_ch->add($fh);
		#push(@pids,$pid);
		#next;
	} else {
		# in the child
		#print ">>CHILD CODE\n";
		my $childhandle = $pipe->writer();
		#$childhandle->autoflush;
		sleep(3);
		print $childhandle "message1 from $_node\n";
		#print $childhandle "	sleeping $_node...\n";
		sleep(3);
		print $childhandle "message2 from $_node\n";
		#print $childhandle "	sleeping $_node...\n";
		sleep(3);
		print $childhandle "message3 from $_node\n";
		#print $childhandle "	sleeping $_node...\n";
		sleep(1);
		#die "fork failed: $!" unless defined $pid;
		#sleep(10);
		exit;
	}
}

# Now, wait until the child processes are done
#1 while (wait() != -1);
#while (waitpid(-1,0)) {
#print "waiting...\n";
#}
#my $kid;
#do {
#	$kid = waitpid(-1, WNOHANG);
#} while $kid > 0;
#1 while (waitpid(-1,0));
#1 while (wait() != -1) {
#print ".";
#}

print "aa\n";


my @readyfiles;
while ( @readyfiles = $select_ch->can_read() ) {
	print "bb\n";
	foreach my $rh (@readyfiles) {
		print "cc\n";
		while (my $child_resp_string = $rh->getline()) {
			print $child_resp_string;
		}
		$select_ch->remove($rh);
		$rh->close();
		print "@{[$select_ch->count()]} handles left to read\n";
	}
}
		



print "all done\n";

