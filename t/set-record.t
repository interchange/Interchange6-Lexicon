use strict;
use warnings;
use utf8;

use Test::More tests => 6;
use Interchange6::Lexicon::Import::LocaleTab;
use Interchange6::Lexicon::Locale;
use Locale::PO;
use Data::Dumper;
use File::Spec;



my $standard_file = File::Spec->catfile('t', 'files', 'standard-locale.txt');

my $ltab = Interchange6::Lexicon::Import::LocaleTab->new(
    filename => $standard_file,
    encoding => 'utf-8',
);

my @output = $ltab->read_locales;

ok(scalar(@output) == 6, "Number of locales");

my $locale = $ltab->locales->{de_DE};

ok($locale);

ok($locale->isa('Interchange6::Lexicon::Locale'));

my $record_new = Locale::PO->new;

$record_new->msgid('XXXXXXXXXX');
$record_new->msgstr('This is a test');

is($locale->set_record($record_new), 1, "New record returns 1");

$record_new = Locale::PO->new;

$record_new->msgid('XXXXXXXXXX');
$record_new->msgstr('This is a test');

is($locale->set_record($record_new), 0, "No changes: return 0 ");

my $record_updated = Locale::PO->new;
$record_updated->msgid('XXXXXXXXXX');
$record_updated->msgstr('This is a test XXXXX');

is($locale->set_record($record_updated), 2, "Record updated returns 2");

