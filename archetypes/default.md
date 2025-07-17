+++
title = '{{ replace (substr .File.ContentBaseName 11) "-" " " | title }}'
slug = '{{ substr .File.ContentBaseName 11 }}'
date = {{ .Date }}
draft = true
+++
