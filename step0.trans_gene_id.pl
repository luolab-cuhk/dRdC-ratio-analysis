`mkdir 02_alignment`;

#merge_seq.faa contains the protein sequences of all genomes
open IN, "merged_seq.faa";
while (<IN>) {
	if (s/>//) {
		chomp ($id=$_);
		chomp ($seq=<IN>);
		$seq{$id} = $seq;
	}
}

#SingleCopyOrthogroups.txt contains single-copied core orthologous gene families shared by all genomes
open IN, "01_orthofinder_result/SingleCopyOrthogroups.txt";
while (<IN>) {
	chomp;
	$single_copy_og{$_} = 1;
}

#Orthogroups.txt contains gene_IDs for each orthologous gene family
open IN, "01_orthofinder_result/Orthogroups.txt";
while (<IN>) {
	chomp;
	($og,@genes) = split " ";
	$og =~ s/://;
	unless ($single_copy_og{$og}) { next; }
	open FAA, ">02_alignment/$og.faa";
	foreach $gene (@genes) { print FAA ">$gene\n$seq{$gene}\n"; }
}
