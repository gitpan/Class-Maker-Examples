package Array;

our $VERSION = '0.01_01';

Class::Maker::class
{
	public =>
	{
		getset => [qw( max )],
	},

	private =>
	{
		array => [qw( array )],
	},
};

sub _preinit
{
	my $this = shift;

	my $args = shift;

		# Manipulate args list, because otherwise teh Class::Maker constructor would forward args
		# for inhertance

	$this->_array( $args->{array} );

	delete $args->{array};
}

sub push : method
{
	my $this = shift;

	push @{ $this->_array }, @_;
}

sub pop : method
{
	pop @{ shift->_array };
}

sub shift : method
{
	my $this = shift;

return shift @{ $this->_array };
}

sub unshift : method
{
	my $this = shift;

return unshift @{ $this->_array }, @_;
}

sub count : method
{
	scalar @{ shift->_array };
}

sub reset : method
{
	@{ shift->_array } = ();
}

sub get : method
{
	@{ shift->_array };
}

sub pick : method
{
	my $this = shift;

		my $step = shift || 2;

		my @result;

		my $cnt;

		map { push @result, $_ unless $cnt++ % $step } @{ $this->_array };

return Array->new( array => \@result );
}

sub join : method
{
	my $this = shift;

return join( shift, @{ $this->_array } );
}

sub union : method
{
	my $this = shift;

		my $other = shift;

return Array->new( array => @{ _calc( $this->_array, $other ) }[0] );
}

sub intersection : method
{
	my $this = shift;

		my $other = shift;

return Array->new( array => @{ _calc( $this->_array, $other ) }[1] );
}

sub difference : method
{
	my $this = shift;

		my $other = shift;

return Array->new( array => @{ _calc( $this->_array, $other ) }[2] );
}

sub _calc
{
	my ( $a, $b ) = @_;

	die 'argument type mismatch for _calc( aref, aref )' unless ref($a) eq 'ARRAY' && ref($a) eq 'ARRAY';

	my @array1 = @$a;

	my @array2 = @$b;

	no strict;

	@union = @intersection = @difference = ();

	%count = ();

	foreach $element (@array1, @array2) { $count{$element}++ }

	foreach $element (keys %count)
	{
	    push @union, $element;

	    push @{ $count{$element} > 1 ? \@intersection : \@difference }, $element;
	}

return ( \@union, \@intersection, \@difference );
}

1;

__END__

=head1 NAME

Array - complete object-oriented array class

=head1 SYNOPSIS

  use Class::Maker::Examples::Array;

	Array->new( array => [1..100] );

		# standard

	$a->shift;

	$a->push( qw/ 1 2 3 4 / );

	$a->pop;

	$a->unshift( qw/ 5 6 7 / );

	$a->reset;

	$a->join( ', ' );

		# extended

	$a->count;

	$a->get;

	$a->pick( 4 );

	$a->union( 100..500 );

	$a->intersection( 50..100 );

	$a->difference( 50..100 );

=head1 DESCRIPTION

This an object-oriented array class, which uses a method-oriented interface.

=head1 METHODS

Mostly they have the similar syntax as the native perl functions (use "perldoc -f"). If not they are
documented below, otherwise a simple example is given.

=head2 count

Returns the number of elements (same as @arry in scalar context).

=head2 reset

Resets the array to an empty array.

=head2 get

Returns the backend array.

=head2 pick( [step{scalar}]:2 )

Returns every 'step' (default: 2) element.

=head2 union

Returns the union of two arrays (Array object is returned).

=head2 intersection

Returns the intersection of the two arrays (Array object is returned).

=head2 difference

Returns the difference of the two arrays (Array object is returned).

=head1 EXPORT

None by default.

=head1 EXAMPLE

=head2 Purpose

Because most methods return Array objects itself, the can be easily further treated with Array methods.
Here a rather useless, but informative example.

=head2 Code

use Class::Maker::Examples::Array;

	my $a = Array->new( array => [1..100] );

	my $b = Array->new( array => [50..100] );

	$a->intersection( $b )->pick( 4 )->join( ', ' );

=head1 AUTHOR

Murat Uenalan, muenalan@cpan.org

=head1 SEE ALSO

L<perl>, L<perlfunc>, L<perlvar>

=cut
