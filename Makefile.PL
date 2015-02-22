
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'WWW::Dailymotion::Download',
#	AUTHOR		=> 'isync',
	ABSTRACT	=> 'Library and command-line script to download videos from Dailymotion',
	LICENSE		=> 'gpl',
	VERSION_FROM	=> 'lib/WWW/Dailymotion/Download.pm',
	PREREQ_PM	=> {
		'Getopt::Long' => 1,
		'LWP::UserAgent' => 1,
		'JSON::XS' => 1,
		'URI::Escape' => 1,
		'Data::Dumper' => 1,
		'Encode' => 1,
	},
	BUILD_REQUIRES	=> { },
	EXE_FILES	=> [
		'dailymotion-download'
	],
	META_MERGE	=> {	# CPAN::Meta::Spec
		'meta-spec'	=> { version => 2 },
		resources	=> {
			repository => {
				url => 'git://github.com/isync/www-dailymotion-download.git',
				web => 'https://github.com/isync/www-dailymotion-download',
				type=> 'git',
			},
		},
	}
);
