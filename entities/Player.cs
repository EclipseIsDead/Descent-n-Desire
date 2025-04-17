using Godot;
using System;

public partial class Player : Node3D
{
	[Export] private float moveSpeed = 0.5f; // Time in seconds to move one cell
	[Export] private float cellSize = 2.0f; // Size of each grid cell
	
	private bool isMoving = false;
	private Tween currentTween;
	private RayCast3D frontRayCast;
	private RayCast3D backRayCast;
	private Camera3D playerCamera;
	
	public override void _Ready()
	{
		// Get the raycast nodes
		frontRayCast = GetNode<RayCast3D>("FrontRayCast");
		backRayCast = GetNode<RayCast3D>("BackRayCast");
		playerCamera = GetNode<Camera3D>("Camera3D");
	}
	
	public override void _PhysicsProcess(double delta)
	{
		// Only allow movement input when not already moving
		if (!isMoving)
		{
			HandleMovement();
			HandleRotation();
		}
	}
	
	private void HandleMovement()
	{
		Vector3 moveDirection = Vector3.Zero;
		
		if (Input.IsActionJustPressed("ui_up"))
			moveDirection = -Transform.Basis.Z;
		else if (Input.IsActionJustPressed("ui_down"))
			moveDirection = Transform.Basis.Z;
			
		if (moveDirection != Vector3.Zero)
		{
			TryMove(moveDirection);
		}
	}
	
	private void HandleRotation()
	{
		if (Input.IsActionJustPressed("ui_left"))
		{
			RotatePlayer(90);
		}
		else if (Input.IsActionJustPressed("ui_right"))
		{
			RotatePlayer(-90);
		}
	}
	
	private void TryMove(Vector3 direction)
	{
		// Determine which raycast to use
		RayCast3D rayToUse;
		if (direction.Dot(-Transform.Basis.Z) > 0) // Moving forward
			rayToUse = frontRayCast;
		else if (direction.Dot(Transform.Basis.Z) > 0) // Moving backward
			rayToUse = backRayCast;
		else
			rayToUse = frontRayCast; // For side movement, use front raycast
		
		// Check if the way is clear
		if (!rayToUse.IsColliding())
		{
			// Calculate target position (grid-aligned)
			Vector3 targetPosition = Position + direction * cellSize;
			
			// Use Tween for smooth movement
			isMoving = true;
			currentTween = CreateTween();
			currentTween.TweenProperty(this, "position", targetPosition, moveSpeed);
			currentTween.Finished += OnMoveCompleted;
		}
	}
	
	private void RotatePlayer(float degrees)
	{
		if (isMoving)
			return;
			
		// Create a tween for smooth rotation
		isMoving = true;
		float targetRotation = Mathf.DegToRad(degrees);
		Vector3 currentRotation = Rotation;
		Vector3 targetRotationVector = new Vector3(
			currentRotation.X,
			currentRotation.Y + targetRotation,
			currentRotation.Z
		);
		
		currentTween = CreateTween();
		currentTween.TweenProperty(this, "rotation", targetRotationVector, moveSpeed);
		currentTween.Finished += OnMoveCompleted;
	}
	
	private void OnMoveCompleted()
	{
		isMoving = false;
	}
}
