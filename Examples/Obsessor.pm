require 5.005_62; use strict; use warnings;

our $VERSION = '0.02';

{
	package Obsessor::Event;

	Class::Maker::class
	{
		public =>
		{
			string => [qw( object method )],

			array => [qw( arguments )],
		},
	};

	sub to_text : method
	{
		my $this = shift;

			printf $Class::Maker::TRACE "visiting %s->%s\n", ref( $this->object ) || $this->object, $this->method;
	}
}

package Obsessor;

Class::Maker::class
{
	public =>
	{
		array => [qw( bouncers )],
	},

	private =>
	{
		ref => { target => 'UNIVERSAL', event => 'Obsessor::Event' },
	},
};

use vars qw($AUTOLOAD);

sub _preinit
{
	my $this = shift;

		$this->_target( undef );

		$this->_event( Obsessor::Event->new() )
}

sub _postinit
{
	my $this = shift;

		$this->target( $this->_target ) if $this->_target;
}

sub target : method
{
	my $this = shift;

	my $destination = shift or die 'new() needs a blessed object or classname as first argument';

			# Binding to class or object...

		$this->_target( ref($destination) ? $destination : $destination->new( @_ ) );

		$this->_event->object( $this->_target );

		printf $Class::Maker::TRACE "\ntaking over '%s'\n", $this->_target;

return $this->_target;
}

	# Future: Class::Maker::Examples::Obsessor should more obscure himself
	#
	#	"goto &func" would be the best solution.
	#
	#	#my $fullfunc = \&{ "${destpack}::$func" };
	#	#goto &$fullfunc if $target->can( $func ) or die "unhandled method $target->$func via Obsessor";

sub AUTOLOAD : method
{
	my $this = shift || return undef;

	my @args = @_;

		my $func = $AUTOLOAD;

		$func =~ s/.*:://;

		return if $func eq 'DESTROY';

		no strict 'refs';

		@_ = ( $this->_target, @args );

		#die "unhandled method $target->$func" unless $target->can( $func );

		$this->_event->arguments( [ @_ ] );

		$this->_event->method( $func );

		foreach my $bouncer ( @{ $this->bouncers } )
		{
			unless( $bouncer->inspect( $this->_event ) )
			{
				die sprintf( "Bouncer $bouncer intercepted at $this->_event for '%s'", $this->_event->method );
			}
		}

		$this->_event->to_text();

return wantarray ? @{ [ $this->_target->$func( @_ ) ] } : $this->_target->$func( @_ );
}

1;

__END__

=head1 NAME

Obsessor - methodcall dispatcher/forwarder

=head1 SYNOPSIS

  use Class::Maker::Examples::Obsessor;

  use Verify;

  use Class::Maker::Examples::User;

		# binding to a class (a clean object is created)
	{
		my $user = Obsessor->new( target => 'User' );

		$user->email( 'murat.uenalan@gmx.de' );

		$user->firstname( 'Murat' );

		$user->lastname( 'Murat' );

		#$user->blabla();

		print Dumper $user;
	}

		# binding to existing object
	{
		my $user = Obsessor->new( target => new User( firstname => 'Murat', lastname => 'Uenalan' ) );

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
		my $accesstester = new Bouncer( );

		push @{ $accesstester->tests }, new Bouncer::Test( field => 'method', type => 'positivliste' );

		my $user = Obsessor->new();

			# CAVE: target is an Class::Maker::Examples::Obsessor method (the only one)

		$user->Obsessor::target( new User( firstname => 'Murat', lastname => 'Uenalan' ) );

		push @{ $user->bouncers }, $accesstester;

			# bouncer won't reject email, firstname or lastname, because they're in the pass-list

		$user->email( 'muenalan@cpan.org' );

		$user->firstname( 'Murat' );

		$user->lastname( 'Murat' );

			# bouncer rejects 'blabla' because it's in fail-list

		$user->blabla();

		print Dumper $user;
	}

=head1 DESCRIPTION

Class::Maker::Examples::Obsessor has nothing to do with a http-server. But, in the very principle
it behaves like it. It serves a target class/object and has all might about it.
This can be used i.e. to restrict/log/bench/forward/obscure/cache/.. the access
to the target.
After you plug a target to an Class::Maker::Examples::Obsessor, the resulting object behaves like
the original target in terms of methodcalls. But a ref()-call would reveal the object
beeing an Class::Maker::Examples::Obsessor in real. Also caller() would be influenced (unfortunately).

=head2 EXPORT

None by default.

=head2 EXAMPLE "Access restriction"

=head1 AUTHOR

Murat Ünalan, <muenalan@cpan.org>

=head1 SEE ALSO

perl(1).

=cut
