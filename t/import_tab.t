# test imports from Interchange5 locale files

use strict;
use warnings;

use utf8;

use Test::More tests => 4;

use File::Spec;

use Interchange6::Lexicon::Import::LocaleTab;

binmode(STDOUT, ':encoding(utf-8)');
binmode(STDERR, ':encoding(utf-8)');

my $standard_file = File::Spec->catfile('t', 'files', 'standard-locale.txt');

my $ltab = Interchange6::Lexicon::Import::LocaleTab->new(
    filename => $standard_file,
    encoding => 'latin1',
);

my @output = $ltab->read_locales;

ok(scalar(@output) == 6, "Number of locales");

my $po_de = $ltab->locales->{de_DE}->records;

ok(scalar(keys %$po_de) == 512, "Number of PO records")
    || diag "PO records returned: ", scalar(keys %$po_de);

my ($msgid, $msgstr);

print "KEYS: ", join("\n", keys %$po_de), "\n";

$msgid = $po_de->{'"About Us"'}->msgid;
$msgstr = $po_de->{'"About Us"'}->msgstr;

warn "MSGID: $msgid\n";
warn "MSGSTR: $msgstr\n";

ok($msgid eq '"About Us"', "About Us msgid")
    || diag "Msgid: $msgid";

ok($msgstr eq '"Über uns"', "About Us msgstr")
    || diag "Msgstr: $msgstr";
