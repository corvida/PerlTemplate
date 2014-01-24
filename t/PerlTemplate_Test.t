use Test::More;
use bleak::PerlTemplate;
use Scalar::Util qw(looks_like_number);

## Expected ref struct
#$VAR1 = bless( { 
#                 'verbose' => 99,
#                 'debug' => 2
#               }, 'PerlTemplate' );

T1: {
    note("############################");
    note("##### Starting T1 Test #####");
    note("#   returned object ref    #");
    note("############################");
    my $t1vars = {};
    my $t1 = new PerlTemplate($t1vars);
    ok( defined($t1), "new() returned object ref");
    is( ref($t1), "PerlTemplate", "ref is indeed a PerlTemplate object");
    is( $t1->debug(), "0", "debug returns correct default value");
    is( $t1->verbose(), "0", "verbose returns correct default value");
}

T2: {
    note("############################");
    note("##### Starting T2 Test #####");
    note("#   correct debug return   ##");
    note("############################");
    my $t2vars = {
        'debug' => 1
    };
    my $t2 = new PerlTemplate($t2vars);
    ok( defined($t2), "new() returned object ref");
    is( ref($t2), "PerlTemplate", "ref is indeed a PerlTemplate object");
    is( $t2->debug(), "1", "debug returns correct value of 1");
    is( $t2->verbose(), "0", "verbose returns correct default value");
}

T3: {
    note("############################");
    note("##### Starting T3 Test #####");
    note("# correct verbose return  ##");
    note("############################");
    my $t3vars = {
        'verbose' => 1
    };
    my $t3 = new PerlTemplate($t3vars);
    ok( defined($t3), "new() returned object ref");
    is( ref($t3), "PerlTemplate", "ref is indeed a PerlTemplate object");
    is( $t3->debug(), "0", "debug returns correct default value");
    is( $t3->verbose(), "1", "verbose returns correct value of 1");
}

T4: {
    note("############################");
    note("##### Starting T4 Test #####");
    note("#   correct verbose return   ##");
    note("############################");
    my $t4vars = {
        'debug' =>'x' 
    };
    eval {
        my $t4 = new PerlTemplate($t4vars);
    };
    ok( defined($@), "exception thrown and caught.");
    like( $@, qr/^invalid input/, "debug returns invalid input");
}

done_testing;
