#!/usr/bin/perl
use strict;
use warnings;

# this is a weechat port of https://github.com/acidvegas/irssi/blob/master/.irssi/scripts/autorun/takeover.pl
# TODO: Combine modes into one line

use utf8;
binmode STDOUT, ":utf8";

my $script_name = "takeover";
my $author      = "www";
my $version     = "0.1";
my $license     = "WTFPL";
my $description = "this script allows you to take over a channel easily, once you have ops";
if (weechat::register($script_name, $author, $version, $license, $description, "", "")) {
    weechat::hook_command("takeover", '/takeover [message]', "", '', '', "takeover", "");
}

sub takeover {
    my (undef, $buffer, $data) = @_;
    my $list = weechat::infolist_get("irc_nick",'',
        weechat::buffer_get_string($buffer, "localvar_server").",".
        weechat::buffer_get_string($buffer, "localvar_channel"));
    return unless $list;

    my (@qop, @aop);
    my $myhost;
    my $mynick = weechat::buffer_get_string($buffer, "localvar_nick");
    while (weechat::infolist_next($list)) {
        my ($nick, $prefixes) = (weechat::infolist_string($list, 'name'), weechat::infolist_string($list, "prefixes"));
        if ($nick eq $mynick) { $myhost = weechat::infolist_string($list, 'host'); next }

        push @qop, $nick if $prefixes =~ /~/;
        push @aop, $nick if $prefixes =~ /&/;
    }
    weechat::infolist_free($list);

    weechat::command("", "/mode -"."q" x @qop." @qop") if @qop;
    weechat::command("", "/mode -"."a" x @aop." @aop") if @aop;
    weechat::command("", "/deop -yes *");
    weechat::command("", "/dehalfop -yes *");
    weechat::command("", "/devoice -yes *");
    weechat::command("", "/ban *!*@*");
    weechat::command("", "/kloeri kickban -* * $data");
    weechat::command("", "/mode +imbeI *!*@* *!$myhost *!$myhost");
    weechat::command("", "/topic $data") if $data;

    return weechat::WEECHAT_RC_OK;
}
