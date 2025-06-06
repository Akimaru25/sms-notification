#!/usr/bin/perl -w

use LWP;
use Getopt::Long;
use File::Basename;

# Déclaration des variables globales
use vars qw (
  $PROGNAME
  $VERSION

  $queue_id

  $opt_host
  $opt_help
  $opt_message
  $opt_destination
  $opt_silent
  $opt_verbose
  $opt_datetime
  $opt_hostname
  $opt_displayname
  $opt_state
  $opt_output
  $opt_notificationtype
  $opt_author
  $opt_comment
  $opt_notes
  $opt_ipv4
  $opt_ipv6
);

# Nom du programme et version
$PROGNAME = basename($0);
$VERSION  = '1.0';

# Lecture des options en ligne de commande
Getopt::Long::Configure('bundling');
GetOptions(
    'h|help'              => \$opt_help,
    'H=s'                 => \$opt_host,
    'D=s@'                => \$opt_destination,  # Accepte plusieurs numéros de destination
    'd=s'                 => \$opt_datetime,
    'l=s'                 => \$opt_hostname,
    'n=s'                 => \$opt_displayname,
    's=s'                 => \$opt_state,
    'o=s'                 => \$opt_output,
    't=s'                 => \$opt_notificationtype,
    'b=s'                 => \$opt_author,
    'c=s'                 => \$opt_comment,
    'X=s'                 => \$opt_notes,
    '4=s'                 => \$opt_ipv4,
    '6=s'                 => \$opt_ipv6,
    'v|verbose'           => \$opt_verbose,
    'q|quiet'             => \$opt_silent,
) || help(1, 'Veuillez vérifier vos options.');

# Affiche l’aide si demandé ou si les paramètres requis sont manquants
help(99) if $opt_help;
help(1, 'Options insuffisantes fournies.') unless ($opt_host && $opt_destination && $opt_datetime);

# Ignore la notification si elle est liée à un état de battement (flapping)
if ($opt_notificationtype eq 'FLAPPINGSTART' || $opt_notificationtype eq 'FLAPPINGEND') {
    print "Notification ignorée pour $opt_notificationtype\n" if $opt_verbose;
    exit 0;
}

# Construction du message SMS
my $message = "        ******Surveillance Hôte******    &#13;&#10; &#13;&#10;";
$message .= "$opt_displayname est $opt_state &#13;&#10;";
$message .= "Infos : $opt_output &#13;&#10; &#13;&#10;";
$message .= "Type de notification : $opt_notificationtype &#13;&#10;" if $opt_notificationtype;
$message .= "Date et heure : $opt_datetime &#13;&#10;";
$message .= "Nom d'hôte : $opt_hostname";
$message .= "&#13;&#10; IPv4 :    $opt_ipv4" if $opt_ipv4;
$message .= "&#13;&#10; IPv6 :    $opt_ipv6" if $opt_ipv6;
$message .= "&#13;&#10; Notes sur l'hôte : $opt_notes" if $opt_notes;
if ($opt_comment) {
    $message .= "&#13;&#10; Commentaire de $opt_author : &#13;&#10;  $opt_comment";
}

# Enregistrement du message dans la variable d'envoi
$opt_message = $message;

# Envoi du message à chaque numéro de destination
foreach my $number (@$opt_destination) {
    my $url = 'http://' . $opt_host . '/service.xml';

    # Construction de la requête SOAP
    my $xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pos="poseidonService.xsd">
<soapenv:Header/>
    <soapenv:Body>
    <pos:QueueAdd>
    <Queue>GsmOut</Queue>
    <Gsm>
        <Cmd>SMS</Cmd>
        <Nmr>[DESTINATION]</Nmr>
        <Text>[MESSAGE]</Text>
    </Gsm>
    </pos:QueueAdd>
    </soapenv:Body>
</soapenv:Envelope>
    ';

    $xml =~ s/\[DESTINATION\]/$number/;
    $xml =~ s/\[MESSAGE\]/$opt_message/;

    # Envoi de la requête SOAP HTTP
    my $ua = LWP::UserAgent->new;
    $ua->agent("PoseidonSMSNotification/1.0 " . $ua->agent);
    my $request = HTTP::Request->new(POST => $url);
    $request->content_type('text/xml');
    $request->content($xml);

    print "Envoi à $number :\n$xml\n" if $opt_verbose;

    my $response = $ua->request($request);

    if (!$response->is_success()) {
        die("Échec de l’envoi à $number, erreur : " . $response->status_line());
    }

    # Récupération de l'ID de file si disponible
    my $data = $response->content();
    if ($data =~ m/>(\d+)</) {
        $queue_id = $1;
    } else {
        $queue_id = 'INCONNU';
    }

    print "Réponse de $number :\n$data\n" if $opt_verbose;
    printf "OK, message envoyé avec l’ID %s au numéro '%s'\n", $queue_id, $number unless $opt_silent;
}

exit 0;

# Fonction d’aide avec message personnalisé
sub help {
    my ($level, $msg) = @_;
    $level = 0 unless ($level);
    if ($level == -1) {
        print "$PROGNAME - Version : $VERSION\n";
        exit 0;
    }
    pod2usage({
        -message => $msg,
        -verbose => $level
    });
    exit 0;
}

