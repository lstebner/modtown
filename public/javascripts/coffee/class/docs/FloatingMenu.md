# class FloatingMenu extends RenderedObject

This class makes button menus that can be easily positioned anywhere and used to take input from the user. Ideally this class is sub-classed to create more specific menus, but it can be used directly and just passed a list of 'items' to use.

## Properties

- title: default `Floating Menu` | The title to give the menu
- items: default `[]` | The items to render buttons for. These should be key/val pairs where the "key" represents the "action" that will be triggered and the "val" is the label for the action.

## Methods

#### constructor

Nothing fancy to see here. This class will create an element for itself and append to the body if no `container` is given.

#### close

Close the menu.

#### open

Open the menu.

#### destroy

Close the menu and remove it from the DOM.

#### set_position (x, y)

Change the position of the menu to the requested `x` and `y` coordinates of the screen. Note that these are `fixed` positioned so these coordinates should be 0,0 based from the top left of the window.

#### trigger (event_name='item_selected', value)

Internal method used to trigger an event on the menu container. These can be listened to by the item that created the menu to get the selected item value back from the menu after the user selects something.

## Example Use

```javascript
menu = new FloatingMenu({
    title: 'Example Menu'
    items: {
        save_game: 'Save Game'
        cancel: 'Cancel'
    }
});

menu.set_position(400, 300);
menu.show();

menu.container.on('item_selected', function(e, action){
    if (action == "save_game"){
        save_game();
    }
    else if (action == "cancel"){
        menu.close();
    }
});
```
