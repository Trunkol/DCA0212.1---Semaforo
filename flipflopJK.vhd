library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flipflopJK is
port ( clk:     in std_logic;
          J, K:               in std_logic;
          Q, Qbar:       out std_logic;
           reset:              in std_logic
);
end flipflopJK;

architecture Behavioral of flipflopJK is
signal qtemp,qbartemp : std_logic :='0';
begin
Q <= qtemp;
Qbar <= qbartemp;

process(clk,reset)
begin
if(reset = '1') then           
 qtemp <= '0';
 qbartemp <= '1';
elsif( rising_edge(clk) ) then
if(J='0' and K='0') then       
 NULL;
elsif(J='0' and K='1') then    
 qtemp <= '0';
 qbartemp <= '1';
elsif(J='1' and K='0') then    
 qtemp <= '1';
 qbartemp <= '0';
else                          
 qtemp <= not qtemp;
 qbartemp <= not qbartemp;
end if;
end if;
end process;

end Behavioral;