--[=[
for internal stuff
do not touchy



InitRoot documentation:
    - InitRoot is the entry point for objects on initialization
    - the InitRoot folder interacts with the LocalController, ServerController, and Prefab object values
    - if there is a LocalController or a ServerController value, it will call the constructor of that controller, passing the prefab as the first, and the required folder as the second
    - If there is no need for a controller on a side, delete the corresponding ObjectValue to indicate that this was an intentional decision. You can always add it back if you want later.
]=]