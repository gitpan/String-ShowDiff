package String::ShowDiff;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    ansi_colored_diff
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

use Algorithm::Diff qw/sdiff/;
use Term::ANSIColor qw/colored/;

sub ansi_colored_diff {
    my ($string, $changed_string, $options) = @_;
    $options ||= {};
    my %colors = (
	'-' => 'on_red',
	'+' => 'on_green',
	'u' => 'reset',
	%$options
    );	
    my @sdiff = sdiff(map {[split //, $_]} $string, $changed_string);
    my $ansi = "";
    my $pos = 0;
    while (@sdiff and my ($mod, $s1, $s2) = @{shift @sdiff}) {
	if ($mod =~ /[u+-]/) { 
	    $ansi .= colored($s1 || $s2, $colors{$mod});
	    next;	
	} else {  # Must be a change
	          # So take a look, whether there are more chars that could be
		  # changed in a row
	    while (@sdiff && $sdiff[0]->[0] eq 'c') {
		$s1 .= $sdiff[0]->[1];          # if so, $s1 = chars to remove
		                                # in a row
		$s2 .= $sdiff[0]->[2];          # and $s2 to add
		shift @sdiff;                   # This element was a change
		                                # that is already in $s1, $s2
						# and thus unnecessary now
	    }
	    $ansi .= join "", map({colored($_, $colors{'-'})} split //, $s1),
		              map({colored($_, $colors{'+'})} split //, $s2);
	}		     
    }
    return $ansi;
}


1;
__END__

=head1 NAME

String::ShowDiff - Perl extension to help visualize differences between strings

=head1 SYNOPSIS

  use String::ShowDiff qw/ansi_colored_diff/;
  print ansi_colored_diff("abcehjlmnp", "bcdefjklmrst");

  # or a bit more detailed:
  my %options = ('u' => 'reset',
                 '+' => 'on_green',
		 '-' => 'on_red');
  print ansi_colored_diff($oldstring, $newstring, \%options);

=head1 DESCRIPTION

This module is a wrapper around the diff algorithm from the module
C<Algorithm::Diff>. It's job is to simplify a visualization of the differences of each strings.

Compared to the many other Diff modules,
the output is neither in C<diff>-style nor are the recognised differences on line or word boundaries,
they are at character level.

=head2 FUNCTIONS

=over 1

=item ansi_colored_diff $string, $changed_string, $options_hash;

This method compares C<$string> with C<$changed_string> 
and returns a string for an output on an ANSI terminal.
Removed characters from C<$string> are shown by default with a red background,
while added characters to C<$changed_string> are shown by default with a green background
(the unchanged characters are shown with the default values for the terminal).

The C<$options_hash> allows you to set the colors for the output.
The variable is a reference to a hash 
with three optional keys ('u' for the color of the unchanged parts,
'-' for the removed parts and '+' for the added ones).
The default values for the options are:

    my $default_options = {
	'u' => 'reset',
	'-' => 'on_red',
	'+' => 'on_green'
    };

The specified colors must follow the conventions for the
C<colored> method of L<Term::ANSIColor>.
Please read its documentation for details.

=back

=head2 EXPORT

None by default.

=head1 SEE ALSO

L<Term::ANSIColor>

L<Algorithm::Diff>,
L<Text::Diff>,
L<Text::ParagraphDiff>,
L<Test::Differences>

=head1 AUTHOR

Janek Schleicher, E<lt>bigj@kamelfreund.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Janek Schleicher

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
