clear; close all;

formatSpec_of='%08i %08i %04i %08i %04i %04i %10.6f %12i %8.4f %9.4f %5.1f %5.1f %5.1f %5.1f %5.1f %4i %5.1f %5.1f %5.1f %5.1f %4i %5.1f %4i %5.1f %6.1f %6i %6i %5.1f %6.2f %10.6f %10.6f %10.6f %2i %9.3f  %9.3f %10.4f %9.4f %6.2f % 03i % 03i % 03i %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %5i %5i %03i %05i %7.2f %18.2f %8.2f %8.2f %7.2f %7.2f\r\n';
data=[00000001 10062010 0000 09062010 0500 0000 6004.000000   1276128000 -99.9999 -999.9999 -99.9 -99.9 -99.9 -99.9 -99.9  -99  -9.9  -9.9 -999.9  -9.9  -99  -9.9  -99  -9.9 -999.9  -9999 -99999 -99.9 -99.99 -99.900000 -99.900000 -99.900000  0 -9999.000  -9999.000  -999.0000 -999.0000 -99.99 -99 -99 -99 -999.99  -99.99  -99.99 -999.99 -999.99 -999.99     5    -9 -99 -9999  -99.99             -99.99   -99.99   -99.99  -99.99  -99.99];

or=data;

localtime_zone=timezone(or(:,10));
localtime=or(:,3)-localtime_zone*100;
localdate=or(:,2);
for i = 1:length(localtime)
    if localtime(i)>2359
        localtime(i)=localtime(i)-2400;
    elseif localtime(i)<0
        localtime(i)=localtime(i)+2400;
    end
    t=datetime(data(i,8)-localtime_zone(i)*60*60,'ConvertFrom','posixtime');
    localdate(i)=t.Year+t.Month*10000+t.Day*1000000;
end
localtime(or(:,10)==-999.9999)=or(or(:,10)==-999.9999,3);
localdate(or(:,10)==-999.9999)=or(or(:,10)==-999.9999,2);
data(:,4)=localdata;
data(:,5)=localtime;
outdata=data;

pos=strfind(filepath,'/');
outfilename=strcat(filepath(pos(end)+1:end-4),'_timefix.txt');
outfile=strcat(filepath(1:pos(end)),outfilename);
fileID=fopen(outfile,'w');
fprintf(fileID,formatSpec_of,outdata');