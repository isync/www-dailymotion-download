package WWW::Dailymotion::Download;

use LWP::UserAgent;
use JSON::XS;
use URI::Escape;

our $VERSION = 0.1;

sub new {
	my $class = shift;
	my $self = bless {
		ua	=> LWP::UserAgent->new( agent => 'libwww-perl/'. $LWP::UserAgent::VERSION . '+' . __PACKAGE__.'/'.$VERSION, parse_head => 0 ),
		debug	=> undef,
		@_
	}, $class;

	require Data::Dumper if $self->{debug} > 1;

	print Data::Dumper::Dumper($self) if $self->{debug} > 1;

	return $self;
}

sub download {
	my ($self, $url) = @_;
	## parse video id
	my $id = $self->get_video_id($url);
	die "Could not get video id!" unless $id;

	## fetch json
	my $json = $self->fetch_json("http://www.dailymotion.com/sequence/full/$id");
	die "Could not fetch and decode json!" unless $json;

	## get title
	my $title = $json->{config}->{metadata}->{title};
	print "WWW::Dailymotion::Download: title is: ". $title ."\n";

	## get video urls
	my @urls = $self->get_video_urls($json);

	## download
	print "WWW::Dailymotion::Download: downloading to ". $title ."_dailymotion-". $id .".mp4 ..." if $self->{debug};
	my $response = $self->{ua}->get( $urls[0], ':content_file' => $title .'_dailymotion-'. $id .'.mp4');
 
	if( $response->is_success ){
		print " OK\n" if $self->{debug};
		return 1;
	}

	print " Error: ".$response->status_line."\n" if $self->{debug};
	return 0;
}

sub get_video_id {
	my $self = shift;
	my $url = shift;
	if( $url =~ /\/video\/([^_]+)_/ ){
		print "WWW::Dailymotion::Download::get_video_id: $1\n" if $self->{debug};
		return $1;
	}

	return;
}

sub fetch_json {
	my $self = shift;
	my $url = shift;
	print "WWW::Dailymotion::Download::fetch_json: $url ... " if $self->{debug};

	my $response = $self->{ua}->get($url);
 
	if ($response->is_success) {
		print "OK\n" if $self->{debug};
		my $json = JSON::XS::decode_json( $response->decoded_content( charset => 'none') ); # only decompress, but content already is encoded utf8
		print 'WWW::Dailymotion::Download::fetch_json: '.Data::Dumper::Dumper($json) if $self->{debug} > 1;
		return $json;
	}

	print "Error: ".$response->status_line."\n" if $self->{debug};

	return;
}

sub get_video_urls {
	my $self = shift;
	my $json = shift;

	my $string = "".Data::Dumper::Dumper($json);

	my @lines = split(/\n/,$string);

	my $urls;
	for my $line (@lines){
		if( $line =~ /'video_url' => 'http([^']+)/ ){
			my $url = uri_unescape('http'.$1);
			print "WWW::Dailymotion::Download::get_video_urls: url: $url \n";
			push(@urls, $url);
		}
	}

	return @urls;
}

1;
