#!/usr/bin/env starman

#===============================================================================
#
#  DESCRIPTION:  PSGI server for WebDAO 
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zag@cpan.org>
#===============================================================================

package main;
use strict;
use warnings;
use WebDAO::Util;
use WebDAO;
use WebDAO::CV;
use WebDAO::Lex;

my $handler = sub {
    my $env = shift;
    die "Only psgi.streaming=1 servers supported !"
     unless $env->{'psgi.streaming'};
    my $coderef = shift;
    $env->{wdEnginePar} = $ENV{wdEnginePar} || $env->{HTTP_WDENGINEPAR} ;
    $env->{wdEngine} = $ENV{wdEngine} || $env->{HTTP_WDENGINE} ;
    $env->{wdSession} = $ENV{wdSession} || $env->{HTTP_WDSESSION} || 'WebDAO::Session' ;
    my $ini = WebDAO::Util::get_classes(__env => $env, __preload=>1);
    my $store_obj = "$ini->{wdStore}"->new(
            %{ $ini->{wdStorePar} }
    );

    my $cv = WebDAO::CV->new(env=>$env, writer=>$coderef);

    my $sess = "$ini->{wdSession}"->new(
        %{ $ini->{wdSessionPar} },
        store => $store_obj,
        cv    => $cv,
    );

    #determine root document
    my $env_var = $env->{HTTP_WDINDEXFILE} || $ENV{wdIndexFile} || $ENV{WD_INDEXFILE};
    my %ini_pars = ();
    if ( $env_var && !-z $env_var ) {
        my ($filename) = grep { -r $_ && -f $_ } $env_var;
        die "$0 ERR:: file not found or can't access (WD_INDEXFILE): $env_var"
          unless $filename;

        open FH, "<$filename" or die $!;
        my $content ='';
        { local $/=undef;
        $content = <FH>;
        }
        close FH;
        my $lex = new WebDAO::Lex:: tmpl => $content;
        $ini_pars{lex} = $lex;
    }
    my $eng = "$ini->{wdEngine}"->new(
        %{ $ini->{wdEnginePar} },
        %ini_pars,
        session => $sess,
    );
    #set default header
    $sess->ExecEngine($eng);
#    use Data::Dumper;
#    $cv->{fd}->write('<pre>'.Dumper($env).'</pre>');
    #close psgi
    $cv->{fd}->close() if exists $cv->{fd};
    $sess->destroy;
};

my $app = sub {
    my $env = shift;
    sub { $handler->( $env, $_[0])}
};
$app;