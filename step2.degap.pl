foreach $file (@ARGV) {
	chomp $file;
	open IN, $file;
	$file =~ s/\.imposeDNA.msa//;
	open OUT, ">$file.fasta";
	$total = `wc -l $file.imposeDNA.msa` / 2;
	undef %hash;
	undef %count;
	
	while (<IN>) {
		s/>//;
		chomp ($id=$_);
		chomp ($seq=<IN>);
		$hash{$id} = $seq;
	}
	
	foreach $seq (values %hash) {
		@array = split ('',$seq);
		for ($i=0;$array[$i];$i++) {
			if ($array[$i] ne '-') {$count{$i}++}
		}
	}
	
	foreach $id (sort {$a cmp $b} keys %hash) {
		($tmp_id=$id) =~ s/_\d+$//;
		print OUT ">$tmp_id\n";
		@array = split ('',$hash{$id});
		for ($i=0;$array[$i];$i++) {
			if ($count{$i} == 1 * $total) {print OUT $array[$i]}
		}
		print OUT "\n";
	}
}
