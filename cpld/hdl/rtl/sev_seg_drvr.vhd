library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all; -- for constant calculations


entity sev_seg_drvr is 
generic (
	--! Hz
	g_clk_frq	: integer := 33000000;	                      
	--! Hz
	g_ref_frq 	: integer := 720;                             
	--! number of segments per digit
	g_num_seg   : integer := 7;                               
	--! number of digits on display
	g_num_dig   : integer := 4                                
); 
port (
	--! clock 
	i_clk		  : in  std_logic;                              
	--! segment data for digit 1
	i_dig_1 	  : in  std_logic_vector(g_num_seg-1 downto 0); 
	--! segment data for digit 2
	i_dig_2 	  : in  std_logic_vector(g_num_seg-1 downto 0); 
	--! segment data for digit 3
	i_dig_3 	  : in  std_logic_vector(g_num_seg-1 downto 0); 
	--! segment data for digit 3
	i_dig_4 	  : in  std_logic_vector(g_num_seg-1 downto 0);
	--! digit select; toggle b/w 1-4	 
	o_digit_sel	: out std_logic_vector(g_num_dig-1 downto 0); 
	--! current segment output
	o_sgmnt_dat : out std_logic_vector(g_num_seg-1 downto 0) 
); 
end sev_seg_drvr;

architecture rtl of sev_seg_drvr is

	constant c_shift_rate : integer := (g_clk_frq / g_ref_frq);	-- 45.8 kHz
	constant c_counter_size : natural := integer(ceil(log2(real(c_shift_rate))));

	signal r_shift_counter : std_logic_vector(c_counter_size-1 downto 0) := (others => '0');
	signal sr_digit_select : std_logic_vector(g_num_dig-1 downto 0) := (g_num_dig-2 downto 0 => '0') & '1'; --! current digit to drive out
	signal r_segment_data  : std_logic_vector(g_num_seg-1 downto 0) := (others => '0');                     --! current 7seg data vector to drive out

begin


	--! shift MSb to LSb when counter rolls over
	p_count_or_shift : process(i_clk) begin
		if(rising_edge(i_clk)) then
			if( r_shift_counter = std_logic_vector(to_unsigned(c_shift_rate, c_counter_size)) ) then
				r_shift_counter <= (others => '0');
				sr_digit_select <= sr_digit_select( sr_digit_select'high-1 downto 0) & sr_digit_select(sr_digit_select'high); 
			else
				r_shift_counter <= r_shift_counter + 1;
			end if;		
		end if;
	end process p_count_or_shift;	
	

	--! mux b/w [i_dig_1:i_dig_4] at c_shift_rate
	p_output_mux : process(i_clk) begin
		if(rising_edge(i_clk)) then
			if ( sr_digit_select(sr_digit_select'low) = '1' ) then
				r_segment_data <= i_dig_1;
			elsif ( sr_digit_select(sr_digit_select'low+1) = '1') then
				r_segment_data <= i_dig_2;
			elsif ( sr_digit_select(sr_digit_select'low+2) = '1') then
				r_segment_data <= i_dig_3;
			elsif ( sr_digit_select(sr_digit_select'low+3) = '1') then
				r_segment_data <= i_dig_4;
			end if;
		end if;
	end process p_output_mux;
	
	o_digit_sel <= sr_digit_select; -- active hi; common anode
  	o_sgmnt_dat <= not r_segment_data; -- active lo
	
end rtl;