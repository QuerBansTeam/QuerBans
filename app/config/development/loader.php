<?php

$loader = new \Phalcon\Loader();

/**
 * We're a registering a set of directories taken from the configuration file
 */
$loader->registerDirs(
    [
        $config->application->controllersDir,
        $config->application->modelsDir
    ]
);

$loader->registerFiles(
    [
        '../app/library/Utils.php',
        '../app/vendor/autoload.php',
        '../app/library/ServerQuery.php',
    ]
);

$loader->register();
