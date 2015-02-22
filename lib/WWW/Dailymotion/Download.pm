package WWW::Dailymotion::Download;

use LWP::UserAgent;
use JSON::XS;
use URI::Escape;
use Data::Dumper;
use Encode;

our $VERSION = 0.2;

sub new {
	my $class = shift;
	my $self = bless {
		ua	=> LWP::UserAgent->new( agent => 'libwww-perl/'. $LWP::UserAgent::VERSION . '+' . __PACKAGE__.'/'.$VERSION, parse_head => 0 ),
		debug	=> undef,
		@_
	}, $class;

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
	print "WWW::Dailymotion::Download: title is: ". encode_utf8($title) ."\n";

	## get video urls
	my @urls = $self->get_video_urls($json,$id);

	unless(@urls){
		print "WWW::Dailymotion::Download: video_urls extraction failed! \n";
		return 0;
	}

	## download
	print "WWW::Dailymotion::Download: downloading to ". encode_utf8($title) ."_dailymotion-". $id .".mp4 ..." if $self->{debug};
	my $response = $self->{ua}->get( $urls[0], ':content_file' => encode_utf8($title) .'_dailymotion-'. $id .'.mp4');
 
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
	my $video_id = shift;

	my $string = "".Data::Dumper::Dumper($json);

	my @lines = split(/\n/,$string);

	my $manifest_url;
	for my $line (@lines){
		if( $line =~ /'autoURL' => 'http([^']+)/ ){
			my $url = uri_unescape('http'.$1);
			print "WWW::Dailymotion::Download::get_video_urls: json-manifest-url: $url \n";
			$manifest_url = $url;
			last;
		}
	}

	# split auth
	my ($frag,$auth) = split(/auth=/,$manifest_url,2);
	print "WWW::Dailymotion::Download::get_video_urls: auth:$auth\n";

	my @urls = (
		'http://www.dailymotion.com/cdn/H264-1920x1080/video/'. $video_id .'.mp4?auth='. $auth,
	);

	return @urls;



	### ignore unfinished code below, is for downloading segments

	## fetch json
	my $manifest = $self->fetch_json($manifest_url);
	die "Could not fetch and decode json!" unless $manifest;

	# print Data::Dumper::Dumper($manifest);

	die "DM manifest seems to be invalid!" unless $manifest && ref($manifest) eq 'HASH';

	my @url_hashes = @{ $manifest->{alternates} };
	my @video_hashes;
	for my $ref (reverse sort { $a->{height} <=> $b->{height} } @url_hashes){
		print "WWW::Dailymotion::Download::get_video_urls: per-video manifest url: $ref->{template} \n";
		push(@video_hashes, $ref);
	}

	print Data::Dumper::Dumper(\@video_hashes);

	# prepare template
	my ($host_template,$frag) = split(/\/sec\(/,$video_hashes[0]->{template},2); # URI->host()
	print "WWW::Dailymotion::Download::get_video_urls: host_template:$host_template\n";

	# let's fetch segment data for first (as of sort: the highest quality) video only

	## fetch json
	my $video_manifest = $self->fetch_json($video_hashes[0]->{template});
	die "Could not fetch and decode json!" unless $video_manifest;

	## todo: dl segments

	print Data::Dumper::Dumper($video_manifest);
}

1;
