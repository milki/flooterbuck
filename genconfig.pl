#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
use Storable;

# Comment out the following line.
#die 'You must edit this file before use\n';

my $config_file = 'flooterbuck.sto';

my $config_hash = { 'server_alias' =>
		  {
              server => 'irc.server.com',
			  channels => [ '#channel1' ],
              # Optional settings for IRC server
              # https://metacpan.org/module/POE::Component::IRC#CONSTRUCTORS
              #port => 61697,
              #UseSSL => 1,
              ##Nick => 'flooterbuck',
              #NickPass => 'flooterbuck',
              #Ircname => 'flooterbuck',
              #Username => 'flooterbuck',
		  },
		};

store($config_hash, $config_file);
my $hash = retrieve($config_file);
print Dumper( $hash );
exit 0;
