#merge_seq.fna contains the nucleic acid sequences of all genomes
open IN, "../merged_seq.fna";
while (<IN>) {
	s/>//;
	chomp ($id=$_);
	chomp ($seq=<IN>);
	$seq{$id}=$seq;
}

#impose DNA
@files = `ls .`;
foreach $file (@files) {
	chomp $file;
	unless ($file =~ s/\.mafft\.msa//) {next}
	open IN, "$file.mafft.msa";
	open OUT, ">$file.imposeDNA.msa";
	while (<IN>) {
		chomp;
		if (s/>//) {
			$id = $_;
			print OUT ">$id\n";
			next
		}
		@faa = split "", $_;
		@fna = split "", $seq{$id};
		for ($i=0, $j=0; exists $faa[$i]; $i++) {
			if ($faa[$i] eq "-") {print OUT "---"}
			else {print OUT "$fna[$j*3]$fna[$j*3+1]$fna[$j*3+2]"; $j++}
		}
		print OUT "\n";
	}
}
