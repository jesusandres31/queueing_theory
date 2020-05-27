
%% Propuestas para presentacion de parcial
%
% Simulacion de turnos en un banco, donde el tiempo de espera maximo de los
% clientes sea de menos de 20 minutos el tiempo de ocio del servidor sea 
% menor a 10 minutos; y la cantidad de turnos por dia sea fija en un lapso
% de x horas
%
% Se desea saber cual es la cantidad de servidores que se necesitan para
% ello...
%
%%
%
% M/M/N
% M: Distribucion EXPONENCIAL del tiempo entre llegadas de clientes a la cola 
% M: Distribucion EXPONENCIAL del tiempo de servicio al cliente que le toca ser atendido 
% N cantidad de servidores
% 1: Una sola cola
%
%
% Cola finita
%
%  Tipo de cola FIFO (First In First Out)
%%

classdef parcial2

    methods (Static)
        

        function corrida (p_mediaClientes, p_cantHoras, p_tServ, p_maxTiempoEspera, p_maxTiempoOcio, p_cantServidores)
            import pkg.guia5.*;          
            % Arreglo con los tiempos entre las llegadas de cada sujeto/cliente
            cantClientes = guia5.poisson(p_mediaClientes, 1);          
            %llegadaACola = zeros(1, cantClientes);
            tiemposEnCola = zeros(1, cantClientes);
            tiempo = 0;
            tiemposOcioServ = 0;
            tablaResultados = zeros(cantClientes,9);
            
            
            servidores = zeros(2,p_cantServidores);
            %Primer Fila tiempo servicio
            %Segunda fila tiempo ocio
            tiemposServicio = guia5.exponencial(p_tServ, cantClientes);



            llegadaACola = 0:(p_cantHoras*60)/cantClientes:(p_cantHoras + 1)*60;
            tablaResultados(:,2) = llegadaACola(1,1:1:cantClientes).';
            tablaResultados(1, 4) = 0;
            memoriaMin = zeros(1,p_cantServidores);
            
            
            for i = 1 : cantClientes 
                
                % Llegada a la cola
                tiempo = tiempo + llegadaACola(1, i);
                servidores(1,:) = servidores(1,:) - llegadaACola(1, i);
                
                
                %Control Servidores
                servLibre = false;
                for j = 1 : p_cantServidores
                    if servLibre
                         if servidores(1,j) <= 0
                            servidores(2,j) = servidores(2,j) + llegadaACola(1, i);
                         end                           
                    else                                                  
                        if servidores(1,j) <= 0
                            servLibre = true;
                            servidores(1,j) = tiemposServicio(1,i);                                
                        end
                    end
                end
                
                llegadaACola(1, :) = llegadaACola(1, :) - llegadaACola(1, i);
                sujetosCola = 0;
                
                
                if not(servLibre) 
                    % Cuenta las personas en la cola hasta que el sujeto/cliente
                    % termina de ser atendido
                    
                    % No se cuenta al cliente/sujeto siendo atendido porque
                    % este no esta en la cola
                    for j = 1 : i - 1
                        if tablaResultados(i, 2) <= (tablaResultados(j, 7) - tiemposServicio(1,j))
                          sujetosCola = sujetosCola + 1;
                        end
                    end
                    
                    [minimo, indiceMin] =  min(servidores(1,p_cantServidores));
                    %%
                    %Donde se presentan los problemas, cuando se empiezan a
                    %encolar los clientes en la fila
                    %
                    if sujetosCola > 0
                        if sujetosCola == 1
                            memoriaMin = servidores(1,:);
                        else
                            [minimo, indiceMin] =  min(memoriaMin);
                        end                            
                        memoriaMin(1,indiceMin) = memoriaMin(1,indiceMin) + tiemposServicio(1,i - 1);
                        [minimo, indiceMin] =  min(memoriaMin);
                        fprintf('Index=%i. Value=%.4f\n',minimo,minimo);
                    end
                    %
                    %
                    %
                    %%
                    
                    tiemposEnCola(1, i) = minimo;
                    tiempo = tiempo + minimo;
                    servidores(1,:) = servidores(1,:) - minimo;
                    llegadaACola(1, :) = llegadaACola(1, :) - minimo;
                    servidores(1,indiceMin) = tiemposServicio(1,i);
                    
                    
                end
                              
                
               
                if i > 1                    
                    % Cantidad de tiempo que transcurre entre las llegadas de
                    % clientes/sujetos consecutivos
                    tablaResultados(i, 4) = tablaResultados(i,2) - tablaResultados(i-1,2);
                end
                
                % Numero de sujeto/cliente que llega a la cola
                tablaResultados(i, 1) = i;
                % Cantidad de tiempo que lleva atender al sujeto/cliente
                tablaResultados(i, 3) = tiemposServicio(1, i);                  
                % Cantidad de tiempo que espera un cliente/sujeto en la
                % cola para ser atendido
                tablaResultados(i, 5) = tiemposEnCola(1, i);
                % Cantidad de tiempo que un cliente/sujeto esta en el
                % sistema
                tablaResultados(i, 6) = tiemposEnCola(1, i) + tiemposServicio(1, i);
                % El tiempo (momento) en el cual el cliente/sujeto sale del sistema
                tablaResultados(i, 7) = tiempo + tiemposServicio(1, i);
                % Cantidad de clientes/sujetos esperando en la cola para
                % ser atendidos
                tablaResultados(i, 8) = sujetosCola;
                % Cantidad de tiempo que el servidor no esta atendiendo
                %tablaResultados(i, 9) = tiemposOcioServ;
               
            end   
            queueing.mostrarResultadoCorrida(tablaResultados);
        end
        

        function mostrarResultadoCorrida(p_tabla)
            
            fprintf('\n\n\t\t\tEjecucion de Modelo de Colas\n\n');
            colNames = {'Sujeto', 'TiempoLlegadaACola','TiempoServicio','TiempoEntreLlegadas','TiempoEnCola','TiempoEnSistema','TiempoSalida', 'PersonasEnCola'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
            
        end
        

    end

end