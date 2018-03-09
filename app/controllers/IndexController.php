<?php

class IndexController extends ControllerBase
{
    public function indexAction() {

        // Set default group
        self::getGroup();

        $config = Config::findFirst();

        if ($this->dispatcher->hasParam('msgs')) {
            return $this->dispatcher->forward([
                "controller"    =>  $config->start_page,
                "action"        =>  'index',
                "params"        =>  [
                    "msgs" => $this->dispatcher->getParam('msgs'),
                ],
            ]);
        } else {
            return $this->dispatcher->forward([
                "controller"    =>  $config->start_page,
                "action"        =>  'index',
            ]);
        }
    }
}
