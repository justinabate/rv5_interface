library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rv5_top is 
generic (
	R2R_SIZE : natural := 5
);
port (
	-- clocks
	i_clk       : in  STD_LOGIC; -- master clock
	-- enable i/f
--	ena_sw      : in  STD_LOGIC; -- fx enable slide switch
--	ena_cv      : in  STD_LOGIC; -- fx enable CV input
--	ena_cv_dv   : in  STD_LOGIC; -- fx enable CV detected
--	ena_out     : out STD_LOGIC; -- fx enable to pedal
	-- mode i/f
	i_pushbttn : in  STD_LOGIC_VECTOR (5 downto 0); -- mode pushbutton detected
	o_r2r_vout : out STD_LOGIC_VECTOR (R2R_SIZE-1 downto 0); -- r2r output bias
	o_7seg_dat : out STD_LOGIC_VECTOR (6 downto 0);  -- mode LED pulldown
	o_7seg_sel : out STD_LOGIC_VECTOR (3 downto 0)  -- LED digit pullup
); end rv5_top;

architecture rtl of rv5_top is

	constant c_num_seg : natural := 7; -- segments per digit
	constant c_num_dig : natural := 4; -- number of digits
	signal w_7seg_dat : std_logic_vector(c_num_seg*c_num_dig-1 downto 0); -- vector for 4x 7seg digits 

begin


--	INST_FX_TOG : entity work.fx_toggle(rtl)
--		port map (
--			clk    => i_clk,
--			cv_dv  => ena_cv_dv,
--			cv     => ena_cv,
--			sw     => ena_sw,
--			toggle => ena_out
--	);
	

	INST_MODE_SEL : entity work.mode_select(rtl)
	generic map (
    	g_r2r_size => R2R_SIZE,
		g_num_seg => c_num_seg,
    	g_num_dig => c_num_dig
	)
	port map (
		i_clk       => i_clk,
		--! active lo input from the PCB
		i_pushbttn  => i_pushbttn,
		--! set 7-segement data vector based on the pushbutton
		o_7seg_dat  => w_7seg_dat,  
		--! active hi output to the PCB
		o_r2r_vout	=> o_r2r_vout
	); 	  
	  

	INST_7SEG_DRVR : entity work.sev_seg_drvr(rtl)
	generic map (
		g_clk_frq => 12000000, -- Hz
		g_ref_frq => 720, -- Hz
		g_num_seg => 7,
		g_num_dig => 4
	)
	port map (
		-- : in  std_logic;
		i_clk			    => i_clk, 
		--! input segment data
		-- : in (6:0); 7seg vector for left digit
		i_dig_1 		  => w_7seg_dat( c_num_seg*(c_num_dig-0)-1 downto c_num_seg*(c_num_dig-1) ), 
		-- : in (6:0); 7seg vector for ...
		i_dig_2 		  => w_7seg_dat( c_num_seg*(c_num_dig-1)-1 downto c_num_seg*(c_num_dig-2) ), 
		-- : in (6:0); 7seg vector for ...
		i_dig_3 		  => w_7seg_dat( c_num_seg*(c_num_dig-2)-1 downto c_num_seg*(c_num_dig-3) ), 
		-- : in (6:0); 7seg vector for right digit
		i_dig_4 		  => w_7seg_dat( c_num_seg*(c_num_dig-3)-1 downto c_num_seg*(c_num_dig-4) ), 
		--! digit select driver (pullup)
		o_digit_sel		=> o_7seg_sel, -- : out std_logic_vector(g_num_digits-1 downto 0);
		--! segment select driver (pulldown)
		o_sgmnt_dat 	=> o_7seg_dat -- : out std_logic_vector(6 downto 0);	
	);

end rtl;