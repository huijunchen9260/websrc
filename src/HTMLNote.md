# Note on Website Creation


## `<dialog>`

Useful popup windows using some javascript

<dialog id="myDialog">
  <p>Hello! I'm a modal.</p>
  <button onclick="document.getElementById('myDialog').close()">Close</button>
</dialog>
<button onclick="document.getElementById('myDialog').showModal()">Open Modal</button>

```HTML
<dialog id="myDialog">
  <p>Hello! I'm a modal.</p>
  <button onclick="document.getElementById('myDialog').close()">Close</button>
</dialog>
<button onclick="document.getElementById('myDialog').showModal()">Open Modal</button>
```

## `details`

Create collapsible section in pure HTML elements.

<details>
  <summary>Click to expand</summary>
  Hidden content here!
</details>

```HTML
<details>
  <summary>Click to expand</summary>
  Hidden content here!
</details>
```
