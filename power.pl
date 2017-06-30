use utf8;
use strict;
use warnings;

my $SCRIPT_NAME = 'power';
my $SCRIPT_AUTHOR = 'www@spiderbyte.io';
my $SCRIPT_VERSION = '1.0';
my $SCRIPT_LICENCE = 'WTFPL';
my $SCRIPT_DESC = 'Gives your power based on access modes across all channels';

my %prefix;

if (weechat::register($SCRIPT_NAME, $SCRIPT_AUTHOR, $SCRIPT_VERSION, $SCRIPT_LICENCE, $SCRIPT_DESC, '', '')) {
    weechat::hook_command($SCRIPT_NAME, $SCRIPT_DESC, '-v', "Inserts power into your input line\n-v: Verbose output (gives individual count for each access mode)", '-v', 'cmd_main', '');
}

sub getpower {
    my $buffer = shift;
    my $count;

    my $iptr = weechat::infolist_get('nicklist', $buffer, '');
    return 0 unless $iptr;

    my $my_nick = weechat::info_get('irc_nick', weechat::buffer_get_string($buffer, 'localvar_server'));

    while (weechat::infolist_next($iptr)) {
        my $name = weechat::infolist_string($iptr, 'name');
        if ($name eq $my_nick) {
            my $my_prefix = weechat::infolist_string($iptr, 'prefix');
            return 0 unless $my_prefix =~ /[!~&@%]/;
            $prefix{o}++  if $my_prefix =~ /@/;
            $prefix{h}++  if $my_prefix =~ /%/;
            $prefix{a}++  if $my_prefix =~ /&/;
            $prefix{q}++  if $my_prefix =~ /[!~]/;
        } else {
            $count++;
        }
    }
    weechat::infolist_free($iptr);

    return $count;
}

sub cmd_main {
    my ($data, $buffer, $args) = @_;
    my $power;
    my $infolist = weechat::infolist_get("buffer", "", "");

    while (weechat::infolist_next($infolist)) {
        my $bpointer = weechat::infolist_pointer($infolist, "pointer");
        my $btype = weechat::buffer_get_string($bpointer, 'localvar_type');
        if ($btype eq 'channel') {
            $power += getpower($bpointer);
        }
    }
    weechat::infolist_free($infolist);
    my $output;

    # -v (verbose) was given, display the individual modes
    if ($args =~ /-v/) {
        $output = "I have the following access levels: (";
        for my $prefix (sort keys %prefix) {
            $output .= " $prefix:$prefix{$prefix}"; 
        }
        $output .= " ) and ";
    }

    $output .= "I have power over $power people";
    weechat::command("", "/input insert $output");
}
