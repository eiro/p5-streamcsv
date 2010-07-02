package Stream::CSV;
use 5.10.0;
use warnings;
use strict;
our $VERSION = '0.01';

# TODO: make "\r" and "\r\n" work

sub new {
    use Text::CSV;
    my ( $method, $source, %csv_args ) = @_;

    # if io is a filename, open it 
    my $io = do {
	if ( ref $source ) { $source }
	else {
	    -f $source
		or die "csv_stream can't use $source as source";
	    open my $fh,$source
		or die "$! while open $source";
	    $fh;
	}
    };
    my $csv  = Text::CSV->new( \%csv_args )
	or die Text::CSV->error_diag;

    if ( ref $method ) {
	# given column names, return hashes
	# csv_stream [qw/ login firstname lastname /], qw/ foo.csv binary 1 auto_diag 1 /

	$csv->column_names( @$method );
	$method = 'getline_hr';
    }

    elsif ( $method ~~ 'getline_hr' ) {
	# using first record, return hashes
	# csv_stream qw/ getline_hr foo.csv binary 1 auto_diag 1 /

	my $cols = $csv->getline($io)
	    or die "can't read header csv:". $csv->error_diag;
	if ( any { not defined } @$cols ) {
	    die "wrong csv header:". $csv->error_diag;
	}
	say "cols: ", join ' / ', @$cols;
	$csv->column_names( $cols );
	$method = 'getline_hr';
    }

    elsif ( $method ne 'getline' ) {
	# return arrays
	# csv_stream qw/ getline foo.csv binary 1 auto_diag 1 /
	# die otherwise

	die "csv_stream can't handle method $method"
    }

    # this is the closure
    sub {
	if ( my $r = $csv->$method( $io ) ) { $r }
	elsif ( $csv->eof ) { undef }
	else {
	    die YAML::Dump
	    { map { $_,  $csv->$_ } qw/error_input error_diag/ }
	}
    } 
}

=head1 NAME

Steam::CSV - csv steam for Lazyness

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

    use 5.10.0;
    use strict;
    use warnings;
    use Lazyness ':all';
    use Stream::CSV;
    use YAML;

    say Dump [ fold
	take 2,
	filter { $$_{login} =~ /r/ }
	Stream::CSV::new [qw/ login passwd uid gid gecos home shell /]
	, qw{ /etc/passwd sep_char : }
    ];

=head1 FUNCTIONS

=head2 new ( $method, $source, %attrs )

method can be: 

    * an array ref that contains the column names. so the stream returns hash refs
    * the keyword getline_hr that will use the first record of the steam as array ref
    * the keyword getline so the steam returns array refs

=head1 AUTHOR

Marc Chantreux, C<< <marc.chantreux at biblibre.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-steam-csv at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Steam-CSV>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Steam::CSV


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Steam-CSV>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Steam-CSV>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Steam-CSV>

=item * Search CPAN

L<http://search.cpan.org/dist/Steam-CSV>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Marc Chantreux, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Steam::CSV
