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

    while ($record = $trp->fetchrow_hashref) {
        for my $lang (@langs) {
            $po = Locale::PO->new;
            $po->msgid($self->_encode_filter($record->{code}));
            $po->msgstr($self->_encode_filter($record->{$lang}));
            $self->locales->{$lang}->set_record($po);
        }
    };

    return @langs;
};

sub _encode_filter {
    my ($self, $text) = @_;

    return $text;
    return encode('utf-8', decode($self->encoding, $text));
}

sub _record_parser {
    my ($self) = @_;

    return Text::RecordParser->new({
        filename => $self->filename,
        field_separator => "\t",
    });
}

1;
