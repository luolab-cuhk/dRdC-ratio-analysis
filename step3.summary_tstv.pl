@files = `ls M10CC_Out`;
open OUT, ">TsTv_ratio.txt";
foreach $file (@files) {
	chomp $file;
	open IN, "M10CC_Out/$file";
	($file) = split "-", $file;
	while (<IN>) {
		chomp;
		if(/^\[ *2\]\s+([\d\.]+)\s+/) { print OUT "$file\t$1\n"; }
	}
}
