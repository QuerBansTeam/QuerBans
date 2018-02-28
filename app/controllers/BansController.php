<?php

use Phalcon\Mvc\Controller;
use Phalcon\Mvc\Model\Query\Builder;
use Phalcon\Paginator\Adapter\Model;
use Phalcon\Forms\Form;
use Phalcon\Forms\Element\Select;
use Phalcon\Forms\Element\Text;
use Phalcon\Forms\Element\TextArea;
use Phalcon\Forms\Element\Submit;
use Phalcon\Validation\Validator\PresenceOf;
use Phalcon\Validation\Validator\Callback;
use Phalcon\Validation\Validator\Regex as RegexValidator;

class BansController extends ControllerBase {
    private $currentPage;

    public function initialize() {
        $this->view->activePage = 'bans';
        $this->currentPage = $this->cookies->has('currentPage') ? $this->cookies->get('currentPage')->getValue() : 1;
    }

    public function afterExecuteRoute() {
        $this->view->msgType = $this->dispatcher->hasParam('msgType') ? $this->dispatcher->getParam('msgType') : null;
        $this->view->msgContent = $this->dispatcher->hasParam('msgContent') ? $this->dispatcher->getParam('msgContent') : null;
    }

    public function indexAction() {
        $qbConfig = Config::findFirst();

        $bans = Bans::find([
            "order" => 'id DESC',
        ]);

        $pageNum = (int)$this->dispatcher->getParam('page');

        $this->cookies->set('currentPage', $pageNum);

        $bansToDisplay = new Model([
            "data" => $bans,
            "limit" => $qbConfig->bans_per_page,
            "page" => $pageNum,
        ]);

        $page = $bansToDisplay->getPaginate();

        $bansForms = [];
        foreach($page->items as $ban) {
            $bansForms[] = new BanEditForm($ban);
        }

        $popoverContentTemplate = '<table class="table table-bordered table-sm table-responsive">
                                <tr>
                                    <td>
                                        <strong>Nickname</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Country</strong>
                                    </td>
                                    <td>
                                        %s <img src="/img/flags/%s.gif">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>SteamID</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>IP</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Reason</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Invoked on</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Expires on</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Banned by</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Banned on</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Map</strong>
                                    </td>
                                    <td>
                                        %s
                                    </td>
                                </tr>
                            </table>
                            %s %s %s';

        $this->view->popoverContentTemplate = $popoverContentTemplate;
        $this->view->page = $page;
        $this->view->pagesToDisplay = getAllowedToBeDisplayedPages($pageNum, 9, $page->last);
        $this->view->editForms = $bansForms;
    }

    public function deleteAction() {
        if ($this->request->isPost() && $this->security->checkToken()) {
            $banId = $this->dispatcher->getParam('banid');
            $ban = Bans::find([
                "id = $banId",
            ]);

            $msgType = 0;
            $msgContent = "Ban #$banId deleted!";

            if (!$ban) {
                $msgType = 1;
                $msgContent = 'Ban not found!';
            } else {
                if ($ban->delete() === false) {
                    $msgType = 1;
                    $msgContent = $ban->getMessages();
                }
            }
        }

        $this->dispatcher->forward([
            "controller" => 'bans',
            "action" => 'index',
            "params" => [
                "page" => $this->currentPage,
                "msgType" => $msgType,
                "msgContent" => $msgContent,
            ],
        ]);
    }

    public function unbanAction() {
        if ($this->request->isPost() && $this->security->checkToken()) {
            $banId = $this->dispatcher->getParam('banid');
            $ban = Bans::find([
                "id = $banId",
            ]);

            $msgType = 0;
            $msgContent = "Ban #$banId marked as unbanned!";

            if (!$ban) {
                $msgType = 1;
                $msgContent = 'Ban not found!';
            } else {
                $result = $ban->update([
                    "unbanned" => 1,
                ]);

                if (!$result) {
                    $msgType = 1;
                    $msgContent = $ban->getMessages();
                }

                /*$editInfo = new BansEdit();
                $editInfo->bid = $banId;
                $editInfo->time = time();
                $editInfo->admin_id = 1;
                $editInfo->reason = '';
                $editInfo->action = 'unban';

                $editInfo->save();*/
            }

        }

        $this->dispatcher->forward([
            "controller" => 'bans',
            "action" => 'index',
            "params" => [
                "page" => $this->currentPage,
                "msgType" => $msgType,
                "msgContent" => $msgContent,
            ],
        ]);
    }

    public function editAction() {
        if ($this->request->isPost() && $this->security->checkToken()) {
            $banId = $this->dispatcher->getParam('banid');
            $ban = Bans::find([
                "id = $banId",
            ]);

            $msgType = 0;
            $msgContent = "Ban #$banId has been successfully edited!";

            if (!$ban) {
                $msgType = 1;
                $msgContent = 'Ban not found!';
            } else {
                $results = $this->request->getPost();

                if ($this->request->getPost('ban')) {
                    $results["created"] = time();
                    $results["unbanned"] = 0;
                }

                if (!strlen($results['player_nick'])) {
                    $results['player_nick'] = null;
                }

                $result = $ban->update($results);

                if (!$result) {
                    $msgType = 1;
                    $messages = $ban->getMessages();
                }
            }
        }
        $this->dispatcher->forward([
            "controller" => 'bans',
            "action" => 'index',
            "params" => [
                "page" => $this->currentPage,
                "msgType" => $msgType,
                "msgContent" => $msgContent,
            ],
        ]);
    }

