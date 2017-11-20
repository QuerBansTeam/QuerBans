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
    
    .table td, .table th
    {
        padding: .25rem;
    }

    .max-lines 
    {
      display: block; /* or inline-block */
      text-overflow: ellipsis;
      word-wrap: break-word;
      overflow: hidden;
      max-height: 3.6em;
      line-height: 1.8em;
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
        }

        idArr.forEach( function(value){
            $('#' + value + id).html(timeout ? '' : dataArr[value]);

            if (value == 'host')
                timeout ? $('#' + value + id).html('<b>Server timeout: ' + address + '</b>') : $('#' + value + id).attr('data-original-title', dataArr[value]);
        });

    });
}

{% endblock %}

{% block content %}


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
                </script>
                <tr id="row{{index}}">
                    <td id="game{{index}}" >
                        <i class="fa fa-spinner fa-spin" style="font-size: 34px;"></i>
                    </td>
                    <td id="vac{{index}}">
                        <i class="fa fa-spinner fa-spin" style="font-size: 34px;"></i>
                    </td>
                    <td id="os{{index}}">
                        <i class="fa fa-spinner fa-spin" style="font-size: 34px;"></i>
                    </td>
                    <td id="pass{{index}}">
                        <i class="fa fa-spinner fa-spin" style="font-size: 34px;"></i>
                    </td>
                    <td id="host{{index}}" class="max-lines" data-toggle="tooltip">
                        <i class="fa fa-spinner fa-spin" style="font-size: 34px;"></i>
                    </td>
                    <td id="players{{index}}">
                        <i class="fa fa-spinner fa-spin" style="font-size: 34px;"></i>
                    </td>
                    <td id="btn{{index}}">
                        {% set playersButton = '<button type="button" class="btn btn-success" data-toggle="modal" data-target="#playersModal{{ index }}">Players</button>' %}
                        <button id="bidButton"
                            type="button"
                            class="btn btn-info"
                            data-placement="auto"
                            data-toggle="popover"
                            data-html="true"
                            title="Server's details"
                            data-content="{{ popoverContentTemplate|format(

                                playersButton
                                )|escape_attr }}">
                            Show
                        </button>
                    </td>
                </tr>
            {% endfor %}
        </tbody>
    </table>    

    {% endblock %}
