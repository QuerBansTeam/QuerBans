<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class BansController extends ControllerBase {

    public function loginAction() {

        if ($this->request->isPost()) {
            $login      =   $this->request->getPost('login');
            $password   =   $this->request->getPost('password');

            //$user =
        }
    }
}
