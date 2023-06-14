#!/usr/bin/perl

# Flags
use strict;
use warnings;
use 5.30.0;

# Modules
use File::Find;
use Switch;
use feature qw(say);
use Path::Tiny qw(path);

# Config vars
my @all_entry;
my $exclude_dir = '(node_modules|\.git|build)';
my $s3_regex = 's3\.theasianparent\.com';
my $bunny = 'static.cdntap.com';
my $target_dir_relative_path = '../community-web';

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
          if (/$s3_regex/) {
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


# Seperate all-entry into file type entry
my @js_entry;
my @scss_entry;
my @html_entry;
my @json_entry;
my @css_entry;

foreach my $filename (@all_entry) {
  chomp $filename;
  switch ($filename) {
      case m{\.js$} { push(@js_entry, $filename) }
      case m{\.json$} { push(@json_entry, $filename) }
      case m{\.css$} { push (@css_entry, $filename) }
      case m{\.scss$} { push (@scss_entry, $filename) }
      case m{\.html$} { push (@html_entry, $filename) }
      else { say "Wont match for this file type: $filename" }
  }
}

# HTML, JSON, CSS search/replace
# my @static_entry = (
#   @html_entry,
#   @json_entry,
#   @css_entry,
# );
# foreach my $static_files (@static_entry) {
#   foreach ($static_files) {
#     push(@log, $_);
#     my $file = path($_);
#     my $file_content = $file->slurp_utf8;
#     snr($file_content);
#     #$file->spew_utf8( $file_content );
#   }
# };


# JS search/replace into helper function
local $/ = undef;

foreach (@js_entry) {
  open(my $fh, "<", $_) or die;
  my $file_content = <$fh>;
  # Find all `${content}`
  # content =~ m{$s3_regex}


  my (@match) = $file_content =~ m|`[^`]+?$s3_regex.*?`|smg;
  foreach (@match) {say; print "\n\n\n";}
}

local $/ = "\n";


# SCSS search/replace into mixin



# Deal with optimizer : cdn-cgi/image
sub snr {
  # get all matches
  my @s3_match = $_[0] =~ m|($s3_regex/.*?\w+\.{1}\w+\b)|g;
  foreach my $match (@s3_match) {
    my $to_replace;
    # then check if optimized
    if ($match =~ m|cdn-cgi/image/|) {
      # optimized: process the matched
      $to_replace = replaceOptimization($match);
      # snr matched to to_replace
      $_[0] =~ s|$match|$to_replace|g;
    } else {
      $to_replace = $match;
      $to_replace =~ s|$s3_regex|$bunny|;
    }
    push(@log, "[Match]:    $match");
    push(@log, "[Replace]:  $to_replace");
    $_[0] =~ s|\Q$match|$to_replace|g;
  }
  return $_[0]
}

sub replaceOptimization {
  my $to_replace = $_[0];

  if (my ($optimization) = $to_replace =~ m|((?<=/cdn-cgi/image/)?\w+=.*?(?=/))| ){
    $to_replace =~ s|$optimization\/||;
    if ($_[1]) {
      $to_replace = $to_replace . $_[1] . $to_replace . $optimization;
    } else {
      $to_replace = $to_replace . '?' . $optimization;
    }
  }
  if ($to_replace =~ m|((?<=/cdn-cgi/image/)?\w+=.*?(?=/))| ) {
    replaceOptimization($_[0], '&');
  } else {
    $to_replace =~ s|cdn-cgi/image/||;
    $to_replace =~ s|$s3_regex|$bunny|;
    return $to_replace 
  }
  $to_replace =~ s|cdn-cgi/image/||;
  $to_replace =~ s|$s3_regex|$bunny|;
  return $to_replace 
}


# my $log_filename = $target_dir_relative_path;
# $log_filename =~ s/(.*\/)([\w|\-]*)/$2/;
# $log_filename = $log_filename . '.log';
#
# open(my $log_fh, ">", ${log_filename}) or die;
# my $gmt_time = gmtime();
# print $log_fh "${gmt_time}\n";
# foreach (@log) {
#   print $log_fh "$_\n";
# }
# close($log_fh);
#
#
#
# # AUDIT static calling python script: ./audit.py
# my $audit_filename = $target_dir_relative_path;
# $audit_filename =~ s/(.*\/)([\w|\-]*)/$2/; 
# $audit_filename = $audit_filename . '-audit.log';
# my $log_file = path($log_filename);
# my @log_file_content = $log_file->lines_utf8;
# say "Auditing new url, please wait...";
# open(my $audit_fh, ">", ${audit_filename}) or die;
# print $audit_fh "${gmt_time}\n";
# foreach my $line (@log_file_content) {
#   if ($line =~ s|\[Replace\]:\s+||) {
#     chomp $line;
#     my $py = `./audit.py '$line'`;    #python file path specify here
#     print "$line:$py";
#     print $audit_fh "$line:$py"; 
#   }
# }
# close($log_fh);






