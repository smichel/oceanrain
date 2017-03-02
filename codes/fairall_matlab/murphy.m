function [ e_s ] = murphy( T )
%MURPHY Berechnet den Saettigungsdampfdruck fuer eine gegebene Temperatur
%in K
e_s=exp(54.842763 - 6763.22/T -4.210*log(T)+0.000367*T+tanh(0.0415*(T-218.8))*(53.878 - 1331.22/T - 9.44523*log(T)+0.014025*T));
end

