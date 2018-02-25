<?php

use Phalcon\Mvc\Model;

class Admins extends Model
{
    public function initialize() {
        $this->hasMany('id', 'BansEdit', 'admin_id');
        $this->hasMany('id', 'AdminServer', 'admin_id');

        $this->belongsTo('groupid', 'Groups', 'id', [
            "alias" =>  'group',
        ]);
    }

    protected $id;
    public $username;
    public $password;
    public $groupid;
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
