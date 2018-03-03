<?php

use Phalcon\Mvc\Model;

class Groups extends Model
{
    public function initialize() {
        $this->hasMany('id', 'Admins', 'groupid');
    }

    protected $id;
    public $name;
    public $access_acp;
    public $show_ip;

    public function getId() {
        return $this->id;
    }
}
