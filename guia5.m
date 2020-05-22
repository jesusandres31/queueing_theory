
classdef guia5
    
    % normrnd(mu, sigma): valor aleatorio de la distribucion normal
    % poissrnd(lambda): valor aleatorio de la distribucion de Poisson
    % exprnd(mu): valor aleatorio de la distribucion exponencial
    
    methods (Static)

    %
    % Metodo que permite generar una muestra artificial con distribucion
    % normal.
    %
    %   Parametros: 
    %       p_media: real, valor de la media de la distribucion normal
    %       p_desv: real, valor de la desviacion de la distribucion
    %       normal
    %       p_muestra: entero, cantidad de elementos que contendra la
    %       muestra
    %
    %   Retorno:
    %       vector: array[1xn], contiene los valores de la muestra
    %       obtenida
    %
        function vector = normal (p_media, p_desv, p_muestra)
            numerador = p_muestra / 2;
            denomin = sqrt(p_muestra/12);
            vector = zeros (1, p_muestra);
            for i = 1 : p_muestra
                suma = 0;
                for j = 1 : p_muestra       
                    suma = suma + rand(1);
                end               
                xi = (suma - numerador)/denomin ;
                vector(1,i) = xi * p_desv + p_media;
            end
                
        end
        
    %
    % Metodo que permite generar una muestra artificial con distribucion
    % Poisson.
    %
    %   Parametros: 
    %       p_media: real, valor de la media de la distribucion Poisson
    %       p_desv: real, valor de la desviacion de la distribucion
    %       Poisson
    %       p_muestra: entero, cantidad de elementos que contendra la
    %       muestra
    %
    %   Retorno:
    %       vector: array[1xn], contiene los valores de la muestra
    %       obtenida
    %
        function vector = poisson (p_media, p_muestra)
            vector = zeros (1, p_muestra);
            for i = 1 : p_muestra       
                k = 1;
                sum = 0;
                while (sum <= 1) 
                    alea = rand(1);
                    sum = sum + (log(alea)/p_media) * (-1);
                    k = k + 1;
                end
                k = k - 1;
                vector(1,i) = k;
            end               
                
        end
        
    %
    % Metodo que permite generar una muestra artificial con distribucion
    % exponencial.
    %
    %   Parametros: 
    %       p_media: real, valor de la media de la distribucion exponencial
    %       p_desv: real, valor de la desviacion de la distribucion
    %       exponencial
    %       p_muestra: entero, cantidad de elementos que contendra la
    %       muestra
    %
    %   Retorno:
    %       vector: array[1xn], contiene los valores de la muestra
    %       obtenida
    %        
        function vector = exponencial (p_media, p_muestra)
            vector = zeros (1, p_muestra);
            for i = 1 : p_muestra
                t = 0;
                ut = 0;
                while ut == 0
                    j = 0;
                    u = rand(1);
                    serie = 1 - u;
                    while serie < 1
                        ui = rand(1);
                        serie = serie + ui;
                        j = j + 1;
                    end
                    if mod (j, 2) == 1
                        ut = u;
                    end
                    t = t + 1;
                end
                x = ((t - 1) + ut)*p_media;%%Asi aparece en el libro, pero para mi se debe multiplicar la media
                vector (1,i) = x;
            end
                
        end

    %
    % Metodo que permite diagramar un grafico de barras con las frecuencias
    % absolutas de los valores de las muestras.
    %
    %   Parametros: 
    %       p_vector: array[1xn], muestra con los valores que se desea
    %       graficar
    %
 
        function prueba_frec (p_vector)
            p_vector = round(p_vector);
            n = size(p_vector,2);
            tabla = [];
            i = 1;
            cont = 1;
            while i <= n
                elemento = p_vector(1,i);              
                repeticiones = size(find(p_vector == elemento),2);
                tabla(cont,1) = elemento;                
                tabla(cont,2) = repeticiones;
                %Elimina los elementos repetidos del vector
                p_vector(p_vector == elemento) = [];
                n = size(p_vector, 2);
                cont = cont + 1;
            end
            tabla = sortrows(tabla);
            x = tabla(:,1);
            y = tabla(:,2);
            bar(x,y);
        end

    end
end