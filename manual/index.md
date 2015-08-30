---
layout: page
title: Manual
---
{% assign pages_list = site.pages | where: 'layout','manual' | sort:"url" %}

<ul>
{% for page in pages_list %}
  <li><a href="{{ site.baseurl }}{{ page.url }}">{{ page.title }}</a></li>
{% endfor %}
</ul>
