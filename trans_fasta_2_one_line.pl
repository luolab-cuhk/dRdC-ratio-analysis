foreach $file (@ARGV) {
	open IN, $file;
	$file =~ s/^(.*)\.(.*?)$/>$1.oneline\.$2/;
	open OUT, $file;
	while (<IN>) {
		print OUT;
		last;
	}
	while (<IN>) {
		chomp;
		if (/>/){print OUT "\n$_\n"}
		else{print OUT}
	}
	print OUT "\n";
}
