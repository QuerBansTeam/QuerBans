<?php

use GeoIp2\Database\Reader;

function sec_to_str(int $duration) : string  {
    $periods = [
        'day' => 86400,
        'hour' => 3600,
        'minute' => 60,
        'second' => 1,
    ];

    $parts = [];

    foreach ($periods as $name => $dur) {
        $div = floor($duration / $dur);

        if (!$div) {
            continue;
        } else {
            $parts[] = "$div $name" . (($div != 1) ? 's' : '');
        }

        $duration %= $dur;
    }

    $last = array_pop($parts);

    if (empty($parts)) {
        return $last;
    } else {
        return join(', ', $parts) . " and $last";
    }
}

function getCountryIsoCode(string $ip) : string {

    if (strlen($ip) === 0) {
        return 'clear';
    }

    global $application;
    $libraryDir = $application->getDi()->getConfig()->application->libraryDir;

    $reader = new Reader($libraryDir . 'GeoLite2-Country.mmdb');

    $iso = '';
    try {
        $record = $reader->country($ip);
        if ($record) {
            $iso = $record->country->isoCode;
        }
    } catch(Exception $e) {
        $iso = 'clear';
    }

    $reader->close();

    return strtolower($iso);
}

function getCountryName(string $ip) : string {

    if (strlen($ip) === 0) {
        return 'Unknown';
    }

    global $application;
    $libraryDir = $application->getDi()->getConfig()->application->libraryDir;

    $reader = new Reader($libraryDir . 'GeoLite2-Country.mmdb');

    $name = 'Unknown';
    try {
        $record = $reader->country($ip);
        if ($record) {
            $name = $record->country->name;
        }
    } catch(Exception $e) {
        $name = 'Unknown';
    }
    $reader->close();

    return strtolower($name);
}

function getAllowedToBeDisplayedPages(int $start_page, int $pages_allow, int $last_page) : array {
    $pagesToDisplay[] = $start_page;

    $left = $right = $pages_allow / 2;

    if ($start_page - $left < 0) {
        $right += abs($start_page - $left);
        //Result is negative, so it's actually subtraction
        $left += $start_page - $left;
    }

    if ($start_page + $right > $last_page) {
        $left += $start_page + $right - $last_page;
        $right = $last_page - $start_page;
    }

    for ($i = $start_page + 1; $i <= $start_page + $right; ++$i) {
        $pagesToDisplay[] = $i;
    }

    for ($i = $start_page - 1; $i >= $start_page - $left; --$i) {
        $pagesToDisplay[] = $i;
    }

    return $pagesToDisplay;
}

function SteamID2ToSteamID64(string $steamid2) : string {
    $steamIdParts = explode(':', $steamid2);
    //https://developer.valvesoftware.com/wiki/SteamID
    if (PHP_INT_SIZE == 8) {
        return strval($steamIdParts[2] * 2 + 0x0110000100000000 + $steamIdParts[1]);
    } else {
        $result = gmp_mul($steamIdParts[2], 2);
        $result = gmp_add($result, '0x0110000100000000');
        $result = gmp_add($result, $steamIdParts[1]);
        return gmp_strval($result);
    }
}

function CheckSteamIds(array $ids) : string {
    $steamIds = implode(',', $ids);

    $curlHandle = curl_init();
    curl_setopt($curlHandle, CURLOPT_URL, 'https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' . Config::findFirst()->steam_web_key . '&steamids=' . $steamIds);
    curl_setopt($curlHandle, CURLOPT_RETURNTRANSFER, true);
    $curlData = curl_exec($curlHandle);
    curl_close($curlHandle);

    return $curlData;
}

function IsValidIp(string $ip) : bool {
    if (!strlen($ip)) {
        return false;
    }
    $ipParts = explode('.', $ip);

    if (count($ipParts) != 4) {
        return false;
    }

    $ipPos = 0;

    foreach ($ipParts as $value) {
        if (!strlen($value) || ($value[0] === '0' && $ipPos === 0) || intval($value) < 0 || intval($value) > 255) {
            return false;
        }
        ++$ipPos;
    }
    return true;
}

function Is32Bit() : bool {
    return PHP_INT_SIZE === 4;
}
