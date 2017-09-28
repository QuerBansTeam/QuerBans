{% for serverKey, server in serversList %}
    {% set adminsNumber = server['admins']|length %}
    {% set slidesNumber = (adminsNumber / 5)|ceil %}
    {% set adminsAdded = 0 %}
    {% set adminId = 0 %}
    <div style="text-align: center; border-width: 2px; border-color: gray; border-radius: 20px;">
        <p>{{ server['hostname'] }}</p>
    </div>
    <div id="carousel{{ serverKey }}" class="carousel slide" data-ride="carousel" data-interval="false">
        {% if slidesNumber > 1 %}
        <ol class="carousel-indicators carousel-indicators-numbers" style="bottom: -17%;">
            <li data-target="#carousel{{ serverKey }}" data-slide-to="0" class="active">1</li>
            {% for i in 2..slidesNumber %}
                <li data-target="#carousel{{ serverKey }}" data-slide-to="{{ i - 1 }}">{{ i }}</li>
            {% endfor %}
        </ol>
        {% endif %}
        <div class="carousel-inner" role="listbox" style="background: rgba(0,0,0,0.125); box-sizing: initial;">
            {% for i in 1..slidesNumber %}
                {% set adminsInSlide = 0 %}
                <div class="carousel-item {{ loop.first ? 'active' : '' }}">
                    <div class="row" style="padding-top: 1%; padding-bottom: 1%;">
                        {% for key, admin in server['admins'] if key > adminId %}
                            {% if admin['personastate'] !== -1 %}
                                {% set profileStateName = statusNames[admin['personastate']] %}
                            {% else %}
                                {% set profileStateName = 'No Steam profile' %}
                            {% endif %}
                            <div class="col-sm-2 mx-auto">
                                <div class="card" style="text-align: center; border-width: 2px; padding: 5%;">
                                    <img src="{{ admin['avatarfull'] }}" class="card-img-top" style="display: block; margin-left: auto; margin-right :auto;">
                                    <div class="card-block">
                                        <h5 class="card-title">{{ admin['personaname'] }}</h5>
                                        <p class="card-text" style="font-weight: bold; {{ admin['personastate'] > 0 ? 'color: green;' : 'color: red;' }}">
                                            {{ profileStateName }}
                                            {% if admin['personastate'] !== -1 and admin['communityvisibilitystate'] === 1 %}
                                                {{ '<span style="font-weight: normal; font-style: italic; color: red;">(Private)</span>' }}
                                            {% endif %}
                                        </p>
                                        <a href="{{ admin['profileurl'] }}" target="_blank" class="btn btn-primary {{ profileState !== -1 ? '' : 'disabled' }}" style="margin: 0 0 auto auto">Steam profile</a>
                                    </div>
                                </div>
                            </div>
                            {% set adminsInSlide += 1 %}
                            {% set adminId = key %}
                            {% if adminsInSlide === 5 %}
                                {% break %}
                            {% endif %}
                        {% endfor %}
                    </div>
                </div>
            {% endfor %}
        </div>
        {% if slidesNumber > 1 %}
            <a class="carousel-control-prev" href="#carousel{{ serverKey }}" role="button" data-slide="prev" style="left: -15%; background: linear-gradient(to right, rgba(0,0,0,0) 0%,rgba(0,0,0,0) 1%,rgba(0,0,0,0.25) 99%,rgba(0,0,0,0.25) 100%) no-repeat center center;">
                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                <span class="sr-only">Previous</span>
            </a>
            <a class="carousel-control-next" href="#carousel{{ serverKey }}" role="button" data-slide="next" style="right: -15%; background: linear-gradient(to right, rgba(0,0,0,0.25) 0%,rgba(0,0,0,0.25) 1%,rgba(0,0,0,0) 99%,rgba(0,0,0,0) 100%) no-repeat center center;">
                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                <span class="sr-only">Next</span>
            </a>
        {% else %}
            <div class="disabled-control-prev">
                <span class="sr-only">Previous</span>
            </div>
            <div class="disabled-control-next">
                <span class="sr-only">Next</span>
            </div>
        {% endif %}
    </div>
    </br>
    </br>
{% endfor %}
