% match current and EDDY data
clear all;

ddir = 'YOUR DIRECTORY TO FORMATION DATA FILES HERE';

myDataFile = 'EddyData.csv';
%myDataFile = 'FilamentData.csv';


inFile = [ddir myDataFile];
formData = readtable(inFile);

for yearOfInterest = 2019
    currentFile = [ddir 'aviso_meanCurrent_' num2str(yearOfInterest) '.txt'];
    disp(currentFile);
    current = readtable(currentFile);
    current = table2array(current);
    % use region 1 for whole-area current average
    % use region3 3 for indication of N-S current incursion
    currentDay = current(:,1);
    r1angle = current(:,2);
    r1vel = current(:,3);
    r3angle = current(:,6);
    r3vel = current(:,7);
    
    formData = formData(formData.Year==yearOfInterest,:);
    
    myDateTime = datetime(formData.Year, formData.Month, formData.Day);
    formDay = 1+days(myDateTime-datetime(year(myDateTime),1,1));
    formDay = sort(formDay);

    %indices = find(julianDay == dayofyear)
    for i = 1:length(currentDay)
        curday = currentDay(i)
        for k = 1:length(formDay)
            curJD = formDay(k)
            if curJD == curday
                clear index
                clear r1angle
                clear r1vel
                clear r3angle
                clear r3vel
                %index = find(julianDay == curJD);
                r1angle = current(i,2);
                r1vel = current(i,3);
                r3angle = current(i,6);
                r3vel = current(i,7);
                
                clear outputarray
                outputarray = [curJD; curday; r1angle; r1vel; r3angle; r3vel].'; % output days just to make sure correct match
                dlmwrite('CurrentAppend2019.csv', outputarray, '-append', 'delimiter',',', 'roffset', 0, 'coffset', 0);
                
            else
                disp('no match')
            end
            
        end
    end
    
    disp('finito')
end


