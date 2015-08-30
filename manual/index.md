---
layout: page
title: Manual
---
{% assign pages_list = site.pages | where: 'layout','test-result' | sort:"url" %}

<ul>
{% for page in pages_list %}
  <li><a href="{{ site.baseurl }}{{ page.url }}">{{ page.title }}</a></li>
{% endfor %}
</ul>
