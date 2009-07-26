package Test;
#$Id: Test.pm 584 2009-07-26 12:59:25Z zag $

=head1 NAME

Base Class for tests

=head1 SYNOPSIS

    use WebDAO::Test;
    my $eng = t_get_engine( 'contrib/www/index.xhtm');
    my $tlib = t_get_tlib($eng);

=head1 DESCRIPTION

Class for tests

=cut

use Test::Class;
use WebDAO::Test;
use base Test::Class;

1;

