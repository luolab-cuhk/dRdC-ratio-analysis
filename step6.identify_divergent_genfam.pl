#!/usr/bin/perl


use warnings;

# user inputs
$seqFile = $ARGV[0] ; 	# the *.SEQ file
$dataFile = $ARGV[1] ; 	# the *.charge_out or *.MY_out file
$outDir = $ARGV[2] ; 	# the output dir of divergent_genfam.charge/ or divergent_genfam.MY/

# =================================================
# load genome name and numbers of the gene family 
# =================================================
open NAME, "<", $seqFile;
%name=();
$count=0;
<NAME>;
while(<NAME>)
{
	chomp $_;
	$count++;
	$name{$count}=$_;
	<NAME>;
}
$num_of_seq=$count;
close NAME;

# =========================================
# load data from *.charge_out or *.MY_out
# =========================================
open DATA, "<", $dataFile;
%sites=();
while(<DATA>)
{
	chomp;
	if(/^otu\s+(\S+):\s+(\S+)\s+(\S+)/)
	{
		$seq_id=$1;
		$rad_site=$2;
		$con_site=$3;
#print "$seq_id\t$rad_site\t$con_site\n";
		$sites{$seq_id}=[$rad_site,$con_site];
	}
	elsif(/^otu(\S+):\s+(\S+)\s+(\S+)/)
	{
		$seq_id=$1;
		$rad_site=$2;
		$con_site=$3;
#print "$seq_id\t$rad_site\t$con_site\n";
		$sites{$seq_id}=[$rad_site,$con_site];
	}
	elsif(/^Proportions of radical differences/)
	{
		last;
	}
	elsif(/^Numbers of radical \(r, above diagonal\) and/)
	{
		$row=0;
		%rad_diff=();
		%con_diff=();
		while(<DATA>)
		{
			chomp;
			chop;
			$row++;
			if($row > $num_of_seq)
			{
				last;
			}
			else
			{
				@items=split /\s+/, $_;
				for ($x=1; $x<=$#items; $x++)
				{
					if($row < $x)
					{
						$pair="$row\_$x";
						$rad_diff{$pair}=$items[$x];
					}
					elsif($row > $x)
					{
						$pair="$x\_$row";
						$con_diff{$pair}=$items[$x];
					}
				}
			}
		}
	}
}
close DATA;

# ==================================================
#  check if rad_rate and con_rate exceed the limit
# ==================================================
open OUT, ">>", "$outDir/divergent.seqid";
for ($i=1; $i<$num_of_seq; $i++)
{
	$n_rad_1=$sites{$i}[0];
	$n_con_1=$sites{$i}[1];
	for ($j=$i+1; $j<=$num_of_seq; $j++)
	{
		$n_rad_2=$sites{$j}[0];
		$n_con_2=$sites{$j}[1];
#print "$i $j $n_rad_1 $n_rad_2 \n" ;
		$n_rad_ave=($n_rad_1+$n_rad_2)/2;
		$n_con_ave=($n_con_1+$n_con_2)/2;
		$pair_id="$i\_$j";
		$n_rad_diff=$rad_diff{$pair_id};
		$n_con_diff=$con_diff{$pair_id};
		$rad_rate=$n_rad_diff/$n_rad_ave;
		$con_rate=$n_con_diff/$n_con_ave;
#print "$rad_rate\t$con_rate\n";
		if($rad_rate >= 0.75 or $con_rate >= 0.75)
		{
			print OUT "$dataFile: $name{$i}\_$name{$j}\n";
		}
	}
}
close OUT;
