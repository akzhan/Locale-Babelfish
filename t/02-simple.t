use utf8;
use strict;
use warnings;

use Test::Deep;
use Test::More;

use FindBin qw($Bin);

use Test::Builder ();

binmode $_, ':encoding(UTF-8)' for map { Test::Builder->new->$_ } qw(output failure_output);

use Locale::Babelfish::Simple qw( single_template t_or_undef );

is(
    t_or_undef( single_template('I have #{test} ((nail|nails)):test'), { test => 2 }, 'ru' ),
    'I have 2 nails',
    'check',
);

done_testing;
