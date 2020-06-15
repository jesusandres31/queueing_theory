
%% 
% Propuestas para presentacion de parcial
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
        
        %% Metodo que desarrolla una corrida del modelo de colas G/M/N.
        %
        %   Parametros: 
        %      *p_maxCantClientes: entero, cantidad maxima de clientes.
        %      *p_lambdaClientes: entero, media de clientes para dist. 
        %        Poisson.
        %      *p_tServ: real, media de tiempo de servicio en minutos para 
        %           distribucion Exponencial.
        %      *p_cantServidores: entero, cantidad de servidores.
        %      *p_cantClientesTurno: entero, cantidad de clientes x turno.
        %      *p_intervaloEntreTurnos: real, intervalo de tiempo entre 
        %        turnos.
        %
        %   Retorno:
        %      *tablaCorrida: array[nx10], contiene los valores recopilados
        %        de la corrida.
        %
        
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
            
            
            for i = 1 : cantClientes
                
                tiemposOcioServidores = zeros(1,p_cantServidores);
                
                % Llegada a la cola
                tiempo = tiempo + llegadaACola(1, i);
                servidores(1,:) = servidores(1,:) - llegadaACola(1, i);

                %Control Servidores
                [servLibre, servidores, tiemposOcioServidores, servidorAsignado] = parcial2.controlServidores(p_cantServidores, servidores, tiemposOcioServidores, tiemposServicio(1,i));
                
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


            end      
            parcial2.mostrarResultadoCorrida(tablaResultados);
            

        end
        
        %% Metodo que controla el estado de los servidores
        %
        % Parametros: 
        %      *p_cantServidores: entero, cantidad de servidores.
        %      *p_servidores: array[1xp_cantServidores], tiempos de
        %        servicio asignados a cada servidor.
        %      *p_tiemposOcioServidores: array[1xp_cantServidores], tiempos
        %        de ocio de servicio de cada servidor.
        %      *p_tiempoServicio: real, tiempo de servicio del cliente.
        %
        %   Retorno:
        %      *servLibre: boolean, verdadero si tiene algun servidor
        %       libre.
        %      *p_servidores: array[1xp_cantServidores], tiempos de
        %        servicio asignados a cada servidor.
        %      *p_tiemposOcioServidores: array[1xp_cantServidores], tiempos
        %        de ocio de servicio de cada servidor.
        %      *servidorAsignado: entero, id del servidor que se le va a
        %        asignar el cliente.
        %
        
        function [servLibre, p_servidores, p_tiemposOcioServidores, servidorAsignado] = controlServidores(p_cantServidores, p_servidores, p_tiemposOcioServidores, p_tiempoServicio)
            servLibre = false;
            servidorAsignado = 0;
            for j = 1 : p_cantServidores
                tiempoLibreServidor = p_servidores(1,j) * -1;
                if servLibre
                    if p_servidores(1,j) <= 0

                        p_tiemposOcioServidores(1,j) = tiempoLibreServidor;
                        p_servidores(1,j) = 0;
                    end
                else
                    if p_servidores(1,j) <= 0 

                        servLibre = true;
                        servidorAsignado = j;
                        p_tiemposOcioServidores(1,j) = tiempoLibreServidor;
                        p_servidores(1,j) = p_tiempoServicio; 
                    end
                end
            end
        end
        


        %% Metodo que muestra por pantalla los resultados recopilados de la corrida
        %
        % Parametros:
        %      *p_tabla: array[nxm], contiene los valores recopilados de la
        %        corrida.
        %
        
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
        
  
        
        
        
        %% Metodo que desarrolla un experimento del modelo de colas G/M/N.
        %
        %   Parametros:
        %      *p_corridas: entero, cantidad de corridas del experimento.
        %      *p_maxCantClientes: entero, cantidad maxima de clientes.
        %      *p_lambdaClientes: entero, media de clientes para dist. 
        %        Poisson.
        %      *p_tServ: array[1xp_corridas], medias de tiempos de servicio
        %        en minutos para distr. Exponencial por cada corrida.
        %      *p_cantServidores: entero, cantidad de servidores.
        %      *p_cantClientesTurno: array[1xp_corridas], cantidades de 
        %        clientes x turno por cada corrida.
        %      *p_intervaloEntreTurnos: real, intervalo de tiempo entre 
        %        turnos.
        %
        %   Retorno:
        %      *tablaExperimento: array[nx10], contiene los valores 
        %        recopilados de todas las corridas del experimento.
        %                                       
        
        function tablaExperimento = experimento(p_corridas, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos, p_i)
            tablaResultados = zeros (p_corridas, 12);
            tablaExperimento = []; 
            
            for i = 1 : p_corridas
                tablaCorrida = parcial2.corrida(p_maxCantClientes, p_lambdaClientes, p_tServ(1,i), p_cantServidores, p_cantClientesTurno(1,i), p_intervaloEntreTurnos);
                
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
                tablaResultados(i, 6) = p_cantClientesTurno(1,i);
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
                
            end
            
             parcial2.mostrarResultadoExperimento(tablaResultados);   
            
             parcial2.graficarExperimentoTiempos([tablaResultados(:, 8), tablaResultados(:, 11)], p_i);
             
             parcial2.graficarExperimentoCantidad(tablaResultados(:, 10), p_i);
        end
        
        %% Metodo para generar un grafico de barras con las medias de cantidad de personas en la cola en cada corrida del experimento
        %
        % Parametros:
        %      *p_cantidad: arreglo[nx1], medias de cantidad de personas en
        %        la cola en cada corrida
        %      *p_i: entero, identificador de experimento
        %
        
        function graficarExperimentoCantidad(p_cantidad, p_i)
            bar(p_cantidad, 'FaceColor',[0 .5 .5],'EdgeColor',[.1 .1 .0],'LineWidth',1.5);
            str = sprintf('Media de personas en cola del experimento %d', p_i);
            title(str, 'FontSize',13);
            ylabel('Cantidad de personas');
            xlabel('Nro. de corrida');
            grid on
            figure;
        end
        
        
        %% Metodo para generar un grafico de barras con las medias de tiempos de espera y ocio en cada corrida del experimento
        %
        % Parametros:
        %      *p_tiempos: arreglo[nx2], medias de tiempos de espera y ocio
        %        en cada corrida
        %      *p_i: entero, identificador de experimento
        %
        
        function graficarExperimentoTiempos(p_tiempos, p_i)
            b = bar(p_tiempos, 'EdgeColor',[.1 .1 .5], 'LineWidth',1);
            str = sprintf('Valores medios de las corridas del experimento %d', p_i);
            title(str, 'FontSize',13);
            ylabel('Tiempo en minutos');
            xlabel('Nro. de corrida');
            grid on
            legend(b,'Tiempo de espera en cola','Tiempo de ocio de los servidores','location','northoutside');
            figure;
        end

        %% Metodo que muestra por pantalla los resultados recopilados del experimento
        %
        % Parametros:
        %      *p_tabla: array[nx12], contiene los valores recopilados del
        %        experimento.
        %
        
        function mostrarResultadoExperimento(p_tabla)
            fprintf('\n\n\t\t\tExperimento Modelo de Colas\n\n');
            colNames = {'Corrida','CantidadMaxClientes','LambdaCantClientes','MediaTiemposDeServicio','CantidadServidores','ClientesXTurno','TiempoEntreTurnos','MediaTiempoEspera','VariacionTiempoEspera','MediaSujetosEnCola','MediaTiempoOcio','VariacionTiempoOcio'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
        end
        
        %% Metodo que desarrolla una simulación del modelo de colas G/M/N.
        %
        %   Parametros:
        %      *p_experimentos: entero, cantidad de experimentos de la
        %        simulación
        %      *p_corridas: entero, cantidad de corridas del experimento.
        %      *p_maxCantClientes: entero, cantidad maxima de clientes.
        %      *p_lambdaClientes: entero, media de clientes para dist. 
        %        Poisson.
        %      *p_tServ: array[1xp_corridas], medias de tiempos de servicio
        %        en minutos para distr. Exponencial de cada corrida.
        %      *p_cantServidores: array[1xp_experimentos] entero, cantidad 
        %        de servidores por cada experimento.
        %      *p_cantClientesTurno: array[1xp_corridas], cantidades de 
        %        clientes x turno por cada corrida.
        %      *p_intervaloEntreTurnos: array[1xp_experimentos], intervalo 
        %        de tiempo entre turnos por cada experimento.
        %
                                                        
        function simulacion(p_experimentos, p_corridas, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos)
            tablaResultados = zeros (p_experimentos, 10);
            
            for i = 1 : p_experimentos
                tablaExperimento = parcial2.experimento(p_corridas, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores(1,i), p_cantClientesTurno, p_intervaloEntreTurnos(1,i), i);
                
                
                %Numero de corrida
                tablaResultados(i, 1) = i;
                
                %PARAMETROS
                % Cantidad maxima de clientes
                tablaResultados(i, 2) = p_maxCantClientes;
                % Lambda Cantidad de clientes
                tablaResultados(i, 3) = p_lambdaClientes;
                % Cantidad de Servidores
                tablaResultados(i, 4) = p_cantServidores(1,i);
                % Clientes por turno
                %tablaResultados(i, 5) = p_cantClientesTurno;
                % Intervalos de tiempo entre turnos
                tablaResultados(i, 5) = p_intervaloEntreTurnos(1,i);
                
                %RESULTADOS                 
                %Media tiempo de espera en cola
                tablaResultados(i, 6) = mean(tablaExperimento(:, 5)); 
                %Variacion tiempo de espera en cola
                tablaResultados(i, 7) = std(tablaExperimento(:, 5)); 
                %Media sujetos en la cola
                tablaResultados(i, 8) = mean(tablaExperimento(:, 8)); 
                %Media tiempo de ocio del servidor
                tablaResultados(i, 9) = mean(tablaExperimento(:, 10));
                %Variacion tiempo de ocio del servidor
                tablaResultados(i, 10) = std(tablaExperimento(:, 10));
                
            end
            
            parcial2.mostrarResultadoSimulacion(tablaResultados);
            
            parcial2.graficarSimulacionCantidad(tablaResultados(:, 8));
            
            parcial2.graficarSimulacionTiempos([tablaResultados(:, 6), tablaResultados(:, 9)]);

        end
        
        %% Metodo para generar un grafico de barras con las medias de cantidad de personas en la cola en cada experimento de la corrida
        %
        % Parametros:
        %      *p_cantidad: arreglo[nx1], medias de cantidad de personas en
        %        la cola en cada experimento
        %
        
         function graficarSimulacionCantidad(p_cantidad)
            bar(p_cantidad, 'FaceColor',[0 .5 .5],'EdgeColor',[.1 .1 .0],'LineWidth',1.5);
            title('Media de personas en cola de la simulacion', 'FontSize',14);          
            ylabel('Cantidad de personas');
            xlabel('Nro. de experimento');
            grid on
            figure;
         end
        
        %% Metodo para generar un grafico de barras con las medias de tiempos de espera y ocio en cada experimento de la simulación
        %
        % Parametros:
        %      *p_tiempos: arreglo[nx2], medias de tiempos de espera y ocio
        %        en cada experimento
        %
        
         function graficarSimulacionTiempos(p_tiempos)
            b = bar(p_tiempos, 'EdgeColor',[.1 .1 .0], 'LineWidth',1.5, 'FaceColor','flat');
            title('Valores medios de la simulacion', 'FontSize',14);          
            ylabel('Tiempo en minutos');
            xlabel('Nro. de experimento');
            grid on
            legend(b,'Tiempo de espera en cola','Tiempo de ocio de los servidores','location','northoutside');;
         end
        
         %% Metodo que muestra por pantalla los resultados recopilados de la simulación
        %
        % Parametros:
        %      *p_tabla: array[nx10], contiene los valores recopilados de
        %       la simulación.
        %
        
        function mostrarResultadoSimulacion(p_tabla)
            fprintf('\n\n\t\t\tSimulacion Modelo de Colas\n\n');
            colNames = {'Experimento','CantidadMaxClientes','LambdaCantClientes','CantidadServidores','TiempoEntreTurnos','MediaTiempoEspera','VariacionTiempoEspera','MediaSujetosEnCola','MediaTiempoOcio','VariacionTiempoOcio'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
        end
        

    end

end