<script>

console.log('dupa');
function getInfo(address, id) {
    $.ajax({
        'url': '{{ url("servers/get") }}',
        'method': 'POST',
        'data': { ip : address },
        'dataType': 'json',
    }).done(function(data) {
        console.log(data);

        var baseDir = "{{ url('img/') }}";

       $('#game'+id).html('<img src="'+baseDir+'games/'+data.server.folder+'.png">');

       $('#vac'+id).html('<img src="'+baseDir+'VAC/'+data.server.folder ? 'vac_fill.png">' : 'no_vac_fill.png">');

    }).always(function(data) {

    })
}

</script>
{#
<nav aria-label="Pagination">
    <ul class="pagination pagination-sm justify-content-center">
        {% if page.first != page.current %}
        <li class="page-item">
        {% set tabIndex = 0 %}
        {% else %}
        <li class="page-item disabled">
        {% set tabIndex = -1 %}
        {% endif %}
        {{ link_to('bans/%d'|format(page.current - 1), 'Previous', 'class': 'page-link', 'tabindex': tabIndex) }}

        {% for _page in 1..page.total_pages %}
            {% if _page != page.current %}
            <li class="page-item">
                {% if _page in pagesToDisplay %}
                    {{ link_to('bans/%d'|format(_page), _page, 'class': 'page-link') }}
                {% endif %}
            {% else %}
            <li class="page-item active">
            <span class="page-link">{{ _page }}</span>
            {% endif %}
            </li>
        {% endfor %}

        {% if page.last != page.current %}
        <li class="page-item">
        {% set tabIndex = 0 %}
        {% else %}
        <li class="page-item disabled">
        {% set tabIndex = -1 %}
        {% endif %}

        {{ link_to('bans/%d'|format(page.current + 1), 'Next', 'class': 'page-link', 'tabindex': tabIndex) }}
        </li>
    </ul>
</nav>
#}

<table class="table table-striped table-hover table-sm table-responsive table-fixed">
    <thead class="thead-inverse" id="theader">
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
        <tr>
            <td id="game{{index}}">
            </td>
            <td id="vac{{index}}">
            </td>
            <td id="os{{index}}">
                {{ image('img/OS/linux_fill.png', 'style': 'width: 35px') }}
            </td>
            <td id="pass{{index}}">
            	{{ image('img/custom/lock_fill.png', 'style': 'width: 35px') }}
            </td>
            <td id="host{{index}}">
               {# {{ server.getHostName()|e }} #}
               go ha go ha go ha go ha go |3zł
            </td>
            <td id="players{{index}}">
                0/64 
            </td>
            <td>
				{% set playersButton = '<button type="button" class="btn btn-success" data-toggle="modal" data-target="#playersModal%d">Players</button>'|format(1) %}
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