use inc::Module::Install;
RTx('RT-Extension-MagicContentType');
all_from('lib/RT/Extension/MagicContentType.pm');
requires( 'File::MimeInfo::Magic' => 0 );
requires( 'IO::Scalar' => 0 );
requires( 'File::LibMagic' => 0 );
&WriteAll;
