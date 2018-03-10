<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class ServersController extends ControllerBase {

    public function initialize() {
        $this->view->activePage = 'servers';
    }

    public function beforeExecuteRoute($dispatcher) {
        $group = self::getGroup();
        if ($this->acl->isAllowed($group, 'Servers', $dispatcher->getActionName())) {
            return true;
        }

        $msgs[0]["type"] = 1;
        $msgs[0]["content"] = 'You don\'t have access to that!';
        $msgs[0]["dismiss"] = 0;

        $this->dispatcher->forward([
            'controller' => 'index',
            'action' => 'index',
            'params' => [
                'msgs' => $msgs,
            ],
        ]);

        return false;
    }

    public function indexAction() {
        if ($this->dispatcher->hasParam('msgs')) {
            $this->view->msgs = $this->dispatcher->getParam('msgs');
        }

        $serversEntries = ServerInfo::find();
        $serversIps = [];

        foreach ($serversEntries as $server) {
            $serversIps[] = $server->address;
        }

        $this->view->ipArray = $serversIps;
    }

    public function getAction() {
        $this->view->disable();

        if ($this->request->isPost() && $this->request->isAjax() && $this->security->checkToken(null, null, false)) {
            $ip = $this->request->getPost('ip');
            $type = $this->request->getPost('type', null, 0x7);

            $portPos = strpos($ip, ':');
            try {
                $ServerInfo = new ServerQuery(substr($ip, 0, $portPos), intval(substr($ip, $portPos + 1)));
                return $this->response->setJsonContent([
                    "server" => ($type & 0x01) ? $ServerInfo->getServerInfo() : [],
                    "players" => ($type & 0x02) ? $ServerInfo->getPlayers() : [],
                    "rules" => ($type & 0x04) ? $ServerInfo->getRules() : [],
                ]);
            } catch(Exception $e) {
                $error = $e->getMessage();
                if (strpos($error, 'Header mismatch') !== false) {
                    $error = "Unsupported reply format: $ip";
                } else if (strpos($error, 'Server timeout') !== false) {
                    $error = "Server timeout: $ip";
                }

                return $this->response->setJsonContent([
                    "error" => $error,
                ]);
            }
        }
    }
}
