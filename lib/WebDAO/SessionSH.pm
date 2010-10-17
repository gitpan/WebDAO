package WebDAO::SessionSH;
#$Id: SessionSH.pm 848 2010-10-17 18:11:00Z zag $

=head1 NAME

WebDAO::SessionSH - Session class used from shell 

=head1 DESCRIPTION

WebDAO::SessionSH - Session class used from shell 

=cut

use strict;
use warnings;
use WebDAO::Base;
use WebDAO::Session;
use Data::Dumper;
use base qw( WebDAO::Session );

#Need to be forever called from over classes;
sub Init {
    my $self = shift;
    my %args = @_;
    #warn Dumper \%args;
    $self->SUPER::Init(@_);
    delete $args{store};
    delete $args{cv};
    $self->U_id( rand(100) );
    #setup default method 
    $ENV{REQUEST_METHOD} ||="GET";
    Params $self ( \%args );
}

sub print_header() {
    return ''
}

sub sess_servise {
    my $self= shift;
    return $self->SUPER::sess_servise(@_)

}

1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

