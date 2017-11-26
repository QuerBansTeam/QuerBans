<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class LoginController extends ControllerBase {

    public function loginAction() {
        $this->view->disable();

        if ($this->request->isPost()) {
            $login      =   $this->request->getPost('login');
            $password   =   $this->request->getPost('password');

            $user = Admins::findFirst([
                "username" => $login,
            ]);

            if ($user) {
                if ($this->security->checkHash($password, $user->password)) {
                    $this->session->set('username', $login);
                }
            } else {
                $this->security->hash(rand());
            }
        }
        $this->response->redirect();
    }

    public function logoutAction() {
        $this->view->disable();

        if ($this->session->has('username')) {
            $this->session->destroy();
        }
        $this->response->redirect();
    }
}
