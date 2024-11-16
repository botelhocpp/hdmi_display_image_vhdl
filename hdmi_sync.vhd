LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.HDMI_PARAMETERS.ALL;

ENTITY hdmi_sync IS
PORT (
    clk_250mhz : IN STD_LOGIC;
    pixel_clk, video_en : OUT STD_LOGIC;
    hsync, vsync : OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE rtl OF hdmi_sync IS
    SIGNAL clk_25MHz, s_vsync, s_hsync, s_video_en : STD_LOGIC := '0';
    SIGNAL h_active, v_active : STD_LOGIC := '0';
BEGIN
    -- Generate 25MHz clock from 250MHz
    GENERATE_PIXEL_CLOCK:
    PROCESS(clk_250MHz)
      VARIABLE count: INTEGER RANGE 0 TO 5;
    BEGIN
        IF RISING_EDGE(clk_250MHz) THEN
            count := count + 1;
            IF (count = 5) THEN
                clk_25MHz <= NOT clk_25MHz;
                count := 0;
            END IF;
        END IF;
    END PROCESS;
    
    -- Horizontal Synchronization (at the of column) & Active
    HORIZONTAL_SYNC:
    PROCESS (clk_25MHz)
        VARIABLE hpos : INTEGER RANGE 0 TO H_MAX := 0;
    BEGIN          
        IF (RISING_EDGE(clk_25MHz)) THEN
            hpos := hpos + 1;
          
            IF (hpos = H_MAX) THEN
                s_hsync <= '0';
                hpos := 0;
            ELSIF (hpos = H_PULSE_WIDTH) THEN
                s_hsync <='1';
            ELSIF (hpos = H_PULSE_WIDTH + H_BACK_PORCH) THEN
                h_active <= '1';
            ELSIF (hpos = H_PULSE_WIDTH + H_BACK_PORCH + FRAME_WIDTH) THEN
                h_active <= '0';
            END IF;
        END IF;
    END PROCESS;
    
    -- Vertical Synchronization (at the of line) & Active
    VERTICAL_SYNC:  
    PROCESS (s_hsync)
        VARIABLE vpos : INTEGER RANGE 0 TO V_MAX := 0;
    BEGIN
        IF (FALLING_EDGE(s_hsync)) THEN
            vpos := vpos + 1;
            IF (vpos = V_MAX) THEN
                s_vsync <= '0';
                vpos := 0;
            ELSIF (vpos = V_PULSE_WIDTH) THEN
                s_vsync <='1';
            ELSIF (vpos = V_PULSE_WIDTH + V_BACK_PORCH) THEN
                v_active <= '1';
            ELSIF (vpos = V_PULSE_WIDTH + V_BACK_PORCH + FRAME_HEIGHT) THEN
                v_active <= '0';
            END IF;

        END IF;
    END PROCESS;

    pixel_clk <= clk_25MHz;
    s_video_en <= h_active AND v_active;
    video_en <= s_video_en;
    vsync <= s_vsync;
    hsync <= s_hsync;

END ARCHITECTURE;