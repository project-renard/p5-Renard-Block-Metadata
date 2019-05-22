use Renard::Incunabula::Common::Setup;
package Renard::Block::Metadata::CrossRef;
# ABSTRACT: CrossRef client

use Mu;
use REST::Client::CrossRef;
use URI::Escape;

=attr email

E-mail address needed to access the public API.

=cut
ro 'email';

lazy _client => method() {
	my $cr = REST::Client::CrossRef->new(
		mailto  => $self->email,
	);
}, handles => [qw(rows get_next)];


=method query_bibliographic

Returns CrossRef data using the field query C<query.bibliographic> for the
C</works> route.

=cut
method query_bibliographic( $query, $select ) {
	my $cr = $self->_client;
	my @params = (
		join('', 'query.bibliographic', '=', uri_escape($query))
	);
	$cr->cursor(undef);
	$cr->{path}   = "/works";
	$cr->{param}  = \@params;
	$cr->{select} = $select;
	$cr->_get_metadata( "/works", \@params, undef, $select );
}

1;
