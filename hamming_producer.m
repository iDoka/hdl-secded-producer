%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Project    : HDL SEC/DED Producer
%%  Designer   : Dmitry Murzinov (kakstattakim@gmail.com)
%%  Link       : https://github.com/iDoka/hdl-secded-producer
%%  Module     : hamming_producer.m
%%  Description: MATLAB generator of Hamming ECC coding. Output format is Verilog HDL
%%  Usage      : refer to README.adoc for usage help
%%  Revision   : $Rev
%%  Date       : $LastChangedDate$
%%  License    : MIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all

K = 4; % data bits
USE_POLY = 0;
POLY = [0 1 0 0 1];

FILE='HammingCode.v';

% calculate correction bits
% 1.25 - still magic numbers
m = ceil(log2(1.25*K));

if USE_POLY == 1
  [h,g,n,k] = hammgen(m, POLY);
else
  [h,g,n,k] = hammgen(m);
end

size_g = size(g);
size_v = size_g(1);
size_h = size_g(2);

size_v = K;
size_h = K+m;

fid = fopen(FILE,'wt');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% CODER %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fprintf(fid,'module HammingCoder(\n  input  [%d:0] D,\n  output [%d:0] DOUT);\n\n',K-1,K-1+m);
fprintf(fid,'module HammingCoder(\n  input  [%d:0] D,\n  output [%d:0] DOUT);\n\n',K-1,K+m);

fprintf(fid,'  wire [%d:0] data;\n\n',K+m-1);
fprintf(fid,'  assign data[%d:0] = D[%d:0];\n',K-1,K-1);


for mm = 1:m
  fprintf(fid,'  assign data[%02d] = ',K-1+mm);
  xor_flag = 0;
  for kk = 1:K
    if g(kk,mm) == 1
      if xor_flag == 0
        xor_flag = 1;
      else
        fprintf(fid,' ^ ');
      end
      if kk<11 fprintf(fid,' '); end
      fprintf(fid,'D[%d]',kk-1);
    end
  end
  fprintf(fid,';\n');
end
%fprintf(fid,'  assign DOUT[%02d] = ^ D[%d:0];\n',K+m,K+m-1);
fprintf(fid,'  assign DOUT = {^ data[%d:0], data[%d:0]};\n',K+m-1,K+m-1);
fprintf(fid,'\nendmodule\n\n\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% DECODER %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(fid,'module HammingDecoder(\n  input  [%d:0] D,\n  output [%d:0] DOUT,\n  output [1:0] ERR);\n\n',K+m,K-1);
fprintf(fid,'  wire [%d:0] S;\n',m-1);
fprintf(fid,'  wire PARITY;\n');
fprintf(fid,'  wire error_hamming;\n');

for mm = 1:m
  fprintf(fid,'  assign S[%d] = D[%02d]',mm-1,K-1+mm);
  for kk = 1:K
    if g(kk,mm) == 1
      fprintf(fid,' ^ ');
      if kk<11 fprintf(fid,' '); end
      fprintf(fid,'D[%d]',kk-1);
    end
  end
  fprintf(fid,';\n');
end
fprintf(fid,'\n');

for kk = 1:K
  fprintf(fid,'  assign DOUT[%02d] = D[%02d] ^',kk-1,kk-1);
  and_flag = 0;
  for mm = 1:m
    if g(kk,mm) == 1
      if and_flag == 0
        and_flag = 1;
      else
        fprintf(fid,' & ');
      end
      if kk<11 fprintf(fid,' '); end
      fprintf(fid,'S[%d]',mm-1);
    end
  end
  fprintf(fid,';\n');
end
fprintf(fid,'\n');

fprintf(fid,'  assign PARITY = ^ D[%d:0];\n',K+m);
fprintf(fid,'  assign error_hamming = | S[%d:0];\n',m-1);
fprintf(fid,'  assign ERR = {PARITY,error_hamming};\n');

fprintf(fid,'\nendmodule\n');

fclose(fid);

quit
