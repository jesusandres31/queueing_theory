
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
% 2: Dos colas
%
%
% Cola finita
%
%  Tipo de cola FIFO (First In First Out)
%%

classdef Integrador
        
    methods(Static)
        %% Metodo para exhibir los formularios para ingreso de parámetros de las colas
        %
        %   Parametros: 
        %      *p_colas: entero, cantidad de colas.
        %      *p_corridas: entero, cantidad de corridas.
        %      *p_experimentos: entero, cantidad de experimentos.
        %      *p_tMaxEspera: real, tiempo maxima espera de los clientes.
        %      *p_cMaxCola: entero, cantidad maxima de personas en la cola.
        %
     
        function interface(p_colas, p_corridas, p_experimentos, p_tMaxEspera, p_cMaxCola)                     
            titulo = {''};
            corr = p_corridas;
            exp = p_experimentos;
            if p_corridas == 0
                corr = 1;
            end
            if p_experimentos == 0
                exp = 1;
            end
            lambdaClientes = zeros(1,p_colas);
            maxCantClientes = zeros(1,p_colas);
            tServ = zeros(1,p_colas);
            cantServidores = zeros(exp,p_colas);
            cantClientesTurno = zeros(corr,p_colas);
            intervaloEntreTurnos = zeros(1,p_colas);

            for i=1:p_colas
                informacionCola = Integrador.gui(i, p_corridas, p_experimentos); 
                titulo{1,i} =  informacionCola{1,1};
                lambdaClientes(1,i) = str2num(informacionCola{2,1});
                maxCantClientes(1,i) = str2num(informacionCola{3,1});
                tServ(1,i) = str2num(informacionCola{4,1});
                cantServidores(:,i) = str2num(informacionCola{5,1});
                cantClientesTurno(:,i) = str2num(informacionCola{6,1});
                intervaloEntreTurnos(1,i) = str2num(informacionCola{7,1});
            end
            
            if p_corridas == 0
                Integrador.corrida(p_colas, titulo, maxCantClientes, lambdaClientes, tServ, cantServidores, cantClientesTurno, intervaloEntreTurnos, p_tMaxEspera, p_cMaxCola);
            else
                if p_experimentos == 0
                    Integrador.experimento(p_corridas, p_colas, titulo, maxCantClientes, lambdaClientes, tServ, cantServidores, cantClientesTurno, intervaloEntreTurnos, p_tMaxEspera, p_cMaxCola);
                else
                    Integrador.simulacion(p_experimentos, p_corridas, p_colas, titulo, maxCantClientes, lambdaClientes, tServ, cantServidores, cantClientesTurno, intervaloEntreTurnos, p_tMaxEspera, p_cMaxCola);
                end
            end
            
            
        end
        
        %% Metodo que desarrolla una corrida del modelo de colas G/M/N de dos colas.
        %
        %   Parametros:
        %      *p_colas: entero, cantidad de colas.
        %      *p_titulo: array[1Xp_colas], titulos descriptivos de cada
        %        cola.
        %      *p_maxCantClientes: array[1Xp_colas], maxima cantidad de
        %        clientes por cola.
        %      *p_lambdaClientes: array[1Xp_colas], cantidad media (lambda)
        %        clientes por cola. 
        %      *p_tServ: array[1Xp_colas], tiempo medio de servicio por
        %        cola.
        %      *p_cantServidores: array[1Xp_colas], cantidad servidores
        %        por cola.
        %      *p_cantClientesTurno: array[1Xp_colas], clientes por turno
        %        por cola.
        %      *p_intervaloEntreTurnos: array[1Xp_colas], tiempo entre
        %        turnos por cola.
        %      *p_tMaxEspera: real, tiempo maxima espera de los clientes.
        %      *p_cMaxCola: entero, cantidad maxima de personas en la cola.
        %
        %   Retorno:
        %      *tabla: array[nX10], contiene los valores recopilados
        %        de la corrida.
        %      *tamanoCola: entero, total personas atendidas en la corrida.
        %      *cantPersMaxEspera: entero, total personas que esperaron mas
        %        que el tiempo maximo de espera en la cola.
        %      *tiempoTotalTranscurrido: real, tiempo total que llevo la
        %        corrida.
        %      *tiempoColaExcedido: real, tiempo total en que la cola
        %        supero el maximo establecido.
        %
        
        function [tabla, tamanoCola, cantPersMaxEspera, tiempoTotalTranscurrido, tiempoColaExcedido] = corrida (p_colas, p_titulo, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos, p_tMaxEspera, p_cMaxCola)
            import pkg.Parcial2.*;
            tabla = [];
            fprintf('\n\n\t\t\tCorrida Modelo de Colas');
            for i=1:p_colas
                fprintf('\n\n\t\t\tResultados Cola %s\n',p_titulo{1,i});
                tabla = [ tabla ; parcial2.corrida(p_maxCantClientes(1,i), p_lambdaClientes(1,i), p_tServ(1,i), p_cantServidores(1,i), p_cantClientesTurno(1,i), p_intervaloEntreTurnos(1,i)) ];
            end
            [tamanoCola, cantPersMaxEspera, tiempoTotalTranscurrido, tiempoColaExcedido] = Integrador.calcularTiempoEspera([tabla(:,1),tabla(:,2), tabla(:,5), tabla(:, 8), tabla(:,7)], p_tMaxEspera, p_cMaxCola);
            
        end
        
        
        %% Metodo que genera el formulario de carga
        %
        %   Parametros:
        %      *p_cola: entero, numero de orden de la cola
        %      *p_corridas: entero, cantidad de corridas.
        %      *p_experimentos: entero, cantidad de experimentos.
        %
        
        function variables = gui(p_cola, p_corridas, p_experimentos)
            titulo = 'Ingrese Datos Cola ';
            numeroCola = num2str(p_cola);
            titulo = strcat(titulo, numeroCola); 
            dialogo = {''};
            dimensiones = [1 70];
                   
            dialogo(1, 1) = {strcat('Descripcion Cola:')};
            dialogo(1, 2) = {strcat('Lambda Cantidad Clientes:')};
            dialogo(1, 3) = {strcat('Maxima Cantidad Clientes:')};
            dialogo(1, 4) = {strcat('Media Tiempo Servicio:')};
            dialogo(1, 5) = {strcat('Cantidad Servidores')};
            if p_experimentos ~= 0
                dialogo(1, 5) = {strcat(string(dialogo(1, 5)), '. Ej: [1,2,3] para 3 Experimentos: ')};
            else
                dialogo(1, 5) = {strcat(string(dialogo(1, 5)), ':')};
            end
            dialogo(1, 6) = {strcat('Cantidad Clientes X Turno:')};
            if p_corridas ~= 0
                dialogo(1, 6) = {strcat(string(dialogo(1, 6)), '. Ej: [1,2,3] para 3 Corridas: ')};
            else
                dialogo(1, 6) = {strcat(string(dialogo(1, 6)), ':')};
            end
            dialogo(1, 7) = {strcat('Intervalo Tiempo Entre Turnos:')};                      
            variables = inputdlg(dialogo, titulo, dimensiones);
        end
        
        %% Metodo que calcula personas y tiempos que superan los umbrales establecidos de espera y cola.
        %
        %   Parametros:
        %      *tabla: array[nX10], contiene los valores recopilados de la 
        %        corrida.
        %      *p_tMaxEspera: real, tiempo maxima espera de los clientes.
        %      *p_cMaxCola: entero, cantidad maxima de personas en la cola.
        %
        %   Retorno:
        %      *tamanoCola: entero, total personas atendidas en la corrida.
        %      *cantPersMaxEspera: entero, total personas que esperaron mas
        %        que el tiempo maximo de espera en la cola.
        %      *tiempoTotalTranscurrido: real, tiempo total que llevo la
        %        corrida.
        %      *tiempoColaExcedido: real, tiempo total en que la cola
        %        supero el maximo establecido.
        %
        
        function [tamanoCola, cantPersMaxEspera, tiempoTotalTranscurrido, tiempoColaExcedido] = calcularTiempoEspera(p_tabla, p_tMaxEspera, p_cMaxCola)
            personas = size(p_tabla, 1);
            cantPersMaxEspera = 0;
            tiempoPrimerExceso = 0;
            tiempoColaExcedido = 0;
            tiempoTotalTranscurrido = 0;
            for i=1 : personas
                if p_tabla(i, 3) >=  p_tMaxEspera
                    cantPersMaxEspera = cantPersMaxEspera + 1;
                end
                if i ~= 1 && p_tabla(i,1) == 1
                    cantClientes = p_tabla(i - 1, 1);
                    tiempoTotalTranscurrido = tiempoTotalTranscurrido + max(p_tabla(i- cantClientes:1:i-1,5));
                end
                if (p_tabla(i, 4) + 1) >=  p_cMaxCola
                    
                    if tiempoPrimerExceso == 0
                        tiempoPrimerExceso = p_tabla(i, 2); 
                    end
                    if i == personas
                        tiempoSalidaPrimeroCola = p_tabla(i - p_cMaxCola + 1, 2) + p_tabla(i - p_cMaxCola + 1, 3) - tiempoPrimerExceso;
                        tiempoColaExcedido = tiempoColaExcedido + tiempoSalidaPrimeroCola;                       
                    end
                else
                    if tiempoPrimerExceso ~= 0
                        tiempoSalidaPrimeroCola = p_tabla(i - p_cMaxCola, 2) + p_tabla(i - p_cMaxCola, 3) - tiempoPrimerExceso;
                        tiempoColaExcedido = tiempoColaExcedido + tiempoSalidaPrimeroCola;
                        tiempoPrimerExceso = 0;                       
                    end
                end
            end
            tiempoTotalTranscurrido = tiempoTotalTranscurrido + max(p_tabla(personas - p_tabla(personas, 1):1:personas,5));
            tamanoCola = size(p_tabla,1);
            fprintf('\n\t\tCantidad total de clientes: %i',tamanoCola);
            fprintf('\n\n\t\tCantidad de personas que han esperado mas de %.2f minutos en la cola: %i',p_tMaxEspera, cantPersMaxEspera);            
            fprintf('\n\n\t\tCantidad de tiempo transcurrido: %.2f',tiempoTotalTranscurrido);
            fprintf('\n\n\t\tCantidad de minutos en el que hubieron %i o mas personas en la cola: %.2f\n',p_cMaxCola, tiempoColaExcedido);
        end
        
        
        %% Metodo que desarrolla un experimento del modelo de colas G/M/N de dos colas.
        %
        %   Parametros:
        %      *p_corridas: entero, cantidad de corridas. 
        %      *p_colas: entero, cantidad de colas.
        %      *p_titulo: array[1Xp_colas], titulos descriptivos de cada
        %        cola.
        %      *p_maxCantClientes: array[1Xp_colas], maxima cantidad de
        %        clientes por cola.
        %      *p_lambdaClientes: array[1Xp_colas], cantidad media (lambda)
        %        clientes por cola. 
        %      *p_tServ: array[1Xp_colas], tiempo medio de servicio por
        %        cola.
        %      *p_cantServidores: array[1Xp_colas], cantidad servidores
        %        por cola.
        %      *p_cantClientesTurno: array[p_corridasXp_colas], vector de 
        %        clientes por turno por cola de cada corrida.
        %      *p_intervaloEntreTurnos: array[1Xp_colas], tiempo entre
        %        turnos por cola.
        %      *p_tMaxEspera: real, tiempo maxima espera de los clientes.
        %      *p_cMaxCola: entero, cantidad maxima de personas en la cola.
        %
        %   Retorno:
        %      *tabla: array[nX10], contiene los valores recopilados
        %        del experimento.
        %      *tiemposEspera: array[mX4], contiene los calculos de tiempos
        %      y personas totales y los que superaron los umbrales establec
        %

        function [tablaExperimento, tiemposEspera] = experimento(p_corridas, p_colas, p_titulo, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos, p_tMaxEspera, p_cMaxCola)
            tablaResultados = [];
            tiemposEspera = zeros(p_corridas,4);
            filaResultados = {''};
            tablaExperimento = [];
            fprintf('\n\n\t\t\tExperimento Modelo de Colas');
            for i = 1 : p_corridas
                [tablaCorrida, tamanoCola, cantPersMaxEspera, tiempoTotalTranscurrido, tiempoColaExcedido] = Integrador.corrida(p_colas, p_titulo, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno(i,:), p_intervaloEntreTurnos, p_tMaxEspera, p_cMaxCola);
                
                %Numero de corrida
                filaResultados{1,1} = i ;
                
                %PARAMETROS
                % Cantidad maxima de clientes
                filaResultados{1,2} = num2str(p_maxCantClientes);
                % Lambda Cantidad de clientes
                filaResultados{1,3} = num2str(p_lambdaClientes);
                % Media mu tiempo de servicio
                filaResultados{1,4} = num2str(p_tServ);
                % Cantidad de Servidores
                filaResultados{1,5} = num2str(p_cantServidores);
                % Clientes por turno
                filaResultados{1,6} = num2str(p_cantClientesTurno(i,:));
                % Intervalos de tiempo entre turnos
                filaResultados{1,7} = num2str(p_intervaloEntreTurnos);

                
                %RESULTADOS                 
                %Media tiempo de espera en cola
                filaResultados{1,8} = num2str(mean(tablaCorrida(:, 5)));
                %Variacion tiempo espera en cola
                filaResultados{1,9} = num2str(std(tablaCorrida(:, 5)));
                %Media sujetos en la cola
                filaResultados{1,10} = num2str(mean(tablaCorrida(:, 8))); 
                %Media tiempo de ocio del servidor
                filaResultados{1,11} = num2str(mean(tablaCorrida(:, 10)));
                %Variacion tiempo de ocio del servidor
                filaResultados{1,12} = num2str(std(tablaCorrida(:, 10)));
                %Porcentaje clientes atendido despues del limite de espera
                filaResultados{1,13} = strcat(num2str(cantPersMaxEspera * 100 / tamanoCola),'%');
                %Porcentaje del tiempo que la cola supera el limite
                filaResultados{1,14} = strcat(num2str(tiempoColaExcedido * 100 / tiempoTotalTranscurrido),'%');
                
                tiemposEspera(i,1) = tamanoCola;
                tiemposEspera(i,2) = cantPersMaxEspera;
                tiemposEspera(i,3) = tiempoTotalTranscurrido;
                tiemposEspera(i,4) = tiempoColaExcedido;
                
                tablaResultados = [tablaResultados; filaResultados];

                tablaExperimento = [tablaExperimento ; tablaCorrida];
                
            end
            Integrador.mostrarResultadoExperimento(tablaResultados);   

        end

        %% Metodo que muestra por pantalla de forma tabular los resultados del experimento
        %
        %   Parametros:
        %      *p_tabla: *tabla: array[nX14], contiene los parametros y
        %       resultados del experimento.
        %
        function mostrarResultadoExperimento(p_tabla)
            fprintf('\n\n\t\t\tExperimento Modelo de Colas\n\n');
            colNames = {'Corrida','CantidadMaxClientes','LambdaCantClientes','MediaTiemposDeServicio','CantidadServidores','ClientesXTurno','TiempoEntreTurnos','MediaTiempoEspera','VariacionTiempoEspera','MediaSujetosEnCola','MediaTiempoOcio','VariacionTiempoOcio','PorcIncumpEspera','PorcIncumpCola'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
        end  
        
       
        %% Metodo que desarrolla una simulacion del modelo de colas G/M/N de dos colas.
        %
        %   Parametros:
        %      *p_experimentos: entero, cantidad de experimentos.
        %      *p_corridas: entero, cantidad de corridas. 
        %      *p_colas: entero, cantidad de colas.
        %      *p_titulo: array[1Xp_colas], titulos descriptivos de cada
        %        cola.
        %      *p_maxCantClientes: array[1Xp_colas], maxima cantidad de
        %        clientes por cola.
        %      *p_lambdaClientes: array[1Xp_colas], cantidad media (lambda)
        %        clientes por cola. 
        %      *p_tServ: array[1Xp_colas], tiempo medio de servicio por
        %        cola.
        %      *p_cantServidores: array[p_experimentosXp_colas], vector de  
        %        cantidad de servidores por cola de cada experimento.
        %      *p_cantClientesTurno: array[p_corridasXp_colas], vector de 
        %        clientes por turno por cola de cada corrida.
        %      *p_intervaloEntreTurnos: array[1Xp_colas], tiempo entre
        %        turnos por cola.
        %      *p_tMaxEspera: real, tiempo maxima espera de los clientes.
        %      *p_cMaxCola: entero, cantidad maxima de personas en la cola.
        %
        
        function simulacion(p_experimentos, p_corridas, p_colas, p_titulo, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores, p_cantClientesTurno, p_intervaloEntreTurnos, p_tMaxEspera, p_cMaxCola)
            tablaResultados = [];
            tiemposEspera = zeros(p_corridas,4);
            filaResultados = {''};
            tablaExperimento = [];
            fprintf('\n\t\t\tSimulacion Modelo de Colas');
            for i = 1 : p_experimentos
                [tablaExperimento, tiemposEspera] = Integrador.experimento(p_corridas, p_colas, p_titulo, p_maxCantClientes, p_lambdaClientes, p_tServ, p_cantServidores(i,:), p_cantClientesTurno, p_intervaloEntreTurnos, p_tMaxEspera, p_cMaxCola);
                
                %Numero de corrida
                filaResultados{1,1} = i ;
                
                %PARAMETROS
                % Cantidad maxima de clientes
                filaResultados{1,2} = num2str(p_maxCantClientes);
                % Lambda Cantidad de clientes
                filaResultados{1,3} = num2str(p_lambdaClientes);
                % Media mu tiempo de servicio
                filaResultados{1,4} = num2str(p_tServ);
                % Cantidad de Servidores
                filaResultados{1,5} = num2str(p_cantServidores(i,:));
                % Intervalos de tiempo entre turnos
                filaResultados{1,6} = num2str(p_intervaloEntreTurnos);

                
                %RESULTADOS                 
                %Media tiempo de espera en cola
                filaResultados{1,7} = num2str(mean(tablaExperimento(:, 5)));
                %Variacion tiempo espera en cola
                filaResultados{1,8} = num2str(std(tablaExperimento(:, 5)));
                %Media sujetos en la cola
                filaResultados{1,9} = num2str(mean(tablaExperimento(:, 8))); 
                %Media tiempo de ocio del servidor
                filaResultados{1,10} = num2str(mean(tablaExperimento(:, 10)));
                %Variacion tiempo de ocio del servidor
                filaResultados{1,11} = num2str(std(tablaExperimento(:, 10)));
                %Porcentaje clientes atendido despues del limite de espera
                filaResultados{1,12} = strcat(num2str(sum(tiemposEspera(:,2)) * 100 / sum(tiemposEspera(:,1))),'%');
                %Porcentaje del tiempo que la cola supera el limite
                filaResultados{1,13} = strcat(num2str(sum(tiemposEspera(:,4)) * 100 / sum(tiemposEspera(:,3))),'%');
                
                tablaResultados = [tablaResultados; filaResultados];
                
            end
            
            Integrador.mostrarResultadoSimulacion(tablaResultados);

        end
       
       %% Metodo que muestra por pantalla de forma tabular los resultados de la simulacion 
       %
       %   Parametros:
       %      *p_tabla: *tabla: array[nX13], contiene los parametros y
       %       resultados de la simulacion.
       %
        
        function mostrarResultadoSimulacion(p_tabla)
            fprintf('\n\n\t\t\tSimulacion Modelo de Colas\n\n');
            colNames = {'Experimento','CantidadMaxClientes','LambdaCantClientes','MediaTiemposDeServicio','CantidadServidores','TiempoEntreTurnos','MediaTiempoEspera','VariacionTiempoEspera','MediaSujetosEnCola','MediaTiempoOcio','VariacionTiempoOcio','PorcIncumpEspera','PorcIncumpCola'};
            sTable = array2table(p_tabla,'VariableNames',colNames);
            disp (sTable);
        end
        
    end
end