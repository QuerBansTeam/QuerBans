{% extends 'layouts/layout.volt' %}

{% block title %}
    Sign in
{% endblock %}

{% block style %}
:root {
    --input-padding-x: .75rem;
    --input-padding-y: .75rem;
}

html, body {
    height: 100%;
}

.form-signin {
    width: 100%;
    max-width: 420px;
    padding: 15px;
    margin: 0 auto;
}

.form-label-group {
    position: relative;
    margin-bottom: 1rem;
}

.form-label-group > input,
.form-label-group > label {
    padding: var(--input-padding-y) var(--input-padding-x);
}

.form-label-group > label {
    position: absolute;
    top: 0;
    left: 0;
    display: block;
    width: 100%;
    margin-bottom: 0; /* Override default `<label>` margin */
    line-height: 1.5;
    color: #495057;
    border: 1px solid transparent;
    border-radius: .25rem;
    transition: all .1s ease-in-out;
}

.form-label-group input::-webkit-input-placeholder {
    color: transparent;
}

.form-label-group input:-ms-input-placeholder {
    color: transparent;
}

.form-label-group input::-ms-input-placeholder {
    color: transparent;
}

.form-label-group input::-moz-placeholder {
    color: transparent;
}

.form-label-group input::placeholder {
    color: transparent;
}

.form-label-group input:not(:placeholder-shown) {
    padding-top: calc(var(--input-padding-y) + var(--input-padding-y) * (2 / 3));
    padding-bottom: calc(var(--input-padding-y) / 3);
}

.form-label-group input:not(:placeholder-shown) ~ label {
    padding-top: calc(var(--input-padding-y) / 3);
    padding-bottom: calc(var(--input-padding-y) / 3);
    font-size: 12px;
    color: #777;
}
{% endblock %}

{% block content %}
    <form class="form-signin" method="post" action="{{ url('signin/login') }}">
        <h2 class="text-center mb-4">Sign in</h2>
        <div class="form-label-group">
            <input type="text" id="inputUsername" class="form-control" placeholder="Username" name="login" required autofocus>
            <label for="inputUsername">Username</label>
        </div>
        <div class="form-label-group">
            <input type="password" id="inputPassword" class="form-control" placeholder="Password" name="password" required>
            <label for="inputPassword">Password</label>
        </div>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
    </form>
{% endblock %}
