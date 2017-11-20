{% extends 'layout.volt' %}

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

        var baseDir = "{{ url('img/') }}";

        $('#game' + id).html('<img src="' + baseDir + 'games/' + data.server.folder + '.png">');

        var vacImg = (data.server.vac) ? 'vac_fill' : 'no_vac_fill';
        $('#vac' + id).html('<img src="' + baseDir + 'VAC/' + vacImg + '.png">');

        var osImg;
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
        $('#os' + id).html('<img src="' + baseDir + 'OS/' + osImg + '.png">');

        var passImg = (data.server.password) ? 'lock_fill' : 'unlock_fill';
        $('#pass' + id).html('<img src="' + baseDir + 'custom/' + passImg + '.png">');
        $('#host' + id).html(data.server.name);
        $('#players' + id).html(data.server.players + '/' + data.server.maxplayers);
    }).always(function(data) {

    })
}

{% endblock %}

{% block content %}


    <table class="table table-striped table-hover table-xs table-responsive-xs">
        <thead class="thead-dark" id="theader">
            <tr>
                <th  class="col-xs-1">Mod</th>
                <th class="col-xs-1">VAC</th>
                <th class="col-xs-1">OS</th>
                <th class="col-xs-1">Password</th>
                <th class="col-xs-6">Server name</th>
                <th class="col-xs-1">Players</th>
                <th class="col-xs-1">Info</th>
            </tr>
        </thead>
        <tbody>
            {% for index, ip in ipArray %}
                <script type="text/javascript">
                    getInfo('{{ ip }}', {{ index }});
                </script>
                <tr>
                    <td id="game{{index}}">
                    </td>
                    <td id="vac{{index}}">
                    </td>
                    <td id="os{{index}}">
                    </td>
                    <td id="pass{{index}}">
                    </td>
                    <td id="host{{index}}" class="max-lines">
                    </td>
                    <td id="players{{index}}">
                    </td>
                    <td>
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

    {% block tableH %}

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
        
        

    {% endblock %}

    {% block tableB %}
        {% for index, ip in ipArray %}
            <script type="text/javascript">
                getInfo('{{ ip }}', {{ index }});
            </script>
            <tr>
                <td id="game{{index}}">
                </td>
                <td id="vac{{index}}">
                </td>
                <td id="os{{index}}">
                </td>
                <td id="pass{{index}}">
                </td>
                <td id="host{{index}}">
                </td>
                <td id="players{{index}}">
                </td>
                <td>
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