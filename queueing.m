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
        

        function tablaResultados = corrida (p_sujetos, p_tLleg, p_tServ)
            import pkg.guia5.*;
            % Arreglo con los tiempos de servicio para cada sujeto/cliente
            tiemposServicio = guia5.exponencial(p_tServ, p_sujetos);
            % Arreglo con los tiempos entre las llegadas de cada sujeto/cliente
            tiemposEntreLlegadas = guia5.exponencial(p_tLleg, p_sujetos);
            tiemposEntreLlegadas(1,1) = 0;
            llegadaACola = zeros(1, p_sujetos);
            tiemposEnCola = zeros(1, p_sujetos);
            tiempo = 0;
            
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
                tiemposOcioServ = 0;
                % Llegada a la cola
                if llegadaACola(1, i) > 0
                    % Si no hay nadie en la cola el servidor esta ocioso
                    % hasta la llegada del cliente/sujeto
                    tiemposOcioServ = llegadaACola(1, i);
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
            queueing.mostrarResultadoCorrida(tablaResultados);
        end

        function mostrarResultadoCorrida(p_tabla)
            
            fprintf('\n\n\t\t\tEjecucion de Modelo de Colas\n\n');
            colNames = {'Sujeto', 'TiempoLlegadaACola','TiempoServicio','TiempoEntreLlegadas','TiempoEnCola','TiempoEnSistema','TiempoSalida', 'PersonasEnCola','TiempoOcioServicio'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
            
        end
        
        
       
        %% Recibe como parametros un array de lambdas de tiempos entre llegadas
        function tablaExperimento=experimento(p_corridas, p_sujetos, p_tLleg, p_tServ, p_i)
            tablaResultados = zeros (p_corridas, 9);
            tablaExperimento = zeros (p_sujetos * p_corridas, 9);
            posicionesFilas = 1:1:p_sujetos;
            posicionesColumnas = 1:1:9;
            v_barras = [];
                       
            for i = 1 : p_corridas
                tablaCorrida = queueing.corrida(p_sujetos, p_tLleg(1,i), p_tServ);
                
                %Numero de corrida
                tablaResultados(i, 1) = i;
                
                %PARAMETROS
                %Cantidad de sujetos
                tablaResultados(i, 2) = p_sujetos;
                %Lambda tiempo entre llegadas
                tablaResultados(i, 3) = p_tLleg(1,i);
                %Lambda tiempo de servicio
                tablaResultados(i, 4) = p_tServ;
                
                %RESULTADOS                
                %Media tiempo de llegada
                tablaResultados(i, 5) = mean(tablaCorrida(:, 2)); 
                %Media tiempo de espera en cola
                tablaResultados(i, 6) = mean(tablaCorrida(:, 5));
                %Media tiempo de permanencia en el sistema
                tablaResultados(i, 7) = mean(tablaCorrida(:, 6)); 
                %Media sujetos en la cola
                tablaResultados(i, 8) = mean(tablaCorrida(:, 8)); 
                %Media tiempo de ocio del servidor
                tablaResultados(i, 9) = mean(tablaCorrida(:, 9));
                
                valor_i = i;
                tablaExperimento(posicionesFilas + p_sujetos*(i - 1),posicionesColumnas) = tablaCorrida;
                
                y = [tablaResultados(i, 5) tablaResultados(i, 6) tablaResultados(i, 7)];
                v_barras = [v_barras; y];
            end
            
            fprintf('\n\n\t\t\tExperimento Modelo de Colas\n\n');
            colNames = {'Corrida','CantidadSujetos','TiempoLambdaEntreLlegadas','TiemposLambdaDeServicio','MediaTiempoLlegadaACola','MediaTiempoEnCola','MediaTiempoEnSistema','MediaPersonasEnCola','MediaTiempoOcioServicio'};
            sTable = array2table(tablaResultados,'VariableNames',colNames);
            disp (sTable);    
            
            queueing.graficarExperimento(v_barras, p_i)
        end
        
        function graficarExperimento(p_barras, p_i)
            b = bar(p_barras, 'LineWidth',1.5);
            str = sprintf('Tiempos promedios de las corridas del experimento %d', p_i);
            title(str);
           
           % b(1).FaceColor = 'r';
           % b(2).FaceColor = 'm';
           % b(3).FaceColor = 'c';
            
           ylabel('Tiempo en minutos');
            xlabel('Nro. de corrida');
            grid on
            legend(b,'Media tiempo de llegada','Media tiempo de espera en cola ','Media tiempo de permanencia en el sistema','location','northoutside');
            figure;
        end
    

        
        
        %% Recibe como parametros dos array de lambdas (tiempos entre llegadas y tiempo de servicio)
        % El largo del de p_tLleg debe ser igual al valor de p_corridas, y
        % el de p_tServ a p_experimentos
        function simulacion(p_experimentos, p_corridas, p_sujetos, p_tLleg, p_tServ)
            tablaSimulacion = zeros (p_experimentos, 9);
            v_barras = [];
                       
            for i = 1 : p_experimentos
                tablaExperimento = queueing.experimento(p_corridas, p_sujetos, p_tLleg, p_tServ(1,i), i);
                
                %Numero de corrida
                tablaSimulacion(i, 1) = i;
                
                %PARAMETROS
                %Cantidad de sujetos
                tablaSimulacion(i, 2) = p_sujetos;
                %Lambda tiempo de servicio
                tablaSimulacion(i, 3) = p_tServ(1,i);
                
                %RESULTADOS 
                %Media tiempo de Servicio
                tablaSimulacion(i, 4) = mean(tablaExperimento(:, 3));
                %Media tiempo de llegada
                tablaSimulacion(i, 5) = mean(tablaExperimento(:, 2)); 
                %Variacion de tiempo de llegada
                tablaSimulacion(i, 6) = std(tablaExperimento(:, 2)); 
                %Media tiempo de espera en cola
                tablaSimulacion(i, 7) = mean(tablaExperimento(:, 5));
                %Media tiempo de permanencia en el sistema
                tablaSimulacion(i, 8) = mean(tablaExperimento(:, 6));  
                %Media tiempo de ocio del servidor
                tablaSimulacion(i, 9) = mean(tablaExperimento(:, 9)); 
               
                y = [tablaSimulacion(i, 5) tablaSimulacion(i, 7) tablaSimulacion(i, 8)];
                v_barras = [v_barras; y];
            end
            
            queueing.mostrarResultadoSimulacion(tablaSimulacion); 
            queueing.graficarSimulacion(v_barras)
        end
        
        function graficarSimulacion(p_barras)
            b = bar(p_barras, 'EdgeColor',[.5 .1 .5], 'LineWidth',2, 'FaceColor','flat');
            title('Tiempos promedios de los experimentos de la simulacion');
            ylabel('Tiempo en minutos');
            xlabel('Nro. de experimento');
            grid on
            legend(b,'Media tiempo de llegada','Media tiempo de espera en cola ','Media tiempo de permanencia en el sistema','location','northoutside');
            figure;
        end
        
        function mostrarResultadoSimulacion(p_tabla)
            fprintf('\n\n\t\t\tSimulacion Modelo de Colas\n\n');
            colNames = {'Experimento','CantidadSujetos','TiemposLambdaDeServicio','MediaTiempoServicio','MediaTiempoLlegadaACola','VariacionTiempoLlegada','MediaTiempoEnCola','MediaTiempoEnSistema','MediaTiempoOcioServicio'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
        end


    end

end