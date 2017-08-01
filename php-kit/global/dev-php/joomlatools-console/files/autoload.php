<?php
/* Autoloader for Joomlatools Console */

$vendorDir = '/usr/share/php';

if (!class_exists('Fedora\\Autoloader\\Autoload', false)) {
	require_once '/usr/share/php/Fedora/Autoloader/autoload.php';
}

\Fedora\Autoloader\Autoload::addPsr4('Joomlatools\\Console\\', __DIR__);

//Dependencies
\Fedora\Autoloader\Dependencies::required(array(
	$vendorDir . '/Symfony/Component/Console/autoload.php'
));
