
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

classdef UnClientePorTurno


    methods (Static)
        

        function corrida (p_maxCantClientes, p_cantHoras, p_tServ, p_cantServidores)
            import pkg.guia5.*;          
            % Arreglo con los tiempos entre las llegadas de cada sujeto/cliente
            cantClientes = guia5.poisson(p_maxCantClientes, 1);      
            if cantClientes > p_maxCantClientes
                cantClientes = p_maxCantClientes;
            end          
            tiemposEnCola = zeros(1, cantClientes);
            tiempo = 0;            
            tablaResultados = zeros(cantClientes,10 + p_cantServidores);
            
            % Tiempo de servicio asignado a servidores dinamicamente
            servidores = zeros(1,p_cantServidores);
            
            tiemposServicio = guia5.exponencial(p_tServ, cantClientes);


            llegadaACola = 0:(p_cantHoras*60)/cantClientes:(p_cantHoras + 1)*60;
            tablaResultados(:,2) = llegadaACola(1,1:1:cantClientes).';
            
            % Cantidad de tiempo que transcurre entre las llegadas de 
            % clientes/sujetos consecutivos
            tablaResultados(:, 4) = (p_cantHoras*60)/cantClientes;
            tablaResultados(1, 4) = 0;
            
            
            for i = 1 : cantClientes 

                tiemposOcioServidores = zeros(1,p_cantServidores);
                
                % Llegada a la cola
                tiempo = tiempo + llegadaACola(1, i);
                servidores(1,:) = servidores(1,:) - llegadaACola(1, i);
                
                
                %Control Servidores
                servLibre = false;               
                for j = 1 : p_cantServidores
                    tiempoLibreServidor = servidores(1,j) * -1;
                    if servLibre
                        if servidores(1,j) <= 0
                            
                            tiemposOcioServidores(1,j) = tiempoLibreServidor;
                            servidores(1,j) = 0;
                        end
                    else
                        if servidores(1,j) <= 0 
                            
                            servLibre = true;
                            servidorAsignado = j;
                            tiemposOcioServidores(1,j) = tiempoLibreServidor;
                            servidores(1,j) = tiemposServicio(1,i); 
                        end
                    end
                end
                
                llegadaACola(1, :) = llegadaACola(1, :) - llegadaACola(1, i);
                sujetosCola = 0;
                
                %
                % Asignacion del servidor que se libere antes
                %
                if not(servLibre) 
                    % Cuenta las personas en la cola hasta que el sujeto/cliente
                    % termina de ser atendido
                    
                    % No se cuenta al cliente/sujeto siendo atendido porque
                    % este no esta en la cola
                    for j = 1 : i - 1
                        if tablaResultados(i, 2) < (tablaResultados(j, 7) - tiemposServicio(1,j) - 0.001)
                          sujetosCola = sujetosCola + 1;
                        end
                    end
                    
                    [minimo, indiceMin] =  min(servidores(1,:));
                    
                    servidorAsignado = indiceMin;
                    tiemposEnCola(1, i) = minimo;
                    tiempo = tiempo + minimo;
                    servidores(1,:) = servidores(1,:) - minimo;
                    llegadaACola(1, :) = llegadaACola(1, :) - minimo;
                    servidores(1,indiceMin) = tiemposServicio(1,i);                    
                    
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
                % Servidor Asignado
                tablaResultados(i, 9) = servidorAsignado;
                % Cantidad de tiempo que los servidores no estan atendiendo
                tablaResultados(i, 10:1: 9 + p_cantServidores) = tiemposOcioServidores;
                % Cantidad de tiempo que el servidor no esta atendiendo
                tablaResultados(i, 10 + p_cantServidores) = sum(tiemposOcioServidores);
               
            end    
            UnClientePorTurno.mostrarResultadoCorrida(tablaResultados);
        end
        

        function mostrarResultadoCorrida(p_tabla)
            
            fprintf('\n\n\t\t\tEjecucion de Modelo de Colas\n\n');
            colNames = {'Sujeto', 'TiempoLlegadaACola','TiempoServicio','TiempoEntreLlegadas','TiempoEnCola','TiempoEnSistema','TiempoSalida', 'PersonasEnCola', 'Servidor'};
            for i = 10 : size(p_tabla,2) - 1
                colNames{1,i} = strcat('TiempoOcioServidor', num2str(i - 8,'%i'));               
            end
            colNames{1,size(p_tabla,2)} = 'TiempoOcioServidorTotal';
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
            
        end
        

    end

end