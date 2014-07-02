use strict;
use warnings;
use utf8;

use Test::More tests => 48;
use Interchange6::Lexicon::Import;
use Interchange6::Lexicon::Import::LocaleTab;
use Interchange6::Lexicon::Locale;
use Locale::PO;
use Data::Dumper;
use File::Spec;
use File::Temp;



my $standard_file = File::Spec->catfile('t', 'files', 'standard-locale.txt');

my $tmpdir = File::Temp->newdir(CLEANUP => 1);

my $ltab = Interchange6::Lexicon::Import::LocaleTab->new(
    filename => $standard_file,
    encoding => 'utf-8',
);

my @output = $ltab->read_locales;

ok(scalar(@output) == 6, "Number of locales");

foreach my $l (@output) {
    is $ltab->count, 512, "512 records";
    is $ltab->count_new, 512, "all new" or exit;
    is $ltab->count_updated, 0, "no updates, it's a fresh import";
}



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

my $basedir = $tmpdir->dirname;
foreach my $lang (@output) {
    my $filename = File::Spec->catfile($basedir, $lang . '.po');
    Locale::PO->save_file_fromhash($filename, $ltab->locales->{$lang}->records,
                                   'utf-8');
    ok(-f $filename, "$filename written");
}

# now, relaod from there

my $lexicon = Interchange6::Lexicon::Import->new(lexicon_directory => $basedir);

$lexicon->read_locales;

my $ic5 = Interchange6::Lexicon::Import::LocaleTab->new({
    filename => $standard_file,
    encoding => 'utf-8',
    locales => $lexicon->locales,
});

my @langs = $ic5->read_locales;

foreach my $l (@langs) {
    is $ic5->count, 512, "512 records";
    is $ic5->count_new, 0, "no new strings";
    is $ic5->count_updated, 0, "no updates, there was no change";
}
