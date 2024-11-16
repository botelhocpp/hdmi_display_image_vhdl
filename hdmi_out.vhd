LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.all;

LIBRARY WORK;
USE WORK.HDMI_PARAMETERS.ALL;

ENTITY hdmi_out IS
PORT (
    channel_r, channel_g, channel_b : IN byte;
    clk_250mhz : IN STD_LOGIC;
    pixel_clk, video_en : OUT STD_LOGIC;
    HDMI_data_p, HDMI_data_n : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    HDMI_clk_p, HDMI_clk_n : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE structural OF hdmi_out IS
    SIGNAL clk_25MHz, vsync, hsync, s_video_en : STD_LOGIC := '0';
    SIGNAL tmds_r_shift, tmds_g_shift, tmds_b_shift : STD_LOGIC := '0';
    SIGNAL tmds_r ,tmds_g, tmds_b: STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
BEGIN
    -- HDMI Syncronizer (generates Pixel clock, HSync, VSync, VDE signals)
    HDMI_SYNC: ENTITY WORK.hdmi_sync
    PORT MAP (
        clk_250mhz => clk_250mhz,
        pixel_clk => clk_25MHz,
        video_en => s_video_en,
        hsync => hsync,
        vsync => vsync
    );
    
    -- TMDS Channel Encoders
    TMDS_ENCODER_R: ENTITY WORK.tmds_encoder
    PORT MAP (  
        data => channel_r,
        clk => clk_25MHz,
        vde => s_video_en,
        c1 => '0',
        c0 => '0',
        q_out => tmds_r
    );
    TMDS_ENCODER_G: ENTITY WORK.tmds_encoder
    PORT MAP (  
        data => channel_g,
        clk => clk_25MHz,
        vde => s_video_en,
        c1 => '0',
        c0 => '0',
        q_out => tmds_g
    );
    TMDS_ENCODER_B: ENTITY WORK.tmds_encoder
    PORT MAP (  
        data => channel_b,
        clk => clk_25MHz,
        vde => s_video_en,
        c1 => vsync,
        c0 => hsync,
        q_out => tmds_b
    );

    -- Channel Shift Registers
    SHIFT_REGISTER_R: ENTITY WORK.shift_register
    GENERIC MAP(N => 10)
    PORT MAP (
        din => tmds_r,  
        clk => clk_250mhz,  
        dout => tmds_r_shift   
    );
    SHIFT_REGISTER_G: ENTITY WORK.shift_register
    GENERIC MAP(N => 10)
    PORT MAP (
        din => tmds_g,  
        clk => clk_250mhz,  
        dout => tmds_g_shift   
    );
    SHIFT_REGISTER_B: ENTITY WORK.shift_register
    GENERIC MAP(N => 10)
    PORT MAP (
        din => tmds_b,  
        clk => clk_250mhz,  
        dout => tmds_b_shift   
    );
 
    -- Create Differential Pairs (TMDS)
    OBUF_CLK : OBUFDS
    GENERIC MAP (IOSTANDARD =>"TMDS_33")
    PORT MAP (
        I => clk_25MHz,
        O => HDMI_clk_p,
        OB => HDMI_clk_n
    );
    OBUF_R : OBUFDS
    GENERIC MAP (IOSTANDARD =>"TMDS_33")
    PORT MAP (
        I => tmds_r_shift,
        O => HDMI_data_p(2),
        OB => HDMI_data_n(2)
    );
    OBUF_G : OBUFDS
    GENERIC MAP (IOSTANDARD =>"TMDS_33")
    PORT MAP (
        I => tmds_g_shift,
        O => HDMI_data_p(1),
        OB => HDMI_data_n(1)
    );
    OBUF_B : OBUFDS
    GENERIC MAP (IOSTANDARD =>"TMDS_33")
    PORT MAP (
        I => tmds_b_shift,
        O => HDMI_data_p(0),
        OB => HDMI_data_n(0)
    );
    
    pixel_clk <= clk_25MHz;
    video_en <= s_video_en;
END ARCHITECTURE;