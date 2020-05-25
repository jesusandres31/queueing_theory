%
% M/M/1
% M: Distribucion EXPONENCIAL del tiempo entre llegadas de clientes a la cola 
% M: Distribucion EXPONENCIAL del tiempo de servicio al cliente que le toca ser atendido 
% 1: Una sola cola
%
% Lambda variable por cada tiempo de la distribucion de la corrida, experimento o simulacion? (El tiempo de llegada y el de servicio depende de lambda?)
%
% Cola infinita
%
%  Tipo de cola FIFO (First In First Out)
%

classdef queueing

    methods (Static)

        function corrida (p_sujetos, p_tLleg, p_tServ)
            import pkg.guia5.*;
            % Arreglo con los tiempos de servicio para cada sujeto/cliente
            tiemposServicio = guia5.exponencial(p_tServ, p_sujetos);
            % Arreglo con los tiempos entre las llegadas de cada sujeto/cliente
            tiemposEntreLlegadas = guia5.exponencial(p_tLleg, p_sujetos);
            tiemposEntreLlegadas(1,1) = 0;
            llegadaACola = zeros(1, p_sujetos);
            tiemposEnCola = zeros(1, p_sujetos);
            tiempo = 0;
            tiemposOcioServ = 0;
            tablaResultados = zeros(p_sujetos,9);

            % Calculos del tiempo de llegada de cada cliente/sujeto a la
            % cola
            llegadaACola(1, 1) = tiemposEntreLlegadas(1, 1);
            % El tiempo (momento) en el cual el cliente/sujeto llega al sistema
            tablaResultados(1,2) = llegadaACola(1, 1);            
            for i = 2 : p_sujetos
                llegadaACola(1, i) = tiemposEntreLlegadas(1, i) +llegadaACola(1, i - 1);
                % El tiempo (momento) en el cual el cliente/sujeto llega al sistema
                tablaResultados(i,2) = llegadaACola(1,i);
            end
            
            for i = 1 : p_sujetos 
                
                % Llegada a la cola
                if llegadaACola(1, i) > 0
                    % Si no hay nadie en la cola el servidor esta ocioso
                    % hasta la llegada del cliente/sujeto
                    tiemposOcioServ = tiemposOcioServ + llegadaACola(1, i);
                    tiempo = tiempo + llegadaACola(1, i);
                    % Se le resta el tiempo transcurrido a los tiempos de 
                    % llegadas de todos los clientes/sujetos
                    llegadaACola(1, :) = llegadaACola(1, :) - llegadaACola(1, i);
                                        
                else
                    tiemposEnCola(1, i) = llegadaACola(1, i) * (-1);
                end   
                              
                % Tiempo transcurrido hasta que el cliente/sujeto termina 
                % de ser atendido efectivamente
                tiempo = tiempo + tiemposServicio(1, i); 
                % Ese tiempo de atencion transcurre tambien en los tiempos 
                % de la cola
                llegadaACola(1, :) = llegadaACola(1, :) - tiemposServicio(1, i); 
                
                % Cuenta las personas en la cola hasta que el sujeto/cliente
                % termina de ser atendido
                sujetosCola = 0;
                if i > 1
                    % No se cuenta al cliente/sujeto siendo atendido porque
                    % este no esta en la cola
                    for j = 1 : i - 1
                        if tablaResultados(i, 2) <= tablaResultados(j, 7)
                          sujetosCola = sujetosCola + 1;
                        end
                    end
                end
                
                % Numero de sujeto/cliente que llega a la cola
                tablaResultados(i, 1) = i;
                % Cantidad de tiempo que lleva atender al sujeto/cliente
                tablaResultados(i, 3) = tiemposServicio(1, i);  
                % Cantidad de tiempo que transcurre entre las llegadas de
                % clientes/sujetos consecutivos
                tablaResultados(i, 4) = tiemposEntreLlegadas(1, i);
                % Cantidad de tiempo que espera un cliente/sujeto en la
                % cola para ser atendido
                tablaResultados(i, 5) = tiemposEnCola(1, i);
                % Cantidad de tiempo que un cliente/sujeto esta en el
                % sistema
                tablaResultados(i, 6) = tiemposEnCola(1, i) + tiemposServicio(1, i);
                % El tiempo (momento) en el cual el cliente/sujeto sale del sistema
                tablaResultados(i, 7) = tiempo;
                % Cantidad de clientes/sujetos esperando en la cola para
                % ser atendidos
                tablaResultados(i, 8) = sujetosCola;
                % Cantidad de tiempo que el servidor no esta atendiendo
                tablaResultados(i, 9) = tiemposOcioServ;
               
            end   
            queueing.mostrarResultadoSimulacion(tablaResultados);
        end

        function mostrarResultadoSimulacion(p_tabla)
            
            fprintf('\n\n\t\t\tEjecucion de Modelo de Colas\n\n');
            colNames = {'Sujeto', 'TiempoLlegadaACola','TiempoServicio','TiempoEntreLlegadas','TiempoEnCola','TiempoEnSistema','TiempoSalida', 'PersonasEnCola','TiempoOcioServicio'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
            
        end

    end

end