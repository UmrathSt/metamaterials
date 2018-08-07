function [port] = DoS11Dump(port, sPP);
fstart = sPP.SParameters.fstart;
fstop = sPP.SParameters.fstop;
df       = sPP.SParameters.df;
freq = linspace(fstart, fstop, round((fstop - fstart)/df));
Sim_Path = [sPP.Paths.SimBasePath sPP.Paths.SimPath];
Res_Path = [sPP.Paths.ResultBasePath sPP.Paths.ResultPath '/' ];
s11_filename = horzcat('S11_', sPP.SParameters.ResultFilename);
s21_filename = horzcat('S21_', sPP.SParameters.ResultFilename);
params = sPP.ParamStr;
port{1} = calcPort(port{1}, Sim_Path, freq, 'RefImpedance', 376.73);%, 'RefImpedance', 130
S11Phase = exp(sPP.S11PhaseFactor*freq);
Z1 = port{1}.uf.tot ./ port{1}.if.tot;
s11 = port{1}.uf.ref ./ (port{1}.uf.inc).*S11Phase;
s21 = zeros(1, length(freq));

if ~strcmp(sPP.grounded, 'True');
    S21Phase = exp(sPP.S21PhaseFactor*freq);
    port{2} = calcPort(port{2}, Sim_Path, freq, 'RefImpedance', 376.73);%, 'RefImpedance', 130
    s21 = port{2}.uf.inc./port{1}.uf.inc*S21Phase;
end;
  Zin = 376.73 .* sqrt(((1+s11) .**2-s21.**2)./ ((1-s11).**2-s21.**2));
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
  fprintf(['Using the result file: ', s_folder s11_filename '\n']);
  outfile = fopen([s_folder s11_filename], 'w+');
  fprintf(outfile, [params]);
  fprintf(outfile, '# Re/Im parts of the scattering parameters S11 (refl.) and S21 (transm.) and the real and imaginary part of the input impedance as a function of frequency \n');
  fprintf(outfile, '# first column is frequency, second and third columns are Re/Im of S11, S21 and Zin respectively.\n');
  for i=1:size(s11,2);
      fprintf(outfile, '%f, %f, %f, %f, %f, %f, %f ', freq(1, i), real(s11(1, i)), imag(s11(1,i )), real(s21(1,i )), imag(s21(1,i )), real(Zin(1,i)), imag(Zin(1,i)));
      fprintf(outfile, '\n');
  end;
  fclose(outfile);
  xlabel = '"$ f\\; [\\mathrm{GHz}]$"';
  ylabelS11 = '"$ 20\\log|S_{11}|$"';
  ylabelS21 = '"$ 20\\log|S_{21}|$"';
  PYScriptPath = [sPP.Paths.ResultBasePath 'python_scripts/S11_plot.py'];
  system(['python3 ' PYScriptPath ' --infile ' s11_filename ' --xlabel ' xlabel ' --ylabel ' ylabelS11 ' --folder ' s_folder ' --outfile ' s11_filename ' --Xaxis ' num2str(0) ' --Yaxis ' num2str(1)]);
  if ~strcmp(sPP.grounded, 'True');
    system(['python3 ' PYScriptPath ' --infile ' s21_filename ' --xlabel ' xlabel ' --ylabel ' ylabelS21 ' --folder ' s_folder ' --outfile ' s21_filename ' --Xaxis ' num2str(0) ' --Yaxis ' num2str(3)]);
  end;
  return;
end