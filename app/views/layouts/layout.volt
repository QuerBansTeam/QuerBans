{% extends 'main.volt' %}

{% block logo %}
	<div class="text-center">
		{{ image('img/banner.png', 'class': 'img-fluid') }}
	</div>
{% endblock %}

{% block navbar %}
	<nav class="navbar sticky-top navbar-expand-md navbar-dark bg-dark">
		<button class="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse" data-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle menu">
			<span class="navbar-toggler-icon"></span>
		</button>
		<a class="navbar-brand" href="{{ url('') }}">QuerBans Inc.</a>
		<div class="collapse navbar-collapse" id="navbar">
			<ul class="navbar-nav mr-auto">
				<li class="nav-item">
					{{ link_to(url(''), '<i class="fas fa-home fa-fw"></i> Home', 'class': 'nav-link') }}
				</li>
				<li class="nav-item {{ activePage === 'bans' ? 'active' : '' }}">
					{{ link_to(url('bans'), '<i class="fas fa-ban fa-fw"></i> Ban list', 'class': 'nav-link') }}
					{% if activePage === "bans" %}
						<span class="sr-only">(current)</span>
					{% endif %}
				</li>
				<li class="nav-item {{ activePage === 'adminlist' ? 'active' : '' }}">
					{{ link_to(url('adminlist'), '<i class="fas fa-users fa-fw"></i> Admin list', 'class': 'nav-link') }}
					{% if activePage === "adminlist" %}
						<span class="sr-only">(current)</span>
					{% endif %}
				</li>
				<li class="nav-item {{ activePage === 'servers' ? 'active' : '' }}">
					{{ link_to(url('servers'), '<i class="fas fa-server fa-fw"></i> Servers', 'class': 'nav-link') }}
					{% if activePage === "adminlist" %}
						<span class="sr-only">(current)</span>
					{% endif %}
				</li>
			</ul>
			{% if this.session.has('id') %}
				<a href="{{ url('admin') }}" class="btn btn-light" role="button"><i class="fas fa-user-secret fa-fw"></i> Admin Panel</a>&nbsp;
				<a href="{{ url('signin/logout') }}" class="btn btn-outline-danger" role="button"><i class="fas fa-sign-out-alt fa-fw"></i> Log out {{ this.session.get('username') }}</a>
			{% else %}
				{% if activePage !== 'signin' %}
					<a href="{{ url('signin') }}" class="btn btn-outline-success" role="button"><i class="fas fa-sign-in-alt fa-fw"></i> Login</a>
				{% else %}
					<a href="{{ url('signin') }}" class="btn btn-success" role="button"><i class="fas fa-sign-in-alt fa-fw"></i> Login</a>
				{% endif %}
			{% endif %}
		</div>
	</nav>
{% endblock %}

{% block alerts %}
	{% if msgType is defined and msgContent is not empty %}
		{% if msgType === 0 %}
			<div class="alert alert-success alert-dismissible fade show" role="alert">
			<strong>Success!</strong>&nbsp;
		{% elseif msgType === 1 %}
			<div class="alert alert-danger alert-dismissible fade show" role="alert">
			<strong>Error!</strong>&nbsp;
		{% endif %}
		{% if msgContent is iterable %}
			{% for msg in msgContent %}
				{{ msg }}
				<br>
			{% endfor %}
		{% else %}
			{{ msgContent }}
		{% endif %}
		<button type="button" class="close" data-dismiss="alert" aria-label="Close">
			<span aria-hidden="true">&times;</span>
		</button>
	</div>
	{% endif %}
{% endblock %}

{% block content %}
{% endblock %}
