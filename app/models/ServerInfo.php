<?php

use Phalcon\Mvc\Model;

class ServerInfo extends Model
{
    public function initialize() {
        $this->hasMany('id', 'Bans', 'server_id');
        $this->hasMany('id', 'AdminServer', 'server_id');
    }

    protected $id;
    protected $timestamp;
    protected $hostname;
    protected $address;
    protected $gametype;
    public $rcon;
    protected $qb_version;
    public $reasons_id;

    public function getId() {
        return $this->id;
    }

    public function getTimeStamp() {
        return $this->timestamp;
    }

    public function getHostName() {
        return $this->hostname;
    }

    public function getAddress() {
        return $this->address;
    }

    public function getGameType() {
        return $this->gametype;
    }

    public function getQBVersion() {
        return $this->qb_version;
    }
}
