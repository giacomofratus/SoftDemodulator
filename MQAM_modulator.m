%Giacomo Fratus
%Ali Ashraf



clear;
clc;


%EE132A Final project
%4-PSK modulation

M = 16;                     % Size of signal constellation
k = log2(M);                % Number of bits per symbol
n = 600000;                  % Number of bits to process

plot = 1;

rng default                 % Use default random number generator
dataIn = randi([0 1],n,1);  % Generate vector of binary data

dataInMatrix = reshape(dataIn,length(dataIn)/k,k);   % Reshape data into binary k-tuples, k = log2(M)
dataSymbolsIn = bi2de(dataInMatrix);                 % Convert to integers

modSignalIn = qammod(dataSymbolsIn,M,'gray');     %Modulate the input using M-QAM


snr = -5;

recSignal = awgn(modSignalIn,snr,'measured'); %Simulate AWGN in the channel

sPlotFig = scatterplot(recSignal,1,0,'b.');   %Plot the constellations of the recieved signal and sent signal
hold on
grid on;
figure(1);
scatterplot(modSignalIn,1,0,'r*',sPlotFig);

%Generate LLRs
LLRbit = zeros(size(recSignal,1),k);

for i = 1:size(recSignal,1)
    %bit0
    if real(recSignal(i)) < -2
        LLRbit(i,1) = 2*(real(recSignal(i))+1);
    elseif real(recSignal(i))>2
        LLRbit(i,1) = 2*(real(recSignal(i))-1);
    else
        LLRbit(i,1) = real(recSignal(i));         
    end
    
    %bit1
    LLRbit(i,2) = -abs(real(recSignal(i)))+2;  
    
    %bit2
    if imag(recSignal(i)) < -2
        LLRbit(i,3) = -2*(imag(recSignal(i))+1);
    elseif imag(recSignal(i))>2
        LLRbit(i,3) = -2*(imag(recSignal(i))-1);
    else
        LLRbit(i,3) = -imag(recSignal(i));         
    end
    
    %bit3
    LLRbit(i,4) = -abs(imag(recSignal(i)))+2;       
end

signalPower = sum(norm(modSignalIn)^2)/size(modSignalIn,1);

var = signalPower/(10^(snr/20));

LLRbit = LLRbit.*(2/(var^2));


if plot
    figure(2);
    scatter(real(recSignal),LLRbit(:,1),'.');
    hold on;
    scatter(real(recSignal),LLRbit(:,2),'o','k');
    scatter(imag(recSignal),LLRbit(:,3),'.');
    scatter(imag(recSignal),LLRbit(:,4),'.','r');
    
    legend('bit0','bit1','bit2','bit3');
    grid on;

    title('theoretical LLRs 16-QAM, SNR = 15dB');
end

r_re = real(recSignal);
r_im = imag(recSignal);
modelInput = [r_re r_im];
modelOutput = LLRbit;

save('C:\Users\giaco\Documents\Python Scripts\TrainingData.mat','modelInput','modelOutput');

