<?php

use Phalcon\Mvc\Model;

class Admins extends Model
{
    public function initialize() {
        $this->hasMany('id', 'BansEdit', 'admin_id');
        $this->hasMany('id', 'AdminServer', 'admin_id');
    }

    protected $id;
    public $username;
    public $password;
    public $groupname;
    public $email;
    public $srv_access;
    public $flags;
    public $steamid;
    public $created;
    public $sessionkey;
    public $logged_ip;

    public function getId() {
        return $this->id;
    }
}
