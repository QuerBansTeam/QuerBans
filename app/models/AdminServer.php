<?php

use Phalcon\Mvc\Model;

class AdminServer extends Model
{
    public function initialize() {
        $this->belongsTo('admin_id', 'Admins', 'id', [
            "alias" => 'admin',
        ]);
        $this->belongsTo('server_id', 'ServerInfo', 'id', [
            "alias" => 'server',
        ]);
    }

    protected $id;
    public $admin_id;
    public $server_id;
    public $custom_flags;
    public $static_bantime;
    public $show_admin;
    public $created;
    public $expired;

    public function getId() {
        return $this->id;
    }
}
