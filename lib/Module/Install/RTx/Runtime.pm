package Module::Install::RTx::Runtime;
use Module::Install::Base; @ISA = qw(Module::Install::Base);

use strict;
use File::Basename ();

sub RTxDatabase {
    my ($self, $action, $name, $version) = @_;

    require RT;

    RT::LoadConfig();

    require RT::System;

    my $lib_path = File::Basename::dirname($INC{'RT.pm'});
    my @args = ("-Ilib");
    push @args, "-I$RT::LocalPath/lib" if $RT::LocalPath;
    push @args, (
        "-I$lib_path",
        "$RT::SbinPath/rt-setup-database",
        "--action"      => $action,
        ($action eq 'upgrade' ? () : ("--datadir"     => "etc")),
        (($action eq 'insert') ? ("--datafile"    => "etc/initialdata") : ()),
        "--dba"         => $RT::DatabaseAdmin || $RT::DatabaseUser,
        "--prompt-for-dba-password" => '',
        (RT::System->can('AddUpgradeHistory') ? ("--package" => $name, "--ext-version" => $version) : ()),
    );
    # If we're upgrading against an RT which isn't at least 4.2 (has
    # AddUpgradeHistory) then pass --package.  Upgrades against later RT
    # releases will pick up --package from AddUpgradeHistory.
    if ($action eq 'upgrade' and
        not RT::System->can('AddUpgradeHistory')) {
        push @args, "--package" => $name;
    }

    print "$^X @args\n";
    (system($^X, @args) == 0) or die "...returned with error: $?\n";
}

1;
