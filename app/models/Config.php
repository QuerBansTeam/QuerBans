<?php

use Phalcon\Mvc\Model;

class Config extends Model
{
    protected $id;
    public $cookie;
    public $bans_per_page;
    public $banner;
    public $banner_url;
    public $default_lang;
    public $start_page;
    public $steam_web_key;
}
