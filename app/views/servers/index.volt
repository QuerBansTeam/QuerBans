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

{% endblock %}

{% block script %}

function getInfo(address, id) {
    $.ajax({
        'url': '{{ url("servers/get") }}',
        'method': 'POST',
        'data': { ip : address, {{ this.security.getTokenKey() }} : '{{ this.security.getToken() }}' },
        'dataType': 'json',
        'cache': false,
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

        idArr.forEach(function(value) {
            $('#' + value + id).html(timeout ? '' : dataArr[value]);

            if (value == 'host')
                timeout ? $('#' + value + id).html('<b>Server timeout: ' + address + '</b>') : $('#' + value + id).attr('data-original-title', dataArr[value]);
        });

    });
}

{% endblock %}

{% block content %}
    
    <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="exampleModalLabel">New message</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <form>
              <div class="form-group">
                <label for="recipient-name" class="col-form-label">Recipient:</label>
                <input type="text" class="form-control" id="recipient-name">
              </div>
              <div class="form-group">
                <label for="message-text" class="col-form-label">Message:</label>
                <textarea class="form-control" id="message-text"></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            <button type="button" class="btn btn-primary">Send message</button>
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
                        <i class="fa fa-spinner fa-spin" ></i>
                    </td>
                    <td data-toggle="tooltip">
                        <span id="host{{index}}" class="spanHost"><i class="fa fa-spinner fa-spin"></i></span>
                    </td>
                    <td id="players{{index}}">
                        <i class="fa fa-spinner fa-spin" style="font-size: 34px;"></i>
                    </td>
                    <td id="btn{{index}}">
                        {% set playersButton = '<button type="button" class="btn btn-success" data-toggle="modal" data-target="#playersModal{{ index }}">Players</button>' %}
                        
                        <button id="bidButton" type="button" class="btn btn-info" data-toggle="modal" data-target="#exampleModal">Show</button>
                    </td>
                </tr>
            {% endfor %}
        </tbody>
    </table>    

    {% endblock %}

    {#
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
    }#