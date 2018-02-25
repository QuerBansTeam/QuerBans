{% extends 'layouts/layout.volt' %}

{% block style %}
    .popover
    {
        display: table;
        z-index: 1; /* makes popover to show under navbar */
    }
{% endblock %}

{% block title %}
    Bans list
{% endblock %}

{% block script %}

    function validateForm(id) {
        $.ajax({
            'url': '{{ url("bans/validate") }}',
            'method': 'POST',
            'data': $('#editForm' + id).serialize(),
            'dataType': 'json',
        }).done(function(data) {
            console.log(data);

            showErrors(data.error.fields.name, data.error.fields.message, id);

            $('#saveButton' + id).prop('disabled', data.error.exist);
            $('#banButton' + id).prop('disabled', data.error.exist);
        });
    }

    function showErrors(errorFieldsNames, errorFieldsMsgs, banid) {

        errorFieldsNames.forEach(function(element, index) {
            $('#' + element + 'EditModal' + banid).removeClass('is-valid').addClass('is-invalid');
            $('#' + element + 'FeedbackControl' + banid).css('display', 'block').html(errorFieldsMsgs[index]);
        });

        var fieldsNames = ['playerId', 'playerIp', 'reason', 'length', 'editReason'];

        fieldsNames.forEach(function(element) {
            var divId = '#' + element + 'EditModal' + banid;
            if (errorFieldsNames.indexOf(element) == -1 && $(divId).hasClass('is-invalid')) {
                $(divId).removeClass('is-invalid').addClass('is-valid');
                $('#' + element + 'FeedbackControl' + banid).css('display', 'none');
            }
        });
    }

{% endblock %}



