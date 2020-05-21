function [x] = MenorTiempoServidor(tiemposervidor,cantservidores)
    menortiemposalida = tiemposervidor(1); 
    posicion = 1;
    for i=2:cantservidores
        if menortiemposalida > tiemposervidor(i)
            menortiemposalida = tiemposervidor(i);
            posicion = i;
        end
    end
    x = posicion;
end