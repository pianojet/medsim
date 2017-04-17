function CepFeature = Cep_Feature(MelFeature, numcep, sr)

% DCT to  4-D Gabor-Mel feature
% check parameter settings in "melfcc.m"

dcttype = 2;
lifterexp = 0.6;
[row, col, di, sc] = size(MelFeature);
CepFeature = zeros(numcep, col, di, sc); % 40 = nbands
for k = 1:di
    for kk = 1:sc
        spectra = postaud(MelFeature(:,:,k,kk), sr);
        cepstra = spec2cep(spectra, numcep, dcttype);

%         cepstra = spec2cep(MelFeature(:,:,k,kk), numcep, dcttype);
        
%         spectra = postaud(MelFeature(:,:,k,kk), sr);
%         lpcas = dolpc(spectra, numcep-1);
%         cepstra = lpc2cep(lpcas, numcep);
  
        cepstra = lifter(cepstra, lifterexp);
        t = isnan(cepstra);%getting rid of NaN values, appear because of lg(0)
        cepstra(find(t(:) == 1)) = 0;
        CepFeature(:,:,k,kk) = cepstra;
    end
end




end