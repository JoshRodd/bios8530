#!/usr/bin/env perl -w
#
# Author: Egan Ford (datajerk@gmail.com)
#
# Installation:
#   OS/X, Linux, other UNIX: (tested)
#     chmod 750 submit.pl, and put in your path
#
#   Windows: (untested)
#     Install ActiveState Perl and keep the .pl extension
#
# Usage: submit.pl emailaddr binary
#
# Example:
#
# $ submit.pl datajerk@gmail.com hello.bin
#
# The XT Server has received your file.
# Your program is starting
# Upload complete.
# OK
#
# hello, world
#
# Program ended normally.
# This concludes your XT server session.
#

use strict;
use LWP::UserAgent;

my $server = 'http://reenigne.mooo.com:8088';

my $file = shift;
my $email = 'josh@rodd.us';
my $browser = LWP::UserAgent->new;
print "Submitting...\n";
my $response = $browser->post(
	"$server/cgi-bin/xtserver.exe",
	[
		'email' => $email,
		'binary' => ["$file"],
	],
	'Content_Type' => 'form-data',
);

die "Error ",$response->status_line
	unless $response->is_success;

my $text = $response->content;
$text =~ s/^.*<pre>//sm;
$text =~ s/<\/pre>.*$//sm;

print "$text";

open my $fh, '<', \$text or die $!;
while (<$fh>) {
    chomp;
    if ( s/^<img src="\.\.\/([^"]*)"\/>/$1/ ) {
        my $cmd = "cd png; export fn=$_; curl -O $server/\$fn && open \$fn";
        print "$cmd\n";
        system "$cmd";
    }
}

exit;
