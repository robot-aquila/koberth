1;

printf("ksplib.m loaded\n");
source("constants.m")

function r = ksp_test()
   r = 1
endfunction


# Расчет полотности атмосферы для указанной высоты.
# Параметры:  
# alt - высота над поверхностью
# Pp0 - давление на поверхности атм. (по умолчанию для Кербина)
# H - шкала высот (по умолчанию для Кербина)
function p = atm_density(alt, Pp0=1, H=5000)
    p = e .^ (-alt ./ H) .* Pp0 .* atm1dens
endfunction


# Расчет орбитальной скорости (для круговой орбиты над Кербином)
# Параметры: 
# alt - высота над поверхностью 
function Vorb = krb_orbital_velocity(alt)
    Vorb = sqrt(G .* krb_mass ./ (alt .+ krb_radius))
endfunction


# Расчет предельной скорости для атмосферы Кербина.
# Параметры: 
# alt - высота над поверхностью
# drag - коэффициент сопротивления (по умолчанию 0.2)
function Vterm = krb_terminal_velocity(alt, drag=0.2)
    r_e2 = (alt.+krb_radius).^2
    Vterm = sqrt((250 * G * krb_mass) ./ (r_e2 .* atm_density(alt) .* drag))
endfunction


# Расчет атмосферного сопротивления движущегося тела (для Кербина).
# Параметры:
# alt - высота над поверхностью
# vel - скорость движения
# mass - масса тела (по умолчанию 1)
# drag - коэффициент сопротивления (по умолчанию 0.2)
function Fd = krb_atm_drag(alt, vel, mass=1, drag=0.2)
    Fd = 0.5 .* atm_density(alt) .* (vel .^ 2) .* drag .* 0.008 .* mass
endfunction


# Расчет коэффициента сопротивления для безопасного приземления на Кербине.
# Параметры:
# mass - масса тела
# tolerance - предельная скорость приземления m/s (по умолчанию 8)
function d = krb_drag_4safelanding(mass, tolerance=8)
    d = (250 * G * krb_mass) / (atm_density(0) * krb_radius^2 * tolerance^2)
endfunction

# Получение дополнительного коэффициента атм. сопротивления.
# Функция предназначена для расчета кол-ва парашютов.
# Параметры:
# mass - масса тела
# tolerance - предельная скорость приземления m/s (по умолчанию 8)
function dc = krb_additional_chutes_drag(mass, tolerance=8)
    dc = krb_drag_4safelanding(mass, tolerance) .* mass .- 0.2 .* mass
endfunction


