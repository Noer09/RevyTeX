#!/usr/bin/env perl
use 5.028;
use warnings;
use feature qw(signatures);
no warnings qw(experimental::signatures);

=head1 NAME

reheasal.pl

=head1 DESCRIPTION

Given a .tex-file, generate a .txt-file suitable for being imported into the Script Rehearser app. (https://scriptrehearser.com/)

=head1 SYNOPSIS

 path/to/rehearsal.pl <texfile>.tex > rehearsal-file.txt

=cut

my ($texfile) = @ARGV;
unless (-f $texfile) {
    die("Usage: $0 <texfile>.tex > rehearsal-file.txt");
}

open(my $f, '<', $texfile);
my $data = do { local $/ = undef; <> };
close($f);

my $segments = join("\n", $data =~ m/\\begin\{(?:sketch|song)\}(.*?)\\end\{(?:sketch|song)\}/gs);

# Remove comments
$segments =~ s/(?!<\\)%.*$//gm;

# Convert misc. TeX-isms
$segments =~ s{\\\\}{\n}gs;
$segments =~ s#\\l?dots#...#gs;
$segments =~ s#\\(?:emph|textit)\{([^}]*)\}#*$1*#gs;
$segments =~ s#``|''#"#gs;

# Convert RevyTeX-isms
$segments =~ s#\\act\{([^}]*)\}#($1)#gs;
$segments =~ s#\\scene\{([^}]*)\}#\n($1)\n#gs;
$segments =~ s#\\(?:says|sings)\{([^}]*)\}\s*#\n\n$1:\n#gs;

# Script Rehearser doesn't like [ ... ] as much, so convert them to ( ... )
$segments =~ s#\[([^]]*)\]#($1)#gs;

# Remove any unprocessed TeX commands.
$segments =~ s#\\[^{\s]*\{([^}]*)\}\s*#$1#gs;
$segments =~ s#\{\}##gs;

# Remove leading whitespace
$segments =~ s/^[ \t]+//gm;

# Trim blank lines
$segments =~ s/\n{3,}/\n\n/gs;

say $segments;
