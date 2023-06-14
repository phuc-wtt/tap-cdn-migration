#!/usr/bin/perl

# Flags
use strict;
use warnings;
use 5.30.0;

use File::Find;
use Switch;
use feature qw(say);
use Path::Tiny qw(path);

my $abc = "asdfasdfs 'sadfasd' \"sadfasd\"  dfj";
$abc =~ s|"||g;
say $abc;

#
# my $s3_regex = 's3\.theasianparent\.com';
# my $bunny = 'static.cdntap.com';
#
#
#
# my $quote_arr;
# my $quote_pair_arr;
# my $temp;
# local $/ = undef;
# open(my $fh, "<", '../community-web/server/controllers/MainContentAmp.js') or die;
# my $file_content = <$fh>;
# while ($file_content =~ m/`/g) {
#   my $position = pos($file_content);
#   push(@$quote_arr, $position);
# }
# local $/ = "\n";
#
# while (my ($index, $item) = each @$quote_arr) {
#   my $non_zero_index = $index + 1;
#   my $is_odd = is_odd($non_zero_index);
#   if ($is_odd) {
#     push_pair_to_array($item);
#   } else {
#     push_pair_to_array(undef, $item);
#   }
# }
#
#
#
# foreach (@$quote_pair_arr) {
#   my $first =  $_->[0];
#   my $second = $_->[1];
#
#   my $quote = substr($file_content, $first - 1, ($second - $first + 1));
#   my @in_quote_matches = $quote =~ m{($s3_regex/.*?\w+\.{1}\w+\b)}g;
#   foreach (@in_quote_matches) {
#     say parse_to_helper_function(get_to_replace($_));
#   }
# }
#
#
# sub parse_to_helper_function {
#   my $url = $_[0];
#   $url =~ s|\Q$bunny/||;
#   if ($url =~ m{\?\w+?=}) {
#     my ($options) = $url =~ m{(?<=\?)[^/]*$}g;
#     $url =~ s|\?\Q${options}||g;
#     foreach ($options) {
#       s|=|: |g;
#       s|&|, |g;
#     }
#     return 'helperFunction(' . "'$url" . ', {' . $options . '})'
#   } else {
#     return "helperFunction('$url')"
#   }
# }
#
#
# sub is_odd {
#   if ($_[0] % 2 == 1) {
#     return 1
#   } else {
#     return 0
#   }
# }
#
# sub push_pair_to_array {
#   if ($_[0]) {
#     push(@$temp, $_[0]);
#   } else {
#     my $temp_item = pop(@$temp);
#     push(@$quote_pair_arr, [$temp_item, $_[1]]);
#   }
# }
#
# sub get_to_replace {
#   my $to_replace = $_[0];
#   if (my ($optimization) = $to_replace =~ m|((?<=/cdn-cgi/image/)\w+=.*?(?=/))| ){
#     $to_replace =~ s|$optimization\/||;
#     if ($_[1]) {
#       $to_replace = $to_replace . $_[1] . $optimization;
#     } else {
#       $to_replace = $to_replace . '?' . $optimization;
#     }
#   }
#   if ($to_replace =~ m|((?<=/cdn-cgi/image/)\w+=.*?(?=/))| ) {
#     $to_replace = get_to_replace($to_replace, '&');
#   }
#   $to_replace =~ s|cdn-cgi/image/||;
#   $to_replace =~ s|$s3_regex|$bunny|;
#   return $to_replace
# }
#
#
#
#
#
#
# =for comment
# my $date = localtime();
# print $date;
# my $target_dir_relative_path = '../community-web';
# my $log_filename = $target_dir_relative_path;
# $log_filename =~ s/(.*\/)([\w|\-]*)/$2/;
# say $log_filename;
# my $s3_regex = 's3\.theasianparent\.com';
# my $file = path('./test.txt');
# my $data = $file->slurp_utf8;
#
# # do something here
# if (my @s3_match = $data =~ m|($s3/.*?\w+\.{1}\w+\b)|g ) {
#   foreach my $match (@s3_match) {
#     if ($match =~ m|cdn-cgi/image/|) {
#       check_if_optimized($match)
#     }
#   }
# }
#
# #$file->spew_utf8( $data );
# sub check_if_optimized {
#   if (my @s3_match = $_[0] =~ m|($s3_regex/.*?\w+\.{1}\w+\b)|g ) {
#     foreach my $match (@s3_match) {
#       if ($match =~ m|cdn-cgi/image/|) {
#         replaceOptimization($_[0], $match)
#       }
#     }
#     $_[0] =~ s|cdn-cgi/image/||g;
#   }
# }
#
# sub replaceOptimization {
#   if (my ($optimization) = $_[1] =~ m|((?<=/cdn-cgi/image/)?\w+=.*?(?=/))| ){
#     $_[1] =~ s|$optimization\/||;
#     if ($_[2]) {
#       $_[1] = $_[1] . $_[2] . $_[1] . $optimization;
#     } else {
#       $_[1] = $_[1] . '?' . $optimization;
#     }
#   }
#   if ($_[1] =~ m|((?<=/cdn-cgi/image/)?\w+=.*?(?=/))| ) {
#     replaceOptimization($_[0],$_[1] , '&');
#   } else {
#     return $_[1]
#   }
#   return $_[1]
# }
#
#
# if ($inputt =~ s|cdn-cgi/image/||g) {
#   replaceOptimization($inputt);
# }
#
# sub replaceOptimization {
#
#     if (my ($optimization) = $_[0] =~ m|((?<=/)?\w+=.*?(?=/))| ){
#       $_[0] =~ s|$optimization/||;
#       if ($_[1]) {
#         $_[0] = $_[0] . $_[1] . $optimization;
#       } else {
#         $_[0] = $_[0] . '?' . $optimization;
#       }
#     }
#
#     if ($_[0] =~ m|((?<=/)?\w+=.*?(?=/))| ) {
#       replaceOptimization($_[0], '&');
#     }
# }
#
# say $inputt;
# =cut
