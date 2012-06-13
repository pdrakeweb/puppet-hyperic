#!/usr/bin/perl -w
use Config::Simple;
use POSIX;

# Database File
my $dbfile="./.stats";

if (!-e $dbfile){
	open(FILE,">$dbfile");
	my $stats = get_stat();
	while(my ($k, $v) = each(%{$stats})){
		print FILE "$k=$v\n";
	}
}

else {
	my $savedStats = getSavedStats();
	my $newStats = get_stat();
	my $deltaStats = getDeltaStats($savedStats,$newStats);
	my @keys = keys(%{$deltaStats});
	foreach my $key (@keys) {
		print "$key=$deltaStats->{$key}\n";
	}
}

sub getDeltaStats {
	my ($savedStats,$newStats) = @_;
	my %deltaStats;
	my @keys = keys(%{$savedStats});
	foreach my $key (@keys){
		$deltaStats{$key}=ceil(($newStats->{$key}-$savedStats->{$key})/5);
	}
	return \%deltaStats;
}

sub get_stat{
	my @stats=`varnishstat -1`;
	open(FILE,">$dbfile");
	my %statics;
	foreach my $stat (@stats) {
		chomp($stat);
		my @detail = split(/\s+/,$stat);
		$detail[1]=~s/^\.$/0/;
		$statics{$detail[0]}="$detail[1]";
		print FILE "$detail[0]=$detail[1]\n";
	}	
	return \%statics;	
}

sub getSavedStats {
	my %savedStats;
	my $conf = new Config::Simple;
	$conf->read($dbfile);
	while(my($k, $v) = each(%{$conf->{default}})){
		$savedStats{$k}=$v;
	}
	return \%savedStats;
}
