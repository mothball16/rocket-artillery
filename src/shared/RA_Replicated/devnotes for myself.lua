--[=[
SHOOTY STEPS (from request to projectile destruction)

relevant:
TurretController - composition root of turret behaviors
AmmoContainer - one of the submodules created inside TurretController
ProjectileController - persistent client-side projectile controller

pipeline:
1. TurretController reads input, asks AmmoContainer to give it a rocket of <type>
2. AmmoContainer searches for first rocket of <type>, and returns rocket or nil
3. TurretController either invalidates the request (no rocket), or tells ProjectileController to fire a rocket
4. ProjectileController creates the projectile, and performs a lookup for the projectile's AmmoConfig
5. ProjectileController either invalidates the request (no ammoconfig), or creates a Projectile object
6. ProjectileController attaches behaviors (as specfied in config) to the Projectile object, and then initiates OnFire from the config
7. Projectile's OnFire runs until it determines it had hit something/ended its lifespan
8. Projectile's OnHit runs
9. Projectile is destroyed

revisions on OnHit
- OnHit should be accessible from the config itself
- it should mostly be a server thing, with something for the client optionally that we can pass to the end of our projectile behavior

revisions on Config/Required/Prefab responsibilities
- required: ONLY should hold either state or object values. No configuration is to be performed through the required folder.
- config: Used for component configurations. STRICTLY cannot be responsible for any initialization.
- prefab: Used for entire system configuration, including addition and removal from the object registry. Defines which configs to use for
  a set of components, with the assumption that whatever controller takes the prefab will know what to do with it.

todo for ObjectRegistry/ObjectLifetimeListener/ObjectInitializer relationship
- there is way too much indirection going on with this an ObjectLifetimeListeners have their own registry. this is dumb
]=]

