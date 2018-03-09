<?php

use Phalcon\Mvc\View;
use Phalcon\Mvc\View\Engine\Php as PhpEngine;
use Phalcon\Mvc\Url as UrlResolver;
use Phalcon\Mvc\View\Engine\Volt as VoltEngine;
use Phalcon\Mvc\Model\Metadata\Memory as MetaDataAdapter;
use Phalcon\Session\Adapter\Files as SessionAdapter;
use Phalcon\Flash\Direct as Flash;
use Phalcon\Mvc\Model\Manager as ModelManager;
use Phalcon\Forms\Manager as FormsManager;
use Phalcon\Crypt;
use Phalcon\Security;
use Phalcon\Http\Response\Cookies;
use Phalcon\Acl\Adapter\Memory as AclList;

/**
 * Shared configuration service
 */
$di->setShared('config', function () {
    $configDir = '/config/config.php';
    if (DEVEL) {
        $configDir = '/config/development/config.php';
    }
    return include APP_PATH . $configDir;
});

/**
 * The URL component is used to generate all kind of urls in the application
 */
$di->setShared('url', function () {
    $url = new UrlResolver();
    $url->setBaseUri($this->getConfig()->application->baseUri);
    return $url;
});

/**
 * Setting up the view component
 */
$di->setShared('view', function () {
    $config = $this->getConfig();

    $view = new View();
    $view->setDI($this);
    $view->setViewsDir($config->application->viewsDir);

    $view->registerEngines([
        '.volt' => function ($view) {
            $config = $this->getConfig();

            $volt = new VoltEngine($view, $this);

            $volt->setOptions([
                'compiledPath' => $config->application->cacheDir,
                'compiledSeparator' => '_'
            ]);

            $compiler = $volt->getCompiler();
            $compiler->addFunction('strftime', 'strftime');
            $compiler->addFunction('getCountryIsoCode', 'getCountryIsoCode');
            $compiler->addFunction('getCountryName', 'getCountryName');
            $compiler->addFunction('Is32Bit', 'Is32Bit');

            $compiler->addFilter('sec_to_str', function ($resolvedArgs, $resolvedExpr) {
                return 'sec_to_str(' . $resolvedArgs . ');';
            });
            $compiler->addFilter('ceil', function ($resolvedArgs, $resolvedExpr) {
                return 'ceil(' . $resolvedArgs . ');';
            });

            return $volt;
        },
        '.phtml' => PhpEngine::class

    ]);

    return $view;
});

/**
 * Database connection is created based in the parameters defined in the configuration file
 */
$di->setShared('db', function () {
    $config = $this->getConfig();

    $class = 'Phalcon\Db\Adapter\Pdo\\' . $config->database->adapter;
    $params = [
        'host'     => $config->database->host,
        'username' => $config->database->username,
        'password' => $config->database->password,
        'dbname'   => $config->database->dbname,
        'charset'  => $config->database->charset
    ];

    if ($config->database->adapter == 'Postgresql') {
        unset($params['charset']);
    }

    $connection = new $class($params);

    return $connection;
});


/**
 * If the configuration specify the use of metadata adapter use it or use memory otherwise
 */
$di->setShared('modelsMetadata', function () {
    return new MetaDataAdapter();
});

/**
 * Register the session flash service with the Twitter Bootstrap classes
 */
$di->set('flash', function () {
    return new Flash([
        'error'   => 'alert alert-danger',
        'success' => 'alert alert-success',
        'notice'  => 'alert alert-info',
        'warning' => 'alert alert-warning'
    ]);
});

/**
 * Start the session the first time some component request the session service
 */
$di->setShared('session', function () {
    $session = new SessionAdapter();
    $session->start();
    return $session;
});

$di->setShared('security', function () {
    $security = new Security();
    $security->setWorkFactor(15);
    return $security;
});

$di->setShared('modelsManager', function () {
    $manager = new ModelManager();
    $manager->setModelPrefix($this->getConfig()->database->prefix);
    return $manager;
});

$di->setShared('forms', function () {
    $formsManager = new FormsManager();
    $formsManager->set('banedit', new BanEditForm());
    return $formsManager;
});

$di->setShared('crypt', function () {
    $crypt = new Crypt();
    $crypt->setKey($this->getConfig()->application->cryptKey);
    return $crypt;
});

$di->setShared('cookies', function () {
    $cookies = new Cookies();
    $cookies->useEncryption(true);
    return $cookies;
});

$di->setShared('acl', function () {
    if (!is_file(APP_PATH . '/config/permissions.data')) {
        // Set up default permissions
        $acl = new AclList();
        $acl->setDefaultAction(Phalcon\Acl::DENY);

        $acl->addRole('admin');
        $acl->addRole('guest');
        $acl->addResource('general', [
            'showip',
            'acp',
        ]);
        $acl->addResource('Bans', [
            'ban',
            'unban',
            'edit',
            'delete',
            'create',
            'view',
            'index',
        ]);
        $acl->allow('admin', '*', '*');
        $acl->allow('guest', 'Bans', 'index');
        $acl->allow('guest', 'Bans', 'view');

        // Store serialized list into plain file
        file_put_contents(APP_PATH . '/config/permissions.data', serialize($acl));
    } else {
        // Restore ACL object from serialized file
        $acl = unserialize(file_get_contents(APP_PATH . '/config/permissions.data'));
    }
    return $acl;
});
