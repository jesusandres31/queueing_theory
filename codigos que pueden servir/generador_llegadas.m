function serie= generador(V0,N)
%clc;
%disp('-------------GENERADOR DE NUMEROS PSEUDO-ALEATORIOS---------------');
%Ingreso de parametros

% V0= input('Ingrese semilla: '); %debe ser impar y relativamente primo a M
% a=input('Ingrese parametro multiplicativo (a): '); %es igual a 8*t+-3, t= entero positivo
% M= input('Ingrese modulo: '); %2^d, d = numero de bits de la palabra
% N=input('Ingrese tamano de la muestra (numero de clientes a simular): ');
%corridas=input('Ingrese numero de corridas para la simulacion:');
M=47591;

a=24;

%--------Se verifica que la semilla y el modulo sean primos----------

while (~isprime(V0))
    V0=V0+1;
end
while (~isprime(M))
    M=M+1;
end

%--------------------------------------------------------------------

v=[];%vector de numeros pseudoaleatorios genereados entre V0 y M
%aux=a*V0;
v(1)=V0;
%v(1)= mod(aux,M);
%na(1)= round((v(1)*11)/M);
for i=2:N
    %v(i) Es un vector que contiene lo numeros pseudo-aleatorios generados
        %por el metodo multiplicativo congruencial (valores entre 0 y modulo)
    %digitos(i) Es un vector que contiene digitos pseudo-aleatorios
    %array(i) Es un vector que contiene los numero pseudo-aleatorios entre 0 y 1 
    
    v(i)= mod(a*v(i-1),M);
    %digitos(i)= round((v(i)*9)/M);
    digitos(i)= mod(v(i),10);
    nroaux=v(i)/M;
    array(i)=nroaux;
end
l = length(v);%Obtiene la longitud del vector

%-------Imprimo Conjunto de digitos generados entre 0 y M------------------
% disp(' ');
% disp('Conjunto de digitos generados:');
% disp(' ');
% j=0;
% for i=1:l
%     fprintf(' %i',digitos(i));
%     j=j+1;
%     if (j==20)
%         fprintf('\n');
%         j=0;
%     end
% end
% %--------------------------------------------------------------------------
% disp(' ');
% fprintf('\n');
% %-------Imprimo Conjunto de digitos generados entre 0 y M------------------
% disp(' ');
% disp('Conjunto de digitos generados entre 0 y 1:');
% disp(' ');
% j=0;
% for i=1:l
%     fprintf(' %0.4f',array(i));
%     j=j+1;
%     if (j==20)
%         fprintf('\n');
%         j=0;
%     end
% end
%--------------------------------------------------------------------------

alpha=0.05;
if (alpha~=100)
    if (chi2s(digitos, alpha)==true)
        fprintf('\n');
        serie=array;
    else
        disp('No supero chi2. Genere una nueva muestra');
    end
end