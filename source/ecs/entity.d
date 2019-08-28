module ecs.entity;

import ecs.icomponent;
import ecs.ientity;
import ecs.componentType;
import ecs.componentManager;


alias EntityId = uint;
static EntityId next_id = 0;

class Entity : IEntity
{
	public EntityId _id;
	public IComponent[ComponentTypeId] _components;
	public IComponent[ComponentTypeId] _disabledComponents;


	public this()
	{
		_id = next_id++;
	}


	/*
	 * Add a component to the refered index
	 * Each component has a an unique index based on it's type
	 * Use it's type instead of manual inserting an index
	 */
	public void addComponent(T)(ComponentTypeId id)
	{
		if (!hasComponent(id))
			_components[id] = new T;
	}


	/*
	 * Removes a component from the respective index
	 * Each component has an unique index based on it's type
	 * Use it's type instead of manual inserting an index 
	 */
	public void removeComponent(ComponentTypeId id)
	{
		if (hasComponent(id))
		{
			destroy(_components[id]);
			_components.remove(id);
		}
	}


	/*
	 * Moves an existing component to the disbled component array
	 * Only use this function if the entity needs the component in the future
	 * If the entity doesn't need it anymore use the 'RemoveComponent' function
	 */
	public void disableComponent(ComponentTypeId id)
	{
		if (hasComponent(id))
		{
			_disabledComponents[id] = _components[id];
			_components.remove(id);
		}
	}


	/*
	 * Enables a component if this is disabled
	 */
	public void enableComponent(ComponentTypeId id)
	{
		if (isComponentDisabled(id))
		{
			_components[id] = _disabledComponents[id];
			_disabledComponents.remove(id);
		}
	}


	/*
	 * Get a component from the respective index
	 * Each component has an unique index based on it's type
	 * Use it's type instead of manual inserting an index 
	 */
	public T getComponent(T)()
	{
		const ComponentTypeId id = getComponentType!T;
		if (hasComponent(id))
			return cast(T)(_components[id]);
		return null;
	}


	/*
	 * Get all components
	 * If possible use the GetComponent template, as it returns the respective type
	 */
	public IComponent[] getComponents()
	{
		IComponent[] ret;
		foreach(component; _components)
			ret ~= component;
		return ret;
	}


	/*
	 * Get all component types
	 */
	public ComponentTypeId[] getComponentTypes()
	{
		ComponentTypeId[] ret;
		foreach(key, component; _components)
			ret ~= key;
		return ret;
	}


	/*
	 * Returns true if the component in the respective index exists
	 * Every component has an unique index based on it's type
	 * Use it's type instead of manual inserting an index
	 */
	public bool hasComponent(ComponentTypeId id)
	{
		return (id in _components) !is null;
	}


	/*
	 * Returns true if all of the components in the respective indices exist
	 * Every component has an unique index based on it's type
	 * Use it's type instead of manual inserting an index
	 */
	public bool hasComponents(ComponentTypeId[] ids)
	{
		foreach(id; ids)
		{
			if (!hasComponent(id))
				return false;
		}
		return true;
	}


	/*
	 * Returns true there's at least one of the component in the respective indices exist
	 * Every component has an unique index based on it's type
	 * Use it's type instead of manual inserting an index
	 */
	public bool hasAnyComponent(ComponentTypeId[] ids)
	{
		foreach(id; ids)
		{
			if (hasComponent(id))
				return true;
		}
		return false;
	}


	/*
	 * Returns if a component is disabled
	 * It doesn't return any info about the existance of the component
	 * If the entity doesn't contain the component neither in '_components' nor '_disabledComponents' it will just return false
	 * For that reason it is recomended not to use this function
	 */
	public bool isComponentDisabled(ComponentTypeId id)
	{
		return (id in _disabledComponents) !is null;
	}


	public ComponentTypeId getComponentType(T)()
	{
		foreach(key, component; _components)
		{
			if (cast(T)(component) !is null)
				return key;
		}
		return 0;
	}
}


unittest
{
	Entity e = new Entity();

	assert(e._id == 0);
	assert(next_id == 1);
}


unittest
{
	Entity e = new Entity();

	e.addComponent!(PositionComponent)(1);

	assert(e.hasAnyComponent([1, 2]));
	assert(e.hasComponent(1));
	assert(cast(PositionComponent)(e.getComponent!PositionComponent) !is null);

	e.removeComponent(1);

	assert(!e.hasAnyComponent([1, 2]));
	assert(!e.hasComponent(1));
	assert(e.getComponent!PositionComponent is null);
}

unittest
{
	Entity e = new Entity();

	e.addComponent!(PositionComponent)(1);

	assert(!e.isComponentDisabled(1));

	e.disableComponent(1);

	assert(!e.hasComponent(1));
	assert(e.isComponentDisabled(1));
}