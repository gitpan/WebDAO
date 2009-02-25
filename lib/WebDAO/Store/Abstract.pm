package WebDAO::Store::Abstract;

#$Id: Abstract.pm 464 2009-02-22 16:07:56Z zag $

=head1 NAME

WebDAO::Store::Abstract - Abstract session store

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Store::Abstract - Abstract session store

=cut


use WebDAO::Base;
use Data::Dumper;
use strict;
@WebDAO::Store::Abstract::ISA = ('WebDAO::Base');
sub _init {
    my $self = shift;
    return $self->init(@_);
}
sub init {
    return 1
}
sub load { {} }
sub store { {} }
sub _load_attributes {
    my $self = shift;
    return {}
}
sub _store_attributes {
    my $self = shift;
    return {}
}
sub flush { #$_[0]->_log1("flush")
}

1;
