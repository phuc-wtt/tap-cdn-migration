#!/usr/bin/perl

# NOTE
# js: second round for non-file, ex: parenttown-prod/community-web/
#
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
my $is_write = 0;
my $exclude_dir = '(node_modules|\.git|build)';
my $s3_regex = 's3\.theasianparent\.com';
my $bunny = 'static.cdntap.com';
my $target_dir_relative_path = '../community-web';
my $helper_function_name = 'console.log';

# Global varsj
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

# JS: search/replace into helper function
my $quote_arr;
my $quote_pair_arr;
my $temp;
my $js_match_replace_pair;
foreach (@js_entry) {
  local $/ = undef;
  # Clear buffer vars
  $quote_arr = [];
  $quote_pair_arr = [];
  $js_match_replace_pair = [];
  # Get js file quote pairs
  open(my $fh, "<", $_) or die;
  my $file_content = <$fh>;
  while ($file_content =~ m/`/g) {
    my $position = pos($file_content);
    push(@$quote_arr, $position);
  }
  while (my ($index, $item) = each @$quote_arr) {
    my $non_zero_index = $index + 1;
    my $is_odd = is_odd($non_zero_index);
    if ($is_odd) {
      push_pair_to_arr($quote_pair_arr, $temp, $item, undef);
    } else {
      push_pair_to_arr($quote_pair_arr, $temp, undef, $item);
    }
  }
  # replace match in quotes
  foreach (@$quote_pair_arr) {
    my $first =  $_->[0];
    my $second = $_->[1];

    my $quote = substr($file_content, $first - 1, ($second - $first + 1));
    my @in_quote_matches = $quote =~ m{($s3_regex/.*?\w+\.{1}\w+\b)}g;
    foreach (@in_quote_matches) {
      my $to_replace = parse_to_helper_function(parse_optimize_static($_));
      push_pair_to_arr($js_match_replace_pair, $temp, $_, undef);
      push_pair_to_arr($js_match_replace_pair, $temp, undef, $to_replace);
    }
  }
  local $/ = "\n";

  # JS: replace in `__` to helper func
  push(@log, '', $_);
  my $js_file = path($_);
  my $js_file_content = $js_file->slurp_utf8;
  foreach (@$js_match_replace_pair) {
    my $match =  $_->[0];
    my $to_replace = $_->[1];
    push(@log, "[Match]:    $match");
    push(@log, "[Replace]:  $to_replace");
    $js_file_content =~ s/\$\{("|')(https:\/\/)?\Q$match\E("|')\}/\$\{$to_replace\}/g;             # match ${"__"}
    $js_file_content =~ s/(\?.*?:.*?)("|')(https:\/\/)?\Q$match\E("|')/$1$to_replace/g;      # match ternary
    $js_file_content =~ s|(https://)?\Q$match\E|\$\{$to_replace\}|;             # match remain
  }
  # JS: replace static to helper funcj
  snr_js_static($js_file_content);
  if ($is_write) {$js_file->spew_utf8( $js_file_content );}

}


# SCSS search/replace into mixin


# HTML, JSON, CSS search/replace
my @static_entry = (
  @html_entry,
  @json_entry,
  @css_entry,
);
foreach my $static_files (@static_entry) {
  foreach ($static_files) {
    push(@log, '', $_);
    my $file = path($_);
    my $file_content = $file->slurp_utf8;
    snr_static($file_content);
    if ($is_write) {$file->spew_utf8( $file_content );}
  }
};


sub snr_static {
  # get all matches
  my @s3_match = $_[0] =~ m|($s3_regex/.*?\w+\.{1}\w+\b)|g;
  foreach my $match (@s3_match) {
    my $to_replace;
    # then check if optimized
    if ($match =~ m|cdn-cgi/image/|) {
      # optimized: process the matched
      $to_replace = parse_optimize_static($match);
      # snr matched to to_replace
      $_[0] =~ s|$match|$to_replace|g;
    } else {
      $to_replace = $match;
      $to_replace =~ s|$s3_regex|$bunny|;
    }
    push(@log, "[Match]:    $match");
    push(@log, "[Replace]:  $to_replace");
    $_[0] =~ s|(https://)?\Q$match|$1$to_replace|g;
  }
  return $_[0]
}

sub snr_js_static { # copy from snr_static
  # get all matches
  my @s3_match = $_[0] =~ m|($s3_regex/.*?\w+\.{1}\w+\b)|g;
  foreach my $match (@s3_match) {
    my $to_replace;
    # then check if optimized
    if ($match =~ m|cdn-cgi/image/|) {
      # optimized: process the matched
      $to_replace = parse_optimize_static($match);
      # snr matched to to_replace
      $to_replace = parse_to_helper_function($to_replace);
      #$_[0] =~ s|$match|$to_replace|g;
    } else {
      $to_replace = $match;
      $to_replace =~ s|$s3_regex|$bunny|;
    }
    push(@log, "[Match]:    $match");
    push(@log, "[Replace]:  $to_replace");
    $to_replace = parse_to_helper_function($to_replace);
    # match patterns
    $_[0] =~ s/(\b\w+\b)=\{?("|')(https:\/\/)?\Q$match\E("|')\}?/$1={$to_replace}/g;
    $_[0] =~ s/=\s?("|'|`)(https:\/\/)?\Q$match\E("|'|`)/= $to_replace/g;
    $_[0] =~ s/:\s?("|'|`)(https:\/\/)?\Q$match\E("|'|`)/: $to_replace/g;
    $_[0] =~ s/return\s?("|'|`)(https:\/\/)?\Q$match\E("|'|`)/return $to_replace/g;
  }
  return $_[0]
}

sub parse_optimize_static {
  my $to_replace = $_[0];
  if (my ($optimization) = $to_replace =~ m|((?<=/cdn-cgi/image/)\w+=.*?(?=/))| ){
    $to_replace =~ s|$optimization\/||;
    if ($_[1]) {
      $to_replace = $to_replace . $_[1] . $optimization;
    } else {
      $to_replace = $to_replace . '?' . $optimization;
    }
  }
  if ($to_replace =~ m|((?<=/cdn-cgi/image/)\w+=.*?(?=/))| ) {
    $to_replace = parse_optimize_static($to_replace, '&');
  }
  $to_replace =~ s|cdn-cgi/image/||;
  $to_replace =~ s|$s3_regex|$bunny|;
  return $to_replace
}

sub parse_to_helper_function {
  my $url = $_[0];
  $url =~ s|\Q$bunny/||;
  my ($file_name) = $url =~ m{(?<=/)([^/]*$|[^?]*)}g;
  my ($bucket_name) = $url =~ m{.*(?=/)}g;

  if ($url =~ m{\?\w+?=}) {
    my ($options) = $url =~ m{(?<=\?)[^/]*$}g;
    $url =~ s|\?\Q${options}||g;
    foreach ($options) {
      s|=|: |g;
      s|&|, |g;
    }
    return "$helper_function_name(" . "\"$bucket_name\", \"$file_name\"" . ", {" . $options . "})"
  } else {
    return "$helper_function_name(\"$bucket_name\", \"$file_name\")"
  }
}

sub is_odd {
  if ($_[0] % 2 == 1) {
    return 1
  } else {
    return 0
  }
}

sub push_pair_to_arr {
  # 0: arr
  # 1: temp_arr
  # 2: first
  # 3: second
  if ($_[2]) {
    push(@{$_[1]}, $_[2]);
  } else {
    my $temp_item = pop(@{$_[1]});
    @{$_[1]} = [];
    push(@{$_[0]}, [$temp_item, $_[3]]);
  }
}


# WRITE LOG
my $log_filename = $target_dir_relative_path;
$log_filename =~ s/(.*\/)([\w|\-]*)/$2/;
$log_filename = $log_filename . '.log';
open(my $log_fh, ">>", ${log_filename}) or die;
my $gmt_time = gmtime();
print $log_fh "//////////////////////////////////////////////////////\n";
print $log_fh "GMT: ${gmt_time}\n";
print $log_fh $is_write ? "Run mode: Write\n" : "Run mode: No Write\n";
print $log_fh "//////////////////////////////////////////////////////\n";
foreach (@log) {
  print $log_fh "$_\n";
}
close($log_fh);



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




