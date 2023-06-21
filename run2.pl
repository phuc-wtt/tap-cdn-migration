#!/usr/bin/perl

#NOTE generateAssetCdnUrl\("[^"]*?"\) when update new helper_function_package
#NOTE import SCSS

# Flags
use strict;
use warnings;
use 5.30.0;

# Modules
use File::Find;
use Switch;
use feature qw(say);
use Path::Tiny qw(path);

my $exclude_dir = '(node_modules|\.git|build)';
my $target_dir_relative_path = '../community-web';
my $func_regex = 'generateAssetCdnUrl';

# Global vars
my @all_entry;
my @log;

find(
  sub {
    if( -d $_ and m/$exclude_dir/o ) {
      $File::Find::prune = 1;
      return;
    }
      if (-f _) {
        open(my $fh, "<", $_) or die;
        while (<$fh>) {
          if (/$func_regex/) {
            push(@all_entry, $File::Find::name);
            last;
          }
        }
        close($fh)
      }

    return;
  },
  $target_dir_relative_path
);

foreach (@all_entry) {
  my $file = path($_);
  my $file_content = $file->slurp_utf8;
  my ($match) = $file_content =~ m|import \{ getUrlImage \} from '.*?/helpers';|g;
  
  if ($match) {
    $file_content =~ s|\Q$match\E|$match\nimport { generateAssetCdnUrl } from '\@tickled-media/web-components.tm-helpers';|;
    $file->spew_utf8( $file_content );
  }
}
































