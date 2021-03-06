<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class SigninController extends ControllerBase {

    public function initialize() {
        $this->view->activePage = 'signin';
    }

    public function indexAction() {
        if ($this->dispatcher->hasParam('msgs')) {
            $this->view->msgs = $this->dispatcher->getParam('msgs');
        }
    }

    public function loginAction() {
        $msgs[0]["dismiss"] = true;

        /* User is currently logged in */
        if ($this->session->has('id')) {
            $msgs[0]["type"] = 1;
            $msgs[0]["content"] = 'You are currently logged in!';

            return $this->dispatcher->forward([
                "controller" => 'index',
                "action" => 'index',
                "params" => [
                    "msgs" => $msgs,
                ],
            ]);
        }

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
                    $this->session->set('group', $user->groupname);

                    $user->update([
                        "sessionkey" => $sessionId,
                        "logged_ip" => $ipAddress,
                    ]);

                    $msgs[0]["type"] = 0;
                    $msgs[0]["content"] = 'You have been logged in successfully!';
                    $msgs[0]["dismiss"] = true;

                    return $this->dispatcher->forward([
                        "controller" => 'index',
                        "action" => 'index',
                        "params" => [
                            "msgs" => $msgs,
                        ],
                    ]);
                }
            } else {
                $this->security->hash(rand());
            }
        }

        $msgs[0]["type"] = 1;
        $msgs[0]["content"] = 'Login failed!';

        return $this->dispatcher->forward([
            "controller" => 'signin',
            "action" => 'index',
            "params" => [
                "msgs" => $msgs,
            ],
        ]);
    }

    public function logoutAction() {
        $msgs[0]["dismiss"] = true;

        if (!$this->session->has('id')) {
            $msgs[0]["type"] = 1;
            $msgs[0]["content"] = 'You are currently logged out!';

            return $this->dispatcher->forward([
                "controller" => 'index',
                "action" => 'index',
                "params" => [
                    "msgs" => $msgs,
                ],
            ]);
        }

        /*
         * Destroy session
         */
        $this->session->destroy();
        $_SESSION = [];
        $this->session->set('groupname', 'guest');

        $msgs[0]["type"] = 0;
        $msgs[0]["content"] = 'You have been logged out successfully!';

        return $this->dispatcher->forward([
            "controller" => 'index',
            "action" => 'index',
            "params" => [
                "msgs" => $msgs,
            ],
        ]);

    }
}
