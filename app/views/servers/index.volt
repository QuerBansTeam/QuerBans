{% extends 'layout.volt' %}

{% block title %}
    Servers list
{% endblock %}

{% block style %}

    td > img
    {
        width: 45px;
        height: 45px;
    }

    .fa-spinner
    {
        font-size: 34px;
    }

    .table td, .table th
    {
        padding: .25rem;
    }

    .max-lines
    {
        text-overflow: ellipsis;
        word-wrap: break-word;
        overflow: hidden;
    }

    .spanHost
    {
        display: inline-block;
        line-height: 1.2rem;
        height: 2.4rem;
        overflow: hidden;
    }

    .modalField
    {
        font-weight: bold;
    }

    .vacEnabled
    {
        color: green;
    }

    .vacDisabled
    {
        color: red;
    }

{% endblock %}

{% block script %}

function getInfo(address, id) {
    $.ajax({
        'url': '{{ url("servers/get") }}',
        'method': 'POST',
        'data': { ip : address, {{ this.security.getTokenKey() }} : '{{ this.security.getToken() }}' },
        'dataType': 'json',
    }).done(function(data) {
        console.log(data);

        var timeout = false;

        var idArr = ['game', 'vac', 'os', 'pass', 'host', 'players', 'btn'];
        var dataArr = [];

        var baseDir = "{{ url('img/') }}";

        if (typeof data.error !== 'undefined') {
            timeout = true;
            $('#row' + id).addClass('table-danger');
        } else {
            $('#row' + id).removeClass('table-danger');
            var vacImg = (data.server.vac) ? 'vac_fill' : 'no_vac_fill';
            var osImg;
            var passImg = (data.server.password) ? 'lock_fill' : 'unlock_fill';

            switch(data.server.os) {
                case 'l':
                    osImg = 'linux_fill';
                    break;
                case 'w':
                    osImg = 'windows_fill';
                    break;
                default:
                    osImg = 'apple_fill';
            }

            dataArr["game"] = '<img src="' + baseDir + 'games/' + data.server.folder + '.png">';
            dataArr["vac"] = '<img src="' + baseDir + 'VAC/' + vacImg + '.png">';
            dataArr["os"] = '<img src="' + baseDir + 'OS/' + osImg + '.png">';
            dataArr["pass"] = '<img src="' + baseDir + 'custom/' + passImg + '.png">';
            dataArr["host"] = data.server.name;
            dataArr["players"] = data.server.players + '/' + data.server.maxplayers;
            $('#btn' + id).html('<button type="button" class="btn btn-primary" data-id="' + address + '" data-toggle="modal" data-target="#infoModal">Show</button>');
        }

        idArr.forEach(function(value) {
            $('#' + value + id).html(timeout ? '' : dataArr[value]);

            if (value === 'host') {
                timeout ? $('#' + value + id).html('<b>' + data.error + '</b>') : $('#' + value + id).attr('data-original-title', dataArr[value]);
            }
        });

    });
}

function secToHour(secs) {
    var periods = [ 3600, 60, 1 ];
    var parts = [0, 0, 0];

    periods.forEach(function(dur, index) {
        var div = Math.floor(secs / dur);

        if (!div) {
            parts[index] = '00';
            return;
        }
        else
            parts[index] = ((div < 10) ? '0' + div : div);
        secs %= dur;
    });

    return parts.join(':');
}

function updateModal(address) {

    $('#labelModal').html('Loading server info... <i class="fa fa-spinner fa-spin"></i>');
    $('#modalServerIpField').html(address);
    $('#modalMapField').html('');
    $('#modalNextMapField').html('');
    $('#modalGameField').html('');
    $('#modalPlayersField').html('');
    $('#modalVacField').html('').removeClass('vacEnabled vacDisabled');
    $('#modalTypeField').html('');

    $.ajax({
        'url': '{{ url("servers/get") }}',
        'method': 'POST',
        'data': { ip : address, type : 0x5, {{ this.security.getTokenKey() }} : '{{ this.security.getToken() }}' },
        'dataType': 'json',
    }).done(function(data) {
        console.log(data);

        if (typeof data.error !== 'undefined') {
            $('#labelModal').html('Cannot gather server information');
        } else {
            $('#labelModal').html(data.server.name);
            $('#modalMapField').html(data.server.map);
            $('#modalNextMapField').html(data.rules.rules.amx_nextmap);
            $('#modalGameField').html(data.server.game);
            $('#modalPlayersField').html(data.server.players + '(' + data.server.bots + ')/' + data.server.maxplayers + ((data.server.players) ? ' <button type="button" class="btn btn-primary" data-id="' + address + '" data-toggle="modal" data-target="#playerModal">Players</button>' : ''));
            $('#modalVacField').html(data.server.vac === 1 ? 'Secure' : 'Insecure').addClass(data.server.vac === 1 ? 'vacEnabled' : 'vacDisabled');
            $('#modalTypeField').html(data.server.password === 1 ? 'Private' : 'Public');
        }
    });
}