{% block content %}
    <nav aria-label="Pagination">
        <ul class="pagination pagination-sm justify-content-center">
            {% if page.first != page.current %}
                {% set tabIndex = 0 %}
                <li class="page-item">
            {% else %}
                {% set tabIndex = -1 %}
                <li class="page-item disabled">
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
                {% set tabIndex = 0 %}
                <li class="page-item">
            {% else %}
                {% set tabIndex = -1 %}
                <li class="page-item disabled">
            {% endif %}

            {{ link_to('bans/%d'|format(page.current + 1), 'Next', 'class': 'page-link', 'tabindex': tabIndex) }}
            </li>
        </ul>
    </nav>
    <table class="table table-striped table-hover table-sm table-responsive-sm">
        <thead class="thead-dark" id="theader">
            <tr>
                <th>Game</th>
                <th>Date</th>
                <th>Player</th>
                <th>Admin</th>
                <th>Reason</th>
                <th>Length</th>
                <th>Info</th>
            </tr>
        </thead>
        <tbody>
        {% set _tokenKey = this.security.getTokenKey() %}
        {% set _tokenValue = this.security.getToken() %}
        {% for ban in page.items %}
            {% if ban.unbanned == 1 %}
                {% set isBanned = false %}
            {% else %}
                {% set isBanned = ban.length == 0 or ban.getCreatedTime() + ban.length * 60 > time() %}
            {% endif %}
            <tr>
                <td>
                    {% if ban.server %}
                        {{ image('img/games/%s.png'|format(ban.server.getGameType())) }}
                    {% else %}
                        {{ image('img/games/web.png') }}
                    {% endif %}
                </td>
                <td>
                    {{ strftime("%G-%m-%d", ban.getCreatedTime()) }}
                </td>
                <td>
                    {{ image('img/flags/%s.gif'|format(ban.player_ip ? getCountryIsoCode(ban.player_ip) : 'clear')) }}
                    {{ ban.player_nick !== null ? ban.player_nick|e : '<i>Unknown</i>' }}
                    {% if isBanned !== true %}
                        {% if ban.unbanned != 1 %}
                            <span class="badge badge-info">Expired</span>
                        {% else %}
                            <span class="badge badge-success">Unbanned</span>
                        {% endif %}
                    {% endif %}
                </td>
                <td>
                    {{ ban.admin_nick|e }}
                </td>
                <td>
                    {{ ban.reason|e }}
                </td>
                <td>
                    {% if ban.length == 0 %}
                        Permament
                    {% else %}
                        {{ (ban.length * 60)|sec_to_str }}
                    {% endif %}
                </td>
                <td>
                    {% set serverHostname = ban.server ? ban.server.hostname : 'website' %}
                    {% set banId = ban.getId() %}
                    {% set unbanButton = '' %}
                    {% set editButton = '' %}
                    {% set deleteButton = '' %}

                    {% if this.session.has('username') %}
                        {% set unbanButton = isBanned ? '<button type="button" class="btn btn-success" data-toggle="modal" data-target="#unbanModal%d">Unban</button>'|format(banId) : '' %}
                        {% set editButton = '<button type="button" class="btn btn-warning" data-toggle="modal" data-target="#editModal%d">Edit</button>'|format(banId) %}
                        {% set deleteButton = '<button type="button" class="btn btn-danger" data-toggle="modal" data-target="#deleteModal%d">Delete</button>'|format(banId) %}
                    {% endif %}

                    <button id="bidButton{{ banId }}"
                        type="button"
                        class="btn btn-info"
                        data-placement="auto"
                        data-toggle="popover"
                        data-html="true"
                        title="Ban's details #{{ banId }}"
                        data-content="{{ popoverContentTemplate|format(
                            ban.player_nick ? ban.player_nick : '<i>Unknown</i>',
                            ban.player_ip ? getCountryName(ban.player_ip)|capitalize : '<i>Unknown</i>',
                            ban.player_ip ? getCountryIsoCode(ban.player_ip) : 'clear',
                            ban.player_id ? ban.player_id : '<i>None</i>',
                            this.session.has('username') ? ban.player_ip ? ban.player_ip : '<i>None</i>' : '<i>Hidden</i>',
                            ban.reason,
                            strftime('%G-%m-%d %T', ban.getCreatedTime()),
                            ban.length != 0 ? strftime('%G-%m-%d %T', ban.getCreatedTime() + ban.length * 60) : 'Permament',
                            ban.admin_nick !== serverHostname ? ban.admin_nick : 'server',
                            serverHostname,
                            ban.getMapName()|length !== 0 ? ban.getMapName() : 'Not available',
                            editButton,
                            unbanButton,
                            deleteButton
                            )|escape_attr }}">
                        Show
                    </button>
                </td>
            </tr>
            {# Modal template for delete and unban actions #}
            {%- macro ban_modal(ban, name, title, modal_content, button_title, key, token) %}
            <div class="modal fade" id="{{ name }}Modal{{ ban.getId() }}" tabindex="-1" role="dialog" aria-labelledby="{{ name }}Modal" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="{{ name }}ModalTitle">{{ title }} <strong>{{ ban.player_nick|e }}</strong>  (#{{ ban.getId() }})</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            {{ modal_content }}
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                            {{ form('bans/' ~ name ~ '/' ~ ban.getId(), 'method': 'post') }}
                                {{ hidden_field('csrf', 'name': key, 'value': token) }}
                                {{ submit_button(button_title, 'class': 'btn btn-primary') }}
                            {{ end_form() }}
                        </div>
                    </div>
                </div>
            </div>
            {%- endmacro %}
            <div class="modal fade" id="editModal{{ banId }}" tabindex="-1" role="dialog" aria-labelledby="editModal" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="editModalTitle">Edit <strong>{{ ban.player_nick|e }}</strong>  (#{{ banId }})</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            {% set currentEditModal = editForms[loop.index0] %}
                            {{ form('bans/edit/' ~ banId, 'method': 'post', 'id': 'editForm' ~ banId) }}
                            <div id="editModalPlayerNickRow{{ banId }}" class="form-group row">
                                {{ currentEditModal.label('player_nick', [ 'class': 'col-sm-2 col-form-label col-form-label-sm', 'for': 'playerNickEditModal' ~ banId, 'required': true ]) }}
                                <div class="col-sm-10">
                                    {{ currentEditModal.render('player_nick') }}
                                </div>
                            </div>
                            <div id="editModalPlayerIdRow{{ banId }}" class="form-group row">
                                {{ currentEditModal.label('player_id', [ 'class': 'col-sm-2 col-form-label col-form-label-sm', 'for': 'playerIdEditModal' ~ banId ]) }}
                                <div class="col-sm-10">
                                    {{ currentEditModal.render('player_id') }}
                                    <div id="playerIdFeedbackControl{{ banId }}" class="invalid-feedback"></div>
                                </div>
                            </div>
                            <div id="editModalPlayerIpRow{{ banId }}" class="form-group row">
                                {{ currentEditModal.label('player_ip', [ 'class': 'col-sm-2 col-form-label col-form-label-sm', 'for': 'playerIpEditModal' ~ banId ]) }}
                                <div class="col-sm-10">
                                    {{ currentEditModal.render('player_ip') }}
                                    <div id="playerIpFeedbackControl{{ banId }}" class="invalid-feedback"></div>
                                </div>
                            </div>
                            <div id="editModalReasonRow{{ banId }}" class="form-group row">
                                {{ currentEditModal.label('reason', [ 'class': 'col-sm-2 col-form-label col-form-label-sm', 'for': 'reasonEditModal' ~ banId ]) }}
                                <div class="col-sm-10">
                                    {{ currentEditModal.render('reason') }}
                                    <div id="reasonFeedbackControl{{ banId }}" class="invalid-feedback"></div>
                                </div>
                            </div>
                            <div id="editModalLengthRow{{ banId }}" class="form-group row">
                                {{ currentEditModal.label('length', [ 'class': 'col-sm-2 col-form-label col-form-label-sm', 'for': 'lengthEditModal' ~ banId ]) }}
                                <div class="col-sm-10">
                                    {{ currentEditModal.render('length') }}
                                    <div id="lengthFeedbackControl{{ banId }}" class="invalid-feedback"></div>
                                    <small class="form-text text-muted">Time in minutes. Type 0 for permament ban.</small>
                                </div>
                            </div>
                            <div id="editModalEditReasonRow{{ banId }}" class="form-group row">
                                {{ currentEditModal.label('editReason', [ 'class': 'col-sm-2 col-form-label col-form-label-sm', 'for': 'editReasonEditModal' ~ banId ]) }}
                                <div class="col-sm-10">
                                    {{ currentEditModal.render('editReason') }}
                                    <div id="editReasonFeedbackControl{{ banId }}" class="invalid-feedback"></div>
                                    <small class="form-text text-muted">Reason for editing ban.</small>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            {% if isBanned === false %}
                                {{ currentEditModal.render('Ban') }}
                            {% endif %}
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                                {{ currentEditModal.render('Save') }}
                                {{ hidden_field('csrf' ~ banId, 'name': _tokenKey, 'value': _tokenValue) }}
                            {{ end_form() }}
                        </div>
                    </div>
                </div>
            </div>
            {% if isBanned === true %}
                {{ ban_modal(ban, 'unban', 'Unban', 'Do you really want to unban this player?', 'Unban', _tokenKey, _tokenValue) }}
            {% endif %}
            {{ ban_modal(ban, 'delete', 'Delete ban', 'Do you really want to delete this ban?', 'Delete', _tokenKey, _tokenValue) }}
            <script>
                {{ partial('bans/partials/ban_edit_modals_js', [ 'banId': banId ]) }}
            </script>
        {% endfor %}
        </tbody>
    </table>
{% endblock %}
