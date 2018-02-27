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
            throw new Exception('Invalid IP address');
        }

        $this->_socket = @socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);

        if ($this->_socket === false) {
            throw new Exception('Cannot create socket: ' . socket_strerror(socket_last_error()));
        }

        socket_connect($this->_socket, $ip, $port);
        socket_set_option($this->_socket, SOL_SOCKET, SO_RCVTIMEO, [
            "sec" => 3,
            "usec" => 0,
        ]);
    }

    function __destruct() {
        if ($this->_socket !== false) {
            socket_close($this->_socket);
        }
    }

    public function getServerInfo() : array {
        socket_write($this->_socket, pack('ccccca*', 0xFF, 0xFF, 0xFF, 0xFF, self::A2S_INFO, "Source Engine Query\0"));
        $this->_recievedLen = @socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);
        $this->_currentPos = 0;

        if (!$this->_recievedLen) {
            throw new Exception('Server Info: Server timeout');
        }

        $this->_implodePacketsPayloadsIfSplitted();

        $header = $this->_getByte();

        /* omit 47 protocol respond and try to read 48's one instead */
        if ($header === 0x6D) {
            $this->_recievedLen = @socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);
            $this->_currentPos = 0;

            $this->_implodePacketsPayloadsIfSplitted();
            $header = $this->_getByte();
        }

        if ($header !== 0x49) {
            throw new Exception('Server info: Header mismatch');
        }

        $serverInfo = [];
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

        return $serverInfo;
    }

    public function getPlayers() : array {
        $challengeNumber = $this->_getChallengeNumber(self::A2S_PLAYER);
        if ($challengeNumber !== -1) {
            socket_write($this->_socket, pack('cccccl', 0xFF, 0xFF, 0xFF, 0xFF, self::A2S_PLAYER, $challengeNumber));
            $this->_recievedLen = @socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);
        }
        $this->_currentPos = 0;

        if (!$this->_recievedLen) {
            throw new Exception('Server timeout');
        }

        $this->_implodePacketsPayloadsIfSplitted();

        $playersInfo = [];
        if ($this->_getByte() !== 0x44) {
            throw new Exception('Server players: Header mismatch');
        }
        $playersNum = $playersInfo['playersnum'] = $this->_getByte();

        if ($playersNum) {
            for ($i = 0; $i < $playersNum; $i++) {
                $playersInfo['players'][$i]['id'] = $this->_getByte(); //Seems to be always 0
                $playersInfo['players'][$i]['name'] = $this->_getString();
                $playersInfo['players'][$i]['score'] = $this->_getLong();
                $playersInfo['players'][$i]['time'] = round($this->_getFloat(), 0, PHP_ROUND_HALF_DOWN);
            }
        }
        return $playersInfo;
    }

    public function getRules() : array {
        $challengeNumber = $this->_getChallengeNumber(self::A2S_RULES);
        if ($challengeNumber !== -1) {
            socket_write($this->_socket, pack('cccccl', 0xFF, 0xFF, 0xFF, 0xFF, self::A2S_RULES, $challengeNumber));
            $this->_recievedLen = @socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);
        }
        $this->_currentPos = 0;

        if (!$this->_recievedLen) {
            throw new Exception('Server timeout');
        }

        $this->_implodePacketsPayloadsIfSplitted();

        $rulesInfo = [];
        if ($this->_getByte() !== 0x45) {
            throw new Exception('Server rules: Header mismatch');
        }
        $rulesNum = $rulesInfo['rulesnum'] = $this->_getShort();

        if ($rulesNum) {
            for ($i = 0; $i < $rulesNum; $i++) {
                $rulesInfo['rules'][$this->_getString()] = $this->_getString();
            }
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
        $this->_recievedLen = @socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);

        if (!$this->_recievedLen) {
            throw new Exception('Server timeout');
        }

        /* Server gave full respond instead of giving challenge number
         * when packet is splitted (-2) or packet is not splitted (-1)
         * with header 'E' for rules
         * with header 'D' for players list
         */
        if ($this->_getLong() === -2) {
            return -1;
        }

        $header = $this->_getByte();

        if ($header === 0x41) {
            $challengeNumber = $this->_getLong();
        } else if ($header === 0x45 || $header === 0x44) /* Got rules or players list */ {
            $challengeNumber = -1;
        } else {
            throw new Exception('Get challenge: Header mismatch');
        }

        return $challengeNumber;
    }

    private function _implodePacketsPayloadsIfSplitted() : void {
        if ($this->_getLong() === -2) {

            $requestId = $this->_getLong();

            $packetNumber = $this->_getByte();
            $packetsNum = $packetNumber & 0xF;
            $packetPayLoad[$packetNumber >> 4] = $this->_getAll();
            $packetRecieved = 1;

            // Get rest of the packets
            while ($packetRecieved < $packetsNum) {
                $this->_currentPos = 0;
                $this->_recievedLen = @socket_recv($this->_socket, $this->_buffer, self::PACKET_SIZE, MSG_OOB);

                if (!$this->_recievedLen) {
                    throw new Exception('Server timeout');
                }

                //Skip non splitted packet
                if ($this->_getLong() !== -2) {
                    continue;
                }

                if ($this->_getLong() === $requestId) {
                    $packetPayLoad[$this->_getByte() >> 4] = $this->_getAll();
                    $packetRecieved++;
                }
            }
            $this->_buffer = implode($packetPayLoad);
            $this->_recievedLen = strlen($this->_buffer);
            $this->_currentPos = 0;
            //Omits header which says that packets is not splitted
            $this->_getLong();
        }
    }
}
