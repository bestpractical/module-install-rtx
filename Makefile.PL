use inc::Module::Install;

name	        'Module-Install-RTx';
all_from        'lib/Module/Install/RTx.pm';
requires        'Module::Install::Admin' => 0.40;

auto_provides;
&WriteAll( check_nmake => 0, sign => 1 );
