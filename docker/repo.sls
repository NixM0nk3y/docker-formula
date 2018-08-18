{% from "docker/map.jinja" import docker with context %}

{% set repo_state = 'absent' %}
{% if docker.use_upstream_repo or docker.use_old_repo %}
  {% set repo_state = 'managed' %}
{% endif %}

{%- if grains['os_family']|lower in ('debian') %}

docker package repository:
  pkgrepo.{{ repo_state }}:
    - humanname: {{ grains["os"] }} {{ grains["oscodename"]|capitalize }} Docker Package Repository
    - name: deb {{ docker.repo.url_base ~ ' ' ~ docker.repo.version ~ ' stable' }}
    - file: {{ docker.repo.file }}
    - key_url: {{ docker.repo.key_url }}
    - refresh_db: True
    - require_in:
      - pkg: docker package
    - require:
      - pkg: docker package dependencies

{%- elif grains['os']|lower in ('centos', 'fedora') %}
{% set url = 'https://yum.dockerproject.org/repo/main/centos/$releasever/' if docker.use_old_repo else docker.repo.url_base %}

docker package repository:
  pkgrepo.{{ repo_state }}:
    - name: docker-ce-stable
    - humanname: {{ grains['os'] }} {{ grains["oscodename"]|capitalize }} {{ humanname_old }}Docker Package Repository
    - baseurl: {{ url }}
    - enabled: 1
    - gpgcheck: 1
    {% if docker.use_old_repo %}
    - gpgkey: https://yum.dockerproject.org/gpg
    {% else %}
    - gpgkey: {{ docker.repo.key_url }}
    {% endif %}
    - require_in:
      - pkg: docker package
    - require:
      - pkg: docker package dependencies

{%- else %}
docker package repository: {}
{%- endif %}
