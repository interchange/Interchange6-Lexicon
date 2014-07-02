package Interchange6::Lexicon::Import::LocaleTab;

use strict;
use warnings;

use Moo;
use MooX::Types::MooseLike::Base qw/HashRef/;
use Sub::Quote;

use Encode;
use Text::RecordParser;
use Locale::PO;

use Interchange6::Lexicon::Locale;

# use Data::Dumper;

# keep it in sync with Interchange6::Lexicon::Locale;
use constant {
    SET_RECORD_NOCHANGE => 0,
    SET_RECORD_NEW => 1,
    SET_RECORD_CHANGED => 2,
};


=head1 NAME

Interchange6::Lexicon::Import::LocaleTab - Import locales from TAB separated file for Interchange6

=head1 ATTRIBUTES

=head2 filename

Filename of the TAB separated file.

=cut

has filename => (
    is => 'rw',
);

=head2 locales

Hash reference with locales. The hash values are
L<Interchange6::Lexicon::Locale> objects.

=cut

has locales => (
    is => 'rw',
    isa => HashRef,
    default => sub { {} },
);

=head2 encoding

Encoding of the TAB separated file, defaults to C<UTF-8>.

=cut

has encoding => (
    is => 'rw',
    lazy => 1,
    default => quote_sub q{return 'UTF-8';},
);

has _counter_hash => (is => 'rw');

has canonical_language => (is => 'ro',
                           default => sub { 'en_US' });

=head2 read_locales

Reads locales from TAB separated file.

=cut

sub read_locales {
    my ($self) = @_;

    my $trp = $self->_record_parser;

    $trp->trim(1);

    $trp->bind_header;

    my @langs = $trp->field_list;

    my $first = shift @langs;

    unless ($first eq 'code') {
        die "First column in tab separated file is named '$first' instead of 'code'";
    }

    # setup object for the languages
    for my $lang (@langs) {
        # check if language exist
        next if exists $self->locales->{$lang};

        $self->locales->{$lang} = Interchange6::Lexicon::Locale->new(
            locale => $lang);
    }

    # loop over records
    my ($record, %entries, $po);

    my $count_struct = {};
    my $counter = {};
    while ($record = $trp->fetchrow_hashref) {
        for my $lang (@langs) {
            $po = Locale::PO->new;
            $po->msgid($self->_encode_filter($record->{code}));
            $po->msgstr($self->_encode_filter($record->{$lang}));
            my $ex = $self->locales->{$lang}->set_record($po);
            $counter->{$lang}->{$ex}++;
        }
    };
    $self->_counter_hash($counter);
    return @langs;
};

sub _get_record_count {
    my ($self, $lang) = @_;
    $lang ||= $self->canonical_language;
    my $hashref = $self->_counter_hash->{$lang} || die "$lang was not imported!";
    return $hashref;
}

=head2 count($lang)

Return the total number of imported strings for the given language,
defaulting to C<canonical_language>

=head2 count_new($lang)

Return the total number of new imported strings for the given language,
defaulting to C<canonical_language>

=head2 count_updated($lang)

Return the total number of updated strings for the given language,
defaulting to C<canonical_language>

=cut

sub count {
    my ($self, $lang) = @_;
    my $hash = $self->_get_record_count($lang);
    my $total = 0;
    foreach my $v (values %$hash) {
        $total += $v;
    }
    return $total;
};

sub count_new {
    my ($self, $lang) = @_;
    my $hash = $self->_get_record_count($lang);
    my $i = SET_RECORD_NEW;
    return $hash->{$i} || 0;
};

sub count_updated {
    my ($self, $lang) = @_;
    my $hash = $self->_get_record_count($lang);
    my $i = SET_RECORD_CHANGED;
    return $hash->{$i} || 0;
};

sub _encode_filter {
    my ($self, $text) = @_;
    return decode($self->encoding, $text);
}

sub _record_parser {
    my ($self) = @_;

    return Text::RecordParser->new({
        filename => $self->filename,
        field_separator => "\t",
    });
}

1;
