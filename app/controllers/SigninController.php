<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class SigninController extends ControllerBase {

    public function initialize() {
        $this->view->activePage = 'signin';
    }

    public function indexAction() {

    }

    public function loginAction() {
        if ($this->request->isPost()) {
            $login = $this->request->getPost('login');
            $password = $this->request->getPost('password');

            $user = Admins::findFirst([
                "username = '$login'",
            ]);

            if ($user) {
                if ($this->security->checkHash($password, $user->password)) {

                    // Generate session ID
                    $ipAddress = $this->request->getClientAddress();
                    $sessionId = hash('sha3-224', microtime() . $ipAddress);

                    // Setup session
                    $this->session->set('id', $sessionId);
                    $this->session->set('username', $user->username);

                    $user->sessionkey = $sessionId;
                    $user->logged_ip = $ipAddress;
                    $user->save();
                    $this->response->redirect();
                    return;
                }
            } else {
                $this->security->hash(rand());
            }
        }
        $this->dispatcher->forward([
            "controller" => 'signin',
            "action" => 'index',
            "params" => [
                "failed" => 1,
            ]
        ]);
    }

    public function logoutAction() {
        $this->view->disable();

        if ($this->session->has('id')) {
            $this->session->destroy();
        }
        $this->response->redirect();
    }
}
