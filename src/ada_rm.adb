with Ada.Text_IO, Ada.Containers.Vectors, Ada.Numerics.Elementary_Functions;
use  Ada.Numerics.Elementary_Functions;

procedure Ada_rm is
   type Point is record
      X : Float := 0.0;
      Y : Float := 0.0;
      Z : Float := 0.0;
   end record;

   -- overload + for point addition
   function "+" (Left, Right : Point) return Point is
      Result : Point;
   begin
      Result.X := Left.X + Right.X;
      Result.Y := Left.Y + Right.Y;
      Result.Z := Left.Z + Right.Z;
      return Result;
   end "+";

   -- overload * for point multiplication
   function "*" (Left : Float; Right : Point) return Point is
      Result : Point;
   begin
      Result.X := Left * Right.X;
      Result.Y := Left * Right.Y;
      Result.Z := Left * Right.Z;
      return Result;
   end "*";

   -- fp Point mod
   function Wrap (Left : Point; Right : Float) return Point is
      Result : Point;
   begin
      Result.X := Left.X - Right * Float'Floor ((Left.X + Right/2.0) / Right);
      Result.Y := Left.Y - Right * Float'Floor ((Left.Y + Right/2.0) / Right);
      Result.Z := Left.Z - Right * Float'Floor ((Left.Z + Right/2.0) / Right);
      return Result;
   end Wrap;

   -- normalize direction
   function Normalize (Unnormalized : Point) return Point is
      Result : Point;
      Magnitude : Float;
   begin
      Magnitude := Sqrt(Unnormalized.X**2 + Unnormalized.Y**2 + Unnormalized.Z**2);
      Result := Unnormalized;
      Result.X := Result.X / Magnitude;
      Result.Y := Result.Y / Magnitude;
      Result.Z := Result.Z / Magnitude;
      return Result;
   end Normalize;

   -- setup
   Screen_Width : constant Integer := 50;
   Screen_Height : constant Integer := 20;

   Steps : constant Integer := 40;

   Space_Repeat : constant Float := 5.0;
   Sphere_Radius : constant Float := 1.5;

   Camera : constant Point := (X => 1.0, Y => 2.0, Z => -4.0);

   -- marching variables
   Traveled : Float := 0.0;
   Safe : Float := 0.0;

   Direction : Point := (X => 0.0, Y => 0.0, Z => 0.0);
   Position : Point := (X => 0.0, Y => 0.0, Z => 0.0);

   -- scene definition
   function SDF (Test_Point : Point) return Float is
      Result : Float;
      Wrapped_Point : Point;
   begin
      Wrapped_Point := Wrap(Test_Point, Space_Repeat);
      Result := Sqrt(Wrapped_Point.X**2 + Wrapped_Point.Y**2 + Wrapped_Point.Z**2) - Sphere_Radius;
      return Result;
   end SDF;

begin
   for Pixel_Y in 0 .. Screen_Height-1 loop
      for Pixel_X in 0 .. Screen_Width-1 loop
         Position := Camera;
         Direction := (
            X => Float(Pixel_X) / Float(Screen_Width) - 0.5,
            Y => Float(Pixel_Y) / Float(Screen_Height) - 0.5,
            Z => 1.0);
         Traveled := 0.0;
         Direction := Normalize(Direction);
         for Step in 1 .. Steps loop
            Safe := SDF(Position);
            Traveled := Traveled + Safe;
            Position := Position + (Safe * Direction);
         end loop;
         if Traveled < 5.0 then
            Ada.Text_IO.Put ("#");
         elsif Traveled < 10.0 then
            Ada.Text_IO.Put ("|");
         elsif Traveled < 15.0 then
            Ada.Text_IO.Put (":");
         elsif Traveled < 20.0 then
            Ada.Text_IO.Put (".");
         else
            Ada.Text_IO.Put (" ");
         end if;
      end loop;
      Ada.Text_IO.Put_Line ("");
   end loop;
end Ada_rm;
