use Test;

BEGIN { plan tests => 2 };

use Class::Maker;

use Class::Maker::Examples::Array;

ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

	my $a = Array->new( array => [1..100] );

	map { print "$_\n" } $a->pick( 2 );

	print '[ ', $a->join( ' ]=[ ' ), ' ]', "\n";

ok(2);
