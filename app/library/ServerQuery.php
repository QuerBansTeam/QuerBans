<?php

class ServerQuery {

    private $_socket;
    private $_buffer;
    private $_recievedLen;
    private $_currentPos;

    const A2S_INFO = 0x54;
    const A2S_PLAYER = 0x55;
    const A2S_RULES = 0x56;
    const PACKET_SIZE = 1400;

    function __construct(string $ip, int $port) {
        if (!IsValidIp($ip)) {
            throw new Exception('IP is not valid');
        }

        $this->_socket = @socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);

        if ($this->_socket === false) {
            throw new Exception('Cannot create socket: ' . socket_strerror(socket_last_error()));
        }

        socket_connect($this->_socket, $ip, $port);
    }

    function __destruct() {
        if ($this->_socket !== false) {
            socket_close($this->_socket);
        }
    }

    public function getServerInfo() : array {
        socket_write($this->_socket, pack('ccccca*', 0xFF, 0xFF, 0xFF, 0xFF, 0x54, 'Source Engine Query'));
        $this->_recievedLen = socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);
        $this->_currentPos = 0;

        $this->_implodePacketsPayloadsIfSplitted();

        $serverInfo = [];
        try {
            if ($this->_getByte() !== 0x49) {
                throw new Exception(chr($header));
            }
            $serverInfo['protocol'] = $this->_getByte();
            $serverInfo['name'] = $this->_getString();
            $serverInfo['map'] = $this->_getString();
            $serverInfo['folder'] = $this->_getString();
            $serverInfo['game'] = $this->_getString();
            $serverInfo['gameid'] = $this->_getShort();
            $serverInfo['players'] = $this->_getByte();
            $serverInfo['maxplayers'] = $this->_getByte();
            $serverInfo['bots'] = $this->_getByte();
            $serverInfo['type'] = chr($this->_getByte());
            $serverInfo['os'] = chr($this->_getByte());
            $serverInfo['password'] = $this->_getByte();
            $serverInfo['vac'] = $this->_getByte();
            $serverInfo['version'] = $this->_getString();

            if ($this->_currentPos < $this->_recievedLen) {
                $edf = $this->_getByte();

                if ($edf & 0x80) {
                    $serverInfo['port'] = $this->_getShort();
                }
            }

        } catch (Exception $e) {
            $serverInfo['error'] = $e->getMessage();
        }

        return $serverInfo;
    }

    public function getPlayers() : array {
        $challengeNumber = $this->_getChallengeNumber(self::A2S_PLAYER);
        socket_write($this->_socket, pack('cccccl', 0xFF, 0xFF, 0xFF, 0xFF, self::A2S_PLAYER, $challengeNumber));
        $this->_recievedLen = socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);
        $this->_currentPos = 0;

        $this->_implodePacketsPayloadsIfSplitted();

        $playersInfo = [];
        try {
            if ($this->_getByte() !== 0x44) {
                throw new Exception('Header mismatch');
            }
            $playersNum = $playersInfo['playersnum'] = $this->_getByte();

            if ($playersNum) {
                for ($i = 0; $i < $playersNum; $i++) {
                    $playerId = $this->_getByte();
                    $playersInfo['players'][$playerId]['name'] = $this->_getString();
                    $playersInfo['players'][$playerId]['score'] = $this->_getLong();
                    $playersInfo['players'][$playerId]['time'] = round($this->_getFloat(), 0, PHP_ROUND_HALF_DOWN);
                }
            }
        } catch (Exception $e) {
            $playersInfo['error'] = $e->getMessage();
        }
        return $playersInfo;
    }

    public function getRules() : array {
        $challengeNumber = $this->_getChallengeNumber(self::A2S_RULES);
        socket_write($this->_socket, pack('cccccl', 0xFF, 0xFF, 0xFF, 0xFF, self::A2S_RULES, $challengeNumber));
        $this->_recievedLen = socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);
        $this->_currentPos = 0;

        $this->_implodePacketsPayloadsIfSplitted();

        $rulesInfo = [];
        try {
            if ($this->_getByte() !== 0x45) {
                throw new Exception('Header mismatch');
            }
            $rulesNum = $rulesInfo['rulesnum'] = $this->_getShort();

            if ($rulesNum) {
                for ($i = 0; $i < $rulesNum; $i++) {
                    $rulesInfo['rules'][$this->_getString()] = $this->_getString();
                }
            }
        } catch (Exception $e) {
            $rulesInfo['error'] = $e->getMessage();
        }
        return $rulesInfo;
    }

    private function _getByte() : int {
        if ($this->_currentPos + 1 > $this->_recievedLen) {
            throw new Exception('Exceeded packet length');
        }

        $toUnpack = substr($this->_buffer, $this->_currentPos, 1);
        $result = unpack('c', $toUnpack)[1];
        ++$this->_currentPos;

        return $result;
    }

    private function _getFloat() : float {
        if ($this->_currentPos + 4 > $this->_recievedLen) {
            throw new Exception('Exceeded packet length');
        }

        $toUnpack = substr($this->_buffer, $this->_currentPos, 4);
        $result = unpack('f', $toUnpack)[1];
        $this->_currentPos += 4;

        return $result;
    }

    private function _getLong() : int {
        if ($this->_currentPos + 4 > $this->_recievedLen) {
            throw new Exception('Exceeded packet length');
        }

        $toUnpack = substr($this->_buffer, $this->_currentPos, 4);
        $result = unpack('l', $toUnpack)[1];
        $this->_currentPos += 4;

        return $result;
    }

    private function _getString() : string {
        if ($this->_currentPos + 1 > $this->_recievedLen) {
            throw new Exception('Exceeded packet length');
        }

        $nullPos = strpos($this->_buffer, 0x0, $this->_currentPos);
        $toUnpack = substr($this->_buffer, $this->_currentPos, $nullPos - $this->_currentPos);
        $result = unpack('a*', $toUnpack)[1];

        $this->_currentPos += $nullPos - $this->_currentPos + 1;

        return $result;
    }

    private function _getShort() : int {
        if ($this->_currentPos + 2 > $this->_recievedLen) {
            throw new Exception('Exceeded packet length');
        }

        $toUnpack = substr($this->_buffer, $this->_currentPos, 2);
        $result = unpack('s', $toUnpack)[1];
        $this->_currentPos += 2;

        return $result;
    }

    private function _getAll() : string {
        return substr($this->_buffer, $this->_currentPos, $this->_recievedLen);
    }

    private function _getChallengeNumber(int $request) : int {
        socket_write($this->_socket, pack('cccccl', 0xFF, 0xFF, 0xFF, 0xFF, $request, -1));

        $challengeNumber = $this->_currentPos = 0;
        $this->_recievedLen = socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);

        if ($this->_getLong() === -1) {
            if ($this->_getByte() === 0x41) {
                $challengeNumber = $this->_getLong();
            } else {
                throw new Exception('Header mismatch');
            }
        } else {
            throw new Exception('Challenge number packet response is splitted');
        }

        return $challengeNumber;
    }

    private function _implodePacketsPayloadsIfSplitted() : void {
        if ($this->_getLong() === -2) {
            // Unique packet's id, useful?
            $this->_getLong();

            $packetNumber = $this->_getByte();
            $packetsNum = $packetNumber & 0xF;
            $packetPayLoad[$packetNumber >> 4] = $this->_getAll();
            $packetRecieved = 1;

            // Get rest of the packets
            while ($packetRecieved < $packetsNum) {
                $this->_currentPos = 0;
                $this->_recievedLen = socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);

                // TODO: Check for split?
                $this->_getLong();
                // Unique packet's id, useful?
                $this->_getLong();

                $packetPayLoad[$this->_getByte() >> 4] = $this->_getAll();
                $packetRecieved++;
            }
            $this->_buffer = implode($packetPayLoad);
            $this->_recievedLen = strlen($this->_buffer);
            $this->_currentPos = 0;
            //Omits header which says that packets is not splitted
            $this->_getLong();
        }
    }
}
