
%% Propuestas para presentacion de parcial
%
% Simulacion de turnos en un banco, donde el tiempo de espera maximo de los
% clientes y el tiempo de ocio del servidor sea menor a un umbral
% establecido; la cantidad de turnos por dia sea definida por una
% distribucion de Poisson y estos turnos se entregan a varios clientes
% cada x cantidad de minutos
%
% ALTERNATIVAS
%
% 1) Determinar cuantos servidores se necesitan para atender los clientes 
% de un mismo turno minimizando el tiempo de espera. (INTEGRADOR)
%
% 2) Determinar la separacion de tiempo entre turnos más a apropiada al
% tiempo de servicio de la cola (PARCIAL)
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
        
        
        function tablaCorrida = corrida(p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos)                       
            
            import pkg.guia5.*;          
            % Arreglo con los tiempos entre las llegadas de cada sujeto/cliente
            cantClientes = guia5.poisson(p_lambdaClientes, 1);      
            if cantClientes > p_maxCantClientes
                cantClientes = p_maxCantClientes;
            end          
            
            llegadaACola(1,1:1:p_cantClientesTurno) = 0;
            for i= p_cantClientesTurno + 1 : p_cantClientesTurno : cantClientes
                llegadaACola(1,i:1:p_cantClientesTurno + i - 1) = llegadaACola(1,i-1) + p_intervaloEntreTurnos;
            end
            
            % Cantidad de tiempo que transcurre entre las llegadas de 
            % clientes/sujetos consecutivos
            tiempoEntreLlegadas = zeros(1,cantClientes);
            tiempoEntreLlegadas(1,p_cantClientesTurno + 1:p_cantClientesTurno:cantClientes) = p_intervaloEntreTurnos;
            
            
            tablaResultados = zeros(cantClientes,10 + p_cantServidores);
            tablaCorrida = zeros(cantClientes,10);
            tablaResultados(:,2) = llegadaACola(1,1:1:cantClientes).';
            tablaResultados(:,4) = tiempoEntreLlegadas(1,1:1:cantClientes).';
            
            tiemposEnCola = zeros(1, cantClientes);
            tiempo = 0;      
            
            % Tiempo de servicio asignado a servidores dinamicamente
            servidores = zeros(1,p_cantServidores);
            
            tiemposServicio = guia5.exponencial(p_tServ, cantClientes);

            v_TiempoEnCola = [];
            v_OcioServidores = [];
            v_barras = [];
            
            
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
                % Numero de Servidor Asignado
                tablaResultados(i, 9) = servidorAsignado;
                % Cantidad de tiempo que los servidores no estan atendiendo
                tablaResultados(i, 10:1: 9 + p_cantServidores) = tiemposOcioServidores;
                % Cantidad de tiempo que el servidor no esta atendiendo
                tablaResultados(i, 10 + p_cantServidores) = sum(tiemposOcioServidores);
                
                tablaCorrida(i, 1:1:9) = tablaResultados(i, 1:1:9);
                tablaCorrida(i,10) = tablaResultados(i, 10 + p_cantServidores);
                
                v_TiempoEnCola = [v_TiempoEnCola tablaResultados(i, 5)];
                v_OcioServidores = [v_OcioServidores sum(tiemposOcioServidores)];

            end      
            parcial2.mostrarResultadoCorrida(tablaResultados);
            
            med_TiempoEnCola = (mean(v_TiempoEnCola));
            med_OcioServidores = (mean(v_OcioServidores));
            v_barras = [med_TiempoEnCola; med_OcioServidores];
           % parcial2.graficarCorrida(v_barras);
        end
        
        
        function graficarCorrida(p_barras)
           figure(1)
           b = bar(p_barras, 'EdgeColor',[.1 .1 0], 'LineWidth',1.5, 'FaceColor','flat');    
           b.CData(1,:) = [0 .5 .5];
           b.CData(2,:) = [.5 0 .5];
           names={ 'Espera en Cola'; 'Ocio Servidores' };
           set(gca,'xticklabel',names,'FontSize',10);
         % xtickangle(45);
         % legend(b, 'Media tiempo de llegada.','Media tiempo de espera en cola.','location','northoutside');
         % legend([b(1), b(2)], '2014 Data','2015 Data')
           title('Tiempos promedios de la simulación.');
           ylabel('Tiempo en minutos.');
           grid on
        end


        function mostrarResultadoCorrida(p_tabla)
            
            fprintf('\n\n\t\t\tEjecucion de Modelo de Colas\n\n');
            colNames = {'Sujeto', 'TiempoLlegadaACola','TiempoServicio','TiempoEntreLlegadas','TiempoEnCola','TiempoEnSistema','TiempoSalida', 'PersonasEnCola', 'Servidor'};
            for i = 10 : size(p_tabla,2) - 1
                colNames{1,i} = strcat('TiempoOcioServidor', num2str(i - 9,'%i'));               
            end
            colNames{1,size(p_tabla,2)} = 'TiempoOcioServidorTotal';
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
            
        end
        
  
        
        
        
        %% Recibe como parametro un array de tiempoDeServicio
        % La cantidad de elementos de este array se debe corresponder con
        % la cantidad de corridas estipuladas
        %                                       
        function tablaExperimento = experimento(p_corridas, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos, p_i)
            tablaResultados = zeros (p_corridas, 12);
            tablaExperimento = [];
            v_barras = [];
            
            for i = 1 : p_corridas
                tablaCorrida = parcial2.corrida(p_maxCantClientes, p_lambdaClientes, p_tServ(1,i), p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos);
                
                %Numero de corrida
                tablaResultados(i, 1) = i;
                
                %PARAMETROS
                % Cantidad maxima de clientes
                tablaResultados(i, 2) = p_maxCantClientes;
                % Lambda Cantidad de clientes
                tablaResultados(i, 3) = p_lambdaClientes;
                % Media mu tiempo de servicio
                tablaResultados(i, 4) = p_tServ(1,i);
                % Cantidad de Servidores
                tablaResultados(i, 5) = p_cantServidores;
                % Clientes por turno
                tablaResultados(i, 6) = p_cantClientesTurno;
                % Intervalos de tiempo entre turnos
                tablaResultados(i, 7) = p_intervaloEntreTurnos;
                
                %RESULTADOS                 
                %Media tiempo de espera en cola
                tablaResultados(i, 8) = mean(tablaCorrida(:, 5));
                %Variacion tiempo espera en cola
                tablaResultados(i, 9) = std(tablaCorrida(:, 5));
                %Media sujetos en la cola
                tablaResultados(i, 10) = mean(tablaCorrida(:, 8)); 
                %Media tiempo de ocio del servidor
                tablaResultados(i, 11) = mean(tablaCorrida(:, 10));
                %Variacion tiempo de ocio del servidor
                tablaResultados(i, 12) = std(tablaCorrida(:, 10));
                

                tablaExperimento = [tablaExperimento ; tablaCorrida];
                
                y = [tablaResultados(i, 10) tablaResultados(i, 8) tablaResultados(i, 11)];
                v_barras = [v_barras; y];
            end
            
             parcial2.mostrarResultadoExperimento(tablaResultados);   
            
             parcial2.graficarExperimento(v_barras, p_i)
        end
        
        function graficarExperimento(p_barras, p_i)
            b = bar(p_barras, 'EdgeColor',[.1 .1 .5], 'LineWidth',1);
            str = sprintf('Valores medios de las corridas del experimento %d', p_i);
            title(str, 'FontSize',13);
           % ylabel('Tiempo en minutos');
            xlabel('Nro. de corrida');
            grid on
            legend(b,'Cantidad de personas en la cola','Tiempo de espera en cola','Tiempo de ocio de los servidores','location','northoutside');
            figure;
        end

        function mostrarResultadoExperimento(p_tabla)
            fprintf('\n\n\t\t\tExperimento Modelo de Colas\n\n');
            colNames = {'Corrida','CantidadMaxClientes','LambdaCantClientes','MediaTiemposDeServicio','CantidadServidores','ClientesXTurno','TiempoEntreTurnos','MediaTiempoEspera','VariacionTiempoEspera','MediaSujetosEnCola','MediaTiempoOcio','VariacionTiempoOcio'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
        end
        
        %% Recibe como parametros dos array (tiempoDeServicio e intervaloEntreTurnos)
        % La cantidad de elementos de tiempoDeServicio debe ser igual
        % al valor de p_corridas, y la cantidad de elementos de
        % intervalosEntreTurnos igual al valor de p_experimentos
                                                        
        function simulacion(p_experimentos, p_corridas, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos)
            tablaResultados = zeros (p_experimentos, 11);
            v_barras = [];
                       
            for i = 1 : p_experimentos
                tablaExperimento = parcial2.experimento(p_corridas, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos(1,i), i);
                
                
                %Numero de corrida
                tablaResultados(i, 1) = i;
                
                %PARAMETROS
                % Cantidad maxima de clientes
                tablaResultados(i, 2) = p_maxCantClientes;
                % Lambda Cantidad de clientes
                tablaResultados(i, 3) = p_lambdaClientes;
                % Cantidad de Servidores
                tablaResultados(i, 4) = p_cantServidores;
                % Clientes por turno
                tablaResultados(i, 5) = p_cantClientesTurno;
                % Intervalos de tiempo entre turnos
                tablaResultados(i, 6) = p_intervaloEntreTurnos(1,i);
                
                %RESULTADOS                 
                %Media tiempo de espera en cola
                tablaResultados(i, 7) = mean(tablaExperimento(:, 5)); 
                %Variacion tiempo de espera en cola
                tablaResultados(i, 8) = std(tablaExperimento(:, 5)); 
                %Media sujetos en la cola
                tablaResultados(i, 9) = mean(tablaExperimento(:, 8)); 
                %Media tiempo de ocio del servidor
                tablaResultados(i, 10) = mean(tablaExperimento(:, 10));
                %Variacion tiempo de ocio del servidor
                tablaResultados(i, 11) = std(tablaExperimento(:, 10));
                
                y = [tablaResultados(i, 9) tablaResultados(i, 7) tablaResultados(i, 10)];
                v_barras = [v_barras; y];
            end
            
            parcial2.mostrarResultadoSimulacion(tablaResultados);
            
            parcial2.graficarSimulacion(v_barras)
        end
        
         function graficarSimulacion(p_barras)
            b = bar(p_barras, 'EdgeColor',[.1 .1 .0], 'LineWidth',1.5, 'FaceColor','flat');
          %  title('Tiempos promedios de la simulacion');
            title('Valores medios de la simulacion', 'FontSize',14);          
           % ylabel('Tiempo en minutos');
            xlabel('Nro. de experimento');
            grid on
            legend(b,'Cantidad de personas en la cola','Tiempo de espera en cola','Tiempo de ocio de los servidores','location','northoutside');
           % legend(b,'Personas en la cola','Espera en cola','Ocio servidores','location','northoutside');
        end
        
        function mostrarResultadoSimulacion(p_tabla)
            fprintf('\n\n\t\t\tSimulacion Modelo de Colas\n\n');
            colNames = {'Experimento','CantidadMaxClientes','LambdaCantClientes','CantidadServidores','ClientesXTurno','TiempoEntreTurnos','MediaTiempoEspera','VariacionTiempoEspera','MediaSujetosEnCola','MediaTiempoOcio','VariacionTiempoOcio'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
        end
        

    end

end