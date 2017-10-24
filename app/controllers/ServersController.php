<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class ServersController extends ControllerBase {

    public function initialize() {
        $this->view->activePage = 'servers';
        $this->view->pageTitle = 'Server List';
    }

    public function indexAction() {

        
    }

}
