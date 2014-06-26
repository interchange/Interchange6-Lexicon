use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Interchange6::Lexicon',
    AUTHOR              => q{Stefan Hornburg (Racke) <racke@linuxia.de>},
    VERSION_FROM        => 'lib/Interchange6/Lexicon/Import.pm',
    ABSTRACT            => 'Interchange6 Open Source Shop Machine',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Test::Warnings' => 0,
    },
    PREREQ_PM => {
        'Moo' => 0,
        'MooX::Types::MooseLike' => 0,
        'Locale::PO' => 0,
        'Sub::Quote' => 0,
        'Text::RecordParser' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Interchange6-Lexicon*' },
    META_MERGE        => {
        resources => {
            repository  => 'https://github.com/interchange/Interchange6-Lexicon.git',
            bugtracker => 'https://github.com/interchange/Interchange6-Lexicon/issues'
        },
    },
);
