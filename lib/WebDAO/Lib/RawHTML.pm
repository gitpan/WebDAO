package WebDAO::Lib::RawHTML;
#$Id: RawHTML.pm 464 2009-02-22 16:07:56Z zag $

=head1 NAME

WebDAO::Lib::RawHTML - Component for raw html

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Lib::RawHTML - Component for raw html

=cut

use WebDAO::Base;
use base qw(WebDAO::Component);
attributes (_raw_html);
sub init {
    my ($self,$ref_raw_html)=@_;
   _raw_html $self $ref_raw_html;
}
sub fetch {
  my $self=shift;
  return ${$self->_raw_html};
}

1;
__DATA__

=head1 SEE ALSO

http://sourceforge.net/projects/webdao

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut