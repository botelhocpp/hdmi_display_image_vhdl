LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.HDMI_PARAMETERS.ALL;

ENTITY video_source IS
PORT (
    din : IN rgb_t;
    clk : IN STD_LOGIC;
    video_en : IN STD_LOGIC;
    addr : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
    channel_r, channel_g, channel_b : OUT byte
);
END ENTITY;

ARCHITECTURE rtl OF video_source IS
BEGIN
    PROCESS(clk)
        CONSTANT IMG_WIDTH : INTEGER := 160;
        CONSTANT IMG_HEIGHT : INTEGER := 120;
        CONSTANT IMG_SIZE : INTEGER := IMG_WIDTH*IMG_HEIGHT;
        
        CONSTANT IMG_POS_X : INTEGER := 0;
        CONSTANT IMG_POS_Y : INTEGER := 0;
        
        CONSTANT SCALE_FACTOR : INTEGER := 4;
        CONSTANT SCALED_IMG_WIDTH : INTEGER := IMG_WIDTH * SCALE_FACTOR;
        CONSTANT SCALED_IMG_HEIGHT : INTEGER := IMG_HEIGHT * SCALE_FACTOR;
    
        VARIABLE h_counter : INTEGER RANGE 0 TO FRAME_WIDTH := 0;
        VARIABLE v_counter : INTEGER RANGE 0 TO FRAME_HEIGHT := 0;
        VARIABLE display_image : STD_LOGIC := '0';
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            IF (video_en = '1') THEN
                
                h_counter := h_counter + 1;
                IF(h_counter = FRAME_WIDTH) THEN
                    h_counter := 0;
                            
                    v_counter := v_counter + 1;
                    IF(v_counter = FRAME_HEIGHT) THEN
                        v_counter := 0;
                    END IF;
                END IF;
                
                IF(
                    (h_counter >= IMG_POS_X) AND (h_counter < IMG_POS_X + SCALED_IMG_WIDTH) AND
                    (v_counter >= IMG_POS_Y) AND (v_counter < IMG_POS_Y + SCALED_IMG_HEIGHT)
                ) THEN
                    display_image := '1';
                ELSE
                    display_image := '0';
                END IF;
                
                IF(display_image = '1') THEN
                    channel_r <= din(23 DOWNTO 16);
                    channel_g <= din(15 DOWNTO 8);
                    channel_b <= din(7 DOWNTO 0);
                ELSE
                    channel_r <= (OTHERS => '0');
                    channel_g <= (OTHERS => '0');
                    channel_b <= (OTHERS => '0');
                END IF;
            END IF;
            
            addr <= STD_LOGIC_VECTOR(
                TO_UNSIGNED(((v_counter - IMG_POS_Y) / SCALE_FACTOR) * IMG_WIDTH +
                (h_counter - IMG_POS_X) / SCALE_FACTOR, 15)
            );
        END IF;
    END PROCESS;

END ARCHITECTURE;