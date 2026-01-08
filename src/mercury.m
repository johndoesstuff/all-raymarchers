:- module mercury.
:- interface.
:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module int.
:- import_module float.
:- import_module math.

% Types for managing scene and screen
:- type point ---> point(x::float, y::float, z::float).
:- type scene_config ---> scene_config(
	camera::point,
	repeat::float,
	sphere_radius::float,
	steps::int
).
:- type screen_config ---> screen_config(
	width::int,
	height::int
).

% Couldn't find floating mod in docs
:- func fmod(float, float) = float.
fmod(N, D) = (N - floor(N / D) * D).

% Operator overloading
:- func (point) + (point) = point.
P1 + P2 = point(P1^x + P2^x, P1^y + P2^y, P1^z + P2^z).
:- func (point) * (float) = point.
P * S = point(P^x * S, P^y * S, P^z * S).

% Util
:- func wrap(point, scene_config) = point.
:- func hypot(point) = float.
:- func normalize(point) = point.
:- func sdf(point, scene_config) = float.

wrap(N, C) = point(
			fmod((N^x + C^repeat / 2.0), C^repeat) - C^repeat / 2.0,
			fmod((N^y + C^repeat / 2.0), C^repeat) - C^repeat / 2.0,
			fmod((N^z + C^repeat / 2.0), C^repeat) - C^repeat / 2.0
		).

hypot(N) = sqrt((N^x * N^x) + (N^y * N^y) + (N^z * N^z)).

normalize(N) = point(N^x / hypot(N), N^y / hypot(N), N^z / hypot(N)).

sdf(N, C) = hypot(wrap(N, C)) - C^sphere_radius.

% Render screen
:- pred render_scene(screen_config::in, scene_config::in, io::di, io::uo) is det.
render_scene(Screen, Scene, !IO) :- render_rows(0, Screen, Scene, !IO).

:- pred render_rows(int::in, screen_config::in, scene_config::in, io::di, io::uo) is det.
render_rows(Y, Screen, Scene, !IO) :-
	(
		if Y < Screen^height then
			render_cols(0, Y, Screen, Scene, !IO),
			io.nl(!IO),
			render_rows(Y + 1, Screen, Scene, !IO)
		else
			true
	).

:- pred render_cols(int::in, int::in, screen_config::in, scene_config::in, io::di, io::uo) is det.
render_cols(X, Y, Screen, Scene, !IO) :-
	(
		if X < Screen^width then
			render_pixel(X, Y, Screen, Scene, !IO),
			render_cols(X + 1, Y, Screen, Scene, !IO)
		else
			true
	).

% Cast pixel
:- pred render_pixel(int::in, int::in, screen_config::in, scene_config::in, io::di, io::uo) is det.
render_pixel(X, Y, Screen, Scene, !IO) :-
	(
		Width = float(Screen^width),
		Height = float(Screen^height),
		Dir = normalize(point( float(X) / Width - 0.5, float(Y) / Height - 0.5, 1.0 )),
		march_dir(Scene^camera, Dir, Scene, 0.0, Traveled, 0),
		( if Traveled < 5.0 then
			io.write_char('#', !IO)
		else if Traveled < 10.0 then
			io.write_char('|', !IO)
		else if Traveled < 15.0 then
			io.write_char(':', !IO)
		else if Traveled < 20.0 then
			io.write_char('.', !IO)
		else
			io.write_char(' ', !IO)
		)
	).

:- pred march_dir(point::in, point::in, scene_config::in, float::in, float::out, int::in) is det.
march_dir(Pos, Dir, Scene, Traveled, FinalDist, Step) :-
	(
		if Step < Scene^steps then
			Safe = sdf(Pos, Scene),
			march_dir(Pos + Dir * Safe, Dir, Scene, Traveled + Safe, FinalDist, Step + 1)
		else
			FinalDist = Traveled
	).

% Main
main(!IO) :- (
	Screen = screen_config(
		50, % width
		20  % height
	),
	Scene = scene_config(
		point( 1.0, 2.0, -4.0 ), % camera		
		5.0, % repeat
		1.5, % radius
		40   % steps
	),
	render_scene(Screen, Scene, !IO)
).
