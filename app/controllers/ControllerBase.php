<?php

use Phalcon\Mvc\Controller;

class ControllerBase extends Controller
{
    protected function getGroup() : string {
        if (!$this->session->has('group')) {
            $this->session->set('group', 'guest');
            return 'guest';
        }
        return $this->session->get('group');
    }
}
