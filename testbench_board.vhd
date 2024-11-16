LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY WORK;
USE WORK.HDMI_PARAMETERS.ALL;

ENTITY testbench_board IS
PORT (
    clk_125mhz : IN STD_LOGIC;
    HDMI_data_n : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    HDMI_data_p : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    HDMI_clk_n : OUT STD_LOGIC;
    HDMI_clk_p : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF testbench_board IS
    SIGNAL clk_250mhz, locked : STD_LOGIC;
    
    SIGNAL rom_addr : INTEGER RANGE 0 TO DISPLAY_RESOLUTION := 0;
    SIGNAL rom_data : rgb_t := (OTHERS => '0');
    SIGNAL channel_r, channel_g, channel_b : byte := (OTHERS => '0');
    SIGNAL clk_25mhz, video_en : STD_LOGIC := '0';
BEGIN
    CLK_DOUBLER : ENTITY WORK.clk_doubler
    PORT MAP (
        clk_in => clk_125mhz,
        reset => '0',
        clk_out => clk_250mhz,
        locked => locked
    );
    IMAGE_ROM: ENTITY WORK.image_rom
    PORT MAP (
        addr => rom_addr,
        dout => rom_data
    );
    VIDEO_SOURCE: ENTITY WORK.video_source
    PORT MAP (
        din => rom_data,
        clk => clk_25mhz,
        video_en => video_en,
        addr => rom_addr,
        channel_r => channel_r,
        channel_g => channel_g,
        channel_b => channel_b
    );
    HDMI_OUT: ENTITY WORK.hdmi_out
    PORT MAP (
        channel_r => channel_r,
        channel_g => channel_g,
        channel_b => channel_b,
        clk_250mhz => clk_250mhz,
        pixel_clk => clk_25mhz,
        video_en => video_en,
        HDMI_data_n => HDMI_data_n,
        HDMI_data_p => HDMI_data_p,
        HDMI_clk_n => HDMI_clk_n,
        HDMI_clk_p => HDMI_clk_p
    );
    
END ARCHITECTURE;