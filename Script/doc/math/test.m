1;

source("ksplib.m")

#[alt, vel] = meshgrid([0:1000:20000], [0:2000:10000])
#drag = krb_atm_drag(alt, vel)
#mesh(vel, alt, drag)
#grid on
#axis("ij")
#xlabel 'Velocity'
#ylabel 'Altitude'
#zlabel 'Drag'


# Тест нахождения предельной скорости
#d = (250 * G * krb_mass) / (atm1dens * krb_radius^2 * 7.56^2)
#Vt = krb_terminal_velocity(0, 35.07)

res = krb_additional_chutes_drag(4)
printf("Need additional drag: %d\n", res)
