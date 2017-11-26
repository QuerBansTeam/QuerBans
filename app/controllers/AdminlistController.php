<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;

class AdminlistController extends ControllerBase {

    public function initialize() {
        $this->view->activePage = 'adminlist';
        $this->view->pageTitle = 'Admin list';
    }

    public function indexAction() {
        $steamIdsToCheck = [];
        $serversArray = [];

        $adminsToServers = AdminServer::find([
            "order" => 'server_id ASC',
        ]);

        $fieldsNames = ['personaname', 'personastate', 'profileurl', 'avatarfull', 'communityvisibilitystate'];

        $defaultSteamAvatar = 'https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg';

        foreach ($adminsToServers as $adminToServer) {
            if (!$adminToServer->show_admin) {
                continue;
            }

            if ($adminToServer->server === false) {
                continue;
            }

            $steamId = $adminToServer->admin->steamid;
            if ($steamId) {
                $steamId64 = SteamID2ToSteamID64($steamId);
            } else {
                $steamId64 = 0;
            }

            if ($steamId64 && !in_array($steamId64, $steamIdsToCheck, true)) {
                $steamIdsToCheck[] = $steamId64;
            }

            $serverId = $adminToServer->server->getId();
            $adminId = $adminToServer->admin->getId();
            $serversArray[$serverId]['hostname'] = $adminToServer->server->hostname;

            $serversArray[$serverId]['admins'][$adminId]['personaname'] = $adminToServer->admin->username;
            $serversArray[$serverId]['admins'][$adminId]['personastate'] = -1;
            $serversArray[$serverId]['admins'][$adminId]['profileurl'] = null;
            $serversArray[$serverId]['admins'][$adminId]['avatarfull'] = $defaultSteamAvatar;
            $serversArray[$serverId]['admins'][$adminId]['steamid'] = $steamId64;
        }

        $data = json_decode(CheckSteamIds($steamIdsToCheck));

        foreach ($data->response->players as $player) {
            foreach ($serversArray as &$server) {
                ksort($server['admins'], SORT_NUMERIC);
                foreach ($server['admins'] as &$admin) {
                    if (in_array($player->steamid, $admin, true)) {
                        foreach ($fieldsNames as $value) {
                            $admin[$value] = $player->$value;
                        }
                        unset($admin);
                        break;
                    }
                    unset($admin);
                }
                unset($server);
            }
        }
        $this->view->serversList = $serversArray;
        $this->view->statusNames = ['Offline', 'Online', 'Busy', 'Away', 'Snooze', 'Looking to trade', 'Looking to play'];
    }
}
