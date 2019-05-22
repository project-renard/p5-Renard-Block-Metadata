use Renard::Incunabula::Common::Setup;
package Renard::Block::Metadata::DOI;
# ABSTRACT: DOI retrieval

use Mu;
use LWP::UserAgent;

lazy _agent => method() {
	my $ua = LWP::UserAgent->new;
	$ua;
};

method _bibtex_header() {
	( Accept => 'text/bibliography; style=bibtex' );
}

=method get_bibtex

Retrieve the BibTeX entry for a given DOI.

=cut
method get_bibtex( $doi ) {
	my $resolver = "http://dx.doi.org/";
	my $doi_url = $doi =~ s,^doi:,$resolver,r;
	die "Not a DOI: $doi" unless $doi_url =~ /\Q$resolver\E/;
	my $content = $self->_agent->get( $doi_url, $self->_bibtex_header )->decoded_content;
}

1;
