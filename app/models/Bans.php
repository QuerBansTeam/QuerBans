<?php

use Phalcon\Mvc\Model;

class Bans extends Model
{
    public function initialize() {
        $this->belongsTo('server_id', 'ServerInfo', 'id', [
            "alias" => "server",
        ]);

        $this->hasMany('id', 'BansEdit', 'bid');
    }

    protected $id;
    public $player_id;
    public $server_id;
    public $player_ip;
    public $player_nick;
    protected $admin_ip;
    protected $admin_id;
    protected $admin_nick;
    public $reason;
    protected $created;
    public $length;
    protected $map;
    public $unbanned;

    public function getId() {
        return $this->id;
    }

    public function getAdminIp() {
        return $this->admin_ip;
    }

    public function getAdminId() {
        return $this->admin_id;
    }

    public function getAdminNick() {
        return $this->admin_nick;
    }

    public function getCreatedTime() {
        return $this->created;
    }

    public function getMapName() {
        return $this->map;
    }
}