    public function validateAction() {
        $this->view->disable();

        $error = true;
        $fieldsNames = [];
        $validateMessages = [];

        if ($this->request->isPost() && $this->request->isAjax()) {

            $form = new BanEditForm();

            if ($form->isValid($this->request->getPost()) === true) {
                $error = false;
            } else {
                $messages = $form->getMessages();

                foreach ($messages as $message) {
                    $fieldName = $message->getField();

                    if ($fieldName === 'player_id') {
                        $fieldName = 'playerId';
                    } else if ($fieldName === 'player_ip') {
                        $fieldName = 'playerIp';
                    }

                    $fieldsNames[] = $fieldName;
                    $validateMessages[] = $message->getMessage();
                }
            }
        }
        echo json_encode([
            "error" => [
                "exist" => $error,
                "fields" => [
                    "name" => $fieldsNames,
                    "message" => $validateMessages
                ],
            ],
        ]);
    }
}

class BanEditForm extends Form
{
    private $banEntity;

    public function initialize($banEntity = null) {
        $this->banEntity = $banEntity;

        $this->add(self::createPlayerNameForm());
        $this->add(self::createPlayerIdForm());
        $this->add(self::createPlayerIpForm());
        $this->add(self::createReasonForm());
        $this->add(self::createTimeForm());
        $this->add(self::createEditReasonForm());

        $banButton = new Submit('Ban', [
            "id" => 'banButton' . ($this->banEntity ? $this->banEntity->getId() : ''),
            "name" => 'ban',
            "class" => 'btn btn-danger',
        ]);
        $submitButton = new Submit('Save', [
            "id" => 'saveButton' . ($this->banEntity ? $this->banEntity->getId() : ''),
            "name" => 'save',
            "class" => 'btn btn-primary',
        ]);

        $this->add($submitButton);
        $this->add($banButton);
    }

    private function createPlayerNameForm() {
        $playerNick = new Text('player_nick', [
            "id" => $this->banEntity ? 'playerNickEditModal' . $this->banEntity->getId() : '',
            "class" => 'form-control form-control-sm',
        ]);
        $playerNick->setLabel('Nick');

        $playerNick->setFilters([
            'string',
            'trim',
        ]);

        return $playerNick;
    }

    private function createPlayerIdForm() {
        $playerId = new Text('player_id', [
            "id" => $this->banEntity ? 'playerIdEditModal' . $this->banEntity->getId() : '',
            "class" => 'form-control form-control-sm',
        ]);
        $playerId->setLabel('SteamID');

        $playerId->addValidators([
            new RegexValidator([
                "pattern" => '/^STEAM_[0-5]:[0-1]:[0-9]{1,32}/',
                "message" => 'Invalid SteamID',
            ]),
        ]);

        $playerId->setFilters([
            'string',
            'trim',
        ]);

        return $playerId;
    }

    private function createPlayerIpForm() {
        $playerIp = new Text('player_ip', [
            "id" => $this->banEntity ? 'playerIpEditModal' . $this->banEntity->getId() : '',
            "class" => 'form-control form-control-sm',
        ]);
        $playerIp->setLabel('IP');

        $playerIp->addValidators([
            new Callback([
                "callback" => function($data) {
                    $ip = $data['player_ip'];
                    return IsValidIp($ip);
                },
                "message" => "Invalid IP address",
            ])
        ]);

        $playerIp->setFilters([
            'string',
            'trim',
        ]);

        return $playerIp;
    }

    private function createReasonForm() {
        $reason = new Text('reason', [
            "id" => $this->banEntity ? 'reasonEditModal' . $this->banEntity->getId() : '',
            "class" => 'form-control form-control-sm',
        ]);
        $reason->setLabel('Reason');

        $reason->addValidators([
            new PresenceOf([
                "message" => 'Ban\'s reason is required',
            ]),
        ]);

        $reason->setFilters([
            'trim',
            'string',
        ]);

        return $reason;
    }

    private function createTimeForm() {
        $length = new Text('length', [
            "id" => $this->banEntity ? 'lengthEditModal' . $this->banEntity->getId() : '',
            "class" => 'form-control form-control-sm',
        ]);
        $length->setLabel('Length');

        $length->addValidators([
            new PresenceOf([
                "message" => 'Ban\'s length is required',
            ]),
            new Callback([
                "callback" => function($data) {
                    $time = $data['length'];
                    if ($time === '-' || $time < 0) {
                        return false;
                    }
                    return true;
                },
                "message" => "Time cannot be negative",
            ]),
        ]);

        $length->setFilters([
            'int',
            'trim',
        ]);

        return $length;
    }

    private function createEditReasonForm() {
        $editReason = new TextArea('editReason', [
            "id" => $this->banEntity ? 'editReasonEditModal' . $this->banEntity->getId() : '',
            "class" => 'form-control form-control-sm',
        ]);
        $editReason->setLabel('Edit reason');

        $editReason->addValidators([
            new PresenceOf([
                "message" => 'Edit reason is required',
            ]),
        ]);

        $editReason->setFilters([
            'trim',
            'string',
        ]);

        return $editReason;
    }
}
