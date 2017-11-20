{% extends 'main.volt' %}

{% block content %}
	
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
	
{% endblock %}