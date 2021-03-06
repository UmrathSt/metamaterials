function [port] = DoS11Dump(port, sPP);
physical_constants;
fstart = sPP.SParameters.fstart;
fstop = sPP.SParameters.fstop;
df       = sPP.SParameters.df;
freq = linspace(fstart, fstop, round((fstop - fstart)/df));
Sim_Path = [sPP.Paths.SimBasePath sPP.Paths.SimPath];
Res_Path = [sPP.Paths.ResultBasePath sPP.Paths.ResultPath '/' ];
s11_filename = strcat('S11_', sPP.SParameters.ResultFilename);
s21_filename = strcat('S21_', sPP.SParameters.ResultFilename);
params = sPP.ParamStr;
epsilon_left = sPP.lEpsilon + 1j*sPP.lKappa./(2*pi*freq*EPS0);
Z1 = conj(sqrt(MUE0./(EPS0*epsilon_left)));
port{1} = calcPort(port{1}, Sim_Path, freq, 'RefImpedance', Z1, 'SwitchDirection', 1);%, 'RefImpedance', 130
% propagation in conductive media: E(x,t) = E0 exp(-iwt + i alpha*x)*exp(-beta*x)
w = 2*pi*freq;
[alpha, beta] = calcPropagationConstant(w, sPP.lEpsilon, sPP.lKappa);
fprintf('Z1(1) = %.2f+i %.2f \n', real(Z1(1)), imag(Z1(1)));
%fprintf(['The calculated port(1) impedance is Z_ref = %.2f\n'], port{1}.ZL);
fprintf('alpha, beta (left) %.2f, %.2f \n', alpha(1), beta(1));
s11factor = sPP.LSPort1*alpha*1j + beta*sPP.LSPort1;
S11Phase = exp(2*s11factor);


s11 = port{1}.uf.ref ./ (port{1}.uf.inc).*S11Phase;
s11 = abs(s11).*exp(-1j.*angle(s11));
s21 = zeros(1, length(freq));
epsilon_right = 1;
if strcmp(sPP.grounded, 'False');
    [alpha, beta] = calcPropagationConstant(w, sPP.rEpsilon, sPP.rKappa);
    fprintf('alpha, beta (right) %.2f, %.2f \n', alpha(1), beta(1));
    epsilon_right = sPP.rEpsilon + 1j*sPP.rKappa./(2*pi*freq*EPS0);
    s21factor = -(sPP.LSPort2*alpha*1j + beta*sPP.LSPort2) + s11factor;
    S21Phase = exp(s21factor);
    Z2 = sqrt(MUE0./(EPS0*epsilon_right));
    port{2} = calcPort(port{2}, Sim_Path, freq, 'RefImpedance', Z2, 'SwitchDirection', 1);
    fprintf('Z2(1) = %.2f+i %.2f \n', real(Z2(1)), imag(Z2(1)));
    %fprintf(['The calculated port(2) impedance is ZL = %.2f\n'], port{2}.ZL);
    s21 = port{2}.uf.inc./port{1}.uf.inc.*S21Phase; % divide by epsilon_left
    s21 = abs(s21).*exp(-1j.*angle(s21));%                                                for power normalization
end;
  Zin = sqrt(4*pi*1e-7./(EPS0*epsilon_right)) .* sqrt(((1+s11) .**2-s21.**2)./ ((1-s11).**2-s21.**2));
  s_folder = [Res_Path];
folder_status = exist(s_folder);
if folder_status == 0;
    fprintf('Folder for S11 output did not exist.');
    fprintf(['Calling: mkdir ' s_folder]);
    [STATUS, MSG, MSGID] = mkdir(s_folder);
elseif folder_status == 7;
    fprintf('Folder for S11 output found:\n');
    fprintf([s_folder '\n']);
else;
        error(['There is a problem with the S11 result folder! ( ' num2str(STATUS) ')' '\n error message: ' MSG '\n']);
end;
  outfile = fopen([s_folder s11_filename], 'w+');
  fprintf(outfile, [params]);
  fprintf(outfile, '# Re/Im parts of the voltage amplitude scattering parameters S11 (refl.) and S21 (transm.) and the real and imaginary part of the input impedance as a function of frequency \n');
  fprintf(outfile, '# To obtain the transmitted power, multiply S21^2 by Z1/Z2.\n');
  fprintf(outfile, '# first column is frequency, second and third columns are Re/Im of S11, S21 and Zin respectively.\n');
  for i=1:size(s11,2);
      fprintf(outfile, '%f, %f, %f, %f, %f, %f, %f ', freq(1, i), real(s11(1, i)), imag(s11(1,i )), real(s21(1,i )), imag(s21(1,i )), real(Zin(1,i)), imag(Zin(1,i)));
      fprintf(outfile, '\n');
  end;
  fclose(outfile);
  xlabel = '"$ f\\; [\\mathrm{GHz}]$"';
  ylabelS11 = '"$ S_{11}$"';
  ylabelS21 = '"$ S_{21}$"';
  PYScriptPath = [sPP.Paths.ResultBasePath 'python_scripts/S11_abs_phase_plot.py'];
  system(['python3 ' PYScriptPath ' --infile ' s11_filename ' --xlabel ' xlabel ' --ylabel ' ylabelS11 ' --folder ' s_folder ' --outfile ' s11_filename ' --Xaxis ' num2str(0) ' --Yaxis ' num2str(1)]);
  if ~strcmp(sPP.grounded, 'True');
    system(['python3 ' PYScriptPath ' --infile ' s11_filename ' --xlabel ' xlabel ' --ylabel ' ylabelS21 ' --folder ' s_folder ' --outfile ' s21_filename ' --Xaxis ' num2str(0) ' --Yaxis ' num2str(3)]);
  end;
  return;
end