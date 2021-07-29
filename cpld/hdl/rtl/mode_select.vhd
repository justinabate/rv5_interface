library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

--! two-process state machine which toggles output voltage & display on button presses

entity mode_select is 
generic (
	g_r2r_size : natural := 5; -- number of segments per digit
	g_num_seg : natural := 7; -- number of segments per digit
	g_num_dig : natural := 4  -- number of digits on display
);
port (
	i_clk      : in  STD_LOGIC;
	i_pushbttn : in  STD_LOGIC_VECTOR (5 downto 0); -- active high PB input
	o_7seg_dat : out STD_LOGIC_VECTOR (g_num_seg*g_num_dig-1 downto 0); -- active low LED output	
	o_r2r_vout : out STD_LOGIC_VECTOR (g_r2r_size-1 downto 0) -- mode voltage bias
); end mode_select;


architecture rtl of mode_select is

	type FSM_STATE is (m0, m1, m2, m3, m4, m5);
	signal fsm_cs : FSM_STATE := m0; -- default state
	
begin

	--! when a pushbutton press is detected (pulled down), 
	--! change the current state to the respective mode 
	p_state_update : process (i_clk) is begin
		if ((i_clk'event) and (i_clk='1')) then
			
			if (i_pushbttn(0) = '0') then 
				fsm_cs <= m0;
			end if;
			
			if (i_pushbttn(1) = '0') then 
				fsm_cs <= m1;					
			end if;
			
			if (i_pushbttn(2) = '0') then 
				fsm_cs <= m2;					
			end if;
			
			if (i_pushbttn(3) = '0') then 
				fsm_cs <= m3;					
			end if;
			
			if (i_pushbttn(4) = '0') then 
				fsm_cs <= m4;					
			end if;
			
			if (i_pushbttn(5) = '0') then 
				fsm_cs <= m5;
			end if;
			
		end if;
	end process;

	p_state_output : process (i_clk) is begin
		if ((i_clk'event) and (i_clk='1')) then
			case (fsm_cs) is 
				
				-- m0: MODX -> 0V0
				when (m0) => 
					o_7seg_dat <= "0101011" & "0111111" & "1011110" & "0000000"; -- [M] [O] [d] [ ] 
					o_r2r_vout <= '0' & x"0"; 

				-- m1: GATE -> 0V3
				when (m1) => 
					o_7seg_dat <= "0111101" & "1110111" & "1110000" & "1111001"; -- [G] [A] [t] [E] 
					o_r2r_vout <= '0' & x"2"; 

				-- m2: ROOM -> 0V6
				when (m2) => 				
					o_7seg_dat <= "1010000" & "1011100" & "1011100" & "0101011"; -- [r] [o] [o] [M] 
					o_r2r_vout <= '0' & x"5";
					
				-- m3: HALL -> 0V9
				when (m3) => 				
					o_7seg_dat <= "1110110" & "1110111" & "0111000" & "0111000"; -- [H] [A] [L] [L] 
					o_r2r_vout <= '0' & x"8";

				-- m4: PLTE -> 1V2
				when (m4) => 				
					o_7seg_dat <= "1110011" & "0111000" & "1110111" & "1110000"; -- [P] [L] [A] [t] 
					o_r2r_vout <= '0' & x"B";

				-- m5: SPRG -> 1V5	
				when (m5) => 				
					o_7seg_dat <= "1101101" & "1110011" & "1010000" & "0111101"; -- [S] [P] [r] [G] 
					o_r2r_vout <= '0' & x"F";

				-- default state
				when others =>
					o_7seg_dat <= "0101011" & "0111111" & "1011110" & "0000000"; -- [M] [O] [d] [ ] 
					o_r2r_vout <= '0' & x"0"; 					
	
				end case; 
		end if; 
	end process;
	
end rtl;