1;
#!/usr/bin/perl -w

use LWP;
use Getopt::Long;
use File::Basename;

# Déclaration des variables globales
use vars qw (
  $PROGNAME
  $VERSION

  $queue_id

  $opt_host
  $opt_help
  $opt_message
  $opt_destination
  $opt_silent
  $opt_verbose
  $opt_datetime
  $opt_hostname
  $opt_displayname
  $opt_state
  $opt_output
  $opt_notificationtype
  $opt_author
  $opt_comment
  $opt_notes
  $opt_ipv4
  $opt_ipv6
);

# Nom du programme et version
$PROGNAME = basename($0);
$VERSION  = '1.0';

# Lecture des options en ligne de commande
Getopt::Long::Configure('bundling');
GetOptions(
    'h|help'              => \$opt_help,
    'H=s'                 => \$opt_host,
    'D=s@'                => \$opt_destination,  # Accepte plusieurs numéros de destination
    'd=s'                 => \$opt_datetime,
    'l=s'                 => \$opt_hostname,
    'n=s'                 => \$opt_displayname,
    's=s'                 => \$opt_state,
    'o=s'                 => \$opt_output,
    't=s'                 => \$opt_notificationtype,
    'b=s'                 => \$opt_author,
    'c=s'                 => \$opt_comment,
    'X=s'                 => \$opt_notes,
    '4=s'                 => \$opt_ipv4,
    '6=s'                 => \$opt_ipv6,
    'v|verbose'           => \$opt_verbose,
    'q|quiet'             => \$opt_silent,
) || help(1, 'Veuillez vérifier vos options.');

# Affiche l’aide si demandé ou si les paramètres requis sont manquants
help(99) if $opt_help;
help(1, 'Options insuffisantes fournies.') unless ($opt_host && $opt_destination && $opt_datetime);

# Ignore la notification si elle est liée à un état de battement (flapping)
if ($opt_notificationtype eq 'FLAPPINGSTART' || $opt_notificationtype eq 'FLAPPINGEND') {
    print "Notification ignorée pour $opt_notificationtype\n" if $opt_verbose;
    exit 0;
}

# Construction du message SMS
my $message = "        ******Surveillance Hôte******    &#13;&#10; &#13;&#10;";
$message .= "$opt_displayname est $opt_state &#13;&#10;";
$message .= "Infos : $opt_output &#13;&#10; &#13;&#10;";
$message .= "Type de notification : $opt_notificationtype &#13;&#10;" if $opt_notificationtype;
$message .= "Date et heure : $opt_datetime &#13;&#10;";
$message .= "Nom d'hôte : $opt_hostname";
$message .= "&#13;&#10; IPv4 :    $opt_ipv4" if $opt_ipv4;
$message .= "&#13;&#10; IPv6 :    $opt_ipv6" if $opt_ipv6;
$message .= "&#13;&#10; Notes sur l'hôte : $opt_notes" if $opt_notes;
if ($opt_comment) {
    $message .= "&#13;&#10; Commentaire de $opt_author : &#13;&#10;  $opt_comment";
}

# Enregistrement du message dans la variable d'envoi
$opt_message = $message;

# Envoi du message à chaque numéro de destination
foreach my $number (@$opt_destination) {
    my $url = 'http://' . $opt_host . '/service.xml';

    # Construction de la requête SOAP
    my $xml = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:pos="poseidonService.xsd">
<soapenv:Header/>
    <soapenv:Body>
    <pos:QueueAdd>
    <Queue>GsmOut</Queue>
    <Gsm>
        <Cmd>SMS</Cmd>
        <Nmr>[DESTINATION]</Nmr>
        <Text>[MESSAGE]</Text>
    </Gsm>
    </pos:QueueAdd>
    </soapenv:Body>
</soapenv:Envelope>
    ';

    $xml =~ s/\[DESTINATION\]/$number/;
    $xml =~ s/\[MESSAGE\]/$opt_message/;

    # Envoi de la requête SOAP HTTP
    my $ua = LWP::UserAgent->new;
    $ua->agent("PoseidonSMSNotification/1.0 " . $ua->agent);
    my $request = HTTP::Request->new(POST => $url);
    $request->content_type('text/xml');
    $request->content($xml);

    print "Envoi à $number :\n$xml\n" if $opt_verbose;

    my $response = $ua->request($request);

    if (!$response->is_success()) {
        die("Échec de l’envoi à $number, erreur : " . $response->status_line());
    }

    # Récupération de l'ID de file si disponible
    my $data = $response->content();
    if ($data =~ m/>(\d+)</) {
        $queue_id = $1;
    } else {
        $queue_id = 'INCONNU';
    }

    print "Réponse de $number :\n$data\n" if $opt_verbose;
    printf "OK, message envoyé avec l’ID %s au numéro '%s'\n", $queue_id, $number unless $opt_silent;
}

exit 0;

# Fonction d’aide avec message personnalisé
sub help {
    my ($level, $msg) = @_;
    $level = 0 unless ($level);
    if ($level == -1) {
        print "$PROGNAME - Version : $VERSION\n";
        exit 0;
    }
    pod2usage({
        -message => $msg,
        -verbose => $level
    });
    exit 0;
}

1;
