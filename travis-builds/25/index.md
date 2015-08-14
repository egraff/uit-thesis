---
layout: test-result
travis:
  build-number: 25
  build-id: 14549578
---
### Test

{% capture build_number %}a{{ page.travis.build-number }}c{% endcapture %}

Build number: {{ page.travis.build-number }} = {{ build_number }}

Num tests: {{ site.data.travis-builds[build-number].num_tests }}

Num tests: {{ site.data.travis-builds["25"].num_tests }}

Num tests: {{ site.data.travis-builds[25].num_tests }}

Num tests: {{ site.data.travis-builds.25.num_tests }}

Test image:
![This is an image](http://lorempixel.com/400/200/)


Test code:

```
This is some code.
```

Test LaTeX code

```latex
\begin{document}
blah
\end{document}
```

