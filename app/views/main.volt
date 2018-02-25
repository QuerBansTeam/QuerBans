<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <title>{% block title %}{% endblock %} - QuerBans</title>
        {{ stylesheet_link('css/bootstrap.min.css') }}
        {{ javascript_include('js/fontawesome-all.min.js') }}
        {{ javascript_include('js/jquery-3.3.1.min.js') }}
        {{ javascript_include('js/bootstrap.bundle.min.js') }}
        <style>{% block style %}{% endblock %}</style>
        <script>{% block script %}{% endblock %}</script>
    </head>
    <body>
        {% block navbar %}{% endblock %}
        {% block logo %}{% endblock %}
        <div class="container">
            {% block alerts %}{% endblock %}
            {% block content %}{% endblock %}
        </div>
    </body>
    <script>
        $(function () {
            $('[data-toggle="popover"]').popover();
            $('[data-toggle="tooltip"]').tooltip();
        });
        $('body').on('click', function (e) {
            $('[data-toggle="popover"]').each(function () {
                if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
                    $(this).popover('hide');
                }
            });
        });
        {% block latescript %}{% endblock %}
    </script>
    <footer class="footer">
        <div style="background-color: #efeae1;" class="container-fluid text-center text-muted">
            <strong>QuerBans</strong> by <strong>QuerBans Team</strong>  <a href="https://github.com/QuerBansTeam/QuerBans" target="_blank">{{ image('img/github.png', 'style': 'width: 20px; height: 20px;') }}</a>
        </div>
    </footer>
</html>
