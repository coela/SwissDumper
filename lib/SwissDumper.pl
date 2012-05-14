use 5.14.2;
use warnings;
use SWISS::Entry;
use Data::Dumper;
use TokyoCabinet;
use Storable qw(nstore store_fd nstore_fd freeze thaw dclone);

my $tcname = 'uniprot.tch';

# create the object
my $hdb = TokyoCabinet::HDB->new();

# open the database
if (!$hdb->open($tcname, $hdb->OWRITER | $hdb->OCREAT)) {
	my $ecode = $hdb->ecode();
	printf STDERR ("open error: %s\n", $hdb->errmsg($ecode));
}

$/ = "\/\/\n";

$ARGV[0] or die;
open my $UP, '<', $ARGV[0] or die $!;
while (<$UP>) {
	my $entry = SWISS::Entry->fromText($_);	
	if (! $hdb->put($entry->ID, freeze $entry)){
		my $ecode = $hdb->ecode();
		printf STDERR ("put error: %s\n", $hdb->errmsg($ecode) );
	}
}

if (!$hdb->close()) {
	my $ecode = $hdb->ecode();
	printf STDERR ("close error: %s\n", $hdb->errmsg($ecode));
}

