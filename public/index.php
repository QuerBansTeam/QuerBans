<?php
use Phalcon\Di\FactoryDefault;

error_reporting(E_ALL);

define('BASE_PATH', dirname(__DIR__));
define('APP_PATH', BASE_PATH . '/app');
define('DEVEL', 1);

try {

    /**
     * The FactoryDefault Dependency Injector automatically registers
     * the services that provide a full stack framework.
     */
    $di = new FactoryDefault();

    /**
     * Handle routes
     */
    if (!DEVEL) {
        include APP_PATH . '/config/router.php';
    } else {
        include APP_PATH . '/config/development/router.php';
    }

    /**
     * Read services
     */
    if (!DEVEL) {
        include APP_PATH . '/config/services.php';
    } else {
        include APP_PATH . '/config/development/services.php';
    }

    /**
     * Get config service for use in inline setup below
     */
    $config = $di->getConfig();

    /**
     * Include Autoloader
     */
    if (!DEVEL) {
        include APP_PATH . '/config/loader.php';
    } else {
        include APP_PATH . '/config/development/loader.php';
    }

    /**
     * Handle the request
     */
    $application = new \Phalcon\Mvc\Application($di);

    echo str_replace(["\n","\r","\t"], '', $application->handle()->getContent());

} catch (\Exception $e) {
    echo $e->getMessage() . '<br>';
    echo '<pre>' . $e->getTraceAsString() . '</pre>';
}
