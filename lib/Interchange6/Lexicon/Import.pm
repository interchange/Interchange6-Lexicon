package Interchange6::Lexicon::Import;

use strict;
use warnings;

use Moo;
use MooX::Types::MooseLike::Base qw/HashRef/;

use Locale::PO;
use Sub::Quote;
use File::Basename;

use Interchange6::Lexicon::Locale;

=head1 NAME

Interchange6::Lexicon::Import - Import locales for Interchange6

=head1 VERSION

0.001

=cut

our $VERSION = '0.001';

=head1 ATTRIBUTES

=head2 lexicon_directory

The directory where we store the *.pod files.

=cut

has lexicon_directory => (
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

=head2 po_encoding

Encoding of the *.po files, defaults to C<UTF-8>.

=cut

has po_encoding => (
    is => 'rw',
    lazy => 1,
    default => quote_sub q{return 'UTF-8';},
);

=head2 read_locales

Read locales from L</"lexicon_directory">.

=cut

sub read_locales {
    my ($self) = @_;

    my $base_dir = $self->lexicon_directory;

    my @po_files = glob("$base_dir/*.po");

    for my $po (@po_files) {
        my $po_name = fileparse($po, qr/\.[^.]*/);
        my $po_obj = Interchange6::Lexicon::Locale->new(
            locale => $po_name,
            po_encoding => $self->po_encoding,
        );
        $po_obj->read_from_file($po);
        $self->locales->{$po_name} = $po_obj;
    }
}

=head2 write_locales

Write locales into L</"lexicon_directory>.

=cut

sub write_locales {
    my ($self) = @_;

    my $base_dir = $self->lexicon_directory;

    while (my ($name, $aref) = each %{$self->locales}) {
        my $po = "$base_dir/$name.po";
        Locale::PO->save_file_fromarray($po, $aref, $self->po_encoding);
    }
}

1;
