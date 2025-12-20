#include <stdio.h>
#include <math.h>

// all raymarchers will have this width
int screen_width = 50;
int screen_height = 20;
int steps = 40;

// all terminal outputs will be: 
char shading[] = " .:|#";

// standard setup
double repeat_space = 5.0;
double sphere_radius = 1.5;

// implementation specific
typedef struct {
	double x;
	double y;
	double z;
} point;

// standard camera position
point camera = { 1.0, 2.0, -4.0 };

double mod(double x, double s) {
	return x - s * floor(x / s);
}

double wrap(double x, double s) {
	return mod(x + s*0.5, s) - s*0.5;
}

double sdf(point* p) {
	point p_m = { wrap(p->x, repeat_space), 
		wrap(p->y, repeat_space), 
		wrap(p->z, repeat_space) };
	double d = sqrt(p_m.x*p_m.x + p_m.y*p_m.y + p_m.z*p_m.z);
	return d - sphere_radius;
}

void normalize(point* p) {
	double d = sqrt(p->x*p->x + p->y*p->y + p->z*p->z);
	p->x /= d;
	p->y /= d;
	p->z /= d;
}

void acc(point* a, point* b) {
	a->x += b->x;
	a->y += b->y;
	a->z += b->z;
}

point mul(point p, double c) {
	p.x *= c;
	p.y *= c;
	p.z *= c;
	return p;
}

int main() {
	for (int y = -screen_height/2; y < screen_height/2; y++) {
		for (int x = -screen_width/2; x < screen_width/2; x++) {
			point dir = { (double)x/screen_width, (double)y/screen_height, 1.0 };
			normalize(&dir);
			point pos = camera;
			double traveled = 0.0;
			for (int i = 0; i < steps; i++) {
				double safe = sdf(&pos);
				traveled += safe;
				point vec = mul(dir, safe);
				acc(&pos, &vec);
			}
			if (traveled < 5)
				printf("%c", shading[4]);
			else if (traveled < 10)
				printf("%c", shading[3]);
			else if (traveled < 15)
				printf("%c", shading[2]);
			else if (traveled < 20)
				printf("%c", shading[1]);
			else
				printf("%c", shading[0]);
		}
		printf("\n");
	}
}
