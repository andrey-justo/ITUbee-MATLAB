%%%%
%% ITUbee_lib
%%%%
function state=create_state(M)
%% Create a state from a message M coded hexadecimal
  state=[];
  for i=1:2:length(M)-1
    state=[state hex2dec(M(i:i+1))];
  end
end


function x=xor_2x5(P, K) %% xor of 5 bytes (P) with 5 other bytes (K)
    x=bitxor(P, K);
end

function x=L(state) %% Function L of the ITUBee specifications
  x(1)=bitxor(bitxor(state(5),state(1)),state(2));
  x(2)=bitxor(bitxor(state(1),state(2)),state(3));
  x(3)=bitxor(bitxor(state(2),state(3)),state(4));
  x(4)=bitxor(bitxor(state(3),state(4)),state(5));
  x(5)=bitxor(bitxor(state(4),state(5)),state(1));
end

function x=F(state, sbox) %% Function F of the ITUBee specifications
  for i=1:5
    x_t(i)=sbox(state(i)+1);
  end
  x_t=L(x_t);
  for i=1:5
    x(i)=sbox(x_t(i)+1);
  end
end

function c=ITUbee_enc(m, k) %% Encryption
  %% Constants
  SBOX=[099 124 119 123 242 107 111 197 048 001 103 043 254 215 171 118 ...
      202 130 201 125 250 089 071 240 173 212 162 175 156 164 114 192 ...
      183 253 147 038 054 063 247 204 052 165 229 241 113 216 049 021 ...
      004 199 035 195 024 150 005 154 007 018 128 226 235 039 178 117 ...
      009 131 044 026 027 110 090 160 082 059 214 179 041 227 047 132 ...
      083 209 000 237 032 252 177 091 106 203 190 057 074 076 088 207 ...
      208 239 170 251 067 077 051 133 069 249 002 127 080 060 159 168 ...
      081 163 064 143 146 157 056 245 188 182 218 033 016 255 243 210 ...
      205 012 019 236 095 151 068 023 196 167 126 061 100 093 025 115 ...
      096 129 079 220 034 042 144 136 070 238 184 020 222 094 011 219 ...
      224 050 058 010 073 006 036 092 194 211 172 098 145 149 228 121 ...
      231 200 055 109 141 213 078 169 108 086 244 234 101 122 174 008 ...
      186 120 037 046 028 166 180 198 232 221 116 031 075 189 139 138 ...
      112 062 181 102 072 003 246 014 097 053 087 185 134 193 029 158 ...
      225 248 152 017 105 217 142 148 155 030 135 233 206 085 040 223 ...
      140 161 137 013 191 230 066 104 065 153 045 015 176 084 187 022];
      
  RC=['1428'; '1327'; '1226'; '1125'; '1024'; ...
      '0f23'; '0e22'; '0d21'; '0c20'; '0b1f'; ...
      '0a1e'; '091d'; '081c'; '071b'; '061a'; ...
      '0519'; '0418'; '0317'; '0216'; '0115'];
  
  %% State creation
  state_m=create_state(m);
  state_k=create_state(k);
  %%%%
  %% Initial
  %%%%
  x(1,:)=xor_2x5(state_m(6:10), state_k(6:10));
  x(2,:)=xor_2x5(state_m(1:5), state_k(1:5));

  %%%%
  %% rounds
  %%%%
  R=[0 0 0 0 0];
  for i=1:20
    if mod(i,2)==1
      RK=state_k(6:10);
    else
      RK=state_k(1:5);
    end
    R(4)=hex2dec(RC(i,1:2));
    R(5)=hex2dec(RC(i,3:4));

    x(end+1,:)=bitxor(x(i,:), F(L(bitxor(RK, bitxor(R, F(x(i+1,:), SBOX)))), SBOX));
  end
  size(x)
  %%%%
  %%  Final
  %%%%
  c_tmp(1:5)=xor_2x5(x(21,:), state_k(6:10));
  c_tmp(6:10)=xor_2x5(x(22,:), state_k(1:5));
  %% reformat cipher
  c_tmp=dec2hex(c_tmp);
  c='';
  for i=1:length(c_tmp)
    c=[c c_tmp(i,:)];
  end
end

function M=ITUbee_dec(c, k) %% Decryption
  %% Constants
  SBOX=[099 124 119 123 242 107 111 197 048 001 103 043 254 215 171 118 ...
      202 130 201 125 250 089 071 240 173 212 162 175 156 164 114 192 ...
      183 253 147 038 054 063 247 204 052 165 229 241 113 216 049 021 ...
      004 199 035 195 024 150 005 154 007 018 128 226 235 039 178 117 ...
      009 131 044 026 027 110 090 160 082 059 214 179 041 227 047 132 ...
      083 209 000 237 032 252 177 091 106 203 190 057 074 076 088 207 ...
      208 239 170 251 067 077 051 133 069 249 002 127 080 060 159 168 ...
      081 163 064 143 146 157 056 245 188 182 218 033 016 255 243 210 ...
      205 012 019 236 095 151 068 023 196 167 126 061 100 093 025 115 ...
      096 129 079 220 034 042 144 136 070 238 184 020 222 094 011 219 ...
      224 050 058 010 073 006 036 092 194 211 172 098 145 149 228 121 ...
      231 200 055 109 141 213 078 169 108 086 244 234 101 122 174 008 ...
      186 120 037 046 028 166 180 198 232 221 116 031 075 189 139 138 ...
      112 062 181 102 072 003 246 014 097 053 087 185 134 193 029 158 ...
      225 248 152 017 105 217 142 148 155 030 135 233 206 085 040 223 ...
      140 161 137 013 191 230 066 104 065 153 045 015 176 084 187 022];
      
  RC=['1428'; '1327'; '1226'; '1125'; '1024'; ...
      '0f23'; '0e22'; '0d21'; '0c20'; '0b1f'; ...
      '0a1e'; '091d'; '081c'; '071b'; '061a'; ...
      '0519'; '0418'; '0317'; '0216'; '0115'];
  
  %% State creation
  state_m=create_state(c);
  state_k=create_state(k);

  x=[];
  %%%%
  %% Initial
  %%%%
  x(1,:)=xor_2x5(state_m(6:10), state_k(1:5));
  x(2,:)=xor_2x5(state_m(1:5), state_k(6:10));

  %%%%
  %% rounds
  %%%%
  R=[0 0 0 0 0];
  for i=1:20
    if mod(i, 2)==0
      RK=state_k(6:10);
    else
      RK=state_k(1:5);
    end
    R(4)=hex2dec(RC(end+1-i,1:2));
    R(5)=hex2dec(RC(end+1-i,3:4));

    x(end+1,:)=bitxor(x(i,:), F(L(bitxor(RK, bitxor(R, F(x(i+1,:), SBOX)))), SBOX));
  end

  %%%%
  %%  Final
  %%%%
  M_tmp(1:5)=xor_2x5(x(21,:), state_k(1:5));
  M_tmp(6:10)=xor_2x5(x(22,:), state_k(6:10));
  
   %% reformat cipher
  M_tmp=dec2hex(M_tmp);
  M='';
  for i=1:length(M_tmp)
    M=[M M_tmp(i,:)];
  end
end