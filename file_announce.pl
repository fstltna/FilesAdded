#!/usr/bin/perl
#
# -- Posts a file announcement to the desired sub-board

use Text::CSV;
use Math::Round;
use Getopt::Long;
use WebService::Discord::Webhook;

my $DISCORD_WEBHOOK = "";

# Probably no change for this

# == No changes below here
my $content = "";
my $VERSION = "1.0.0";
my $NEWFILESFILE="/root/.newfilestoadd";	# Stores the list of files we have added but not posted about
my $USAGE;
my $CONF_FILE = "/root/.fa_settings";	# Settings to use
my $DiscordText = "Added the following files:";
my $TempName = "/tmp/fileannounce.txt";

# Try and pull in configs
if (! -f $CONF_FILE)
{
	# Not found, create it
	open(OUTF, ">$CONF_FILE") || die "Unable to create $CONF_FILE for output";
	print (OUTF "webhook=EDITME");
	close(OUTF);
}
if (-e $CONF_FILE)
{
	open(INPF, "<$CONF_FILE") || die "Unable to open $CONF_FILE for input";

	foreach $line (<INPF>)
	{
		#print $line;
		chop($line);
		if (substr($line, 0, 8) eq "webhook=")
		{
			# Saw webhook
			$DISCORD_WEBHOOK = substr($line, 8);
			#print ("Webhook = '$DISCORD_WEBHOOK'\n");
		}
	}
	close(INPF);
}

print "Running file_announce $VERSION\n";
print "============================\n";

GetOptions ("length=i" => \$length,    # numeric
            "usage"    => \$USAGE,      # flag
            "settings"    => \$ShowSettings,      # string
            "help"    => \$USAGE,      # string
            "verbose"  => \$verbose)   # flag
or die("Error in command line arguments\n");

if ($ShowSettings)
{
	print "\tCurrent Settings\n";
	print "\t----------------\n";
	if ($DISCORD_WEBHOOK eq "")
	{
		$DISCORD_WEBHOOK = "\<not set\>";
	}
	print "\tDiscord Webhook: $DISCORD_WEBHOOK\n\n";
	exit 0;
}

if ($USAGE)
{
	print("Usage:\n\t--settings = Displays the settings that will be used\n");
	exit 0;
}

open(TEMPFILE, ">$TempName") || die "Unable to create temp file $TempName";

# Post header to the temp file
print (TEMPFILE $content);

# Read the list of files added
if (! -f "$NEWFILESFILE")
{
	print "No files queued\n";
	exit 0;
}

open(NEWFILES, "<$NEWFILESFILE") || die "Unable to open $NEWFILESFILE for input";

my $csv = Text::CSV->new();
my $FilesWorked = 0;

# Loop for each line in the file
while(<NEWFILES>)
{
	chop;
	my $status = $csv->parse($_);
	my $Line2Out = "";
	my $Line3Out = "";
	my $Line4Out = "";
	my $Line5Out = "";
	my $Line6Out = "";
	my $Line7Out = "";
	($Field1, $LongName, $ShortName, $FileSize) = $csv->fields();
	$FileSize = round($FileSize / 1024);
	print "Proccessing file $LongName\n";
	my $LongLength= length($LongName);
	if ($LongLength > 25)
	{
		$Line2Out = substr($LongName . "                                                  ", 25, 25) . "|";
		if ($LongLength > 50)
		{
			$Line3Out = substr($LongName . "                                                  ", 50, 25) . "|";
			if ($LongLength > 75)
			{
				$Line4Out = substr($LongName . "                                                  ", 75, 25) . "|";
				if ($LongLength > 100)
				{
					$Line5Out = substr($LongName . "                                                  ", 100, 25) . "|";
					if ($LongLength > 125)
					{
						$Line6Out = substr($LongName . "                                                  ", 125, 25) . "|";
						if ($LongLength > 150)
						{
							$Line7Out = substr($LongName . "                                                  ", 50, 25) . "|";
						}
					}
				}
			}
		}
	}
	my $OutputStr = $LongName . " | ($FileSize KB)";
	$DiscordText = "$DiscordText\n$LongName - (Size $FileSize KB)\n";
	if ($FilesWorked > 0)
	{
		print (TEMPFILE "---\n");
		$DiscordText = "$DiscordText\n";
	}
	$FilesWorked++;
	print (TEMPFILE "$OutputStr\n");
	if ($Line2Out ne "")
	{
		print (TEMPFILE "$Line2Out\n");
	}
	if ($Line3Out ne "")
	{
		print (TEMPFILE "$Line3Out\n");
	}
	if ($Line4Out ne "")
	{
		print (TEMPFILE "$Line4Out\n");
	}
	if ($Line5Out ne "")
	{
		print (TEMPFILE "$Line5Out\n");
	}
	if ($Line6Out ne "")
	{
		print (TEMPFILE "$Line6Out\n");
	}
	if ($Line7Out ne "")
	{
		print (TEMPFILE "$Line7Out\n");
	}
}
close(NEWFILES);
close(TEMPFILE);

if ($DISCORD_WEBHOOK eq "")
{
	print "Webhook not set\n";
	exit 0;
}

my $webhook = WebService::Discord::Webhook->new($DISCORD_WEBHOOK);
 
$webhook->get();
print "Webhook posting as '" . $webhook->{name} .
  "' in channel " . $webhook->{channel_id} . "\n";
#$webhook->execute(content => 'Hello, world!', tts => 1);
$webhook->execute($DiscordText);
sleep(5);
#$webhook->execute('All files listed');

exit 0;
