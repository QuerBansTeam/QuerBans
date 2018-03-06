{% extends 'layouts/layout.volt' %}

{% block title %}
    {% if banData is defined %}
        View ban #{{ banData.id }}
    {% else %}
        Not found
    {% endif %}
{% endblock %}

{% block content %}
    {% if banData is defined %}
        {% set serverHostname = banData.server ? banData.server.hostname : 'website' %}
        <h3>Ban's details #{{ banData.id }}</h3>
        <div class="table-responsive">
            <table class="table table-sm">
                <tbody>
                    <tr>
                        <td><strong>Nickname</strong></td>
                        <td>{{ banData.player_nick|e }}</td>
                    </tr>
                    <tr>
                        <td><strong>Country</strong></td>
                        <td>
                            {% if banData.player_ip %}
                                {{ getCountryName(banData.player_ip)|capitalize }}&nbsp;
                                {{ image('img/flags/%s.gif')|format(getCountryIsoCode(banData.player_ip)) }}
                            {% else %}
                                <i>Unknown</i>
                                {{ image('img/flags/clear.gif') }}
                            {% endif %}
                        </td>
                    </tr>
                    <tr>
                        <td><strong>IP address</strong></td>
                        <td>{{ this.session.get('loggedin') ? banData.player_ip : '<i>Hidden</i>' }}</td>
                    </tr>
                    <tr>
                        <td><strong>Reason</strong></td>
                        <td>{{ banData.reason|e }}</td>
                    </tr>
                    <tr>
                        <td><strong>Invoked on</strong></td>
                        <td>{{ strftime('%G-%m-%d %T', banData.getCreatedTime()) }}</td>
                    </tr>
                    <tr>
                        <td><strong>Ban length</strong></td>
                        <td>
                            {% if banData.length != 0 %}
                                {{ (banData.length * 60)|sec_to_str }}</td>
                            {% else %}
                                Permament
                            {% endif %}
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Expires on</strong></td>
                        <td>
                            {% if banData.length != 0 %}
                                {{ strftime('%G-%m-%d %T', banData.getCreatedTime() + banData.length * 60) }}
                            {% else %}
                                Never
                            {% endif %}
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Banned by</strong></td>
                        <td>
                            {% if banData.admin_nick !== serverHostname %}
                                {{ banData.admin_nick }}
                            {% else %}
                                server
                            {% endif %}
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Banned on</strong></td>
                        <td>{{ serverHostname }}</td>
                    </tr>
                    <tr>
                        <td><strong>Map</strong></td>
                        <td>
                            {% if banData.getMapName()|length !== 0 %}
                                {{ banData.getMapName() }}
                            {% else %}
                                <i>Not available</i>
                            {% endif %}
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    {% endif %}
{% endblock %}
