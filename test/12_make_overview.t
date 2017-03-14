#!/usr/bin/env perl
use 5.012;
use warnings;
use Test::More;

my $tests = 0;
# Does 'make' work as we would expect?

sub execute {
    my $arg = shift;
    say "\$ $arg";
    say `timeout -sKILL 1m $arg 2>&1`;
    ok($? == 0, "$arg - process exited with code: $?");
    $tests += 1;
    return;
}

execute('echo "TestRevy\n2016\n" | make ../make_manus');
chdir('../make_manus');

execute('make aktoversigt.plan');
execute('make www/json.js');
execute('../RevyTeX/tools/overview.pl www/json.js > overview.md');

ok(-f 'overview.md', 'overview file exists');
$tests += 1;

my $expected = <<EOF;
# Sange

## Titel (Kunstner - Originaltitel)
* Filnavn: sange/skabelon.tex
* Forfattere: Forfatter
* Status: Ikke faerdig
* Version: 0.1

# Sketches

## Her skal sketchens titel stå
* Filnavn: sketches/skabelon.tex
* Forfattere: en forfatter
* Status: Ikke færdig
* Version: 0.1

# Video

## Her skal sketchens titel stå
* Filnavn: video/skabelon.tex
* Forfattere: en forfatter
* Status: Ikke færdig
* Version: 0.1

EOF

open(my $f, '<', 'overview.md');
my $actual = do { local $/; <$f> };
close($f);

is($actual, $expected, 'content of overview file is as expected');
$tests += 1;

chdir('../RevyTeX');
execute('rm -rf ../make_manus');

done_testing($tests);
