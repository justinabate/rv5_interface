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
	clk          : in  STD_LOGIC;
	mode_pb      : in  STD_LOGIC_VECTOR (5 downto 0); -- active high PB input
	mode_display : out STD_LOGIC_VECTOR (g_num_seg*g_num_dig-1 downto 0); -- active low LED output	
	mode_vout    : out STD_LOGIC_VECTOR (g_r2r_size-1 downto 0) -- mode voltage bias
); end mode_select;


architecture rtl of mode_select is

	type FSM_STATE is (m0, m1, m2, m3, m4, m5);
	signal fsm_cs : FSM_STATE := m0; -- default state
	
begin

	--! when a pushbutton press is detected (pulled down), 
	--! change the current state to the respective mode 
	p_state_update : process (clk) is begin
		if ((clk'event) and (clk='1')) then
			
			if (mode_pb(0) = '0') then 
				fsm_cs <= m0;
			end if;
			
			if (mode_pb(1) = '0') then 
				fsm_cs <= m1;					
			end if;
			
			if (mode_pb(2) = '0') then 
				fsm_cs <= m2;					
			end if;
			
			if (mode_pb(3) = '0') then 
				fsm_cs <= m3;					
			end if;
			
			if (mode_pb(4) = '0') then 
				fsm_cs <= m4;					
			end if;
			
			if (mode_pb(5) = '0') then 
				fsm_cs <= m5;
			end if;
			
		end if;
	end process;

	p_state_output : process (clk) is begin
		if ((clk'event) and (clk='1')) then
			case (fsm_cs) is 
				
				-- m0: MODX -> 0V0
				when (m0) => 
					mode_display <= "0101011" & "0111111" & "1011110" & "0000000"; -- [M] [O] [d] [ ] 
					mode_vout <= '0' & x"0"; 

				-- m1: GATE -> 0V3
				when (m1) => 
					mode_display <= "0111101" & "1110111" & "1110000" & "1111001"; -- [G] [A] [t] [E] 
					mode_vout <= '0' & x"2"; 

				-- m2: ROOM -> 0V6
				when (m2) => 				
					mode_display <= "1010000" & "1011100" & "1011100" & "0101011"; -- [r] [o] [o] [M] 
					mode_vout <= '0' & x"5";
					
				-- m3: HALL -> 0V9
				when (m3) => 				
					mode_display <= "1110110" & "1110111" & "0111000" & "0111000"; -- [H] [A] [L] [L] 
					mode_vout <= '0' & x"8";

				-- m4: PLTE -> 1V2
				when (m4) => 				
					mode_display <= "1110011" & "0111000" & "1110111" & "1110000"; -- [P] [L] [A] [t] 
					mode_vout <= '0' & x"B";

				-- m5: SPRG -> 1V5	
				when (m5) => 				
					mode_display <= "1101101" & "1110011" & "1010000" & "0111101"; -- [S] [P] [r] [G] 
					mode_vout <= '0' & x"F";

				-- default state
				when others =>
					mode_display <= "0101011" & "0111111" & "1011110" & "0000000"; -- [M] [O] [d] [ ] 
					mode_vout <= '0' & x"0"; 					
	
				end case; 
		end if; 
	end process;
	
end rtl;