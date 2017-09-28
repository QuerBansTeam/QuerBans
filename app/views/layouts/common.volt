<nav class="navbar navbar-toggleable-md navbar-inverse bg-inverse sticky-top">
    <button class="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse" data-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle menu">
        <span class="navbar-toggler-icon"></span>
    </button>
    <a class="navbar-brand" href="https://godskill.pl">GodSkill.pl</a>
    <div class="collapse navbar-collapse" id="navbar">
        <ul class="navbar-nav mr-auto">
            <li class="nav-item">
                {{ link_to(url(''), 'Home', 'class': 'nav-link') }}
            </li>
            {% if activePage !== "bans" %}
            <li class="nav-item">
            {% else %}
            <li class="nav-item active">
            {% endif %}
                {{ link_to(url('bans'), 'Ban list', 'class': 'nav-link') }}
                {% if activePage === "bans" %}
                <span class="sr-only">(current)</span>
                {% endif %}
            </li>
            {% if activePage !== "adminlist" %}
            <li class="nav-item">
            {% else %}
            <li class="nav-item active">
            {% endif %}
                {{ link_to(url('adminlist'), 'Admin list', 'class': 'nav-link') }}
                {% if activePage === "adminlist" %}
                <span class="sr-only">(current)</span>
                {% endif %}
            </li>
            <li class="nav-item">
                <a class="nav-link" href="/search">Search</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="/servers">Servers</a>
            </li>
        </ul>
        <form class="form-inline my-2 my-lg-0" action="/login/index" method="post">
            <input class="form-control mr-sm-2" type="text" name="login" placeholder="login">
            <input class="form-control mr-sm-2" type="password" name="password" placeholder="password">
            <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Log in</button>
        </form>
    </div>
</nav>
<div class="text-center">
    <img src="/img/banner.png" class="img-fluid">
</div>
{{ content() }}
