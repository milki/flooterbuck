#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

use Flooterbuck;
use Storable;

my $pidfile = 'flooterbuck.pid';
my $config = 'flooterbuck.sto';

open(PIDFILE, ">$pidfile") or die "Could not open PID file: $!\n";
print PIDFILE "$$\n";
close(PIDFILE);

my $config_hash = retrieve($config);

print 'Config:';
print Dumper( $config_hash );

Flooterbuck->spawn( config => $config_hash );
exit 0;
