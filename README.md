WWW::Dailymotion::Download
==========================

Similar to [xaicron](https://github.com/xaicron/)'s effort [WWW::YouTube::Download](http://search.cpan.org/perldoc?WWW::YouTube::Download) (also on [github](https://github.com/xaicron/p5-www-youtube-download)),
this script is a Perl replacement for what the python
based youtube-dl does: 
help a user download videos from Dailymotion.com.

## Please note

This distribution probably becomes deprecated once its functionality
has been migrated into the more general [WWW::Video::Download](https://github.com/isync/www-video-download)

It's not yet there, but prepare yourself for the possibility.

## Installation

With Makefile.PL:
* wget https://github.com/isync/www-dailymotion-download/archive/master.tar.gz
* tar xvf master.tar.gz
* cd www-dailymotion-download-master
* perl Makefile.PL
* make
* sudo make install

Or without installation:

* wget https://github.com/isync/www-dailymotion-download/archive/master.zip
* unzip master.zip
* cd www-dailymotion-download-master
* perl dailymotion-download some-video-url


## Origin

I've found the script [dailymotion-dl.pl](http://backpan.perl.org/authors/id/G/GN/GNUTOO/dailymotion-dl.pl)
abandoned on the CPAN. No user email was to be found, no description,
and it had been deleted from CPAN. The Backpan had a
copy, with the original GNU open source license intact.

Since then it has evolved quite a bit and doesn't resemble the original script anymore.
