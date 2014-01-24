#!/opt/local/bin/perl 

=head1 NAME

test.pl

=head1 SYNOPSIS

test.pl [--help] [--debug] [--verbose]

=head1 DESCRIPTION

 test script for PerlTemplate.pm
 Acceptance Criteria: 
 * SSH into a system (server or network devices or storage array), run a command and parse the output. 
 * Use pp to inspect the parsed output 
 * Use YAML module to dump the parsed output to YAML 
 * Functions are written in self contained gems 
 * The SSH function is designed to execute in a separate forked pid 
 * Each function is documented via RDOC 
 * Each function produces logs of varying verboseness to a native log, stderr/stdout, and syslog (spike logger versus Log4r) 
 * Each template contains standard rake build instructions which produce a directory structure suitable for packaging 
 * Utilizes standard CLI input: --debug --verbose --version --help --host, --workers, etc.... (spike getoptlong versus optionparser) 

=head1 AUTHOR

Bradford Leak <bleak@salesforce.com>

=cut

my $ec = 0;

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
	#push @INC, "$FindBin::Bin/../../p3/lib";
	#push @INC, "$FindBin::Bin/../../p3/lib/perl5";
	#push @INC, "$FindBin::Bin/../../p3/lib/perl5/x86_64-linux-thread-multi";
	#push @INC, "$FindBin::Bin/../../p3/lib/perl5/darwin-multi-2level";

	push @INC, "$FindBin::Bin/../lib";
	push @INC, "$FindBin::Bin/../lib/perl5";
	push @INC, "$FindBin::Bin/../lib/perl5/x86_64-linux-thread-multi";
	push @INC, "/Users/bleak/ops/lib/perl5";
	foreach ('PerlTemplate','systools','YAML::XS') {
		croak "$_ module not available" unless eval "use $_; 1";
	}
}
#warn "systools module not available" unless eval {require systools;1};
use systools;
use PerlTemplate;
use YAML::XS qw(LoadFile);



############################################################
# Setup CLI and Parse Config:
############################################################
my $h = systools->new();
my $yamlconf;
if ( -e $h->{'meta'}->{'yamlconfig'} ) {
	$yamlconf = LoadFile($h->{'meta'}->{'yamlconfig'});
	$h->{'config'}->{'nodes'} = $yamlconf->{'nodes'} if $yamlconf->{'nodes'};
}

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
 	'n=s'				=> \@{$h->{'config'}->{'n'}},
	'host=s'			=> \@{$h->{'config'}->{'clihosts'}},
	'o|outputtype=s'	=> \$h->{'config'}->{'outputtype'},
	'noheader'			=> \$h->{'config'}->{'noheader'},
) or die pod2usage(1);
pod2usage(2) if $h->{'config'}->{'help'};

if (defined($h->{'config'}->{'version'})) {
    print "Author: Brad Leak\n";
    print "Version: ", $h->{'meta'}->{'version'}, "\n";
    exit 0;
}

if ( defined @{$h->{'config'}->{'clihosts'}} && @{$h->{'config'}->{'clihosts'}} ) {
	undef $h->{'config'}->{'nodes'};
	@{$h->{'config'}->{'nodes'}} = @{$h->{'config'}->{'clihosts'}};
	undef $h->{'config'}->{'clihosts'};
}

if ( not defined $h->{'config'}->{'nodes'} ) {
	push @{$h->{'config'}->{'nodes'}} , $h->{'sys'}->{'hostname'};
}

##############################
# Set up logging
#use Log::Log4Perl qw(get_logger :levels);
#Log::Log4perl->easy_init($INFO);
#my $logger = get_logger();
#
#my $layout = Log::Log4perl::Layout::PatternLayout->new("%d %p> %F{1}:%L %M - %m%n");
#my $screenappender = Log::Log4perl::Appender->new("Log::Log4perl::Appender::Screen",name=>'dumpy');
#my $logappender = Log::Log4perl::Appender->new("Log::Dispatch::File", filename=> $h->{'config'}->{'log'}, mode=> "append",);
#$screenappender->layout($layout);
#$logappender->layout($layout);
#$logger->add_appender($logappender);
	
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init(
                          {
                            level       => $DEBUG,
                            file        => ">> $h->{'config'}->{'log'}",
                            category    => "PerlTemplate",
                            layout      => "<date \"%d\"/><level \"%p\"/><pid %P/><hostname %H/><source /><message %m/>%n",
                          } ,
#                          {
#                            level       => $DEBUG,
#                            file        => ">> $h->{'config'}->{'log'}",
#                            category    => "DAL::OracleDB",
#                            layout      => "<date \"%d\"/><level \"%p\"/><pid %P/><hostname %H/><source /><message %m/>%n",
#                          } ,
#                          {
#                            level       => $DEBUG,
#                            file        => ">> $h->{'config'}->{'log'}",
#                            category    => "SAL::Array3PAR",
#                            layout      => "<date \"%d\"/><level \"%p\"/><pid %P/><hostname %H/><source /><message %m/>%n",
#                          } ,
#                          {
#                            level       => $DEBUG,
#                            file        => ">> $h->{'config'}->{'log'}",
#                            category    => "XAL",
#                            layout      => "<date \"%d\"/><level \"%p\"/><pid %P/><hostname %H/><source /><message %m/>%n",
#                          } ,
                        );
my $logger = get_logger();

############################################################
# Set defaults
############################################################
$h->{'config'}->{'debug'} = 0 unless(defined($h->{'config'}->{'debug'}));
$h->{'config'}->{'verbose'} = 0 unless(defined($h->{'config'}->{'verbose'}));
$h->{'config'}->{'loglevel'} = 0 unless(defined($h->{'config'}->{'loglevel'}));

############################################################
# Print Debug Info:
############################################################
if ($h->{'config'}->{'debug'} > 1 || defined($h->{'config'}->{'debugexit'}) ) {
    print "DEBUG: configfile=\$h->{'config'}->config\n";
    print Dumper($h);
    exit if defined($h->{'config'}->{'debugexit'});
}

############################################################
# Functions
############################################################

############################################################
# Main
############################################################
sub main {
	my $pt = PerlTemplate->new();


	eval {
		$pt->doer(
			{
				one => '1',
				two => '2',
			}
		);
	};
    if ($@) {
        $@ =~ s/(\S+)\n(\s+)/$1/g;
        $logger->fatal($@);
        croak $@;
    } else {
        $msg = "Mount of " . $h->{'config'}->{'mount'} . " complete.";
        $logger->info($msg);
    }


} #End of main()

eval {main()};
if ($@) {
	$ec = 1;
	#$@ =~ s/(\S+)\n(\s+)/$1/g;
	$@ =~ s/\n/ /g;
	$logger->fatal($@);
}
exit $ec;
__END__





