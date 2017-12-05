<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <title>QuerBans - {% block title %}{% endblock %}</title>
        {{ stylesheet_link('css/bootstrap.min.css') }}
        {{ stylesheet_link('css/font-awesome.min.css') }}
        {{ javascript_include('js/jquery-3.2.1.min.js') }}
        {{ javascript_include('js/bootstrap.bundle.min.js') }}
        <style type="text/css">{% block style %}{% endblock %}</style>
        <script type="text/javascript">{% block script %}{% endblock %}</script>
    </head>
    <body>
        <nav class="navbar navbar-expand-md navbar-dark bg-dark">
            <button class="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse" data-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle menu">
                <span class="navbar-toggler-icon"></span>
            </button>
            <a class="navbar-brand" href="{{ url('') }}">QuerBans Inc.</a>
            <div class="collapse navbar-collapse" id="navbar">
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item">
                        {{ link_to(url(''), '<i class="fa fa-home fa-lg" aria-hidden="true"></i> Home', 'class': 'nav-link') }}
                    </li>
                    {% if activePage !== "bans" %}
                        <li class="nav-item">
                    {% else %}
                        <li class="nav-item active">
                    {% endif %}
                        {{ link_to(url('bans'), '<i class="fa fa-ban fa-lg" aria-hidden="true"></i> Ban list', 'class': 'nav-link') }}
                        {% if activePage === "bans" %}
                            <span class="sr-only">(current)</span>
                        {% endif %}
                    </li>
                    {% if activePage !== "adminlist" %}
                        <li class="nav-item">
                    {% else %}
                        <li class="nav-item active">
                    {% endif %}
                        {{ link_to(url('adminlist'), '<i class="fa fa-users fa-lg" aria-hidden="true"></i> Admin list', 'class': 'nav-link') }}
                        {% if activePage === "adminlist" %}
                            <span class="sr-only">(current)</span>
                        {% endif %}
                    </li>
                    {% if activePage !== 'servers' %}
                    <li class="nav-item">
                    {% else %}
                    <li class="nav-item active">
                    {% endif %}
                        {{ link_to(url('servers'), '<i class="fa fa-server fa-lg" aria-hidden="true"></i> Servers', 'class': 'nav-link') }}
                        {% if activePage === "adminlist" %}
                        <span class="sr-only">(current)</span>
                        {% endif %}
                    </li>
                </ul>
                {% if this.session.has('username') %}
                    <a href="{{ url('signin/logout') }}" class="btn btn-outline-danger" role="button"><i class="fa fa-sign-out" aria-hidden="true"></i>
 Log out {{ this.session.get('username') }}</a>
                {% else %}
                    {% if activePage !== 'signin' %}
                        <a href="{{ url('signin') }}" class="btn btn-outline-success" role="button"><i class="fa fa-sign-in" aria-hidden="true"></i> Login</a>
                    {% else %}
                        <a href="{{ url('signin') }}" class="btn btn-success" role="button"><i class="fa fa-sign-in" aria-hidden="true"></i> Login</a>
                    {% endif %}
                {% endif %}
            </div>
        </nav>
        <div class="text-center">
            {{ image('img/banner.png', 'class': 'img-fluid') }}
        </div>
        <div class="container">{% block content %}{% endblock %}</div>
        <script type="text/javascript">
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
    </body>

    {#
    <footer class="footer">
        <div style="background-color: #efeae1;" class="container-fluid text-center text-muted">
            <strong>QuerBans</strong> by <strong>Amaroq</strong>  <a href="https://github.com/Amaroq7" target="_blank"><img src="/img/github.png" width="25px" height="25px" alt="GitHub Account"></a>
        </div>
    </footer>
    #}
</html>
