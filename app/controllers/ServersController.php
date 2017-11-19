<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class ServersController extends ControllerBase {

    public function initialize() {
        $this->view->activePage = 'servers';
        $this->view->pageTitle = 'Server List';
    }

    public function indexAction() {
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

            $portPos = strpos($ip, ':');
            try {
                $ServerInfo = new ServerQuery(substr($ip, 0, $portPos), intval(substr($ip, $portPos + 1)));
                echo json_encode([
                    "server" => $ServerInfo->getServerInfo(),
                    "players" => $ServerInfo->getPlayers(),
                    "rules" => $ServerInfo->getRules(),
                ]);
            } catch(Exception $e) {
                echo json_encode([
                    "error" => $e->getMessage(),
                ]);
            }
        }
    }
}
