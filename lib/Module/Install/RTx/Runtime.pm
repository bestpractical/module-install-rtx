package Module::Install::RTx::Runtime;

use base 'Exporter';
our @EXPORT = qw/RTxDatabase RTxPatch RTxPlugin/;

use strict;
use File::Basename ();
use POSIX qw (WIFEXITED);
use File::Find;
use Carp;
use Cwd;


# Switch
my $dispatch  ={
    '>' => \&_greater_than,
    '<' => \&_less_than,
    '-' => \&_in_range,
    '=' => \&_equal,
};

sub _in_range {
    my ($rt_ver, $dir) = @_;

    # Get our lower and upper versions
    my ($start_ver, $end_ver) = $dir =~ m/([\d\.]+)-([\d\.]+)/xms;

    # Check if rt_ver is between range of version values
    return 1 if &_greater_than($rt_ver, $start_ver)
                and &_less_than($rt_ver, $end_ver);
    return 1 if &_equal($rt_ver, $start_ver);
    return 1 if &_equal($rt_ver, $end_ver);
    return 0;
}

sub _greater_than {
    my ($rt_ver, $patch_ver) = @_;

    $patch_ver =~ s/\A>//xms;
    $patch_ver = _convert_version($patch_ver);
    $rt_ver = _convert_version($rt_ver);

    # Return TRUE if we are greater than the patch
    return 1 if $rt_ver > $patch_ver;
    return 0;
}

sub _less_than {
    my ($rt_ver, $patch_ver) = @_;

    $patch_ver =~ s/\A<//xms;
    $patch_ver = _convert_version($patch_ver);
    $rt_ver = _convert_version($rt_ver);

    # Return TRUE if we are less than the patch
    return 1 if $rt_ver < $patch_ver;
    return 0;
}

sub _equal {
    my ($rt_ver, $patch_ver) = @_;

    $patch_ver = _convert_version($patch_ver);
    $rt_ver = _convert_version($rt_ver);

    # Check if the versions are equal
    return 1 if $rt_ver == $patch_ver;
    return 0;
}

sub _convert_version {
    my $version = shift @_;
    my @nums;
    my $num;

    # Pass version straight back if no "." is found in it
    # else convert to a float in the format \d+.\d+
    if ($version =~ m/\./xms) {
        @nums = split(/\./, $version);
        $num = shift @nums;
        $num .= '.';
        $num .= join('0', @nums);
        return $num;
    }
    else {
        return $version;
    }
}

sub _required_patch {
    my ($path, $version) = @_;

    # We are pretty safe doing this as the ./patches path is hardcoded
    my @dirs = split('/', $path);
    my $dir = $dirs[2];

    # Check range of versions
    return $dispatch->{'-'}($version, $dir) if $dir =~ m/[\d.]+.\d-\d.[\d.]+/xms;
    # Check greater than
    return $dispatch->{'>'}($version, $dir) if $dir =~ m/\A>[\d.]+\z/xms;
    # Check less than
    return $dispatch->{'<'}($version, $dir) if $dir =~ m/\A<[\d.]+\z/xms;
    # Check if equal
    return $dispatch->{'='}($version, $dir) if $dir =~ m/\A\d.\d+\z/xms;

    # If none of the above match then just apply the patch(s) regardless
    return 1;
}

sub _rt_runtime_load {
    require RT;

    eval { RT::LoadConfig(); };
    if (my $err = $@) {
        die $err unless $err =~ /^RT couldn't load RT config file/m;
        my $warn = <<EOT;
This usually means that your current user cannot read the file.  You
will likely need to run this installation step as root, or some user
with more permissions.
EOT
        $err =~ s/This usually means.*/$warn/s;
        die $err;
    }
}

sub RTxDatabase {
    my ($action, $name, $version) = @_;

    _rt_runtime_load();

    require RT::System;
    my $has_upgrade = RT::System->can('AddUpgradeHistory');

    my $lib_path = File::Basename::dirname($INC{'RT.pm'});
    my @args = (
        "-Ilib",
        "-I$RT::LocalLibPath",
        "-I$lib_path",
        "$RT::SbinPath/rt-setup-database",
        "--action"      => $action,
        ($action eq 'upgrade' ? () : ("--datadir"     => "etc")),
        (($action eq 'insert') ? ("--datafile"    => "etc/initialdata") : ()),
        "--dba"         => $RT::DatabaseAdmin || $RT::DatabaseUser,
        "--prompt-for-dba-password" => '',
        ($has_upgrade ? ("--package" => $name, "--ext-version" => $version) : ()),
    );
    # If we're upgrading against an RT which isn't at least 4.2 (has
    # AddUpgradeHistory) then pass --package.  Upgrades against later RT
    # releases will pick up --package from AddUpgradeHistory.
    if ($action eq 'upgrade' and not $has_upgrade) {
        push @args, "--package" => $name;
    }

    print "$^X @args\n";
    (system($^X, @args) == 0) or die "...returned with error: $?\n";
}

sub RTxPatch {
    my ($patch, $dir) = @_;

    _rt_runtime_load();

    my @cmd = ($patch, '-d', $RT::BasePath, '-p1', '-i');

    # Anonymous subroutine to apply all patches in a directory structure
    my $patch_rt = sub {

        # Next entry if not a file
        return unless -f $_;

        # Next entry if not approprate version of patch
        return unless &_required_patch($File::Find::dir, $RT::VERSION);

        if ($_ =~ m/\.patch\z/xms) {
            push @cmd, getcwd . "/$_";
            WIFEXITED(system(@cmd))
                or croak "Couldn't run: " . join(' ', @cmd) . "($?)\n";
            pop @cmd;
        }
    };

    find {wanted => $patch_rt}, $dir;
}

sub RTxPlugin {
    my ($name) = @_;

    _rt_runtime_load();
    require YAML::Tiny;
    my $data = YAML::Tiny::LoadFile('META.yml');
    my $name = $data->{name};

    my @enabled = RT->Config->Get('Plugins');
    for my $required (@{$data->{x_requires_rt_plugins} || []}) {
        next if grep {$required eq $_} @enabled;

        warn <<"EOT";

**** Warning: $name requires that the $required plugin be installed and
              enabled; it is not currently in \@Plugins.

EOT
    }
}

1;
