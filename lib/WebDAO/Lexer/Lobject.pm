package WebDAO::Lexer::Lobject;
#$Id: Lobject.pm 464 2009-02-22 16:07:56Z zag $

=head1 NAME

WebDAO::Lexer::Lobject - Process object tag

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Lexer::Lobject - Process object tag

=cut

use WebDAO::Lexer::Lbase;
use Data::Dumper;
use base qw( WebDAO::Lexer::Lbase );
use strict;

sub value {
    my $self = shift;
    my $eng  = shift;
    my $par  = $self->all;
    my @val  = map { $_->value($eng) } @{ $self->childs };
    if ($eng) {
        my $error;

        #check if alias
        unless ( $eng->_pack4name( $par->{class} ) ) {

            #try class as perl modulename
            $error = $eng->register_class( $par->{class} );

        }
        if ($error) {
            _log1 $self "use module $par->{class}, id: $par->{id} fail. $error";
            return
        }
        else {
            my $object = $eng->_createObj( $par->{id}, $par->{class}, @val );
            _log1 $self "create_obj fail for class: "
              . $par->{class}
              . " ,id: "
              . $par->{id}
              unless $object;

            return $object;
        }
    }
    return {"Object ( "
          . ( join ",", map { "$_ => " . $par->{$_} } keys %{$par} )
          . ")" => \@val };
}
1;
