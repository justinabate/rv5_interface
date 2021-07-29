library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rv5_top is 
generic (
	R2R_SIZE : natural := 5
);
port (
	-- clocks
	clk_m       : in  STD_LOGIC; -- master clock
	-- enable i/f
--	ena_sw      : in  STD_LOGIC; -- fx enable slide switch
--	ena_cv      : in  STD_LOGIC; -- fx enable CV input
--	ena_cv_dv   : in  STD_LOGIC; -- fx enable CV detected
--	ena_out     : out STD_LOGIC; -- fx enable to pedal
	-- mode i/f
	mode_pb     : in  STD_LOGIC_VECTOR (5 downto 0); -- mode pushbutton detected
	mode_r2r    : out STD_LOGIC_VECTOR (R2R_SIZE-1 downto 0); -- r2r output bias
	mode_led_segment_data : out STD_LOGIC_VECTOR (6 downto 0);  -- mode LED pulldown
	mode_led_active_digit : out STD_LOGIC_VECTOR (3 downto 0)  -- LED digit pullup
); end rv5_top;

architecture rtl of rv5_top is

	constant c_num_seg : natural := 7; -- segments per digit
	constant c_num_dig : natural := 4; -- number of digits
	signal mode_display : std_logic_vector(c_num_seg*c_num_dig-1 downto 0); -- vector for 4x 7seg digits 

begin

--	INST_FX_TOG : entity work.fx_toggle(rtl)
--		port map (
--			clk    => clk_m,
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
		clk          => clk_m,
		mode_pb      => mode_pb, -- active low
		mode_display => mode_display, -- active low
		mode_vout	 => mode_r2r
	); 


	INST_7SEG_DRVR : entity work.sev_seg_drvr(rtl)
	generic map (
    g_clk_frq => 12000000, -- Hz
    g_ref_frq => 720, -- Hz
    g_num_seg => 7,
    g_num_dig => 4
	)
	port map (
    i_clk			    => clk_m, -- : in  std_logic;
    --! input segment data
    i_dig_1 		  => mode_display( c_num_seg*(c_num_dig-0)-1 downto c_num_seg*(c_num_dig-1) ), -- : in (6:0); 7seg vector for left digit
    i_dig_2 		  => mode_display( c_num_seg*(c_num_dig-1)-1 downto c_num_seg*(c_num_dig-2) ), -- : in (6:0); 7seg vector for ...
    i_dig_3 		  => mode_display( c_num_seg*(c_num_dig-2)-1 downto c_num_seg*(c_num_dig-3) ), -- : in (6:0); 7seg vector for ...
    i_dig_4 		  => mode_display( c_num_seg*(c_num_dig-3)-1 downto c_num_seg*(c_num_dig-4) ), -- : in (6:0); 7seg vector for right digit
    --! digit select driver (pullup)
    o_drive_dig		=> mode_led_active_digit, -- : out std_logic_vector(g_num_digits-1 downto 0);
    --! segment select driver (pulldown)
    o_drive_seg 	=> mode_led_segment_data -- : out std_logic_vector(6 downto 0);	
	);

end rtl;