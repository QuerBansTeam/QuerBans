{% extends 'layouts/layout.volt' %}

{% block title %}
    Admin Panel
{% endblock %}

{% block logo %}
{# no logo in admin panel #}
{% endblock %}

{% block style %}
    .sidebar {
        position: fixed;
        top: 56px;
        bottom: 0;
        left: 0;
        z-index: 100; /* Behind the navbar */
        padding: 0;
        box-shadow: inset -1px 0 0 rgba(0, 0, 0, .1);
    }

    .sidebar-sticky {
        position: -webkit-sticky;
        position: sticky;
        top: 64px; /* Height of navbar */
        height: calc(100vh - 64px);
        padding-top: .5rem;
        overflow-x: hidden;
        overflow-y: auto; /* Scrollable contents if viewport is shorter than content. */
    }

    .sidebar .nav-link {
        font-weight: 500;
        color: #333;
    }

    .sidebar .nav-link.active {
        color: #007bff;
    }

    .sidebar-heading {
        font-size: .75rem;
        text-transform: uppercase;
    }

    .border-top {
        border-top: 1px solid #e5e5e5;
    }

    .border-bottom {
        border-bottom: 1px solid #e5e5e5;
    }
{% endblock %}

{% block content %}
    <div class="container-fluid">
        <div class="row">
            <nav class="col-md-2 d-none d-md-block bg-light sidebar">
                <div class="sidebar-sticky">

                    <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
                        Overview
                    </h6>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link {{ activePageAdmin === 'index' ? 'active' : '' }}" href="{{ url('/admin') }}">
                            Overview
                            {% if activePageAdmin === 'index' %}
                                 <span class="sr-only">(current)</span>
                            {% endif %}
                            </a>
                        </li>
                    </ul>

                    <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
                        Bans
                    </h6>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link {{ activePageAdmin === 'addban' ? 'active' : '' }}" href="{{ url('/admin/addban') }}">
                            Add ban
                            {% if activePageAdmin === 'addban' %}
                                 <span class="sr-only">(current)</span>
                            {% endif %}
                            </a>
                        </li>
                    </ul>

                    <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
                        Users
                    </h6>
                    <ul class="nav flex-column">
                        <li class="nav-item">
                            <a class="nav-link" href="{{ url('/admin/users') }}">
                                Users
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                Groups
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                Add user
                            </a>
                        </li>
                    </ul>

                    <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
                        Servers
                    </h6>
                    <ul class="nav flex-column mb-2">
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                Settings
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                Ban sets
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                Assign admins
                            </a>
                        </li>
                    </ul>

                    <h6 class="sidebar-heading d-flex justify-content-between align-items-center px-3 mt-4 mb-1 text-muted">
                        Website
                    </h6>
                    <ul class="nav flex-column mb-2">
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                Settings
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">
                                Logs
                            </a>
                        </li>
                    </ul>
                </div>
            </nav>
            <main role="main" class="col-md-9 ml-sm-auto col-lg-10 pt-3 px-4">
                <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-2 mb-3 border-bottom">
                    <h1 class="h2">Overview</h1>
                </div>
                <br>
                <h3>Server setup</h3>
                <div class="table-responsive">
                    <table class="table table-sm">
                        <thead class="thead-dark">
                            <tr>
                                <td>Component</td>
                                <td>Version</td>
                                <td>Recommended</td>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="{{ (okPHPver) ? 'table-success' : 'table-warning' }}">
                                <td><strong>PHP Version</strong></td>
                                <td><i class="fas fa-check"></i> {{ phpversion }}</td>
                                <td>{{ recomPhpVer }}</td>
                            </tr>
                            <tr class="{{ (okPhalconVer) ? 'table-success' : 'table-warning' }}">
                                <td><strong>Phalcon Version</strong></td>
                                <td><i class="fas fa-check"></i> {{ phalconversion }}</td>
                                <td>{{ recomPhalconVer }}</td>
                            </tr>
                            <tr class="{{ ((Is32Bit() and gmploaded) or !Is32Bit()) ? 'table-success' : 'table-warning' }}">
                                <td><strong>GMP Module</strong></td>
                                {% if Is32Bit() === true %}
                                    {% if gmploaded === true %}
                                        <td><i class="fas fa-check"></i> Loaded</td>
                                    {% else %}
                                        <td><i class="fas fa-exclamation"></i> Not loaded</td>
                                    {% endif %}
                                    <td>Present</td>
                                {% else %}
                                    {# on 64 bit installations always passes #}
                                    <td>
                                        {% if gmploaded === true %}
                                            <i class="fas fa-check"></i>
                                        {% else %}
                                            Not present
                                        {% endif %}
                                    </td>
                                    <td>Not necessary</td>
                                {% endif %}
                            </tr>
                        </tbody>
                    </table>
                </div>
                <br>
                <h3>Statistics</h3>
                <div class="table-responsive">
                    <table class="table table-sm">
                        <tbody>
                            <tr>
                                <td><strong>Bans in database</strong></td>
                                <td>{{ allBansCount }}</td>
                            </tr>
                            <tr>
                                <td><strong>Active bans</strong></td>
                                <td>{{ activeBansCount }}</td>
                            </tr>
                            <tr>
                                <td><strong>Expired bans</strong></td>
                                <td>{{ expiredBansCount }}</td>
                            </tr>
                            <tr>
                                <td><strong>Unbanned</strong></td>
                                <td>{{ unbannedCount }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </main>
        </div>
    </div>
{% endblock %}
