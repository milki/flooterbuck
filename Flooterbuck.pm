package Flooterbuck;

use strict;
use warnings;

use POE qw(Wheel::Run Filter::Line);
use POE::Component::IRC::State;
use POE::Component::IRC::Common qw(:ALL);
use POE::Component::IRC::Plugin qw(:ALL);
use POE::Component::IRC::Plugin::AutoJoin;
use POE::Component::IRC::Plugin::Connector;
use POE::Component::IRC::Plugin::NickServID;
use POE::Session;

our $VERSION = '0.1';

sub spawn {
    my $package = shift;
    my $self = bless { @_ }, $package;

    my $settings = delete $self->{config}->{settings};
    die "No settings\n" unless $settings or ref($settings) ne 'HASH';

    $self->{initial} = __PACKAGE__ . "-" . $VERSION;

    my $network_settings;
    foreach my $network (keys %{$self->{config}}) {
        $network_settings = $self->{config}->{$network};
        $self->{irc}->{$network} = POE::Component::IRC::State->spawn(
            alias => $network,
            %$network_settings);
    }

    POE::Session->create(
        object_states => [
            $self => [ qw(_start irc_plugin_add
                          irc_001
                          irc_join
                          )],
        ],
    );

    $poe_kernel->run();
}

sub _start {
    my $self = $_[OBJECT];

    foreach my $network (keys %{$self->{irc}}) {
        my $irc = $self->{irc}->{$network};
        $irc->yield(register => 'all');
        $irc->plugin_add('Connector', POE::Component::IRC::Plugin::Connector->new());
        $irc->plugin_add('AutoJoin', POE::Component::IRC::Plugin::AutoJoin->new( Channels => $self->{config}->{$network}->{channels}  ));

        if( $self->{config}->{$network}->{NickPass} ) {
            $irc->plugin_add( 'NickServID', POE::Component::IRC::Plugin::NickServID->new( Password => $self->{config}->{$network}->{NickPass} ));
        }

        $irc->yield(connect => { } );
    }
    undef;
}

sub irc_plugin_add {
    my ($self, $name) = @_[OBJECT, ARG0];
    print STDOUT "Add plugin $name\n";
    undef;
}

sub irc_001 {
    my ($sender, $msg) = @_[SENDER, ARG1];
    my $irc = $sender->get_heap();
    print STDOUT "Connected ", $irc->server_name(), ": $msg\n";
    return PCI_EAT_NONE;
}

sub irc_join {
    my $sender = $_[SENDER];
    my $irc = $sender->get_heap();

    my $joiner = parse_user($_[ARG0]);
    my $chan   = $_[ARG1];


    if($joiner eq $irc->nick_name()) {
        print STDOUT $irc->server_name(), ": joined $chan\n";
    }

    return PCI_EAT_NONE;
}

1;
