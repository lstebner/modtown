# class RenderedObject extends RenderedObject

RenderedObject is intended to be extended by any object that is going to be rendered somewhere. It sets up the ability to use a "container" to render to and also a template and view data. It provides several helper methods that can be overridden for easily managing this element. 

## Properties

- @container: jQuery object representing the element for this object
- @tmpl: default `null` | represents a template to use in the render method and can be set using `set_template`
- @rendered: default `false` | a flag that can be used to prevent re-rendering. 
- @view_data: default `{}` | anything in this will be automatically passed to the template during render. This can be accessed directly or through the `set_view_data` method.
- opts: default `{}` | options are like settings that can be passed to the constructor. Defaults can be set up in sub-classes by overriding the `default_opts` method

## Methods

- constructor: (container, opts)
    - container: the selector for the container element
    - opts: default `{}` used to set initial config
- default_opts: ()
    - override this method in sub-classes to set the default values for opts passed to the constructor
- set_opts: (opts)
    - this method is used to set the opts. The constructor uses it automatically, but it can be used at any time to reset them.
- set_template: (tmpl_id)
    - tmpl_id: the selector to use for the template
    - this method sets the @tmpl property
- template_id: ()
    - This method is used like `default_opts` to override in sub-classes to specify the ID of the template to use. The constructor will check this for setting the initial template.
- set_view_data: (key, val)
    - sets a value on the `view_data` object 
- clear_view_data: ()
    - resets all `view_data`
- setup_events: ()
    - meant to be overridden in subclasses, but is automatically called from the constructor
- render: (force)
    - force can be specified to render even if `rendered` is flagged `true` 
    - calls a re-render using the tmpl. Automatically passes
    `view_data` to template.
