package WebDAO::Lex;

#$Id$

=head1 NAME

WebDAO::Lex - Lexer class

=head1 DESCRIPTION

WebDAO::Lex - Lexer class

=cut

use XML::LibXML;
use Data::Dumper;
use WebDAO::Lexer::Lobject;
use WebDAO::Lexer::Lbase;
use WebDAO::Lexer::Lregclass;
use WebDAO::Lexer::Lobjectref;
use WebDAO::Lexer::Ltext;
use WebDAO::Lexer::Linclude;
use WebDAO::Lexer::Lmethod;
use WebDAO::Base;
use base qw( WebDAO::Base );
__PACKAGE__->attributes qw/ tree auto /;
__PACKAGE__->mk_attr( __tmpl__ => '' );

use strict;

sub _init() {
    my $self = shift;
    return $self->Init(@_);
}

sub Init {
    my $self = shift;
    my %par  = @_;
    $self->auto( [] );
    $self->tree( $self->buld_tree( $par{content} ) ) if $par{content};

    #    $self->__tmpl__($par{tmpl}) if $par{tmpl};
    $self->__tmpl__( $self->_parsed_template_( $par{tmpl} ) ) if $par{tmpl};
    return 1;
}

=head2 split_template

Return [ $pre_part, $main_html, $post_part ]

=cut

sub split_template {
    my $self = shift;
    my @txt = split( m%<!--\s*<(\/?wd:(?:pre_|post_)?fetch)>\s*-->%x, shift );
    my ( $pre, $fetch, $post ) = \( '', '', '' );
    my $default = $fetch;
    foreach my $l (@txt) {

        if ( $l eq 'wd:pre_fetch' ) {
            $default = $pre;
            $$fetch  = '';
        }
        elsif ( $l eq '/wd:pre_fetch' ) {
            $default = $fetch;
        }
        elsif ( $l eq 'wd:fetch' ) {

            #store previaus aggreagated text as
            # pre
            $$pre    = $$default;
            $default = $fetch;
            $$fetch  = '';
        }
        elsif ( $l eq '/wd:fetch' ) {
            $default = $post;
        }
        elsif ( $l eq 'wd:post_fetch' ) {
            $default = $post;
        }
        elsif ( $l eq '/wd:post_fetch' ) {
            last;
        }
        else {

            $$default .= $l;
        }
    }

    #clean
    for ( $pre, $fetch, $post ) {
        $_ = '' if $$_ =~ m/^[\r\n\s]*$/i;
    }
    return [ $pre, $fetch, $post ];
    return \@txt;
}

sub _parsed_template_ {
    my $self = shift;
    my @res;
    foreach ( @{ $self->split_template( shift || $self->__tmpl__ ) } ) {
        my $res = ref($_) ? $self->buld_tree($$_) : [];
        push @res, $res;
    }
    return \@res;
}

sub buld_tree {
    my $self     = shift;
    my $raw_html = shift;

    #Mac and DOS line endings
    $raw_html =~ s/\r\n?/\n/g;
    my $mass;
    $mass = [ split( /(<WD>.*?<\/WD>)/is, $raw_html ) ];
    my @res;
    foreach my $text (@$mass) {
        my @ref;
        unless ( $text =~ /^<wd/i ) {
            push @ref,
              WebDAO::Lexer::Lobject->new(
                class   => "_rawhtml_element",
                id      => "none",
                childs  => [ WebDAO::Lexer::Ltext->new( value => \$text ) ],
                context => $self
              ) unless $text =~ /^\s*$/;
        }
        else {
            my $parser = new XML::LibXML;
            my $dom    = $parser->parse_string($text);
            push @ref, $self->get_obj_tree( $dom->documentElement->childNodes );

        }
        next unless @ref;
        push @res, @ref;
    }
    return \@res;
}

sub get_obj_tree {
    my $self = shift;
    my %map  = (
        object    => 'WebDAO::Lexer::Lobject',
        regclass  => 'WebDAO::Lexer::Lregclass',
        objectref => 'WebDAO::Lexer::Lobjectref',
        text      => 'WebDAO::Lexer::Ltext',
        include   => 'WebDAO::Lexer::Linclude',
        default   => 'WebDAO::Lexer::Lbase',
        method    => 'WebDAO::Lexer::Lmethod'
    );
    my @result;
    foreach my $node (@_) {
        my $node_name = $node->nodeName;
        my %attr =
          map { $_->nodeName => $_->value }
          grep { defined $_ } $node->attributes;
        my $map_key = $node->nodeName || 'text';
        $map_key = $map_key =~ /text$/ ? "text" : $map_key;
        $attr{name} = $map_key unless exists $attr{name};
        if ( $map_key eq 'text' ) { $attr{value} = $node->nodeValue }
        my $lclass = $map{$map_key} || $map{default};
        my @vals = ();

        if ( my @childs = $node->childNodes ) {
            @vals = grep { defined $_ } $self->get_obj_tree(@childs);
        }
        my $lobject = $lclass->new( %attr, childs => \@vals, context => $self )
          || next;
        if ( my @res = grep { ref($_) } ( $lobject->get_self ) ) {
            push @result, @res;
        }
    }
    return @result;
}

sub _destroy {
    my $self = shift;
    $self->auto( [] );
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

