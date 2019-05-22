#!/usr/bin/env perl
# PODNAME: query-crossref
# ABSTRACT: Query CrossRef

# Vim:
# :exe ".-1r!query.pl --title '" . getline('.') . "'"

use FindBin;
use lib "$FindBin::Bin/../lib";

use Modern::Perl;

package Q {
	use Mu;
	use CLI::Osprey;
	#use Log::Any::Adapter( 'File', './log.txt', 'log_level'=> 'info');
	use Renard::Incunabula::Common::Setup;
	use Renard::Block::Metadata::CrossRef;
	use Renard::Block::Metadata::DOI;
	use utf8::all;

	lazy email => method() {
		chomp(my $email = `git config user.email`);
		die "No e-mail in .gitconfig" unless $email;
		$email;
	};

	lazy crossref => method() {
		Renard::Block::Metadata::CrossRef->new(
			email => $self->email,
		);
	};

	lazy doi => method() {
		Renard::Block::Metadata::DOI->new;
	};


	option title => (
		is => 'ro',
		required => 1,
		format => 's',
		doc => 'Article title'
	);

	method run() {
		my $cr = $self->crossref;
		my $num_of_results = 1;
		$cr->rows(1);
		my $data = $cr->query_bibliographic( $self->title, "title,DOI,URL" );
		my $count = 0;
		while () {
			last unless $data;

			for my $row (@$data) {
				print "\n" unless ($row);
				for my $field (sort keys %$row) {
					print $field, ": ", $row->{$field}. "\n";
					if( $field eq 'URL' ) {
						my $content = $self->doi->get_bibtex( $row->{$field} );
						$content =~ s/\n+\Z//sm;
						say $content;
					}
				}
			}

			last if ++$count >= $num_of_results;

			$data = $cr->get_next();
		}
	}
}

sub main {
	binmode STDOUT, ":encoding(UTF-8)";
	Q->new_with_options->run;
}

main;
