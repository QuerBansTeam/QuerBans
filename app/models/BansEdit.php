<?php

use Phalcon\Mvc\Model;

class BansEdit extends Model
{
    public function initialize() {
        $this->belongsTo('bid', 'Bans', 'id', [
            "alias" =>  'ban',
        ]);
        $this->belongsTo('admin_id', 'Admins', 'id', [
            "alias" => 'admin',
        ]);

        //$this->belongsTo('admin_id', 'Admins')
    }

    protected $id;
    public $bid;
    public $time;
    public $admin_id;
    public $reason;
    public $action;

    public function getId() {
        return $this->id;
    }
}