function updatePlayers(address) {

    $('#playerLabelModal').html('Players <i class="fa fa-spinner fa-spin"></i>');
    $('#playerTableModal').html('');

    $.ajax({
        'url': '{{ url("servers/get") }}',
        'method': 'POST',
        'data': { ip : address, type : 0x2, {{ this.security.getTokenKey() }} : '{{ this.security.getToken() }}' },
        'dataType': 'json',
    }).done(function(data) {
        console.log(data);

        if (typeof data.error !== 'undefined') {
            $('#playerLabelModal').html('Cannot gather players\' information');
        } else {
            $('#playerLabelModal').html('Players');
            if (data.players.playersnum) {
                var playersContent = '';

                data.players.players.forEach(function(player) {
                    playersContent += '<tr><td>' + player.name + '</td><td>' + player.score + '</td><td>' + secToHour(player.time) + '</td></tr>';
                });
                $('#playerTableModal').html(playersContent);
            } else {
                $('#playerTableModal').html('<tr><td></td><td>No players</td><td></td></tr>');
            }
        }
    });
}

{% endblock %}

{% block content %}
    <div class="modal fade" id="infoModal" tabindex="-1" role="dialog" aria-labelledby="labelModal" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="labelModal"></h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    Server's IP: <span class="modalField" id="modalServerIpField"></span>
                    <hr>
                    Map: <span class="modalField" id="modalMapField"></span>
                    <hr>
                    Next map: <span class="modalField" id="modalNextMapField"></span>
                    <hr>
                    Game: <span class="modalField" id="modalGameField"></span>
                    <hr>
                    Players: <span class="modalField" id="modalPlayersField"></span>
                    <hr>
                    VAC status: <span class="modalField" id="modalVacField"></span>
                    <hr>
                    Typ: <span class="modalField" id="modalTypeField"></span>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="playerModal" tabindex="-1" role="dialog" aria-labelledby="playerLabelModal" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="playerLabelModal">Players</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <table class="table table-striped table-hover table-sm table-responsive-sm">
                        <thead class="thead-dark">
                            <tr>
                                <th>Name</th>
                                <th>Score</th>
                                <th>Time</th>
                            </tr>
                        </thead>
                        <tbody id="playerTableModal">
                            <tr>
                                <td></td>
                                <td>No players</td>
                                <td></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    <table class="table table-striped table-hover table-sm table-responsive-sm">
        <thead class="thead-dark" id="theader">
            <tr>
                <th>Mod</th>
                <th>VAC</th>
                <th>OS</th>
                <th>Password</th>
                <th>Server name</th>
                <th>Players</th>
                <th>Info</th>
            </tr>
        </thead>
        <tbody>
        {% for index, ip in ipArray %}
            <script type="text/javascript">
                getInfo('{{ ip }}', {{ index }});
                setInterval(getInfo, 5000, '{{ ip }}', {{ index }});

                {% if loop.first %}
                    $('#infoModal').on('show.bs.modal', function (e) {
                        updateModal($(e.relatedTarget).data('id'));
                    });
                    $('#playerModal').on('show.bs.modal', function (e) {
                        updatePlayers($(e.relatedTarget).data('id'));
                    });
                {% endif %}
            </script>
            <tr id="row{{index}}">
                <td id="game{{index}}" >
                    <i class="fa fa-spinner fa-spin"></i>
                </td>
                <td id="vac{{index}}">
                    <i class="fa fa-spinner fa-spin"></i>
                </td>
                <td id="os{{index}}">
                    <i class="fa fa-spinner fa-spin"></i>
                </td>
                <td id="pass{{index}}">
                    <i class="fa fa-spinner fa-spin"></i>
                </td>
                <td data-toggle="tooltip">
                    <span id="host{{index}}" class="spanHost"><i class="fa fa-spinner fa-spin"></i></span>
                </td>
                <td id="players{{index}}">
                    <i class="fa fa-spinner fa-spin"></i>
                </td>
                <td id="btn{{index}}">
                </td>
            </tr>
        {% else %}
            <tr>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td>No servers to display</td>
                <td></td>
                <td></td>
            </tr>
        {% endfor %}
        </tbody>
    </table>
{% endblock %}
