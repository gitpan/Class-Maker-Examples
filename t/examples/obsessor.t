BEGIN
{
	$| = 1; print "1..1\n";
}

my $loaded;

use strict; use warnings;

use Carp;

END { print "not ok 1\n" unless $loaded; }

use Object::Server;

print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use class::examples::User;

use Data::Dumper;

use Object::Bouncer;

		# Early binding to a class (a clean object is created)
	{
		my $user = Class::Maker::Object::Server->new( client => 'User' );

		$user->email( 'murat.uenalan@gmx.de' );

		$user->firstname( 'Murat' );

		$user->lastname( 'Murat' );

		#$user->blabla();

		print Dumper $user;
	}

		# Late binding to existing object
	{
		my $user = Class::Maker::Object::Server->new( client => new User( firstname => 'Murat', lastname => 'Uenalan' ) );

		$user->email( 'murat.uenalan@gmx.de' );

		$user->firstname( 'Murat' );

		#$user->blabla();

		print Dumper $user;
	}

package Verify::Type;

		our $positivliste = new Verify::Type(

			desc => 'test access right',

			pass => { exists_in => { firstname => 1, lastname => 1, email => 1 } },

			fail => { exists_in => [qw(blabla)] }

		);

package main;

	{
		my $accesstester = new Object::Bouncer( );

		push @{ $accesstester->tests }, new Object::Bouncer::Test( field => 'method', type => 'positivliste' );

		my $user = Class::Maker::Object::Server->new();

			# CAVE: client is an Class::Maker::Object::Server method

		$user->Class::Maker::Object::Server::client( new User( firstname => 'Murat', lastname => 'Uenalan' ) );

		push @{ $user->bouncers }, $accesstester;

			# bouncer won't reject email, firstname or lastname, because they're in the pass-list

		$user->email( 'murat.uenalan@gmx.de' );

		$user->firstname( 'Murat' );

		$user->lastname( 'Murat' );

			# bouncer rejects 'blabla' because it's in fail-list

		$user->blabla();

		print Dumper $user;
	}

	eval
	{
		1;
	};
	if($@)
	{
    	warn "Exception: $@\n";

    	print "\nnot ";
	}

printf "ok %d\n", ++$loaded;
