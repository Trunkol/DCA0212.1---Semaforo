library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity projeto2 is
port (	
			 clk, switch0, switch1   : in std_logic;
          botaoinicio, botaofinal :	in std_logic;
			 reset						 : in std_logic;
			 multa						 : out std_logic;
          counter, sinais 			 : out std_logic_vector(5 downto 0)
);
end projeto2;

architecture semaforo of projeto2 is
	component flipflopJK is
		port ( 
				clk:     in std_logic;
				clockenable: in std_logic;
				J, K:    in std_logic;
			   Q, Qbar: out std_logic;
				reset:    std_logic
				);
	end component;
	
	component DivisorFrequencia is
		port( 
			clock_in : in std_logic;
			clock_out : out std_logic
			);
	end component;

signal J3,J4,J5,J6,Q1,Q2,Q3,Q4,Q5,Q6,Qbar1,Qbar2,Qbar3,Qbar4, Qbar5, Qbar6, fimcontagem : std_logic :='0';
signal acaiverde, acaiamarelo, acaivermelho, guaranaverde, guaranamarelo, guaranavermelho : std_logic;
signal sita, sitb, sitc, clock_alterado : std_logic;

signal velocidadearmazenada, contadorvelocidade : std_logic_vector(5 downto 0);
begin 
	contadorvelocidade <= Q6 & Q5 & Q4 & Q3 & Q2 & Q1;

	process (botaoinicio, botaofinal, velocidadearmazenada, contadorvelocidade)
	begin
		if(botaoinicio = '1') then
			multa <= '0';
			velocidadearmazenada <= contadorvelocidade;
		end if;

		if(botaofinal = '1') then
			if(to_integer(unsigned(contadorvelocidade)) - (to_integer(unsigned(velocidadearmazenada))) < 3) then
				multa <= '1';
			else
				multa <= '0';
				velocidadearmazenada <= '0' & '0' & '0' & '0' & '0' & '0';
			end if;
		end if;
	end process;

	J3 <= Q1 and Q2;
	J4<= J3 and Q3;
	J5<= J4 and Q4;
	J6<= J5 and Q5;

	DVF00: DivisorFrequencia port map(clk, clock_alterado);
	
	fimcontagem <= Q6 and (not Q5) and Q4 and Q3 and Q2 and not Q1;
	
	FF1 : flipflopJK port map (clock_alterado,'1', '1','1',Q1,Qbar1,fimcontagem);
	FF2 : flipflopJK port map (clock_alterado,'1', Q1,Q1,Q2,Qbar2,fimcontagem);
	FF3 : flipflopJK port map (clock_alterado,'1', J3,J3,Q3,Qbar3,fimcontagem);
	FF4 : flipflopJK port map (clock_alterado,'1', J4,J4,Q4,Qbar4,fimcontagem);
	FF5 : flipflopJK port map (clock_alterado,'1', J5,J5,Q5,Qbar5,fimcontagem);
	FF6 : flipflopJK port map (clock_alterado,'1', J6,J6,Q6,Qbar6,fimcontagem);

	-- y = AB'CDEF'
	
	sita <= not switch0 and not switch1;
	sitb <= not switch0 and switch1;
	sitc <= switch0 and not switch1;
	-- A = Q6
	-- B = Q5
	-- C = Q4
	-- D = Q3
	-- E = Q2
	-- F = Q1
	
	--situação A:
	acaiverde <= 
		-- y = A'B' + A'C'D' (0 a 19)
		(((not Q6 and not Q5) or (not(Q6) and not Q4 and not Q3)) and sita) or 
		--  y = A'B' + A'C' + A'D' + A'E' (0 a 29)
		(((not Q6 and not Q5) or (not Q6 and not Q4) or (not Q6 and not Q3) or (not Q6 and not Q2)) and sitb) or
		-- Verde apagado
		('0' and sitc);
	 
	acaiamarelo <= 
		-- y = A'BC'DE' + A'BC'DF' (20 a 22)
		(((not Q6 and Q5 and not Q4 and Q3 and not Q2) or (not Q6 and Q5 and not Q4 and Q3 and not Q1)) and sita) or
		-- y = A'BCDE + AB'C'D'E'F' (30 a 32)
		(((not Q6 and Q5 and Q4 and Q3 and Q2) or (Q6 and not Q5 and not Q4 and not Q3 and not Q2 and not Q1)) and sitb) or
		-- Amarelo piscando
		(not Q1 and sitc);
		

	acaivermelho <= 
		-- y = A'BC + AB'C' + AB'D' + AB'E' + AB'F' + A'BDEF (23 a 45)
		 ((
			(not Q6 and Q5 and Q4) or 
			(Q6 and not Q5 and not Q4) or 
			(Q6 and (not Q5) and not Q3) or 
			(Q6 and (not Q5) and (not Q1)) or 
			(not (Q6) and (Q5 and Q3) and (Q2 and Q1))) 
			and sita) 
			or
		--	y = AB'C'F + AB'C'E + AB'DE' + AB'CD' (33 a 45)
		 ((
			(Q6 and not Q5 and not Q4 and Q1) or 
			(Q6 and not Q5 and not Q4 and Q2) or 
			(Q6 and not Q5 and Q3 and not Q2) or 
			(Q6 and not Q5 and Q4 and not Q3)) 
			and sitb)
			or
			('0' and sitc);
	
   guaranaverde <= 
	 -- y = A'BC + AB'C' + AB'D'E' + AB'D'F' + A'BDEF (23 a 42)
	 ((
		(not Q6 and Q5 and Q4) or (Q6 and not Q5 and not Q4) or 
		(Q6 and not Q5 and not Q3 and not Q2) or 
		(Q6 and not Q5 and not Q3 and not Q1) or 
		(not Q6 and Q5 and Q3 and Q2 and Q1)) 
		and sita) or
	 -- y = y = AB'C'F + AB'C'D + AB'D'EF' + AB'CD'E' (33 a 42)
	 (((Q6 and not Q5 and not Q4 and Q1) or 
		(Q6 and not Q5 and not Q4 and Q3) or 
		(Q6 and not Q5 and not Q3 and Q2 and not Q1) or 
		(Q6 and not Q5 and Q4 and not Q3 and not Q2)) and sitb)
		or
		('0' and sitc);

	  guaranamarelo <= 
	  -- y = AB'CDE' + AB'CD'EF (43 a 45)
	  (((Q6 and not Q5 and Q4 and Q3 and not Q2) or (Q6 and not Q5 and Q4 and not Q3 and Q2 and Q1)) and sita)  or
		-- y = AB'CDE' + AB'CD'EF (43 a 45)
	  (((Q6 and not Q5 and Q4 and Q3 and not Q2) or (Q6 and not Q5 and Q4 and not Q3 and Q2 and Q1)) and sitb) or (not Q1 and sitc);
	  
   guaranavermelho <= acaiverde or (acaiamarelo and (sitb or sita)) or (sitc and '0');
  
	sinais <= acaiverde & acaiamarelo & acaivermelho & guaranaverde & guaranamarelo & guaranavermelho; 
	counter <= Q6 & Q5 & Q4 & Q3 & Q2 & Q1;
	
	
end semaforo;
