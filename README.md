# QuerBans [![License](https://img.shields.io/badge/License-GPLv3-brightgreen.svg?style=flat-square)](LICENSE)
Ban system for Half-Life 1 based games

## About

QuerBans is a ban system for Half-Life 1 based games. It is compatible with PHP7+ and built using [Phalcon Framework](https://github.com/phalcon/cphalcon) for backend and [Bootstrap](https://github.com/twbs/bootstrap) and [JQuery ](https://github.com/jquery/jquery) for frontend.

## Motivation

Main goal is to provide replacement for [AMXBans](https://bitbucket.org/yamikaitou/amxbans) which its development is stagnant and it is not compatible with PHP7+. QuerBans focuses on having more readable code base by using framework and providing modern look for end users.

## Supported games & protocols
- Games
    - Half-Life
    - Counter-Strike
    - Day of Defeat
    - Counter-Strike: Condition Zero
    - Team Fortress Classic
    - Sven Coop
- Protocols
    - Protocol 48 (any older will not be supported)

## Design
### Bans page
![Bans page](https://screenshotscdn.firefoxusercontent.com/images/2050bfc6-1a86-4042-9908-17ea9884d263.png)
### Bans page (quick view)
![Bans page quick view](https://screenshotscdn.firefoxusercontent.com/images/234b3729-2a63-4067-a141-f2646e78600c.png)
### Servers view
![Servers](https://screenshotscdn.firefoxusercontent.com/images/c3478178-b78c-4b90-876f-63099217b39c.png)

## Requirements
- Phalcon Framework
    - version 3.3.2 or any later
- PHP
    - 7.0.0 or any later
- GMP module
    - only 32 bit PHP installations
- Sockets module
- SQL server
    - MariaDB
    - MySQL

## Installing

*Coming soon*

## License

Querbans is licensed under the General Public License version 3 - see the [LICENSE](LICENSE) file for details.
