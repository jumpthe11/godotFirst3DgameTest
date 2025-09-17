using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
	

public partial class Player : CharacterBody3D
{
	[Export]
	public int Speed { get; set; } = 14;

	[Export]
	public int FallAcceleration { get; set; } = 75;

	[Export]
	public int JumpImpulse { get; set; } = 20;

	[Export]
	public int BounceImpulse { get; set; } = 16;

	private Vector3 _targetVelocity = Vector3.Zero;

	public override void _PhysicsProcess(double delta)
	{
		// We create a local variable to store the input direction.
		var direction = Vector3.Zero;

		// We check for each move input and update the direction accordingly.
		if (Input.IsActionPressed("move_right"))
		{
			direction.X += 1.0f;
		}
		if (Input.IsActionPressed("move_left"))
		{
			direction.X -= 1.0f;
		}
		if (Input.IsActionPressed("move_back"))
		{
			// Notice how we are working with the vector's X and Z axes.
			// In 3D, the XZ plane is the ground plane.
			direction.Z += 1.0f;
		}
		if (Input.IsActionPressed("move_forward"))
		{
			direction.Z -= 1.0f;
		}
		if (direction != Vector3.Zero)
		{
			direction = direction.Normalized();
			// Setting the basis property will affect the rotation of the node.
			GetNode<Node3D>("Pivot").Basis = Basis.LookingAt(direction);
		}
		//Ground Velocity
		_targetVelocity.X = direction.X * Speed;
		_targetVelocity.Z = direction.Z * Speed;

		//Vertical velocity
		if (!IsOnFloor()) //f in the air, fall towards the floor. Bruh gravity
		{
			_targetVelocity.Y -= FallAcceleration * (float)delta;
		}
		//Moving the character
		Velocity = _targetVelocity;
		MoveAndSlide();

		//Jumping
		if (IsOnFloor() && Input.IsActionJustPressed("jump"))
		{
			_targetVelocity.Y = JumpImpulse;
		}




	}

}
