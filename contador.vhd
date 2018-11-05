library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity contador is
port (	
			 clk, switch0, switch1 :     in std_logic;
          reset:      in std_logic;
          counter, sinais : out std_logic_vector(5 downto 0)
);
end contador;

architecture semaforo of contador is
	component flipflopJK is
		port ( 
				clk:     in std_logic;
				J, K:    in std_logic;
			   Q, Qbar: out std_logic;
				reset:   in std_logic
				);
	end component;
	
	component DivisorFrequencia is
		port( 
			clock_in : in std_logic;
			clock_out : out std_logic
			);
	end component;

signal J3,J4,J5,J6,Q1,Q2,Q3,Q4,Q5,Q6,Qbar1,Qbar2,Qbar3,Qbar4, Qbar5, Qbar6 : std_logic :='0';
signal acaiverde, acaiamarelo, acaivermelho, guaranaverde, guaranamarelo, guaranavermelho : std_logic;
signal sita, sitb, sitc, clock_alterado : std_logic;

begin 
	J3 <= Q1 and Q2;
	J4<= J3 and Q3;
	J5<= J4 and Q4;
	J6<= J5 and Q5;

	DVF00: DivisorFrequencia port map(clk, clock_alterado);
	
	FF1 : flipflopJK port map (clock_alterado,'1','1',Q1,Qbar1,reset);
	FF2 : flipflopJK port map (clock_alterado, Q1,Q1,Q2,Qbar2,reset);
	FF3 : flipflopJK port map (clock_alterado, J3,J3,Q3,Qbar3,reset);
	FF4 : flipflopJK port map (clock_alterado, J4,J4,Q4,Qbar4,reset);
	FF5 : flipflopJK port map (clock_alterado, J5,J5,Q5,Qbar5,reset);
	FF6 : flipflopJK port map (clock_alterado, J6,J6,Q6,Qbar6,reset);
	
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
		(((not Q6 and not Q5) or (not Q6 and not Q4) or (not Q6 and not Q3) or (not Q6 and not Q2)) and sitb);
	 
	acaiamarelo <= 
		-- y = A'BC'DE' + A'BC'DF' (20 a 22)
		(((not Q6 and Q5 and not Q4 and Q3 and not Q2) or (not Q6 and Q5 and not Q4 and Q3 and not Q1)) and sita) or
		-- y = A'BCDE + AB'C'D'E'F' (30 a 32)
		(((not Q6 and Q5 and Q4 and Q3 and Q2) or (Q6 and not Q5 and not Q4 and not Q3 and not Q2 and not Q1)) and sitb);
 

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
			and sitb);
		
  
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
		(Q6 and not Q5 and Q4 and not Q3 and not Q2)) and sitb);

	  guaranamarelo <= 
	  -- y = AB'CDE' + AB'CD'EF (43 a 45)
	  (((Q6 and not Q5 and Q4 and Q3 and not Q2) or (Q6 and not Q5 and Q4 and not Q3 and Q2 and Q1)) and sita)  or
		-- y = AB'CDE' + AB'CD'EF (43 a 45)
	  (((Q6 and not Q5 and Q4 and Q3 and not Q2) or (Q6 and not Q5 and Q4 and not Q3 and Q2 and Q1)) and sitb);
	  
	  guaranavermelho <= acaiverde or acaiamarelo;
  
--  --situação C:
--  ave <= '0';
--  aam <= not Q1;
--  avo <= '0';
--  gve <= '0';
--  gam <= not Q1;
--  gvo <= '0';
	sinais <= acaiverde & acaiamarelo & acaivermelho & guaranaverde & guaranamarelo & guaranavermelho; 
	counter <= Q6 & Q5 & Q4 & Q3 & Q2 & Q1;


end semaforo;