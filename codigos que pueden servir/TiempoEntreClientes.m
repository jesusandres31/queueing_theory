function [x] = TiempoEntreClientes(TiempoLlegada)
    n = length(TiempoLlegada);
    x(1) = 0;
    for i=2:n
        x(i) = TiempoLlegada(i) - TiempoLlegada(i-1);
    end
end