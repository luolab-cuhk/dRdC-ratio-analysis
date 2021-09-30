@files = `ls *fasta`;
foreach $file (@files) {
	chomp $file;
	unless ($file =~ s/\.fasta//) { next; }
	#header
	open OUT, ">$file.seq";
	$no_row = `wc -l $file.fasta` / 2;
	open IN, "$file.fasta";
	<IN>;
	$seq = <IN>;
	chomp $seq;
	$len = length $seq;
	print OUT "$no_row    $len\n";
	
	#body
	open IN, "$file.fasta";
	while (<IN>) {
		s/>//;
		print OUT;
	}
}