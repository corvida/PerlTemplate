use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'              => 'bleak::PerlTemplate',
	'VERSION_FROM'      => 'lib/SAL/Array3PAR.pm',
	'PREREQ_PM'			=> { systools => 1.0.0 },
	'EXE_FILES'			=> [ qw(bin/sal-array3par.pl)]
);

