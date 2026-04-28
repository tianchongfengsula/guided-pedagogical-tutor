# NOTES, ISSUES and LESSON LEARNED

## Version 0.0.2.2 Issues

### Firefox's weird quirk

```
Import maps are not allowed after a module load or preload has started. localhost:3000
Uncaught TypeError: The specifier “application” was a bare specifier, but was not remapped to anything. Relative module specifiers must start with “./”, “../” or “/”. localhost:3000:46:30
Firefox can’t establish a connection to the server at ws://localhost:3000/cable. turbo-eced32e0.js:5692:24
```

#### The solution

```ruby
<%= javascript_importmap_tags %>                       <!-- 1: map first -->

<%= javascript_include_tag "turbo.min",
      type: "module", defer: true,
      "data-turbo-track": "reload" %>                  <!-- 2: Turbo, deferred -->

<%= javascript_include_tag "application",
      type: "module", defer: true %>                   <!-- 3: your app, deferred -->
```
Module should be the last after the import map is read, that's the rule. a strict rule by firefox
While brave(or chromium) browsers can tolerate that, firefox is not.

##### Chromium-based browsers vs Firefox

Firefox will lock the importmap if is finds a module first
Whilst Chromium-based are more forgiving then didn't lock up the importmap
