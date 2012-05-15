use 5.14.2;
use warnings;
use SWISS::Entry;
use Data::Dumper;
use TokyoCabinet;
use Storable qw(nstore store_fd nstore_fd freeze thaw dclone);

my $tcname = 'uniprot.tch';
my $acname = 'uniprot_ac.tch';

#store_ac_id($ARGV[0], $acname);
#store_swissknife();

sub store_ac_id {
	my $fh = shift // die;

	my $tcname = shift // die;
	my $hdb = TokyoCabinet::HDB->new();

	if (!$hdb->open($tcname, $hdb->OWRITER | $hdb->OCREAT)) {
		my $ecode = $hdb->ecode();
		printf STDERR ("open error: %s\n", $hdb->errmsg($ecode));
	}

	open my $UP, '<', $fh or die $!;
	$/ = "\/\/\n";
	while (<$UP>) {
		my $entry = SWISS::Entry->fromText($_);
		for my $ac (@{$entry->ACs->list}){
			if (! $hdb->put($ac, $entry->ID)){
				my $ecode = $hdb->ecode();
				printf STDERR ("put error: %s\n", $hdb->errmsg($ecode) );
			}
		}
	}

	if (!$hdb->close()) {
		my $ecode = $hdb->ecode();
		printf STDERR ("close error: %s\n", $hdb->errmsg($ecode));
	}
}

sub store_swissknife {
	my $fh = shift // die;
	my $tcname = shift // die;

	my $hdb = TokyoCabinet::HDB->new();

	if (!$hdb->open($tcname, $hdb->OWRITER | $hdb->OCREAT)) {
		my $ecode = $hdb->ecode();
		printf STDERR ("open error: %s\n", $hdb->errmsg($ecode));
	}


	open my $UP, '<', $fh or die $!;

	$/ = "\/\/\n";
	while (<$UP>) {
		my $entry = SWISS::Entry->fromText($_);
		if (! $hdb->put($entry->ID, freeze($entry))){
			my $ecode = $hdb->ecode();
			printf STDERR ("put error: %s\n", $hdb->errmsg($ecode) );
		}
	}

	if (!$hdb->close()) {
		my $ecode = $hdb->ecode();
		printf STDERR ("close error: %s\n", $hdb->errmsg($ecode));
	}
}
