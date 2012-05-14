use 5.14.2;
use warnings;
use SWISS::Entry;
use Data::Dumper;
use TokyoCabinet;

$/ = "\/\/\n";

while (<>){
	my $entry = SWISS::Entry->fromText($_);	
	for my $db (@{$entry->DRs->{list}}){
		my $db_name = shift $db;
		next unless $db_name eq "GO";
		my ($go_id, $go_annotation, $go_evidence) = @$db;
		$go_annotation =~ /^(\S)\:.+$/ or die;
		my $go_type = $1;
		say join "\t", ("SwissProt",$entry->AC,$entry->ID,"",$go_id, "","IMP","",$go_type,"","","","","","");
	}
}

