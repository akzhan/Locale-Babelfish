package Locale::Babelfish::Simple;

# ABSTRACT: Babelfish parse/compile single tepmlate only.

use utf8;
use strict;
use warnings;

use Exporter qw( import );
use Locale::Babelfish::Phrase::Parser ();
use Locale::Babelfish::Phrase::Compiler ();

our @EXPORT_OK = qw( &single_template &t_or_undef );

my $parser   = Locale::Babelfish::Phrase::Parser->new();
my $compiler = Locale::Babelfish::Phrase::Compiler->new();

sub phrase_need_compilation {
    my ($phrase) = @_;
    die "L10N: $phrase is undef" unless defined $phrase;
    return
         1
      && ref($phrase) eq ''
      && $phrase =~ m/ (?: \(\( | \#\{ | \\\\ )/x;
}

sub single_template {
    my ( $sentence, $locale ) = @_;

    $sentence = $compiler->compile( $parser->parse( $sentence, $locale ) )
      if phrase_need_compilation($sentence);
}

=method t_or_undef

Get internationalized value for key from dictionary.

    t_or_undef( single_template );
    t_or_undef( single_template, { param1 => 1 , param2 => { next_level  => 'test' } } );
    t_or_undef( single_template, { param1 => 1 }, $specific_locale );
    t_or_undef( single_template, 1 );

=cut

sub t_or_undef {
    my ( $single_template, $params, $locale ) = @_;

    if ( defined $single_template ) {
        if ( ref($single_template) eq 'SCALAR' ) {
            $single_template =
              $compiler->compile( $parser->parse( $$single_template, $locale ), );
        }
    }

    if ( ref($single_template) eq 'CODE' ) {
        my $flat_params = {};

        # Convert parameters hash to flat form like "key.subkey"
        if ( defined($params) ) {

            # Scalar interpreted as { count => $scalar, value => $scalar }.
            if ( ref($params) eq '' ) {
                $flat_params = {
                    count => $params,
                    value => $params,
                };
            }
            else {
                _flat_hash_keys( $params, '', $flat_params );
            }
        }

        return $single_template->($flat_params);
    }
    return $single_template;
}

=for Pod::Coverage _flat_hash_keys

=cut

sub _flat_hash_keys {
    my ( $hash, $prefix, $store ) = @_;
    while ( my ($key, $value) = each(%$hash) ) {
        if (ref($value) eq 'HASH') {
            _flat_hash_keys( $value, "$prefix$key.", $store );
        } else {
            $store->{"$prefix$key"} = $value;
        }
    }
    return 1;
}
