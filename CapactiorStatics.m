function [C, G, I, V] = CapactiorStatics(shape, material, distance, voltage, length, width, height, inner_radius, outer_radius)
    %define constants table
    dielectric_constants = readtable('Dielectric_Table.xlsx');
    e0 = 8.854e-12;
    names = ["Air", "Alumina", "Barium Titanate", "Glass", "Ice", "Mica", "Polyethylene", "Polystyrene", "Quartz (fused)", "Silicon", "Soil", "Teflon", "Water (distilled)"];
    for i = 1:13
        if names(i) == material
            index = i;
        end
    end
    info = table2array(dielectric_constants(index,2:4));
    %call each shape
    if shape == "P"
        [C, G, I, V] = parallel(info, voltage, length, width, distance);
    end
    if shape == "C"
        [C, G, I, V] = cylinder(info, voltage, height, inner_radius, outer_radius);
    end
    if shape == "S"
        [C, G, I, V] = spherical(info, voltage, inner_radius, outer_radius);
    end

    %parallel plate function
    function [C, G, I, V] = parallel(info, voltage, length, width, distance)
        %calculate capacitance
        C = e0*info(1)*length*width/distance;
        %calculate conductance
        G = info(3)*length*width/distance;
        %calcualte leakage current
        I = leakage_current(G, voltage);
        %calcultae vbr
        V = breakdown_voltage(distance, info(2));
    end

    %cylinder function
    function [C, G, I, V] = cylinder(info, voltage, height, outer_radius, inner_radius)
        %calculate capacitance
        C = 2*pi*info(1)*e0*height/(log(outer_radius/inner_radius));
        %calculate conductance
        G = info(3)*height;
        %calcualte leakage current
        I = leakage_current(G, voltage);
        %calcultae vbr
        V = breakdown_voltage(0, info(2));
    end

    %spherical function
    function [C, G, I, V] = spherical(info, voltage, inner_radius, outer_radius)
        %calculate capacitance
        C = info(1)*4*pi*e0/(1/inner_radius - 1/outer_radius);
        %calculate conductance
        G = info(3);
        %calcualte leakage current
        I = leakage_current(G, voltage);
        %calcultae vbr
        V = breakdown_voltage(0, info(2));
    end

    %leakage current function
    function I = leakage_current(G, V)
        I = G*V;
    end
    
    %breakdown voltage function
    function Vbr = breakdown_voltage(d, Ebr)
        Vbr = d*Ebr;
    end
end
