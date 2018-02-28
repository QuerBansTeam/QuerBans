<?php

class IndexController extends ControllerBase
{
    public function indexAction() {

        $config = Config::findFirst();
        $msgType = $this->dispatcher->hasParam('msgType') ? $this->dispatcher->getParam('msgType') : null;
        $msgContent = $this->dispatcher->hasParam('msgContent') ? $this->dispatcher->getParam('msgContent') : null;

        return $this->dispatcher->forward([
            "controller"    =>  $config->start_page,
            "action"        =>  'index',
            "params"        =>  [
                "msgType" => $msgType,
                "msgContent" => $msgContent,
            ],
        ]);
    }
}
