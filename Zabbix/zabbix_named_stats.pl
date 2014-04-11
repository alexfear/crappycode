my $success;
my $referral;
my $nxrrset;
my $nxdomain;
my $recursion;
my $failure;
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)}; # Make %ENV safer
$ENV{'PATH'}="/usr/local/bin:/bin:/usr/bin";
while ($code>0 && $i<$retry)
{
  $i++;
  #$code=system("$rndc stats >/dev/null� 2>&1");
  $code=system("$rndc stats");
  if ($code>0) {sleep($sleep);}
}
#my $position=(stat($stats))[7];
#if ($position<$data)
# {
#� $position=0;
# }
#else {$position=$position-$data;}

open(FILE,"$stats");
#seek(FILE,$position,0);
while(<FILE>)
{
  if (/\s+(\d+)\ queries\ resulted\ in\ successful/) {$success=$1;}
  if (/\s+(\d+)\ queries\ resulted\ in\ referral\s+/) {$referral=$1;}
  if (/\s+(\d+)\ queries\ resulted\ in\ nxrrset\s+/) {$nxrrset=$1;}
  if (/\s+(\d+)\ queries\ resulted\ in\ NXDOMAIN\s+/) {$nxdomain=$1;}
  if (/\s+(\d+)\ queries\ caused\ recursion\s+/) {$recursion=$1;}
  if (/\s+(\d+)\ other\ query\ failures\s+/) {$failure=$1;}
  if (/Statistics Dump ---\s+\((\d+)\)/) {$date=$1;}
}
close(FILE);
if ((stat($stats))[7]>$maxsize)
{
  open(FILE,">$stats");
  close(FILE);
}
open(FILE,">$stat_file");
print FILE "date: $date ",scalar(localtime($date)),"\n";
print FILE "success: $success\n";
print FILE "referral: $referral\n";
print FILE "nxrrset: $nxrrset\n";
print FILE "nxdomain: $nxdomain\n";
print FILE "recursion: $recursion\n";
print FILE "failure: $failure\n";
close(FILE);
if ($code>0)
{
  print "2\n";
}
else
{
  print "1\n";
}
