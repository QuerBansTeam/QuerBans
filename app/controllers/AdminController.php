<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class AdminController extends ControllerBase {

    public function beforeExecuteRoute($dispatcher) {
        $group = self::getGroup();
        if ($this->acl->isAllowed($group, 'general', 'acp')) {
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

    public function initialize() {
        $this->view->activePage = 'admin';
        $this->view->activePageAdmin = 'index';
    }

    public function indexAction() {
        $recomPhpVer = '7.2.0';
        $recomPhalconVer = '3.3.0';

        if ($this->dispatcher->hasParam('msgs')) {
            $this->view->msgs = $this->dispatcher->getParam('msgs');
        }

        $phpVer = $this->view->phpversion = phpversion();
        $phalconVer = $this->view->phalconversion = phpversion('phalcon');
        $this->view->gmploaded = extension_loaded('gmp') ? true : false;

        $okPHPver = false;
        if (version_compare($phpVer, $recomPhpVer) > -1) {
            $okPHPver = true;
        }
        $this->view->okPHPver = $okPHPver;

        $okPhalconVer = false;
        if (version_compare($phalconVer, $recomPhalconVer) > -1) {
            $okPhalconVer = true;
        }
        $this->view->okPhalconVer = $okPhalconVer;

        $this->view->recomPhpVer = $recomPhpVer;
        $this->view->recomPhalconVer = $recomPhalconVer;

        $allBans = Bans::find();
        $activeBansCount = 0;
        $unbannedCount = 0;
        $expiredBansCount = 0;

        foreach ($allBans as $ban) {

            if ($ban->unbanned)
            {
                $unbannedCount++;
                continue;
            }

            if (!$ban->length || $ban->length * 60 + $ban->created > time())
            {
                $activeBansCount++;
                continue;
            }

            $expiredBansCount++;
        }

        $this->view->allBansCount = count($allBans);
        $this->view->activeBansCount = $activeBansCount;
        $this->view->unbannedCount = $unbannedCount;
        $this->view->expiredBansCount = $expiredBansCount;
    }
}
