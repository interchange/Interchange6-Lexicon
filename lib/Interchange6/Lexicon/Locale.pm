package Interchange6::Lexicon::Locale;

use strict;
use warnings;

use Moo;
use Sub::Quote;
use Locale::PO;

=head1 NAME

Interchange6::Lexicon::Locale - Locale object

=head1 ATTRIBUTES

=head2 locale

Locale, e.g. C<de_DE>.

=cut

has locale => (
    is => 'ro',
    required => 1,
);

=head2 records

Locale records.

=cut

has records => (
    is => 'ro',
);

=head2 po_encoding

Encoding of the *.po files, defaults to C<UTF-8>.

=cut

has po_encoding => (
    is => 'rw',
    lazy => 1,
    default => quote_sub q{return 'UTF-8';},
);

=head1 METHODS

=head2 read_from_file($filename)

Read locale from file.

=cut

sub read_from_file {
    my ($self, $filename) = @_;
    my ($href);

    $href = Locale::PO->load_file_ashash($filename, $self->po_encoding);
    $self->{records} = $href;
}

=head2 set_record($po)

Set PO record. Parameter is C<Locale::PO> object.

=cut

sub set_record {
    my ($self, $po) = @_;
    my $key = $po->msgid;

    if (exists $self->{records}->{$key}) {
        warn "Key exists: $key\n";
    }
    
    $self->{records}->{$key} = $po;
}

1;
