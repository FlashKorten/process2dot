SUMMARY:
========
  - converts a hybris process definition into a [graphviz](http://graphviz.org/) 'dot' file, to be rendered into any of dot's output formats (png/svg/...)
  - only a subset of the process definition following `http://www.hybris.de/xsd/processdefinition` is currently supported

USAGE:
======
 - create 'dot' file: `process2dot INPUT.xml > OUTPUT.dot`
 - render directly: `process2dot INPUT.xml | dot -Tpng -o OUTPUT.png`
 - see example directory for input/output

LICENSE:
========
Distributed under the [WTFPL](http://www.wtfpl.net/)
