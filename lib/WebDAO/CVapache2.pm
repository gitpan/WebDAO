package WebDAO::CVapache2;
#$Id: CVapache2.pm 483 2009-02-25 19:31:33Z zag $

=head1 NAME

WebDAO::CVapache2 - Apache2 mod_perl controller

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::CVapache2 - Apache2 mod_perl controller

=cut

use WebDAO::Base;
use CGI;
use Data::Dumper;
use strict;
use warnings;

use base qw( WebDAO::Base );
#__PACKAGE__->
attributes qw ( _req _cgi );

my %met2sub =(
        url =>sub { return 'http://site.zag'},
#        path_info =>sub { $r->uri},
    );
sub _init {
    my $self = shift;
    my $r = shift || return;
    _req $self  $r;
    _cgi $self new CGI::;
    return 1;
}
#path_info param url header
sub path_info {
    my $self = shift;
    return $self->_req->uri
}
sub param {
    my $self = shift;
    return $self->_cgi->param(@_)
}
sub response {
    my $self = shift;
    my $res = shift || return;
#    $self->_log1(Dumper(\$res));
#    $self->_log1($r);
    my $r = $self->_req;
#    $self->_log1($r);
    while ( my ($key,$val) = each %{$res->{headers}}) {
        for ($key) {
            /-TYPE/ && do { 
                #$r->headers_out->add('Content-Type', 'text/html' );
#                $self->_log1("type".$val);
                $r->content_type($val) 
                }
                ||
            /-COOKIE/ && do { 
               $r->headers_out->add( 'Set-Cookie', $val->as_string )
            } ||
            /Last-Modified/i && do {
                $r->headers_out->add( $key, $val )
            }
        }
    }
#    $r->content_type($res->{type});
    if ($res->{file}) {
        $r->sendfile($res->{file})
    } else {
        print $res->{data};
    }
}
sub print {
    my $self = shift;
    print @_;
}

sub get_cookie {
    my $self = shift;
    return $self->_cgi->cookie(@_)
}

sub header {
    my $self = shift;
    return $self->_cgi->header(@_)
}
sub AUTOLOAD { 
    my $self = shift;
    return if $WebDAO::CVapache2::AUTOLOAD =~ /::DESTROY$/;
    ( my $auto_sub ) = $WebDAO::CVapache2::AUTOLOAD =~ /.*::(.*)/;
#    print STDERR  "$self do $auto_sub ";
    $self->_log2("sub $auto_sub not handle in ".__PACKAGE__."called from\n".Dumper([map {[caller($_)]} (1..6)])) unless my $sub = $met2sub{$auto_sub};
    return  $sub->(@_)
#    die "errrr"
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