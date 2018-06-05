1;

source("ksplib.m")

[alt, vel] = meshgrid([0:1000:20000], [0:2000:10000])
drag = krb_atm_drag(alt, vel)
mesh(vel, alt, drag)
grid on
axis("ij")
xlabel 'Velocity'
ylabel 'Altitude'
zlabel 'Drag'
