<?php

class IndexController extends ControllerBase
{
    public function indexAction() {

        $config = Config::findFirst();
        return $this->dispatcher->forward(
            [
                "controller"    =>  $config->start_page,
                "action"        =>  'index',
            ]
        );
    }
}
